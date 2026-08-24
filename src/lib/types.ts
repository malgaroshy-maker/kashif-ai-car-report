export type SeverityStatus = "حرج / خطر" | "متوسط / انتبه" | "سليم / خفيف";

export type FuelType = "بنزين" | "نافطة / ديزل" | "هايبرد" | "كهرباء";

export interface ElectricalDiagnosticInfo {
  fuseInfo: {
    boxLocation: string; // e.g. "علبة فيوزات حوض المحرك (الرئيسية)" أو "علبة الفيوزات الداخلية (تحت التابلو)"
    fuseNumber: string; // e.g. "F14" أو "F02" أو "ENG-15A"
    rating: string; // e.g. "15A (أزرق)" أو "20A (أصفر)" أو "30A (أخضر)"
    relayName?: string; // e.g. "كتاوت تغذية المحرك الرئيسية (Main Relay)" أو "كتاوت طرمبة البنزين"
    circuitDescription: string; // e.g. "تغذية حساسات المحرك والـ ECM"
  };
  sensorLocation: {
    areaName: string; // e.g. "مدخل الهواء بعد علبة الفيلترو مباشرة"
    engineZone: "front-air" | "top-manifold" | "exhaust-downpipe" | "transmission" | "wheel-hub" | "fuel-tank" | "cabin";
    accessTip: string; // e.g. "يمكن الوصول إليه بسهولة بفك قفيز خرطوم الهواء دون الحاجة لرفع السيارة"
    coordinatePct: { x: number; y: number }; // Relative position on top-down engine diagram (0-100%)
  };
  multimeterTest: {
    powerPin: string; // e.g. "12V خط الكهرباء الثابت/مع السويتش (Pin 1)"
    groundPin: string; // e.g. "أقل من 0.1V خط الأرضي الشاسي (Pin 2)"
    signalPin: string; // e.g. "0.5V - 4.5V خط الإشارة الراجع للكمبيوتر (Pin 3)"
    referenceVoltage?: string; // e.g. "5.0V مرجعي ثابت من الـ ECM"
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
  oemPartNumber: string; // e.g. "22204-22010"
  aftermarketReplacements: string[]; // e.g. ["Denso 197-6030", "Bosch 0280218xxx"]
  estimatedPriceRangeLYD: {
    min: number;
    max: number;
    marketNote: string; // e.g. "جديد أصلي أو تجاري تايواني، أو رابش في السواني / الدائري"
  };
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
    toolName: string; // e.g. "Ediag", "Launch X431", "Autel MaxiSys"
    serialNumber?: string;
    testTime?: string;
  };
  vehicle: {
    vin: string;
    make: string;
    model: string;
    year: number | string;
    mileage?: string;
    engineSpecs?: {
      displacement?: string;
      fuelType: FuelType;
      cylinders?: number;
      transmission?: string;
    };
  };
  summary: {
    overallHealthScore: number; // 0 - 100
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

export interface ChatMessage {
  id: string;
  sender: "user" | "assistant";
  text: string;
  timestamp: string;
}
