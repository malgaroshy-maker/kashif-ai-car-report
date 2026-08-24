/**
 * HTML escaping for the standalone report export.
 *
 * Every string in a diagnostic report is model output. The export builds an
 * HTML file by template interpolation and the user forwards that file to their
 * customer over WhatsApp, so a fault description containing `</style><script>`
 * or `<img onerror=...>` would execute in the customer's browser. Escaping at
 * the source is the only place this is enforceable — the template has hundreds
 * of interpolation points and one missed call is the whole hole.
 */

const ENTITIES: Record<string, string> = {
  "&": "&amp;",
  "<": "&lt;",
  ">": "&gt;",
  '"': "&quot;",
  "'": "&#39;",
};

export function escapeHtml(value: unknown): string {
  if (value === null || value === undefined) return "";
  return String(value).replace(/[&<>"']/g, (c) => ENTITIES[c]);
}

/**
 * Deep-escapes every string in a structure, preserving its shape so the
 * existing template can interpolate the escaped copy unchanged.
 *
 * Anything that is meant to reach the file as real markup — the generated part
 * SVGs — must be produced from the ORIGINAL value and merged in afterwards,
 * never taken from the result of this function.
 */
export function escapeDeep<T>(value: T): T {
  if (typeof value === "string") return escapeHtml(value) as unknown as T;
  if (Array.isArray(value)) return value.map(escapeDeep) as unknown as T;
  if (value && typeof value === "object") {
    const out: Record<string, unknown> = {};
    for (const [k, v] of Object.entries(value)) out[k] = escapeDeep(v);
    return out as T;
  }
  return value;
}

/**
 * Makes a model-supplied string safe to use as a download filename. Strips
 * path separators, control characters, and the reserved characters Windows
 * rejects, so a make of `../../evil` cannot steer the save dialog.
 */
export function safeFilenamePart(value: unknown, fallback = "تقرير"): string {
  const cleaned = String(value ?? "")
    .replace(/[\u0000-\u001f\u007f]/g, "")
    .replace(/[\\/:*?"<>|]/g, "")
    .replace(/\s+/g, "_")
    .trim();
  return cleaned.slice(0, 60) || fallback;
}
