# Kashif AI — Rebuild Plan

**Status:** all phases done and verified. Not deployed — that needs your Cloudflare credentials.
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

**F4 · The entire build output was published publicly.** — **FIXED**

`prepare-cloudflare.js` copied everything into `.next` and `wrangler.jsonc` pointed `assets.directory` at that whole directory. All of these returned HTTP 200 on the live site:

```
/server/app/index.html   /BUILD_ID   /build-manifest.json
/required-server-files.json   /app-path-routes-manifest.json   /cache/.rscinfo
```

`.next/server/**` was 15 MB of server bundles carrying the full system prompt and every lib. The upload was **378 MB** locally (`cache` 168 MB, `dev` 191 MB), far past Workers' asset limits. *(Checked: no API key was inlined in any build artifact.)*

The adapter now publishes `.open-next/assets`, which contains exactly four entries — `_next`, `parts`, `favicon.ico`, `BUILD_ID` — **31 files, 27 MB total**. Every path above returns 404, verified against the real Worker runtime, and CI re-asserts it after each deploy. `BUILD_ID` is deliberately still served: the adapter emits it by design and it carries nothing sensitive.

**F5 · CI deployed to the wrong product and had never deployed the live site.** — **FIXED**. The workflow ran `wrangler pages deploy .next` — Cloudflare **Pages** — while production is a **Worker** named `kashif`. Even on success it would have served static assets with no `worker.ts`, so all four API routes would have 404'd.

Rewritten: typecheck → lint → `cf:build` as a verify job, then `cf:deploy` gated on credentials being present (a fork still gets verified rather than failing), then the F4 leak assertion against the deployed URL. Lint is `continue-on-error` until F19 removes the remaining `no-explicit-any` errors, and becomes a hard gate in that same change.

## 2.2 P1 — Architecture

**F6 · Two copies of the API, already drifted.** — **FIXED**. `src/worker.ts` is deleted; `src/app/api/*` is the only implementation and now actually runs in production. Originally:  `src/worker.ts` (241 lines) reimplements all four routes from `src/app/api/*`. In production the Next routes are dead code. The worker's copy is already missing PDF text extraction, part-image enrichment, and chat history, and it carries a different model list. Every future fix has to be written twice or silently isn't.

**F7 · `gemini.ts` read `.env.local` off disk on every key resolution.** — **FIXED**. `fs` and `path` are gone from the module; `.env.local` still works in development because Next loads it into `process.env` at startup, which is the supported route. Originally: `fs.readFileSync(process.cwd() + "/.env.local")` per call, a filesystem read per request in a bundle that has no filesystem.

**F8 · Key priority was documented backwards.** — **FIXED**. The order is now the caller's key first, then `GEMINI_API_KEY` from the environment, and the JSDoc says so. `NEXT_PUBLIC_GEMINI_API_KEY` was removed as a source entirely: anything with that prefix is inlined into the client bundle, so honouring it would have meant publishing a key to every visitor. Nothing else in the repo referenced it.

**F9 · A client component imported a server module.** — **FIXED in Phase 1**, when the model catalogue moved to `lib/models.ts`. [Header.tsx](src/components/Header.tsx) imports the type from there now, so the Gemini SDK and the system prompt no longer reach the client bundle.

**F10 · O(n²) base64 in the Worker.**

```ts
new Uint8Array(buf).reduce((data, byte) => data + String.fromCharCode(byte), "")  // worker.ts:79
```

Quadratic string building over the whole upload. A 5 MB PDF will exhaust the Worker CPU budget.

**F11 · No upload validation.** No size cap, no MIME allowlist, no page-count limit. Any file of any size is accepted.

**F12 · The model picker is decorative.** `kashif_gemini_model` is written to localStorage ([Header.tsx:126](src/components/Header.tsx)) and never sent on any request. The server always uses `process.env.GEMINI_MODEL`, so a user who picks `gemini-3.7-flash` still gets whatever the server defaults to. This is the client half of F2 and should land with it.

**F13 · `agy` is a code-execution surface.** — **FIXED** (brought forward from Phase 3, because it broke the deploy). Originally:  [antigravity-cli.ts:96](src/lib/antigravity-cli.ts) spawns the CLI with `--dangerously-skip-permissions` and a prompt built from the request body. `spawn` without a shell means no argument injection, but an HTTP request still drives an agent CLI with permissions disabled on the workshop machine. Confirmed decision: compile it out of production entirely.

**F14 · The API was an open proxy.** — **MOSTLY FIXED**. `Access-Control-Allow-Origin: *` went with `worker.ts` in Phase 2, and the upstream call got a 45s cap per model attempt in Phase 1. Phase 3 adds the client half: [api-client.ts](src/lib/api-client.ts) puts every request under an `AbortSignal.timeout` (120s for an analysis, 60s for a chat turn, 15s for a part photo), so a request that never comes back stops the spinner instead of hanging the page forever. The chat panel also cancels its own in-flight question when a new one is sent or the panel closes.

**Still open:** no rate limit. Under bring-your-own-key each caller spends their own quota, which removes the usual reason for one, but nothing stops a stranger from using the deployment as a free PDF-to-Gemini pipe with a stolen key. Cloudflare's rate-limiting rules are the cheap answer and belong with the deploy, not the code.

## 2.3 P2 — Correctness and quality

**F15 · XSS in the exported report.** — **FIXED** via [html-escape.ts](src/lib/html-escape.ts): the template now interpolates an `escapeDeep` copy (verified: 0 raw `${report.` references remain), the part SVGs are still generated from the original values, and the download filename is sanitised so model output cannot steer the save dialog. Verified with `<img src=x onerror>` and `</script><script>` payloads — both render inert.

Originally:  `ExportActionBar.handleDownloadHtml` interpolates AI-generated strings straight into an HTML template with no escaping ([ExportActionBar.tsx:110+](src/components/ExportActionBar.tsx)). Model output containing `</script>` or `<img onerror=...>` becomes live script in a file the user forwards to their customer over WhatsApp.

**F16 · The "self-contained" export is not self-contained.** It `<link>`s Google Fonts ([ExportActionBar.tsx:117](src/components/ExportActionBar.tsx)). Opened offline — the actual usage scene — it renders unstyled.

**F17 · `dangerouslySetInnerHTML` without a guard.** [SparePartsSection.tsx:288](src/components/SparePartsSection.tsx) and `:488`. Currently safe (`part-visuals.ts` interpolates nothing), but nothing enforces that. Needs a sanitizer or an explicit invariant plus a lint rule.

**F18 · Fabricated vehicle data.** — **FIXED**. `normalizeDiagnosticReport` no longer invents anything: unknown values are `null` and the UI renders "غير محدد" / "غير مسعّرة". Gone with it: the fabricated OEM number `OEM-GENUINE`, the 50-200 LYD default price, the `["Bosch", "Denso"]` aftermarket list, the invented checklist step, and — most seriously — a `passedSystems` default asserting the ABS and airbags had passed when nothing had said so. A score derived from fault counts is now flagged `isScoreEstimated`.

Originally:  `normalizeDiagnosticReport` fills gaps with `vin: "LIBYA-OBD-SCAN"`, `model: "صالون / جيب"`, `year: "2020"`, `overallHealthScore: 70`. Presenting a guessed year as the vehicle's year violates the product's own "never fake certainty" principle. Missing means missing, rendered as "غير محدد".

**F19 · No validation of AI output.** — **FIXED**. [report-schema.ts](src/lib/report-schema.ts) is a Zod schema for what the model sends back, applied before `normalizeDiagnosticReport` sees it. The two jobs that were tangled together are now separate: the schema decides whether a value is the right *kind* of thing, and normalization decides what a missing value means.

It is deliberately lenient about presence and strict about values. An omitted mileage is a fact about the scan we do not have, and the report already says so — rejecting an analysis over it would be worse than useless. A *wrong* value is different: `urgencyLevel: "very urgent"` used to flow straight through `f.urgencyLevel || defaultUrgency` into the UI, where the severity lookup missed and the fault rendered with no priority at all. Those fields use `.catch()`, so an unrecognised value falls to the documented default. The `electricalDiagnostics` block is dropped whole unless every field parses — a malformed one is worse than an absent one, because it puts a marker on the wrong part of the engine bay and prints a pinout for a different circuit.

Every field is `.nullish()` rather than `.optional()`, because a normalized report writes `null` for "the scan did not say" and gets re-normalized on the agy path; treating those nulls as parse failures would have blanked a VIN that was read correctly the first time.

**F20 · Empty catch blocks.** — **FIXED**. All three now log with enough context to be found. Two of them were hiding a failed history write, which is why a report could silently vanish from the list.

The same pass found a worse one next door in [page.tsx](src/app/page.tsx): the history loader did not drop a malformed stored report, it *patched* it — a record with no summary was rendered with a health score of 70 and a status of "متوسط / انتبه". That is the F18 fabrication class, in the one place nobody was looking. A stored report is now validated and dropped if it no longer parses.

[ExportActionBar.tsx](src/components/ExportActionBar.tsx) had two more of the same:
- the WhatsApp share text fell back to `70% / متوسط / انتبه / تم فحص التقرير بنجاح` — a grade, a severity and a verdict, none of them from this car. It says `غير محدد` now.
- `scoreNote` was computed and never printed, so the exported certificate — the copy that gets forwarded and printed — showed a derived score with no indication it was derived. The gauge is labelled `الجاهزية (تقديري)` when the score came from arithmetic rather than the scan.

**F21 · Accessibility is effectively absent.** Across 11 components there are **3 total** `aria-*` / `role` / `alt` attributes. Four modals have no `role="dialog"`, no `aria-modal`, no focus trap, no focus restore; only one handles Escape. Every icon-only button is unlabelled. This directly contradicts the workshop-legibility requirement in PRODUCT.md. *(The redesign removes three of the four modals, which fixes much of this structurally.)*

**F22 · 55 ESLint errors, 26 warnings.** Mostly `no-explicit-any` at the AI boundary (dissolved by F19) plus dead imports: `Hash` in VehicleHealthCard, `LIBYAN_DICTIONARY` and both `SAMPLE_*` in gemini.ts, `KashifDiagnosticReport` in antigravity-cli.ts, `model` at [sensor-locator.ts:238](src/lib/sensor-locator.ts).

**F23 · No tests at all.** Four ad-hoc scripts (`test_app.py`, `test_upload.py`, `test_api_direct.py`, `test_parts_search.js`), one of them committed.

**F24 · The whole app is one client component.** [page.tsx](src/app/page.tsx) is `"use client"` and holds all state. No SSR, no streaming, no `error.tsx`, no `loading.tsx`, no `not-found.tsx`, no error boundary.

**F25 · Metadata and PWA gaps.** No `metadataBase`, `openGraph`, `twitter`, `manifest`, `themeColor`, or `robots` in [layout.tsx](src/app/layout.tsx); no `sitemap.ts`, no `robots.ts`, no web manifest. For an app used on a phone in a workshop, installability and an offline shell matter.

**F26 · No security headers.** — **FIXED** in [next.config.ts](next.config.ts): CSP, HSTS, `nosniff`, `X-Frame-Options`, `Referrer-Policy`, `Permissions-Policy`, and `no-store` on `/api/*` so a pasted key never lands in a cache. The load-bearing line is `connect-src 'self' https://generativelanguage.googleapis.com` — injected script cannot post a user's key anywhere else. Two knowingly loose directives: `script-src` still allows `'unsafe-inline'` (tightening it to a nonce needs middleware), and `img-src` allows `https:` because part photos come from an unknown host until F28 moves that search behind our own endpoint. Originally:  [next.config.ts](next.config.ts) is an empty object. No CSP, HSTS, `X-Content-Type-Options`, or `Referrer-Policy`.

**F27 · Unbounded third-party images.** Three raw `<img>` tags load URLs returned by a live web search — no `next/image`, no dimensions, no CLS protection, no domain allowlist.

**F28 · Live scraping inside the request path.** — **FIXED**, and this was the single biggest thing standing between the app and being usable.

The DuckDuckGo tier is deleted, not moved: it scraped an internal `i.js` endpoint with a spoofed Chrome user agent and a lifted `vqd` token, which is against their terms, broke whenever the token format moved, cost 4-8s per part, and returned images from arbitrary hosts — which is the only reason `img-src` had to allow every https origin. What remains is Wikimedia Commons (a public API, hotlinking permitted) and the curated registry.

`enrichReportWithOnlinePartImages` is gone from all three branches of `/api/analyze`. The client already had the lazy per-part `/api/parts-image` call — the server-side enrichment was pure duplicated latency, filling `partImageUrl` in so the client would skip work it was perfectly capable of doing after the report had rendered. Cards now paint immediately with their vector schematic and a photo swaps in if one turns up.

`/api/parts-image` is the one route carved out of the blanket `no-store` on `/api/*`: it carries no key and no vehicle data worth protecting, and the answer is the same for everyone, so it is `public, max-age=86400`.

**KV is not used.** The plan called for it, but the in-process cache plus a day of browser caching covers the same ground, and adding a namespace to a Worker that otherwise needs no storage is a binding to provision and pay for with nothing to show. Worth revisiting only if the Commons round trip shows up in real numbers.

**F30 · `sensor-locator.ts` invented electrical data for codes it did not know.** — **FIXED**.

When a fault code was not in its table, [sensor-locator.ts](src/lib/sensor-locator.ts) derived a fuse box, a fuse number, an amperage, a relay name, a position on the engine diagram and a full multimeter pinout from the code's first three characters — `F03 / 15A`, `15A (أزرق)`, `coordinatePct: { x: 50, y: 50 }`, `5.0V مرجعي ثابت`. Even an exact table hit was topped up with those generics for any missing sub-block. This is the same class as F1 and F18 and the sharpest instance of it: the reader acts on these physically — they pull that fuse, and they put a probe where the marker is.

Following it into the UI turned up worse. The old `SensorFuseLocatorModal` (deleted in Phase 5, now [WiringSheet.tsx](src/components/report/WiringSheet.tsx)) rendered a **"FUSE BOX SCHEMATIC MATRIX"**: a hardcoded sixteen-fuse grid — `F01 (10A)` through `F16 (7.5A)` — with the "matching" cell pulsing amber and labelled `المستهدف ⭐`. No car has that layout except by coincidence. It is deleted.

Three sources now, and the modal always says which one it is showing:

| | means | carries |
|---|---|---|
| `scan` | read off this car's scan by the analysis | everything the model gave |
| `reference` | exact code match in our table | real data, with a note that numbering varies by model year |
| `general` | inferred from the code family only | no fuse number, no amperage, no relay, no diagram position, no pin number |

What is left in the `general` branches is the part that was always true — which end of the engine bay a sensor family lives in, and how to check a supply and a ground. That is workshop practice, and it is labelled as such in an amber banner: *"الرمز مش موجود في المرجع عندنا … رقم الفيوز الصحيح مطبوع على غطاء علبة الفيوزات في سيارتك."* The engine diagram draws no marker without a coordinate, and says so under the drawing.

The exported certificate carries the same disclosure, because that is the copy that leaves the workshop and gets acted on.

**F29 · Chat is heavy.** — **MOSTLY FIXED**. The panel sends `chatContextOf(report)` — the vehicle, the headline summary, the critical and moderate fault codes, and the part names, which is exactly what the prompt quotes. Everything else stayed in the browser: the checklist, every fault's symptoms and root causes, and the whole electrical diagnostics block with its pin voltages and diagram coordinates. Measured on a four-fault report, that is **1.6 KB instead of 9.9 KB, 84% smaller**, on a connection that in Libya is usually a phone's. History is trimmed to the last six turns server-side, and the message objects are stripped to `{sender, text}` — the ids and display timestamps were being uploaded every turn and mean nothing to the model.

**Still open:** no streaming. A reply arrives all at once after ~20s, which is the remaining thing that makes the assistant feel slow. That is a change to the route's response shape and the panel's rendering, and belongs with Phase 5.

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
| ~~`src/worker.ts`~~ | **Deleted.** Replaced by the adapter (F6). |
| ~~`scripts/prepare-cloudflare.js`~~ | **Deleted.** Replaced by the adapter (F4). |
| ~~`public/*.svg`~~ | **Deleted.** Next.js scaffolding that was being published on the live site. |
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

- ~~`README.md`~~ — **DONE.** Version badge corrected, the deployment section rewritten for the adapter, the local `file:///d:/...` links removed, and the dual-engine claim replaced with bring-your-own-key plus a dev-only `agy`.
- `PRD_KASHIF_AI.md`, `ROADMAP.md` — same deployment correction; the design sections now describe a visual world that has been replaced.
- `.env.example` — drop the retired `gemini-2.0-flash` from the options comment; reframe `GEMINI_API_KEY` as local-dev-only now that the app is bring-your-own-key.
- `AGENTS.md` — keep. It is generated by `next dev` and re-appears if removed.

---

# PART 5 — Execution phases

Each phase ends green: `tsc --noEmit` clean, `eslint` clean, and a working deploy.

### Phase 0 — Safety net — **DONE** (out of order: after the fixes, not before)

Vitest, **35 tests in 3 files**, wired into `npm test` and into CI ahead of the build.

The plan called for writing these first, to lock behaviour before touching it. That is not what happened — the dangerous bugs were fixed first, and until now every one of those fixes was guaranteed only by verification scripts living in a scratch directory. This commit is what makes them durable.

Every case is something a real version of this product once did:

| file | guards |
|---|---|
| `no-invention.test.ts` | a failed parse throws instead of returning a report; an unreported VIN, make, model and year stay `null`; no system is claimed as passing; OEM numbers and prices stay `null`; a half-quoted price is dropped whole; a derived score is flagged `isScoreEstimated` |
| `wiring-provenance.test.ts` | an unknown code yields no fuse number, no amperage, no relay and no diagram coordinate; the seven specific invented strings (`F03 / 15A`, `F10 / ECU-15A`, `5.0V مرجعي ثابت`, …) appear for no code; the honest general guidance survives |
| `boundaries.test.ts` | the schema drops an out-of-range enum and an off-canvas diagram coordinate but accepts nulls; the export escaper neutralises a `<script>` in a fault description; part photos resolve only to allowlisted origins; the model ladder always has a real model behind an unknown id; the chat context leaves symptoms, causes, coordinates and the checklist in the browser |

Two of the first drafts failed, and **both were the test being wrong, not the product**: `safeFilenamePart` turns spaces into underscores, which is correct for a filename; and `resolveModelId` deliberately passes an unknown-but-plausible `gemini-*` id through rather than rewriting it, because the live catalogue moves faster than the file and the fallback ladder is what makes that safe. Both are now asserted as the contract they actually are.

**Not done:** Playwright. The browser-level behaviour verified by hand this round — contrast in both themes, 375px overflow, focus trap and restore, the provenance banner — is exactly what an end-to-end suite should hold, and it is the obvious next piece of test work.

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

### Phase 2 — Cloudflare migration — **DONE**
F4, F5, F6, F26, plus F13 pulled forward.

`@opennextjs/cloudflare` 1.20.2 replaces the hand-written runtime. Deleted: `src/worker.ts` (241 lines), `scripts/prepare-cloudflare.js`, and the five unused Next.js scaffolding SVGs that were being served publicly. Added: `open-next.config.ts`, `.dev.vars.example`, `cf:build` / `cf:preview` / `cf:deploy` scripts.

**F13 had to come forward.** `/api/models` returned **HTTP 500** on the Worker: the route called `getAgyCliStatus()`, which pulls `child_process` into the edge runtime. [agy.ts](src/lib/agy.ts) now gates the whole engine behind `NODE_ENV !== "production"` with a dynamic import, so the module is never loaded in a production bundle — which also removes the code-execution surface rather than merely leaving it unused.

Verified against the real Worker runtime via `cf:preview` — 22/22:

- all six leaked paths return 404, and the two scaffolding SVGs are gone
- `/`, `/design`, and `/parts/*` all serve
- `/api/models` returns 200 with `gemini-3.7-flash`; `/api/analyze` serves the demo and still refuses an empty request
- all seven security headers present and correct
- **a real analysis ran end-to-end on the Worker in 9.6s** — a genuine VIN, no invented placeholders

Asset payload: **378 MB → 27 MB**, 31 published files.

Not done here: an actual deploy. That needs your Cloudflare credentials and is yours to run — `npm run cf:deploy`, or push the branch once `CLOUDFLARE_API_TOKEN` and `CLOUDFLARE_ACCOUNT_ID` are set as GitHub secrets.

### Phase 3 — Backend cleanup — **DONE**
F7, F8, F9, F14, F19, F20, F28, F29.

**The headline is F28.** An analysis no longer waits on an image search for every part before it returns, and the DuckDuckGo scrape is deleted rather than relocated.

New modules: [report-schema.ts](src/lib/report-schema.ts) (Zod, F19), [api-client.ts](src/lib/api-client.ts) (the browser's side of the API, with timeouts), [local-store.ts](src/lib/local-store.ts), [part-image-hosts.ts](src/lib/part-image-hosts.ts).

Two things came out of this that were not on the list:

- **`localStorage` was read by effect in three places.** Render empty, then `useEffect` -> `setState` with what was in storage. Besides the wasted render pass, nothing propagated: saving a new API key in Settings did not tell the upload panel, and saving a report did not tell the history list — each held a copy taken at mount. [local-store.ts](src/lib/local-store.ts) moves all of it to `useSyncExternalStore`, with cached snapshots so identity stays stable. Saving a model without pasting a key also used to discard the model choice; it does not now.

- **Three more fabrications**, all described under F20 above: the history loader inventing a 70% score for a broken record, the WhatsApp share text doing the same, and the exported certificate not disclosing a derived score.

**Lint is a hard gate in CI as of this change.** Errors went 27 -> 0. The two remaining warnings are `no-img-element` on the part thumbnails, which is a `next/image` decision for Phase 5. `.open-next` and `.wrangler` are excluded from linting — without that, `npx eslint .` walks the Cloudflare bundle and reports about 35,000 problems in code we did not write.

Verified against the real Worker via `cf:preview` — **27/27**, plus a live analysis: **HTTP 200 in 22.6s**, a genuine VIN, no invented placeholders, every urgency and category value in range, zero parts arriving with a server-fetched photo.

### Phase 4 — Design system — **DONE**
Tokens (§1.3), the two fonts (§1.4), light and dark, the print stylesheet as a first-class output, the severity notation, the base primitives, and the direction contract committed as the HTML comment in the root layout. Verified per §1.6. `/design` renders the living spec.

### Phase 5 — Rebuild the surface — **DONE**

**Every incumbent component is gone and the `globals.css` bridge is deleted.** `src/components/` now holds only `report/` and `ui/`.

Deleted: `Header`, `UploadDropzone`, `VehicleHealthCard`, `FaultPriorityMatrix`, `SparePartsSection`, `DiagnosticChecklist`, `ExportActionBar`, `InspectionHistory`, `FaultCodeCard`, `SensorFuseLocatorModal`, `MechanicChatAssistant` — eleven files. In their place, twelve on the fuse-box primitives: `Masthead`, `Intake`, `VehiclePlate`, `FaultBoard`, `FaultCell`, `Checklist`, `PartsBank`, `ReportActions`, `HistoryBank`, `SettingsPanel`, `DictionaryPanel`, `WiringSheet`, `AssistantPanel`, plus `ui/Sheet`.

The 650-line standalone-HTML builder moved out of the deleted button bar into [export-report.ts](src/lib/export-report.ts) — it produces a file that opens on a workshop laptop with no internet and had already been through the escaping and no-invented-values passes, so it was the part worth keeping.

**Two decisions that changed the shape of the screen, not just its colours:**

- **The assistant is a section, not a floating drawer.** It sat in a bubble over the bottom-left corner, which covered the spare-parts list — the thing people are asking about. It is now the last section of the document, in reading order: you read what is wrong, then you ask the follow-up.
- **Modals became sheets, and reading detail stopped being a modal at all.** A fault's symptoms and causes disclose in place on the cell, because a mechanic holding a phone under a bonnet should not have to manage a stack of overlays to compare two faults. Only settings, the dictionary and the wiring reference — reference material, not steps — arrive over the board.

**Two real bugs the rebuild exposed:**

- **`text-[var(--cell)]` was being silently deleted.** `Button`'s primary variant set its text colour that way, and callers passed `className="text-[var(--t-plate)]"` for size. tailwind-merge cannot tell an arbitrary custom property is a size rather than a colour, so it treated them as the same utility and the later one won — the primary button lost its colour (measured **1.68:1** against its own background) *and* never got the smaller size either. Every arbitrary `text-` value in the codebase is now typed: `text-(color:--cell)`, `text-(length:--t-plate)`. 13 size and 71 colour classes.
- **Every field label was read out twice.** `VehiclePlate` and `PartsBank` wrapped a `Field` in a `<dd>` and put a second, `sr-only` `<dt>` above it, so a screen reader said *"رقم الهيكل، رقم الهيكل، JTDBR42E309SAMPLE"*. `Field` gained a `pair` prop that renders the real `<dt>`/`<dd>`.

`ui/Sheet` carries the modal behaviour once, because there is one correct version of it and the incumbent modals had none: they closed on Escape and nothing else. Focus fell through to the page behind, Tab cycled the whole document, and closing left focus on `<body>`.

Verified against the real Worker:

- **contrast: 0 failures in both themes**, 148 text nodes measured against their real computed backgrounds
- **mobile 375px: 0px horizontal overflow**, nothing outside the viewport; the four sub-44px controls are checkbox inputs inside 342x143 labels
- the wiring sheet reports `reference` for P0102 with real data, and `general` for B2321 with `غير محدد` where the invented `F10 / ECU-15A` used to be
- Escape closes a sheet, focus returns to the exact button that opened it, body scroll is restored
- `no-print` on the export bar and the assistant; 27 drawn severity marks survive black and white

Not done here: `page.tsx` is still one client component rather than a server shell with client islands. It reads `localStorage` for history during render, which is a client concern all the way down — splitting it would mean moving history into a child, and the win is a few KB. Left for Phase 6 with the rest of the performance work.

### Phase 6 — Accessibility, offline export, PWA — **DONE**
F16, F17, F21, F24, F25, F27.

**F16 — the "self-contained" export was not.** It linked two Google Fonts families, so the one scene it exists for — a workshop laptop with no internet — rendered it in whatever the browser fell back to. It was also still the dark dashboard: a certificate that printed white-on-dark, with a print override that could not reach the inline `color: #fff` written into the markup, so several findings printed white on white.

Rewritten light-first on the ISO fuse palette with system font stacks only. Measured on a real export: **0 external requests, 0 contrast failures across 123 text nodes**. `break-inside: avoid` keeps a fault whole across a page break.

Two more inventions surfaced while restyling it, both now gone:
- the generic part schematic had **"GENUINE OEM", "OEM SPEC" and "AUTO COMPONENT"** drawn into it — certification claims on a drawing that is identical for every part we have no illustration for
- the gauge label was computed and never printed, so an estimated score appeared on the certificate as measured

**F17 — `dangerouslySetInnerHTML` had no guard.** The invariant that made it safe (the schematics are literals interpolating nothing) was true only by inspection. `getPartSvg` now returns a branded `SafeSvg` that cannot be constructed outside the module and refuses any string carrying a script tag, an inline handler or a `javascript:` URL. Tests drive a hostile part name and OEM number through every visual type.

**F21 — accessibility.** The sheets landed in Phase 5. This round swept the rendered report: no unlabelled control, no image without `alt`, no heading level skipped, `lang`/`dir` correct, part schematics hidden from assistive tech through their container. A skip link, and `#main` to land on.

**F24 — no error boundary at all.** A render error blanked the page and took the report the reader had just spent a Gemini call on. `error.tsx`, `not-found.tsx` and `loading.tsx` are the fuse-box board. `error.tsx` deliberately does not print `error.message`: what is being rendered when it throws is a scan of somebody's car.

**F25 — metadata and PWA.** `metadataBase` (without it every `og:image` and canonical resolved against localhost), Open Graph, Twitter, canonical, `robots.ts`, `sitemap.ts`, and a web manifest with `lang`/`dir` set so an installed RTL app does not launch left-to-right. Two drawn icons — a seated 15A blade — one maskable. `formatDetection: { telephone: false }`, because a VIN and an OEM number are both long digit runs that iOS turns into unselectable phone links.

**F27 — unbounded third-party images.** Closed in Phase 3 by the host allowlist and the CSP; the schematic container is now a fixed 104×104 box, so a drawing cannot resize the card as it paints.

### Phase 6b — Playwright — **DONE**
**28 tests, two device profiles** (Desktop Chrome and Pixel 7), driving the **built Worker** rather than `next dev` — every bug this project found at the deployment boundary was invisible in dev. They run on the demo reports, so CI needs no API key.

They hold: the bring-your-own-key line, the legend, the VIN, worst-first ranking, in-place disclosure with no dialog, the wiring sheet degrading to `إرشاد عام` for an unknown code, the focus trap and restore, the skip link, zero console errors, zero failed requests, contrast over every text node, the PWA routes, and the build-internals 404s.

One test failed on the first run and it was **the test, not the product**: the disclosure locator matched on the button's label, which changes to `إخفاء التفاصيل` when it opens, so Playwright silently re-resolved to the next still-collapsed fault. It locates by `aria-controls` now.

### Phase 7 — Docs — **DONE**
[DESIGN.md](DESIGN.md) written from the built system, not the proposal: the ISO fuse code and the two-value colour law, the rib as the entire depth system, the one container, the two type roles, both lids as separate token sets, print as a first-class output, and the rule that outranks the rest — the interface never states a finding about a car it did not read, and what each component renders when it has nothing.

Corrected against reality:
- **README** — the component tree was eleven files out of date and still listed `Header.tsx`, `SparePartsSection.tsx`, `ExportActionBar.tsx` and the rest; the Antigravity badge implied a shipping dual engine.
- **ROADMAP** — claimed `src/worker.ts` and `scripts/prepare-cloudflare.js` as completed features. Both are deleted, and the entries now say why.
- **PRD §7.1** — specified a dark-slate palette with cyan/amber accents and IBM Plex/JetBrains. None of that is what was built. The section now points at DESIGN.md and summarises the fuse code, with a note that the proposal and the build deliberately diverged.

**All seven phases are done.** What remains is not development work:

1. **Deploy.** `npm run cf:deploy`, or set `CLOUDFLARE_API_TOKEN` and `CLOUDFLARE_ACCOUNT_ID` as GitHub secrets and push to `main`.
2. **Decide on the two WhatsApp PDFs** (see Open questions). They are still committed and still contain a real VIN.
3. **Streaming the assistant's reply**, the one remaining latency win — a reply currently arrives all at once after ~20s.

---

## Acceptance criteria

- [x] A malformed or failed AI response produces a visible error. No report is ever substituted for another. *(F1)*
- [x] One shared model list, seeded from the live models endpoint; `gemini-2.0-flash` gone; the Worker's default matches the app's advertised default. *(F2)*
- [x] `/server/app/index.html` and `/required-server-files.json` return 404. *(F4)* — verified locally; re-asserted by CI on every deploy.
- [~] A push to `main` deploys the live Worker. *(F5)* — workflow rewritten and the build verified; awaiting `CLOUDFLARE_API_TOKEN` / `CLOUDFLARE_ACCOUNT_ID`.
- [x] One implementation of each API route exists in the repo. *(F6)*
- [x] A user with no key sees a clear, explained key step and two working sample reports. — the intake screen opens with the bring-your-own-key note and both demos, and the demos need no key.
- [x] A user's key is accepted, validated with real feedback, and produces a real analysis. — verified end to end on the Worker with a live key: a genuine VIN, no invented placeholders, every enum in range.
- [x] An exported report containing `<script>alert(1)</script>` in a fault description opens inert, and opens with no network at all. *(F15, F16)* — 0 external requests, verified on a real export.
- [x] `eslint` reports zero errors. `tsc --noEmit` is clean. *(F19, F20)* — and CI now fails on a lint error rather than warning.
- [x] Every interactive element is keyboard-reachable and labelled; every dialog traps and restores focus. *(F21)* — `ui/Sheet` carries the modal behaviour once; a Playwright test tabs 25 times inside a sheet and asserts focus never leaves it, then that Escape returns focus to the exact opening button. The rendered report has no unlabelled control, no image without alt, and no heading level skipped.
- [x] The report is legible printed in black and white — severity is carried by 27 drawn shapes, the furniture is `no-print`, and `break-inside: avoid` keeps a fault whole across a page break. The exported certificate is light-first and asks the network for nothing. *(F16)*
- [~] Performance. Not measured with Lighthouse. What *is* measured: 0 console errors, 0 failed requests, 0px horizontal overflow and 0 contrast failures at 375px and at desktop, on the built Worker, in CI. The known cost is the model call itself (~20-40s), which Lighthouse would not see.
- [x] Light and dark both ship, and neither is a filter over the other. — separate token sets; 0 contrast failures in each, measured on the built page.

---

## Open questions

1. **The two WhatsApp PDFs** — delete, or move to private fixtures? Does history need rewriting?
2. **Report sharing** — sharing today means a downloaded HTML file or a WhatsApp text. A short-lived shareable link (Workers KV, expiring) would fit how these reports actually travel, but it means storing customer vehicle data server-side. Out of scope unless you want it.
3. **Part-image search** — keep scraping DuckDuckGo, or drop to the curated registry plus SVG vectors only? The vectors are honest, instant, offline, and never wrong; the scraped photos are prettier and sometimes show a different part than the one specified.
4. **Mark** — no logo asset exists. The fuse-box world suggests a moulded or silkscreened mark rather than a drawn logo — a stencilled كاشف on the board, or a blank fuse seat as the icon. Do you want one designed, or is the wordmark set in Readex Pro enough?
5. **The health score** — `--t-score` is the only large type in the system and nothing uses it yet. On a fuse-box board the natural home is a seat-shaped block at the masthead rather than a gauge. Confirm at Phase 5, or tell me now if you want the score presented differently.
