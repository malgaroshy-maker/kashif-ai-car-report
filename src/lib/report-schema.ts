import { z } from "zod";

/**
 * The shape of what the model sends back — not the shape of a report.
 *
 * Two different jobs used to be tangled together in `normalizeDiagnosticReport`:
 * checking that a value is the right *kind* of thing, and deciding what a
 * missing value means. This file does the first one. `normalizeDiagnosticReport`
 * does the second, and can now trust its input's types.
 *
 * The schema is deliberately lenient about presence and strict about values.
 * A field the model omitted is a fact about the scan we do not have, and the
 * report is built to say so — rejecting a whole analysis over a missing
 * mileage would be worse than useless. A field whose *value* is wrong is a
 * different problem: `urgencyLevel: "very urgent"` used to flow straight
 * through `f.urgencyLevel || defaultUrgency` into the UI, where the severity
 * lookup missed and the fault rendered with no priority at all. Those fields
 * use `.catch()`, so an unrecognised value becomes `undefined` and the
 * caller's documented default applies.
 *
 * Nothing here invents content. `.catch(undefined)` means "the model gave no
 * usable answer", which is the same state as giving none.
 */

/**
 * Every field below is `.nullish()`, not just `.optional()`.
 *
 * A normalized report writes `null` for "the scan did not say", and
 * `normalizeDiagnosticReport` runs a second time on the agy path — so a report
 * that has already been through it comes back here with real nulls in it.
 * Treating those as parse failures would silently blank a VIN that was read
 * correctly the first time.
 */

/** An enum that degrades to `undefined` rather than passing a bad value on. */
const oneOf = <T extends readonly [string, ...string[]]>(values: T) =>
  z.enum(values).nullish().catch(undefined);

/** Models sometimes number a year and sometimes quote it. Both are fine. */
const loose = z.union([z.string(), z.number()]).nullish().catch(undefined);

const stringList = z.array(z.string()).nullish().catch(undefined);

export const URGENCY = ["عالي جداً", "متوسط", "منخفض"] as const;
export const SAFETY = ["عالي", "متوسط", "منخفض"] as const;
export const FUEL_ECONOMY = ["متأثر", "غير متأثر"] as const;
export const DRIVABILITY = [
  "خطر على المحرك",
  "عزم ضعيف / تفتفة",
  "قيادة طبيعية",
] as const;
export const SEVERITY_STATUS = [
  "حرج / خطر",
  "متوسط / انتبه",
  "سليم / خفيف",
] as const;
export const FUEL_TYPE = ["بنزين", "نافطة / ديزل", "هايبرد", "كهرباء"] as const;
export const DIAGRAM_CATEGORY = [
  "المحرك",
  "الفرامل",
  "الفرامل والعادم",
  "التعليق والصالة",
  "الكهرباء",
  "التبريد والتكييف",
  "الهيكل والمقصورة",
  "الهيكل",
  "الأمان والوسائد الهوائية",
  "نقل الحركة",
] as const;
export const ENGINE_ZONE = [
  "front-air",
  "top-manifold",
  "exhaust-downpipe",
  "transmission",
  "wheel-hub",
  "fuel-tank",
  "cabin",
] as const;

/**
 * The fuse box, sensor location and multimeter pinouts drive a drawn diagram.
 * A malformed block here is worse than an absent one: it puts a marker on the
 * wrong part of the engine bay, or prints a pinout for a different circuit.
 * The whole object is dropped unless every field parses.
 */
const electricalDiagnosticsSchema = z
  .object({
    fuseInfo: z.object({
      boxLocation: z.string(),
      fuseNumber: z.string(),
      rating: z.string(),
      relayName: z.string().nullish(),
      circuitDescription: z.string(),
    }),
    sensorLocation: z.object({
      areaName: z.string(),
      engineZone: z.enum(ENGINE_ZONE),
      accessTip: z.string(),
      // Anything outside this range would be drawn off the diagram.
      coordinatePct: z.object({
        x: z.number().min(0).max(100),
        y: z.number().min(0).max(100),
      }),
    }),
    multimeterTest: z.object({
      powerPin: z.string(),
      groundPin: z.string(),
      signalPin: z.string(),
      referenceVoltage: z.string().nullish(),
      testingTipLibyan: z.string(),
    }),
    // A hazard in the work. Optional, because most circuits carry none.
    warning: z.string().nullish(),
  })
  .nullish()
  .catch(undefined);

const faultSchema = z
  .object({
    code: loose,
    dtc: loose,
    module: loose,
    moduleNameArabic: loose,
    moduleName: loose,
    standardDescriptionEn: loose,
    descriptionEn: loose,
    libyanTerm: loose,
    term: loose,
    nameLibyan: loose,
    standardArabicDescription: loose,
    descriptionArabic: loose,
    driverSymptoms: stringList,
    rootCauses: stringList,
    urgencyLevel: oneOf(URGENCY),
    impactOnVehicle: z
      .object({
        safety: oneOf(SAFETY),
        fuelEconomy: oneOf(FUEL_ECONOMY),
        drivability: oneOf(DRIVABILITY),
      })
      .loose()
      .nullish()
      .catch(undefined),
    recommendedAction: loose,
    recommendedPartId: loose,
    electricalDiagnostics: electricalDiagnosticsSchema,
  })
  .loose();

const partSchema = z
  .object({
    id: loose,
    relatedCode: loose,
    partNameLibyan: loose,
    partNameStandardArabic: loose,
    partNameEnglish: loose,
    oemPartNumber: loose,
    aftermarketReplacements: stringList,
    // A price someone will budget against. Both ends must be real numbers or
    // the range is dropped whole, rather than half-rendered.
    estimatedPriceRangeLYD: z
      .object({
        min: z.number(),
        max: z.number(),
        marketNote: z.string().nullish(),
      })
      .loose()
      .nullish()
      .catch(undefined),
    diagramCategory: oneOf(DIAGRAM_CATEGORY),
    partImageUrl: loose,
  })
  .loose();

const checklistStepSchema = z
  .object({
    stepNumber: z.number().nullish().catch(undefined),
    targetComponent: loose,
    actionRequiredLibyan: loose,
    toolNeeded: loose,
    isCompleted: z.boolean().nullish().catch(undefined),
  })
  .loose();

/** A system claimed as passing is a safety statement; a partial one is dropped. */
const passedSystemSchema = z.object({
  systemCode: z.string(),
  systemNameArabic: z.string(),
  systemNameEnglish: z.string(),
});

const faultList = z.array(faultSchema).nullish().catch(undefined);

export const rawReportSchema = z
  .object({
    reportId: loose,
    generatedAt: loose,

    scannerInfo: z
      .object({
        toolName: loose,
        serialNumber: loose,
        testTime: loose,
      })
      .loose()
      .nullish()
      .catch(undefined),
    scannerTool: loose,

    vehicle: z
      .object({
        vin: loose,
        make: loose,
        model: loose,
        year: loose,
        mileage: loose,
        engineSpecs: z
          .object({
            displacement: loose,
            fuelType: oneOf(FUEL_TYPE),
            cylinders: z.number().nullish().catch(undefined),
            transmission: loose,
          })
          .loose()
          .nullish()
          .catch(undefined),
      })
      .loose()
      .nullish()
      .catch(undefined),
    // Some responses flatten the vehicle onto the root instead.
    vin: loose,
    make: loose,
    model: loose,
    year: loose,
    mileage: loose,

    summary: z
      .object({
        overallHealthScore: z.number().min(0).max(100).nullish().catch(undefined),
        severityStatus: oneOf(SEVERITY_STATUS),
        briefSummaryArabic: loose,
        systemsCheckedCount: z.number().nonnegative().nullish().catch(undefined),
        faultsFoundCount: z.number().nonnegative().nullish().catch(undefined),
        passedSystemsCount: z.number().nonnegative().nullish().catch(undefined),
      })
      .loose()
      .nullish()
      .catch(undefined),
    overallHealthScore: z.number().min(0).max(100).nullish().catch(undefined),
    briefSummaryArabic: loose,

    faultCategories: z
      .object({
        criticalFaults: faultList,
        moderateFaults: faultList,
        minorOrHistoricalFaults: faultList,
      })
      .loose()
      .nullish()
      .catch(undefined),
    criticalFaults: faultList,
    moderateFaults: faultList,
    minorFaults: faultList,

    passedSystems: z.array(passedSystemSchema).nullish().catch(undefined),
    sparePartsRequired: z.array(partSchema).nullish().catch(undefined),
    workshopChecklist: z.array(checklistStepSchema).nullish().catch(undefined),
  })
  .loose();

export type RawReport = z.infer<typeof rawReportSchema>;
export type RawFault = z.infer<typeof faultSchema>;
export type RawPart = z.infer<typeof partSchema>;
export type RawChecklistStep = z.infer<typeof checklistStepSchema>;

/**
 * Parses a model response into `RawReport`, or returns null.
 *
 * Only a response that is not an object at all fails outright: every field
 * inside is optional or self-healing, so this rejects garbage without
 * rejecting an honestly incomplete scan.
 */
export function parseRawReport(data: unknown): RawReport | null {
  const result = rawReportSchema.safeParse(data);
  if (!result.success) {
    console.warn(
      "[report-schema] response rejected:",
      result.error.issues.slice(0, 5)
    );
    return null;
  }
  return result.data;
}
