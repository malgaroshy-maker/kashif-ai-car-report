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

/** The upstream body, for the server log only. Never sent to the client. */
function upstreamMessage(err: unknown): string {
  return String((err as Error)?.message ?? err).slice(0, 500);
}

/**
 * Which 4xx this is.
 *
 * Every 4xx used to be reported as "Google rejected your key", which is right
 * for a 401/403 and wrong for everything else. The one that cost the most time
 * was the opposite mistake — a genuinely dead key, reported correctly but with
 * nothing in the log to say so, so it read as a model outage for an hour. A
 * 400 can equally be a request this build sent wrongly, and telling the user to
 * go and check their key over that sends them somewhere there is nothing to
 * find.
 */
function classify4xx(err: unknown, status: number): KashifError {
  const message = upstreamMessage(err);
  const aboutTheKey =
    status === 401 ||
    status === 403 ||
    /API_KEY_INVALID|API key not valid|PERMISSION_DENIED|UNAUTHENTICATED/i.test(
      message
    );
  return aboutTheKey
    ? new KashifError("INVALID_API_KEY", String(status))
    : new KashifError("UPSTREAM_ERROR", String(status));
}

/**
 * How much the model is allowed to invent when reading a scan.
 *
 * Nothing. This value was never set, so every analysis ran at the API's
 * default of about 1.0 — the setting for writing prose, on the one call in
 * this app whose whole job is to copy facts out of a PDF without adding any.
 *
 * It showed. The same Camry PDF, uploaded twice, produced four spare parts and
 * then two; the vapour pressure sensor came back as 89460-06020 on one run and
 * 89460-06010 on the next. Both are plausible Toyota numbers and one of them
 * is wrong, and nothing on the card could tell the reader which run they were
 * holding. A mechanic who re-reads the same scan and gets a different parts
 * list has no reason to trust either list.
 *
 * Zero does not make the model correct. It makes it *consistent*, which is
 * the property a report has to have before anyone can check whether it is
 * correct — and it is what the rest of this file already assumes, every time
 * it says the report must not state a finding it did not read.
 */
const ANALYSIS_TEMPERATURE = 0;

async function generateWithModelFallback(
  ai: GoogleGenAI,
  params: {
    systemInstruction: string;
    contents: unknown[];
    responseMimeType?: string;
    model?: string;
    temperature?: number;
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
            ...(params.temperature !== undefined
              ? { temperature: params.temperature }
              : {}),
            ...(params.responseMimeType
              ? { responseMimeType: params.responseMimeType }
              : {}),
          },
          contents: params.contents as never,
        }),
        MODEL_TIMEOUT_MS
      );
      // Which model answered, not which was asked for. The ladder is silent
      // about falling through, and that silence is what makes two runs of one
      // scan impossible to compare.
      if (response?.text) return { response, model };
    } catch (err) {
      if (err instanceof KashifError) throw err;
      const status = (err as { status?: number; code?: number })?.status;
      // The status alone does not say what went wrong, and this line is the
      // only record of it — the client is deliberately never told, because an
      // upstream body can carry the caller's own key. Logging the message
      // server-side is what makes a 400 diagnosable at all: a stale
      // machine-level GEMINI_API_KEY shadowing `.env.local` produced six
      // identical "400" lines and nothing that said "API key not valid".
      console.warn(
        `[Gemini] ${model} unavailable (${status ?? "error"}), trying next candidate:`,
        upstreamMessage(err)
      );
      // Only availability failures are worth retrying on another model. A 4xx
      // is about the key or the request, and trying five more models just
      // multiplies the round trips before showing the same error: an invalid
      // key took six upstream calls to report before this early exit.
      if (status && status >= 400 && status < 500 && status !== 429) {
        throw classify4xx(err, status);
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
  /**
   * The DTCs the PDF parser found in the scan text, by pattern.
   *
   * The parser had been extracting these since the beginning and the route
   * dropped them on the floor. They are ground truth in a way nothing else in
   * the prompt is — matched out of the machine's own printout — so they are
   * quoted back to the model as the list it must not add to or drop from.
   */
  codesFound?: string[];
  /** The tool name the scan printed, e.g. "Ediag". */
  scannerTool?: string;
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
  rawInput: RawAnalyzeInput,
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
${rawInput.codesFound?.length ? `--- الأكواد المقروءة حرفياً من نص التقرير (هذي هي المرجع) ---\n${rawInput.codesFound.join("، ")}\nممنوع تزيد كود ما هوش في القائمة هذي، وممنوع تسقط كود منها. لو نفس الكود متكرر في التقرير بحالات مختلفة (Current / Pending / History) اعتبره عطل واحد وقول في وصفه إنه متكرر وفي أي حالات ظهر.\n` : ""}
${rawInput.scannerTool ? `جهاز الفحص كما طبعه التقرير حرفياً: ${rawInput.scannerTool} — استعمل هذا الاسم كما هو ولا تزيد عليه.\n` : ""}
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
    // Reading a scan is extraction, not writing. See ANALYSIS_TEMPERATURE.
    temperature: ANALYSIS_TEMPERATURE,
  });

  const parsedData = safeJsonParseOrRepair(response.response?.text || "");

  // An unreadable response means we do not know what is wrong with this car.
  // Saying so is the only safe answer.
  if (!parsedData) throw new KashifError("UNREADABLE_RESPONSE");

  const report = normalizeDiagnosticReport(parsedData, rawInput);
  report.analyzedByModel = response.model;
  return report;
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
   * A value that says outright it has no value.
   *
   * The list grew: the first version caught "غير محدد", and a second engine
   * answered the same empty odometer with "غير مسجل / 0 ميل" — a phrase that
   * says "not recorded" and then prints a number anyway. Both halves have to
   * be caught, and it is the whole value that goes, not the tidy half.
   */
  const saysNothing = (value: string): boolean => {
    const v = value.trim();
    // Phrases that disown the value even when something else is printed
    // beside them, so they are looked for anywhere in it.
    if (
      /غير محدد|غير مسجل|غير معروف|غير متوفر|مش مسجل|مش محدد|مش متوفر|not (specified|recorded|available)|unknown/i.test(
        v
      )
    ) {
      return true;
    }
    // "N/A" and a row of dashes only count as the whole value. Matched loose
    // they would hit real content — an "NA" sits inside plenty of part names.
    return /^(n\s*[/.-]?\s*a|-+|—+|\?+)$/i.test(v);
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
    if (saysNothing(value)) return null;

    // A zero odometer, alone or inside a compound: "0", "0 ميل", "0 Miles".
    //
    // Read as numbers rather than as digit runs. A pattern over digits matched
    // the "000" inside "185,000 كم" and threw away a real reading.
    const numbers = (value.match(/\d[\d.,]*/g) ?? []).map((n) =>
      Number(n.replace(/[.,]/g, ""))
    );
    if (numbers.length > 0 && numbers.every((n) => n === 0)) return null;

    return value;
  };

  /**
   * Did the scan itself print this, or did the model work it out?
   *
   * The scan text is the only authority. A displacement the scan never
   * mentions is an inference from the VIN — usually a good one, and still not
   * a reading.
   */
  const scanText = `${rawInput?.textReport ?? ""} ${rawInput?.manualCodes ?? ""}`;
  const statedInScan = (value: string | null): boolean => {
    if (!value || !scanText.trim()) return false;
    // Compared token by token, not whole string: the scan prints "2AZ-FE"
    // where the report writes "2.4L 2AZ-FE", and an exact comparison called a
    // stated engine inferred. A token of four characters or more is
    // distinctive enough to mean the scan really named this thing.
    const norm = (t: string) => t.toLowerCase().replace(/[^a-z0-9]/g, "");
    const haystack = norm(scanText);
    // Split on whitespace only. Splitting on every non-alphanumeric character
    // broke "2AZ-FE" into "2az" and "fe", both under the threshold, and the
    // engine the scan had named came back inferred.
    return value
      .split(/\s+/)
      .map(norm)
      .some((token) => token.length >= 4 && haystack.includes(token));
  };

  /**
   * The engine, with "I do not know" spelled one way.
   *
   * A real Elantra scan prints no engine at all, and the model answered the
   * displacement with the literal string "غير محدد". The plate then rendered
   * "غير محدد · بنزين · كمبيو أوتوماتيك" under a badge saying the engine was
   * worked out from the VIN — a claim to have inferred something, printed
   * beside the word for having inferred nothing. The same filter the odometer
   * uses turns that back into a null the UI already knows how to render.
   *
   * `isInferred` is then decided on the cleaned value, so a spec that does not
   * exist is not also labelled as deduced.
   */
  const engineSpecsOf = (
    specs:
      | {
          displacement?: string | number | null;
          fuelType?: string | null;
          cylinders?: number | null;
          transmission?: string | number | null;
        }
      | null
      | undefined
  ) => {
    const known = (value: string | null): string | null =>
      value && !saysNothing(value) ? value : null;
    const displacement = known(pick(specs?.displacement));
    return {
      isInferred: displacement !== null && !statedInScan(displacement),
      displacement,
      fuelType: (specs?.fuelType || null) as FuelType | null,
      cylinders: typeof specs?.cylinders === "number" ? specs.cylinders : null,
      transmission: known(pick(specs?.transmission)),
    };
  };

  // 1. Vehicle — every field may legitimately be unknown.
  const vehicle = {
    vin: pick(d.vehicle?.vin, d.vin, rawInput?.vehicleInfo?.vin),
    make: pick(d.vehicle?.make, d.make, rawInput?.vehicleInfo?.make),
    model: pick(d.vehicle?.model, d.model, rawInput?.vehicleInfo?.model),
    year: pick(d.vehicle?.year, d.year, rawInput?.vehicleInfo?.year),
    mileage: readingOrNull(pick(d.vehicle?.mileage, d.mileage)),
    engineSpecs: engineSpecsOf(d.vehicle?.engineSpecs),
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
  const allFaults = [
    ...criticalFaults,
    ...moderateFaults,
    ...minorOrHistoricalFaults,
  ];
  const totalFaultsCount = allFaults.length;

  /**
   * How many control units the faults came out of — not how many faults.
   *
   * A scan reports per module. A real Camry scan read eight modules: the
   * engine ECU, the SRS, and six that came back clean. It found eleven codes,
   * all of them in two of those modules, and the plate printed "systems
   * checked: 11" beside "6 passed" — more systems than the machine touched,
   * and a number that grew every time one module produced another code. The
   * Elantra was worse: four codes out of the one EPS module read as four
   * systems.
   */
  const faultedModules = new Set(
    allFaults
      .map((f) => f.module.trim().toUpperCase())
      .filter((m) => m && m !== "—")
  );
  // A fault with no module named still came from somewhere, and that somewhere
  // was checked. Count the unnamed ones as one module between them rather than
  // dropping them, which would under-report a scan the model labelled loosely.
  const unnamedModuleFaults = allFaults.some(
    (f) => !f.module.trim() || f.module.trim() === "—"
  );
  const faultedModuleCount = faultedModules.size + (unnamedModuleFaults ? 1 : 0);

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
    // Always estimated, because no scan tool reports one.
    //
    // This used to be true only when the model gave no number — so when the
    // model did give one, the report printed "الجاهزية" and the reader took it
    // for a measurement off the machine. A real Camry scan came back with 35%
    // labelled as though the scanner had said so; the scanner reports fault
    // codes and nothing else. Whoever produced the number, it is a judgement.
    isScoreEstimated: true,
    severityStatus: d.summary?.severityStatus ?? derivedStatus,
    briefSummaryArabic:
      pick(d.summary?.briefSummaryArabic, d.briefSummaryArabic) || "",
    // Counted from the lists the report actually prints, never taken from the
    // model's own tally.
    //
    // A real Camry scan listed eight SRS codes, two of them the same fault
    // twice; the report merged them to seven and printed seven cards, while
    // the headline kept saying eight because the model's number won. Both were
    // defensible and the document contradicted itself, which is the thing a
    // customer notices first. Whatever is on the page is what gets counted.
    systemsCheckedCount: faultedModuleCount + passedSystems.length,
    faultsFoundCount: totalFaultsCount,
    passedSystemsCount: passedSystems.length,
  };

  // 6. Spare parts — the OEM number, the aftermarket list and the price are
  // commercial claims someone will spend money on. Unknown stays null.
  const oemOrNull = (value: string | null): string | null =>
    value && !saysNothing(value) ? value : null;
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
          // A number nobody can order is not a number. One engine answered
          // an airbag connector repair with an oemPartNumber of "N/A", and
          // the card printed "N/A" in the slot somebody reads out at the
          // parts counter. Same filter the odometer already uses.
          oemPartNumber: oemOrNull(pick(part.oemPartNumber)),
          isOemNumberUnverified: !statedInScan(oemOrNull(pick(part.oemPartNumber))),
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
          // No temperature here on purpose. This one is a conversation with a
          // mechanic — "وش نعمل في الشمعات؟" — where the default is right and
          // two phrasings of the same advice are not a contradiction. The
          // analysis is the call that has to come back the same twice.
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
        `[Gemini] ${model} would not stream (${status ?? "error"}), trying next candidate:`,
        upstreamMessage(err)
      );
      if (status && status >= 400 && status < 500 && status !== 429) {
        throw classify4xx(err, status);
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
