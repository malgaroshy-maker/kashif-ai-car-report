/**
 * Where this deployment lives.
 *
 * `metadataBase`, the sitemap and the robots file all need an absolute origin,
 * and getting it wrong means a social preview that points at localhost. It is
 * read from the environment so a fork or a preview deployment is correct
 * without editing code, and falls back to production.
 */
export const SITE_URL =
  process.env.NEXT_PUBLIC_SITE_URL?.replace(/\/+$/, "") ||
  "https://kashif.malgaroshy.workers.dev";
