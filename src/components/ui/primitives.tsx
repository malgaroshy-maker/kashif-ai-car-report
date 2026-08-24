import * as React from "react";
import { cn } from "@/lib/cn";
import { SEVERITY, SEVERITY_ORDER, type Severity } from "@/lib/design/severity";
import { SeverityMark, SeveritySeat } from "./SeverityMark";

/* ==========================================================================
   Fuse-box primitives.

   Depth is a moulded rib, never a shadow: .rib pairs a dark groove with a lit
   crest, which is how a ridge in plastic actually reads. The single shadow in
   the system belongs to a cell that has been pulled out of the board.

   One colour law holds everywhere: a filled ground takes the tier's `-ink`
   value with `--cell` on top of it. The raw `-tab` value is the fuse's own
   plastic and appears only on the large legend swatches, where it is being
   shown as itself rather than carrying meaning.
   ========================================================================== */

/* --------------------------------------------------------------- CodePlate */

/**
 * A stamped label: reversed mono on a solid ink block. Only ever holds a
 * measured value — a DTC, an OEM number, a VIN, a voltage, a fuse rating.
 * Mono is for data here, never for atmosphere.
 */
export function CodePlate({
  children,
  tone = "ink",
  className,
}: {
  children: React.ReactNode;
  tone?: "ink" | Severity;
  className?: string;
}) {
  const style =
    tone === "ink"
      ? undefined
      : { backgroundColor: SEVERITY[tone].ink, color: "var(--cell)" };

  return (
    <span data-num className={cn("k-plate inline-block", className)} style={style}>
      {children}
    </span>
  );
}

/* -------------------------------------------------------------------- Cell */

/**
 * A silkscreened panel recessed into the board — the only container in the
 * system. There is no card, no nested card, and no rounded corner.
 *
 * Severity is carried by a `SeveritySeat` placed in the cell's content, not by
 * a coloured border down its edge: an edge band reads as the generic status
 * stripe, and it cannot show the amp rating.
 */
export function Cell({
  lifted = false,
  as: Tag = "div",
  className,
  children,
  ...rest
}: {
  lifted?: boolean;
  as?: React.ElementType;
  className?: string;
  children: React.ReactNode;
} & React.HTMLAttributes<HTMLElement>) {
  return (
    <Tag
      className={cn(
        "k-cell relative p-[var(--s4)]",
        lifted && "k-lift",
        "transition-shadow duration-[var(--dur-lift)] ease-[var(--ease)]",
        className
      )}
      {...rest}
    >
      {children}
    </Tag>
  );
}

/* ---------------------------------------------------------------- BankRule */

/**
 * The heavy moulded rib that opens a severity bank, with the bank's name set
 * inside the rule itself — the way a fuse box moulds its row letters into the
 * ridge rather than printing them above it.
 */
export function BankRule({
  severity,
  count,
  className,
}: {
  severity: Severity;
  count?: number;
  className?: string;
}) {
  const token = SEVERITY[severity];

  return (
    <div
      className={cn(
        "rib-heavy flex items-center gap-[var(--s2)] pt-[var(--s2)]",
        className
      )}
    >
      <SeverityMark severity={severity} size={14} labelled />
      <h2 className="k-bank uppercase" style={{ color: token.ink }}>
        {token.labelAr}
      </h2>
      {typeof count === "number" && (
        <span data-num className="k-label text-[var(--ink-3)]">
          {count}
        </span>
      )}
      <span className="rib mt-[2px] h-px flex-1" aria-hidden />
      <span data-num className="k-label text-[var(--ink-3)]">
        {token.ampRating}
      </span>
    </div>
  );
}

/* ------------------------------------------------------------------- Field */

/** Label above, value below, hairline under. The universal data pair. */
export function Field({
  label,
  value,
  mono = false,
  className,
}: {
  label: string;
  value: React.ReactNode;
  mono?: boolean;
  className?: string;
}) {
  const missing = value === null || value === undefined || value === "";

  return (
    <div className={cn("pb-[var(--s2)]", className)}>
      <div className="k-label uppercase">{label}</div>
      <div
        {...(mono ? { "data-num": true } : {})}
        className={cn(
          "border-b border-[var(--rib)] pb-[var(--s1)] pt-[2px]",
          missing ? "text-[var(--ink-3)] italic" : "text-[var(--ink)]"
        )}
      >
        {missing ? "غير محدد" : value}
      </div>
    </div>
  );
}

/* ------------------------------------------------------------------ Legend */

/**
 * The key panel. A real lid prints one, so the colour code is taught before it
 * is used rather than assumed. Rendered once per report, above the first bank.
 */
export function SeverityLegend({ className }: { className?: string }) {
  return (
    <Cell as="section" className={cn("p-[var(--s3)]", className)}>
      <h2 className="k-label uppercase mb-[var(--s2)]">مفتاح الرموز</h2>
      <ul className="flex flex-wrap gap-x-[var(--s5)] gap-y-[var(--s2)]">
        {SEVERITY_ORDER.map((s) => {
          const token = SEVERITY[s];
          return (
            <li key={s} className="flex items-center gap-[var(--s2)]">
              <SeveritySeat severity={s} />
              <span className="font-semibold" style={{ color: token.ink }}>
                {token.labelAr}
              </span>
            </li>
          );
        })}
      </ul>
    </Cell>
  );
}

/* ------------------------------------------------------------------ Button */

type ButtonProps = React.ButtonHTMLAttributes<HTMLButtonElement> & {
  variant?: "primary" | "ghost" | "danger";
};

/**
 * Square, silkscreened, tap-target sized. Nothing here is rounded and nothing
 * glows; pressed state sinks into the board instead of lifting off it.
 */
export function Button({
  variant = "ghost",
  className,
  children,
  ...rest
}: ButtonProps) {
  return (
    <button
      className={cn(
        "inline-flex items-center justify-center gap-[var(--s2)]",
        "min-h-[var(--tap)] px-[var(--s4)] py-[var(--s2)]",
        "border font-semibold",
        "transition-[background-color,color,border-color] duration-[var(--dur-mark)] ease-[var(--ease)]",
        "active:translate-y-px",
        "disabled:cursor-not-allowed disabled:opacity-45",
        variant === "primary" &&
          "border-transparent bg-[var(--amp-15-ink)] text-[var(--cell)] hover:brightness-110",
        variant === "ghost" &&
          "border-[var(--rib)] bg-[var(--cell)] text-[var(--ink)] hover:bg-[var(--board-sunk)]",
        variant === "danger" &&
          "border-transparent bg-[var(--amp-10-ink)] text-[var(--cell)] hover:brightness-110",
        className
      )}
      {...rest}
    >
      {children}
    </button>
  );
}
