import { chromium } from "@playwright/test";
import { readFile } from "node:fs/promises";
import { fileURLToPath } from "node:url";
import path from "node:path";

/**
 * Rasterises public/og.svg into public/og.png.
 *
 * The social card has to be a raster. WhatsApp — which for this product is how
 * a link actually travels — ignores an SVG og:image entirely, and so do
 * Facebook and Twitter. Pointing og:image at an SVG means no preview at all,
 * which looks like a broken link rather than a plain one.
 *
 * The SVG stays the source of truth so the card cannot drift from the identity
 * it is drawn in. This just prints it.
 *
 *     node scripts/render-og.mjs
 *
 * Playwright is already a devDependency for the end-to-end suite, so this adds
 * nothing to the install. It is a build-time tool: nothing at runtime imports
 * it, and the Worker never sees it.
 */

const root = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "..");
const src = path.join(root, "public", "og.svg");
const out = path.join(root, "public", "og.png");

// The size every platform crops to 1.91:1 from.
const WIDTH = 1200;
const HEIGHT = 630;

const svg = await readFile(src, "utf8");

const browser = await chromium.launch();
const page = await browser.newPage({
  viewport: { width: WIDTH, height: HEIGHT },
  deviceScaleFactor: 1,
});

// Inlined rather than loaded from file:// so the SVG renders in the page's own
// context — an <img src="*.svg"> is a replaced element and cannot inherit the
// page, which matters if the card ever uses currentColor.
await page.setContent(
  `<!doctype html><meta charset="utf-8">
   <style>
     html,body{margin:0;padding:0;width:${WIDTH}px;height:${HEIGHT}px;overflow:hidden}
     svg{display:block;width:${WIDTH}px;height:${HEIGHT}px}
   </style>
   ${svg}`,
  { waitUntil: "load" }
);

await page.screenshot({ path: out, type: "png" });
await browser.close();

const bytes = (await readFile(out)).length;
console.log(`og.png written — ${WIDTH}x${HEIGHT}, ${(bytes / 1024).toFixed(1)} KB`);
