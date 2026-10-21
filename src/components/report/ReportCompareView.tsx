"use client";

import React, { useState, useMemo } from "react";
import { KashifDiagnosticReport, orUnknown } from "@/lib/types";
import {
  compareDiagnosticReports,
  generateComparisonShareableText,
  ReportComparisonResult,
} from "@/lib/report-comparison";
import { Button } from "@/components/ui/primitives";

interface ReportCompareViewProps {
  history: KashifDiagnosticReport[];
  initialBefore?: KashifDiagnosticReport | null;
  initialAfter?: KashifDiagnosticReport | null;
  onSelectReport?: (report: KashifDiagnosticReport) => void;
}

export function ReportCompareView({
  history,
  initialBefore,
  initialAfter,
  onSelectReport,
}: ReportCompareViewProps) {
  const [beforeReportId, setBeforeReportId] = useState<string>(
    initialBefore?.reportId || (history.length > 1 ? history[1].reportId : history[0]?.reportId || "")
  );
  const [afterReportId, setAfterReportId] = useState<string>(
    initialAfter?.reportId || history[0]?.reportId || ""
  );
  const [copied, setCopied] = useState(false);

  const beforeReport = useMemo(
    () => history.find((r) => r.reportId === beforeReportId) || null,
    [history, beforeReportId]
  );

  const afterReport = useMemo(
    () => history.find((r) => r.reportId === afterReportId) || null,
    [history, afterReportId]
  );

  const comparison: ReportComparisonResult | null = useMemo(() => {
    if (!beforeReport || !afterReport || beforeReport.reportId === afterReport.reportId) {
      return null;
    }
    return compareDiagnosticReports(beforeReport, afterReport);
  }, [beforeReport, afterReport]);

  const workshopName = typeof window !== "undefined" ? localStorage.getItem("kashif_workshop_name") || "" : "";

  const handleCopy = () => {
    if (!comparison) return;
    const txt = generateComparisonShareableText(comparison, workshopName);
    navigator.clipboard.writeText(txt);
    setCopied(true);
    setTimeout(() => setCopied(false), 2500);
  };

  const handleShareWhatsApp = () => {
    if (!comparison) return;
    const txt = generateComparisonShareableText(comparison, workshopName);
    window.open(`https://wa.me/?text=${encodeURIComponent(txt)}`, "_blank");
  };

  if (history.length < 2) {
    return (
      <div className="rounded-2xl border border-[var(--rib)] bg-[var(--cell)] p-12 text-center text-(color:--ink-2) shadow-sm">
        <span className="text-4xl">⚖️</span>
        <h3 className="mt-3 text-lg font-bold text-(color:--ink)">
          مقارنة الفحوصات (قبل وبعد الصيانة)
        </h3>
        <p className="mt-2 text-xs max-w-md mx-auto leading-relaxed">
          تحتاج إلى تقريرين مفحوصين على الأقل في السجل لإجراء مقارنة بين حالة السيارة قبل الصيانة وبعدها، واحتساب نسبة التحسن في الأعطال.
        </p>
      </div>
    );
  }

  return (
    <div className="space-y-[var(--s5)]">
      {/* Top Header & Report Pickers */}
      <div className="rounded-2xl border border-[var(--rib)] bg-[var(--cell)] p-5 shadow-sm space-y-4">
        <div className="flex flex-wrap items-center justify-between gap-3 border-b border-[var(--rib)] pb-3">
          <div className="flex items-center gap-2.5">
            <span className="flex h-8 w-8 items-center justify-center rounded-lg bg-[var(--royal-blue)] text-sm font-black text-white">
              ⚖️
            </span>
            <div>
              <h2 className="text-base font-bold text-(color:--ink)">
                مقارنة الفحوصات وإثبات الصيانة (Before & After)
              </h2>
              <p className="text-xs text-(color:--ink-2)">
                قارن بين فحصين للسيارة لقياس معدل إصلاح الأعطال ونسبة تحسن الجاهزية الفنية
              </p>
            </div>
          </div>

          {comparison && (
            <div className="flex items-center gap-2">
              <button
                type="button"
                onClick={handleCopy}
                className="inline-flex items-center gap-1.5 rounded-lg border border-[var(--rib)] bg-[var(--board-sunk)] px-3 py-1.5 text-xs font-bold text-(color:--ink) transition hover:bg-[var(--board)]"
              >
                <span>{copied ? "✓" : "📋"}</span>
                <span>{copied ? "تم نسخ الشهادة!" : "نسخ الشهادة"}</span>
              </button>
              <button
                type="button"
                onClick={handleShareWhatsApp}
                className="inline-flex items-center gap-1.5 rounded-lg border border-emerald-500/40 bg-emerald-500/15 px-3 py-1.5 text-xs font-bold text-emerald-400 transition hover:bg-emerald-500/25"
              >
                <span>💬</span>
                <span>مشاركة واتساب</span>
              </button>
            </div>
          )}
        </div>

        {/* Pickers Grid */}
        <div className="grid grid-cols-1 sm:grid-cols-2 gap-4">
          {/* Before Picker */}
          <div className="rounded-xl border border-amber-500/30 bg-amber-500/5 p-3.5 space-y-2">
            <div className="flex items-center justify-between">
              <label className="text-xs font-bold text-amber-500 flex items-center gap-1.5">
                <span>🕒</span>
                <span>فحص ما قبل الصيانة (الأولي):</span>
              </label>
              {beforeReport && (
                <span className="font-mono text-xs font-bold text-amber-500">
                  {beforeReport.summary.overallHealthScore}%
                </span>
              )}
            </div>
            <select
              value={beforeReportId}
              onChange={(e) => setBeforeReportId(e.target.value)}
              className="w-full rounded-lg border border-amber-500/40 bg-[var(--cell)] px-3 py-2 text-xs font-bold text-(color:--ink) outline-none focus:border-amber-500"
            >
              {history.map((r) => (
                <option key={r.reportId} value={r.reportId}>
                  {r.vehicle.make || "سيارة"} {r.vehicle.model || ""} — {r.summary.overallHealthScore}% ({r.generatedAt.slice(0, 10)})
                </option>
              ))}
            </select>
          </div>

          {/* After Picker */}
          <div className="rounded-xl border border-emerald-500/30 bg-emerald-500/5 p-3.5 space-y-2">
            <div className="flex items-center justify-between">
              <label className="text-xs font-bold text-emerald-500 flex items-center gap-1.5">
                <span>✅</span>
                <span>فحص ما بعد الصيانة (الحالي):</span>
              </label>
              {afterReport && (
                <span className="font-mono text-xs font-bold text-emerald-500">
                  {afterReport.summary.overallHealthScore}%
                </span>
              )}
            </div>
            <select
              value={afterReportId}
              onChange={(e) => setAfterReportId(e.target.value)}
              className="w-full rounded-lg border border-emerald-500/40 bg-[var(--cell)] px-3 py-2 text-xs font-bold text-(color:--ink) outline-none focus:border-emerald-500"
            >
              {history.map((r) => (
                <option key={r.reportId} value={r.reportId}>
                  {r.vehicle.make || "سيارة"} {r.vehicle.model || ""} — {r.summary.overallHealthScore}% ({r.generatedAt.slice(0, 10)})
                </option>
              ))}
            </select>
          </div>
        </div>
      </div>

      {/* Same Report Selected Warning */}
      {beforeReportId === afterReportId && (
        <div className="rounded-xl border border-amber-500/40 bg-amber-500/10 p-4 text-center text-xs text-amber-500 font-bold">
          ⚠️ يرجى اختيار تقريرين مختلفين للمقارنة بينهما.
        </div>
      )}

      {/* Comparison Results Dashboard */}
      {comparison && (
        <div className="space-y-[var(--s4)]">
          {/* Executive Delta Card */}
          <div className="rounded-2xl border border-[var(--rib)] bg-[var(--cell)] p-6 shadow-md">
            <div className="flex flex-wrap items-center justify-between gap-4">
              <div>
                <span className="text-xs font-semibold text-(color:--ink-3)">المركبة المقارنة:</span>
                <h3 className="text-lg font-black text-(color:--ink)">
                  {orUnknown(comparison.afterReport.vehicle.make, "سيارة")}{" "}
                  {orUnknown(comparison.afterReport.vehicle.model, "")} (
                  {orUnknown(comparison.afterReport.vehicle.year, "")})
                </h3>
                {comparison.afterReport.vehicle.vin && (
                  <p className="font-mono text-xs text-(color:--ink-2)">
                    VIN: {comparison.afterReport.vehicle.vin}
                  </p>
                )}
              </div>

              {/* Score Progress Comparison */}
              <div className="flex items-center gap-4">
                <div className="text-center">
                  <div className="font-mono text-2xl font-black text-amber-500">
                    {comparison.healthScoreBefore}%
                  </div>
                  <span className="text-[10px] text-(color:--ink-3)">قبل الصيانة</span>
                </div>

                <div className="text-xl text-(color:--ink-3)">➔</div>

                <div className="text-center">
                  <div className="font-mono text-2xl font-black text-emerald-500">
                    {comparison.healthScoreAfter}%
                  </div>
                  <span className="text-[10px] text-(color:--ink-3)">بعد الصيانة</span>
                </div>

                <div className="border-r border-[var(--rib)] pr-4">
                  <span
                    className={`inline-block rounded-xl px-3.5 py-1.5 font-mono text-sm font-black shadow-sm ${
                      comparison.healthScoreDiff > 0
                        ? "bg-emerald-500 text-white"
                        : comparison.healthScoreDiff < 0
                        ? "bg-red-500 text-white"
                        : "bg-slate-700 text-white"
                    }`}
                  >
                    {comparison.improvementBadge}
                  </span>
                </div>
              </div>
            </div>
          </div>

          {/* Three Categorized Fault Columns */}
          <div className="grid grid-cols-1 gap-4 lg:grid-cols-3">
            {/* 1. Resolved Faults */}
            <div className="rounded-xl border border-emerald-500/30 bg-emerald-500/5 p-4 space-y-3">
              <div className="flex items-center justify-between border-b border-emerald-500/20 pb-2">
                <div className="flex items-center gap-1.5">
                  <span className="text-emerald-500 font-bold">✓</span>
                  <h4 className="text-xs font-bold text-emerald-500">
                    أعطال تم إصلاحها بنجاح
                  </h4>
                </div>
                <span className="rounded-full bg-emerald-500/20 px-2 py-0.5 font-mono text-xs font-bold text-emerald-400">
                  {comparison.resolvedFaults.length}
                </span>
              </div>

              {comparison.resolvedFaults.length === 0 ? (
                <p className="text-xs text-(color:--ink-3) py-4 text-center">
                  لا توجد أعطال تم إصلاحها بين هذين الفحصين
                </p>
              ) : (
                <div className="space-y-2">
                  {comparison.resolvedFaults.map((f) => (
                    <div
                      key={f.code}
                      className="rounded-lg border border-emerald-500/20 bg-[var(--cell)] p-2.5 text-xs shadow-xs"
                    >
                      <div className="flex items-center justify-between">
                        <span className="rounded bg-emerald-500/20 px-2 py-0.5 font-mono font-black text-emerald-400">
                          {f.code}
                        </span>
                        <span className="text-[10px] text-(color:--ink-3)">{f.module}</span>
                      </div>
                      <p className="mt-1 font-bold text-(color:--ink)">{f.libyanTerm}</p>
                      <p className="text-[11px] text-(color:--ink-2) mt-0.5">
                        {f.standardArabicDescription}
                      </p>
                    </div>
                  ))}
                </div>
              )}
            </div>

            {/* 2. Persistent Faults */}
            <div className="rounded-xl border border-amber-500/30 bg-amber-500/5 p-4 space-y-3">
              <div className="flex items-center justify-between border-b border-amber-500/20 pb-2">
                <div className="flex items-center gap-1.5">
                  <span className="text-amber-500 font-bold">⚠️</span>
                  <h4 className="text-xs font-bold text-amber-500">
                    أعطال مستمرة لا تزال قائمة
                  </h4>
                </div>
                <span className="rounded-full bg-amber-500/20 px-2 py-0.5 font-mono text-xs font-bold text-amber-400">
                  {comparison.persistentFaults.length}
                </span>
              </div>

              {comparison.persistentFaults.length === 0 ? (
                <p className="text-xs text-(color:--ink-3) py-4 text-center">
                  لا توجد أعطال مستمرة — تم حل جميع الأعطال القديمة!
                </p>
              ) : (
                <div className="space-y-2">
                  {comparison.persistentFaults.map((f) => (
                    <div
                      key={f.code}
                      className="rounded-lg border border-amber-500/20 bg-[var(--cell)] p-2.5 text-xs shadow-xs"
                    >
                      <div className="flex items-center justify-between">
                        <span className="rounded bg-amber-500/20 px-2 py-0.5 font-mono font-black text-amber-400">
                          {f.code}
                        </span>
                        <span className="text-[10px] text-(color:--ink-3)">{f.module}</span>
                      </div>
                      <p className="mt-1 font-bold text-(color:--ink)">{f.libyanTerm}</p>
                      <p className="text-[11px] text-(color:--ink-2) mt-0.5">
                        {f.standardArabicDescription}
                      </p>
                    </div>
                  ))}
                </div>
              )}
            </div>

            {/* 3. New Faults */}
            <div className="rounded-xl border border-red-500/30 bg-red-500/5 p-4 space-y-3">
              <div className="flex items-center justify-between border-b border-red-500/20 pb-2">
                <div className="flex items-center gap-1.5">
                  <span className="text-red-500 font-bold">🔴</span>
                  <h4 className="text-xs font-bold text-red-500">
                    أعطال جديدة ظهرت بالفحص
                  </h4>
                </div>
                <span className="rounded-full bg-red-500/20 px-2 py-0.5 font-mono text-xs font-bold text-red-400">
                  {comparison.newFaults.length}
                </span>
              </div>

              {comparison.newFaults.length === 0 ? (
                <p className="text-xs text-(color:--ink-3) py-4 text-center">
                  لا توجد أعطال جديدة ظهرت
                </p>
              ) : (
                <div className="space-y-2">
                  {comparison.newFaults.map((f) => (
                    <div
                      key={f.code}
                      className="rounded-lg border border-red-500/20 bg-[var(--cell)] p-2.5 text-xs shadow-xs"
                    >
                      <div className="flex items-center justify-between">
                        <span className="rounded bg-red-500/20 px-2 py-0.5 font-mono font-black text-red-400">
                          {f.code}
                        </span>
                        <span className="text-[10px] text-(color:--ink-3)">{f.module}</span>
                      </div>
                      <p className="mt-1 font-bold text-(color:--ink)">{f.libyanTerm}</p>
                      <p className="text-[11px] text-(color:--ink-2) mt-0.5">
                        {f.standardArabicDescription}
                      </p>
                    </div>
                  ))}
                </div>
              )}
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
