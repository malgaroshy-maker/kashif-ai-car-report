import { SAMPLE_BMW_528I, SAMPLE_TOYOTA_COROLLA } from "./lib/sample-data";
import { getKashifSystemInstruction, normalizeDiagnosticReport, safeJsonParseOrRepair } from "./lib/gemini";
import { searchPartImageOnline } from "./lib/parts-search";
import { KashifError, errorPayload, fromUpstreamStatus } from "./lib/errors";
import { DEFAULT_MODEL, KNOWN_MODELS, fetchLiveModels, resolveModelId } from "./lib/models";

/** Uploads are base64'd into the request to Gemini; cap them before that. */
const MAX_UPLOAD_BYTES = 8 * 1024 * 1024;

/**
 * Chunked base64. The previous version built the string with
 * `bytes.reduce((s, b) => s + String.fromCharCode(b), "")`, which is quadratic
 * and exhausts the Worker CPU budget on a multi-megabyte PDF.
 */
function toBase64(buffer: ArrayBuffer): string {
  const bytes = new Uint8Array(buffer);
  const CHUNK = 0x8000;
  let binary = "";
  for (let i = 0; i < bytes.length; i += CHUNK) {
    binary += String.fromCharCode(...bytes.subarray(i, i + CHUNK));
  }
  return btoa(binary);
}

interface Env {
  ASSETS: { fetch: (request: Request) => Promise<Response> };
  GEMINI_API_KEY?: string;
  GEMINI_MODEL?: string;
}

export default {
  async fetch(request: Request, env: Env): Promise<Response> {
    const url = new URL(request.url);

    // 1. Handle API routes on Cloudflare Edge
    if (url.pathname.startsWith("/api/")) {
      const corsHeaders = {
        "Access-Control-Allow-Origin": "*",
        "Access-Control-Allow-Methods": "GET, POST, OPTIONS",
        "Access-Control-Allow-Headers": "Content-Type, x-gemini-api-key, x-ai-provider, x-gemini-model",
      };

      if (request.method === "OPTIONS") {
        return new Response(null, { headers: corsHeaders });
      }

      // GET /api/models
      if (url.pathname === "/api/models" && request.method === "GET") {
        const key = request.headers.get("x-gemini-api-key") || env.GEMINI_API_KEY || "";
        // With a key, Google is the authority on what exists; without one the
        // shared offline list is returned so settings still renders something.
        const models = key ? await fetchLiveModels(key) : KNOWN_MODELS;
        return new Response(
          JSON.stringify({
            success: true,
            hasEnvKey: Boolean(env.GEMINI_API_KEY),
            defaultModel: DEFAULT_MODEL,
            models,
            agyStatus: {
              available: false,
              engineName: "Antigravity CLI (agy)",
              statusNote:
                "أداة agy تعمل محلياً فقط على أجهزة الورشة (يتم استخدام Gemini Cloud API)",
            },
          }),
          { headers: { "Content-Type": "application/json", ...corsHeaders } }
        );
      }

      // GET /api/parts-image
      if (url.pathname === "/api/parts-image" && request.method === "GET") {
        const make = url.searchParams.get("make") || "";
        const model = url.searchParams.get("model") || "";
        const year = url.searchParams.get("year") || "";
        const oem = url.searchParams.get("oem") || "";
        const partName = url.searchParams.get("partName") || "";

        const imageUrl = await searchPartImageOnline(oem, partName, make, model, year);
        return new Response(
          JSON.stringify({ success: true, imageUrl: imageUrl || null }),
          { headers: { "Content-Type": "application/json", ...corsHeaders } }
        );
      }

      // POST /api/analyze
      if (url.pathname === "/api/analyze" && request.method === "POST") {
        try {
          const contentType = request.headers.get("content-type") || "";
          const headerKey =
            request.headers.get("x-gemini-api-key") || env.GEMINI_API_KEY || "";

          const bodyData: {
            imageBase64?: string;
            imageMimeType?: string;
            textReport?: string;
            manualCodes?: string;
            vehicleInfo?: Record<string, unknown>;
            model?: string;
          } = {};
          let sampleId: string | null = null;
          let activeKey = headerKey;
          let requestedModel: string | null =
            request.headers.get("x-gemini-model") || null;

          if (contentType.includes("multipart/form-data")) {
            const formData = await request.formData();
            sampleId = formData.get("sampleId") as string | null;
            const formKey = formData.get("apiKey") as string | null;
            if (formKey) activeKey = formKey;
            const formModel = formData.get("model") as string | null;
            if (formModel) requestedModel = formModel;

            const file = formData.get("file") as File | null;
            if (file) {
              if (file.size > MAX_UPLOAD_BYTES) {
                throw new KashifError("FILE_TOO_LARGE", `${file.size} bytes`);
              }
              const mime = file.type || "application/pdf";
              if (
                !/^(application\/pdf|image\/(jpeg|png|webp))$/.test(mime)
              ) {
                throw new KashifError("UNSUPPORTED_FILE", mime);
              }
              bodyData.imageBase64 = toBase64(await file.arrayBuffer());
              bodyData.imageMimeType = mime;
            }
          } else {
            const json = (await request.json()) as Record<string, unknown>;
            Object.assign(bodyData, json);
            sampleId = (json.sampleId as string) || null;
            if (json.apiKey) activeKey = json.apiKey as string;
            if (json.model) requestedModel = json.model as string;
          }

          // The two demos are the only reports served without analysis, and
          // they are requested explicitly by id — never substituted silently.
          if (sampleId === "bmw-528i") {
            return new Response(
              JSON.stringify({ success: true, report: SAMPLE_BMW_528I, sample: true }),
              { headers: { "Content-Type": "application/json", ...corsHeaders } }
            );
          }
          if (sampleId === "toyota-corolla") {
            return new Response(
              JSON.stringify({ success: true, report: SAMPLE_TOYOTA_COROLLA, sample: true }),
              { headers: { "Content-Type": "application/json", ...corsHeaders } }
            );
          }

          if (!activeKey) throw new KashifError("NO_API_KEY");
          if (!bodyData.imageBase64 && !bodyData.textReport && !bodyData.manualCodes) {
            throw new KashifError("NO_INPUT");
          }

          const systemInstruction = getKashifSystemInstruction();
          const contents: unknown[] = [];

          if (bodyData.imageBase64) {
            contents.push({
              parts: [
                {
                  inlineData: {
                    mimeType: bodyData.imageMimeType || "application/pdf",
                    data: bodyData.imageBase64,
                  },
                },
                {
                  text: "حلل مستند فحص السيارة وأكواد الأعطال وقدم التقرير التشخيصي الفني بالقاموس الليبي بصيغة JSON.",
                },
              ],
            });
          } else {
            const promptText = `حلل بيانات الفحص التالية:
${bodyData.textReport ? `تقرير الفحص:\n${bodyData.textReport}\n` : ""}
${bodyData.manualCodes ? `أكواد الأعطال:\n${bodyData.manualCodes}\n` : ""}
${bodyData.vehicleInfo ? `السيارة: ${JSON.stringify(bodyData.vehicleInfo)}\n` : ""}
`;
            contents.push({ parts: [{ text: promptText }] });
          }

          // The user's choice first, then the app's advertised default. This
          // used to hardcode gemini-2.5-flash, so the deployed site silently
          // ran two generations below what the UI showed.
          const modelName = resolveModelId(
            requestedModel || env.GEMINI_MODEL || DEFAULT_MODEL
          );
          const geminiUrl = `https://generativelanguage.googleapis.com/v1beta/models/${modelName}:generateContent?key=${encodeURIComponent(activeKey)}`;

          const geminiRes = await fetch(geminiUrl, {
            method: "POST",
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify({
              systemInstruction: { parts: [{ text: systemInstruction }] },
              generationConfig: { responseMimeType: "application/json" },
              contents,
            }),
            signal: AbortSignal.timeout(45_000),
          });

          if (!geminiRes.ok) {
            // The upstream body can echo the key back; keep it out of the client.
            throw fromUpstreamStatus(geminiRes.status, await geminiRes.text());
          }

          const geminiJson = (await geminiRes.json()) as {
            candidates?: { content?: { parts?: { text?: string }[] } }[];
          };
          const responseText =
            geminiJson.candidates?.[0]?.content?.parts?.[0]?.text || "";
          const parsedReport = safeJsonParseOrRepair(responseText);

          // THE bug this whole pass exists for: this used to be
          // `parsedReport = SAMPLE_BMW_528I`, handing the BMW demo to whoever
          // uploaded a scan that failed to parse — presented as their own car.
          if (!parsedReport) throw new KashifError("UNREADABLE_RESPONSE");

          return new Response(
            JSON.stringify({
              success: true,
              report: normalizeDiagnosticReport(parsedReport, bodyData),
              model: modelName,
            }),
            { headers: { "Content-Type": "application/json", ...corsHeaders } }
          );
        } catch (err) {
          const { body, status } = errorPayload(err);
          if (err instanceof KashifError) {
            console.warn(`[analyze] ${err.code}: ${err.detail ?? ""}`);
          } else {
            console.error("[analyze] unexpected", err);
          }
          return new Response(JSON.stringify(body), {
            status,
            headers: { "Content-Type": "application/json", ...corsHeaders },
          });
        }
      }

      // POST /api/chat
      if (url.pathname === "/api/chat" && request.method === "POST") {
        try {
          const body = (await request.json()) as {
            apiKey?: string;
            model?: string;
            question?: string;
            report?: { vehicle?: unknown; faultCategories?: unknown };
          };
          const activeKey =
            body.apiKey || request.headers.get("x-gemini-api-key") || env.GEMINI_API_KEY || "";

          if (!activeKey) {
            return new Response(
              JSON.stringify({
                reply: "يرجى تعيين مفتاح Google Gemini API في الإعدادات لتفعيل محادثة الأسطى كاشف.",
              }),
              { headers: { "Content-Type": "application/json", ...corsHeaders } }
            );
          }

          const modelName = resolveModelId(
            body.model || env.GEMINI_MODEL || DEFAULT_MODEL
          );
          const geminiUrl = `https://generativelanguage.googleapis.com/v1beta/models/${modelName}:generateContent?key=${encodeURIComponent(activeKey)}`;

          const prompt = `أنت "الأسطى كاشف"، فني ميكانيكا وفاحص سيارات ليبي خبير في ورش الصيانة.
سياق السيارة: ${JSON.stringify(body.report?.vehicle || {})}
الأعطال: ${JSON.stringify(body.report?.faultCategories || {})}
سؤال السائق / الورشة: "${body.question}"
أجب بلهجة ليبية فنية محترمة وقدم نصائح عملية واضحة وسريعة:`;

          const geminiRes = await fetch(geminiUrl, {
            method: "POST",
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify({
              contents: [{ parts: [{ text: prompt }] }],
            }),
            signal: AbortSignal.timeout(30_000),
          });

          if (!geminiRes.ok) {
            throw fromUpstreamStatus(geminiRes.status, await geminiRes.text());
          }

          const geminiJson = (await geminiRes.json()) as {
            candidates?: { content?: { parts?: { text?: string }[] } }[];
          };
          const reply = geminiJson.candidates?.[0]?.content?.parts?.[0]?.text;
          if (!reply) throw new KashifError("UNREADABLE_RESPONSE");

          return new Response(
            JSON.stringify({ reply }),
            { headers: { "Content-Type": "application/json", ...corsHeaders } }
          );
        } catch (err) {
          const { body: payload, status } = errorPayload(err);
          return new Response(JSON.stringify({ ...payload, reply: null }), {
            status,
            headers: { "Content-Type": "application/json", ...corsHeaders },
          });
        }
      }
    }

    // 2. Serve static assets from .next
    return env.ASSETS.fetch(request);
  },
};
