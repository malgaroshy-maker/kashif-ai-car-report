import { NextRequest, NextResponse } from "next/server";
import { fetchAvailableGeminiModels } from "@/lib/gemini";
import { DEFAULT_MODEL } from "@/lib/models";
import { getAgyStatus } from "@/lib/agy";

export async function GET(req: NextRequest) {
  try {
    const headerApiKey = req.headers.get("x-gemini-api-key") || undefined;
    const models = await fetchAvailableGeminiModels(headerApiKey);
    const hasEnvKey = !!process.env.GEMINI_API_KEY;
    const agyStatus = await getAgyStatus();

    return NextResponse.json({
      success: true,
      models,
      defaultModel: DEFAULT_MODEL,
      hasEnvKey,
      agyStatus,
    });
  } catch (error) {
    // The upstream message is not ours to forward: a Google error body can
    // quote back the key that was sent with the request.
    console.error("[models] unexpected", error);
    return NextResponse.json(
      { success: false, error: "فشل جلب قائمة النماذج" },
      { status: 500 }
    );
  }
}
