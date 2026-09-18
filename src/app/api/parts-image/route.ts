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
  // The Libyan name is what the dictionary can translate. It never used to be
  // sent, so the dictionary tier was searching an empty list for every part
  // that had an English name.
  const partNameLibyan = searchParams.get("partNameLibyan") || "";

  if (!oem && !partName && !partNameLibyan) {
    return NextResponse.json(
      { success: false, error: "يجب توفير رقم الـ OEM أو اسم القطعة للبحث" },
      { status: 400 }
    );
  }

  try {
    const photo = await searchPartImageOnline(
      oem,
      partName,
      make,
      model,
      year,
      partNameLibyan
    );
    // `source` and `listingUrl` ride along because the card says where the
    // picture came from. A hand-checked photograph of a radiator and somebody's
    // eBay listing for part 84306-06140 are different kinds of claim, and the
    // second is only honest with its listing attached — which is also what
    // eBay's licence expects of anyone displaying it.
    return NextResponse.json(
      {
        success: true,
        imageUrl: photo?.url ?? null,
        source: photo?.source ?? null,
        listingUrl: photo?.listingUrl ?? null,
      },
      { headers: { "Cache-Control": CACHE } }
    );
  } catch (error) {
    // Not finding a photo is not a failure the user needs to see, and the
    // upstream message is not ours to forward. Answer "no photo".
    console.warn("[parts-image] lookup failed:", error);
    return NextResponse.json(
      { success: true, imageUrl: null, source: null, listingUrl: null },
      { headers: { "Cache-Control": "no-store" } }
    );
  }
}
