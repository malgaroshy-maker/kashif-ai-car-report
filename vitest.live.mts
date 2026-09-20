import { defineConfig } from "vitest/config";
import { fileURLToPath } from "node:url";

/**
 * The live photo audit. `npm run audit:live`.
 *
 * Separate from the main suite on purpose: every test under `tests/live/`
 * talks to Wikimedia over the network, so it is slow, it is not deterministic,
 * and it must never be what a pull request waits on. It exists because the
 * offline suite cannot see the one failure that actually took the feature
 * down — an upstream host change that the code then discards in silence.
 */
export default defineConfig({
  test: {
    environment: "node",
    include: ["tests/live/**/*.test.ts"],
    // Each part name is up to four sequential round trips to Wikimedia.
    testTimeout: 300_000,
    // The audit's whole output is a table. Vitest buffers console output per
    // test and prints it after the fact, which turns a three-minute run into
    // three minutes of nothing.
    disableConsoleIntercept: true,
  },
  resolve: {
    alias: {
      "@": fileURLToPath(new URL("./src", import.meta.url)),
    },
  },
});
