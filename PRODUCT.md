# Product

<!-- impeccable:product-schema 1 -->

## Platform

web

## Users

1. **Workshop technician / الأسطى** — reads a scanner report at the bay, needs the affected systems, a sequential electrical/mechanical check order before pulling parts, OEM numbers, and fuse/wire verification (بيانتو / خيوط / فيوزات).
2. **Car owner / pre-purchase buyer** — wants to know what the check-engine or ABS light actually means, how dangerous it is to keep driving, and a Libyan-dinar cost estimate, without being exploited.
3. **DIY enthusiast** — wants the part's location, diagram, and how to test or replace it.

Confirmed: no single primary. Phone-in-the-workshop and desktop-at-the-service-desk are equally weighted; full responsive parity is required.

## Product Purpose

Turn an OBD-II scanner report (Launch X431, Autel, Ediag, ThinkDiag, Topdon, Bosch KTS) — delivered as PDF, phone photo of the scanner screen, or hand-typed codes — into an interactive diagnostic report written in the working vocabulary of Libyan repair shops. Success is a technician acting on the report instead of swapping parts at random, and an owner understanding severity and cost before paying.

## Positioning

Three-layer translation no generic DTC lookup can copy: **Libyan shop term ⇄ plain Arabic ⇄ standard English code**, bound to a curated 200+ term dictionary across 12 categories (بوبينات، مزاطوري، شمعات، بيانتو، براتشو، كونفيرتا، قرسيوني كوبيركو، ستاقوبا، باطنيات، امبروكم). Paired with a sensor/fuse/multimeter locator that names the fuse box, fuse number, amp rating and colour, the sensor's position in the engine bay, and the expected pin voltages — the specific thing that stops a good part from being replaced.

## Operating Context

- Input arrives as a WhatsApp'd PDF, a photo of a scanner screen under bad shop lighting, or codes read aloud and typed by hand.
- Output leaves the app as a printed A4 sheet, a standalone HTML file, or a WhatsApp message to the customer — often on a connection that is slow or intermittent.
- Reports are consulted mid-job on a phone that may be held one-handed, and reviewed at a desk.
- Report history is local to the browser (localStorage); there are no accounts.

## Capabilities and Constraints

- **Interface language is Arabic, RTL, throughout.** English appears only as codes, OEM part numbers, module names, and scanner tool names.
- Confirmed AI access model: **bring-your-own key**. Each user pastes their own Google AI Studio Gemini key in Settings; the product ships no shared key. Two built-in sample reports (BMW 528i E39, Toyota Corolla) must stay fully functional with no key, since they are the entire first-run experience.
- Deployment target is Cloudflare (currently `kashif.malgaroshy.workers.dev`). Confirmed direction: migrate to the official `@opennextjs/cloudflare` adapter and retire the hand-written `src/worker.ts` router.
- The Antigravity CLI (`agy`) local engine is confirmed **development-only**; it must not be reachable or visible in production.
- Report data structure (`KashifDiagnosticReport`) is established product truth: vehicle profile, health score 0–100, three fault severity tiers, passed systems, spare parts with OEM + aftermarket + LYD price range, and a sequential workshop checklist.
- Part photos are best-effort from a live multi-tier search; a curated SVG vector of the part is the guaranteed offline fallback. Neither may be presented as a verified match for the specific vehicle.
- Undecided: whether Bluetooth OBD-II (ELM327 / OBDLink) direct connection is ever built. The PRD lists it as a future interface only.

## Brand Commitments

- Name: **كاشف AI / Kashif AI**. Voice: Libyan technical shop Arabic — direct, respectful, never patronising, never Modern Standard Arabic where a shop term exists.
- The dictionary has binding term rules: **شمعات** (never بواجي), **علبة الفيوزات** (never سكاتلة). Source of truth: `قاموس_مصطلحات_صيانة_السيارات_الليبية.md`.
- The in-report assistant persona is **"الأسطى كاشف"**.
- No logo asset exists yet.

## Evidence on Hand

- `قاموس_مصطلحات_صيانة_السيارات_الليبية.md` — the 200+ term Libyan dictionary, real and authored.
- `DOC-20260812-WA0026.pdf`, `DOC-20260821-WA0001.pdf` — two real scanner reports received over WhatsApp. Treat as potentially containing a real VIN and owner data.
- `src/lib/sample-data.ts` — two hand-built demo reports derived from real scans.
- `src/lib/sensor-locator.ts` — authored sensor/fuse/pinout data.
- No customers, testimonials, usage numbers, press, pricing, or accuracy benchmarks exist. Future work must not invent any.

## Product Principles

1. **The shop term leads; the code follows.** Every fault is named the way it is named in the bay, with the standard code and English description available beside it, never instead of it.
2. **Test before you replace.** The checklist and the fuse/pinout data are the product's reason to exist; they outrank the parts list in prominence.
3. **Severity is the spine.** Everything sorts by what can strand or endanger the driver, not by module or code order.
4. **Never fake certainty.** AI-derived part numbers, prices, and photos are labelled as estimates; nothing is dressed up as a verified OEM match.
5. **Readable in the worst conditions.** Sunlight, a cracked phone screen, greasy hands, a slow connection, and a black-and-white office printer are all normal.

## Accessibility & Inclusion

- Arabic RTL is the base direction, not a mirrored afterthought.
- The workshop scene sets the floor: high contrast, large touch targets, and legibility at arm's length on a phone in daylight.
- Colour alone may never carry severity — every tier needs a label and a shape too.
- The printed / exported report must stay fully legible in monochrome.
