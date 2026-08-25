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
    // Ad-hoc scripts at the repo root. These are gitignored and never ship;
    // flat config does not read .gitignore, so they are named here.
    "test_*.js",
  ]),
  {
    // The suite asserts on values the product must never produce, so it
    // deliberately contains non-null assertions on parse results and long
    // literal strings that were once invented.
    files: ["tests/**/*.ts"],
    rules: {
      "@typescript-eslint/no-non-null-assertion": "off",
    },
  },
]);

export default eslintConfig;
