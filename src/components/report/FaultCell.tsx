"use client";

import * as React from "react";
import { Cell, CodePlate, Button } from "@/components/ui/primitives";
import { SeveritySeat } from "@/components/ui/SeverityMark";
import { SEVERITY, type Severity } from "@/lib/design/severity";
import type { DiagnosticCodeDetail } from "@/lib/types";

/**
 * One fault, as a cell in the board.
 *
 * The card this replaces put its severity in a coloured left border and a
 * pill that said "حرج وعاجل" — the generic status stripe, which carries
 * nothing a printer or a colour-blind reader can use. Here the tier is a
 * seated fuse: a drawn shape plus its amp rating, both of which survive black
 * and white.
 *
 * Detail is disclosed in place. There is no modal for reading, because a
 * mechanic holding a phone under a bonnet should not have to manage a stack of
 * overlays to compare two faults.
 */
export function FaultCell({
  fault,
  severity,
  onSelectPart,
  onOpenWiring,
}: {
  fault: DiagnosticCodeDetail;
  severity: Severity;
  onSelectPart?: (partId?: string) => void;
  onOpenWiring?: () => void;
}) {
  const [open, setOpen] = React.useState(false);
  const bodyId = `fault-${fault.code}-body`;
  const token = SEVERITY[severity];

  const hasDetail =
    fault.driverSymptoms.length > 0 ||
    fault.rootCauses.length > 0 ||
    Boolean(fault.standardArabicDescription) ||
    Boolean(fault.recommendedAction);

  return (
    <Cell as="article" lifted={open} className="p-[var(--s4)]">
      <div className="flex items-start gap-[var(--s3)]">
        <SeveritySeat severity={severity} />

        <div className="min-w-0 flex-1">
          <div className="flex flex-wrap items-center gap-[var(--s2)]">
            <CodePlate>{fault.code}</CodePlate>
            <span className="k-label uppercase">
              {fault.moduleNameArabic || fault.module}
            </span>
          </div>

          <h3 className="mt-[var(--s2)] font-bold leading-snug text-(color:--ink)">
            {fault.libyanTerm}
          </h3>

          {fault.standardDescriptionEn && (
            <p data-num className="k-label mt-[2px] normal-case">
              {fault.standardDescriptionEn}
            </p>
          )}
        </div>
      </div>

      {/* The three impact readings, always present, always in the same order,
          so two faults can be compared without reading prose. */}
      <dl className="rib mt-[var(--s3)] grid grid-cols-3 gap-[var(--s2)] pt-[var(--s2)]">
        <Impact label="السلامة" value={fault.impactOnVehicle.safety} />
        <Impact label="الوقود" value={fault.impactOnVehicle.fuelEconomy} />
        <Impact label="القيادة" value={fault.impactOnVehicle.drivability} />
      </dl>

      {hasDetail && (
        <>
          <div className="mt-[var(--s3)] flex flex-wrap items-center gap-[var(--s2)]">
            <Button
              onClick={() => setOpen((v) => !v)}
              aria-expanded={open}
              aria-controls={bodyId}
              className="text-(length:--t-plate)"
            >
              {open ? "إخفاء التفاصيل" : "التفاصيل والأسباب"}
            </Button>

            {onOpenWiring && (
              <Button onClick={onOpenWiring} className="text-(length:--t-plate)">
                الفيوز والفيشة
              </Button>
            )}

            {fault.recommendedPartId && onSelectPart && (
              <Button
                variant="primary"
                onClick={() => onSelectPart(fault.recommendedPartId)}
                className="text-(length:--t-plate)"
              >
                القطعة المطلوبة
              </Button>
            )}
          </div>

          <div id={bodyId} hidden={!open} className="mt-[var(--s3)] space-y-[var(--s3)]">
            {fault.standardArabicDescription && (
              <p className="leading-relaxed text-(color:--ink)">
                {fault.standardArabicDescription}
              </p>
            )}
            <FaultList label="اللي يحسّه السائق" items={fault.driverSymptoms} />
            <FaultList label="الأسباب المحتملة" items={fault.rootCauses} />
            {fault.recommendedAction && (
              <div
                className="border-s-[3px] ps-[var(--s3)]"
                style={{ borderColor: token.ink }}
              >
                <div className="k-label uppercase">التوجيه</div>
                <p className="leading-relaxed text-(color:--ink)">
                  {fault.recommendedAction}
                </p>
              </div>
            )}
          </div>
        </>
      )}
    </Cell>
  );
}

function Impact({ label, value }: { label: string; value: string }) {
  return (
    <div>
      <dt className="k-label uppercase">{label}</dt>
      <dd className="text-(color:--ink)">{value}</dd>
    </div>
  );
}

/**
 * A list the model may not have supplied. An empty one is omitted entirely —
 * printing an empty "الأعراض" heading reads as "no symptoms", which is a
 * finding we do not have.
 */
function FaultList({ label, items }: { label: string; items: string[] }) {
  if (items.length === 0) return null;
  return (
    <div>
      <div className="k-label uppercase">{label}</div>
      <ul className="mt-[var(--s1)] space-y-[var(--s1)]">
        {items.map((item, i) => (
          <li key={i} className="flex gap-[var(--s2)] text-(color:--ink)">
            <span aria-hidden className="text-(color:--ink-3)">
              —
            </span>
            <span>{item}</span>
          </li>
        ))}
      </ul>
    </div>
  );
}
