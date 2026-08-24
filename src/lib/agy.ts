/**
 * Development-only gate for the Antigravity CLI engine.
 *
 * `antigravity-cli.ts` imports `child_process`, `fs` and `path` at module
 * scope. On the Cloudflare Worker that module cannot work at all: calling
 * `getAgyCliStatus()` there threw, which is why `/api/models` returned 500
 * from the deployed bundle.
 *
 * It is also a code-execution surface — an HTTP request driving a local agent
 * CLI with `--dangerously-skip-permissions` — so production is the right place
 * for it to be absent rather than merely unused.
 *
 * The import is dynamic and behind a build-time flag, so the module is never
 * loaded (and its Node built-ins never evaluated) in a production bundle.
 */

import type { AgyStatusInfo } from "./antigravity-cli";

export const AGY_ENABLED = process.env.NODE_ENV !== "production";

const UNAVAILABLE: AgyStatusInfo = {
  available: false,
  engineName: "Antigravity CLI (agy)",
  statusNote:
    "محرك agy المحلي متاح في بيئة التطوير فقط. النسخة المنشورة تستعمل Google Gemini.",
};

export async function getAgyStatus(): Promise<AgyStatusInfo> {
  if (!AGY_ENABLED) return UNAVAILABLE;
  try {
    const mod = await import("./antigravity-cli");
    return await mod.getAgyCliStatus();
  } catch {
    return UNAVAILABLE;
  }
}

/**
 * Runs a prompt through the local CLI, or returns null when that is not
 * possible. Never throws: every caller treats a null as "use Gemini instead".
 */
export async function tryAgyPrompt(
  prompt: string,
  timeoutMs: number
): Promise<string | null> {
  if (!AGY_ENABLED) return null;
  try {
    const mod = await import("./antigravity-cli");
    const status = await mod.getAgyCliStatus();
    if (!status.available) return null;
    const out = await mod.runAgyPrompt(prompt, timeoutMs);
    return out?.trim() ? out : null;
  } catch (err) {
    console.warn("[agy] unavailable, falling back to Gemini:", err);
    return null;
  }
}

export async function parseAgyJson(raw: string): Promise<unknown> {
  if (!AGY_ENABLED) return null;
  try {
    const mod = await import("./antigravity-cli");
    return mod.extractJsonFromAgyResponse(raw);
  } catch {
    return null;
  }
}
