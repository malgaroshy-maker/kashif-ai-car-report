"use client";

import React, { useState } from "react";
import { Masthead } from "@/components/report/Masthead";
import { Button } from "@/components/ui/primitives";
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
import { DashboardLightsPanel } from "@/components/report/DashboardLightsPanel";
import { AuthenticFuseCardModal } from "@/components/report/AuthenticFuseCardModal";
import { DtcLookupView } from "@/components/report/DtcLookupView";
import { ReportCompareView } from "@/components/report/ReportCompareView";
import { analyzeCodes } from "@/lib/api-client";

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
  const [activeTab, setActiveTab] = useState<"scan" | "report" | "dtc" | "compare" | "history">("scan");
  const [isLoading, setIsLoading] = useState(false);
  const [selectedPartId, setSelectedPartId] = useState<string | undefined>();
  const [settingsOpen, setSettingsOpen] = useState(false);
  const [dictionaryOpen, setDictionaryOpen] = useState(false);
  const [dashboardLightsOpen, setDashboardLightsOpen] = useState(false);
  const [fuseMapOpen, setFuseMapOpen] = useState(false);

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
    setActiveTab("report");
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


  const handleGenerateFromCodes = async (codes: string[]) => {
    if (codes.length === 0) return;
    setIsLoading(true);
    try {
      const report = await analyzeCodes({ manualCodes: codes.join(", ") });
      handleReportGenerated(report);
    } catch (e: any) {
      alert("تعذر تحليل الأكواد: " + (e?.message || e));
    } finally {
      setIsLoading(false);
    }
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
        activeTab={activeTab}
        onTabChange={(tab) => {
          setActiveTab(tab);
          window.scrollTo({ top: 0, behavior: "smooth" });
        }}
        hasActiveReport={Boolean(activeReport)}
        onNewScan={() => {
          setActiveReport(null);
          setSelectedPartId(undefined);
          setActiveTab("scan");
          window.scrollTo({ top: 0, behavior: "smooth" });
        }}
        onOpenSettings={() => setSettingsOpen(true)}
        onOpenDictionary={() => setDictionaryOpen(true)}
        onOpenDashboardLights={() => setDashboardLightsOpen(true)}
        onOpenFuseMap={() => setFuseMapOpen(true)}
      />

      <main id="main" className="mx-auto w-full max-w-[1280px] flex-1 px-[var(--s4)] py-[var(--s5)]">
        {/* 1. Tab: Scan / Intake */}
        {activeTab === "scan" && (
          <div className="space-y-[var(--s5)]">
            <Intake
              busy={isLoading}
              setBusy={setIsLoading}
              onReport={handleReportGenerated}
            />
            {savedReports.length > 0 && (
              <div className="rounded-xl border border-[var(--rib)] bg-[var(--cell)] p-4 shadow-sm">
                <div className="flex items-center justify-between border-b border-[var(--rib)] pb-2.5 mb-3">
                  <h3 className="text-xs font-bold text-(color:--ink) flex items-center gap-1.5">
                    <span>🕒</span>
                    <span>آخر الفحوصات المحفوظة:</span>
                  </h3>
                  <button
                    onClick={() => setActiveTab("history")}
                    className="text-xs font-bold text-[var(--royal-blue-light)] hover:underline"
                  >
                    عرض كل السجل ({savedReports.length}) ➔
                  </button>
                </div>
                <div className="grid grid-cols-1 sm:grid-cols-2 md:grid-cols-3 gap-2 text-xs">
                  {savedReports.slice(0, 3).map((r) => (
                    <button
                      key={r.reportId}
                      onClick={() => {
                        setActiveReport(r);
                        setActiveTab("report");
                        window.scrollTo({ top: 0, behavior: "smooth" });
                      }}
                      className="flex items-center justify-between rounded-lg border border-[var(--rib)] bg-[var(--board-sunk)] p-2.5 text-right transition hover:border-[var(--royal-blue)]"
                    >
                      <div>
                        <div className="font-bold text-(color:--ink)">
                          {r.vehicle.make || "سيارة"} {r.vehicle.model || ""} ({r.vehicle.year || ""})
                        </div>
                        <div className="text-[10px] text-(color:--ink-3)">{r.generatedAt.slice(0, 10)}</div>
                      </div>
                      <span className="font-mono font-black text-amber-500">
                        {r.summary.overallHealthScore}%
                      </span>
                    </button>
                  ))}
                </div>
              </div>
            )}
          </div>
        )}

        {/* 2. Tab: Active Diagnostic Report */}
        {activeTab === "report" && (
          activeReport ? (
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
                  vin: activeReport.vehicle.vin ?? undefined,
                }}
              />
              <AssistantPanel report={activeReport} />
            </div>
          ) : (
            <div className="rounded-2xl border border-[var(--rib)] bg-[var(--cell)] p-12 text-center text-(color:--ink-2) shadow-sm space-y-4">
              <span className="text-4xl">📋</span>
              <h3 className="text-lg font-bold text-(color:--ink)">
                لم يتم فحص أو تحميل تقرير بعد
              </h3>
              <p className="text-xs max-w-md mx-auto text-(color:--ink-2) leading-relaxed">
                قم برفع ملف فحص (PDF / صورة) أو إدخال أكواد الأعطال، أو اختر فحصاً من السجل لعرض التقرير هنا.
              </p>
              <div className="flex justify-center gap-3 pt-2">
                <Button variant="primary" onClick={() => setActiveTab("scan")}>
                  ⚡ ابدأ فحصاً جديداً
                </Button>
                {savedReports.length > 0 && (
                  <Button onClick={() => setActiveTab("history")}>
                    🕒 فتح السجل
                  </Button>
                )}
              </div>
            </div>
          )
        )}

        {/* 3. Tab: DTC Encyclopedia & Basket */}
        {activeTab === "dtc" && (
          <DtcLookupView
            onGenerateReport={handleGenerateFromCodes}
            onOpenFuseMap={() => setFuseMapOpen(true)}
          />
        )}

        {/* 4. Tab: Report Comparison */}
        {activeTab === "compare" && (
          <ReportCompareView
            history={savedReports}
            initialBefore={savedReports[1]}
            initialAfter={savedReports[0]}
            onSelectReport={(r) => {
              setActiveReport(r);
              setActiveTab("report");
            }}
          />
        )}

        {/* 5. Tab: History Bank */}
        {activeTab === "history" && (
          <HistoryBank
            history={savedReports}
            onSelect={(r) => {
              setActiveReport(r);
              setActiveTab("report");
              window.scrollTo({ top: 0, behavior: "smooth" });
            }}
            onClear={() => removeLocal(HISTORY_KEY)}
          />
        )}
      </main>

      <footer className="border-t border-[var(--rib)] px-[var(--s4)] py-[var(--s4)]">
        <p className="mx-auto max-w-[1180px] k-label normal-case">
          كاشف يقرا تقرير جهاز الفحص ويترجمه. مش بديل عن كشف الفني على
          السيارة نفسها.
        </p>
      </footer>

      {settingsOpen && <SettingsPanel onClose={() => setSettingsOpen(false)} />}
      {dictionaryOpen && (
        <DictionaryPanel onClose={() => setDictionaryOpen(false)} />
      )}
      {dashboardLightsOpen && (
        <DashboardLightsPanel onClose={() => setDashboardLightsOpen(false)} />
      )}
      {fuseMapOpen && (
        <AuthenticFuseCardModal onClose={() => setFuseMapOpen(false)} />
      )}
    </div>
  );
}
