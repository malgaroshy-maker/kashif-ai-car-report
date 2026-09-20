/**
 * A part photograph found by its OEM number, from an aftermarket catalogue.
 *
 * The strongest source this app has, and the one with the most caveats.
 *
 * **Why it is first.** Every other tier searches by *name* and then argues
 * about whether the answer is relevant — rules over words, each one written
 * after a specific wrong picture got through. This one is keyed by the number,
 * so there is no matching to get wrong: asked for 04465-33471 it returns the
 * article that Toyota part number belongs to, and the photograph is of that
 * article. Measured over sixteen real numbers off Libyan reports, twelve
 * matched and ten had a photograph — including a coolant temperature sensor,
 * a Hyundai water pump and a Camry brake pad set that nothing on Wikimedia
 * could answer.
 *
 * **It is the aftermarket equivalent, not the genuine part.** The catalogue
 * maps an OEM number to the parts other manufacturers sell against it, so the
 * picture is a Bosch, Stellox or SKV item that fits where the Toyota one did.
 * For a mechanic about to buy one that is usually the more useful photograph —
 * it is what the shop on شارع الرابش actually stocks — but it is a different
 * claim from "this is your car's part", and the card says so.
 *
 * **Several carry the supplier's watermark.** Left as they are, deliberately:
 * the report already lists aftermarket brands beside every part, and a
 * mechanic reading STELLOX across a photograph of brake pads is not being
 * misled about anything.
 *
 * **The quota is small.** The free plan is 100 requests a month and each
 * lookup costs two, so an unpaid key is exhausted by fifty parts. Every
 * failure here — quota, outage, a number the catalogue has never heard of —
 * returns `null` and the next tier answers, which is why this one can be first
 * without being a single point of failure.
 */

import { normalizeOem } from "./ebay-parts";

const DEFAULT_BASE = "https://auto-parts-catalog.apiprofile.com";

/** English. The catalogue's own list puts it at 4. */
const LANG_ID = 4;

/** A photo on a card, never the report. Two of these run in series. */
const TIMEOUT_MS = 5000;

export interface CataloguePartPhoto {
  imageUrl: string;
  /** "BOSCH 0 280 218 135" — what the photograph is actually of. */
  article: string;
  /** "Mass Air Flow Sensor" — the catalogue's own name for it. */
  productName: string;
}

interface OemRow {
  articleId?: number;
  oemNo?: { oemBrand?: string; oemDisplayNo?: string }[];
}

interface ArticleDetails {
  article?: {
    articleNo?: string;
    supplierName?: string;
    articleProductName?: string;
  };
}

interface MediaRow {
  mediaInformation?: string;
  s3image?: string;
}

/**
 * Credentials, read at call time.
 *
 * `next build` evaluates modules without the Worker's secrets bound, so a
 * module that decided it was unconfigured at load would stay that way for the
 * life of the deployment.
 */
function apiKey(): string {
  return process.env.AUTOPARTS_API_KEY?.trim() ?? "";
}

/**
 * The account's base URL.
 *
 * The console prints it with "/api" already on the end while every documented
 * path also begins with "/api", so the suffix is trimmed rather than asked for
 * twice — which is a mistake worth making exactly once.
 */
function baseUrl(): string {
  const raw = process.env.AUTOPARTS_BASE_URL?.trim() || DEFAULT_BASE;
  return raw
    .replace(/^(?!https?:\/\/)/, "https://")
    .replace(/\/+$/, "")
    .replace(/\/api$/, "");
}

export function isCatalogueConfigured(): boolean {
  return apiKey().length > 0;
}

async function get<T>(path: string): Promise<T | null> {
  const res = await fetch(`${baseUrl()}${path}`, {
    headers: { "x-apiprofile-key": apiKey() },
    signal: AbortSignal.timeout(TIMEOUT_MS),
  });
  if (!res.ok) {
    // 429 is the monthly quota, and it is the failure this will actually hit.
    // Said once, plainly, because from the outside it is indistinguishable
    // from "this part has no photograph".
    console.warn(`[catalogue] ${res.status} for ${path}`);
    return null;
  }
  return (await res.json()) as T;
}

/**
 * Does this article really carry the number we asked for?
 *
 * The endpoint is named "search all equal oem no" and it is believed, but it
 * is a search endpoint and this costs one string comparison. The rows carry
 * their own OEM list — "13 62 7 566 988" for a number written 13627566988 —
 * so the two are compared with the punctuation taken off both, exactly as the
 * eBay tier compares a listing title.
 */
function rowCarriesOem(row: OemRow, oem: string): boolean {
  const wanted = normalizeOem(oem);
  return (row.oemNo ?? []).some(
    (n) => normalizeOem(n.oemDisplayNo ?? "") === wanted
  );
}

/** Shortest first, so a 190px card is not handed a 1500px studio original. */
const MIN_OEM_LENGTH = 6;

/**
 * The catalogue's photograph for this OEM number, or `null`.
 *
 * Two requests: the number resolves to an article, and the article to its
 * media. Only entries the catalogue itself labels "Picture" are taken —
 * the same endpoint also returns fitting diagrams and PDF manuals.
 */
export async function searchCataloguePartPhoto(
  oem: string
): Promise<CataloguePartPhoto | null> {
  if (!isCatalogueConfigured()) return null;
  if (normalizeOem(oem).length < MIN_OEM_LENGTH) return null;

  try {
    const rows = await get<OemRow[]>(
      `/api/articles-oem/search-all-equal-oem-no/lang-id/${LANG_ID}` +
        `/article-oem-no/${encodeURIComponent(oem)}`
    );

    // The same articleId comes back several times over, once per vehicle it
    // fits. One article is all this needs.
    const articleId = (rows ?? []).find(
      (r) => r.articleId && rowCarriesOem(r, oem)
    )?.articleId;
    if (!articleId) return null;

    const [details, media] = await Promise.all([
      get<ArticleDetails>(
        `/api/articles/details/article-id/${articleId}/lang-id/${LANG_ID}`
      ),
      get<MediaRow[]>(
        `/api/articles/article-all-media-info?articleId=${articleId}&langId=${LANG_ID}`
      ),
    ]);

    const picture = (media ?? []).find(
      (m) => /pictur/i.test(m.mediaInformation ?? "") && m.s3image
    )?.s3image;
    if (!picture) return null;

    const a = details?.article ?? {};
    return {
      imageUrl: picture,
      article: [a.supplierName, a.articleNo].filter(Boolean).join(" "),
      productName: a.articleProductName ?? "",
    };
  } catch (error) {
    // A missing photo is an ordinary outcome and never the reader's problem.
    console.warn("[catalogue] lookup failed:", error);
    return null;
  }
}
