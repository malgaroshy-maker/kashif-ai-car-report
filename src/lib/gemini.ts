import { GoogleGenAI } from "@google/genai";
import { getDictionaryContextForPrompt } from "./dictionary";
import {
  KashifDiagnosticReport,
  ChatReportContext,
  DiagnosticCodeDetail,
  SeverityStatus,
  FuelType,
} from "./types";
import { KashifError } from "./errors";
import {
  parseRawReport,
  type RawChecklistStep,
  type RawFault,
  type RawPart,
} from "./report-schema";
import {
  fetchLiveModels,
  KNOWN_MODELS,
  modelsToTry,
  type AvailableModelItem,
} from "./models";

export type { AvailableModelItem };

/**
 * Resolves the Gemini API key for one request.
 *
 * Kashif is bring-your-own-key: the key the caller typed into Settings is the
 * one that must be used. The previous version read `.env.local` off disk on
 * *every* call and returned that first, so a stale server key silently
 * overrode what the user typed — and the JSDoc claimed the opposite order.
 * The disk read also pulled `fs` and `path` into a bundle that has no
 * filesystem.
 *
 * Order now, most specific first:
 *   1. the caller's key (Settings -> `x-gemini-api-key`)
 *   2. `GEMINI_API_KEY` from the environment (a self-hosted or Worker secret)
 *
 * `.env.local` still works in development: Next.js loads it into
 * `process.env` at startup, which is the supported way to read it.
 */
export function resolveActiveApiKey(apiKeyOverride?: string): string | null {
  return pickKey(apiKeyOverride) ?? pickKey(process.env.GEMINI_API_KEY);
}

/** A usable key, or null. Rejects the placeholder shipped in `.env.example`. */
function pickKey(value: string | undefined | null): string | null {
  const key = value?.trim();
  if (!key || key.length <= 10) return null;
  if (key.includes("your_gemini_api_key")) return null;
  return key;
}

export function getGenAIClient(apiKeyOverride?: string): GoogleGenAI | null {
  const apiKey = resolveActiveApiKey(apiKeyOverride);
  if (!apiKey) {
    return null;
  }
  return new GoogleGenAI({ apiKey });
}

/**
 * The model catalogue lives in `./models`. This wrapper only supplies the key.
 */
export async function fetchAvailableGeminiModels(
  apiKeyOverride?: string
): Promise<AvailableModelItem[]> {
  const apiKey = resolveActiveApiKey(apiKeyOverride);
  if (!apiKey) return KNOWN_MODELS;
  return fetchLiveModels(apiKey);
}

/**
 * Runs a request down the availability ladder: the caller's chosen model first,
 * then the shared fallback chain, so a 503 or a quota spike degrades to a
 * slower model instead of failing the request.
 *
 * A model swap is the ONLY kind of fallback allowed in this file. If every
 * model refuses, this throws — it never returns substitute findings.
 */
const MODEL_TIMEOUT_MS = 30_000;

function withTimeout<T>(promise: Promise<T>, ms: number): Promise<T> {
  return Promise.race([
    promise,
    new Promise<never>((_, reject) =>
      setTimeout(
        () => reject(new KashifError("MODEL_UNAVAILABLE", `timeout after ${ms}ms`)),
        ms
      )
    ),
  ]);
}

async function generateWithModelFallback(
  ai: GoogleGenAI,
  params: {
    systemInstruction: string;
    contents: unknown[];
    responseMimeType?: string;
    model?: string;
  }
) {
  const candidates = modelsToTry(params.model || process.env.GEMINI_MODEL);
  let lastError: unknown = null;

  for (const model of candidates) {
    try {
      const response = await withTimeout(
        ai.models.generateContent({
          model,
          config: {
            systemInstruction: params.systemInstruction,
            ...(params.responseMimeType
              ? { responseMimeType: params.responseMimeType }
              : {}),
          },
          contents: params.contents as never,
        }),
        MODEL_TIMEOUT_MS
      );
      if (response?.text) return response;
    } catch (err) {
      if (err instanceof KashifError) throw err;
      const status = (err as { status?: number; code?: number })?.status;
      console.warn(
        `[Gemini] ${model} unavailable (${status ?? "error"}), trying next candidate`
      );
      // Only availability failures are worth retrying on another model. A 4xx
      // is about the key or the request, and trying five more models just
      // multiplies the round trips before showing the same error: an invalid
      // key took six upstream calls to report before this early exit.
      if (status && status >= 400 && status < 500 && status !== 429) {
        throw new KashifError("INVALID_API_KEY", String(status));
      }
      lastError = err;
    }
  }

  const status = (lastError as { status?: number })?.status;
  if (status === 429) throw new KashifError("QUOTA_EXCEEDED");
  throw new KashifError("MODEL_UNAVAILABLE", String(status ?? lastError));
}

export interface RawAnalyzeInput {
  textReport?: string;
  imageParts?: { inlineData: { data: string; mimeType: string } }[];
  manualCodes?: string;
  vehicleInfo?: { vin?: string; make?: string; model?: string; year?: string };
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

2-ب. منظومة القطعة (diagramCategory) لازم تكون واحدة من هذي بالضبط:
"المحرك" | "الفرامل" | "الفرامل والعادم" | "التعليق والصالة" | "الكهرباء" | "التبريد والتكييف" | "الهيكل والمقصورة" | "الهيكل" | "الأمان والوسائد الهوائية" | "نقل الحركة"
- قطع الإيرباق والـ SRS (شريط الدومان / Clock Spring، طقطوقة حزام الأمان، حساس وزن الكرسي، الإيرباق الجانبي، كمبيوتر الـ SRS) منظومتها "الأمان والوسائد الهوائية" — موش "المحرك".
- قطع الكمبيو والكونفيرتا منظومتها "نقل الحركة".
- إذا ما كنتش متأكد من المنظومة، حط null. ممنوع تحط "المحرك" كقيمة افتراضية.

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
  apiKeyOverride?: string,
  modelId?: string
): Promise<KashifDiagnosticReport> {
  const ai = getGenAIClient(apiKeyOverride);

  // No key is a condition to report, not to paper over. The previous version
  // answered this by inventing a full report locally.
  if (!ai) throw new KashifError("NO_API_KEY");

  const systemInstruction = getKashifSystemInstruction();

  const userPrompt = `
حلل بيانات التقرير التالية وأصدر تقرير الفحص الشامل:
${rawInput.textReport ? `--- نص التقرير المستخرج من جهاز الفحص ---\n${rawInput.textReport}\n` : ""}
${rawInput.manualCodes ? `--- الأكواد المدخلة ---\n${rawInput.manualCodes}\n` : ""}
${rawInput.vehicleInfo?.vin ? `رقم الهيكل VIN: ${rawInput.vehicleInfo.vin}\n` : ""}
${rawInput.vehicleInfo?.make ? `الصانع: ${rawInput.vehicleInfo.make} ${rawInput.vehicleInfo.model || ""} ${rawInput.vehicleInfo.year || ""}\n` : ""}
`;

  const contents: unknown[] = [];
  if (rawInput.imageParts?.length) contents.push(...rawInput.imageParts);
  contents.push({ text: userPrompt });

  // Model/availability errors surface as KashifError from the ladder above.
  const response = await generateWithModelFallback(ai, {
    systemInstruction,
    responseMimeType: "application/json",
    contents,
    model: modelId,
  });

  const parsedData = safeJsonParseOrRepair(response?.text || "");

  // An unreadable response means we do not know what is wrong with this car.
  // Saying so is the only safe answer.
  if (!parsedData) throw new KashifError("UNREADABLE_RESPONSE");

  return normalizeDiagnosticReport(parsedData, rawInput);
}

/**
 * Robust JSON parser that repairs common model output flaws (trailing commas, quotes, control chars)
 */
export function safeJsonParseOrRepair(rawText: string): unknown {
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
/**
 * Shapes a model response into the report structure, WITHOUT inventing content.
 *
 * The previous version filled every gap with a plausible default: a VIN of
 * "LIBYA-OBD-SCAN", a year of "2020", an OEM number of "OEM-GENUINE", a price
 * of 50-200 LYD, and a passed-systems list asserting ABS and the airbags were
 * fine. Those are findings about a specific car, and inventing them is exactly
 * what this product exists not to do.
 *
 * The rule now: unknown is `null`, and the UI renders "غير محدد". An empty list
 * stays empty.
 */
export function normalizeDiagnosticReport(
  data: unknown,
  rawInput?: RawAnalyzeInput
): KashifDiagnosticReport {
  const d = parseRawReport(data);

  // A response we cannot even read the shape of tells us nothing about this
  // car. Saying so is the only safe answer.
  if (!d) {
    throw new KashifError("UNREADABLE_RESPONSE", "response did not parse");
  }

  /** First usable value, or null. Never a fabricated placeholder. */
  const pick = (...values: (string | number | null | undefined)[]): string | null => {
    for (const v of values) {
      if (typeof v === "number") return String(v);
      if (typeof v === "string" && v.trim()) return v.trim();
    }
    return null;
  };

  /**
   * A reading that says it has no reading is not a reading.
   *
   * A real Camry scan left the mileage field empty and the model wrote
   * "غير محدد (0 ميل)" — the report then printed "unspecified" and a number
   * in the same breath, and a mechanic reads the number.
   */
  const readingOrNull = (value: string | null): string | null => {
    if (!value) return null;
    if (/غير محدد|غير معروف|not specified|unknown|n\/a/i.test(value)) return null;
    // "0", "0 ميل", "0 كم", "0.0" — an odometer that reads zero was not read.
    if (/^0[\s.,0]*(كم|ميل|km|mi(les)?)?$/i.test(value.trim())) return null;
    return value;
  };

  // 1. Vehicle — every field may legitimately be unknown.
  const vehicle = {
    vin: pick(d.vehicle?.vin, d.vin, rawInput?.vehicleInfo?.vin),
    make: pick(d.vehicle?.make, d.make, rawInput?.vehicleInfo?.make),
    model: pick(d.vehicle?.model, d.model, rawInput?.vehicleInfo?.model),
    year: pick(d.vehicle?.year, d.year, rawInput?.vehicleInfo?.year),
    mileage: readingOrNull(pick(d.vehicle?.mileage, d.mileage)),
    engineSpecs: {
      displacement: pick(d.vehicle?.engineSpecs?.displacement),
      fuelType: (d.vehicle?.engineSpecs?.fuelType || null) as FuelType | null,
      cylinders:
        typeof d.vehicle?.engineSpecs?.cylinders === "number"
          ? d.vehicle.engineSpecs.cylinders
          : null,
      transmission: pick(d.vehicle?.engineSpecs?.transmission),
    },
  };

  // 2. Scanner — the tool name is the one field worth a generic label, since
  // the report demonstrably came from some OBD-II scanner.
  const scannerInfo = {
    toolName: pick(d.scannerInfo?.toolName, d.scannerTool) || "جهاز فحص OBD-II",
    serialNumber: pick(d.scannerInfo?.serialNumber),
    testTime: pick(d.scannerInfo?.testTime),
  };

  // 3. Faults. The model puts these under `faultCategories` or at the root
  // depending on how it read the prompt; both spellings are accepted.
  const asArray = (...candidates: (RawFault[] | null | undefined)[]): RawFault[] =>
    candidates.find(Array.isArray) ?? [];

  const critical = asArray(d.faultCategories?.criticalFaults, d.criticalFaults);
  const moderate = asArray(d.faultCategories?.moderateFaults, d.moderateFaults);
  const minor = asArray(
    d.faultCategories?.minorOrHistoricalFaults,
    d.minorFaults
  );

  const mapFault = (
    f: RawFault,
    defaultUrgency: "عالي جداً" | "متوسط" | "منخفض"
  ): DiagnosticCodeDetail => ({
    code: String(f.code || f.dtc || "").trim() || "—",
    module: pick(f.module) || "—",
    moduleNameArabic: pick(f.moduleNameArabic, f.moduleName) || "منظومة غير محددة",
    standardDescriptionEn: pick(f.standardDescriptionEn, f.descriptionEn) || "",
    libyanTerm:
      pick(f.libyanTerm, f.term, f.nameLibyan) || "عطل غير مسمّى في التقرير",
    standardArabicDescription:
      pick(f.standardArabicDescription, f.descriptionArabic) || "",
    // No invented symptoms or causes: an empty list means the model did not say.
    driverSymptoms: f.driverSymptoms ?? [],
    rootCauses: f.rootCauses ?? [],
    // The schema has already discarded any value outside these three, so a
    // fault labelled "very urgent" lands on its list default instead of
    // reaching the UI with no priority at all.
    urgencyLevel: f.urgencyLevel ?? defaultUrgency,
    impactOnVehicle: {
      safety: f.impactOnVehicle?.safety ?? "متوسط",
      fuelEconomy: f.impactOnVehicle?.fuelEconomy ?? "غير متأثر",
      drivability: f.impactOnVehicle?.drivability ?? "قيادة طبيعية",
    },
    recommendedAction: pick(f.recommendedAction) || "",
    recommendedPartId: pick(f.recommendedPartId) || undefined,
    // The model read this off the scan, so it is about this car — but it is
    // still a claim, and the modal has to say where it came from.
    electricalDiagnostics: f.electricalDiagnostics
      ? { ...f.electricalDiagnostics, provenance: "scan" as const }
      : undefined,
  });

  const criticalFaults = critical.map((f) => mapFault(f, "عالي جداً"));
  const moderateFaults = moderate.map((f) => mapFault(f, "متوسط"));
  const minorOrHistoricalFaults = minor.map((f) => mapFault(f, "منخفض"));
  const totalFaultsCount =
    criticalFaults.length + moderateFaults.length + minorOrHistoricalFaults.length;

  // 4. Passed systems — an unreported system is unknown, not passed. Claiming
  // the ABS passed when nothing said so is a safety claim we cannot make.
  const passedSystems = d.passedSystems ?? [];

  // 5. Summary
  const derivedStatus: SeverityStatus =
    criticalFaults.length > 0
      ? "حرج / خطر"
      : moderateFaults.length > 0
        ? "متوسط / انتبه"
        : "سليم / خفيف";

  const modelScore = d.summary?.overallHealthScore ?? d.overallHealthScore ?? null;

  const summary = {
    // Derived from the faults actually found when the model gives no score.
    // This is arithmetic on real findings, not an invented measurement.
    overallHealthScore:
      modelScore ??
      Math.max(25, 100 - (criticalFaults.length * 20 + moderateFaults.length * 10)),
    isScoreEstimated: modelScore === null,
    severityStatus: d.summary?.severityStatus ?? derivedStatus,
    briefSummaryArabic:
      pick(d.summary?.briefSummaryArabic, d.briefSummaryArabic) || "",
    systemsCheckedCount:
      d.summary?.systemsCheckedCount ?? totalFaultsCount + passedSystems.length,
    faultsFoundCount: d.summary?.faultsFoundCount ?? totalFaultsCount,
    passedSystemsCount: d.summary?.passedSystemsCount ?? passedSystems.length,
  };

  // 6. Spare parts — the OEM number, the aftermarket list and the price are
  // commercial claims someone will spend money on. Unknown stays null.
  const sparePartsRequired = (d.sparePartsRequired ?? []).map(
    (part: RawPart, idx: number) => {
      // The schema keeps a price range only when both ends are real numbers,
      // so there is no half-rendered "from 40 to —".
      const price = part.estimatedPriceRangeLYD;
      return {
          id: String(part.id || `part-${idx}`),
          relatedCode: pick(part.relatedCode) || "",
          partNameLibyan: pick(part.partNameLibyan) || "قطعة غير مسمّاة",
          partNameStandardArabic:
            pick(part.partNameStandardArabic, part.partNameLibyan) || "",
          partNameEnglish: pick(part.partNameEnglish) || "",
          oemPartNumber: pick(part.oemPartNumber),
          aftermarketReplacements: part.aftermarketReplacements ?? [],
          estimatedPriceRangeLYD: price
            ? {
                min: price.min,
                max: price.max,
                marketNote: pick(price.marketNote) || "",
              }
            : null,
          diagramCategory: part.diagramCategory ?? null,
          partImageUrl: pick(part.partImageUrl) || undefined,
        };
    }
  );

  // 7. Checklist — no invented step. Nothing to check is an empty list.
  const workshopChecklist = (d.workshopChecklist ?? []).map(
    (c: RawChecklistStep, idx: number) => ({
      stepNumber: c.stepNumber ?? idx + 1,
      targetComponent: pick(c.targetComponent) || "—",
      actionRequiredLibyan: pick(c.actionRequiredLibyan) || "",
      toolNeeded: pick(c.toolNeeded) || "",
      isCompleted: Boolean(c.isCompleted),
    })
  );

  return {
    reportId: pick(d.reportId) || `kashif-${Date.now()}`,
    generatedAt: pick(d.generatedAt) || new Date().toISOString(),
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
 * The assistant's system prompt for one report.
 *
 * Split out of the old `askMechanicAssistant` so the streaming and buffered
 * paths cannot drift apart — they must send the model the same instructions.
 */
export function assistantPrompt(report: ChatReportContext): string {
  const dictionaryContext = getDictionaryContextForPrompt();

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

  return `
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
}

/** The conversation, newest question last. */
function assistantContents(
  history: { sender: "user" | "assistant"; text: string }[],
  question: string
): unknown[] {
  const contents: unknown[] = history.map((h) => ({
    role: h.sender === "user" ? "user" : "model",
    parts: [{ text: h.text }],
  }));
  contents.push({ role: "user", parts: [{ text: question }] });
  return contents;
}

/**
 * Starts a stream, falling back to another model if this one will not start.
 *
 * The buffered path can try the next model on any failure because nothing has
 * been sent yet. A stream cannot: once a chunk has left, switching models
 * would splice two different answers together. So the decision is made on the
 * **first chunk** — it is pulled here, under the same timeout the buffered
 * path uses, and only once it arrives is the stream handed back. After that
 * point a failure is a failure, not a reason to retry.
 */
async function streamWithModelFallback(
  ai: GoogleGenAI,
  params: { systemInstruction: string; contents: unknown[]; model?: string }
): Promise<AsyncGenerator<string>> {
  const candidates = modelsToTry(params.model || process.env.GEMINI_MODEL);
  let lastError: unknown = null;

  for (const model of candidates) {
    try {
      const stream = await withTimeout(
        ai.models.generateContentStream({
          model,
          config: { systemInstruction: params.systemInstruction },
          contents: params.contents as never,
        }),
        MODEL_TIMEOUT_MS
      );

      // Time to first token, not time to the whole answer: a long reply must
      // not be killed at 45s just because it is long.
      const first = await withTimeout(stream.next(), MODEL_TIMEOUT_MS);
      if (first.done) {
        lastError = new KashifError("UNREADABLE_RESPONSE");
        continue;
      }
      return replayFrom(first.value?.text ?? "", stream);
    } catch (err) {
      if (err instanceof KashifError && err.code !== "MODEL_UNAVAILABLE") throw err;
      const status = (err as { status?: number; code?: number })?.status;
      console.warn(
        `[Gemini] ${model} would not stream (${status ?? "error"}), trying next candidate`
      );
      if (status && status >= 400 && status < 500 && status !== 429) {
        throw new KashifError("INVALID_API_KEY", String(status));
      }
      lastError = err;
    }
  }

  const status = (lastError as { status?: number })?.status;
  if (status === 429) throw new KashifError("QUOTA_EXCEEDED");
  throw new KashifError("MODEL_UNAVAILABLE", String(status ?? lastError));
}

/** Puts the already-pulled first chunk back at the head of the stream. */
async function* replayFrom(
  first: string,
  rest: AsyncGenerator<{ text?: string }>
): AsyncGenerator<string> {
  if (first) yield first;
  for await (const chunk of rest) {
    if (chunk?.text) yield chunk.text;
  }
}

/**
 * The assistant's answer, streamed a piece at a time.
 *
 * A reply runs twenty seconds or more, and it used to land all at once at the
 * end — twenty seconds of a spinner and no way to tell a slow answer from a
 * dead one. Streaming does not make the model faster; it makes the wait
 * legible, which on a workshop phone connection is the part that matters.
 */
export async function* streamMechanicAssistant(
  report: ChatReportContext,
  question: string,
  history: { sender: "user" | "assistant"; text: string }[],
  apiKeyOverride?: string,
  modelId?: string
): AsyncGenerator<string> {
  const ai = getGenAIClient(apiKeyOverride);

  // The assistant used to answer a missing key with canned mechanic advice
  // ("check the fuse and the wiring first"), which reads exactly like a real
  // diagnosis of this car. Say there is no key instead.
  if (!ai) throw new KashifError("NO_API_KEY");

  let stream: AsyncGenerator<string>;
  try {
    stream = await streamWithModelFallback(ai, {
      systemInstruction: assistantPrompt(report),
      contents: assistantContents(history, question),
      model: modelId,
    });
  } catch (err) {
    // A model-availability failure is already a KashifError. Anything else is
    // reported as one — never answered with invented advice about this car.
    if (err instanceof KashifError) throw err;
    console.error("[chat] unexpected", err);
    throw new KashifError("UPSTREAM_ERROR");
  }

  let sawText = false;
  for await (const piece of stream) {
    sawText = true;
    yield piece;
  }
  if (!sawText) throw new KashifError("UNREADABLE_RESPONSE");
}
