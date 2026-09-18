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
  // Wikimedia now hands out thumbnails on this host. Both the Commons
  // `imageinfo` API and the Wikipedia REST summary return `thumb.wikimedia.org`
  // where they used to return `upload.wikimedia.org/.../thumb/...`, and the two
  // serve the same bytes on the same path.
  //
  // Everything the live search found was being discarded here: the Commons
  // tiers and the encyclopedia tier did their work, passed every relevance and
  // category check, and were then dropped one line before returning, because
  // the host they came back on was not on this list. Only the curated registry
  // still showed a photo, because its URLs are written out by hand against the
  // old host — which is why it read as "some parts have no picture" rather than
  // as a broken feature. `npm run audit:live` fails when this happens again.
  "https://thumb.wikimedia.org",
  "https://assets.turnermotorsport.com",
] as const;

// cdn4.pelicanparts.com was here for one photograph. That host answers 403 to
// any request that is not from its own pages, so the photo never loaded, and
// an origin nothing can load from is an origin the CSP should not name.

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
