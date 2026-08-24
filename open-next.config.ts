import { defineCloudflareConfig } from "@opennextjs/cloudflare";

/**
 * Kashif has no ISR or on-demand revalidation: the report screen is fully
 * client-driven and history lives in the browser's localStorage. So there is
 * no incremental cache override here, which also means no R2 bucket, no KV
 * namespace, and no Durable Object to provision before a deploy works.
 *
 * Add `incrementalCache` here the day a route actually needs revalidating.
 */
export default defineCloudflareConfig();
