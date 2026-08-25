export type SeverityStatus = "حرج / خطر" | "متوسط / انتبه" | "سليم / خفيف";

export type FuelType = "بنزين" | "نافطة / ديزل" | "هايبرد" | "كهرباء";

/**
 * Where a piece of electrical guidance came from.
 *
 * This decides how much the reader is entitled to trust it, and the UI has to
 * say which one it is. Somebody puts a probe on a pin, or pulls a fuse,
 * because this screen told them which one.
 *
 * - `scan`      — read out of this car's own scan by the analysis.
 * - `reference` — an exact fault-code match in our own lookup table. Correct
 *                 for the code, but not verified against this exact model year.
 * - `general`   — inferred from the code's family, nothing more. Workshop
 *                 practice that happens to be true of most cars. It carries no
 *                 fuse number, no amperage, no diagram position and no pin
 *                 number, because those would be inventions about this car.
 */
export type ElectricalProvenance = "scan" | "reference" | "general";

export interface ElectricalDiagnosticInfo {
  provenance: ElectricalProvenance;
  fuseInfo: {
    boxLocation: string; // e.g. "علبة فيوزات حوض المحرك (الرئيسية)" أو "علبة الفيوزات الداخلية (تحت التابلو)"
    /** null unless the source actually names one. Never a guessed "F15". */
    fuseNumber: string | null; // e.g. "F14" أو "F02" أو "ENG-15A"
    /** null unless the source actually names one. Never a guessed "15A". */
    rating: string | null; // e.g. "15A (أزرق)" أو "20A (أصفر)" أو "30A (أخضر)"
    relayName?: string | null; // e.g. "كتاوت تغذية المحرك الرئيسية (Main Relay)" أو "كتاوت طرمبة البنزين"
    circuitDescription: string; // e.g. "تغذية حساسات المحرك والـ ECM"
  };
  sensorLocation: {
    areaName: string; // e.g. "مدخل الهواء بعد علبة الفيلترو مباشرة"
    engineZone: "front-air" | "top-manifold" | "exhaust-downpipe" | "transmission" | "wheel-hub" | "fuel-tank" | "cabin";
    accessTip: string; // e.g. "يمكن الوصول إليه بسهولة بفك قفيز خرطوم الهواء دون الحاجة لرفع السيارة"
    /** null when nothing located it. The diagram then draws no marker rather
     *  than dropping one in the middle of the engine bay. */
    coordinatePct: { x: number; y: number } | null; // Relative position on top-down engine diagram (0-100%)
  };
  multimeterTest: {
    powerPin: string; // e.g. "12V خط الكهرباء الثابت/مع السويتش (Pin 1)"
    groundPin: string; // e.g. "أقل من 0.1V خط الأرضي الشاسي (Pin 2)"
    signalPin: string; // e.g. "0.5V - 4.5V خط الإشارة الراجع للكمبيوتر (Pin 3)"
    referenceVoltage?: string | null; // e.g. "5.0V مرجعي ثابت من الـ ECM"
    testingTipLibyan: string; // e.g. "حط الأفوميتر على وضع V DC، شغل السويتش بدون تشغيل الموتوري، واقرا الفولتية بين خط الأرضي والكهرباء."
  };
}

export interface DiagnosticCodeDetail {
  code: string; // e.g. "P0102", "02", "CB", "ABS 21"
  module: string; // e.g. "ECM", "TCM", "ABS", "SRS", "IC", "LSZ", "BCM"
  moduleNameArabic: string; // e.g. "كمبيوتر المحرك", "كمبيوتر الكمبيو", "منظومة الفرامل ABS"
  standardDescriptionEn: string;
  libyanTerm: string; // e.g. "حساس الماف (فيلترو الهواء)"
  standardArabicDescription: string;
  driverSymptoms: string[]; // e.g. ["ضعف في العزم", "تقطيع أثناء المشي", "صرفية بنزين زايدة"]
  rootCauses: string[]; // الأسباب الجذرية
  urgencyLevel: "عالي جداً" | "متوسط" | "منخفض";
  impactOnVehicle: {
    safety: "عالي" | "متوسط" | "منخفض";
    fuelEconomy: "متأثر" | "غير متأثر";
    drivability: "خطر على المحرك" | "عزم ضعيف / تفتفة" | "قيادة طبيعية";
  };
  recommendedAction: string;
  recommendedPartId?: string;
  electricalDiagnostics?: ElectricalDiagnosticInfo;
}

export interface SparePartItem {
  id: string;
  relatedCode: string;
  partNameLibyan: string; // e.g. "حساس ماف (حساس الهواء)"
  partNameStandardArabic: string;
  partNameEnglish: string;
  /** null when the model did not supply one. Never a placeholder — somebody
   *  walks into a parts shop with this number. */
  oemPartNumber: string | null;
  aftermarketReplacements: string[]; // empty when none were given
  /** null when no price was given. An invented range misleads a purchase. */
  estimatedPriceRangeLYD: {
    min: number;
    max: number;
    marketNote: string;
  } | null;
  diagramCategory: "المحرك" | "الفرامل" | "الفرامل والعادم" | "التعليق والصالة" | "الكهرباء" | "التبريد والتكييف" | "الهيكل والمقصورة" | "الهيكل";
  partImageUrl?: string;
}

export interface DiagnosticStep {
  stepNumber: number;
  targetComponent: string;
  actionRequiredLibyan: string; // e.g. "قيس تغذية الخيوط (البيانتو) بـ الأفوميتر وتأكد من الفيوز قبل ما تغير الحساس"
  toolNeeded: string; // e.g. "أفوميتر / جهاز كشف / سبراي تنظيف"
  isCompleted?: boolean;
}

export interface PassedSystem {
  systemCode: string; // e.g. "A/C", "EWS", "RAD"
  systemNameArabic: string;
  systemNameEnglish: string;
}

export interface KashifDiagnosticReport {
  reportId: string;
  generatedAt: string;
  scannerInfo: {
    toolName: string; // the one safe generic: the report came from some scanner
    serialNumber?: string | null;
    testTime?: string | null;
  };
  /** A scanner report often omits half of this. `null` means the scan did not
   *  say — the UI renders "غير محدد" rather than guessing a year or a VIN. */
  vehicle: {
    vin: string | null;
    make: string | null;
    model: string | null;
    year: number | string | null;
    mileage?: string | null;
    engineSpecs?: {
      displacement?: string | null;
      fuelType?: FuelType | null;
      cylinders?: number | null;
      transmission?: string | null;
    };
  };
  summary: {
    overallHealthScore: number; // 0 - 100
    /** true when the score was computed from the fault counts rather than
     *  supplied by the analysis. The UI must say so. */
    isScoreEstimated?: boolean;
    severityStatus: SeverityStatus;
    briefSummaryArabic: string; // ملخص بلهجة ليبية فصيحة ومفهومة
    systemsCheckedCount: number;
    faultsFoundCount: number;
    passedSystemsCount: number;
  };
  faultCategories: {
    criticalFaults: DiagnosticCodeDetail[];
    moderateFaults: DiagnosticCodeDetail[];
    minorOrHistoricalFaults: DiagnosticCodeDetail[];
  };
  passedSystems: PassedSystem[];
  sparePartsRequired: SparePartItem[];
  workshopChecklist: DiagnosticStep[];
}

/**
 * The slice of a report the assistant actually reads.
 *
 * The chat panel used to POST the entire report on every message — every
 * fault's symptoms, root causes and electrical pinouts included — even though
 * the prompt only ever quotes the vehicle, the headline summary, the fault
 * codes and the part names. This type is what gets sent instead.
 */
export interface ChatReportContext {
  vehicle: KashifDiagnosticReport["vehicle"];
  summary: Pick<
    KashifDiagnosticReport["summary"],
    "overallHealthScore" | "severityStatus" | "briefSummaryArabic"
  >;
  faultCategories: {
    criticalFaults: { code: string; libyanTerm: string }[];
    moderateFaults: { code: string; libyanTerm: string }[];
  };
  sparePartsRequired: { partNameLibyan: string; oemPartNumber: string | null }[];
}

export interface ChatMessage {
  id: string;
  sender: "user" | "assistant";
  text: string;
  timestamp: string;
}

/** Renders a possibly-unknown report value. One spelling of "we do not know". */
export function orUnknown(
  value: string | number | null | undefined,
  fallback = "غير محدد"
): string {
  if (value === null || value === undefined) return fallback;
  const s = String(value).trim();
  return s === "" ? fallback : s;
}
