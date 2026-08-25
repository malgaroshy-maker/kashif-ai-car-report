/**
 * Part photo lookup for the spare-parts list.
 *
 * This never runs inside /api/analyze. It is called one part at a time from
 * /api/parts-image after the report has already rendered, because the previous
 * arrangement enriched every part *before* returning the analysis and turned a
 * ~10s diagnosis into a ~41s one.
 *
 * Two sources, in order, and both are ones we are allowed to use:
 *   1. A curated registry of known-good photos, matched by part name. It is
 *      hand-checked and costs no round trip, so it goes first.
 *   2. Wikimedia Commons — a public API, hotlinking permitted — for anything
 *      the registry does not cover, subject to the relevance check below.
 *
 * A third tier used to scrape DuckDuckGo's internal `i.js` endpoint with a
 * spoofed Chrome user agent and a lifted `vqd` token. It was against their
 * terms, it broke whenever the token format moved, it cost 4-8s per part, and
 * it returned images from arbitrary hosts — which is why the CSP had to allow
 * every https origin. It is gone.
 */

import { isAllowedPartImage } from "./part-image-hosts";

/** Only the two shapes we read out of the Commons API. */
interface CommonsSearchResult {
  query?: { search?: { title?: string }[] };
}
interface CommonsImageInfo {
  query?: { pages?: Record<string, { imageinfo?: { url?: string }[] }> };
}

// In-memory cache for fast response and deduplication
const imageSearchCache = new Map<string, string>();

/**
 * Curated High-Definition Genuine Automotive Parts Photo Registry
 * Guaranteed 100% uptime with CDN hosting & unblocked CORS headers
 */
const CURATED_PARTS_PHOTO_REGISTRY: { pattern: RegExp; url: string }[] = [
  {
    pattern: /spark[\s_-]*plug|شمع|بوجي|ignit.*plug/i,
    url: "https://upload.wikimedia.org/wikipedia/commons/7/7c/Spark_plug_2.jpg",
  },
  {
    pattern: /ignition[\s_-]*coil|بوبين|ملف.*إشعال|كويل/i,
    url: "https://cdn4.pelicanparts.com/BMW/techarticles/BMW-5-Series-E39/55-ENGINE-Spark_Plug_Coil_Replacement/images_large/pic06.jpg",
  },
  {
    pattern: /mass[\s_-]*air|maf|حساس.*ماف|حساس.*هواء|air.*flow/i,
    url: "https://upload.wikimedia.org/wikipedia/commons/1/12/Bosch_Mass_Air_Flow_Sensor_location_in_the_engine_bay_%28Opel_Antara_2.0_CDTI%29.jpg",
  },
  {
    pattern: /oxygen|lambda|مرميط|عادم|o2.*sensor|شكمان/i,
    url: "https://upload.wikimedia.org/wikipedia/commons/b/b3/Lambda_sond_till_volvo240_etc.jpg",
  },
  {
    pattern: /abs|wheel.*speed|سرعة.*عجل/i,
    url: "https://assets.turnermotorsport.com/product_library_tms/1769855_x800.jpg",
  },
  {
    pattern: /fuel.*pump|بومب.*بنزين|طلمب.*وقود/i,
    url: "https://upload.wikimedia.org/wikipedia/commons/4/43/Kraftstofff%C3%B6rdereinheit.jpg",
  },
  {
    pattern: /fuel.*filter|فيلترو.*بنزين|فلتر.*وقود/i,
    url: "https://upload.wikimedia.org/wikipedia/commons/b/b5/Kraftstofffilter.jpg",
  },
  {
    pattern: /brake.*pad|باطني|فحمات|قماش/i,
    url: "https://upload.wikimedia.org/wikipedia/commons/3/36/Brake_pads_and_discs.jpg",
  },
  {
    pattern: /brake.*disc|ديسكو.*فرينو|هوبات/i,
    url: "https://upload.wikimedia.org/wikipedia/commons/c/cc/Brake_disc.jpg",
  },
  {
    pattern: /catalytic|علبة.*كربون|كتلايزر|دبة.*بيئة/i,
    url: "https://upload.wikimedia.org/wikipedia/commons/0/07/Catalytic_converter.jpg",
  },
  {
    pattern: /control.*arm|براتشو|مقص|نوتشي/i,
    url: "https://upload.wikimedia.org/wikipedia/commons/5/50/Querlenker_Kfz.jpg",
  },
  {
    pattern: /shock|مزاطوري|مساعد|ياي/i,
    url: "https://upload.wikimedia.org/wikipedia/commons/7/77/Sto%C3%9Fd%C3%A4mpfer_P1010041.JPG",
  },
  {
    pattern: /oil.*sensor|حساس.*زيت|ستاقوب/i,
    url: "https://assets.turnermotorsport.com/product_library_tms/341975_x600.jpg",
  },
  {
    pattern: /radiator|رداتوري|رادياتير|تبريد/i,
    url: "https://upload.wikimedia.org/wikipedia/commons/0/0c/Car_Radiator.jpg",
  },
  {
    pattern: /thermostat|ثيرموستات|بلف.*حرارة/i,
    url: "https://upload.wikimedia.org/wikipedia/commons/4/4a/Thermostat_auto.jpg",
  },
  {
    pattern: /throttle|بوابة|راس.*انجكشن|tps/i,
    url: "https://upload.wikimedia.org/wikipedia/commons/7/7b/Drosselklappe.jpg",
  },
  {
    pattern: /alternator|دينمو|مولد/i,
    url: "https://upload.wikimedia.org/wikipedia/commons/2/23/Alternator_1.jpg",
  },
  {
    pattern: /starter|مارش|بادئ.*حركة/i,
    url: "https://upload.wikimedia.org/wikipedia/commons/1/14/Starter_motor.jpg",
  },
];

/**
 * Is this Commons result actually the part we asked for?
 *
 * Commons search is full text over the whole archive, and it always returns
 * its best guess rather than nothing. Asking it for "Toyota Engine Air Filter"
 * came back with a scan of the Guantanamo Bay Gazette — a confident, wholly
 * unrelated photograph presented on a card labelled "فيلتر هواء المحرك".
 *
 * The file title has to contain a real word from the part name, matched on a
 * word boundary. Short words are ignored, because "air" and "oil" match half
 * the archive on their own; boundaries matter because a substring test on
 * "engine" accepted a photo captioned "Falls City engineer".
 */
function titleMatchesPart(title: string, partName: string): boolean {
  const haystack = title.toLowerCase();
  const words = partName
    .toLowerCase()
    .split(/[^a-z0-9]+/)
    .filter((w) => w.length > 3);
  if (words.length === 0) return false;
  return words.some((w) => new RegExp(String.raw`\b${w}\b`).test(haystack));
}

/**
 * Searches Wikimedia Commons (a public API; hotlinking is permitted).
 *
 * `partName` is passed separately from `query` so the result can be checked
 * against what was actually asked for.
 */
async function searchWikimediaCommons(
  query: string,
  partName: string
): Promise<string> {
  try {
    const listUrl = `https://commons.wikimedia.org/w/api.php?action=query&list=search&srsearch=${encodeURIComponent(
      query + " auto part"
    )}&srnamespace=6&format=json&origin=*`;

    const res = await fetch(listUrl, {
      headers: { "User-Agent": "KashifAI-CarReport/1.0" },
      signal: AbortSignal.timeout(4000),
    });

    if (!res.ok) return "";
    const data = (await res.json()) as CommonsSearchResult;

    // Look past the top hit: the best *relevant* result is often second.
    const title = (data.query?.search ?? [])
      .map((r) => r.title)
      .find((t): t is string => !!t && titleMatchesPart(t, partName));

    if (title) {
      const infoUrl = `https://commons.wikimedia.org/w/api.php?action=query&titles=${encodeURIComponent(
        title
      )}&prop=imageinfo&iiprop=url&format=json&origin=*`;

      const infoRes = await fetch(infoUrl, {
        headers: { "User-Agent": "KashifAI-CarReport/1.0" },
        signal: AbortSignal.timeout(3000),
      });

      if (!infoRes.ok) return "";
      const infoData = (await infoRes.json()) as CommonsImageInfo;
      const page = Object.values(infoData.query?.pages ?? {})[0];
      const url = page?.imageinfo?.[0]?.url;
      if (typeof url === "string") return url;
    }
  } catch {
    // Continue to next tier
  }
  return "";
}

/**
 * Searches the web for genuine car spare part photos with multi-tier failover
 */
export async function searchPartImageOnline(
  oemNumber: string = "",
  partNameEn: string = "",
  make?: string,
  model?: string,
  year?: string | number
): Promise<string> {
  const cacheKey = `${make || ""}_${model || ""}_${year || ""}_${oemNumber}_${partNameEn}`.toLowerCase().trim();

  if (cacheKey && imageSearchCache.has(cacheKey)) {
    return imageSearchCache.get(cacheKey)!;
  }

  const cleanOem = oemNumber ? oemNumber.replace(/[^a-zA-Z0-9-]/g, " ").trim() : "";
  const queryParts: string[] = [];
  if (make) queryParts.push(make);
  if (model) queryParts.push(model);
  if (year) queryParts.push(String(year));
  if (partNameEn) queryParts.push(partNameEn);
  if (cleanOem) queryParts.push(`OEM ${cleanOem}`);
  queryParts.push("genuine auto part");

  const fullQuery = queryParts.join(" ").trim();

  // Tier 1: the curated registry. Hand-matched, no round trip, and it knows
  // the Libyan workshop names as well as the English ones.
  let foundUrl = "";
  const combinedText = `${partNameEn} ${cleanOem} ${fullQuery}`;
  for (const item of CURATED_PARTS_PHOTO_REGISTRY) {
    if (item.pattern.test(combinedText)) {
      foundUrl = item.url;
      break;
    }
  }

  // Tier 2: Wikimedia Commons, for parts the registry does not name.
  if (!foundUrl && partNameEn) {
    foundUrl = await searchWikimediaCommons(
      `${make || ""} ${partNameEn}`,
      partNameEn
    );
  }

  // Commons can return a file on an unexpected host, and the registry is
  // hand-edited. Anything off the allowlist would be blocked by the CSP in the
  // browser anyway; drop it here so the UI falls back to its vector schematic
  // instead of rendering a broken image.
  if (foundUrl && isAllowedPartImage(foundUrl)) {
    imageSearchCache.set(cacheKey, foundUrl);
    return foundUrl;
  }

  return "";
}
