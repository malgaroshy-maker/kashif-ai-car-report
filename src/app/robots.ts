import type { MetadataRoute } from "next";
import { SITE_URL } from "@/lib/site";

/**
 * The API is not for crawlers.
 *
 * `/api/*` is disallowed because every route there either spends a Gemini key
 * or reaches a third-party image API, and a crawler walking them costs the
 * user money for nothing. The app itself is meant to be found.
 */
export default function robots(): MetadataRoute.Robots {
  return {
    rules: {
      userAgent: "*",
      allow: "/",
      disallow: ["/api/"],
    },
    sitemap: `${SITE_URL}/sitemap.xml`,
  };
}
