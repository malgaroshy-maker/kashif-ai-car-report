# The Fuse-Box Lid

The design system Kashif is built on, written from the built thing rather than
from the proposal. Everything here is in the code; `/design` renders it live.

---

## The thesis

**Kashif does not draw a dashboard. It prints a fuse-box legend.**

The category's default is a dark screen of floating rounded cards with a
coloured arc gauge — the same arrangement whether it is showing server uptime,
a fitness streak, or a misfire in cylinder one. Kashif refuses it, because the
object it is replacing is not a dashboard. It is the printed legend inside a
fuse box lid: a flat moulded board, silkscreened, read under a bonnet with one
hand, and correct enough to act on.

That analogy is not decoration. It decides the colour system, the depth
system, and what happens when the app does not know something.

---

## 1. Colour is a code, not a palette

Severity uses **ISO/DIN 72581-3** — the blade-fuse colour code printed on every
fuse in every car. The mechanic reading this report already decodes it without
being taught.

| tier | fuse | `--tab` (light) | `--ink` (light) | shape | Arabic |
|---|---|---|---|---|---|
| critical | 10A | `#de3b2f` | `#a81f15` | triangle | حرج |
| moderate | 20A | `#f2c200` | `#7a5500` | half bar | متوسط |
| passed | 30A | `#2e9e5b` | `#125b2f` | tick | سليم |
| history | 25A | `#c8cbc5` | `#565c59` | ring | ذاكرة |
| *interactive* | 15A | `#2e7fc4` | `#0f5288` | — | — |

Two values per tier, and the distinction is load-bearing:

- **`-tab`** is the fuse's own plastic. It appears on the legend swatches and
  on a seated fuse, where it is being shown *as itself*.
- **`-ink`** is the same hue pushed to text-safe contrast against `--cell`.
  Everything that carries meaning uses this one.

**15A blue is the only chromatic value that is not a status.** It is the
interactive ink — links, primary buttons, focus. Kashif is the thing that reads
the box, not one of the faults in it.

Nothing else in the product is chromatic.

### The colour law

> A filled ground takes the tier's **`-ink`** with **`--cell`** on top of it.
> The raw `-tab` value is never a text background.

This is not a preference. Filled buttons were measured at **2.59:1** while they
used `-tab`; on `-ink` they pass. The system is verified at **0 contrast
failures across 148 text nodes, in both themes**, and the check runs in CI.

### Colour never carries severity alone

Every tier has a **drawn shape** as well as an ink, because the report is
printed on office black-and-white printers and read by colour-blind
technicians. Twenty-seven drawn marks survive a monochrome printout with the
ranking intact. See `src/lib/design/severity.ts` — one source of truth, no
second list anywhere.

---

## 2. Depth is a moulded rib, never a shadow

```css
.rib {
  border-block-start: 1px solid var(--rib);
  box-shadow: inset 0 1px 0 0 var(--rib-lit);
}
```

A dark groove plus its lit crest. That pair **is** the entire depth system —
it is how a ridge in moulded plastic actually reads, and it is the reason the
product does not look like every other card UI.

`.rib-heavy` (3px) opens a severity bank, with the bank's name set *inside* the
rule, the way a fuse box moulds its row letters into the ridge instead of
printing them above it.

**There is exactly one shadow in the product**, `--lift`, and it belongs to a
cell that has been pulled out of the board.

Nothing is rounded. `--radius-plate: 1px` is the largest radius in the system,
and it exists so a stamped code plate does not look laser-cut.

---

## 3. One container

`Cell` — a silkscreened panel recessed into the board. There is no card, no
nested card, and no panel-inside-a-panel.

Severity is carried by a `SeveritySeat` placed *in* the cell's content, not by
a coloured band down its edge. An edge band reads as the generic status stripe
every dashboard has, and it cannot show the amp rating a seat can.

---

## 4. Type

Two families, each with one job.

- **Readex Pro** — Arabic-first variable, engineered for legibility at small
  sizes and poor contrast, which is the scene. Not a Latin face with Arabic
  bolted on.
- **Azeret Mono** — measured values only: DTCs, OEM numbers, VINs, voltages,
  fuse ratings. Marked in markup with `data-num`. Mono is for **data**, never
  as a costume for "technical".

**One body size carries the whole board.** Rank is weight, case, and rule —
not a ladder of nine sizes. `--t-score` (2.75rem) exists for exactly one
number.

---

## 5. Both lids ship

Light is the default, because the scene is a phone at arm's length in Libyan
daylight. Dark is the night bay, not the default.

They are **separate token sets**, not a filter. `--rib` in light is `#a9ada5`
against a `#d5d7cf` board; in dark it is `#0b0d0e` against `#17191a`. Inverting
one would produce a groove that reads as a ridge.

The theme is stamped on `<html>` before first paint by a tiny inline script, so
a stored choice never flashes the other lid. `ThemeToggle` reads the DOM
through `useSyncExternalStore` rather than holding its own copy.

Three states are handled, and all three are defined: an explicit
`data-theme="light"`, an explicit `data-theme="dark"`, and the default where
nothing is stamped and `prefers-color-scheme` decides.

---

## 6. Print is a first-class output

The board prints as a legend sheet: the amp inks drop out, the **shapes** carry
severity, furniture is `no-print`, and `break-inside: avoid` keeps a fault
whole across a page break — a symptom split onto the next sheet is how it gets
read against the wrong code.

The **exported certificate** is a separate document with the same rules and one
extra constraint: it asks the network for **nothing**. No font links, no remote
images, no analytics. Verified at 0 external requests, because the scene it
exists for is a workshop laptop with no internet.

---

## 7. Space and touch

A 4px module — a fuse box is a grid of fixed pitches. `--s1` 4px through `--s8`
64px, and nothing between them.

`--tap: 44px` is a floor, not a target. Where a control is visually smaller
(the checklist checkbox is 18px), the **label** is the tap target, and it is
342×143 at phone width.

---

## 8. Motion

Three durations, one curve.

```css
--ease: cubic-bezier(0.16, 1, 0.3, 1);
--dur-mark: 90ms;   /* a mark changing state   */
--dur-lift: 160ms;  /* a cell pulling out      */
--dur-sheet: 200ms; /* a sheet arriving        */
```

**Only the sheet animates position**, and it arrives from the edge it is
anchored to: up from the bottom on a phone, in from the inline-start edge on a
wide screen. `prefers-reduced-motion: reduce` flattens everything to 0.01ms.

---

## 9. Direction

The product is RTL. `dir="rtl"` on `<html>`, and **logical properties
everywhere** — `border-inline-start`, `ms-`, `ps-`, `text-start`. There is no
`left` or `right` in the system.

Latin data (a VIN, an OEM number) is marked `dir="ltr"` where it appears inside
Arabic prose, so the digits do not reverse.

---

## 10. The rule that outranks the rest

> **The interface never states a finding about a car it did not read.**

This is a design rule as much as an engineering one, because it decides what a
component renders when it has nothing.

- Unknown is **`غير محدد`**, set in `--ink-3` italic — visibly a gap, not a
  value.
- An empty list is **omitted entirely**. Printing an empty "الأعراض" heading
  reads as "no symptoms", which is a finding we do not have.
- A derived number **says it is derived**: `الجاهزية (تقديري)` on screen and on
  the certificate.
- Wiring guidance **names its source** — `من فحص سيارتك`, `من مرجع الأكواد`, or
  `إرشاد عام — مش مخطط سيارتك` — before it says anything, because the reader
  acts on it with a probe.

`Field` implements the first two. `severity.ts` and `WiringSheet` implement the
others. 43 unit tests and 28 end-to-end tests hold the line.

---

## Identity

The mark is a **seated 15A blade fuse** (ATO/ATC standard), hand-drawn with its
moulded polymer body, zinc terminal blades, and intact S-element bridge.

- **Why the fuse**: The product's metaphor is the fuse-box lid. "كاشف" means the
  uncoverer / revealer. An intact S-element bridge is the universal automotive
  sign of unbroken electrical integrity — it tells at a glance whether the circuit
  is sound or blown, which is exactly what Kashif does for the car.
- **Colour**: Exclusively **15A blue** (`--amp-15-tab` / `--amp-15-ink`). It never
  takes 10A red, 20A yellow, or 30A green. 15A blue is the interactive brand ink;
  the mark represents the instrument reading the board, not a fault tier on it.
- **Scale and legibility**: Tested down to **16px** (browser tab favicon). At 16px,
  the silhouette of the two terminal blades, the 15A blue housing, and the
  high-contrast central bridge element survive without blurring.
- **Lockup**: RTL-correct. The mark sits on the **inline-start (right) edge** of
  the Arabic wordmark, leading the eye into the name.
- **What not to do**:
  - Never round the corners. `--radius-plate: 1px` is the ceiling.
  - Never add drop shadows, lighting flares, or radial glows.
  - Never show a blown (severed) element in the identity mark — a broken fuse is
    the fault state, not the brand.
  - Never render the mark in a severity status colour.

---

## Files

| | |
|---|---|
| `public/icon.svg` | the primary 15A blade fuse mark, square |
| `public/icon-maskable.svg` | the maskable mark inside the 80% safe zone |
| `public/logo.svg` | the RTL horizontal wordmark lockup |
| `public/og.svg` | the 1200×630 WhatsApp social preview |
| `src/app/globals.css` | tokens, both themes, `.rib`, `.k-cell`, `.k-plate`, `.k-seat`, print |
| `src/lib/design/severity.ts` | the severity notation, single source |
| `src/components/ui/primitives.tsx` | `Cell`, `CodePlate`, `BankRule`, `Field`, `SeverityLegend`, `Button` |
| `src/components/ui/SeverityMark.tsx` | the four drawn shapes and the seat |
| `src/components/ui/Sheet.tsx` | the one modal behaviour |
| `src/app/design/page.tsx` | the living spec, at `/design` |

## Provenance

The direction was chosen from three grounded candidates generated under seed
`3a0b3d60` (assigned index 3), and confirmed over a rival "official inspection
certificate" concept. The contract — thesis, own-world, story, first viewport,
form, finish — is committed as an HTML comment in `src/app/layout.tsx`, where
it cannot drift from the thing it describes.
