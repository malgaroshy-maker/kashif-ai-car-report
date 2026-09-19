import { describe, expect, it } from "vitest";
import {
  agreesWithEnglishName,
  commonsFileNameFrom,
  curatedEntryFor,
  curatedPhotoFor,
  englishSearchVariants,
  isDocumentNotPart,
  isFiledAsAnotherVehicle,
  isFiledAsAutomotive,
  isSearchableTerm,
  titleMatchesPart,
} from "@/lib/parts-search";
import { englishTermsFor, LIBYAN_DICTIONARY } from "@/lib/dictionary";
import { isAllowedPartImage } from "@/lib/part-image-hosts";
import { listingMatchesOem, normalizeOem } from "@/lib/ebay-parts";
import { readFileSync } from "node:fs";

/**
 * Every case here is a photograph this app actually put on a part card.
 *
 * A wrong photo is worse than no photo. The card falls back to a drawn
 * schematic, which names the part without ever claiming to be a picture of
 * it — so the bar a real photograph has to clear is "certainly this part",
 * not "probably related".
 */
describe("what may be shown as a photo of a part", () => {
  it("rejects a mule artillery battery for a car battery", () => {
    // A 19th-century photograph of soldiers and pack animals on a hillside,
    // titled "Mule Battery WDL11495". One matching word was all it took.
    expect(titleMatchesPart("File:Mule Battery WDL11495.png", "Battery")).toBe(false);
  });

  it("rejects a document about seat belts for a serpentine belt", () => {
    expect(
      titleMatchesPart(
        "File:Safety belt usage among drivers - use of child restraint devices.jpg",
        "Serpentine Belt"
      )
    ).toBe(false);
  });

  // A known limit, written down rather than asserted away: Québec has a
  // geological formation called the Serpentine Belt, and its map matches the
  // words "serpentine" and "belt" exactly as well as a photograph of the belt
  // on an engine does. No rule over titles can separate them. This is the
  // reason the curated registry is tier one and Commons is a fallback, and the
  // reason the fallback must stay conservative: when it is unsure the card
  // shows the drawn schematic, which is never wrong about what it is.

  it("rejects anything that is not a still picture", () => {
    // File namespace 6 holds PDFs and scans. One came back as a .pdf URL that
    // the browser rendered as a broken image.
    expect(titleMatchesPart("File:Car Radiator.pdf", "Radiator")).toBe(false);
    expect(titleMatchesPart("File:Car Radiator.djvu", "Radiator")).toBe(false);
    expect(titleMatchesPart("File:Car Radiator.jpg", "Radiator")).toBe(true);
  });

  it("still accepts a title that is about the part and nothing else", () => {
    expect(titleMatchesPart("File:Car Radiator.jpg", "Radiator")).toBe(true);
    expect(titleMatchesPart("File:Alternator 1.jpg", "Alternator")).toBe(true);
    expect(titleMatchesPart("File:Thermostat auto.jpg", "Thermostat")).toBe(true);
  });

  it("rejects a wall clock for a clock spring, on its categories", () => {
    // Measured against the live archive: searching "Clock Spring" returns a
    // 19th-century spring-driven wall clock, and it matches both words of the
    // part name perfectly. No rule over the title can separate them —
    const title = "File:Spring-driven wall clock Sault Museum.jpg";
    expect(titleMatchesPart(title, "Clock Spring")).toBe(true);

    // — so what the file is filed under is asked instead, and that is decisive.
    expect(
      isFiledAsAutomotive([
        { title: "Category:19th-century pendulum clocks" },
        { title: "Category:Spring-driven clocks" },
        { title: "Category:Wall clocks in Canada" },
      ])
    ).toBe(false);

    // The same question, asked of a photograph that really is a car part.
    expect(
      isFiledAsAutomotive([
        { title: "Category:Side air bags" },
        { title: "Category:Renault interiors" },
      ])
    ).toBe(true);
  });

  it("rejects a village hand pump for a water pump", () => {
    // "Water pump at Morwellham" matches both words and even sits inside the
    // automotive category tree, reached through a subcategory. Its own
    // categories are about Devon and industrial heritage.
    expect(
      isFiledAsAutomotive([
        { title: "Category:Water pumps in England" },
        { title: "Category:Industrial heritage in England" },
        { title: "Category:Images from Geograph Britain and Ireland" },
      ])
    ).toBe(false);
  });

  it("treats an uncatalogued file as unproven, not as innocent", () => {
    expect(isFiledAsAutomotive(undefined)).toBe(false);
    expect(isFiledAsAutomotive([])).toBe(false);
  });

  it("rejects a photograph of a scene that lists several parts", () => {
    // A dashboard photograph captioned with three separate controls matched
    // three words of "Brake Light Switch". The mechanic opens that card
    // expecting the switch he has to go and buy.
    expect(
      titleMatchesPart(
        "File:Mercedes W221 start button, light switch and parking brake.JPG",
        "Brake Light Switch"
      )
    ).toBe(false);
  });

  it("matches a plural on the archive side", () => {
    // Commons files it as "Ignition coils"; the report names one coil. A bare
    // word boundary missed every plural and threw away exact answers.
    expect(titleMatchesPart("File:Ignition coils.jpg", "Ignition Coil")).toBe(true);
  });

  it("lets a car be named once the search was confined to car parts", () => {
    // Inside the automotive category tree "is this about a car" is already
    // settled, so the title only has to name the part. Strictly judged, this
    // real result was thrown away for saying which car the airbag came out of.
    const title = "File:Renault Talisman Grandtour (10) - Undeployed airbag.jpg";
    expect(titleMatchesPart(title, "Side Airbag")).toBe(false);
    expect(
      titleMatchesPart(title, "Side Airbag", { insideAutomotiveCategory: true })
    ).toBe(true);
  });

  it("does not put a driver airbag on a clock spring card", () => {
    // The commonest SRS part in these reports is the clock spring, named
    // "شريط إيرباق الدومان" — the airbag *ribbon* of the steering wheel. It
    // matches a driver-airbag rule word for word, and the two are a different
    // part in the same place at a different price.
    expect(curatedPhotoFor("شريط إيرباق الدومان كامري 2007")).toBe("");
    expect(curatedPhotoFor("Clock Spring Toyota Camry genuine auto part")).toBe("");

    // The driver airbag itself still finds its photograph.
    expect(curatedPhotoFor("Driver Airbag genuine auto part")).toContain(
      "Driver_airbag_stored"
    );
  });

  it("finds the SRS parts a real airbag scan asks for", () => {
    expect(curatedPhotoFor("Seat Belt Buckle Switch")).toContain("Gurtschloss");
    expect(curatedPhotoFor("طقطوقة / قفل حزام أمان السواق")).toContain("Gurtschloss");
    expect(curatedPhotoFor("Airbag Control Module")).toContain("Airbag_control_unit");
    expect(curatedPhotoFor("كمبيوتر الوسائد الهوائية")).toContain("Airbag_control_unit");
  });

  it("shows the drawing for the SRS parts Commons has no photograph of", () => {
    // Written down rather than approximated. A seat-side airbag on its own and
    // an occupant weight sensor are not photographed on Commons, and the
    // nearest thing to each is a different part.
    expect(curatedPhotoFor("إيرباق جانب الكرسي")).toBe("");
    expect(curatedPhotoFor("Occupant Classification Sensor")).toBe("");
    expect(curatedPhotoFor("حساس وزن كرسي المعاون")).toBe("");
  });

  it("needs two words to agree when the part name has two to give", () => {
    expect(
      titleMatchesPart("File:Bosch Mass Air Flow Sensor in engine bay.jpg", "Mass Air Flow Sensor")
    ).toBe(true);
    // "Sensor" alone is not evidence: half the archive is sensors.
    expect(
      titleMatchesPart("File:Pressure sensor on a boiler.jpg", "Mass Air Flow Sensor")
    ).toBe(false);
  });

  it("ignores where the part sits when counting evidence", () => {
    // "Front", "Left" and "Assembly" would otherwise count as agreement.
    expect(
      titleMatchesPart("File:Front left assembly of a bicycle.jpg", "Front Left Wheel Assembly")
    ).toBe(false);
  });
});

describe("the curated registry", () => {
  it("does not answer a shock absorber with an ABS sensor", () => {
    // `abs` matched inside "shock ABSorber", so the suspension part showed a
    // wheel-speed sensor. The shock absorber's own entry has since been
    // removed — its URL was one of the thirteen dead ones, and Commons offers
    // nothing for it but 1920s magazine advertisements — so the honest answer
    // is no photograph and the drawn schematic. It must still never be the
    // sensor.
    const shock = curatedPhotoFor("Shock Absorber مزاطوري genuine auto part");
    expect(shock).toBe("");
  });

  it("still answers a real ABS sensor", () => {
    expect(curatedPhotoFor("Front Left ABS Wheel Speed Sensor")).toContain(
      "turnermotorsport"
    );
  });

  it("does not answer a muffler or an EGR valve with a lambda probe", () => {
    // "عادم" is the exhaust and "شكمان" the muffler — neither is the sensor
    // screwed into them.
    expect(curatedPhotoFor("EGR Valve بلف العادم")).not.toContain("Lambda");
    expect(curatedPhotoFor("Muffler شكمان")).not.toContain("Lambda");
  });

  it("keeps every photo on an allowlisted host", async () => {
    // A registry edit that adds a new host silently would be blocked by the
    // CSP in the browser and show a broken image instead of the schematic.
    const { PART_IMAGE_HOSTS } = await import("@/lib/part-image-hosts");
    const { isAllowedPartImage } = await import("@/lib/part-image-hosts");
    const probes = [
      "Oil Filter", "Fuel Injector", "Timing Chain", "Ball Joint",
      "Brake Master Cylinder", "Crankshaft Position Sensor", "Clutch Kit",
      "Battery", "Spark Plug", "Radiator",
    ];
    expect(PART_IMAGE_HOSTS.length).toBeGreaterThan(0);
    for (const p of probes) {
      const url = curatedPhotoFor(p);
      if (url) expect(isAllowedPartImage(url)).toBe(true);
    }
  });
});

describe("reading a Libyan part name", () => {
  it("finds an English name the archive might know", () => {
    // "براتشو" is a control arm. An English-language archive has never heard
    // of it, so the photo search had nothing to go on.
    expect(englishTermsFor("براتشو أمامي يسار").join(" ")).toMatch(/[A-Za-z]/);
    expect(englishTermsFor("دينمو").join(" ").toLowerCase()).toContain("alternator");
  });

  it("returns nothing rather than a guess for a name it does not know", () => {
    expect(englishTermsFor("قطعة ما نعرفهاش")).toEqual([]);
  });

  it("strips the gloss so the search term is a search term", () => {
    // Dictionary entries read "Gearbox / transmission (cambio)".
    for (const t of englishTermsFor("كمبيو")) {
      expect(t).not.toContain("/");
      expect(t).not.toContain("(");
    }
  });
});

/**
 * These cannot check that a photo still exists — that needs the network, and
 * `npm run audit:photos` does it. They check the two properties that made
 * thirteen dead URLs possible in the first place.
 */
describe("every curated url", () => {
  const urls = [
    ...readFileSync("src/lib/parts-search.ts", "utf8").matchAll(/url:\s*"([^"]+)"/g),
  ].map((m) => m[1]);

  it("is on the allowlist the CSP and the proxy share", () => {
    expect(urls.length).toBeGreaterThan(10);
    for (const url of urls) expect(isAllowedPartImage(url), url).toBe(true);
  });

  it("links a Commons thumbnail, never the original", () => {
    // Three of these were 1MB originals rendered in a 72px card — and since
    // the export embeds photos, carried whole into the downloaded file.
    for (const url of urls) {
      if (!url.includes("upload.wikimedia.org")) continue;
      expect(url, url).toContain("/thumb/");
      expect(url, url).toMatch(/\/\d+px-/);
    }
  });
});

describe("what the live search may answer with", () => {
  it("rejects a 1926 magazine advertisement for shock absorbers", () => {
    // This was being served on the card for a مزاطوري. It is filed under
    // "Automobile shock absorbers" and matches both words of the part name, so
    // the positive evidence was all in order — and its own category list said
    // "The Elks Magazine advertisements in 1926" the whole time.
    const title = "File:Burd-Gilmans Shock Absorber ad 1926-08.png";
    expect(isFiledAsAutomotive([{ title: "Category:Automobile shock absorbers" }])).toBe(true);
    expect(isDocumentNotPart(title, undefined)).toBe(true);
    expect(
      isDocumentNotPart("File:Something.jpg", [
        { title: "Category:The Elks Magazine advertisements in 1926" },
      ])
    ).toBe(true);
  });

  it("keeps a photograph of the part itself", () => {
    expect(isDocumentNotPart("File:Ignition coil module.jpg", [
      { title: "Category:Ignition coils" },
    ])).toBe(false);
  });

  it("requires the part to be what the title is about, not a word in it", () => {
    // English compounds put the head last. Taking any mention gave a radiator
    // fan for a radiator and a Tesla heat pump for a pump.
    const inside = { insideAutomotiveCategory: true };
    expect(titleMatchesPart("File:RADIATOR FAN.jpg", "Radiator", inside)).toBe(false);

    // "Tesla heat pump" is the other half of the same problem and the head
    // rule does not catch it — "pump" really is the head of that title. What
    // stops it is that "Pump" is never searched for at all; see the term test
    // below. Written down so the next reader does not assume this rule covers
    // a bare generic word.
    expect(titleMatchesPart("File:Tesla heat pump 01.jpg", "Pump", inside)).toBe(true);
    expect(isSearchableTerm("Pump")).toBe(false);
    // and still keeps the airbag that names its car
    expect(
      titleMatchesPart(
        "File:Renault Talisman Grandtour (10) - Undeployed airbag.jpg",
        "Side Airbag",
        inside
      )
    ).toBe(true);
  });

  it("will not search on a term that names a category rather than a part", () => {
    // The dictionary is a glossary: it answers "بومبة مية" with "Pump" and
    // "حساس مرميطة علوي" with "Exhaust system".
    expect(isSearchableTerm("Pump")).toBe(false);
    expect(isSearchableTerm("Exhaust system")).toBe(false);
    expect(isSearchableTerm("Sensor")).toBe(false);
    expect(isSearchableTerm("Clock spring")).toBe(true);
    expect(isSearchableTerm("Control arm")).toBe(true);
  });
});

describe("registry order", () => {
  it("does not answer a catalytic converter with an oxygen sensor", () => {
    // "مرميط" sits inside "المرميطة", so the sensor's pattern matched the
    // converter's Libyan name first and the card showed a lambda probe.
    expect(curatedPhotoFor("علبة كربون المرميطة")).toContain("Catalytic");
    // and the sensor itself still finds the probe
    expect(curatedPhotoFor("حساس مرميطة علوي")).toContain("Lambda");
  });

  it("finds the engine air filter, which fell through every tier", () => {
    expect(curatedPhotoFor("فيلترو هواء المحرك")).toContain("Air_filter");
    expect(curatedPhotoFor("Engine Air Filter")).toContain("Air_filter");
  });
});

describe("the article tier", () => {
  it("does not answer a clock spring with a steering wheel", () => {
    // The dictionary maps "شريط إيرباق الدومان" — the airbag ribbon of the
    // steering wheel — to "Clock spring" and then "Steering wheel". Walking
    // the whole list meant that when no clock spring article existed, the card
    // was given a very good photograph of the wrong part. Twice: tier 3 did it
    // through Commons, and the article tier repeated it.
    const [first] = englishTermsFor("شريط إيرباق الدومان");
    expect(first).toBe("Clock spring");
    expect(englishTermsFor("شريط إيرباق الدومان")).toContain("Steering wheel");
  });

  it("keeps the parts the article tier is there to reach", () => {
    // Commons search answers "radiator" with vintage filler caps and hood
    // mascots; the encyclopedia has a photograph of a radiator.
    expect(curatedPhotoFor("رداتوري")).toContain("Automobile_radiator");
    expect(curatedPhotoFor("طرمبة بنزين")).toContain("Fuelpump");
  });
});

describe("the dictionary as a source of search terms", () => {
  it("answers an oxygen sensor with a sensor, not with the pipe it sits in", () => {
    // The entry is written "حساس مرميطة علوي (قبل علبة الكربون)" and a scan
    // says "حساس مرميطة علوي". The full spelling never matched the short one,
    // so the only thing that did match was "مرميطة" — the muffler.
    expect(englishTermsFor("حساس مرميطة علوي")[0]).toBe("Oxygen sensor");
    expect(englishTermsFor("حساس مرميطة سفلي")[0]).toBe("Oxygen sensor");
    // and the muffler itself is still the muffler
    expect(englishTermsFor("مرميطة")[0]).toBe("Muffler");
    expect(englishTermsFor("علبة كربون المرميطة")[0]).toBe("Catalytic converter");
  });

  it("does not reduce an air-conditioning part to the letter A", () => {
    // "A/C Compressor (compressore)" was cut at its first slash. Four entries
    // searched an image archive for "A".
    expect(englishTermsFor("كمبريسوري المكيف")[0]).toBe("Air conditioning compressor");
    expect(englishTermsFor("رداتوري المكيف")[0]).toBe("Air conditioning condenser");
    expect(englishTermsFor("ثلاجة التكييف")[0]).toBe("Evaporator core");
  });

  it("offers nothing at all for a term that is not a part", () => {
    // Labour, a diagnosis, a service interval, a salvage yard. An archive
    // asked for any of them answers with something, and it is always wrong.
    for (const term of ["اليد العاملة", "جهاز كشف", "رابش", "سيرفيز", "تسريب"]) {
      expect(englishTermsFor(term), term).toEqual([]);
    }
  });

  it("keeps every entry's gloss readable for a person", () => {
    // The search term is a separate field precisely so the glossary can go on
    // reading like a glossary.
    for (const entry of LIBYAN_DICTIONARY) {
      expect(entry.english.length, entry.libyanTerm).toBeGreaterThan(2);
      expect(entry.standardArabic.length, entry.libyanTerm).toBeGreaterThan(2);
    }
  });
});

describe("names that overlap between two different parts", () => {
  it("does not answer a muffler with an oxygen sensor", () => {
    // "مرميط" matches inside "مرميطة", so the exhaust box itself was given a
    // photograph of the probe screwed into it.
    expect(curatedPhotoFor("مرميطة")).not.toContain("Lambda");
    expect(curatedPhotoFor("حساس مرميطة علوي")).toContain("Lambda");
  });

  it("does not answer an A/C condenser with the engine radiator", () => {
    // Libyan calls both a "رداتوري". They are different parts in different
    // circuits, at different prices.
    expect(curatedPhotoFor("رداتوري المكيف")).not.toContain("Automobile_radiator");
    expect(curatedPhotoFor("رداتوري")).toContain("Automobile_radiator");
  });
});

describe("searching under the name the report actually gave", () => {
  it("asks for the head of a catalogue name, not only the whole phrase", () => {
    // A real card from an Elantra HD report. No archive has titled anything
    // this, and the single miss handed the card to the dictionary — which
    // answered with a photograph of a Volvo steering wheel.
    expect(englishSearchVariants("EPS Column Assembly with Torque Sensor")).toEqual([
      "EPS Column Assembly with Torque Sensor",
      "EPS Column Assembly",
      "EPS Column",
    ]);
  });

  it("drops where the part sits, which no archive files anything under", () => {
    expect(englishSearchVariants("Front Left ABS Wheel Speed Sensor")).toEqual([
      "Front Left ABS Wheel Speed Sensor",
      "ABS Wheel Speed Sensor",
    ]);
  });

  it("keeps the word a catalogue put in brackets", () => {
    // Cutting at the bracket unconditionally is how "Upstream Oxygen (O2)
    // Sensor" once became "Upstream Oxygen", losing the component's name.
    expect(englishSearchVariants("Upstream Oxygen (O2) Sensor")).toEqual([
      "Upstream Oxygen (O2) Sensor",
      "Upstream Oxygen Sensor",
    ]);
  });

  it("costs one search for a name that is already a part name", () => {
    expect(englishSearchVariants("Ignition Coil")).toEqual(["Ignition Coil"]);
  });

  it("offers nothing for a name that is only a category", () => {
    // `isSearchableTerm` throws these out: an archive asked for "Sensor"
    // answers with something, and whatever it answers with is wrong.
    expect(englishSearchVariants("Sensor")).toEqual([]);
  });
});

describe("a dictionary term standing in for the part's own name", () => {
  it("refuses a steering wheel for a steering column", () => {
    // "عمود ستيرسو كهربائي مع حساس التورك" contains "ستيرسو", whose gloss reads
    // "Steering wheel (sterzo)". Right about the word, wrong about the part.
    expect(
      agreesWithEnglishName("Steering wheel", "EPS Column Assembly with Torque Sensor")
    ).toBe(false);
  });

  it("accepts a term that names the same part the report did", () => {
    expect(
      agreesWithEnglishName("Steering Angle Sensor", "Steering Angle Sensor")
    ).toBe(true);
    expect(agreesWithEnglishName("Shock absorber", "Rear Shock Absorber Assembly")).toBe(
      true
    );
  });

  it("still answers for a part the report named only in Libyan", () => {
    // Nothing to disagree with, and the dictionary is the only tier that can
    // say anything at all about "براتشو".
    expect(agreesWithEnglishName("Control arm", "")).toBe(true);
    expect(agreesWithEnglishName("Control arm", "براتشو")).toBe(true);
  });
});

describe("reading a file's name off a Wikimedia URL", () => {
  it("takes the file, not the rendering, out of a thumbnail URL", () => {
    // "330px-Mini_Shocks.JPG" is a size Commons has never heard of. Asking it
    // about that name returns a missing page, which reads as "no categories" —
    // and the categories are the strongest evidence there is about a picture.
    expect(
      commonsFileNameFrom(
        "https://thumb.wikimedia.org/wikipedia/commons/thumb/a/a4/Mini_Shocks.JPG/330px-Mini_Shocks.JPG"
      )
    ).toBe("Mini_Shocks.JPG");
  });

  it("takes the last segment when the file is served whole", () => {
    // Small enough to need no thumbnail, so it comes from its own path.
    expect(
      commonsFileNameFrom(
        "https://upload.wikimedia.org/wikipedia/commons/8/8c/Heckscheibenwischer_kl.jpg"
      )
    ).toBe("Heckscheibenwischer_kl.jpg");
  });

  it("decodes a name Wikimedia escaped", () => {
    expect(
      commonsFileNameFrom(
        "https://upload.wikimedia.org/wikipedia/commons/thumb/e/e1/Olejov%C3%BD_filtr.jpg/330px-Olejov%C3%BD_filtr.jpg"
      )
    ).toBe("Olejový_filtr.jpg");
  });
});

describe("the photos added for parts the live search could never find", () => {
  const photoFor = (text: string) =>
    decodeURIComponent(curatedPhotoFor(text)).split("/").pop() ?? "";

  it("shows a water pump, and does not take the other four pumps with it", () => {
    // The dictionary lists a fuel pump, a power steering pump, a brake master
    // cylinder and an inverter pump, and Libyan calls every one of them a
    // "بومبة".
    expect(photoFor("Water Pump بومبة ميه")).toContain("coolant_pump");
    expect(photoFor("Fuel Pump بومبة بنزين")).toContain("Fuelpump");
    expect(photoFor("Power steering pump بومبة ستيرسو")).not.toContain("coolant_pump");
    expect(photoFor("Brake master cylinder بومبة فرينو")).toContain("master_cylinder");
  });

  it("shows a hub bearing for a wheel bearing and a sensor for a wheel speed sensor", () => {
    // Both name a wheel. One is a lump of steel and one is an electrical part,
    // and "bearing" is what tells them apart.
    expect(photoFor("Wheel Hub Bearing كوشينتي")).toContain("Hub_Bearing");
    expect(photoFor("Front Left ABS Wheel Speed Sensor")).toContain("1769855");
  });

  it("shows the EGR valve itself, not the engine it is bolted to", () => {
    // The card used to be given the lead image of "Exhaust gas recirculation",
    // which is a photograph of a whole Saab engine bay.
    expect(photoFor("EGR Valve فالف الـ EGR")).toContain("EGR_valve");
    // A word boundary, because "egr" sits inside "integrated".
    expect(photoFor("Integrated Control Module")).not.toContain("EGR_valve");
  });

  it("shows a tie rod end as a photograph rather than a cross-section drawing", () => {
    // The drawn schematic beside it is already a diagram, and a better one.
    expect(photoFor("Tie Rod End بوكل دركسيون")).toContain("Tie_rod_end");
    expect(photoFor("Ball joint فوزيلي")).toContain("Tie_rod_end");
    expect(curatedPhotoFor("Ball joint")).not.toContain("cross_section");
  });

  it("shows an A/C compressor, and never the engine radiator", () => {
    // Libyan calls the condenser and the radiator both "رداتوري"; the
    // compressor is a third part again, and all three are in the same circuit
    // diagram.
    expect(photoFor("A/C Compressor كمبريسوري")).toContain("verdichter");
    expect(photoFor("كمبروسر مكيف")).toContain("verdichter");
    expect(photoFor("Radiator رداتوري")).toContain("Automobile_radiator");
  });

  it("shows a CV joint for a half shaft", () => {
    expect(photoFor("CV Joint سمياص")).toContain("CV_joint");
    expect(photoFor("CV Axle")).toContain("CV_joint");
  });

  it("still draws the parts nothing has photographed", () => {
    // Searched under their English, German, French and Spanish names and under
    // every Libyan word the dictionary has. A wrong photograph would be worse
    // than the drawing — the camshaft sensor especially, which is nearly
    // identical to the crankshaft sensor already in this list.
    for (const part of [
      "Camshaft Position Sensor حساس كامة",
      "Clock Spring شريط إيرباق الدومان",
      "Knock Sensor حساس الطرق",
      "Coolant Temperature Sensor حساس حرارة المية",
      "Engine Mount كرسي مكينة",
      "Purge Valve فالف التبخير",
    ]) {
      expect(curatedPhotoFor(part), part).toBe("");
    }
  });
});

describe("a part for a different machine, and a picture of a box", () => {
  it("refuses a bicycle's brake pads for a car's", () => {
    // "Bicycle brake pads" satisfies `isFiledAsAutomotive`, because that rule
    // accepts a category for naming a brake and a bicycle has brakes. A card
    // for تيل فرينو was given a blister pack of Shimano disc pads: the right
    // component for the wrong machine, and nothing on the card said so.
    const shimano = [
      { title: "Category:Bicycle brake pads" },
      { title: "Category:Shimano bicycle parts" },
    ];
    expect(isFiledAsAutomotive(shimano)).toBe(true);
    expect(isFiledAsAnotherVehicle(shimano)).toBe(true);
  });

  it("leaves a car's own categories alone", () => {
    expect(
      isFiledAsAnotherVehicle([
        { title: "Category:Automobile disk brakes" },
        { title: "Category:Brake blocks" },
      ])
    ).toBe(false);
  });

  it("refuses a photograph of the packaging", () => {
    // A box with the part's name printed on it is not a picture of the part.
    expect(
      isDocumentNotPart("File:L05A-RF Shimano Disc Brake Pads packaging.jpg", undefined)
    ).toBe(true);
  });

  it("shows the pads themselves for pads, and the disc for a disc", () => {
    // Sold separately, priced differently, and Commons has answered "brake
    // pads" with a photograph of a disc more than once.
    expect(curatedPhotoFor("Brake Pads تيل فرينو")).toContain("Brake_pad.jpg");
    expect(curatedPhotoFor("Brake Disc ديسكو فرينو")).toContain("Disk_brake");
  });
});

describe("a title that matches only the words every part shares", () => {
  it("refuses a Geo Storm's dashboard loom for a side airbag connector", () => {
    // From a real Camry report. "Wiring" and "harness" are two matching words
    // and neither says which loom: the word that would, "airbag", is not in
    // the title at all.
    expect(
      titleMatchesPart(
        "File:2008-04-17 Geo Storm instrument cluster wiring harness.jpg",
        "Side Airbag Wiring Connector Harness",
        { insideAutomotiveCategory: true }
      )
    ).toBe(false);
  });

  it("still accepts a match that names the part", () => {
    // "Pads" is not a category word, so this one carries real evidence.
    expect(titleMatchesPart("File:Brake pads.JPG", "Brake Pads")).toBe(true);
    // Neither is "timing", against a category word for the other half.
    expect(isSearchableTerm("Timing Belt")).toBe(true);
  });
});

describe("a part photo found by its OEM number", () => {
  it("accepts a listing whose title quotes the number, however it is punctuated", () => {
    // Toyota writes 84306-06140; sellers write it every other way.
    for (const title of [
      "Genuine Toyota 84306-06140 Clock Spring Spiral Cable",
      "TOYOTA 8430606140 CLOCK SPRING OEM",
      "Spiral cable 84306 06140 fits Camry 2007-2011",
    ]) {
      expect(listingMatchesOem(title, "84306-06140"), title).toBe(true);
    }
  });

  it("refuses a listing that never names the part number", () => {
    // The relevance rules everywhere else in this file argue from words. This
    // one can be proved, and so it is the only tier allowed to answer from a
    // marketplace: a seller who does not quote the number is not claiming to
    // sell that part.
    expect(
      listingMatchesOem("Clock Spring Spiral Cable for Toyota Camry", "84306-06140")
    ).toBe(false);
  });

  it("refuses a number too short to be one", () => {
    // Four characters is a fragment, and it will turn up inside somebody
    // else's part number.
    expect(listingMatchesOem("Widget 1234 for sale", "1234")).toBe(false);
  });

  it("strips punctuation from both sides before comparing", () => {
    expect(normalizeOem(" 84306-06140 ")).toBe("8430606140");
    expect(normalizeOem("06A906036F")).toBe("06A906036F");
  });
});

describe("a curated photo of where the part sits", () => {
  it("still answers when there is no part number to look up", () => {
    // The location shot is what this registry is good for when nothing else
    // can say anything: the mechanic is going to be looking at that view.
    expect(curatedEntryFor("Mass Air Flow Sensor حساس ماف")?.inSitu).toBe(true);
    expect(curatedPhotoFor("Mass Air Flow Sensor")).toContain("location_in_the_engine_bay");
  });

  it("is marked on the four entries that are views rather than parts", () => {
    // An arrow into an engine bay, a filter under a car, a converter in the
    // exhaust line, an arm numbered against the suspension around it.
    const inSitu = ["Mass Air Flow Sensor", "Fuel Filter", "Catalytic Converter", "Control Arm"];
    for (const name of inSitu) {
      expect(curatedEntryFor(name)?.inSitu, name).toBe(true);
    }
    // And not on the ones that photograph the part itself.
    for (const name of ["Brake Pads", "Ignition Coil", "Spark Plug", "Water Pump", "Alternator"]) {
      expect(curatedEntryFor(name)?.inSitu, name).toBeUndefined();
    }
  });
});
