import type { ChatReportContext, KashifDiagnosticReport } from "./types";

/**
 * The browser's side of the API.
 *
 * Three copies of the same fetch-parse-report dance lived in UploadDropzone,
 * each with its own `catch (err: any)` and none with a timeout — a request
 * that never came back left the spinner running forever with no way out. The
 * settings lookup was copied three times too, so a change to how the key is
 * stored had to be made in three places or the key silently stopped being
 * sent on one path.
 */

/**
 * Long enough for a real analysis with a model fallback behind it (the server
 * gives each model attempt 45s), short enough to fail rather than hang.
 */
const ANALYZE_TIMEOUT_MS = 120_000;
const CHAT_TIMEOUT_MS = 60_000;

export const STORAGE_KEYS = {
  apiKey: "kashif_gemini_api_key",
  provider: "kashif_ai_provider",
  model: "kashif_gemini_model",
} as const;

export interface ClientSettings {
  apiKey: string;
  provider: string;
  model: string;
}

/** Reads the user's settings. Safe on the server, where there is no storage. */
export function readSettings(): ClientSettings {
  if (typeof window === "undefined") {
    return { apiKey: "", provider: "gemini", model: "" };
  }
  try {
    return {
      apiKey: localStorage.getItem(STORAGE_KEYS.apiKey) || "",
      provider: localStorage.getItem(STORAGE_KEYS.provider) || "gemini",
      model: localStorage.getItem(STORAGE_KEYS.model) || "",
    };
  } catch {
    // Private browsing, or storage disabled. The app still works; the user is
    // asked for a key again next time.
    return { apiKey: "", provider: "gemini", model: "" };
  }
}

function settingsHeaders(s: ClientSettings): Record<string, string> {
  const headers: Record<string, string> = { "x-ai-provider": s.provider };
  if (s.apiKey) headers["x-gemini-api-key"] = s.apiKey;
  if (s.model) headers["x-gemini-model"] = s.model;
  return headers;
}

/**
 * An error already phrased for the user, in Arabic.
 *
 * The server's `errorPayload` deliberately never forwards an upstream message,
 * because a Gemini error body can quote the caller's own key back. Whatever
 * reaches here is either one of our own messages or a generic one.
 */
export class ApiError extends Error {
  constructor(message: string) {
    super(message);
    this.name = "ApiError";
  }
}

/** Whatever went wrong, said in Arabic. Never leaks an upstream body. */
export function messageOf(err: unknown, fallback: string): string {
  if (err instanceof ApiError) return err.message;
  if (err instanceof DOMException && err.name === "AbortError") {
    return "انتهت مهلة الطلب. جرب مرة ثانية أو اختر نموذجاً أسرع من الإعدادات.";
  }
  if (err instanceof TypeError) {
    return "تعذر الاتصال بالخادم. تحقق من الإنترنت وحاول مرة ثانية.";
  }
  return fallback;
}

interface ApiEnvelope {
  success?: boolean;
  error?: string;
  report?: KashifDiagnosticReport;
  reply?: string;
}

/**
 * Posts to an API route under a timeout and returns the parsed envelope.
 *
 * `signal` lets a caller cancel too — the chat panel uses it so a second
 * question abandons the first instead of racing it.
 */
async function post(
  path: string,
  init: RequestInit,
  timeoutMs: number,
  signal?: AbortSignal
): Promise<ApiEnvelope> {
  const timeout = AbortSignal.timeout(timeoutMs);
  const res = await fetch(path, {
    ...init,
    method: "POST",
    signal: signal ? AbortSignal.any([signal, timeout]) : timeout,
  });

  // Read as text first: an error from the platform rather than the route (a
  // 502, a size limit) is HTML, and JSON.parse on it threw a SyntaxError that
  // reached the user as "Unexpected token <".
  const raw = await res.text();
  let data: ApiEnvelope;
  try {
    data = JSON.parse(raw) as ApiEnvelope;
  } catch {
    throw new ApiError(
      res.ok
        ? "تعذر قراءة رد الخادم."
        : `تعذر إكمال الطلب (${res.status}). تحقق من إعدادات المفتاح في الإعدادات.`
    );
  }

  if (!res.ok || data.success === false) {
    throw new ApiError(data.error || "تعذر إكمال الطلب.");
  }
  return data;
}

function reportOf(data: ApiEnvelope): KashifDiagnosticReport {
  if (!data.report) throw new ApiError("لم يصل تقرير من الخادم.");
  return data.report;
}

/** One of the two bundled demo reports. */
export async function loadSampleReport(
  sampleId: "bmw-528i" | "toyota-corolla"
): Promise<KashifDiagnosticReport> {
  const data = await post(
    "/api/analyze",
    {
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ sampleId }),
    },
    30_000
  );
  return reportOf(data);
}

/** A scanner PDF or a photo of a scanner screen. */
export async function analyzeFile(
  file: File
): Promise<KashifDiagnosticReport> {
  const settings = readSettings();
  const form = new FormData();
  form.append("file", file);
  form.append("provider", settings.provider);
  if (settings.apiKey) form.append("apiKey", settings.apiKey);
  // The settings model picker used to write this to localStorage and stop
  // there, so the user's choice never reached the API.
  if (settings.model) form.append("model", settings.model);

  const data = await post(
    "/api/analyze",
    { headers: settingsHeaders(settings), body: form },
    ANALYZE_TIMEOUT_MS
  );
  return reportOf(data);
}

/** Codes typed in by hand. */
export async function analyzeCodes(input: {
  manualCodes: string;
  vin?: string;
  makeModel?: string;
}): Promise<KashifDiagnosticReport> {
  const settings = readSettings();
  const data = await post(
    "/api/analyze",
    {
      headers: { "Content-Type": "application/json", ...settingsHeaders(settings) },
      body: JSON.stringify({
        manualCodes: input.manualCodes,
        apiKey: settings.apiKey || undefined,
        model: settings.model || undefined,
        provider: settings.provider,
        vehicleInfo: { vin: input.vin, make: input.makeModel },
      }),
    },
    ANALYZE_TIMEOUT_MS
  );
  return reportOf(data);
}

/**
 * A question for the assistant, answered a piece at a time.
 *
 * `report` is trimmed to what the prompt actually reads before it leaves the
 * browser — see `chatContextOf`. The full report used to be re-serialised and
 * uploaded on every single message.
 *
 * The reply arrives as newline-delimited JSON. Anything that fails before the
 * first token still comes back as an ordinary JSON error with a status code,
 * so the key and quota messages are unchanged; the content type is what tells
 * the two apart.
 */
export async function* streamAssistant(
  report: KashifDiagnosticReport,
  question: string,
  history: { sender: "user" | "assistant"; text: string }[],
  signal?: AbortSignal
): AsyncGenerator<string> {
  const settings = readSettings();
  const timeout = AbortSignal.timeout(CHAT_TIMEOUT_MS);

  const res = await fetch("/api/chat", {
    method: "POST",
    headers: { "Content-Type": "application/json", ...settingsHeaders(settings) },
    body: JSON.stringify({
      report: chatContextOf(report),
      question,
      history,
      apiKey: settings.apiKey || undefined,
      model: settings.model || undefined,
      provider: settings.provider,
    }),
    signal: signal ? AbortSignal.any([signal, timeout]) : timeout,
  });

  if (!res.headers.get("content-type")?.includes("ndjson")) {
    const raw = await res.text();
    let data: ApiEnvelope;
    try {
      data = JSON.parse(raw) as ApiEnvelope;
    } catch {
      throw new ApiError(
        res.ok
          ? "تعذر قراءة رد الخادم."
          : `تعذر إكمال الطلب (${res.status}). تحقق من إعدادات المفتاح في الإعدادات.`
      );
    }
    throw new ApiError(data.error || "تعذر إكمال الطلب.");
  }

  if (!res.body) throw new ApiError("لم يصل رد من المساعد.");

  const reader = res.body.pipeThrough(new TextDecoderStream()).getReader();
  let buffer = "";
  let sawText = false;

  try {
    for (;;) {
      const { done, value } = await reader.read();
      if (done) break;
      buffer += value;

      // A chunk boundary lands anywhere, including the middle of a multi-byte
      // Arabic character or halfway through a JSON object. Only complete
      // lines are parsed; the remainder waits for the next read.
      let cut = buffer.indexOf("\n");
      while (cut !== -1) {
        const raw = buffer.slice(0, cut).trim();
        buffer = buffer.slice(cut + 1);
        cut = buffer.indexOf("\n");
        if (!raw) continue;

        let event: { delta?: string; error?: string; done?: boolean };
        try {
          event = JSON.parse(raw);
        } catch {
          continue;
        }
        if (event.error) throw new ApiError(event.error);
        if (event.delta) {
          sawText = true;
          yield event.delta;
        }
      }
    }
  } finally {
    // Leaving the loop early — the caller stopped reading, or the question was
    // superseded — must not leave the body open.
    await reader.cancel().catch(() => {});
  }

  if (!sawText) throw new ApiError("لم يصل رد من المساعد.");
}

/**
 * The slice of a report the assistant prompt reads.
 *
 * The assistant prompt uses the vehicle, the summary, the critical and
 * moderate fault codes, and the part names — and nothing else. Sending the
 * whole report meant every message carried the full checklist, every fault's
 * symptoms and root causes, and the entire electrical diagnostics block with
 * its pin voltages and diagram coordinates, on a connection that in Libya is
 * often a phone's. On a report with a dozen faults that is most of a
 * megabyte re-uploaded per question.
 */
export function chatContextOf(report: KashifDiagnosticReport): ChatReportContext {
  const codes = (list: { code: string; libyanTerm: string }[] = []) =>
    list.map((f) => ({ code: f.code, libyanTerm: f.libyanTerm }));

  return {
    vehicle: report.vehicle,
    summary: {
      overallHealthScore: report.summary.overallHealthScore,
      severityStatus: report.summary.severityStatus,
      briefSummaryArabic: report.summary.briefSummaryArabic,
    },
    faultCategories: {
      criticalFaults: codes(report.faultCategories.criticalFaults),
      moderateFaults: codes(report.faultCategories.moderateFaults),
    },
    sparePartsRequired: report.sparePartsRequired.map((p) => ({
      partNameLibyan: p.partNameLibyan,
      oemPartNumber: p.oemPartNumber,
    })),
  };
}
