import offlineDtcRaw from "../../public/data/offline_dtc.json";

export interface OfflineDtcKnowledge {
  code: string;
  module: string;
  moduleNameArabic: string;
  standardDescriptionEn: string;
  libyanTerm: string;
  standardArabicDescription: string;
  driverSymptoms: string[];
  rootCauses: string[];
  urgencyLevel: string;
  recommendedAction: string;
  severity: "critical" | "moderate" | "passed" | "history";
  partNameLibyan?: string | null;
  partNameEnglish?: string | null;
  partPriceMin?: number | null;
  partPriceMax?: number | null;
  aftermarketBrands?: string[] | null;
}

export const QUICK_CODES = [
  "P0300",
  "P0420",
  "P0171",
  "P0100",
  "P0700",
  "C0035",
  "B1000",
  "U0100",
];

export const OFFLINE_DTC_DATABASE: OfflineDtcKnowledge[] = (offlineDtcRaw as any[]).map(
  (item) => ({
    code: item.code,
    module: item.module || "ECM",
    moduleNameArabic: item.moduleNameArabic || "كمبيوتر المحرك",
    standardDescriptionEn: item.standardDescriptionEn || "",
    libyanTerm: item.libyanTerm || "",
    standardArabicDescription: item.standardArabicDescription || "",
    driverSymptoms: Array.isArray(item.driverSymptoms) ? item.driverSymptoms : [],
    rootCauses: Array.isArray(item.rootCauses) ? item.rootCauses : [],
    urgencyLevel: item.urgencyLevel || "متوسط",
    recommendedAction: item.recommendedAction || "",
    severity: (item.severity === "critical" || item.severity === "moderate" || item.severity === "passed" || item.severity === "history")
      ? item.severity
      : "moderate",
    partNameLibyan: item.partNameLibyan || null,
    partNameEnglish: item.partNameEnglish || null,
    partPriceMin: typeof item.partPriceMin === "number" ? item.partPriceMin : null,
    partPriceMax: typeof item.partPriceMax === "number" ? item.partPriceMax : null,
    aftermarketBrands: Array.isArray(item.aftermarketBrands) ? item.aftermarketBrands : null,
  })
);

export function findDtcByCode(code: string): OfflineDtcKnowledge | undefined {
  const clean = code.trim().toUpperCase();
  return OFFLINE_DTC_DATABASE.find((d) => d.code === clean);
}

export function searchOfflineDtc(
  query: string,
  category: "all" | "P" | "C" | "B" | "U" = "all"
): OfflineDtcKnowledge[] {
  const q = query.trim().toLowerCase();

  return OFFLINE_DTC_DATABASE.filter((item) => {
    // Category prefix check
    if (category !== "all" && !item.code.startsWith(category)) {
      return false;
    }

    if (!q) return true;

    return (
      item.code.toLowerCase().includes(q) ||
      item.libyanTerm.toLowerCase().includes(q) ||
      item.standardArabicDescription.toLowerCase().includes(q) ||
      item.standardDescriptionEn.toLowerCase().includes(q) ||
      item.module.toLowerCase().includes(q) ||
      item.driverSymptoms.some((s) => s.toLowerCase().includes(q)) ||
      item.rootCauses.some((r) => r.toLowerCase().includes(q)) ||
      (item.partNameLibyan && item.partNameLibyan.toLowerCase().includes(q))
    );
  });
}
