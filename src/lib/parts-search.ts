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
import { englishTermsFor } from "./dictionary";

/** Only the two shapes we read out of the Commons API. */
interface CommonsSearchResult {
  query?: { search?: { title?: string }[] };
}
interface CommonsImageInfo {
  query?: {
    pages?: Record<
      string,
      { imageinfo?: { url?: string; thumburl?: string }[] }
    >;
  };
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
    pattern: /mass[\s_-]*air|\bmaf\b|حساس.*ماف|حساس.*هواء|air.*flow/i,
    url: "https://upload.wikimedia.org/wikipedia/commons/1/12/Bosch_Mass_Air_Flow_Sensor_location_in_the_engine_bay_%28Opel_Antara_2.0_CDTI%29.jpg",
  },
  {
    // "عادم" and "شكمان" are the exhaust and the muffler, not the sensor
    // in them: an EGR valve and a muffler both came back as a lambda probe.
    pattern: /oxygen|lambda|مرميط|\bo2\b.*sensor/i,
    url: "https://upload.wikimedia.org/wikipedia/commons/b/b3/Lambda_sond_till_volvo240_etc.jpg",
  },
  {
    // `abs` must be a whole word. As a substring it matched "shock
    // ABSorber", so a shock absorber card showed an ABS sensor photo.
    pattern: /\babs\b|wheel.*speed|سرعة.*عجل/i,
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
    pattern: /throttle|بوابة|راس.*انجكشن|\btps\b/i,
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

  // Everything below was looked at before it was written down. Commons titles
  // a great deal of machinery "auto part" that is nothing of the kind: the
  // search for a turbocharger returned a ship's engine room, and "serpentine
  // belt" returns the geological formation in Québec. A wrong photograph is
  // worse than the drawn schematic, because the schematic never claims to be
  // a photograph of anything.
  {
    pattern: /oil.*filter|فيلترو.*زيت|فلتر.*زيت/i,
    url: "https://upload.wikimedia.org/wikipedia/commons/thumb/e/e1/Olejov%C3%BD_filtr_s_t%C4%9Bsn%C4%9Bn%C3%ADm.jpg/330px-Olejov%C3%BD_filtr_s_t%C4%9Bsn%C4%9Bn%C3%ADm.jpg",
  },
  {
    pattern: /fuel.*injector|injector|رشاش|بخاخ|حاقن/i,
    url: "https://upload.wikimedia.org/wikipedia/commons/thumb/6/6f/06A906036F_Noozle_of_Fuel_Injector.jpg/330px-06A906036F_Noozle_of_Fuel_Injector.jpg",
  },
  {
    pattern: /timing.*(chain|belt)|كاتينة|سير.*تيمن/i,
    url: "https://upload.wikimedia.org/wikipedia/commons/thumb/a/a8/Nockenwellenantrieb.jpg/330px-Nockenwellenantrieb.jpg",
  },
  {
    pattern: /ball.*joint|بوكل/i,
    url: "https://upload.wikimedia.org/wikipedia/commons/thumb/c/c3/Ball_joint_cross_section_%28from_English_Wikipedia_to_be_used_in_other_languages%29.jpg/330px-Ball_joint_cross_section_%28from_English_Wikipedia_to_be_used_in_other_languages%29.jpg",
  },
  {
    pattern: /master.*cylinder|بومب.*فرينو|اسطوانة.*رئيسية/i,
    url: "https://upload.wikimedia.org/wikipedia/commons/thumb/c/c4/Brake_master_cylinder_and_reservoir.JPG/330px-Brake_master_cylinder_and_reservoir.JPG",
  },
  {
    pattern: /crankshaft.*(position|sensor)|حساس.*كولوا|حساس.*مرفق/i,
    url: "https://upload.wikimedia.org/wikipedia/commons/thumb/7/7c/Crankshaft_sensor.png/330px-Crankshaft_sensor.png",
  },
  {
    pattern: /battery|بطاري|batterie/i,
    url: "https://upload.wikimedia.org/wikipedia/commons/thumb/0/04/Batterie_TUNDRA_EFB.jpg/330px-Batterie_TUNDRA_EFB.jpg",
  },
  {
    pattern: /clutch|فرسيوني|طاقم.*فاصل|دبرياج|قابض/i,
    url: "https://upload.wikimedia.org/wikipedia/commons/thumb/0/03/Kupplungsscheibe2.jpg/330px-Kupplungsscheibe2.jpg",
  },
];

/**
 * Words that describe where a part sits or how it is sold, not what it is.
 *
 * "Front Left ABS Wheel Speed Sensor" is four useful words and three that
 * would match half the archive. They are dropped before matching so that the
 * two-word rule below counts real evidence.
 */
const POSITIONAL = new Set([
  "front", "rear", "left", "right", "upper", "lower", "inner", "outer",
  "genuine", "original", "assembly", "replacement", "aftermarket", "spare",
  "auto", "part", "parts", "kit", "unit", "side", "with", "without",
]);

/**
 * Words that place a photograph in a car without naming a part.
 *
 * They are ignored when judging whether a title is *about* the part, so that
 * "Car radiator" counts as a title about a radiator and nothing else.
 */
const AUTOMOTIVE_CONTEXT = new Set([
  "car", "cars", "auto", "automobile", "vehicle", "motor", "engine",
]);

/** Only still pictures. See `titleMatchesPart` for why this is not obvious. */
const IMAGE_FILE = /\.(jpe?g|png|webp)$/i;

function significantWords(partName: string): string[] {
  return [
    ...new Set(
      partName
        .toLowerCase()
        .split(/[^a-z0-9]+/)
        .filter((w) => w.length > 3 && !POSITIONAL.has(w))
    ),
  ];
}

/**
 * Is this Commons result actually the part we asked for?
 *
 * Commons search is full text over the whole archive, and it always returns
 * its best guess rather than nothing. Asking it for "Toyota Engine Air Filter"
 * came back with a scan of the Guantanamo Bay Gazette — a confident, wholly
 * unrelated photograph presented on a card labelled "فيلتر هواء المحرك".
 *
 * Two rules, and each is here because a specific wrong picture got through:
 *
 * **Two words must match, not one.** Requiring a single word put a PDF titled
 * "Safety belt usage among drivers…" on the card for a serpentine *belt*. When
 * the part name only yields one significant word — "Radiator", "Alternator" —
 * one is all that can be asked for.
 *
 * **It has to be a picture.** File namespace 6 holds PDFs, DjVu scans, video
 * and audio as well as photographs, and Commons will happily return a
 * government report on battery manufacturing for the query "Battery". It came
 * back as a `.pdf` URL that the browser rendered as a broken image.
 */
export function titleMatchesPart(title: string, partName: string): boolean {
  if (!IMAGE_FILE.test(title)) return false;

  // Commons returns every result in its namespace form, "File:Car Radiator.jpg".
  // Left on, "file" counts as a subject the title is about, and the
  // single-word rule below then rejects every result Commons can return.
  const haystack = title.toLowerCase().replace(/^file:\s*/, "");
  const words = significantWords(partName);
  if (words.length === 0) return false;

  const matched = words.filter((w) =>
    new RegExp(String.raw`\b${w}\b`).test(haystack)
  );

  if (words.length >= 2) return matched.length >= 2;

  // Only one word to go on. Requiring that one word to appear is not enough:
  // it put a 19th-century photograph of a mule artillery *battery* — soldiers
  // and pack animals on a hillside — on the card for a car battery. So the
  // title has to be about that word and nothing else: no leftover subject
  // once the match, the automotive context and any catalogue number are
  // removed. "Car radiator" passes, "Mule battery WDL11495" does not.
  if (matched.length !== 1) return false;

  const leftovers = haystack
    .replace(IMAGE_FILE, "")
    .split(/[^a-z0-9]+/)
    .filter(
      (w) =>
        w.length > 3 &&
        !matched.includes(w) &&
        !AUTOMOTIVE_CONTEXT.has(w) &&
        !/\d/.test(w)
    );

  return leftovers.length === 0;
}

/**
 * Searches Wikimedia Commons (a public API; hotlinking is permitted).
 *
 * `partName` is passed separately from `query` so the result can be checked
 * against what was actually asked for.
 *
 * A thumbnail is requested rather than the original. Commons originals are
 * frequently 4-8 MB — one photograph is heavier than the entire report around
 * it, and this card renders it at 72 pixels. On the phone connection this app
 * is actually used on, that difference is the whole feature.
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
      )}&prop=imageinfo&iiprop=url&iiurlwidth=${THUMB_WIDTH}&format=json&origin=*`;

      const infoRes = await fetch(infoUrl, {
        headers: { "User-Agent": "KashifAI-CarReport/1.0" },
        signal: AbortSignal.timeout(3000),
      });

      if (!infoRes.ok) return "";
      const infoData = (await infoRes.json()) as CommonsImageInfo;
      const page = Object.values(infoData.query?.pages ?? {})[0];
      const info = page?.imageinfo?.[0];

      // `thumburl` is absent when the file is already narrower than the
      // requested width, in which case the original is the thumbnail.
      const url = info?.thumburl || info?.url;

      // Commons appends its own `utm_*` campaign parameters. They are not ours
      // to pass on to the reader's browser, and they are not part of the file.
      if (typeof url === "string") return url.split("?")[0];
    }
  } catch {
    // Continue to next tier
  }
  return "";
}

/** Wide enough for a retina 72px card and for the print stylesheet. */
const THUMB_WIDTH = 320;

/** The first curated photo whose pattern matches, or "". Exported to be tested. */
export function curatedPhotoFor(text: string): string {
  for (const item of CURATED_PARTS_PHOTO_REGISTRY) {
    if (item.pattern.test(text)) return item.url;
  }
  return "";
}

/**
 * A photo for one part, or "" when there honestly is not one.
 *
 * Tiers, in order: the curated registry, then Commons under the English part
 * name, then Commons under whatever English the Libyan dictionary can supply.
 * The third tier exists because a report often names a part only in Libyan —
 * "براتشو", "مزاطوري", "قرسيوني كوبيركو" — and an English-language archive has
 * never heard of any of them.
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
  let foundUrl = curatedPhotoFor(`${partNameEn} ${cleanOem} ${fullQuery}`);

  // Tier 2: Commons under the part's own English name.
  //
  // The make is deliberately left out of the search text. Commons is a general
  // archive, not a parts catalogue: adding "Toyota" to "Thermostat" pushes the
  // results towards photographs of cars rather than of the component, and the
  // relevance check then rejects all of them.
  if (!foundUrl && partNameEn) {
    foundUrl = await searchWikimediaCommons(partNameEn, partNameEn);
  }

  // Tier 3: the same search, under an English name the dictionary supplies for
  // the Libyan one.
  if (!foundUrl) {
    for (const english of englishTermsFor(partNameEn)) {
      foundUrl = await searchWikimediaCommons(english, english);
      if (foundUrl) break;
    }
  }

  // Commons can return a file on an unexpected host, and the registry is
  // hand-edited. Anything off the allowlist would be blocked by the CSP in the
  // browser anyway; drop it here so the UI falls back to its vector schematic
  // instead of rendering a broken image.
  const result = foundUrl && isAllowedPartImage(foundUrl) ? foundUrl : "";

  // The miss is cached too. Only hits used to be, so every card without a
  // photo — which is most of them — re-ran two Commons queries on every single
  // render of the report.
  if (cacheKey) imageSearchCache.set(cacheKey, result);
  return result;
}
