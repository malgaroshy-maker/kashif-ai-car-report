import { describe, expect, it } from "vitest";
import {
  curatedPhotoFor,
  isFiledAsAutomotive,
  titleMatchesPart,
} from "@/lib/parts-search";
import { englishTermsFor } from "@/lib/dictionary";

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
    // wheel-speed sensor.
    const shock = curatedPhotoFor("Shock Absorber مزاطوري genuine auto part");
    expect(shock).toContain("mpfer");
    expect(shock).not.toContain("turnermotorsport");
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
