import { defineConfig, globalIgnores } from "eslint/config";
import nextVitals from "eslint-config-next/core-web-vitals";
import nextTs from "eslint-config-next/typescript";

const eslintConfig = defineConfig([
  ...nextVitals,
  ...nextTs,
  // Override default ignores of eslint-config-next.
  globalIgnores([
    // Default ignores of eslint-config-next:
    ".next/**",
    "out/**",
    "build/**",
    "next-env.d.ts",
    // Build output. `npx eslint .` otherwise walks the whole Cloudflare
    // bundle and reports ~35k problems in code we did not write.
    ".open-next/**",
    // Wrangler's local dev scratch, which holds a bundled copy of the worker.
    ".wrangler/**",
  ]),
]);

export default eslintConfig;
