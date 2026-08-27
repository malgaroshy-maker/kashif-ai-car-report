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
      {
        imageinfo?: { url?: string; thumburl?: string }[];
        categories?: { title?: string }[];
      }
    >;
  };
}

// In-memory cache for fast response and deduplication
const imageSearchCache = new Map<string, string>();

/**
 * Hand-checked photographs, tried before anything is searched for.
 *
 * The header here used to claim "Guaranteed 100% uptime". Thirteen of its
 * twenty-nine URLs answered 404, and five of those named files that have never
 * existed on Commons at all — plausible filenames under plausible hash
 * prefixes, constructed rather than copied. Two more pointed at real files
 * through the wrong prefix, and one was hotlinked from a catalogue that
 * answers 403 to everyone but itself. Every dead one sat above the "looked at
 * before it was written down" line further down; everything below it resolved.
 *
 * So: a URL goes in here only after it has been fetched and the picture
 * opened. A Commons link is to the 330px thumbnail, never to the original —
 * three of these were 1MB originals being rendered in a 72px card and, since
 * the export embeds photos, carried whole into the downloaded file.
 *
 * `npm run audit:photos` refetches every URL here and fails on a dead or
 * oversized one, because nothing else will notice when one goes.
 */
const CURATED_PARTS_PHOTO_REGISTRY: { pattern: RegExp; url: string }[] = [
  // ── Safety / SRS ──────────────────────────────────────────────────────
  //
  // Added after a real Camry report needed four of these and Commons could
  // match none of them: an SRS scan is one of the commonest things a Libyan
  // workshop reads off a used import, and the archive files airbag parts under
  // German names or not at all.
  //
  // Every one below was opened and looked at. Three of the six parts that
  // report named have no photograph on Commons at all — the clock spring, the
  // occupant weight sensor and a seat-side airbag on its own — and they are
  // deliberately absent here rather than approximated. Those cards show the
  // drawn schematic, which is never wrong about what it is.
  {
    // A buckle receptacle beside the seat, latch open. This is the طقطوقة
    // itself, not a photograph of somebody fastening a belt — which is what
    // every English search for "seat belt buckle" returns.
    pattern: /seat[\s_-]*belt[\s_-]*(buckle|switch)|belt[\s_-]*buckle|gurtschloss|طقطوقة|قفل.*حزام/i,
    url: "https://upload.wikimedia.org/wikipedia/commons/thumb/5/52/Gurtschloss.jpg/330px-Gurtschloss.jpg",
  },
  {
    // The control unit out of the car: metal box, yellow mounting brackets,
    // its bolts beside it. Yellow is the SRS connector colour, so this reads
    // as an airbag module to a mechanic before he has read the caption.
    pattern:
      /airbag[\s_-]*(control|module|ecu)|srs[\s_-]*(control|module|unit)|كمبيوتر.*وسائد|عقل.*(ايرباق|إيرباق)/i,
    url: "https://upload.wikimedia.org/wikipedia/commons/thumb/d/db/2008-04-14_Airbag_control_unit.jpg/330px-2008-04-14_Airbag_control_unit.jpg",
  },
  {
    // The driver airbag folded into the steering wheel with the cover off.
    //
    // The negative lookahead is load-bearing. The commonest SRS part in these
    // reports is the clock spring, named "شريط إيرباق الدومان" — the airbag
    // *ribbon* of the steering wheel. Without excluding شريط it matches this
    // rule word for word and every clock spring card would show a photograph
    // of the airbag instead: a different part, in the same place, for a
    // different price.
    pattern:
      /^(?!.*(شريط|clock[\s_-]*spring))(?=.*(airbag|air[\s_-]*bag|إيرباق|ايرباق))(?=.*(steering|driver|دومان|عجلة.*القيادة))/i,
    url: "https://upload.wikimedia.org/wikipedia/commons/thumb/3/39/Driver_airbag_stored.JPG/330px-Driver_airbag_stored.JPG",
  },

  {
    pattern: /spark[\s_-]*plug|شمع|بوجي|ignit.*plug/i,
    url: "https://upload.wikimedia.org/wikipedia/commons/thumb/7/7c/Spark_plug_2.jpg/330px-Spark_plug_2.jpg",
  },
  {
    // A four-cylinder coil pack with its boots — what a modern engine
    // actually has. The previous photo was hotlinked from a parts catalogue
    // that answers 403 to anyone but its own pages, so the commonest part in
    // these reports had no picture at all.
    pattern: /ignition[\s_-]*coil|بوبين|ملف.*إشعال|كويل/i,
    url: "https://upload.wikimedia.org/wikipedia/commons/thumb/d/d9/Ignition_coil_module.jpg/330px-Ignition_coil_module.jpg",
  },
  {
    pattern: /mass[\s_-]*air|\bmaf\b|حساس.*ماف|حساس.*هواء|air.*flow/i,
    url: "https://upload.wikimedia.org/wikipedia/commons/thumb/1/12/Bosch_Mass_Air_Flow_Sensor_location_in_the_engine_bay_%28Opel_Antara_2.0_CDTI%29.jpg/330px-Bosch_Mass_Air_Flow_Sensor_location_in_the_engine_bay_%28Opel_Antara_2.0_CDTI%29.jpg",
  },
  {
    // Before the oxygen sensor, and this order is the whole point: "مرميط"
    // sits inside "المرميطة", so "علبة كربون المرميطة" — the catalytic
    // converter — matched the sensor's pattern first and was given a
    // photograph of a lambda probe. The converter itself, in the exhaust line,
    // seen from under the car.
    pattern: /catalytic|علبة.*كربون|كتلايزر|دبة.*بيئة/i,
    url: "https://upload.wikimedia.org/wikipedia/commons/thumb/9/91/Catalytic_Converter.JPG/330px-Catalytic_Converter.JPG",
  },
  {
    // "عادم" and "شكمان" are the exhaust and the muffler, not the sensor
    // in them: an EGR valve and a muffler both came back as a lambda probe.
    pattern: /oxygen|lambda|مرميط|\bo2\b.*sensor/i,
    url: "https://upload.wikimedia.org/wikipedia/commons/thumb/b/b3/Lambda_sond_till_volvo240_etc.jpg/330px-Lambda_sond_till_volvo240_etc.jpg",
  },
  {
    // `abs` must be a whole word. As a substring it matched "shock
    // ABSorber", so a shock absorber card showed an ABS sensor photo.
    pattern: /\babs\b|wheel.*speed|سرعة.*عجل/i,
    url: "https://assets.turnermotorsport.com/product_library_tms/1769855_x800.jpg",
  },
  {
    // A panel filter out of its box. Named only in Libyan in these reports
    // ("فيلترو هواء"), and the dictionary has no entry for it, so before this
    // it fell through every tier.
    pattern: /air[\s_-]*filter|فيلترو.*هوا|فلتر.*هوا/i,
    url: "https://upload.wikimedia.org/wikipedia/commons/thumb/9/93/Air_filter_for_Toyota_1KR-FE.jpg/330px-Air_filter_for_Toyota_1KR-FE.jpg",
  },
  {
    // A filter in place under the car, its own label legible. Grimy, which is
    // what one looks like at the age these cars are.
    pattern: /fuel.*filter|فيلترو.*بنزين|فلتر.*وقود/i,
    url: "https://upload.wikimedia.org/wikipedia/commons/thumb/7/79/Just_a_fuel_filter..._%2822493933238%29.jpg/330px-Just_a_fuel_filter..._%2822493933238%29.jpg",
  },
  {
    // Disc and caliper on the hub.
    pattern: /brake.*disc|ديسكو.*فرينو|هوبات/i,
    url: "https://upload.wikimedia.org/wikipedia/commons/thumb/7/72/Disk_brake_dsc03682.jpg/330px-Disk_brake_dsc03682.jpg",
  },
  {
    // The arm in place under the car, numbered against the rest of the
    // suspension. Busy, but it is where the mechanic will be looking.
    pattern: /control.*arm|براتشو|مقص|نوتشي/i,
    url: "https://upload.wikimedia.org/wikipedia/commons/thumb/7/71/Control_Arm_Fahrwerk.JPG/330px-Control_Arm_Fahrwerk.JPG",
  },
  {
    pattern: /oil.*sensor|حساس.*زيت|ستاقوب/i,
    url: "https://assets.turnermotorsport.com/product_library_tms/341975_x600.jpg",
  },
  {
    pattern: /thermostat|ثيرموستات|بلف.*حرارة/i,
    url: "https://upload.wikimedia.org/wikipedia/commons/thumb/7/71/1-1111_Automobile_Thermostat_20180929_1730.jpg/330px-1-1111_Automobile_Thermostat_20180929_1730.jpg",
  },
  {
    pattern: /throttle|بوابة|راس.*انجكشن|\btps\b/i,
    url: "https://upload.wikimedia.org/wikipedia/commons/thumb/3/3f/Drosselklappe.jpg/330px-Drosselklappe.jpg",
  },
  {
    pattern: /alternator|دينمو|مولد/i,
    url: "https://upload.wikimedia.org/wikipedia/commons/thumb/3/3e/Automotive_alternator._Terminals.jpg/330px-Automotive_alternator._Terminals.jpg",
  },
  {
    pattern: /starter|مارش|بادئ.*حركة/i,
    url: "https://upload.wikimedia.org/wikipedia/commons/thumb/8/83/Automobile_starter.JPG/330px-Automobile_starter.JPG",
  },

  // Four parts that belong here and are not: the radiator, the shock
  // absorber, the fuel pump and the brake pads. Commons answers each of them
  // with something else — patent drawings and cooling fans for the radiator,
  // 1920s magazine advertisements for the shock absorber, a teardown on a
  // bench for the pump, and for the pads a photograph of a disc. Each had an
  // entry here and every one of those URLs was dead. They are drawn instead.


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
export function titleMatchesPart(
  title: string,
  partName: string,
  opts: { insideAutomotiveCategory?: boolean } = {}
): boolean {
  if (!IMAGE_FILE.test(title)) return false;

  // Commons returns every result in its namespace form, "File:Car Radiator.jpg".
  // Left on, "file" counts as a subject the title is about, and the
  // single-word rule below then rejects every result Commons can return.
  const haystack = title.toLowerCase().replace(/^file:\s*/, "");
  // An advertisement, a patent drawing or a magazine scan is about the part
  // rather than being it. Cheap to ask here; asked again against the file's
  // own categories once those are in hand.
  if (isDocumentNotPart(title, undefined)) return false;

  // A caption that lists several things is a photograph of a scene, not of a
  // part. "Mercedes W221 start button, light switch and parking brake" matches
  // three words of "Brake Light Switch" and is a picture of a dashboard; the
  // mechanic opens the card expecting the switch he has to go and buy.
  if (/,| and /.test(haystack)) return false;

  const words = significantWords(partName);
  if (words.length === 0) return false;

  // Commons titles a file "Ignition coils.jpg" while the report names the part
  // "Ignition Coil". A bare word boundary misses every plural on the archive
  // side, and threw away results that were exactly right.
  const matched = words.filter((w) =>
    new RegExp(String.raw`\b${w}(?:e?s)?\b`).test(haystack)
  );

  if (words.length >= 2) return matched.length >= 2;

  // The search that produced this title was confined to the automotive
  // category tree, so "is this about a car at all" is already settled and the
  // title only has to name the part. Without this, "Airbag SEAT Ibiza.jpg" —
  // an airbag, filed by Commons under automobile parts — was thrown away for
  // mentioning which car it came out of.
  //
  // But the word has to be what the title is *about*. English compounds put
  // the head last, and taking any mention gave "RADIATOR FAN" for a radiator
  // and "Tesla heat pump" for a pump: both name a different component, and
  // both contain the word. So the part must be the last thing named.
  if (opts.insideAutomotiveCategory) {
    if (matched.length === 0) return false;
    // Three letters, not four, and this is the reason: the head of
    // "RADIATOR FAN" is "fan", and a four-letter floor dropped it and left
    // "radiator" looking like the subject of its own title.
    const titleWords = haystack
      .replace(IMAGE_FILE, "")
      .split(/[^a-z0-9]+/)
      .filter((w) => w.length >= 3 && !/^\d+$/.test(w) && !POSITIONAL.has(w));
    const head = titleWords[titleWords.length - 1] ?? "";
    return matched.some((w) => head === w || head === `${w}s` || head === `${w}es`);
  }

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
 * Wikimedia's policy asks for a User-Agent that identifies the client and
 * gives a way to reach whoever runs it. "KashifAI-CarReport/1.0" did neither.
 */
const COMMONS_UA =
  "KashifAI-CarReport/1.0 (https://kashif.malgaroshy.workers.dev)";

/**
 * The category tree Commons files actual vehicle components under.
 *
 * Confining the search to it is what turned this tier from decorative into
 * useful. Measured over twenty part names it returned nothing at all: a
 * full-text search of the whole archive for "Brake Light Switch" answers with
 * five scans of the 1908 Westinghouse *Air Brake Catechism*, and "Clock
 * Spring" with a 1930 Nancy Drew novel — because Commons always returns its
 * best guess rather than nothing, and the archive is mostly not about cars.
 *
 * `deepcategory` walks the subcategories, so "Ignition coils" and "Airbags"
 * are reached without naming either.
 */
const AUTOMOTIVE_CATEGORY = "Automobile parts";

/**
 * Categories that mean "this is a picture of part of a road vehicle".
 *
 * Kept to words that cannot be read another way. "Pumps" is not here — that is
 * exactly how the village hand pump got in — and neither is "Springs", which
 * on Commons is mostly water sources and mattresses.
 */
const AUTOMOTIVE_CATEGORY_WORD =
  /\b(automobile|automotive|auto part|car part|vehicle part|motor vehicle|airbag|air bag|brake|ignition|spark plug|exhaust|catalytic|carburet|alternator|odometer|dashboard|windscreen|windshield|tyre|tire|engine of|engines of|interior of|cars? by|vehicles? by)/i;

export /**
 * Categories and titles that mean "this is a document about the part, not the
 * part".
 *
 * Asked as well as `isFiledAsAutomotive`, because the positive evidence is not
 * enough on its own: a 1926 magazine advertisement for shock absorbers is
 * filed under "Automobile shock absorbers", matches both words of the part
 * name, and was being served on the card for a مزاطوري. Its own category list
 * says "The Elks Magazine advertisements in 1926" — the disqualifier was
 * sitting in the evidence the whole time and nothing was reading it.
 */
const NOT_A_PART =
  /advertis|magazine|periodical|patent|poster|catalogue|catalog|brochure|leaflet|drawing|diagram|schematic|blueprint|\bmaps?\b|logos|postcard|stamps/i;

/** A part on a shelf is not titled with the year the Model T was current. */
const HISTORICAL_YEAR = /\b1[89]\d{2}\b/;

export function isDocumentNotPart(
  title: string,
  categories: { title?: string }[] | undefined
): boolean {
  const name = title.replace(/^File:\s*/, "");
  if (NOT_A_PART.test(name) || HISTORICAL_YEAR.test(name)) return true;
  if (/\bads?\b/i.test(name)) return true;
  return (categories ?? []).some((c) =>
    NOT_A_PART.test((c.title ?? "").replace(/^Category:/, ""))
  );
}

export function isFiledAsAutomotive(
  categories: { title?: string }[] | undefined
): boolean {
  // No category list at all is not evidence of anything; the file simply has
  // not been catalogued. Treated as a fail, because the whole point is to
  // require positive evidence rather than absence of contradiction.
  return (categories ?? []).some((c) =>
    AUTOMOTIVE_CATEGORY_WORD.test((c.title ?? "").replace(/^Category:/, ""))
  );
}

/**
 * Searches Wikimedia Commons (a public API; hotlinking is permitted).
 *
 * `partName` is passed separately from `query` so the result can be checked
 * against what was actually asked for.
 *
 * Two passes. The first is confined to the automotive category tree, which is
 * where the answer almost always is; the second is the open archive, kept for
 * the parts Commons has photographed but not filed, and judged by the strict
 * title rule because nothing else vouches for it.
 *
 * `filetype:bitmap` replaces checking the extension after the fact. Namespace
 * 6 holds PDFs, DjVu scans, video and audio, and asking the API for pictures
 * costs nothing and removes them at the source.
 *
 * The query used to have " auto part" appended to it. That is what summoned
 * the auto-biographies: it doubled the archive's weight on the word "auto"
 * while adding no automotive meaning at all. It is gone.
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
    const titleFrom = async (
      srsearch: string,
      insideAutomotiveCategory: boolean
    ): Promise<string> => {
      const listUrl = `https://commons.wikimedia.org/w/api.php?action=query&list=search&srsearch=${encodeURIComponent(
        srsearch
      )}&srnamespace=6&srlimit=10&format=json&origin=*`;

      const res = await fetch(listUrl, {
        headers: { "User-Agent": COMMONS_UA },
        signal: AbortSignal.timeout(4000),
      });
      if (!res.ok) return "";

      const data = (await res.json()) as CommonsSearchResult;
      // Look past the top hit: the best *relevant* result is often second.
      return (
        (data.query?.search ?? [])
          .map((r) => r.title)
          .find(
            (t): t is string =>
              !!t && titleMatchesPart(t, partName, { insideAutomotiveCategory })
          ) ?? ""
      );
    };

    const title =
      (await titleFrom(
        `${query} filetype:bitmap deepcategory:"${AUTOMOTIVE_CATEGORY}"`,
        true
      )) || (await titleFrom(`${query} filetype:bitmap`, false));

    if (title) {
      // Categories ride along on the request that fetches the URL, so what a
      // file is actually filed under costs nothing to find out.
      const infoUrl = `https://commons.wikimedia.org/w/api.php?action=query&titles=${encodeURIComponent(
        title
      )}&prop=imageinfo|categories&iiprop=url&iiurlwidth=${THUMB_WIDTH}&cllimit=50&format=json&origin=*`;

      const infoRes = await fetch(infoUrl, {
        headers: { "User-Agent": COMMONS_UA },
        signal: AbortSignal.timeout(3000),
      });

      if (!infoRes.ok) return "";
      const infoData = (await infoRes.json()) as CommonsImageInfo;
      const page = Object.values(infoData.query?.pages ?? {})[0];

      // What the file is filed under, not what its name suggests.
      //
      // The title rules alone put a spring-driven wall clock on the card for a
      // clock spring, and a Victorian village hand pump on the card for a
      // water pump — both match two words of the part name, and both are the
      // kind of confident wrong photograph that is worse than the drawing,
      // because the drawing never claims to be a photograph of anything.
      if (!isFiledAsAutomotive(page?.categories)) return "";
      if (isDocumentNotPart(title, page?.categories)) return "";

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

/**
 * Does this name carry a word Commons can be searched with?
 *
 * An all-Arabic name used to be sent to Commons anyway, which is an English
 * language archive: a guaranteed miss that still cost the round trip. The
 * dictionary tier below is the one that can answer for those.
 */
/**
 * Terms too general to identify a part.
 *
 * The dictionary is a glossary, not a parts catalogue: it answers "بومبة مية"
 * with "Pump" and "حساس مرميطة علوي" with "Exhaust system". Searched
 * literally, the first matches any pump on the archive — a Tesla heat pump
 * came back for a water pump — and the second returns a muffler for an oxygen
 * sensor. A term that names a system or a whole category cannot pick a part
 * out of it.
 */
const TOO_GENERAL =
  /^(pump|sensor|filter|switch|belt|valve|motor|engine|module|unit|relay|fuse|wire|wiring|hose|pipe|bearing|gasket|seal|cover|housing|bracket|arm|light|lamp|system|assembly)$/i;

export function isSearchableTerm(term: string): boolean {
  const t = term.trim();
  if (t.length < 4) return false;
  if (TOO_GENERAL.test(t)) return false;
  // "Exhaust system", "Cooling system" — the system, not the part in it.
  if (/\bsystems?$/i.test(t)) return false;
  return true;
}

function hasLatinWord(name: string): boolean {
  return /[a-z]{3}/i.test(name);
}

/**
 * The cache is per isolate and dies with it, so it is a request-burst cache —
 * the ten cards of one report asking at once — not a store. Bounded because an
 * isolate that lives a long time would otherwise keep every part name ever
 * looked up; the CDN in front of /api/parts-image is the real cache.
 */
const CACHE_LIMIT = 500;

function rememberPhoto(key: string, url: string): void {
  if (imageSearchCache.size >= CACHE_LIMIT) {
    const oldest = imageSearchCache.keys().next().value;
    if (oldest !== undefined) imageSearchCache.delete(oldest);
  }
  imageSearchCache.set(key, url);
}

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
  year?: string | number,
  partNameLibyan: string = ""
): Promise<string> {
  const cleanOem = oemNumber ? oemNumber.replace(/[^a-zA-Z0-9-]/g, " ").trim() : "";

  // The key is what the answer actually depends on.
  //
  // It used to carry the make, the model and the year as well, none of which
  // reach any search below. Two cars asking for an ignition coil got two keys
  // for one answer, so the cache missed on almost everything — and the same
  // over-specified string is the request URL, so the CDN in front of
  // /api/parts-image missed with it.
  const cacheKey = `${partNameEn}|${partNameLibyan}|${cleanOem}`
    .toLowerCase()
    .trim();

  if (cacheKey !== "||" && imageSearchCache.has(cacheKey)) {
    return imageSearchCache.get(cacheKey)!;
  }

  // Tier 1: the curated registry. Hand-matched, no round trip, and it knows
  // the Libyan workshop names as well as the English ones — so it is given
  // both, which is the only place the Libyan name used to reach.
  //
  // The make, model, year and the words "genuine auto part" used to be in
  // this text too. None of them can make a pattern match more correct, and
  // any of them can make one match that should not have.
  let foundUrl = curatedPhotoFor(
    `${partNameEn} ${partNameLibyan} ${cleanOem}`.trim()
  );

  // Tier 2: Commons under the part's own English name.
  //
  // The make is deliberately left out of the search text. Commons is a general
  // archive, not a parts catalogue: adding "Toyota" to "Thermostat" pushes the
  // results towards photographs of cars rather than of the component, and the
  // relevance check then rejects all of them.
  if (!foundUrl && hasLatinWord(partNameEn)) {
    foundUrl = await searchWikimediaCommons(partNameEn, partNameEn);
  }

  // Tier 3: the same search, under an English name the dictionary supplies for
  // the Libyan one.
  //
  // This tier was dead. `englishTermsFor` matches Libyan workshop terms, and
  // it was being handed `partNameEn` — so for every part that had an English
  // name, which is most of them, it searched an empty list. The Libyan name
  // was never sent to this module at all. Now both arrive and the dictionary
  // is asked the question it can answer.
  if (!foundUrl) {
    // Only the most specific mapping, which `englishTermsFor` returns first.
    //
    // A compound Libyan name matches a dictionary entry for each of its parts:
    // "شريط إيرباق الدومان" — the airbag ribbon of the steering wheel — yields
    // "Clock spring" and then "Steering wheel". Trying them in turn meant that
    // when Commons had no clock spring, which it does not, the card was given
    // a photograph of a steering wheel instead. A different part, and the
    // reader has no way to tell.
    const [term] = [
      ...englishTermsFor(partNameLibyan),
      ...englishTermsFor(partNameEn),
    ].filter(isSearchableTerm);

    if (term) foundUrl = await searchWikimediaCommons(term, term);
  }

  // A limit that no rule over titles and categories can close, written down
  // rather than asserted away: a title can name the part and the photograph
  // still be a detail of it. "Radiator (43312087441).jpg" is filed under
  // automobile parts, is titled after the part and nothing else, and is a
  // close-up of the filler cap. It is related rather than wrong, which is why
  // the curated registry is tier one and this is the fallback.

  // Commons can return a file on an unexpected host, and the registry is
  // hand-edited. Anything off the allowlist would be blocked by the CSP in the
  // browser anyway; drop it here so the UI falls back to its vector schematic
  // instead of rendering a broken image.
  const result = foundUrl && isAllowedPartImage(foundUrl) ? foundUrl : "";

  // The miss is cached too. Only hits used to be, so every card without a
  // photo — which is most of them — re-ran two Commons queries on every single
  // render of the report.
  if (cacheKey !== "||") rememberPhoto(cacheKey, result);
  return result;
}

