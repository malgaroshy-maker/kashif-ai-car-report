import type { MetadataRoute } from "next";
import { SITE_URL } from "@/lib/site";

/** Two pages: the app, and the design system's living spec. */
export default function sitemap(): MetadataRoute.Sitemap {
  return [
    { url: SITE_URL, changeFrequency: "monthly", priority: 1 },
    { url: `${SITE_URL}/design`, changeFrequency: "monthly", priority: 0.3 },
  ];
}
