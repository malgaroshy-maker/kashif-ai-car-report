"use client";

import * as React from "react";
import { BankRule, Cell, SeverityLegend } from "@/components/ui/primitives";
import { SeveritySeat } from "@/components/ui/SeverityMark";
import { SEVERITY_ORDER, type Severity } from "@/lib/design/severity";
import { FaultCell } from "./FaultCell";
import { WiringSheet } from "./WiringSheet";
import type { DiagnosticCodeDetail, KashifDiagnosticReport } from "@/lib/types";

/**
 * The board itself: every finding, in banks, worst first.
 *
 * The matrix this replaces opened on a filter bar — الكل / حرج / متوسط —
 * which put a control between the mechanic and the one thing he came for. A
 * fuse box does not have a filter. It has rows, and the row that matters is
 * the one at the top. Everything is on the page; the heavy rib and the amp
 * rating tell you where you are, and scrolling is the filter.
 *
 * Order is fixed by `SEVERITY_ORDER` and is not the reader's to change:
 * critical, moderate, memory, passed. What strands the driver comes first.
 */
export function FaultBoard({
  report,
  onSelectPart,
}: {
  report: KashifDiagnosticReport;
  onSelectPart?: (partId?: string) => void;
}) {
  const [wiringFor, setWiringFor] = React.useState<DiagnosticCodeDetail | null>(
    null
  );

  const banks: Record<Severity, DiagnosticCodeDetail[]> = {
    critical: report.faultCategories.criticalFaults,
    moderate: report.faultCategories.moderateFaults,
    history: report.faultCategories.minorOrHistoricalFaults,
    passed: [],
  };

  const totalFaults =
    banks.critical.length + banks.moderate.length + banks.history.length;

  return (
    <section className="space-y-[var(--s5)]" aria-labelledby="board-heading">
      <h2 id="board-heading" className="sr-only">
        الأعطال المسجلة والمنظومات المفحوصة
      </h2>

      {/* The lid prints its own key before it uses it. */}
      <SeverityLegend />

      {totalFaults === 0 && report.passedSystems.length === 0 && (
        <Cell className="p-[var(--s5)] text-center text-(color:--ink-2)">
          التقرير ما فيهش أعطال مسجلة ولا منظومات سليمة. راجع ملف الفحص الأصلي.
        </Cell>
      )}

      {SEVERITY_ORDER.filter((s) => s !== "passed").map((severity) => {
        const faults = banks[severity];
        if (faults.length === 0) return null;
        return (
          <div key={severity} className="space-y-[var(--s3)]">
            <BankRule severity={severity} count={faults.length} />
            <div className="grid gap-[var(--s3)] lg:grid-cols-2">
              {faults.map((fault, i) => (
                <FaultCell
                  key={`${fault.code}-${i}`}
                  fault={fault}
                  severity={severity}
                  onSelectPart={onSelectPart}
                  onOpenWiring={() => setWiringFor(fault)}
                />
              ))}
            </div>
          </div>
        );
      })}

      {report.passedSystems.length > 0 && <PassedBank report={report} />}

      {wiringFor && (
        <WiringSheet
          fault={wiringFor}
          vehicleMake={report.vehicle.make ?? undefined}
          vehicleModel={report.vehicle.model ?? undefined}
          onClose={() => setWiringFor(null)}
        />
      )}
    </section>
  );
}

/**
 * The systems that passed.
 *
 * These are seated fuses too, not a list of ticks: a system that passed is a
 * fuse that is intact, which is the same object as a fault, in a different
 * colour. They are terse on purpose — a passing system has no story.
 *
 * An empty bank is omitted rather than shown as "0 passed", because nothing
 * reported as passing is not the same as nothing passing.
 */
function PassedBank({ report }: { report: KashifDiagnosticReport }) {
  return (
    <div className="space-y-[var(--s3)]">
      <BankRule severity="passed" count={report.passedSystems.length} />
      <Cell className="p-[var(--s3)]">
        <ul className="flex flex-wrap gap-x-[var(--s5)] gap-y-[var(--s3)]">
          {report.passedSystems.map((system, i) => (
            <li
              key={`${system.systemCode}-${i}`}
              className="flex items-center gap-[var(--s2)]"
            >
              <SeveritySeat severity="passed" />
              <span className="text-(color:--ink)">{system.systemNameArabic}</span>
              <span data-num className="k-label">
                {system.systemCode}
              </span>
            </li>
          ))}
        </ul>
      </Cell>
    </div>
  );
}
