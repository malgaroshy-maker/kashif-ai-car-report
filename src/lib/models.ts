/**
 * The one place model IDs live.
 *
 * Before this existed, `gemini.ts`, `worker.ts` and `Header.tsx` each carried
 * their own hardcoded list and they had already drifted: the Worker defaulted
 * to `gemini-2.5-flash` while the UI advertised `gemini-3.7-flash`, so the
 * deployed site silently ran two generations below what it claimed.
 *
 * Edge-safe: no `fs`, no `process.cwd()`. The Worker imports this directly.
 *
 * The IDs below were verified against `GET /v1beta/models` on 2026-08-24. When
 * a key is available the live endpoint is the authority and this list is only
 * the offline fallback — that is what stops it drifting again.
 */

export interface AvailableModelItem {
  id: string;
  displayName: string;
  description: string;
  isRecommended?: boolean;
}

/** What the app advertises, and what every runtime must actually use. */
export const DEFAULT_MODEL = "gemini-3.6-flash";

/**
 * Tried in order when a model is unavailable (503 high demand, 429 quota).
 * Availability ladder: newest and fastest active 3.x models first.
 */
export const MODEL_FALLBACK_CHAIN = [
  DEFAULT_MODEL,
  "gemini-3.7-flash",
  "gemini-3.5-flash",
  "gemini-3.5-flash-lite",
  "gemini-3.1-flash-lite",
  "gemini-3.1-pro-preview",
] as const;

/** Shown when there is no key to query the live endpoint with. */
export const KNOWN_MODELS: AvailableModelItem[] = [
  {
    id: "gemini-3.6-flash",
    displayName: "Gemini 3.6 Flash",
    description: "النموذج الافتراضي — معالجة سريعة ودقيقة للتقارير والأعطال",
    isRecommended: true,
  },
  {
    id: "gemini-3.7-flash",
    displayName: "Gemini 3.7 Flash",
    description: "استنتاج متقدم ومعالجة شاملة للتقارير المعقدة",
  },
  {
    id: "gemini-3.5-flash",
    displayName: "Gemini 3.5 Flash",
    description: "استنتاج متقدم وسريع",
  },
  {
    id: "gemini-3.5-flash-lite",
    displayName: "Gemini 3.5 Flash-Lite",
    description: "نموذج خفيف وفائق السرعة",
  },
  {
    id: "gemini-3.1-flash-lite",
    displayName: "Gemini 3.1 Flash-Lite",
    description: "معالجة خفيفة وموفرة للحصة",
  },
  {
    id: "gemini-3.1-pro-preview",
    displayName: "Gemini 3.1 Pro (Preview)",
    description: "الاستنتاج الهندسي المتقدم للتقارير المعقدة",
  },
];

const KNOWN_IDS = new Set(KNOWN_MODELS.map((m) => m.id));

/**
 * Guards a model ID coming from a client. A user's stored preference can name a
 * model Google has since retired, and an unvalidated id would 404 every
 * request; falling back to the advertised default is the honest recovery.
 */
export function resolveModelId(requested?: string | null): string {
  const id = requested?.trim();
  if (!id) return DEFAULT_MODEL;
  // Accept anything that looks like a real Gemini id: the live catalogue moves
  // faster than this file, so an unknown-but-plausible id is passed through and
  // allowed to fail loudly rather than being silently rewritten.
  if (KNOWN_IDS.has(id) || /^gemini-[\w.-]+$/.test(id)) return id;
  return DEFAULT_MODEL;
}

/** Builds the fallback ladder for a request, honouring the caller's choice first. */
export function modelsToTry(preferred?: string | null): string[] {
  const first = resolveModelId(preferred);
  return Array.from(new Set([first, ...MODEL_FALLBACK_CHAIN]));
}

interface LiveModel {
  name?: string;
  displayName?: string;
  description?: string;
  supportedGenerationMethods?: string[];
}

/**
 * Asks Google what actually exists right now. Returns the offline list on any
 * failure — a settings panel that cannot reach the API should still offer
 * something usable rather than rendering empty.
 */
export async function fetchLiveModels(apiKey: string): Promise<AvailableModelItem[]> {
  try {
    const res = await fetch(
      `https://generativelanguage.googleapis.com/v1beta/models?key=${encodeURIComponent(apiKey)}&pageSize=200`,
      { signal: AbortSignal.timeout(8000) }
    );
    if (!res.ok) return KNOWN_MODELS;

    const data = (await res.json()) as { models?: LiveModel[] };
    if (!Array.isArray(data.models)) return KNOWN_MODELS;

    const live = data.models
      .filter(
        (m) =>
          m.name?.startsWith("models/gemini-") &&
          m.supportedGenerationMethods?.includes("generateContent") &&
          // Text-in / JSON-out only: image, tts and robotics variants cannot
          // produce a diagnostic report.
          !/-image|-tts|computer-use|robotics/.test(m.name)
      )
      .map<AvailableModelItem>((m) => {
        const id = m.name!.replace("models/", "");
        return {
          id,
          displayName: m.displayName || id,
          description: m.description || "",
          isRecommended: id === DEFAULT_MODEL,
        };
      });

    if (live.length === 0) return KNOWN_MODELS;

    // Recommended first, then newest-looking ids.
    live.sort((a, b) => {
      if (a.id === DEFAULT_MODEL) return -1;
      if (b.id === DEFAULT_MODEL) return 1;
      return b.id.localeCompare(a.id, "en");
    });
    return live;
  } catch {
    return KNOWN_MODELS;
  }
}
