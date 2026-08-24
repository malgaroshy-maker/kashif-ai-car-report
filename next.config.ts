import type { NextConfig } from "next";
import { initOpenNextCloudflareForDev } from "@opennextjs/cloudflare";

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
const csp = [
  "default-src 'self'",
  // Next.js inlines hydration data, and the root layout inlines the
  // before-paint theme script. Tightening this to a nonce needs middleware —
  // tracked in plan.md rather than left implied.
  "script-src 'self' 'unsafe-inline'",
  "style-src 'self' 'unsafe-inline'",
  "font-src 'self' data:",
  // Part photos come back from a live image search, so the host is not known
  // ahead of time. Narrows to an allowlist when that search moves behind our
  // own endpoint (F28).
  "img-src 'self' data: blob: https:",
  "connect-src 'self' https://generativelanguage.googleapis.com",
  "form-action 'self'",
  "base-uri 'self'",
  "object-src 'none'",
  "frame-ancestors 'none'",
  "upgrade-insecure-requests",
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
    ];
  },
};

export default nextConfig;
