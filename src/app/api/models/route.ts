import { NextRequest, NextResponse } from "next/server";
import { fetchAvailableGeminiModels } from "@/lib/gemini";
import { DEFAULT_MODEL } from "@/lib/models";
import { getAgyCliStatus } from "@/lib/antigravity-cli";

export async function GET(req: NextRequest) {
  try {
    const headerApiKey = req.headers.get("x-gemini-api-key") || undefined;
    const models = await fetchAvailableGeminiModels(headerApiKey);
    const hasEnvKey = !!process.env.GEMINI_API_KEY;
    const agyStatus = await getAgyCliStatus();

    return NextResponse.json({
      success: true,
      models,
      defaultModel: DEFAULT_MODEL,
      hasEnvKey,
      agyStatus,
    });
  } catch (error: any) {
    return NextResponse.json(
      { success: false, error: error.message || "فشل جلب النماذج" },
      { status: 500 }
    );
  }
}
