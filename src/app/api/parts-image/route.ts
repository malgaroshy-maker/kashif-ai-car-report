import { NextRequest, NextResponse } from "next/server";
import { searchPartImageOnline } from "@/lib/parts-search";

/**
 * One part photo, looked up lazily.
 *
 * The spare-parts list calls this per card after the report has rendered, so a
 * slow or missing photo costs the user nothing — the card shows its vector
 * schematic until a real photo arrives, and keeps it if none does. This work
 * used to happen inside /api/analyze for every part before the diagnosis was
 * returned.
 */

/** Long enough to matter, short enough that a fixed registry edit lands. */
const CACHE = "public, max-age=86400, stale-while-revalidate=604800";

export async function GET(req: NextRequest) {
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

  try {
    const imageUrl = await searchPartImageOnline(oem, partName, make, model, year);
    return NextResponse.json(
      { success: true, imageUrl: imageUrl || null },
      { headers: { "Cache-Control": CACHE } }
    );
  } catch (error) {
    // Not finding a photo is not a failure the user needs to see, and the
    // upstream message is not ours to forward. Answer "no photo".
    console.warn("[parts-image] lookup failed:", error);
    return NextResponse.json(
      { success: true, imageUrl: null },
      { headers: { "Cache-Control": "no-store" } }
    );
  }
}
