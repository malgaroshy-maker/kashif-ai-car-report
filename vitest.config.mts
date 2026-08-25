import { defineConfig } from "vitest/config";
import { fileURLToPath } from "node:url";

/**
 * The suite guards one property above all others: that this app never states a
 * finding about a car it did not read. Everything under `tests/` exists
 * because a real version of this product once did exactly that.
 */
export default defineConfig({
  test: {
    environment: "node",
    include: ["tests/**/*.test.ts"],
  },
  resolve: {
    alias: {
      "@": fileURLToPath(new URL("./src", import.meta.url)),
    },
  },
});
