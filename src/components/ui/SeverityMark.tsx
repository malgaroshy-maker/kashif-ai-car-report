import { cn } from "@/lib/cn";
import { SEVERITY, type Severity, type SeverityShape } from "@/lib/design/severity";

/**
 * The shape half of the severity notation.
 *
 * Drawn, not a unicode glyph — the shapes must hold their weight next to the
 * icon set and survive at 12px on a phone in daylight. They exist so severity
 * still reads when the ink is gone: black-and-white printout, colour-blind
 * technician, a screenshot pasted into WhatsApp.
 *
 * The mark always paints in the tier's `-ink` value, never the raw `-tab`.
 * A fuse's own plastic yellow sits at about 1.3:1 on the light cell, which is
 * invisible; `-ink` is the value tuned to clear 3:1 as a meaningful graphic in
 * both themes. `-tab` is reserved for the large legend swatches, where the
 * plastic colour is being shown as itself rather than carrying meaning.
 */

const PATHS: Record<SeverityShape, React.ReactNode> = {
  // Critical — filled triangle, the universal warning silhouette.
  triangle: <path d="M8 2.2 14.6 13.4H1.4Z" />,
  // Moderate — a bar filled to half, the fuse half-drawn.
  halfbar: (
    <>
      <rect x="1.6" y="4.4" width="12.8" height="7.2" fill="none" strokeWidth="1.8" />
      <rect x="1.6" y="4.4" width="6.4" height="7.2" stroke="none" />
    </>
  ),
  // Passed — a tick, struck the way a mechanic strikes a job card.
  tick: (
    <path
      d="M2.4 8.4 6.3 12.4 13.6 3.9"
      fill="none"
      strokeWidth="2.4"
      strokeLinecap="square"
      strokeLinejoin="miter"
    />
  ),
  // History — a hollow ring, a code stored but not live.
  ring: <circle cx="8" cy="8" r="5.2" fill="none" strokeWidth="1.8" />,
};

export function SeverityMark({
  severity,
  size = 16,
  className,
  /** Set when a visible label already names the tier beside this mark. */
  labelled = false,
  /** Set when the mark sits on a filled seat rather than on the cell. */
  onSeat = false,
}: {
  severity: Severity;
  size?: number;
  className?: string;
  labelled?: boolean;
  onSeat?: boolean;
}) {
  const token = SEVERITY[severity];
  const paint = onSeat ? "var(--cell)" : token.ink;

  return (
    <svg
      viewBox="0 0 16 16"
      width={size}
      height={size}
      className={cn("shrink-0", className)}
      style={{ fill: paint, stroke: paint }}
      role={labelled ? "presentation" : "img"}
      aria-hidden={labelled || undefined}
      aria-label={labelled ? undefined : token.descriptionAr}
      focusable="false"
    >
      {PATHS[token.shape]}
    </svg>
  );
}

/**
 * The fuse in its slot: a solid block in the tier's ink, carrying the mark and
 * the amp rating. This is what sits at a fault row's leading edge — an object
 * you could pull out, which is also the interaction the report is built on.
 */
export function SeveritySeat({
  severity,
  showRating = true,
  className,
}: {
  severity: Severity;
  showRating?: boolean;
  className?: string;
}) {
  const token = SEVERITY[severity];

  return (
    <span
      className={cn("k-seat", className)}
      style={{ backgroundColor: token.ink }}
      role="img"
      aria-label={token.descriptionAr}
    >
      <SeverityMark severity={severity} size={12} onSeat labelled />
      {showRating && <span aria-hidden>{token.ampRating}</span>}
    </span>
  );
}
