import type { NextConfig } from "next";
import { initOpenNextCloudflareForDev } from "@opennextjs/cloudflare";
import { PART_IMAGE_HOSTS } from "./src/lib/part-image-hosts";

// Makes Cloudflare bindings (env vars, ASSETS) available during `next dev`,
// so local development behaves like the deployed Worker.
initOpenNextCloudflareForDev();

/**
 * Content-Security-Policy.
 *
 * `connect-src` is the load-bearing one: the app talks to exactly two origins,
 * itself and Google's Generative Language API. A key pasted into settings
 * cannot be posted anywhere else by injected script.
 */
const isDev = process.env.NODE_ENV !== "production";

const csp = [
  "default-src 'self'",
  // Next.js inlines hydration data, and the root layout inlines the
  // before-paint theme script. In development, React & Turbopack require 'unsafe-eval'
  // for callstack reconstruction and debugging overlays.
  `script-src 'self' 'unsafe-inline'${isDev ? " 'unsafe-eval'" : ""}`,
  "style-src 'self' 'unsafe-inline'",
  "font-src 'self' data:",
  // Part photos now come from a fixed set of origins, checked again in
  // /api/parts-image before the URL reaches the browser.
  `img-src 'self' data: blob: ${PART_IMAGE_HOSTS.join(" ")}`,
  "connect-src 'self' https://generativelanguage.googleapis.com",
  "form-action 'self'",
  "base-uri 'self'",
  "object-src 'none'",
  "frame-ancestors 'none'",
  ...(isDev ? [] : ["upgrade-insecure-requests"]),
].join("; ");

const nextConfig: NextConfig = {
  async headers() {
    return [
      {
        source: "/:path*",
        headers: [
          { key: "Content-Security-Policy", value: csp },
          {
            key: "Strict-Transport-Security",
            value: "max-age=63072000; includeSubDomains; preload",
          },
          { key: "X-Content-Type-Options", value: "nosniff" },
          { key: "X-Frame-Options", value: "DENY" },
          {
            key: "Referrer-Policy",
            value: "strict-origin-when-cross-origin",
          },
          {
            key: "Permissions-Policy",
            value: "camera=(), microphone=(), geolocation=(), payment=()",
          },
        ],
      },
      {
        // A pasted API key rides in the request; make sure nothing caches the
        // analysis or the assistant's replies.
        source: "/api/:path*",
        headers: [
          { key: "Cache-Control", value: "no-store, max-age=0" },
        ],
      },
      {
        // The exception: a part photo lookup carries no key and no vehicle
        // data worth protecting, and the answer is the same for everyone.
        // Listed after the rule above so it wins for this one route.
        source: "/api/parts-image",
        headers: [
          {
            key: "Cache-Control",
            value: "public, max-age=86400, stale-while-revalidate=604800",
          },
        ],
      },
    ];
  },
};

export default nextConfig;
