# Kashif AI — Rebuild Plan

**Status:** design system built and verified (Part 1, Phase 4). Phase 1 done and verified. Phases 0, 2, 3, 5-7 outstanding.
**Scope:** full visual redesign, engineering remediation, and a real Cloudflare deployment.
**Written:** 2026-08-24 · **Product truth:** [PRODUCT.md](PRODUCT.md)

> **Uncommitted.** Everything from this session is still working-tree only.

---

## 0. Decisions already made

| Question | Decision |
|---|---|
| AI access model | **Bring-your-own key.** Each user pastes their own Google AI Studio key. No shared key ships. The two sample reports must work with no key at all. |
| Primary device | **Both equally.** Full responsive parity, phone-in-the-bay and desk. |
| `agy` / Antigravity engine | **Development-only.** Gated out of production builds, hidden from the UI on the web. |
| Cloudflare | **Migrate to `@opennextjs/cloudflare`.** Retire the hand-written `src/worker.ts` and `scripts/prepare-cloudflare.js`. |
| Visual world | **The Fuse-Box Lid** — the legend silkscreened inside a car's fuse-box lid. |

---

# PART 1 — The redesign

**Status: built.** Tokens, typography, severity notation and base primitives are in the repo and verified. The surface rebuild (Phase 5) is not started.

| File | What it holds |
|---|---|
| [globals.css](src/app/globals.css) | Tokens for both themes, base layer, browser surfaces, primitives, print |
| [severity.ts](src/lib/design/severity.ts) | The severity notation — single source of truth |
| [SeverityMark.tsx](src/components/ui/SeverityMark.tsx) | The four drawn shapes |
| [primitives.tsx](src/components/ui/primitives.tsx) | Cell, CodePlate, BankRule, Field, SeverityLegend, Button |
| [ThemeToggle.tsx](src/components/ui/ThemeToggle.tsx) | Day bay / night bay |
| [layout.tsx](src/app/layout.tsx) | Fonts, theme bootstrap, the direction contract |
| [design/page.tsx](src/app/design/page.tsx) | The living spec — `/design` |

## 1.1 What we are replacing and why

The old UI was a dark slate/blue technical dashboard: `bg-[#090D16]`, blue-400 icon chips, rounded cards, a gauge. Competent, and the exact look every AI tool ships. Three concrete failures beyond genericness:

- **No typeface.** The old `globals.css` set a system stack, so Arabic rendered in Segoe UI on Windows, Noto on Android, Geeza on iOS. The product's core asset is Arabic vocabulary and it had no typographic identity at all.
- **Tokens that nothing used.** Sixteen CSS custom properties were declared and then ignored; components hardcoded `slate-800`, `blue-400`, `#0D1527`.
- **Dark-only, in daylight.** `<html className="dark">` was hardcoded. The scene is a mechanic on a phone in a Libyan repair bay. The print stylesheet was a 40-line `!important` override compensating for it.

## 1.2 The direction contract

Committed verbatim as an HTML comment in [layout.tsx](src/app/layout.tsx), so it survives the production build and can be audited against the render.

> **THESIS** — Kashif does not draw a dashboard, it prints a fuse-box legend. Faults are cells in a moulded board, ordered by what strands the driver. It refuses this category's arrangement: floating rounded cards on a dark ground with a coloured gauge.
>
> **OWN-WORLD** — Moulded polymer board, silkscreen ink, hairline and heavy moulded ribs instead of shadows. Severity rides on a fuse seated in its slot: a solid block carrying its mark and amp rating. Status colour is ISO/DIN 72581-3 blade fuse code, plus 15A blue as the only interactive ink. Nothing else is chromatic. Nothing is rounded. One shadow exists, on a pulled cell.
>
> **STORY** — The mechanic reads faults in his own words, ranked by danger, with the test to run before buying the part.
>
> **FIRST VIEWPORT** — Masthead and vehicle plate, the legend key beside them, then the critical bank opening on a heavy rib — phone and desk alike.
>
> **FORM** — The Fuse-Box Lid; grounded candidate 3, assigned by seed `3a0b3d60` and confirmed by you over the certificate.

### The two material facts

1. **Depth is a moulded rib, never a shadow.** `.rib` pairs a dark groove with a lit crest (`border-block-start` plus `inset 0 1px 0 var(--rib-lit)`). That pair is how a ridge in plastic actually reads. Exactly one shadow exists in the system, `--lift`, and it belongs to a cell pulled out of the board.
2. **Status colour is not a palette.** It is the blade-fuse colour code printed on every fuse in every car, so the mechanic decodes it without being taught.

### Named raises

Disciplines donated by the directions this one was weighed against. Each transfers a rule, not a look.

- **from the timetable rack** — one body type size across the whole board; rank is weight, case and rule, never six font sizes.
- **from the hazard grammar** — every severity carries a shape as well as an ink, so it survives a monochrome printout and colour-blind reading.
- **from the phosphor terminal** — the analysis prints its own progress as cells filling in, instead of a spinner. *(Phase 5.)*
- **from the WPA poster** — ink discipline: two inks plus the status inks, and the ground does all the shading. No gradients, no glow.

### Honest risk

Red, yellow and green on a charcoal board read as a Christmas tree the moment an ink is used for anything but severity. **The ink law is what saves it:** `--amp-15-*` and the four status inks are the only chromatic values in the system, and a new colour requires deleting one.

## 1.3 Tokens

Light leads. The scene forced it: a phone held at arm's length in Libyan daylight, and a report printed on a black-and-white office printer. Dark is the night bay — the canonical charcoal lid — not a filter over the light one. Both are materially honest; fuse-box lids ship in pale grey with black print and in charcoal with white silkscreen.

```css
/* Light — the pale grey lid */             /* Dark — the charcoal lid */
--board:      #d5d7cf;                       --board:      #17191a;
--board-sunk: #c2c5bc;                       --board-sunk: #0e1011;
--cell:       #f4f4f0;                       --cell:       #212426;
--ink:        #1a1d19;                       --ink:        #edeeea;
--ink-2:      #4c524a;                       --ink-2:      #a3a9a5;
--ink-3:      #525956;                       --ink-3:      #8b928e;
--rib:        #a9ada5;  /* the groove */     --rib:        #0b0d0e;
--rib-lit:    #eceee7;  /* the lit crest */  --rib-lit:    #363b3d;
```

Status inks, ISO/DIN 72581-3. Each tier carries two values. **`-ink` carries every meaning**: marks, text, and filled grounds (with `--cell` on top). **`-tab` is the fuse's literal plastic colour and appears only on the large legend swatches**, where it is shown as itself. That split is not stylistic — 20A fuse yellow sits at roughly 1.3:1 on the light cell, so a mark drawn in it would be invisible.

| Tier | Fuse | Shape | Light `-tab` / `-ink` | Dark `-tab` / `-ink` |
|---|---|---|---|---|
| حرج | 10A red | filled triangle | `#de3b2f` / `#a81f15` | `#f0554a` / `#ff9188` |
| متوسط | 20A yellow | half bar | `#f2c200` / `#7a5500` | `#f5cb1e` / `#f0c94f` |
| سليم | 30A green | tick | `#2e9e5b` / `#125b2f` | `#3fbe73` / `#63d795` |
| ذاكرة | 25A clear | hollow ring | `#c8cbc5` / `#565c59` | `#8e948f` / `#b0b6b2` |
| *(interactive)* | 15A blue | — | `#2e7fc4` / `#0f5288` | `#4a9bdd` / `#82c0f0` |

Every token is declared on bare `:root` first, then redefined under `:root[data-theme="dark"]` and under `@media (prefers-color-scheme: dark)` guarded by `:not([data-theme="light"])`, so the toggle wins in both directions.

Space is a 4px module (`--s1` through `--s8`) — a fuse box is a grid of fixed pitches. Radius is `2px`, used on inputs and nothing else. Motion is three moments on one curve (`cubic-bezier(.16,1,.3,1)`): mark 90ms, lift 160ms, sheet 200ms.

## 1.4 Typography

| Role | Face | Why |
|---|---|---|
| Arabic + Latin, everything | **Readex Pro** (variable, arabic + latin subsets) | An Arabic-first design, not a Latin face with Arabic bolted on. Engineered for legibility at small sizes and poor contrast — the actual scene. Avoids the Arabic-web default trio (Cairo / Tajawal / Rubik). |
| Measured values only | **Azeret Mono** (latin, 400/600) | DTCs, OEM numbers, VINs, voltages, fuse ratings. Reads as stamped onto the board. Mono is here for data, never as a costume for "technical". |

Both self-hosted through `next/font/google`, `display: swap`, with automatic metric-matched fallbacks. No display face exists — a fuse-box lid has none, which is exactly what the one-type-size raise wants.

**One body size.** `--t-body` at 15px, 16px from 768px, carries every field value, fault name, checklist step and part row. Above it sit only `--t-title` (the vehicle name) and `--t-score` (the health indicator). Below it, `--t-plate` for code plates and `--t-label` for tracked field captions.

Latin numerals throughout, `tabular-nums` on all data. A fuse box prints `F14`, `15A` and `P0102`; Arabic-Indic numerals would belong to a different world.

## 1.5 Component language

Every container is a silkscreened panel recessed into the board. There is no card, no nested card, no rounded corner, and no shadow except on a pulled cell.

| Component | Form |
|---|---|
| `Cell` | The only container — a recessed silkscreened panel. `lifted` applies the one shadow. It carries no colour of its own. |
| `CodePlate` | Reversed mono on a solid ink block. Holds a measured value and nothing else. |
| `BankRule` | The heavy moulded rib opening a severity bank, with the bank name, count and amp rating set inside the rule. |
| `SeverityMark` | The four drawn shapes — triangle, half bar, tick, ring. `labelled` suppresses the `aria-label` when a visible label already names the tier. |
| `SeveritySeat` | The fuse in its slot: a solid `-ink` block carrying the mark and the amp rating, at a fault row's leading edge. An object you could pull out — which is the interaction the report is built on. |
| `SeverityLegend` | The key panel a real lid prints, so the colour code is taught before it is used. |
| `Field` | Label above, value below, hairline under. Renders missing data as an italic "غير محدد" rather than inventing a plausible default (see F18). |
| `Button` | Square, `--tap`-sized. Filled variants take `-ink`; pressed sinks into the board instead of lifting off it. |
| `ThemeToggle` | Day bay / night bay, applied before first paint by a tiny inline script so a stored theme never flashes the other lid. |

**Browser surfaces are themed**, not left at browser defaults: selection, caret, focus ring, link underline offset, and a square scrollbar drawn from `--rib` and `--board-sunk`.

A temporary bridge in `globals.css` maps the incumbent `.workbench-panel`, `.workbench-card` and `.font-heading` classes onto the new tokens, so the existing screens keep rendering — and pick up the new palette — while they are rewritten. It is marked for deletion with Phase 5.

## 1.6 Verification

Run on `/design` at 1280x1000, both themes:

- **Contrast — 0 failures in light, 0 in dark**, auditing every text node against its resolved background at the WCAG AA threshold for its size and weight. This pass forced three fixes: `--ink-3` was raised in both themes, the light board was lightened from `#c9cbc4` to `#d5d7cf`, and filled buttons and plates were moved off `-tab` onto `-ink` (light primary measured 2.59:1 before that change).
- **RTL** — `dir=rtl` verified live: the fuse seat sits at each row's leading edge, logical properties resolve correctly, and no layout mirrors by accident.
- **Fonts** — `Readex Pro` resolved on `body` with its generated fallback; no console errors; no horizontal overflow at 1280.
- **Theme toggle** — writes `data-theme` and `localStorage`, and survives reload.
- **Mobile at 375px** — no horizontal overflow, no overflowing elements, body at 15px, every tap target 44px or larger.
- **Mechanical detector** — clean. Its one finding was the first cut of the amp tab: a 6px coloured `border-inline-start` on the fault cell, which is the side-accent stripe that reads as an AI-generated tell however it is justified. Replaced with `SeveritySeat`, which is both a stronger object and more materially honest — and it can show the amp rating, which the border could not.
- **Print** — the status inks are pinned to their light-lid values inside `@media print`, so a report printed at night does not come out in the pale night-bay reds. Not yet checked against a real printout.

Not yet verified: a real printout, and keyboard traversal of the full page. Both belong to the batched inspection round at the end of Phase 5.

## 1.7 Screens still to build (Phase 5)

1. **First run / no key** — the fatal gap today: the live site's only path is two demo buttons and the key field is buried behind a wrench icon. The board arrives empty, with the ingestion cell as its first bank and a visible, explained key step.
2. **Ingestion** — one cell, three tabs: PDF, صورة شاشة, إدخال يدوي. The drop target is a recessed cell, not a dashed rounded box.
3. **Analysing** — cells fill in one by one with the real steps, no spinner.
4. **Report** — masthead, vehicle plate, legend, fault banks, checklist, parts, locator appendix.
5. **Pull the fuse** — the signature interaction. Tapping a fault's `SeveritySeat` lifts the cell to reveal fuse number, pin voltages and sensor position, replacing `SensorFuseLocatorModal`. This is the one place `--lift` is used.
6. **Print / export** — the screen design is the print design. The status inks drop out and the shapes carry severity.
7. **Empty / error / no-faults** — designed states, not blank divs.

**Craft-floor items to honour when those screens are written:** no eyebrow or kicker above a heading (the current landing has one), no same-size icon-heading-text card row as page structure (the current landing has three), and no modal for a task that needs neither interruption nor protected focus.

# PART 2 — Engineering findings

## 2.1 P0 — Actively wrong in production

**F1 · The app fabricated reports and did not say so.** — **FIXED**

The deployed Worker did this on a JSON parse failure:

```ts
if (!parsedReport) { parsedReport = SAMPLE_BMW_528I; }   // src/worker.ts:200
```

A user who uploaded a Toyota scan could be handed the **BMW demo report** as their own vehicle's faults, with no error shown. `analyzeReportWithGemini` had the same shape: any failure returned `fallbackLocalAnalyzer()`, which manufactured a whole diagnosis — a P0300 misfire, a spark-plug part, a 45-130 LYD price — for a car nobody had analysed. The chat assistant did it too, answering a missing key with canned advice about checking the fuse and wiring.

Fixed by [errors.ts](src/lib/errors.ts): a typed `KashifError` with an Arabic message and a machine-readable code, returned by every failure path in the Worker, both API routes, and the library.

- The Worker's sample substitution is gone; the two demos are served only for an explicit `sampleId`.
- `fallbackLocalAnalyzer` and `generateLocalMechanicResponse` are **deleted**. Neither had an honest use.
- A model swap is now the only thing "fallback" may mean. If every model refuses, the request fails.
- Upstream error bodies are logged, never returned — a Gemini error body can echo the caller's own key.

Two further faults surfaced while verifying this, both fixed:

- **An invalid key burned the whole model ladder.** Only 401/403 exited early, so a 400 (which is what Google returns for a malformed key) retried five more models before reporting. Any 4xx except 429 now fails fast.
- **An empty request hung forever.** The JSON branch of the Next route had no input guard, so `{}` reached the model as a prompt with no scan in it. There was also no timeout on the SDK call. Both fixed: `NO_INPUT` is rejected, and every model call is bounded at 45s.

**F2 · One stale model ID, and the Worker silently downgraded the model.** — **FIXED** *(The model list was verified against `GET /v1beta/models` with the project key on 2026-08-24: `gemini-3.7-flash`, `gemini-3.6-flash`, `gemini-3.5-flash`, `gemini-3.5-flash-lite`, `gemini-3.1-flash-lite`, `gemini-3-flash-preview`, `gemini-2.5-flash` and `gemini-2.5-pro` all exist and serve `generateContent`. An earlier draft of this plan wrongly called them invented.)*

[models.ts](src/lib/models.ts) is now the one place model IDs live, shared by `gemini.ts`, the Worker and the settings UI.

- The Worker defaulted to `gemini-2.5-flash`, two generations below what the UI advertised. It now uses `DEFAULT_MODEL`.
- Retired `gemini-2.0-flash` removed.
- `/api/models` queries the live endpoint when a key is present and falls back to the shared offline list otherwise, so the catalogue cannot drift again.
- **F12 folded in:** the model picker was writing `kashif_gemini_model` to localStorage and stopping there. The choice now travels as `x-gemini-model` (and in the body / form field) and is honoured by both runtimes.

**F3 · Production has no key, so the live site does nothing.**

```
$ curl https://kashif.malgaroshy.workers.dev/api/models
{"success":true,"hasEnvKey":false,...}
```

Under the BYO-key decision this is correct behaviour — but the UI is not built for it. Fixed by the first-run screen in §1.7.

**F4 · The entire build output is published publicly.** `prepare-cloudflare.js` does `fs.cpSync(publicDir, nextDir)` and `wrangler.jsonc` points `assets.directory` at `.next` — the whole thing. Verified live, all HTTP 200:

```
/server/app/index.html   /BUILD_ID   /build-manifest.json
/required-server-files.json   /app-path-routes-manifest.json   /cache/.rscinfo
```

`.next/server/**` is 15 MB of server bundles containing the full system prompt and every lib. Locally `.next` is **378 MB** (`cache` 168 MB, `dev` 191 MB) — far past Workers' asset limits. *(Checked: no API key is inlined in any build artifact.)*

**F5 · CI deploys to the wrong product and has never deployed the live site.** [deploy-cloudflare.yml:50](.github/workflows/deploy-cloudflare.yml) runs `pages deploy .next --project-name=kashif-ai-car-report` — Cloudflare **Pages** — while production is a **Worker** named `kashif`. Even on success it would serve static assets with no `worker.ts`, so all four API routes would 404.

## 2.2 P1 — Architecture

**F6 · Two copies of the API, already drifted.** `src/worker.ts` (241 lines) reimplements all four routes from `src/app/api/*`. In production the Next routes are dead code. The worker's copy is already missing PDF text extraction, part-image enrichment, and chat history, and it carries a different model list. Every future fix has to be written twice or silently isn't.

**F7 · `gemini.ts` reads `.env.local` off disk on every key resolution.** [gemini.ts:20-53](src/lib/gemini.ts) does `fs.readFileSync(process.cwd() + "/.env.local")` per call, and `worker.ts` imports this module — pulling `fs`/`path` into an edge bundle where it can never work. A filesystem read per request, a secret-handling smell, and a portability landmine.

**F8 · Key priority is documented backwards.** The JSDoc says env first; the code reads the disk file first, *then* the user's key. Under BYO-key, a stale server key silently overrides what the user typed.

**F9 · A client component imports a server module.** [Header.tsx:20](src/components/Header.tsx) — `import { AvailableModelItem } from "@/lib/gemini"` without `import type`, reaching into a module that imports `fs`. Move the type to `types.ts`.

**F10 · O(n²) base64 in the Worker.**

```ts
new Uint8Array(buf).reduce((data, byte) => data + String.fromCharCode(byte), "")  // worker.ts:79
```

Quadratic string building over the whole upload. A 5 MB PDF will exhaust the Worker CPU budget.

**F11 · No upload validation.** No size cap, no MIME allowlist, no page-count limit. Any file of any size is accepted.

**F12 · The model picker is decorative.** `kashif_gemini_model` is written to localStorage ([Header.tsx:126](src/components/Header.tsx)) and never sent on any request. The server always uses `process.env.GEMINI_MODEL`, so a user who picks `gemini-3.7-flash` still gets whatever the server defaults to. This is the client half of F2 and should land with it.

**F13 · `agy` is a code-execution surface.** [antigravity-cli.ts:96](src/lib/antigravity-cli.ts) spawns the CLI with `--dangerously-skip-permissions` and a prompt built from the request body. `spawn` without a shell means no argument injection, but an HTTP request still drives an agent CLI with permissions disabled on the workshop machine. Confirmed decision: compile it out of production entirely.

**F14 · The API is an open proxy.** `Access-Control-Allow-Origin: *` on every route ([worker.ts:15](src/worker.ts)), no rate limit, no timeout on the upstream Gemini call, no `AbortSignal` on any client fetch.

## 2.3 P2 — Correctness and quality

**F15 · XSS in the exported report.** — **FIXED** via [html-escape.ts](src/lib/html-escape.ts): the template now interpolates an `escapeDeep` copy (verified: 0 raw `${report.` references remain), the part SVGs are still generated from the original values, and the download filename is sanitised so model output cannot steer the save dialog. Verified with `<img src=x onerror>` and `</script><script>` payloads — both render inert.

Originally:  `ExportActionBar.handleDownloadHtml` interpolates AI-generated strings straight into an HTML template with no escaping ([ExportActionBar.tsx:110+](src/components/ExportActionBar.tsx)). Model output containing `</script>` or `<img onerror=...>` becomes live script in a file the user forwards to their customer over WhatsApp.

**F16 · The "self-contained" export is not self-contained.** It `<link>`s Google Fonts ([ExportActionBar.tsx:117](src/components/ExportActionBar.tsx)). Opened offline — the actual usage scene — it renders unstyled.

**F17 · `dangerouslySetInnerHTML` without a guard.** [SparePartsSection.tsx:288](src/components/SparePartsSection.tsx) and `:488`. Currently safe (`part-visuals.ts` interpolates nothing), but nothing enforces that. Needs a sanitizer or an explicit invariant plus a lint rule.

**F18 · Fabricated vehicle data.** — **FIXED**. `normalizeDiagnosticReport` no longer invents anything: unknown values are `null` and the UI renders "غير محدد" / "غير مسعّرة". Gone with it: the fabricated OEM number `OEM-GENUINE`, the 50-200 LYD default price, the `["Bosch", "Denso"]` aftermarket list, the invented checklist step, and — most seriously — a `passedSystems` default asserting the ABS and airbags had passed when nothing had said so. A score derived from fault counts is now flagged `isScoreEstimated`.

Originally:  `normalizeDiagnosticReport` fills gaps with `vin: "LIBYA-OBD-SCAN"`, `model: "صالون / جيب"`, `year: "2020"`, `overallHealthScore: 70`. Presenting a guessed year as the vehicle's year violates the product's own "never fake certainty" principle. Missing means missing, rendered as "غير محدد".

**F19 · No validation of AI output.** `safeJsonParseOrRepair` returns `any` and it flows into the report untouched. Roughly 170 lines of hand-rolled defaulting stand in for a schema. Replace with Zod; it deletes most of the `any` and gives an honest parse-failure path for F1.

**F20 · Empty catch blocks.** [page.tsx:66](src/app/page.tsx), `:75`, [gemini.ts:34](src/lib/gemini.ts).

**F21 · Accessibility is effectively absent.** Across 11 components there are **3 total** `aria-*` / `role` / `alt` attributes. Four modals have no `role="dialog"`, no `aria-modal`, no focus trap, no focus restore; only one handles Escape. Every icon-only button is unlabelled. This directly contradicts the workshop-legibility requirement in PRODUCT.md. *(The redesign removes three of the four modals, which fixes much of this structurally.)*

**F22 · 55 ESLint errors, 26 warnings.** Mostly `no-explicit-any` at the AI boundary (dissolved by F19) plus dead imports: `Hash` in VehicleHealthCard, `LIBYAN_DICTIONARY` and both `SAMPLE_*` in gemini.ts, `KashifDiagnosticReport` in antigravity-cli.ts, `model` at [sensor-locator.ts:238](src/lib/sensor-locator.ts).

**F23 · No tests at all.** Four ad-hoc scripts (`test_app.py`, `test_upload.py`, `test_api_direct.py`, `test_parts_search.js`), one of them committed.

**F24 · The whole app is one client component.** [page.tsx](src/app/page.tsx) is `"use client"` and holds all state. No SSR, no streaming, no `error.tsx`, no `loading.tsx`, no `not-found.tsx`, no error boundary.

**F25 · Metadata and PWA gaps.** No `metadataBase`, `openGraph`, `twitter`, `manifest`, `themeColor`, or `robots` in [layout.tsx](src/app/layout.tsx); no `sitemap.ts`, no `robots.ts`, no web manifest. For an app used on a phone in a workshop, installability and an offline shell matter.

**F26 · No security headers.** [next.config.ts](next.config.ts) is an empty object. No CSP, HSTS, `X-Content-Type-Options`, or `Referrer-Policy`.

**F27 · Unbounded third-party images.** Three raw `<img>` tags load URLs returned by a live web search — no `next/image`, no dimensions, no CLS protection, no domain allowlist.

**F28 · Live scraping inside the request path.** `parts-search.ts` scrapes DuckDuckGo with a spoofed Chrome UA and a `vqd` token ([parts-search.ts:130-190](src/lib/parts-search.ts)) — brittle, against DDG's terms, 4-8s of latency, and `enrichReportWithOnlinePartImages` runs it for *every* part before the analyze response returns. Move to a lazy per-part `/api/parts-image` call after the report renders, cache in KV, and keep the curated registry plus the SVG vector as the honest default.

**F29 · Chat is heavy.** The entire report JSON is re-serialised and sent on every message, with full history, no streaming, and no cancel.

---

# PART 3 — Making it work on the web

Target stays `kashif.malgaroshy.workers.dev`.

### 3.1 Adopt `@opennextjs/cloudflare`

```bash
npm i -D @opennextjs/cloudflare wrangler
```

- Delete `src/worker.ts` and `scripts/prepare-cloudflare.js`. `src/app/api/*` becomes the single implementation (kills F6).
- `wrangler.jsonc`: `main` points at the adapter's generated worker, `assets.directory` at `.open-next/assets` (kills F4 — no `.next/server`, no `.next/cache`, no 378 MB upload).
- `build` becomes `opennextjs-cloudflare build`; add `deploy` for `opennextjs-cloudflare deploy`.
- Add `open-next.config.ts` and `.dev.vars`; gitignore `.open-next`.
- Rewrite the CI workflow to deploy the Worker named `kashif` (kills F5).

### 3.2 BYO-key handling

The key is the user's, so it must be handled like it:

- Stored **only** in `localStorage`, never in a cookie, never sent to any origin but our own `/api/*` (which forwards to Google and nothing else).
- Never logged. Never echoed in an error message. Never written to KV or a Durable Object.
- The settings panel states plainly, in Arabic, where the key goes and what it is used for, with a one-click "امسح المفتاح".
- Server-side `GEMINI_API_KEY` stays supported for local dev only, and its priority is fixed: **the user's key wins over env** (kills F8).
- A "تحقق من المفتاح" button that does a real cheap round-trip and reports the actual failure — invalid key, quota exceeded, region blocked — instead of silently degrading.
- `Access-Control-Allow-Origin` restricted to the app's own origin (kills the open-proxy half of F14).

### 3.3 Runtime constraints to respect

| Constraint | Action |
|---|---|
| Worker CPU budget | Replace the O(n²) base64 with a chunked encoder (F10). |
| PDF parsing on the edge | `pdf2json` is Node-only. Either keep PDF extraction on a `nodejs_compat` route, or send the PDF to Gemini as `inlineData` and drop `pdf2json` entirely — Gemini reads PDFs natively. **Recommended: drop it**, which also removes the unused `pdf-parse` and `@types/pdf-parse`. |
| Upload size | Hard cap at **8 MB**, MIME allowlist `application/pdf, image/jpeg, image/png, image/webp`, enforced client and server (F11). |
| Request timeout | `AbortSignal.timeout(45_000)` on the Gemini call; `AbortController` on every client fetch (F14). |
| Rate limiting | Cloudflare Rate Limiting rules on `/api/analyze` and `/api/chat`, per-IP. Cheap, and requires no KV. |
| Slow connections | Font budget 90 KB or less, no blocking third-party requests, images lazy and off the critical path, `sample-data.ts` dynamically imported so 504 lines of demo JSON leave the initial bundle. |
| Offline | Service worker caching the app shell, the dictionary, and saved reports. The workshop's connection is unreliable and history is already local-only. |

### 3.4 Headers

CSP with `connect-src 'self' https://generativelanguage.googleapis.com`, `img-src` limited to `'self' data:` plus the part-image domains, HSTS, `X-Content-Type-Options: nosniff`, `Referrer-Policy: strict-origin-when-cross-origin` (F26).

---

# PART 4 — Delete list

### Delete outright

| Item | Reason |
|---|---|
| `src/worker.ts` | Replaced by the adapter (F6). |
| `scripts/prepare-cloudflare.js` | Replaced by the adapter (F4). |
| `public/next.svg`, `vercel.svg`, `file.svg`, `globe.svg`, `window.svg` | Next.js scaffolding, currently published on the live site. |
| `test_app.py` *(tracked)* | Ad-hoc script, superseded by a real test suite. |
| `test_upload.py`, `test_api_direct.py`, `test_parts_search.js`, `scratch_models.json`, `test_downloaded_report.html`, `screenshot_*.png` *(untracked)* | Working-tree litter. |
| `canvas-confetti` + `@types/canvas-confetti` | Wrong register for a fault board; the motion budget is three transitions. |
| `pdf-parse` + `@types/pdf-parse` | Never imported. Dead dependency. |
| `pdf2json` | Removed if Gemini handles PDFs natively (§3.3). |
| `fallbackLocalAnalyzer` as a *silent* path | The function may survive as an explicit "offline demo mode", never as a hidden substitution (F1). |
| Dead imports | `Hash`, `LIBYAN_DICTIONARY`, `SAMPLE_*`, `KashifDiagnosticReport`, `model` (F22). |
| The dark-only assumption | Replaced by a two-theme token system. |

### Move out of the repo — needs your decision

`DOC-20260812-WA0026.pdf` and `DOC-20260821-WA0001.pdf` are **real scanner reports received over WhatsApp**, committed to the repository. They very likely contain a real VIN and possibly owner or plate data. Options: delete them, or move them to a private `fixtures/` path outside version control. Removing them from *history* needs a force-push, which is your call. Flagging it, not doing it.

### Fix, don't delete

- `README.md` — the badge says "Next.js 15.3" (actual: 16.3.2), it describes the deployment as Cloudflare Pages when production is a Worker, and it contains `file:///d:/projects/car%20report/...` absolute local links that are broken for every other reader. The `gemini-3.7-flash` claims are accurate and stay.
- `PRD_KASHIF_AI.md`, `ROADMAP.md` — same deployment correction; the design sections now describe a visual world that has been replaced.
- `.env.example` — drop the retired `gemini-2.0-flash` from the options comment; reframe `GEMINI_API_KEY` as local-dev-only now that the app is bring-your-own-key.
- `AGENTS.md` — keep. It is generated by `next dev` and re-appears if removed.

---

# PART 5 — Execution phases

Each phase ends green: `tsc --noEmit` clean, `eslint` clean, and a working deploy.

### Phase 0 — Safety net *(half a day)*
Vitest + Testing Library + Playwright. Lock behaviour before touching it: schema validation of both sample reports, the analyze route's success and failure paths, the dictionary matcher, PDF/DTC extraction, and the export escaper. **Write the F1 regression test first** — a malformed AI response must produce an error, never a substituted report.

### Phase 1 — Stop the bleeding — **DONE**
F1, F2, F12, F15, F18, plus F10 (the Worker's O(n²) base64, replaced with a chunked encoder while rewriting that handler) and F11 (8 MB cap and a MIME allowlist on both runtimes).

New: [errors.ts](src/lib/errors.ts), [models.ts](src/lib/models.ts), [html-escape.ts](src/lib/html-escape.ts).
Deleted: `fallbackLocalAnalyzer`, `generateLocalMechanicResponse`.

Verified against the running server — 9/9 acceptance checks:

- an invalid key returns an error with a code, not a report, and does not echo the key
- an empty request returns an error, not a report
- an explicit `sampleId` still returns its demo
- `/api/models` reports `gemini-3.7-flash` as default and no longer offers the retired model
- a real analysis (`P0102, P0300` on a 2010 Corolla) returns a real report with a real VIN, real OEM numbers and real prices, and **zero** invented placeholders
- the export template has 0 raw interpolations left, and XSS payloads render inert

ESLint errors went from 55 to 30; the rest are the `no-explicit-any` cluster that F19 dissolves in Phase 3. `tsc --noEmit` clean.

Still open from F3: production has no key and the first-run UI that makes bring-your-own-key usable is Phase 5. The error states it needs now exist.

One thing worth knowing: a real analysis took **41 seconds**. Most of that is F28 — the DuckDuckGo part-image scrape running for every part *inside* the request. Phase 3.

### Phase 2 — Cloudflare migration *(1 day)*
§3.1 and §3.4. Delete `worker.ts` and `prepare-cloudflare.js`, adopt the adapter, restrict assets, fix CI, add headers. Verify the F4 URLs return 404.

### Phase 3 — Backend cleanup *(1-2 days)*
F6-F14, F19, F20, F28, F29. Zod schemas, fixed key priority, `agy` gated to dev, upload caps, chunked base64, timeouts, CORS, part-image search moved off the request path.

### Phase 4 — Design system — **DONE**
Tokens (§1.3), the two fonts (§1.4), light and dark, the print stylesheet as a first-class output, the severity notation, the base primitives, and the direction contract committed as the HTML comment in the root layout. Verified per §1.6. `/design` renders the living spec.

### Phase 5 — Rebuild the surface *(3-4 days)*
Screens in §1.7, on the primitives in §1.5, mobile and desktop together. Delete the compatibility bridge in `globals.css` when the last incumbent component is gone. `page.tsx` splits into a server shell with client islands. First run, ingestion, analysing, report, empty and error states. Modals become in-place sections and sheets.

### Phase 6 — Accessibility, performance, PWA *(1 day)*
F21, F24-F27. Then one batched verification round: desktop and mobile screenshots together, the mechanical detector over the changed files, fix everything found in one pass, confirm once, stop.

### Phase 7 — Docs *(half a day)*
`DESIGN.md` written from the built world. README, PRD, and ROADMAP corrected against reality.

**Estimate: 7-10 working days remaining** (Phases 1 and 4 are done). Phase 2 is the next independently shippable block; Phase 5 is the largest.

---

## Acceptance criteria

- [x] A malformed or failed AI response produces a visible error. No report is ever substituted for another. *(F1)*
- [x] One shared model list, seeded from the live models endpoint; `gemini-2.0-flash` gone; the Worker's default matches the app's advertised default. *(F2)*
- [ ] `/server/app/index.html`, `/BUILD_ID`, and `/required-server-files.json` return 404 in production. *(F4)*
- [ ] A push to `main` deploys the live Worker, and `/api/analyze` works on the deployed URL. *(F5)*
- [ ] One implementation of each API route exists in the repo. *(F6)*
- [ ] A user with no key sees a clear, explained key step and two working sample reports.
- [ ] A user's key is accepted, validated with real feedback, and produces a real analysis.
- [x] An exported report containing `<script>alert(1)</script>` in a fault description opens inert. *(F15)* — the offline-fonts half (F16) is still open.
- [ ] `eslint` reports zero errors. `tsc --noEmit` is clean.
- [ ] Every interactive element is keyboard-reachable and labelled; every dialog traps and restores focus. *(F21)*
- [ ] The report is fully legible printed in black and white — severity readable from shape alone.
- [ ] Lighthouse on a throttled 3G phone profile: LCP under 2.5s, CLS under 0.1, a11y 95 or above.
- [ ] Light and dark both ship, and neither is a filter over the other.

---

## Open questions

1. **The two WhatsApp PDFs** — delete, or move to private fixtures? Does history need rewriting?
2. **Report sharing** — sharing today means a downloaded HTML file or a WhatsApp text. A short-lived shareable link (Workers KV, expiring) would fit how these reports actually travel, but it means storing customer vehicle data server-side. Out of scope unless you want it.
3. **Part-image search** — keep scraping DuckDuckGo, or drop to the curated registry plus SVG vectors only? The vectors are honest, instant, offline, and never wrong; the scraped photos are prettier and sometimes show a different part than the one specified.
4. **Mark** — no logo asset exists. The fuse-box world suggests a moulded or silkscreened mark rather than a drawn logo — a stencilled كاشف on the board, or a blank fuse seat as the icon. Do you want one designed, or is the wordmark set in Readex Pro enough?
5. **The health score** — `--t-score` is the only large type in the system and nothing uses it yet. On a fuse-box board the natural home is a seat-shaped block at the masthead rather than a gauge. Confirm at Phase 5, or tell me now if you want the score presented differently.
