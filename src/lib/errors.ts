/**
 * Typed failures with a message the workshop can act on.
 *
 * This file exists because of the worst bug in the codebase: the analyze path
 * used to answer every failure by returning a *different car's report* — the
 * BMW demo, or a locally invented one — with no indication anything had gone
 * wrong. A mechanic acting on that replaces parts that were never faulty.
 *
 * The rule this encodes: a failure is reported, never papered over with
 * plausible-looking data. "Fallback" may mean a slower model or a cached
 * value. It may never mean substituted findings.
 */

export type KashifErrorCode =
  | "NO_API_KEY"
  | "INVALID_API_KEY"
  | "QUOTA_EXCEEDED"
  | "MODEL_UNAVAILABLE"
  | "UNREADABLE_RESPONSE"
  | "NO_INPUT"
  | "FILE_TOO_LARGE"
  | "UNSUPPORTED_FILE"
  | "UPSTREAM_ERROR";

/** Arabic, in the register the rest of the product uses. */
const MESSAGES: Record<KashifErrorCode, string> = {
  NO_API_KEY:
    "ما فيش مفتاح Google Gemini. افتح الإعدادات وحط مفتاحك باش تقدر تحلل تقارير حقيقية.",
  INVALID_API_KEY:
    "المفتاح المدخل مرفوض من Google. تأكد منه في الإعدادات وجرب ثاني.",
  QUOTA_EXCEEDED:
    "حصة المفتاح خلصت أو تجاوزت الحد المسموح. جرب بعد شوية أو استعمل مفتاح ثاني.",
  MODEL_UNAVAILABLE:
    "كل النماذج المتاحة مشغولة أو غير متوفرة حالياً. جرب بعد دقيقة.",
  UNREADABLE_RESPONSE:
    "الرد اللي جا من محرك التحليل ما كانش مقروء، وما نقدروش نطلع تقرير من غير بيانات مؤكدة. جرب ترفع التقرير ثاني.",
  NO_INPUT: "ما وصلنا أي ملف أو أكواد للفحص.",
  FILE_TOO_LARGE: "حجم الملف كبير. الحد الأقصى 8 ميجابايت.",
  UNSUPPORTED_FILE:
    "نوع الملف غير مدعوم. ارفع PDF أو صورة (JPEG / PNG / WebP).",
  UPSTREAM_ERROR: "حصل خطأ أثناء الاتصال بمحرك التحليل. جرب ثاني.",
};

const STATUS: Record<KashifErrorCode, number> = {
  NO_API_KEY: 400,
  INVALID_API_KEY: 401,
  QUOTA_EXCEEDED: 429,
  MODEL_UNAVAILABLE: 503,
  UNREADABLE_RESPONSE: 502,
  NO_INPUT: 400,
  FILE_TOO_LARGE: 413,
  UNSUPPORTED_FILE: 415,
  UPSTREAM_ERROR: 502,
};

export class KashifError extends Error {
  readonly code: KashifErrorCode;
  readonly status: number;
  /** Technical detail for the server log. Never sent to the client — an
   *  upstream error body can echo the user's own API key. */
  readonly detail?: string;

  constructor(code: KashifErrorCode, detail?: string) {
    super(MESSAGES[code]);
    this.name = "KashifError";
    this.code = code;
    this.status = STATUS[code];
    this.detail = detail;
  }
}

/** Maps an upstream Gemini HTTP status onto our vocabulary. */
export function fromUpstreamStatus(status: number, detail?: string): KashifError {
  if (status === 400 || status === 401 || status === 403)
    return new KashifError("INVALID_API_KEY", detail);
  if (status === 429) return new KashifError("QUOTA_EXCEEDED", detail);
  if (status === 404) return new KashifError("MODEL_UNAVAILABLE", detail);
  if (status >= 500) return new KashifError("MODEL_UNAVAILABLE", detail);
  return new KashifError("UPSTREAM_ERROR", detail);
}

/**
 * The single shape every failing endpoint returns. `code` lets the UI decide
 * what to offer next (open settings, retry, pick another file) instead of
 * pattern-matching on a message string.
 */
export function errorPayload(err: unknown): {
  body: { success: false; error: string; code: KashifErrorCode };
  status: number;
} {
  if (err instanceof KashifError) {
    return {
      body: { success: false, error: err.message, code: err.code },
      status: err.status,
    };
  }
  return {
    body: {
      success: false,
      error: MESSAGES.UPSTREAM_ERROR,
      code: "UPSTREAM_ERROR",
    },
    status: 502,
  };
}
