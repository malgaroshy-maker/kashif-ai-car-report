/**
 * Refetches every photo in the curated registry.
 *
 * Nothing else notices when one of these goes. Thirteen of twenty-nine were
 * answering 404 before this existed — five of them naming files that had never
 * been on Commons at all — and the app failed silently every time: the card
 * quietly showed its drawing, so the registry looked like it was working.
 *
 *   node scripts/audit-photos.mjs      (npm run audit:photos)
 *
 * Fails on a dead link, a non-image, or a Commons original where a thumbnail
 * was meant. Needs the network, which is why it is a script and not a test.
 */
import { readFileSync } from "node:fs";

const UA = "KashifAI-CarReport/1.0 (https://kashif.malgaroshy.workers.dev)";
/** Above this, one photograph outweighs the report it is embedded in. */
const MAX_BYTES = 250_000;
/** Wikimedia answers 429 to a burst. This is not a race. */
const SPACING_MS = 1200;

const src = readFileSync("src/lib/parts-search.ts", "utf8");
const urls = [...src.matchAll(/url:\s*"([^"]+)"/g)].map((m) => m[1]);

if (urls.length === 0) {
  console.error("no urls found in the registry — has the file moved?");
  process.exit(1);
}

let failed = 0;

for (const url of urls) {
  const shown = decodeURIComponent(url).replace(/^https:\/\//, "");
  let verdict = "ok   ";
  let detail = "";

  try {
    const res = await fetch(url, {
      headers: { "User-Agent": UA },
      signal: AbortSignal.timeout(20000),
    });
    const type = res.headers.get("content-type") || "";
    const bytes = (await res.arrayBuffer()).byteLength;

    if (!res.ok) {
      verdict = "DEAD ";
      detail = `HTTP ${res.status}`;
    } else if (!type.startsWith("image/")) {
      verdict = "DEAD ";
      detail = `not an image (${type})`;
    } else if (bytes > MAX_BYTES) {
      verdict = "HEAVY";
      detail = `${Math.round(bytes / 1024)}KB — link the 330px thumbnail`;
    } else {
      detail = `${Math.round(bytes / 1024)}KB`;
    }
  } catch (error) {
    verdict = "DEAD ";
    detail = String(error.name || error);
  }

  if (verdict !== "ok   ") failed++;
  console.log(`${verdict} ${detail.padEnd(34)} ${shown.slice(0, 88)}`);
  await new Promise((r) => setTimeout(r, SPACING_MS));
}

console.log(`\n${urls.length} photos, ${failed} need attention`);
process.exit(failed === 0 ? 0 : 1);
