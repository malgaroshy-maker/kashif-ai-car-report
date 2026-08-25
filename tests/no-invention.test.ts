import { describe, expect, it } from "vitest";
import { normalizeDiagnosticReport } from "@/lib/gemini";
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

    const reported = normalizeDiagnosticReport({
      summary: { overallHealthScore: 72 },
    });
    expect(reported.summary.isScoreEstimated).toBe(false);
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
