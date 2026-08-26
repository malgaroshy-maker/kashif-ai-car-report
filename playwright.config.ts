import { defineConfig, devices } from "@playwright/test";

/**
 * End-to-end, against the real Cloudflare Worker.
 *
 * `next dev` is not the thing that ships. Every bug this project found at the
 * deployment boundary — /api/models returning 500 because a route dragged
 * `child_process` into the edge runtime, the whole build directory being
 * served as public assets — was invisible in dev and obvious in `cf:preview`.
 * So the suite drives the built Worker.
 *
 * Two projects, because the product is used equally on both and the plan says
 * neither is primary: a phone at the car, and a laptop at the desk.
 */
const PORT = 8787;
const BASE = `http://127.0.0.1:${PORT}`;

export default defineConfig({
  testDir: "./e2e",
  fullyParallel: false,
  forbidOnly: !!process.env.CI,
  retries: process.env.CI ? 1 : 0,
  workers: 1,
  reporter: process.env.CI ? "github" : "list",

  use: {
    baseURL: BASE,
    trace: "retain-on-failure",
    locale: "ar-LY",
  },

  projects: [
    { name: "desktop", use: { ...devices["Desktop Chrome"] } },
    { name: "mobile", use: { ...devices["Pixel 7"] } },
  ],

  webServer: {
    // Build then serve. `cf:preview` alone would happily serve a stale bundle
    // and pass against code that is no longer in the repo.
    command: "npm run cf:build && npm run cf:preview",
    url: BASE,
    reuseExistingServer: !process.env.CI,
    timeout: 10 * 60 * 1000,
    stdout: "ignore",
    stderr: "pipe",
  },
});
