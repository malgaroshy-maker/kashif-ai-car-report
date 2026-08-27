import { describe, expect, it } from "vitest";
import { normalizeDiagnosticReport } from "@/lib/gemini";
import { SAMPLE_BMW_528I, SAMPLE_TOYOTA_COROLLA } from "@/lib/sample-data";
import { KashifError } from "@/lib/errors";

/**
 * The one rule this product cannot break.
 *
 * A previous version answered a failed parse by handing back a stored BMW
 * report, and filled every gap in a real one with a plausible default: a VIN of
 * "LIBYA-OBD-SCAN", a year of 2020, an OEM number of "OEM-GENUINE", a price of
 * 50-200 LYD, and a passed-systems list asserting the ABS and the airbags were
 * fine. Someone buys a car on that.
 *
 * Every test here is a specific thing that was once invented.
 */
describe("normalizeDiagnosticReport never invents a finding", () => {
  it("throws rather than returning a report it could not read", () => {
    for (const junk of [null, undefined, "", 42, "not json"]) {
      expect(() => normalizeDiagnosticReport(junk)).toThrow(KashifError);
    }
  });

  it("leaves an unreported vehicle unknown instead of guessing it", () => {
    const report = normalizeDiagnosticReport({ faultCategories: {} });

    expect(report.vehicle.vin).toBeNull();
    expect(report.vehicle.make).toBeNull();
    expect(report.vehicle.model).toBeNull();
    expect(report.vehicle.year).toBeNull();

    // The specific placeholders the old version produced.
    const json = JSON.stringify(report);
    expect(json).not.toContain("LIBYA-OBD-SCAN");
    expect(json).not.toContain("2020");
    expect(json).not.toContain("مركبة مفحوصة");
  });

  it("does not claim a system passed when nothing said so", () => {
    const report = normalizeDiagnosticReport({
      faultCategories: { criticalFaults: [{ code: "P0300" }] },
    });

    // An unreported system is unknown, not passing. Asserting that the ABS and
    // the airbags are fine is a safety claim we have no basis for.
    expect(report.passedSystems).toEqual([]);
    expect(report.summary.passedSystemsCount).toBe(0);
  });

  it("leaves an OEM number and a price null rather than filling them in", () => {
    const report = normalizeDiagnosticReport({
      sparePartsRequired: [{ partNameLibyan: "حساس مرميطة" }],
    });

    const part = report.sparePartsRequired[0];
    expect(part.oemPartNumber).toBeNull();
    expect(part.estimatedPriceRangeLYD).toBeNull();
    expect(part.aftermarketReplacements).toEqual([]);

    // Someone walks into a parts shop with these.
    const json = JSON.stringify(report);
    expect(json).not.toContain("OEM-GENUINE");
    expect(json).not.toContain("Bosch");
  });

  it("drops a half-quoted price rather than rendering one end of it", () => {
    const report = normalizeDiagnosticReport({
      sparePartsRequired: [
        { partNameLibyan: "بوبينة", estimatedPriceRangeLYD: { min: 40 } },
      ],
    });
    expect(report.sparePartsRequired[0].estimatedPriceRangeLYD).toBeNull();
  });

  it("keeps a price that is fully quoted", () => {
    const report = normalizeDiagnosticReport({
      sparePartsRequired: [
        {
          partNameLibyan: "بوبينة",
          estimatedPriceRangeLYD: { min: 40, max: 90, marketNote: "الرابش" },
        },
      ],
    });
    expect(report.sparePartsRequired[0].estimatedPriceRangeLYD).toEqual({
      min: 40,
      max: 90,
      marketNote: "الرابش",
    });
  });

  it("invents no checklist step and no symptoms", () => {
    const report = normalizeDiagnosticReport({
      faultCategories: { criticalFaults: [{ code: "P0300" }] },
    });
    expect(report.workshopChecklist).toEqual([]);
    expect(report.faultCategories.criticalFaults[0].driverSymptoms).toEqual([]);
    expect(report.faultCategories.criticalFaults[0].rootCauses).toEqual([]);
  });

  it("marks a score it derived rather than passing it off as measured", () => {
    const derived = normalizeDiagnosticReport({
      faultCategories: { criticalFaults: [{ code: "P0300" }] },
    });
    expect(derived.summary.isScoreEstimated).toBe(true);

    // This used to expect `false` — the model's own number was treated as
    // measured. No scan tool reports a health percentage, so a number from the
    // model is a judgement too, and the report must say so. Its value is kept
    // either way.
    const reported = normalizeDiagnosticReport({
      summary: { overallHealthScore: 72 },
    });
    expect(reported.summary.isScoreEstimated).toBe(true);
    expect(reported.summary.overallHealthScore).toBe(72);
  });

  it("keeps what the scan did say", () => {
    const report = normalizeDiagnosticReport({
      vehicle: { vin: "JTDKN3DU8A0123456", make: "Toyota", year: 2010 },
      faultCategories: {
        criticalFaults: [
          { code: "P0301", libyanTerm: "تفتفة في السلندر الأول" },
        ],
      },
    });

    expect(report.vehicle.vin).toBe("JTDKN3DU8A0123456");
    expect(report.vehicle.make).toBe("Toyota");
    expect(report.vehicle.year).toBe("2010");
    expect(report.faultCategories.criticalFaults[0].code).toBe("P0301");
  });

  it("falls back to the vehicle the caller supplied, not to a made-up one", () => {
    const report = normalizeDiagnosticReport(
      { faultCategories: {} },
      { vehicleInfo: { vin: "WBADT43452G123456", make: "BMW" } }
    );
    expect(report.vehicle.vin).toBe("WBADT43452G123456");
    expect(report.vehicle.make).toBe("BMW");
    expect(report.vehicle.model).toBeNull();
  });
});

describe("what the scanner did not measure", () => {
  const scan = {
    vehicle: { vin: "4T1BE46K17U046638", make: "TOYOTA", model: "Camry", year: "2007" },
    faultCategories: {
      criticalFaults: [{ code: "B1811", libyanTerm: "قطع في شريط إيرباق الدومان" }],
      moderateFaults: [],
      minorOrHistoricalFaults: [],
    },
  };

  it("marks the readiness score as an estimate even when the model supplies one", () => {
    // No scan tool reports a health percentage. This was flagged authoritative
    // whenever the model gave a number, so a real Camry report printed 35%
    // under "الجاهزية" as though the machine had said so.
    const withScore = normalizeDiagnosticReport({ ...scan, summary: { overallHealthScore: 35 } });
    expect(withScore.summary.overallHealthScore).toBe(35);
    expect(withScore.summary.isScoreEstimated).toBe(true);

    const withoutScore = normalizeDiagnosticReport(scan);
    expect(withoutScore.summary.isScoreEstimated).toBe(true);
  });

  it("drops an odometer that says it was never recorded", () => {
    // The scan prints "Mileage:0 Miles". Two engines phrased that back two
    // ways, and both said "unrecorded" and then printed a number anyway.
    for (const mileage of [
      "غير مسجل / 0 ميل",
      "غير محدد (0 ميل)",
      "0 Miles",
      "not recorded",
      "0 كم",
    ]) {
      const r = normalizeDiagnosticReport({ ...scan, vehicle: { ...scan.vehicle, mileage } });
      expect(r.vehicle.mileage, mileage).toBeNull();
    }
  });

  it("keeps a real odometer reading", () => {
    for (const mileage of ["185,000 كم", "280,911 Miles (~452,000 كم)", "120000 km"]) {
      const r = normalizeDiagnosticReport({ ...scan, vehicle: { ...scan.vehicle, mileage } });
      expect(r.vehicle.mileage, mileage).toBe(mileage);
    }
  });
});

describe("what came off the machine, and what did not", () => {
  const scanText = `All System Diagnostic Report
SN:9TBC29728913
Make:TOYOTA
Model:Camry
Year:2007
VIN:4T1BE46K17U046638
1.B1811 Open in Driver's Squib (Dual Stage - 2nd Step) Circuit`;

  const model = {
    vehicle: {
      vin: "4T1BE46K17U046638",
      make: "TOYOTA",
      engineSpecs: { displacement: "2.4L 2AZ-FE", cylinders: 4 },
    },
    faultCategories: { criticalFaults: [{ code: "B1811" }] },
    sparePartsRequired: [
      { id: "p1", partNameLibyan: "طقطوقة حزام الأمان", oemPartNumber: "73230-06130" },
    ],
  };

  it("marks engine specs the scan never printed as inferred", () => {
    // A real Camry scan prints the VIN, the model, the year and the codes, and
    // nothing about the engine. "2.4L 2AZ-FE" is right about that car and was
    // still worked out from the VIN, not read off the machine.
    const r = normalizeDiagnosticReport(model, { textReport: scanText });
    expect(r.vehicle.engineSpecs?.displacement).toBe("2.4L 2AZ-FE");
    expect(r.vehicle.engineSpecs?.isInferred).toBe(true);
  });

  it("does not call it inferred when the scan did print it", () => {
    const r = normalizeDiagnosticReport(model, {
      textReport: `${scanText}
Engine:2AZ-FE`,
    });
    expect(r.vehicle.engineSpecs?.isInferred).toBe(false);
  });

  it("marks an OEM number the scan never printed as unverified", () => {
    // Two engines gave two different numbers for this same buckle, and neither
    // is anywhere in the scan. It is what somebody reads out at the counter.
    const r = normalizeDiagnosticReport(model, { textReport: scanText });
    expect(r.sparePartsRequired[0].oemPartNumber).toBe("73230-06130");
    expect(r.sparePartsRequired[0].isOemNumberUnverified).toBe(true);
  });
});

describe("the demo reports", () => {
  // The demo is what a new reader judges the product by, so it has to disclose
  // exactly what a real report discloses. These were returned as written, and
  // said less: OEM numbers with no note that they came from the assistant, an
  // engine worked out from the VIN presented as read, and a readiness score
  // with nothing marking it an estimate.
  for (const [name, sample] of [
    ["Toyota", SAMPLE_TOYOTA_COROLLA],
    ["BMW", SAMPLE_BMW_528I],
  ] as const) {
    it(`${name} discloses what a real report discloses`, () => {
      const r = normalizeDiagnosticReport(sample);
      expect(r.summary.isScoreEstimated, "score").toBe(true);
      expect(r.vehicle.engineSpecs?.isInferred, "engine").toBe(true);
      for (const part of r.sparePartsRequired) {
        expect(part.isOemNumberUnverified, part.partNameLibyan).toBe(true);
      }
    });

    it(`${name} counts the faults it actually lists`, () => {
      // The BMW fixture announced 28 faults above a list of 8, and the Toyota
      // claimed four systems checked where three faults and three passed
      // systems make six.
      const r = normalizeDiagnosticReport(sample);
      const listed =
        r.faultCategories.criticalFaults.length +
        r.faultCategories.moderateFaults.length +
        r.faultCategories.minorOrHistoricalFaults.length;
      expect(r.summary.faultsFoundCount).toBe(listed);
      expect(r.summary.passedSystemsCount).toBe(r.passedSystems.length);
      expect(r.summary.systemsCheckedCount).toBe(listed + r.passedSystems.length);
    });

    it(`${name} keeps everything the fixture actually says`, () => {
      const r = normalizeDiagnosticReport(sample);
      expect(r.vehicle.vin).toBe(sample.vehicle.vin);
      expect(r.vehicle.mileage).toBe(sample.vehicle.mileage);
      expect(r.sparePartsRequired.length).toBe(sample.sparePartsRequired.length);
      expect(r.workshopChecklist.length).toBe(sample.workshopChecklist.length);
      expect(r.faultCategories.criticalFaults.length).toBe(
        sample.faultCategories.criticalFaults.length
      );
    });
  }
});
