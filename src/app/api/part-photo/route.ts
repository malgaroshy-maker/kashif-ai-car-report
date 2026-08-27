import { NextRequest, NextResponse } from "next/server";
import { isAllowedPartImage } from "@/lib/part-image-hosts";

/**
 * The bytes of one part photo, fetched by the app's own origin.
 *
 * The exported report embeds its photos so the file is genuinely self
 * contained. The browser cannot fetch them itself: `connect-src` in the CSP is
 * deliberately `'self'` plus Google and nothing else, so that a key pasted into
 * settings cannot be posted anywhere by injected script. Widening it to the
 * photo hosts to save one hop would trade that away for a picture.
 *
 * Two of the three allowed hosts also send no `Access-Control-Allow-Origin`,
 * so even with the CSP opened up their photos could not be read in the page.
 * Server side there is no such restriction.
 *
 * The URL is checked against the same allowlist the rest of the app uses
 * before anything is fetched. Without that this route is an open proxy: any
 * page could hand it an internal address and read the response through us.
 */

/** A part photo does not change. */
const CACHE = "public, max-age=604800, immutable";

/** Matches the export's own per-report budget; one file cannot exceed it. */
const MAX_BYTES = 1_500_000;

export async function GET(req: NextRequest) {
  const url = new URL(req.url).searchParams.get("url") || "";

  if (!isAllowedPartImage(url)) {
    return NextResponse.json(
      { success: false, error: "مصدر الصورة غير مسموح" },
      { status: 400 }
    );
  }

  try {
    const upstream = await fetch(url, {
      headers: { "User-Agent": "KashifAI-CarReport/1.0 (+report export)" },
      signal: AbortSignal.timeout(8000),
    });

    const type = upstream.headers.get("content-type") || "";
    if (!upstream.ok || !type.startsWith("image/")) {
      return NextResponse.json(
        { success: false, error: "تعذّر جلب الصورة" },
        { status: 502 }
      );
    }

    const bytes = await upstream.arrayBuffer();
    if (bytes.byteLength > MAX_BYTES) {
      return NextResponse.json(
        { success: false, error: "الصورة أكبر من الحد المسموح" },
        { status: 413 }
      );
    }

    // Only the image is passed through. Nothing upstream sets a header on this
    // response — a `Set-Cookie` from a parts catalogue is not ours to forward.
    return new NextResponse(bytes, {
      headers: { "Content-Type": type, "Cache-Control": CACHE },
    });
  } catch (error) {
    console.warn("[part-photo] fetch failed:", error);
    return NextResponse.json(
      { success: false, error: "تعذّر جلب الصورة" },
      { status: 502 }
    );
  }
}
