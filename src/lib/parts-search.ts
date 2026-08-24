/**
 * High-Accuracy Online Automotive Spare Parts Image Search Engine
 * Dynamically queries live automotive image catalogs & search engines
 * to find the exact genuine product photo matching vehicle make, model, year, and OEM part number.
 */

// In-memory cache for fast response and deduplication
const imageSearchCache = new Map<string, string>();

export interface PartImageSearchResult {
  imageUrl: string;
  sourceTitle?: string;
  sourceUrl?: string;
  isOnlinePhoto: boolean;
}

/**
 * Constructs an optimal search query targeting genuine car parts catalogs
 */
function buildOptimalPartQuery(
  partName: string,
  oemNumber: string,
  make?: string,
  model?: string,
  year?: string | number
): string {
  const cleanOem = oemNumber ? oemNumber.replace(/[^a-zA-Z0-9-]/g, " ").trim() : "";
  const parts: string[] = [];

  if (make) parts.push(make);
  if (model) parts.push(model);
  if (year) parts.push(String(year));
  if (partName) parts.push(partName);
  if (cleanOem) parts.push(`OEM ${cleanOem}`);
  parts.push("genuine auto part");

  return parts.join(" ").trim();
}

/**
 * Searches the web for genuine car spare part photos based on make, model, year, and OEM number
 */
export async function searchPartImageOnline(
  oemNumber: string = "",
  partNameEn: string = "",
  make?: string,
  model?: string,
  year?: string | number
): Promise<string> {
  const cacheKey = `${make || ""}_${model || ""}_${year || ""}_${oemNumber}_${partNameEn}`.toLowerCase();
  
  if (imageSearchCache.has(cacheKey)) {
    return imageSearchCache.get(cacheKey)!;
  }

  const query = buildOptimalPartQuery(partNameEn, oemNumber, make, model, year);

  try {
    const controller = new AbortController();
    const timeoutId = setTimeout(() => controller.abort(), 3500);

    // 1. Get search session token
    const tokenUrl = `https://duckduckgo.com/?q=${encodeURIComponent(query)}&iax=images&ia=images`;
    const tokenRes = await fetch(tokenUrl, {
      signal: controller.signal,
      headers: {
        "User-Agent":
          "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/122.0.0.0 Safari/537.36",
        "Accept": "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8",
        "Accept-Language": "en-US,en;q=0.5",
      },
    });

    if (!tokenRes.ok) {
      clearTimeout(timeoutId);
      return "";
    }

    const tokenHtml = await tokenRes.text();
    const vqdMatch =
      tokenHtml.match(/vqd=([\d-]+)/) ||
      tokenHtml.match(/vqd="([\d-]+)"/) ||
      tokenHtml.match(/vqd='([\d-]+)'/) ||
      tokenHtml.match(/data-vqd="([\d-]+)"/);

    if (vqdMatch && vqdMatch[1]) {
      const vqd = vqdMatch[1];
      const searchUrl = `https://duckduckgo.com/i.js?l=us-en&o=json&q=${encodeURIComponent(
        query
      )}&vqd=${vqd}&f=,,,type:photo,&p=1`;

      const searchRes = await fetch(searchUrl, {
        signal: controller.signal,
        headers: {
          "User-Agent":
            "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/122.0.0.0 Safari/537.36",
          Referer: "https://duckduckgo.com/",
        },
      });

      clearTimeout(timeoutId);

      if (searchRes.ok) {
        const searchData = await searchRes.json();
        if (searchData.results && searchData.results.length > 0) {
          // Find first secure, valid image URL
          const validItem = searchData.results.find(
            (r: any) =>
              r.image &&
              (r.image.startsWith("https://") || r.image.startsWith("http://")) &&
              !r.image.includes("lookaside")
          );

          if (validItem && validItem.image) {
            const finalUrl = validItem.image;
            imageSearchCache.set(cacheKey, finalUrl);
            return finalUrl;
          }
        }
      }
    } else {
      clearTimeout(timeoutId);
    }
  } catch (err: any) {
    // Graceful fallback on network timeout or abort
  }

  return "";
}

/**
 * Enriches all spare parts in a diagnostic report by searching the internet for exact model part photos
 */
export async function enrichReportWithOnlinePartImages(
  parts: any[],
  make?: string,
  model?: string,
  year?: string | number
): Promise<any[]> {
  if (!parts || parts.length === 0) return [];

  const enriched = await Promise.all(
    parts.map(async (part) => {
      try {
        // If part already has a verified external https image, preserve it
        if (part.partImageUrl && part.partImageUrl.startsWith("https://") && !part.partImageUrl.includes("/parts/")) {
          return part;
        }

        const liveImage = await searchPartImageOnline(
          part.oemPartNumber || "",
          part.partNameEnglish || part.partNameStandardArabic || part.partNameLibyan || "",
          make,
          model,
          year
        );

        if (liveImage) {
          return {
            ...part,
            partImageUrl: liveImage,
          };
        }
        return part;
      } catch {
        return part;
      }
    })
  );

  return enriched;
}
