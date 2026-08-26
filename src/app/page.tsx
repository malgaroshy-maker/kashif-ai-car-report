"use client";

import React, { useState } from "react";
import { Masthead } from "@/components/report/Masthead";
import { Intake } from "@/components/report/Intake";
import { VehiclePlate } from "@/components/report/VehiclePlate";
import { FaultBoard } from "@/components/report/FaultBoard";
import { Checklist } from "@/components/report/Checklist";
import { PartsBank } from "@/components/report/PartsBank";
import { ReportActions } from "@/components/report/ReportActions";
import { HistoryBank } from "@/components/report/HistoryBank";
import { SettingsPanel } from "@/components/report/SettingsPanel";
import { DictionaryPanel } from "@/components/report/DictionaryPanel";
import { AssistantPanel } from "@/components/report/AssistantPanel";
import { KashifDiagnosticReport } from "@/lib/types";
import { removeLocal, useLocalJson, writeLocal } from "@/lib/local-store";

const HISTORY_KEY = "kashif_saved_reports";

/** Stable identity: a fresh [] each render would loop useSyncExternalStore. */
const EMPTY_HISTORY: KashifDiagnosticReport[] = [];

/** The history list holds the last fifteen scans. */
const HISTORY_LIMIT = 15;

/**
 * A stored report is only shown if it still has the parts the UI reads.
 * Anything else is a record from an older version, or a truncated write.
 */
function isUsableStoredReport(value: unknown): value is KashifDiagnosticReport {
  if (!value || typeof value !== "object") return false;
  const r = value as Partial<KashifDiagnosticReport>;
  return (
    typeof r.reportId === "string" &&
    !!r.vehicle &&
    !!r.summary &&
    typeof r.summary.overallHealthScore === "number" &&
    !!r.faultCategories &&
    Array.isArray(r.faultCategories.criticalFaults) &&
    Array.isArray(r.faultCategories.moderateFaults) &&
    Array.isArray(r.faultCategories.minorOrHistoricalFaults) &&
    Array.isArray(r.passedSystems) &&
    Array.isArray(r.sparePartsRequired) &&
    Array.isArray(r.workshopChecklist)
  );
}

/**
 * Reads the stored history, dropping anything that no longer parses.
 *
 * The previous version patched the holes instead of dropping the record: a
 * report with no summary was rendered with a health score of 70 and a status
 * of "متوسط / انتبه" — a grade this app invented for a car whose findings it
 * had lost.
 */
function readHistory(value: unknown): KashifDiagnosticReport[] | null {
  if (!Array.isArray(value)) return null;
  return value.filter(isUsableStoredReport);
}

/**
 * The lid.
 *
 * One page with two states — an empty board waiting for a scan, and a board
 * with a car on it. The reading order below is the order of the STORY in the
 * root layout's direction contract: which car, then what is wrong ranked by
 * danger, then the test to run before buying the part.
 */
export default function HomePage() {
  const [activeReport, setActiveReport] =
    useState<KashifDiagnosticReport | null>(null);
  const [isLoading, setIsLoading] = useState(false);
  const [selectedPartId, setSelectedPartId] = useState<string | undefined>();
  const [settingsOpen, setSettingsOpen] = useState(false);
  const [dictionaryOpen, setDictionaryOpen] = useState(false);

  // Read straight from storage during render, so there is no empty first pass
  // and no second one to correct it.
  const savedReports = useLocalJson<KashifDiagnosticReport[]>(
    HISTORY_KEY,
    readHistory,
    EMPTY_HISTORY
  );

  const handleReportGenerated = (report: KashifDiagnosticReport) => {
    setActiveReport(report);
    setSelectedPartId(undefined);
    window.scrollTo({ top: 0, behavior: "smooth" });

    // Persist to local history. A failed write (quota, storage disabled) is
    // logged and shrugged off: the report is on screen either way, and only
    // the history list loses it.
    const filtered = savedReports.filter((r) => r.reportId !== report.reportId);
    writeLocal(
      HISTORY_KEY,
      JSON.stringify([report, ...filtered].slice(0, HISTORY_LIMIT))
    );
  };

  /** Jumps to a part named by a fault, and marks it so it can be seen. */
  const handleSelectPart = (partId?: string) => {
    setSelectedPartId(partId);
    const target = partId
      ? document.getElementById(`part-${partId}`)
      : document.getElementById("spare-parts-section");
    target?.scrollIntoView({ behavior: "smooth", block: "center" });
  };

  return (
    <div className="flex min-h-dvh flex-col bg-[var(--board)]">
      <Masthead
        onNewScan={
          activeReport
            ? () => {
                setActiveReport(null);
                setSelectedPartId(undefined);
                window.scrollTo({ top: 0, behavior: "smooth" });
              }
            : undefined
        }
        onOpenSettings={() => setSettingsOpen(true)}
        onOpenDictionary={() => setDictionaryOpen(true)}
      />

      <main id="main" className="mx-auto w-full max-w-[1180px] flex-1 px-[var(--s4)] py-[var(--s5)]">
        {activeReport ? (
          <div className="space-y-[var(--s5)]">
            <VehiclePlate report={activeReport} />
            <ReportActions report={activeReport} />
            <FaultBoard report={activeReport} onSelectPart={handleSelectPart} />
            <Checklist steps={activeReport.workshopChecklist} />
            <PartsBank
              parts={activeReport.sparePartsRequired}
              selectedPartId={selectedPartId}
              vehicle={{
                make: activeReport.vehicle.make ?? undefined,
                model: activeReport.vehicle.model ?? undefined,
                year: activeReport.vehicle.year ?? undefined,
              }}
            />
            <AssistantPanel report={activeReport} />
          </div>
        ) : (
          <div className="space-y-[var(--s5)]">
            <Intake
              busy={isLoading}
              setBusy={setIsLoading}
              onReport={handleReportGenerated}
            />
            <HistoryBank
              history={savedReports}
              onSelect={(r) => {
                setActiveReport(r);
                window.scrollTo({ top: 0, behavior: "smooth" });
              }}
              onClear={() => removeLocal(HISTORY_KEY)}
            />
          </div>
        )}
      </main>

      <footer className="border-t border-[var(--rib)] px-[var(--s4)] py-[var(--s4)]">
        <p className="mx-auto max-w-[1180px] k-label normal-case">
          كاشف يقرا تقرير جهاز الفحص ويترجمه. مش بديل عن كشف الأسطى على
          السيارة نفسها.
        </p>
      </footer>

      {settingsOpen && <SettingsPanel onClose={() => setSettingsOpen(false)} />}
      {dictionaryOpen && (
        <DictionaryPanel onClose={() => setDictionaryOpen(false)} />
      )}
    </div>
  );
}
