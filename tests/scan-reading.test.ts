import { describe, expect, it } from "vitest";
import { textInReadingOrder, type PdfOutput } from "@/lib/pdf-parser";
import { normalizeDiagnosticReport } from "@/lib/gemini";

/**
 * A page of an Ediag "All System Diagnostic Report", as pdf2json hands it
 * over: runs carrying their own x and y, in whatever order the content stream
 * happened to list them. These scanners write their pages bottom-up, so the
 * array below is the real one — upside down.
 *
 * The y values are the ones measured off a real Camry report.
 */
const CAMRY_PAGE: PdfOutput = {
  Pages: [
    {
      Texts: [
        { x: 1.125, y: 27.438, R: [{ T: "History" }] },
        { x: 1.125, y: 26.5, R: [{ T: "Pressure%20Sensor%2FSwitch%20High%20Input" }] },
        { x: 1.125, y: 25.563, R: [{ T: "3.P0453%20Evaporative%20Emission%20Control%20System" }] },
        { x: 1.125, y: 20.813, R: [{ T: "Pending" }] },
        { x: 1.125, y: 19.875, R: [{ T: "Pressure%20Sensor%2FSwitch%20High%20Input" }] },
        { x: 1.125, y: 18.938, R: [{ T: "1.P0453%20Evaporative%20Emission%20Control%20System" }] },
        { x: 1.125, y: 17.406, R: [{ T: "ECMECT-Engine%20and%20ECT%203%20problems%20exist" }] },
        { x: 1.125, y: 7.5, R: [{ T: "Make%3ATOYOTA" }] },
        { x: 1.125, y: 6.313, R: [{ T: "SN%3A9TBC29728913" }] },
      ],
    },
  ],
};

/**
 * The scan text is everything: it is the only thing in the prompt that came
 * off the machine, and `statedInScan` measures every other claim against it.
 *
 * `getRawTextContent()` returns the runs in content-stream order, which on
 * these reports is bottom-to-top. So the model was shown the page upside down:
 * every status word (Current / Pending / History) sat above the code it
 * belongs to and directly under a different one, and every wrapped description
 * came before its own code line. Which fault is current and which is history
 * is the thing that decides whether somebody drives the car.
 */
describe("scanner PDF text arrives in reading order", () => {
  const text = textInReadingOrder(CAMRY_PAGE);
  const lines = text.split("\n");

  it("reads down the page, not up it", () => {
    expect(lines[0]).toContain("SN:9TBC29728913");
    expect(lines[1]).toContain("Make:TOYOTA");
    expect(lines[lines.length - 1]).toBe("History");
  });

  it("keeps each status word under its own code", () => {
    const first = lines.findIndex((l) => l.startsWith("1.P0453"));
    const third = lines.findIndex((l) => l.startsWith("3.P0453"));
    expect(first).toBeGreaterThan(-1);
    expect(third).toBeGreaterThan(first);

    // The description wraps onto the next line, then the status. Both belong
    // to the code above them.
    expect(lines[first + 1]).toContain("Pressure Sensor");
    expect(lines[first + 2]).toBe("Pending");
    expect(lines[third + 2]).toBe("History");
  });

  it("decodes the run text rather than passing the escapes through", () => {
    expect(text).not.toContain("%20");
    expect(text).toContain("Pressure Sensor/Switch High Input");
  });

  it("returns nothing for a document with no page data, so the caller falls back", () => {
    expect(textInReadingOrder({})).toBe("");
    expect(textInReadingOrder({ Pages: [] })).toBe("");
  });
});

/**
 * A number nobody can order is not a number. One engine answered an airbag
 * connector repair with an `oemPartNumber` of "N/A", and the card printed
 * "N/A" in the slot somebody reads out at the parts counter.
 */
describe("a part number that says it has no part number", () => {
  for (const empty of ["N/A", "n/a", "NA", "—", "غير متوفر", "unknown", "---"]) {
    it(`drops ${JSON.stringify(empty)} rather than printing it`, () => {
      const r = normalizeDiagnosticReport({
        sparePartsRequired: [{ partNameLibyan: "فيشة", oemPartNumber: empty }],
      });
      expect(r.sparePartsRequired[0].oemPartNumber).toBeNull();
    });
  }

  it("keeps a real number, and still marks it unverified", () => {
    const r = normalizeDiagnosticReport({
      sparePartsRequired: [
        { partNameLibyan: "شريط الدومان", oemPartNumber: "84306-06140" },
      ],
    });
    expect(r.sparePartsRequired[0].oemPartNumber).toBe("84306-06140");
    expect(r.sparePartsRequired[0].isOemNumberUnverified).toBe(true);
  });

  it("does not mistake a part name containing 'na' for an empty one", () => {
    // The filter matches "N/A" only as the whole value. Matched loose it would
    // hit real content.
    const r = normalizeDiagnosticReport({
      sparePartsRequired: [
        { partNameLibyan: "حساس", oemPartNumber: "NAK-2210-A" },
      ],
    });
    expect(r.sparePartsRequired[0].oemPartNumber).toBe("NAK-2210-A");
  });
});

/**
 * A scan reads modules. Several codes out of one module are one system
 * checked, not several.
 */
describe("the systems-checked count", () => {
  it("counts modules, not faults", () => {
    // The Elantra: four EPS codes and five modules that came back clean.
    const r = normalizeDiagnosticReport({
      faultCategories: {
        criticalFaults: [
          { code: "C1259", module: "EPS" },
          { code: "C1290", module: "EPS" },
        ],
        moderateFaults: [
          { code: "C1261", module: "EPS" },
          { code: "C1611", module: "EPS" },
        ],
      },
      passedSystems: ["ECM", "TCM", "ABS", "SRS", "IMM"].map((c) => ({
        systemCode: c,
        systemNameArabic: c,
        systemNameEnglish: c,
      })),
    });
    expect(r.summary.faultsFoundCount).toBe(4);
    expect(r.summary.passedSystemsCount).toBe(5);
    expect(r.summary.systemsCheckedCount).toBe(6);
  });

  it("counts two faulted modules as two", () => {
    // The Camry: the engine ECU and the SRS, plus six clean modules.
    const r = normalizeDiagnosticReport({
      faultCategories: {
        criticalFaults: [
          { code: "B1650", module: "SRS" },
          { code: "B1800", module: "SRS" },
        ],
        moderateFaults: [{ code: "P0453", module: "ECM" }],
      },
      passedSystems: ["CCS", "ABS", "AC", "CM", "BCM", "IMMO"].map((c) => ({
        systemCode: c,
        systemNameArabic: c,
        systemNameEnglish: c,
      })),
    });
    expect(r.summary.systemsCheckedCount).toBe(8);
  });

  it("counts faults whose module the analysis did not name as one system", () => {
    const r = normalizeDiagnosticReport({
      faultCategories: { criticalFaults: [{ code: "P0300" }, { code: "P0301" }] },
    });
    expect(r.summary.systemsCheckedCount).toBe(1);
  });
});

/**
 * A real Elantra scan prints no engine at all, and the model answered the
 * displacement with the literal string "غير محدد". The plate rendered it under
 * a badge saying the engine was worked out from the VIN — a claim to have
 * inferred something, printed beside the word for having inferred nothing.
 */
describe("an engine spec that says it has no value", () => {
  it("drops the placeholder and stops calling it inferred", () => {
    const r = normalizeDiagnosticReport({
      vehicle: {
        make: "HYUNDAI",
        engineSpecs: { displacement: "غير محدد", transmission: "N/A", cylinders: 4 },
      },
    });
    expect(r.vehicle.engineSpecs?.displacement).toBeNull();
    expect(r.vehicle.engineSpecs?.transmission).toBeNull();
    expect(r.vehicle.engineSpecs?.isInferred).toBe(false);
    // What the model did say still stands.
    expect(r.vehicle.engineSpecs?.cylinders).toBe(4);
  });

  it("marks a real spec the scan never printed as inferred", () => {
    const r = normalizeDiagnosticReport(
      { vehicle: { engineSpecs: { displacement: "1.6L Gamma" } } },
      { textReport: "Make:HYUNDAI\nModel:Elantra(HD)\nYear:2010" }
    );
    expect(r.vehicle.engineSpecs?.displacement).toBe("1.6L Gamma");
    expect(r.vehicle.engineSpecs?.isInferred).toBe(true);
  });

  it("does not call a spec inferred when the scan itself printed it", () => {
    const r = normalizeDiagnosticReport(
      { vehicle: { engineSpecs: { displacement: "2.4L 2AZ-FE" } } },
      { textReport: "Engine:2AZ-FE\nMake:TOYOTA" }
    );
    expect(r.vehicle.engineSpecs?.isInferred).toBe(false);
  });
});
