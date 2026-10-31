import { NextRequest, NextResponse } from "next/server";
import { GoogleGenAI } from "@google/genai";
import { resolveActiveApiKey } from "@/lib/gemini";
import { KashifError } from "@/lib/errors";
import { VehiclePartsCatalog } from "@/lib/vehicle-parts-catalog";

// In-memory cache for resolved parts across requests
const partsCache = new Map<string, {
  oemPartNumber: string;
  aftermarketReplacements: string[];
  estimatedPriceRangeLYD: { min: number; max: number };
  confidence: "verified" | "requires_vin";
  catalogSearchUrl: string;
}>();

function buildCacheKey(vehicle: { make?: string; model?: string; year?: string; engine?: string }, partName: string): string {
  const v = `${vehicle.make || ""}_${vehicle.model || ""}_${vehicle.year || ""}_${vehicle.engine || ""}`.toLowerCase().trim();
  const p = partName.toLowerCase().trim();
  return `${v}::${p}`;
}

interface PartInput {
  id: string;
  partNameLibyan?: string;
  partNameStandardArabic?: string;
  partNameEnglish?: string;
  relatedCode?: string;
  existingOem?: string;
}

export async function POST(req: NextRequest) {
  try {
    const body = await req.json();
    const vehicle = body.vehicle || {};
    const parts: PartInput[] = body.parts || [];

    if (!Array.isArray(parts) || parts.length === 0) {
      return NextResponse.json({ success: true, parts: [] });
    }

    const resolvedResults = [];
    const partsToQuery: PartInput[] = [];

    // 0. Primary Check: Verified Vehicle Parts Catalog
    const remainingAfterCatalog: PartInput[] = [];
    for (const part of parts) {
      const catalogMatch = VehiclePartsCatalog.resolve(vehicle, part as any);
      if (catalogMatch) {
        const item = {
          id: part.id,
          oemPartNumber: catalogMatch.oemPartNumber || "مطابقة برقم الهيكل (VIN)",
          aftermarketReplacements: catalogMatch.aftermarketReplacements || [],
          estimatedPriceRangeLYD: catalogMatch.estimatedPriceRangeLYD || { min: 70, max: 180 },
          confidence: "verified" as const,
          catalogSearchUrl: catalogMatch.catalogSearchUrl || VehiclePartsCatalog.generateCatalogSearchUrl(vehicle, catalogMatch),
        };
        const partName = part.partNameEnglish || part.partNameStandardArabic || part.partNameLibyan || "part";
        partsCache.set(buildCacheKey(vehicle, partName), item);
        resolvedResults.push(item);
      } else {
        remainingAfterCatalog.push(part);
      }
    }

    // 1. Check in-memory cache for remainder
    for (const part of remainingAfterCatalog) {
      const partName = part.partNameEnglish || part.partNameStandardArabic || part.partNameLibyan || "part";
      const key = buildCacheKey(vehicle, partName);
      if (partsCache.has(key)) {
        const cached = partsCache.get(key)!;
        resolvedResults.push({
          id: part.id,
          ...cached,
        });
      } else {
        partsToQuery.push(part);
      }
    }

    // If all parts were cached, return immediately (<10ms)
    if (partsToQuery.length === 0) {
      return NextResponse.json({
        success: true,
        source: "cache",
        parts: resolvedResults,
      });
    }

    // 2. Resolve remaining parts dynamically
    const apiKey = resolveActiveApiKey(req.headers.get("x-gemini-api-key") || undefined);
    let newlyResolved: Record<string, any> = {};

    // Strategy A: Gemini with Google Search Grounding
    if (apiKey) {
      try {
        const ai = new GoogleGenAI({ apiKey });
        newlyResolved = await resolveWithGemini(ai, vehicle, partsToQuery);
      } catch (geminiErr: any) {
        console.warn("[ResolveParts] Gemini grounding failed or quota hit, falling back to Apinex:", geminiErr?.message || geminiErr);
        newlyResolved = await resolveWithApinex(vehicle, partsToQuery);
      }
    } else {
      // Strategy B: Fallback to Apinex
      newlyResolved = await resolveWithApinex(vehicle, partsToQuery);
    }

    // 3. Assemble and cache results
    const seenOems = new Set<string>();
    for (const part of partsToQuery) {
      const resolved = newlyResolved[part.id] || generateSafeFallback(vehicle, part);
      
      // Deduplication guard
      let oem = resolved.oemPartNumber;
      if (seenOems.has(oem) && !oem.includes("VIN")) {
        oem = `مطابقة برقم الهيكل (VIN)`;
      } else if (oem && !oem.includes("VIN")) {
        seenOems.add(oem);
      }

      const finalItem = {
        id: part.id,
        oemPartNumber: oem,
        aftermarketReplacements: resolved.aftermarketReplacements || [],
        estimatedPriceRangeLYD: resolved.estimatedPriceRangeLYD || { min: 70, max: 180 },
        confidence: resolved.confidence || "verified",
        catalogSearchUrl: resolved.catalogSearchUrl || generateSearchUrl(vehicle, part, oem),
      };

      const partName = part.partNameEnglish || part.partNameStandardArabic || part.partNameLibyan || "part";
      const key = buildCacheKey(vehicle, partName);
      partsCache.set(key, finalItem);
      resolvedResults.push(finalItem);
    }

    return NextResponse.json({
      success: true,
      source: "live_resolved",
      parts: resolvedResults,
    });
  } catch (error: any) {
    console.error("[ResolveParts] Error resolving parts:", error);
    return NextResponse.json(
      { success: false, error: error?.message || "Failed to resolve parts" },
      { status: 500 }
    );
  }
}

async function resolveWithGemini(
  ai: GoogleGenAI,
  vehicle: any,
  parts: PartInput[]
): Promise<Record<string, any>> {
  const prompt = `You are a master automotive parts catalog engineer with direct EPC access.
Search the live automotive parts databases and Google for the EXACT authentic factory OEM part number and certified aftermarket manufacturer replacement codes (Bosch, Denso, Delphi, Pierburg, Febi, NGK, Hella) for this vehicle:
Vehicle: ${vehicle.year || ""} ${vehicle.make || ""} ${vehicle.model || ""}, Engine: ${vehicle.engine || "Standard"}, VIN: ${vehicle.vin || "Standard"}.

Parts to resolve:
${JSON.stringify(parts, null, 2)}

Strict Requirements:
1. Provide the genuine factory OEM number (e.g. Toyota, GM/Opel, BMW, Hyundai/Mobis).
2. For aftermarketReplacements, provide exact manufacturer part numbers (e.g. "Bosch 0261230042", "Denso 673-1301"). NEVER return just brand names without part numbers.
3. NEVER repeat the same part number across two different components.
4. Estimate market price range in Libyan Dinars (LYD) in Tripoli/Benghazi.
5. Set confidence to "verified" if certain, or "requires_vin" if multiple chassis/engine splits exist.

Respond strictly in valid JSON format:
{
  "parts": [
    {
      "id": "part-id",
      "oemPartNumber": "12345-67890",
      "aftermarketReplacements": ["Brand 12345", "Brand 67890"],
      "estimatedPriceRangeLYD": { "min": 80, "max": 160 },
      "confidence": "verified"
    }
  ]
}`;

  const candidates = ["gemini-3.8-flash", "gemini-2.0-flash"];
  let text = "";

  for (const model of candidates) {
    try {
      const timeoutPromise = new Promise((_, reject) =>
        setTimeout(() => reject(new Error("Timeout after 10s")), 10000)
      );
      const res: any = await Promise.race([
        ai.models.generateContent({
          model,
          contents: prompt,
          config: {
            tools: [{ googleSearch: {} }],
            temperature: 0.1,
          },
        }),
        timeoutPromise,
      ]);
      if (res?.text) {
        text = res.text;
        break;
      }
    } catch (e) {
      console.warn(`[ResolveParts] Model ${model} failed, trying next candidate...`);
    }
  }

  if (!text) {
    throw new Error("No response from Gemini models for parts resolution");
  }

  return parseResolvedJson(text);
}

async function resolveWithApinex(
  vehicle: any,
  parts: PartInput[]
): Promise<Record<string, any>> {
  const apiKey = process.env.APINEX_API_KEY || "";
  const baseUrl = process.env.APINEX_BASE_URL || "https://api.apinex.bond/v1";

  if (!apiKey) {
    throw new Error("No APINEX_API_KEY configured for parts resolution fallback");
  }

  const prompt = `You are a master automotive parts catalog engineer with direct EPC access.
Identify the REAL, GENUINE factory OEM part numbers and REAL certified aftermarket manufacturer replacement codes (Bosch, Denso, Delphi, Pierburg, Febi, NGK, Hella) for this vehicle:
Vehicle: ${vehicle.year || ""} ${vehicle.make || ""} ${vehicle.model || ""}, Engine: ${vehicle.engine || "Standard"}, VIN: ${vehicle.vin || "Standard"}.

Parts to resolve:
${JSON.stringify(parts, null, 2)}

Strict Requirements:
1. Provide genuine factory OEM numbers (e.g. GM, Toyota, BMW, Hyundai). NEVER invent fake "-ALT" or synthetic numbers.
2. For aftermarketReplacements, provide exact manufacturer part numbers (e.g. "Bosch 0261230042", "Denso 673-1301"). NEVER return just brand names without codes.
3. NEVER repeat the same part number across two different components.
4. Estimate market price range in Libyan Dinars (LYD).
5. Set confidence to "verified" if certain, or "requires_vin" if chassis splits exist.

Respond strictly in valid JSON format:
{
  "parts": [
    {
      "id": "part-id",
      "oemPartNumber": "...",
      "aftermarketReplacements": ["Brand 12345", ...],
      "estimatedPriceRangeLYD": { "min": 80, "max": 160 },
      "confidence": "verified"
    }
  ]
}`;

  const res = await fetch(`${baseUrl}/chat/completions`, {
    method: "POST",
    headers: {
      "Content-Type": "application/json",
      "Authorization": `Bearer ${apiKey}`,
    },
    body: JSON.stringify({
      model: "free/deepseek-v4.1-flash",
      messages: [
        { role: "system", content: "You are a professional automotive parts EPC resolver that outputs strictly valid JSON." },
        { role: "user", content: prompt }
      ],
      temperature: 0.1,
    }),
  });

  if (!res.ok) {
    throw new Error(`Apinex error ${res.status}: ${await res.text()}`);
  }

  const json: any = await res.json();
  const text = json.choices?.[0]?.message?.content || "";
  return parseResolvedJson(text);
}

function parseResolvedJson(text: string): Record<string, any> {
  const result: Record<string, any> = {};
  try {
    const cleanJson = text
      .replace(/^```json\s*/m, "")
      .replace(/^```\s*/m, "")
      .replace(/```$/m, "")
      .trim();

    const parsed = JSON.parse(cleanJson);
    const list = parsed.parts || parsed.resolvedParts || [];
    for (const item of list) {
      if (item.id) {
        result[item.id] = item;
      }
    }
  } catch (err) {
    console.warn("[ResolveParts] JSON parse failed, extracting via regex:", err);
    // Regex fallback
    const idMatches = text.matchAll(/"id":\s*"([^"]+)"[\s\S]*?"oemPartNumber":\s*"([^"]+)"/g);
    for (const match of idMatches) {
      result[match[1]] = {
        id: match[1],
        oemPartNumber: match[2],
        aftermarketReplacements: [],
        estimatedPriceRangeLYD: { min: 70, max: 180 },
        confidence: "verified"
      };
    }
  }
  return result;
}

function generateSafeFallback(vehicle: any, part: PartInput) {
  const searchUrl = generateSearchUrl(vehicle, part, "");
  return {
    id: part.id,
    oemPartNumber: "مطابقة برقم الهيكل (VIN)",
    aftermarketReplacements: ["Bosch Automotive", "Denso Aftermarket", "TRW Genuine"],
    estimatedPriceRangeLYD: { min: 80, max: 200 },
    confidence: "requires_vin" as const,
    catalogSearchUrl: searchUrl,
  };
}

function generateSearchUrl(vehicle: any, part: PartInput, oem?: string): string {
  const car = `${vehicle.year || ""} ${vehicle.make || ""} ${vehicle.model || ""}`.trim();
  const pName = part.partNameEnglish || part.partNameLibyan || "";
  const query = `${car} ${pName} ${oem || ""} OEM part number`.trim();
  return `https://www.google.com/search?q=${encodeURIComponent(query)}`;
}
