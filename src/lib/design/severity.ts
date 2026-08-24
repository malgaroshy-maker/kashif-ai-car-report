/**
 * Severity notation — the single source of truth for how danger is shown.
 *
 * The colours are not a palette. They are ISO/DIN 72581-3, the blade-fuse
 * colour code printed on every fuse in every car, which the mechanic reading
 * this report already decodes without being taught.
 *
 * Every tier carries a SHAPE as well as an ink, because the report is printed
 * on black-and-white office printers and read by colour-blind technicians.
 * Colour alone never carries severity anywhere in this product.
 */

import type { SeverityStatus } from "@/lib/types";

export type Severity = "critical" | "moderate" | "passed" | "history";

export type SeverityShape = "triangle" | "halfbar" | "tick" | "ring";

export interface SeverityToken {
  /** The blade fuse this tier borrows its colour from. */
  ampRating: string;
  /** The fuse's own plastic colour: tabs, marks, fills. */
  tab: string;
  /** The same hue at text-safe contrast against the cell. */
  ink: string;
  /** Carries the tier when the ink is gone (print, colour-blindness). */
  shape: SeverityShape;
  /** Workshop Arabic, not Modern Standard. */
  labelAr: string;
  /** Spoken out to assistive technology alongside the shape. */
  descriptionAr: string;
}

export const SEVERITY: Record<Severity, SeverityToken> = {
  critical: {
    ampRating: "10A",
    tab: "var(--amp-10-tab)",
    ink: "var(--amp-10-ink)",
    shape: "triangle",
    labelAr: "حرج",
    descriptionAr: "عطل حرج — يتطلب صيانة عاجلة",
  },
  moderate: {
    ampRating: "20A",
    tab: "var(--amp-20-tab)",
    ink: "var(--amp-20-ink)",
    shape: "halfbar",
    labelAr: "متوسط",
    descriptionAr: "عطل متوسط — يتطلب صيانة قريبة",
  },
  passed: {
    ampRating: "30A",
    tab: "var(--amp-30-tab)",
    ink: "var(--amp-30-ink)",
    shape: "tick",
    labelAr: "سليم",
    descriptionAr: "منظومة سليمة — اجتازت الفحص",
  },
  history: {
    ampRating: "25A",
    tab: "var(--amp-25-tab)",
    ink: "var(--amp-25-ink)",
    shape: "ring",
    labelAr: "ذاكرة",
    descriptionAr: "كود مخزّن في الذاكرة — غير نشط حالياً",
  },
};

/** Tiers in the order the board prints them: worst first. */
export const SEVERITY_ORDER: Severity[] = [
  "critical",
  "moderate",
  "history",
  "passed",
];

/** The interactive ink. 15A blue is the only chromatic value that is not a status. */
export const ACCENT = {
  ampRating: "15A",
  tab: "var(--amp-15-tab)",
  ink: "var(--amp-15-ink)",
} as const;

/** Maps a report's overall status onto a tier. */
export function severityFromStatus(status?: SeverityStatus | string): Severity {
  if (!status) return "moderate";
  if (status.includes("حرج") || status.includes("خطر")) return "critical";
  if (status.includes("سليم") || status.includes("خفيف")) return "passed";
  return "moderate";
}

/** Maps a single fault's urgency onto a tier. */
export function severityFromUrgency(urgency?: string): Severity {
  if (!urgency) return "moderate";
  if (urgency.includes("عالي")) return "critical";
  if (urgency.includes("منخفض")) return "history";
  return "moderate";
}

/**
 * Maps a health score onto a tier.
 * Thresholds are the product's, not the design system's — they live here so a
 * score, a badge and a seal can never disagree about what 61 means.
 */
export function severityFromScore(score: number): Severity {
  if (score < 55) return "critical";
  if (score < 80) return "moderate";
  return "passed";
}
