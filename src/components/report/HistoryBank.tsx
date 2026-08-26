"use client";

import * as React from "react";
import { Button, Cell, CodePlate } from "@/components/ui/primitives";
import { SeverityMark } from "@/components/ui/SeverityMark";
import { SEVERITY, severityFromScore } from "@/lib/design/severity";
import { orUnknown, type KashifDiagnosticReport } from "@/lib/types";

/**
 * The scans already on this device.
 *
 * A mechanic checks three cars in an afternoon and wants the second one back.
 * Every row is one car, identified the way the reader identifies it — make,
 * model, and the VIN they can match against the one on the windscreen — with
 * the readiness figure that decided the verdict.
 *
 * Nothing here is on a server. That is worth saying on the panel rather than
 * in a settings page nobody opens: the reports live in this browser, and
 * clearing the browser clears them.
 */
export function HistoryBank({
  history,
  onSelect,
  onClear,
}: {
  history: KashifDiagnosticReport[];
  onSelect: (report: KashifDiagnosticReport) => void;
  onClear: () => void;
}) {
  const [confirming, setConfirming] = React.useState(false);

  if (history.length === 0) return null;

  return (
    <section className="space-y-[var(--s3)]" aria-labelledby="history-heading">
      <div className="rib-heavy flex items-center gap-[var(--s2)] pt-[var(--s2)]">
        <h2 id="history-heading" className="k-bank uppercase text-(color:--ink)">
          تقارير محفوظة على هذا الجهاز
        </h2>
        <span className="rib mt-[2px] h-px flex-1" aria-hidden />
        <span data-num className="k-label">
          {history.length}
        </span>
      </div>

      <Cell as="ul" className="p-0">
        {history.map((report, i) => (
          <li key={report.reportId} className={i > 0 ? "rib" : undefined}>
            <HistoryRow report={report} onSelect={() => onSelect(report)} />
          </li>
        ))}
      </Cell>

      <div className="flex flex-wrap items-center gap-[var(--s3)]">
        <p className="k-label normal-case flex-1">
          محفوظة في متصفحك بس — ما فيش نسخة على أي خادم.
        </p>

        {confirming ? (
          <div className="flex items-center gap-[var(--s2)]">
            <span className="k-label normal-case">تمسح الكل؟</span>
            <Button
              variant="danger"
              onClick={() => {
                onClear();
                setConfirming(false);
              }}
            >
              امسح
            </Button>
            <Button onClick={() => setConfirming(false)}>تراجع</Button>
          </div>
        ) : (
          // Deleting every saved report is not undoable and the reports are not
          // stored anywhere else, so it asks first.
          <Button onClick={() => setConfirming(true)}>مسح السجل</Button>
        )}
      </div>
    </section>
  );
}

function HistoryRow({
  report,
  onSelect,
}: {
  report: KashifDiagnosticReport;
  onSelect: () => void;
}) {
  const { vehicle, summary, faultCategories } = report;
  const severity = severityFromScore(summary.overallHealthScore);
  const token = SEVERITY[severity];

  const name = [vehicle.make, vehicle.model].filter(Boolean).join(" ");
  const faults =
    faultCategories.criticalFaults.length + faultCategories.moderateFaults.length;

  return (
    <button
      onClick={onSelect}
      className="flex w-full items-center gap-[var(--s3)] p-[var(--s3)] text-start transition-colors duration-[var(--dur-mark)] hover:bg-[var(--board-sunk)] min-h-[var(--tap)]"
    >
      <SeverityMark severity={severity} size={16} labelled />

      <span className="min-w-0 flex-1">
        <span className="block truncate font-semibold text-(color:--ink)">
          {name || "سيارة غير محددة"}
          {vehicle.year && (
            <span data-num className="ms-[var(--s2)] font-normal text-(color:--ink-2)">
              {vehicle.year}
            </span>
          )}
        </span>
        <span className="k-label mt-[2px] block normal-case">
          {orUnknown(vehicle.vin, "بدون رقم هيكل")} ·{" "}
          {faults > 0 ? `${faults} عطل` : "بدون أعطال"}
        </span>
      </span>

      <span
        data-num
        className="shrink-0 font-semibold"
        style={{ color: token.ink }}
      >
        {summary.overallHealthScore}%
      </span>

      <CodePlate className="shrink-0">
        {String(report.generatedAt).slice(0, 10)}
      </CodePlate>
    </button>
  );
}
