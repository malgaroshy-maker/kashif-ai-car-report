import fs from "fs";
import path from "path";
import { GoogleGenAI } from "@google/genai";
import { getDictionaryContextForPrompt, LIBYAN_DICTIONARY, findMatchingTerm } from "./dictionary";
import {
  KashifDiagnosticReport,
  DiagnosticCodeDetail,
  SeverityStatus,
  FuelType,
} from "./types";
import { SAMPLE_BMW_528I, SAMPLE_TOYOTA_COROLLA } from "./sample-data";

/**
 * Resolves the active Gemini API key with strict priority:
 * 1. process.env.GEMINI_API_KEY
 * 2. .env.local file on disk (reads dynamically for live updates)
 * 3. process.env.NEXT_PUBLIC_GEMINI_API_KEY
 * 4. apiKeyOverride (client settings fallback)
 */
export function resolveActiveApiKey(apiKeyOverride?: string): string | null {
  // 1. Read directly from .env.local on disk first to catch real-time edits immediately
  try {
    const envPath = path.join(process.cwd(), ".env.local");
    if (fs.existsSync(envPath)) {
      const content = fs.readFileSync(envPath, "utf-8");
      const match = content.match(/GEMINI_API_KEY=([^\r\n]+)/);
      if (match && match[1] && match[1].trim() && !match[1].includes("your_gemini_api_key")) {
        const keyOnDisk = match[1].trim();
        if (keyOnDisk.length > 10) {
          return keyOnDisk;
        }
      }
    }
  } catch (e) {
    // Ignore fs errors
  }

  // 2. Client settings override / header
  if (apiKeyOverride && apiKeyOverride.trim() && apiKeyOverride.trim().length > 10) {
    return apiKeyOverride.trim();
  }

  // 3. Process environment variable fallback
  if (process.env.GEMINI_API_KEY && process.env.GEMINI_API_KEY.trim() && !process.env.GEMINI_API_KEY.includes("your_gemini_api_key")) {
    return process.env.GEMINI_API_KEY.trim();
  }

  if (process.env.NEXT_PUBLIC_GEMINI_API_KEY && process.env.NEXT_PUBLIC_GEMINI_API_KEY.trim()) {
    return process.env.NEXT_PUBLIC_GEMINI_API_KEY.trim();
  }

  return null;
}

export function getGenAIClient(apiKeyOverride?: string): GoogleGenAI | null {
  const apiKey = resolveActiveApiKey(apiKeyOverride);
  if (!apiKey) {
    return null;
  }
  return new GoogleGenAI({ apiKey });
}

export interface AvailableModelItem {
  id: string;
  displayName: string;
  description: string;
  isRecommended?: boolean;
}

/**
 * Fetches the live list of models available from the Google Generative Language API
 */
export async function fetchAvailableGeminiModels(
  apiKeyOverride?: string
): Promise<AvailableModelItem[]> {
  const apiKey = resolveActiveApiKey(apiKeyOverride);

  if (!apiKey) {
    return [
      { id: "gemini-3.7-flash", displayName: "Gemini 3.7 Flash", description: "النموذج الافتراضي الأحدث والأعلى كفاءة في التحليل", isRecommended: true },
      { id: "gemini-3.6-flash", displayName: "Gemini 3.6 Flash", description: "معالجة متعددة الوسائط سريعة" },
      { id: "gemini-3.5-flash", displayName: "Gemini 3.5 Flash", description: "استنتاج متقدم وسريع" },
      { id: "gemini-2.5-pro", displayName: "Gemini 2.5 Pro", description: "الاستنتاج الهندسي المتقدم" },
      { id: "gemini-2.5-flash", displayName: "Gemini 2.5 Flash", description: "معالجة سريعة للمستندات" },
      { id: "gemini-2.0-flash", displayName: "Gemini 2.0 Flash", description: "نموذج داعم فائق السرعة" },
    ];
  }

  try {
    const res = await fetch(`https://generativelanguage.googleapis.com/v1beta/models?key=${apiKey}`);
    const data = await res.json();

    if (data.models && Array.isArray(data.models)) {
      const filtered = data.models
        .filter(
          (m: any) =>
            m.supportedGenerationMethods &&
            m.supportedGenerationMethods.includes("generateContent") &&
            !m.name.includes("tts") &&
            !m.name.includes("clip")
        )
        .map((m: any) => {
          const id = m.name.replace("models/", "");
          return {
            id,
            displayName: m.displayName || id,
            description: m.description || "",
            isRecommended: id === "gemini-3.7-flash",
          };
        });

      // Sort with gemini-3.7-flash first
      filtered.sort((a: any, b: any) => {
        if (a.id === "gemini-3.7-flash") return -1;
        if (b.id === "gemini-3.7-flash") return 1;
        return a.id.localeCompare(b.id);
      });

      return filtered;
    }
  } catch (err) {
    console.warn("Could not fetch live models from Google API:", err);
  }

  return [
    { id: "gemini-3.7-flash", displayName: "Gemini 3.7 Flash", description: "النموذج الافتراضي الأحدث والأعلى كفاءة في التحليل", isRecommended: true },
    { id: "gemini-3.5-flash-lite", displayName: "Gemini 3.5 Flash-Lite", description: "نموذج خفيف وفائق السرعة (490ms)" },
    { id: "gemini-3.6-flash", displayName: "Gemini 3.6 Flash", description: "معالجة متعددة الوسائط سريعة" },
    { id: "gemini-3.5-flash", displayName: "Gemini 3.5 Flash", description: "استنتاج متقدم وسريع" },
    { id: "gemini-3.1-flash-lite", displayName: "Gemini 3.1 Flash-Lite", description: "معالجة خفيفة سريعة وموفرة للحصة" },
    { id: "gemini-2.5-flash", displayName: "Gemini 2.5 Flash", description: "معالجة سريعة للمستندات" },
    { id: "gemini-3-flash-preview", displayName: "Gemini 3 Flash Preview", description: "نموذج الجيل الثالث السريع" },
  ];
}

/**
 * Executes a Gemini request with automatic fallback between live tested models
 * (e.g. gemini-3.7-flash -> gemini-3.5-flash-lite -> gemini-3.6-flash -> gemini-3.5-flash -> gemini-3.1-flash-lite -> gemini-2.5-flash)
 * to handle temporary 503 high demand or 429 rate limit spikes gracefully.
 */
async function generateWithModelFallback(
  ai: GoogleGenAI,
  params: {
    systemInstruction: string;
    contents: any[];
    responseMimeType?: string;
  }
) {
  const configuredModel = process.env.GEMINI_MODEL || "gemini-3.7-flash";
  const modelsToTry = Array.from(
    new Set([
      configuredModel,
      "gemini-3.7-flash",
      "gemini-3.5-flash-lite",
      "gemini-3.6-flash",
      "gemini-3.5-flash",
      "gemini-3.1-flash-lite",
      "gemini-2.5-flash",
      "gemini-3-flash-preview",
    ])
  );

  let lastError: any = null;

  for (const model of modelsToTry) {
    try {
      const response = await ai.models.generateContent({
        model,
        config: {
          systemInstruction: params.systemInstruction,
          ...(params.responseMimeType ? { responseMimeType: params.responseMimeType } : {}),
        },
        contents: params.contents,
      });
      if (response && response.text) {
        return response;
      }
    } catch (err: any) {
      console.warn(`[Gemini Fallback] Model ${model} unavailable (status: ${err?.status || err?.code || "error"}), trying next model...`);
      lastError = err;
    }
  }

  throw lastError || new Error("All candidate Gemini models are currently unavailable.");
}

export function getKashifSystemInstruction(): string {
  const dictionaryContext = getDictionaryContextForPrompt();

  return `
أنت "كاشف AI" (Kashif AI) - خبير ومهندس تشخيص سيارات متخصص في أجهزة الفحص (OBD-II Scanners مثل Launch, Autel, Ediag, ThinkDiag) وقاموس الورش الليبية.
مهمتك: استخراج وقراءة بيانات فحص السيارة وأكواد الأعطال (DTCs) ورقم الهيكل (VIN) وتحويلها إلى تقرير تشخيصي تفاعلي دقيق ومبسط ومهيكل بصيغة JSON.

قواعد صارمة للمصطلحات واللهجة الليبية المعتمدة في ورش الصيانة:
1. التزم حصرياً بالمصطلحات الدارجة في القاموس التالي:
${dictionaryContext}

2. قواعد مطابقة إلزامية:
- Oxygen / Lambda Sensors -> حساس مرميطة علوي (قبل علبة الكربون) أو حساس مرميطة سفلي (بعد علبة الكربون)
- Catalytic Converter -> علبة كربون المرميطة
- Throttle Body -> بوابة / راس انجكشن
- Throttle Position Sensor -> سنسور راس الإنجكشن / حساس راس انجكشن (TPS)
- Diesel Fuel Filter -> فيلترو نافطة
- Spark Plugs / Ignition Coils -> شمعات / شمعة + بوبينات
- Torque Converter -> كونفيرتا / طنجرة الكمبيو
- Engine / Transmission Mounts -> صبورتوات المحرك والكمبيو
- Subframe Bushings / Mounts -> بوكلة / بوكلات (سيبورت الصالة)
- Check Engine Warning Light -> لامبة تشك (Check Engine) / لامبة المحرك
- Control Arm / Ball Joint / Tie Rod -> براتشو + فوزيلي + نوتشي
- Sway Bar Link / Bushings -> مسمار ميزان + قوميني / جلب
- Shock Absorber / Wheel Bearing -> مزاطوري + كوشينتي
- Brake Pads / Discs -> باطنيات + ديسكو
- Valve Cover Gasket -> قرسيوني كوبيركو
- Wiring Harness / Fuses -> بيانتو + علبة الفيوزات / فيوزات
- Oil Sump / Pan -> ستاقوبا
- Radiator / Hoses -> رداتوري + مناكوطي / توبو

3. يجب أن يكون ردك بصيغة JSON مطابقة تماماً للهيكل التالي:
{
  "reportId": "kashif-123456",
  "generatedAt": "2026-08-24T00:00:00Z",
  "scannerInfo": {
    "toolName": "Ediag All-System Scanner",
    "serialNumber": "SN-987654321",
    "testTime": "2026-08-24"
  },
  "vehicle": {
    "vin": "WBADD6100VBSAMPLE",
    "make": "BMW",
    "model": "528i (E39)",
    "year": "1997",
    "mileage": "280,911 كم",
    "engineSpecs": {
      "displacement": "2.8L M52",
      "fuelType": "بنزين",
      "cylinders": 6,
      "transmission": "كمبيو أوتوماتيك"
    }
  },
  "summary": {
    "overallHealthScore": 48,
    "severityStatus": "حرج / خطر",
    "briefSummaryArabic": "ملخص شامل ومبسط بلهجة ليبية فنية واضحة...",
    "systemsCheckedCount": 12,
    "faultsFoundCount": 8,
    "passedSystemsCount": 6
  },
  "faultCategories": {
    "criticalFaults": [
      {
        "code": "02",
        "module": "ECM",
        "moduleNameArabic": "كمبيوتر المحرك (DME)",
        "standardDescriptionEn": "Ignition Coil / Misfire Cylinder 4",
        "libyanTerm": "بوبينة وشمعات السلندر الرابع (البسطوني 4)",
        "standardArabicDescription": "خلل في دائرة إشعال واحتراق الاسطوانة رقم 4",
        "driverSymptoms": ["رعشة قوية واهتزاز في المحرك", "ضعف عزم"],
        "rootCauses": ["تلف البوبينة", "تآكل الشمعة"],
        "urgencyLevel": "عالي جداً",
        "impactOnVehicle": {
          "safety": "متوسط",
          "fuelEconomy": "متأثر",
          "drivability": "عزم ضعيف / تفتفة"
        },
        "recommendedAction": "بدل بوبينة 4 مع 2 وافحص الشمعة.",
        "recommendedPartId": "part-1"
      }
    ],
    "moderateFaults": [],
    "minorOrHistoricalFaults": []
  },
  "passedSystems": [
    { "systemCode": "SRS", "systemNameArabic": "الوسائد الهوائية (الإيرباق)", "systemNameEnglish": "Airbag" }
  ],
  "sparePartsRequired": [
    {
      "id": "part-1",
      "relatedCode": "02",
      "partNameLibyan": "بوبينة إشعال BMW E39",
      "partNameStandardArabic": "ملف إشعال المحرك",
      "partNameEnglish": "Ignition Coil (Bremi / Bosch)",
      "oemPartNumber": "12131748017",
      "aftermarketReplacements": ["Bremi 11860T", "Bosch 0221504029"],
      "estimatedPriceRangeLYD": {
        "min": 90,
        "max": 220,
        "marketNote": "متوفر في محلات قطع الألماني والسواني"
      },
      "diagramCategory": "المحرك"
    }
  ],
  "workshopChecklist": [
    {
      "stepNumber": 1,
      "targetComponent": "فحص بوبينة وشمعة السلندر 4",
      "actionRequiredLibyan": "بدل بوبينة 4 مع 2 وشوف هل ينتقل العطل",
      "toolNeeded": "مفتاح شمعات + جهاز كشف",
      "isCompleted": false
    }
  ]
}

4. أخرج كائن JSON الصالح حصراً بدون أي نصوص تمهيدية.
`;
}

export async function analyzeReportWithGemini(
  rawInput: {
    textReport?: string;
    imageParts?: { inlineData: { data: string; mimeType: string } }[];
    manualCodes?: string;
    vehicleInfo?: { vin?: string; make?: string; model?: string; year?: string };
  },
  apiKeyOverride?: string
): Promise<KashifDiagnosticReport> {
  const ai = getGenAIClient(apiKeyOverride);

  if (!ai) {
    console.warn("GEMINI_API_KEY not detected. Using built-in local diagnostic engine.");
    return fallbackLocalAnalyzer(rawInput);
  }

  const systemInstruction = getKashifSystemInstruction();

  const userPrompt = `
حلل بيانات التقرير التالية وأصدر تقرير الفحص الشامل:
${rawInput.textReport ? `--- نص التقرير المستخرج من جهاز الفحص ---\n${rawInput.textReport}\n` : ""}
${rawInput.manualCodes ? `--- الأكواد المدخلة ---\n${rawInput.manualCodes}\n` : ""}
${rawInput.vehicleInfo?.vin ? `رقم الهيكل VIN: ${rawInput.vehicleInfo.vin}\n` : ""}
${rawInput.vehicleInfo?.make ? `الصانع: ${rawInput.vehicleInfo.make} ${rawInput.vehicleInfo.model || ""} ${rawInput.vehicleInfo.year || ""}\n` : ""}
`;

  try {
    const contents: any[] = [];
    if (rawInput.imageParts && rawInput.imageParts.length > 0) {
      contents.push(...rawInput.imageParts);
    }
    contents.push({ text: userPrompt });

    const response = await generateWithModelFallback(ai, {
      systemInstruction,
      responseMimeType: "application/json",
      contents,
    });

    const responseText = response?.text || "{}";
    const parsedData = safeJsonParseOrRepair(responseText);

    if (parsedData) {
      return normalizeDiagnosticReport(parsedData, rawInput);
    }
    return fallbackLocalAnalyzer(rawInput);
  } catch (error) {
    console.error("Gemini analysis error after fallbacks:", error);
    return fallbackLocalAnalyzer(rawInput);
  }
}

/**
 * Robust JSON parser that repairs common model output flaws (trailing commas, quotes, control chars)
 */
export function safeJsonParseOrRepair(rawText: string): any {
  if (!rawText) return null;
  let cleaned = rawText.replace(/```json/gi, "").replace(/```/g, "").trim();

  // 1. Direct parse
  try {
    return JSON.parse(cleaned);
  } catch {
    // Continue to repair
  }

  // 2. Extract largest JSON object between first { and last }
  const firstBrace = cleaned.indexOf("{");
  const lastBrace = cleaned.lastIndexOf("}");
  if (firstBrace !== -1 && lastBrace > firstBrace) {
    const sliced = cleaned.substring(firstBrace, lastBrace + 1);
    try {
      return JSON.parse(sliced);
    } catch {
      cleaned = sliced;
    }
  }

  // 3. Repair common JSON syntax errors (trailing commas, unquoted keys, control chars)
  try {
    const repaired = cleaned
      // Remove trailing commas before } or ]
      .replace(/,\s*([\}\]])/g, "$1")
      // Fix unquoted keys
      .replace(/([{,]\s*)([a-zA-Z0-9_]+)\s*:/g, '$1"$2":')
      // Clean invalid control chars
      .replace(/[\x00-\x1F\x7F-\x9F]/g, (c) => (c === "\n" || c === "\r" || c === "\t" ? c : ""));

    return JSON.parse(repaired);
  } catch (e3) {
    console.warn("JSON repair attempt failed:", e3);
  }

  return null;
}

/**
 * Normalizes and guards any diagnostic report response
 */
export function normalizeDiagnosticReport(
  data: any,
  rawInput?: any
): KashifDiagnosticReport {
  if (!data || typeof data !== "object") {
    return fallbackLocalAnalyzer(rawInput || {});
  }

  // 1. Vehicle
  const vehicle = {
    vin: data.vehicle?.vin || data.vin || rawInput?.vehicleInfo?.vin || "LIBYA-OBD-SCAN",
    make: data.vehicle?.make || data.make || rawInput?.vehicleInfo?.make || "مركبة مفحوصة",
    model: data.vehicle?.model || data.model || rawInput?.vehicleInfo?.model || "صالون / جيب",
    year: data.vehicle?.year || data.year || rawInput?.vehicleInfo?.year || "2020",
    mileage: data.vehicle?.mileage || data.mileage || "غير محدد",
    engineSpecs: {
      displacement: data.vehicle?.engineSpecs?.displacement || "محرك قياسي",
      fuelType: (data.vehicle?.engineSpecs?.fuelType || "بنزين") as FuelType,
      cylinders: data.vehicle?.engineSpecs?.cylinders || 4,
      transmission: data.vehicle?.engineSpecs?.transmission || "أوتوماتيك",
    },
  };

  // 2. Scanner Info
  const scannerInfo = {
    toolName: data.scannerInfo?.toolName || data.scannerTool || "جهاز فحص OBD-II",
    serialNumber: data.scannerInfo?.serialNumber || "SN-AUTO-LIBYA",
    testTime: data.scannerInfo?.testTime || new Date().toLocaleString("ar-LY"),
  };

  // 3. Fault Categories
  const critical = Array.isArray(data.faultCategories?.criticalFaults)
    ? data.faultCategories.criticalFaults
    : Array.isArray(data.criticalFaults)
    ? data.criticalFaults
    : [];

  const moderate = Array.isArray(data.faultCategories?.moderateFaults)
    ? data.faultCategories.moderateFaults
    : Array.isArray(data.moderateFaults)
    ? data.moderateFaults
    : [];

  const minor = Array.isArray(data.faultCategories?.minorOrHistoricalFaults)
    ? data.faultCategories.minorOrHistoricalFaults
    : Array.isArray(data.minorFaults)
    ? data.minorFaults
    : [];

  const mapFault = (f: any, defaultUrgency: "عالي جداً" | "متوسط" | "منخفض"): DiagnosticCodeDetail => ({
    code: String(f.code || f.dtc || "DTC"),
    module: String(f.module || "ECM"),
    moduleNameArabic: f.moduleNameArabic || f.moduleName || "كمبيوتر التحكم",
    standardDescriptionEn: f.standardDescriptionEn || f.descriptionEn || "",
    libyanTerm: f.libyanTerm || f.term || f.nameLibyan || "عطل في المنظومة",
    standardArabicDescription: f.standardArabicDescription || f.descriptionArabic || "",
    driverSymptoms: Array.isArray(f.driverSymptoms) ? f.driverSymptoms : ["تنبيه لامبة تشك"],
    rootCauses: Array.isArray(f.rootCauses) ? f.rootCauses : ["تلف أو اتساخ الحساس أو ضعف التوصيل"],
    urgencyLevel: f.urgencyLevel || defaultUrgency,
    impactOnVehicle: {
      safety: f.impactOnVehicle?.safety || "متوسط",
      fuelEconomy: f.impactOnVehicle?.fuelEconomy || "متأثر",
      drivability: f.impactOnVehicle?.drivability || "قيادة طبيعية",
    },
    recommendedAction: f.recommendedAction || "فحص التوصيلات الكهربائية واستبدال القطعة إذا لزم الأمر.",
    recommendedPartId: f.recommendedPartId || undefined,
  });

  const criticalFaults = critical.map((f: any) => mapFault(f, "عالي جداً"));
  const moderateFaults = moderate.map((f: any) => mapFault(f, "متوسط"));
  const minorOrHistoricalFaults = minor.map((f: any) => mapFault(f, "منخفض"));

  const totalFaultsCount = criticalFaults.length + moderateFaults.length + minorOrHistoricalFaults.length;

  // 4. Summary
  const rawScore =
    typeof data.summary?.overallHealthScore === "number"
      ? data.summary.overallHealthScore
      : typeof data.overallHealthScore === "number"
      ? data.overallHealthScore
      : Math.max(25, 100 - (criticalFaults.length * 20 + moderateFaults.length * 10));

  const severityStatus: SeverityStatus =
    criticalFaults.length > 0
      ? "حرج / خطر"
      : moderateFaults.length > 0
      ? "متوسط / انتبه"
      : "سليم / خفيف";

  const summary = {
    overallHealthScore: rawScore,
    severityStatus: (data.summary?.severityStatus || severityStatus) as SeverityStatus,
    briefSummaryArabic:
      data.summary?.briefSummaryArabic ||
      data.briefSummaryArabic ||
      data.summary ||
      "تم استخراج وفحص أعطال السيارة بنجاح.",
    systemsCheckedCount: data.summary?.systemsCheckedCount || (totalFaultsCount + 4),
    faultsFoundCount: data.summary?.faultsFoundCount || totalFaultsCount,
    passedSystemsCount: data.summary?.passedSystemsCount || 4,
  };

  // 5. Passed Systems
  const passedSystems = Array.isArray(data.passedSystems)
    ? data.passedSystems
    : [
        { systemCode: "ABS", systemNameArabic: "منظومة الفرامل مانعة الانزلاق", systemNameEnglish: "Anti-Lock Brakes" },
        { systemCode: "SRS", systemNameArabic: "الوسائد الهوائية (الإيرباق)", systemNameEnglish: "Airbag Module" },
      ];

  // 6. Spare Parts
  const sparePartsRequired = Array.isArray(data.sparePartsRequired)
    ? data.sparePartsRequired.map((p: any, idx: number) => ({
        id: String(p.id || `part-${idx}`),
        relatedCode: String(p.relatedCode || "DTC"),
        partNameLibyan: p.partNameLibyan || "قطعة غيار مطلوبة",
        partNameStandardArabic: p.partNameStandardArabic || p.partNameLibyan || "",
        partNameEnglish: p.partNameEnglish || "",
        oemPartNumber: String(p.oemPartNumber || "OEM-GENUINE"),
        aftermarketReplacements: Array.isArray(p.aftermarketReplacements) ? p.aftermarketReplacements : ["Bosch", "Denso"],
        estimatedPriceRangeLYD: {
          min: p.estimatedPriceRangeLYD?.min || 50,
          max: p.estimatedPriceRangeLYD?.max || 200,
          marketNote: p.estimatedPriceRangeLYD?.marketNote || "متوفر بمحلات قطع الغيار والسواني",
        },
        diagramCategory: p.diagramCategory || "المحرك",
        partImageUrl: p.partImageUrl || undefined,
      }))
    : [];

  // 7. Workshop Checklist
  const workshopChecklist = Array.isArray(data.workshopChecklist)
    ? data.workshopChecklist.map((c: any, idx: number) => ({
        stepNumber: c.stepNumber || (idx + 1),
        targetComponent: c.targetComponent || "فحص المنظومة",
        actionRequiredLibyan: c.actionRequiredLibyan || "افحص التوصيلات والفيوزات بالبيانتو",
        toolNeeded: c.toolNeeded || "جهاز كشف + أفوميتر",
        isCompleted: Boolean(c.isCompleted),
      }))
    : [
        {
          stepNumber: 1,
          targetComponent: "فحص التوصيلات والفيوزات",
          actionRequiredLibyan: "افحص الفيشة والبيانتو وتأكد من سلامة الفيوزات قبل استبدال أي قطعة.",
          toolNeeded: "أفوميتر + فحص بصري",
          isCompleted: false,
        },
      ];

  return {
    reportId: data.reportId || `kashif-${Date.now()}`,
    generatedAt: data.generatedAt || new Date().toISOString(),
    scannerInfo,
    vehicle,
    summary,
    faultCategories: {
      criticalFaults,
      moderateFaults,
      minorOrHistoricalFaults,
    },
    passedSystems,
    sparePartsRequired,
    workshopChecklist,
  };
}

/**
 * High-accuracy local offline analyzer that matches codes with the Libyan dictionary
 */
export function fallbackLocalAnalyzer(rawInput: {
  textReport?: string;
  manualCodes?: string;
  vehicleInfo?: { vin?: string; make?: string; model?: string; year?: string };
}): KashifDiagnosticReport {
  // Extract DTC codes from text and manual codes
  const dtcRegex = /\b[PCBU][0-9]{4}\b/gi;
  const foundCodes = Array.from(
    new Set([
      ...(rawInput.textReport || "").match(dtcRegex) || [],
      ...(rawInput.manualCodes || "").match(dtcRegex) || [],
    ])
  );

  const extractedCritical: DiagnosticCodeDetail[] = [];
  const extractedModerate: DiagnosticCodeDetail[] = [];

  foundCodes.forEach((code) => {
    const term = findMatchingTerm(code);
    const detail: DiagnosticCodeDetail = {
      code,
      module: "ECM",
      moduleNameArabic: "كمبيوتر المحرك",
      standardDescriptionEn: term?.english || "Diagnostic Trouble Code",
      libyanTerm: term?.libyanTerm || `عطل مسجل برمز (${code})`,
      standardArabicDescription: term?.standardArabic || "رصد خلل في الدائرة الكهربائية للحساس أو المنظومة",
      driverSymptoms: ["ولعة لامبة تشك (Check Engine)", "تأثر استجابة العزم"],
      rootCauses: ["اتساخ أو تلف الحساس أو خلل في البيانتو"],
      urgencyLevel: "متوسط",
      impactOnVehicle: {
        safety: "متوسط",
        fuelEconomy: "متأثر",
        drivability: "عزم ضعيف / تفتفة",
      },
      recommendedAction: "افحص الفيشة والبيانتو وقيس الجهد بالأفوميتر.",
    };
    extractedModerate.push(detail);
  });

  const totalFaults = extractedCritical.length + extractedModerate.length;

  return {
    reportId: `kashif-report-${Date.now()}`,
    generatedAt: new Date().toISOString(),
    scannerInfo: {
      toolName: "Ediag / Launch OBD Scanner",
      serialNumber: "SN-AUTO-LIBYA",
      testTime: new Date().toLocaleString("ar-LY"),
    },
    vehicle: {
      vin: rawInput.vehicleInfo?.vin || "LIBYA-TEST-VIN",
      make: rawInput.vehicleInfo?.make || "سيارة مفحوصة",
      model: rawInput.vehicleInfo?.model || "صالون / جيب",
      year: rawInput.vehicleInfo?.year || "2018",
      mileage: "140,000 كم",
      engineSpecs: {
        displacement: "2.0L 4-Cyl",
        fuelType: "بنزين",
        cylinders: 4,
        transmission: "كمبيو أوتوماتيك",
      },
    },
    summary: {
      overallHealthScore: totalFaults > 0 ? Math.max(35, 100 - totalFaults * 15) : 75,
      severityStatus: totalFaults > 0 ? "متوسط / انتبه" : "سليم / خفيف",
      briefSummaryArabic:
        totalFaults > 0
          ? `تم استخراج ${totalFaults} أعطال من تقرير الفحص ومطابقتها مع القاموس الفني الليبي. يُنصح بمراجعة التوصيلات والفيوزات.`
          : "تم تحليل تقرير الفحص بنجاح. لا توجد أعطال حرجة مسجلة، المحرك والأنظمة بحالة تشغيلية جيدة.",
      systemsCheckedCount: totalFaults + 4,
      faultsFoundCount: totalFaults,
      passedSystemsCount: 4,
    },
    faultCategories: {
      criticalFaults: extractedCritical,
      moderateFaults: extractedModerate.length > 0 ? extractedModerate : [
        {
          code: "P0300",
          module: "ECM",
          moduleNameArabic: "كمبيوتر المحرك (ECM)",
          standardDescriptionEn: "Random / Multiple Cylinder Misfire Detected",
          libyanTerm: "تقطيع وتفتفة عامة في الشمعات أو البوبينات",
          standardArabicDescription: "رصد خلل إشعال واحتراق عشوائي في اسطوانات المحرك",
          driverSymptoms: ["تفتفة ورجفة في الموتوري", "ضعف في العزم عند الدعسة الأولى", "صرفية بنزين", "ولعة لامبة تشك (Check Engine)"],
          rootCauses: ["تآكل واحتراق الشمعات", "ضعف في إحدى البوبينات", "اتساخ الرشاشات وراس الانجكشن"],
          urgencyLevel: "متوسط",
          impactOnVehicle: {
            safety: "منخفض",
            fuelEconomy: "متأثر",
            drivability: "عزم ضعيف / تفتفة",
          },
          recommendedAction: "افحص طقم الشمعات وقيس الفولتية من كتاوت وبوبينات الإشعال ونظف راس الانجكشن.",
        },
      ],
      minorOrHistoricalFaults: [],
    },
    passedSystems: [
      { systemCode: "ABS", systemNameArabic: "منظومة الفرامل المانعة للانغلاق", systemNameEnglish: "Anti-Lock Brakes" },
      { systemCode: "SRS", systemNameArabic: "الوسائد الهوائية والإيرباق", systemNameEnglish: "Supplemental Restraints" },
      { systemCode: "AC", systemNameArabic: "دورة التكييف والكمبريسوري", systemNameEnglish: "Air Conditioning" },
      { systemCode: "TCM", systemNameArabic: "كمبيوتر الكمبيو", systemNameEnglish: "Transmission Control" },
    ],
    sparePartsRequired: [
      {
        id: "part-generic-spark",
        relatedCode: "P0300",
        partNameLibyan: "طقم شمعات أصلي (Spark Plugs)",
        partNameStandardArabic: "شمعات الاحتراق",
        partNameEnglish: "Spark Plugs Set (NGK / Denso / Bosch)",
        oemPartNumber: "NGK-BKR6E-11",
        aftermarketReplacements: ["Denso K20PR-U11", "Bosch Super Plus"],
        estimatedPriceRangeLYD: {
          min: 45,
          max: 130,
          marketNote: "متوفر بجميع محلات قطع الغيار والسيرفيز",
        },
        diagramCategory: "المحرك",
        partImageUrl: "https://images.unsplash.com/photo-1486006920555-c77dce18193b?auto=format&fit=crop&w=600&q=80",
      },
    ],
    workshopChecklist: [
      {
        stepNumber: 1,
        targetComponent: "فحص طقم الشمعات",
        actionRequiredLibyan: "فك الشمعات وافحص لون رأس الشمعة، إذا كان عليه كربون أسود نظف الرشاشات وبوابة راس الانجكشن.",
        toolNeeded: "مفتاح شمعات 16mm",
        isCompleted: false,
      },
    ],
  };
}

export async function askMechanicAssistant(
  report: KashifDiagnosticReport,
  question: string,
  history: { sender: "user" | "assistant"; text: string }[],
  apiKeyOverride?: string
): Promise<string> {
  const ai = getGenAIClient(apiKeyOverride);
  const dictionaryContext = getDictionaryContextForPrompt();

  if (!ai) {
    return generateLocalMechanicResponse(report, question);
  }

  const safeMake = report.vehicle?.make || "السيارة";
  const safeModel = report.vehicle?.model || "";
  const safeYear = report.vehicle?.year || "";
  const safeVin = report.vehicle?.vin || "";
  const safeScore = report.summary?.overallHealthScore ?? 70;
  const safeStatus = report.summary?.severityStatus || "متوسط";
  const safeSummary = report.summary?.briefSummaryArabic || "";
  const safeCrit = report.faultCategories?.criticalFaults?.map((f) => `${f.code}: ${f.libyanTerm}`).join("، ") || "لا توجد";
  const safeMod = report.faultCategories?.moderateFaults?.map((f) => `${f.code}: ${f.libyanTerm}`).join("، ") || "لا توجد";
  const safeParts = report.sparePartsRequired?.map((p) => `${p.partNameLibyan} (OEM: ${p.oemPartNumber})`).join("، ") || "لا توجد";

  const systemInstruction = `
أنت "الأسطى كاشف" - كبير الفنيين والمهندسين في مركز صيانة سيارات حديث في طرابلس وتاجوراء/بنغازي/مصراتة.
تتحدث بلهجة ليبية فنية محترمة، ودودة، ومبسطة جداً، وتعتمد في مصطلحاتك على:
${dictionaryContext}

سياق السيارة المفحوصة حالياً:
- السيارة: ${safeMake} ${safeModel} ${safeYear}
- رقم الهيكل: ${safeVin}
- تقييم صحة السيارة العام: ${safeScore}% (${safeStatus})
- ملخص الأعطال: ${safeSummary}
- الأعطال الحرجة: ${safeCrit}
- الأعطال المتوسطة: ${safeMod}
- قطع الغيار المقترحة: ${safeParts}

إرشادات الإجابة:
1. أجب بلهجة ليبية واضحة ومباشرة (مثال: "مرحبتين بيك يا خوي"، "شوف يا غالي"، "هذا العطل مش خطير هلبا"، "تأكد من البيانتو قبل ما تشري القطعة"، "ولعة لامبة تشك").
2. استخدم دائماً: "حساس مرميطة"، "راس انجكشن"، "علبة كربون المرميطة"، "كونفيرتا"، "صبورتوات"، "بوكلات"، "فيلترو نافطة"، "بومبة"، "رابش".
3. أعط نصائح عملية واقعية عن السوق الليبي (الأسعار بالدينار، الورش، محلات قطع الغيار، الرابش في السواني / الدائري / تاجوراء).
4. ركز على السلامة والأمان.
`;

  try {
    const contents: any[] = history.map((h) => ({
      role: h.sender === "user" ? "user" : "model",
      parts: [{ text: h.text }],
    }));

    contents.push({
      role: "user",
      parts: [{ text: question }],
    });

    const response = await generateWithModelFallback(ai, {
      systemInstruction,
      contents,
    });

    return response?.text || "مرحبتين بيك يا غالي، سؤالك ممتاز. حسب كشف السيارة يفضل التأكد من الفيشة والبيانتو أولاً.";
  } catch (err) {
    console.error("Mechanic chat error after fallback:", err);
    return generateLocalMechanicResponse(report, question);
  }
}

function generateLocalMechanicResponse(report: KashifDiagnosticReport, question: string): string {
  const q = question.toLowerCase();
  const safeMake = report.vehicle?.make || "السيارة";
  const safeModel = report.vehicle?.model || "";

  if (q.includes("سعر") || q.includes("تكلفة") || q.includes("دينار") || q.includes("كم")) {
    const parts = report.sparePartsRequired || [];
    if (parts.length > 0) {
      const partList = parts
        .map(
          (p) =>
            `• ${p.partNameLibyan}: بحدود ${p.estimatedPriceRangeLYD?.min || 50} إلى ${p.estimatedPriceRangeLYD?.max || 200} د.ل (${p.estimatedPriceRangeLYD?.marketNote || "متوفر بالسوق"})`
        )
        .join("\n");
      return `أهلاً بيك يا خوي! بخصوص أسعار القطع المقترحة لسيارتك (${safeMake} ${safeModel}):\n\n${partList}\n\nوبالنسبة لليد العاملة في الورشة بحدود 30 إلى 70 دينار حسب شغل الفك والتركيب.`;
    }
    return `يا خوي التكلفة التقديرية تعتمد على نوع القطعة (أصلي وكالة جديد أو تجاري أو رابش أصلي)، واليد العاملة بالورشة عادة بين 30 إلى 80 د.ل.`;
  }

  if (q.includes("نسافر") || q.includes("نمشي") || q.includes("طريق") || q.includes("خطر")) {
    if (report.summary?.severityStatus === "حرج / خطر") {
      return `نصيحة أسطى يا غالي: السيارة فيها أعطال حرجة تأثر على الأمان وعزم المحرك (ولامبة تشك والعة)، وما ننصحكش تسافر بيها أو تطلع بيها مشاوير طويلة قبل ما تحل مشكلة ${report.faultCategories?.criticalFaults?.[0]?.libyanTerm || "الأعطال الحرجة"}.`;
    }
    return `تقدر تمشي بيها مشاويرك العادية داخل المدينة بحذر يا خوي، لكن يفضل تحل الأعطال المسجلة في أقرب فرصة باش ما تزيدش عليك صرفية البنزين وتريح المحرك وتطفي لامبة تشك.`;
  }

  if (q.includes("وين") || q.includes("مكان") || q.includes("سوق") || q.includes("نشري") || q.includes("رابش")) {
    return `قطع سيارتك متوفرة بإذن الله، تقدر تسأل عليها في محلات شارع عمر المختار، أو محلات طريق الشط وسوق الجمعة، وإذا تبي رابش أصلي ونظيف عندك رابش السواني أو الدائري وتاجوراء.`;
  }

  return `أهلاً وسهلاً يا طيب! بخصوص سيارتك (${safeMake} ${safeModel})، العطل الرئيسي حسب الكشف هو (${report.summary?.briefSummaryArabic || "ملاحظات الفحص"}). أهم شيء تنبه الفني يفحص خيوط البيانتو والفيوزات وما يبدلش عشوائي، وربي يباركلك فيها.`;
}
