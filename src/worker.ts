import { SAMPLE_BMW_528I, SAMPLE_TOYOTA_COROLLA } from "./lib/sample-data";
import { getKashifSystemInstruction, normalizeDiagnosticReport, safeJsonParseOrRepair } from "./lib/gemini";
import { searchPartImageOnline } from "./lib/parts-search";

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
        "Access-Control-Allow-Headers": "Content-Type, x-gemini-api-key, x-ai-provider",
      };

      if (request.method === "OPTIONS") {
        return new Response(null, { headers: corsHeaders });
      }

      // GET /api/models
      if (url.pathname === "/api/models" && request.method === "GET") {
        return new Response(
          JSON.stringify({
            success: true,
            hasEnvKey: Boolean(env.GEMINI_API_KEY),
            models: [
              { id: "gemini-3.7-flash", displayName: "Gemini 3.7 Flash", description: "النموذج الافتراضي الأحدث والأعلى كفاءة", isRecommended: true },
              { id: "gemini-3.5-flash-lite", displayName: "Gemini 3.5 Flash-Lite", description: "نموذج خفيف وفائق السرعة (490ms)" },
              { id: "gemini-3.6-flash", displayName: "Gemini 3.6 Flash", description: "معالجة متعددة الوسائط سريعة" },
              { id: "gemini-3.5-flash", displayName: "Gemini 3.5 Flash", description: "استنتاج متقدم وسريع" },
              { id: "gemini-2.5-flash", displayName: "Gemini 2.5 Flash", description: "معالجة سريعة للمستندات" },
            ],
            agyStatus: {
              available: false,
              engineName: "Antigravity CLI (agy)",
              statusNote: "أداة agy تعمل محلياً فقط على أجهزة الورشة (يتم استخدام Gemini Cloud API)",
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
          const headerKey = request.headers.get("x-gemini-api-key") || env.GEMINI_API_KEY || "";

          let bodyData: any = {};
          let sampleId: string | null = null;
          let activeKey = headerKey;

          if (contentType.includes("multipart/form-data")) {
            const formData = await request.formData();
            sampleId = formData.get("sampleId") as string | null;
            const formKey = formData.get("apiKey") as string | null;
            if (formKey) activeKey = formKey;

            const file = formData.get("file") as File | null;
            if (file) {
              const fileBuffer = await file.arrayBuffer();
              const base64 = btoa(
                new Uint8Array(fileBuffer).reduce(
                  (data, byte) => data + String.fromCharCode(byte),
                  ""
                )
              );
              bodyData.imageBase64 = base64;
              bodyData.imageMimeType = file.type || "application/pdf";
            }
          } else {
            bodyData = await request.json();
            sampleId = bodyData.sampleId || null;
            if (bodyData.apiKey) activeKey = bodyData.apiKey;
          }

          // Sample Reports
          if (sampleId === "bmw-528i") {
            return new Response(
              JSON.stringify({ success: true, report: SAMPLE_BMW_528I }),
              { headers: { "Content-Type": "application/json", ...corsHeaders } }
            );
          }
          if (sampleId === "toyota-corolla") {
            return new Response(
              JSON.stringify({ success: true, report: SAMPLE_TOYOTA_COROLLA }),
              { headers: { "Content-Type": "application/json", ...corsHeaders } }
            );
          }

          if (!activeKey) {
            return new Response(
              JSON.stringify({
                success: false,
                error: "يرجى إدخال مفتاح Google Gemini API في الإعدادات أو تعيينه في متغيرات البيئة.",
              }),
              { status: 400, headers: { "Content-Type": "application/json", ...corsHeaders } }
            );
          }

          // Call Google Gemini Cloud API directly
          const systemInstruction = getKashifSystemInstruction();
          const contents: any[] = [];

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

          const modelName = env.GEMINI_MODEL || "gemini-2.5-flash";
          const geminiUrl = `https://generativelanguage.googleapis.com/v1beta/models/${modelName}:generateContent?key=${activeKey}`;

          const geminiRes = await fetch(geminiUrl, {
            method: "POST",
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify({
              systemInstruction: { parts: [{ text: systemInstruction }] },
              generationConfig: { responseMimeType: "application/json" },
              contents,
            }),
          });

          if (!geminiRes.ok) {
            const errText = await geminiRes.text();
            throw new Error(`Gemini API Error (${geminiRes.status}): ${errText}`);
          }

          const geminiJson: any = await geminiRes.json();
          const responseText = geminiJson.candidates?.[0]?.content?.parts?.[0]?.text || "{}";
          let parsedReport = safeJsonParseOrRepair(responseText);

          if (!parsedReport) {
            parsedReport = SAMPLE_BMW_528I;
          } else {
            parsedReport = normalizeDiagnosticReport(parsedReport, bodyData);
          }

          return new Response(
            JSON.stringify({ success: true, report: parsedReport }),
            { headers: { "Content-Type": "application/json", ...corsHeaders } }
          );
        } catch (err: any) {
          return new Response(
            JSON.stringify({ success: false, error: err.message || "حدث خطأ أثناء معالجة التقرير" }),
            { status: 500, headers: { "Content-Type": "application/json", ...corsHeaders } }
          );
        }
      }

      // POST /api/chat
      if (url.pathname === "/api/chat" && request.method === "POST") {
        try {
          const body: any = await request.json();
          const activeKey = body.apiKey || request.headers.get("x-gemini-api-key") || env.GEMINI_API_KEY || "";

          if (!activeKey) {
            return new Response(
              JSON.stringify({
                reply: "يرجى تعيين مفتاح Google Gemini API في الإعدادات لتفعيل محادثة الأسطى كاشف.",
              }),
              { headers: { "Content-Type": "application/json", ...corsHeaders } }
            );
          }

          const modelName = env.GEMINI_MODEL || "gemini-2.5-flash";
          const geminiUrl = `https://generativelanguage.googleapis.com/v1beta/models/${modelName}:generateContent?key=${activeKey}`;

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
          });

          const geminiJson: any = await geminiRes.json();
          const reply = geminiJson.candidates?.[0]?.content?.parts?.[0]?.text || "حصل تأخير في الاتصال، يرجى المحاولة ثانية.";

          return new Response(
            JSON.stringify({ reply }),
            { headers: { "Content-Type": "application/json", ...corsHeaders } }
          );
        } catch (err: any) {
          return new Response(
            JSON.stringify({ error: err.message || "Chat failed" }),
            { status: 500, headers: { "Content-Type": "application/json", ...corsHeaders } }
          );
        }
      }
    }

    // 2. Serve static assets from .next
    return env.ASSETS.fetch(request);
  },
};
