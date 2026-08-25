/**
 * Every origin a part photo is allowed to come from.
 *
 * This is the single source for two things that must agree: the `img-src`
 * directive in `next.config.ts`, and the check `/api/parts-image` runs before
 * handing a URL to the browser. While the DuckDuckGo scrape was in place the
 * host could be anything, so the CSP had to allow all of `https:` — which
 * meant it protected nothing on images.
 *
 * Adding a photo to the curated registry means adding its host here too, or
 * the browser will refuse to load it.
 */
export const PART_IMAGE_HOSTS = [
  "https://upload.wikimedia.org",
  "https://cdn4.pelicanparts.com",
  "https://assets.turnermotorsport.com",
] as const;

/** True when `url` is an https URL on one of the allowed origins. */
export function isAllowedPartImage(url: string): boolean {
  try {
    const parsed = new URL(url);
    if (parsed.protocol !== "https:") return false;
    return PART_IMAGE_HOSTS.includes(parsed.origin as (typeof PART_IMAGE_HOSTS)[number]);
  } catch {
    return false;
  }
}
