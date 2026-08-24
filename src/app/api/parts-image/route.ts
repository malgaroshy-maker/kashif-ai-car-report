import { NextRequest, NextResponse } from "next/server";
import { searchPartImageOnline } from "@/lib/parts-search";

export async function GET(req: NextRequest) {
  try {
    const { searchParams } = new URL(req.url);
    const make = searchParams.get("make") || "";
    const model = searchParams.get("model") || "";
    const year = searchParams.get("year") || "";
    const oem = searchParams.get("oem") || "";
    const partName = searchParams.get("partName") || "";

    if (!oem && !partName) {
      return NextResponse.json(
        { success: false, error: "يجب توفير رقم الـ OEM أو اسم القطعة للبحث" },
        { status: 400 }
      );
    }

    const imageUrl = await searchPartImageOnline(oem, partName, make, model, year);

    return NextResponse.json({
      success: true,
      imageUrl: imageUrl || null,
      query: { make, model, year, oem, partName },
    });
  } catch (error: any) {
    console.error("Part image API error:", error);
    return NextResponse.json(
      { success: false, error: error.message || "حدث خطأ أثناء جلب صورة القطعة" },
      { status: 500 }
    );
  }
}
