"use client";

import React, { useState, useEffect } from "react";
import { Header } from "@/components/Header";
import { UploadDropzone } from "@/components/UploadDropzone";
import { VehicleHealthCard } from "@/components/VehicleHealthCard";
import { FaultPriorityMatrix } from "@/components/FaultPriorityMatrix";
import { SparePartsSection } from "@/components/SparePartsSection";
import { DiagnosticChecklist } from "@/components/DiagnosticChecklist";
import { MechanicChatAssistant } from "@/components/MechanicChatAssistant";
import { ExportActionBar } from "@/components/ExportActionBar";
import { InspectionHistory } from "@/components/InspectionHistory";
import { KashifDiagnosticReport } from "@/lib/types";
import {
  Wrench,
  ShieldCheck,
  Zap,
  BookOpen,
  Cpu,
  CheckCircle2,
} from "lucide-react";

export default function HomePage() {
  const [activeReport, setActiveReport] = useState<KashifDiagnosticReport | null>(null);
  const [isLoading, setIsLoading] = useState(false);
  const [savedReports, setSavedReports] = useState<KashifDiagnosticReport[]>([]);
  const [selectedPartId, setSelectedPartId] = useState<string | undefined>(undefined);

  // Load history from LocalStorage
  useEffect(() => {
    try {
      const stored = localStorage.getItem("kashif_saved_reports");
      if (stored) {
        const parsed = JSON.parse(stored);
        if (Array.isArray(parsed)) {
          const safe = parsed
            .filter((p) => p && typeof p === "object")
            .map((p) => ({
              ...p,
              vehicle: p.vehicle || { make: "مركبة مفحوصة", model: "", year: "" },
              summary: p.summary || { overallHealthScore: 70, severityStatus: "متوسط / انتبه" },
              faultCategories: p.faultCategories || { criticalFaults: [], moderateFaults: [], minorOrHistoricalFaults: [] },
              passedSystems: p.passedSystems || [],
              sparePartsRequired: p.sparePartsRequired || [],
              workshopChecklist: p.workshopChecklist || [],
            }));
          setSavedReports(safe);
        }
      }
    } catch (e) {
      console.error("Failed to load local reports:", e);
    }
  }, []);

  // Save new report to state & LocalStorage
  const handleReportGenerated = (report: KashifDiagnosticReport) => {
    setActiveReport(report);
    window.scrollTo({ top: 0, behavior: "smooth" });

    // Persist to local history
    setSavedReports((prev) => {
      const filtered = prev.filter((r) => r.reportId !== report.reportId);
      const updated = [report, ...filtered].slice(0, 15);
      try {
        localStorage.setItem("kashif_saved_reports", JSON.stringify(updated));
      } catch (err) {}
      return updated;
    });
  };

  const handleClearHistory = () => {
    setSavedReports([]);
    try {
      localStorage.removeItem("kashif_saved_reports");
    } catch (e) {}
  };

  const handleSelectPart = (partId?: string) => {
    if (partId) {
      setSelectedPartId(partId);
      const el = document.getElementById(partId);
      if (el) {
        el.scrollIntoView({ behavior: "smooth", block: "center" });
      } else {
        const section = document.getElementById("spare-parts-section");
        section?.scrollIntoView({ behavior: "smooth" });
      }
    }
  };

  return (
    <div className="min-h-screen bg-[#090D16] text-slate-100 flex flex-col justify-between selection:bg-blue-600/30 selection:text-white">
      {/* Top Navigation Bar */}
      <Header
        hasActiveReport={!!activeReport}
        onNewScanClick={() => {
          setActiveReport(null);
          setSelectedPartId(undefined);
          window.scrollTo({ top: 0, behavior: "smooth" });
        }}
      />

      {/* Main Content Workbench */}
      <main className="flex-1 max-w-7xl w-full mx-auto px-4 sm:px-6 lg:px-8 py-6 space-y-6">
        {!activeReport ? (
          /* ================= Landing & Ingestion Screen ================= */
          <div className="space-y-8">
            {/* Hero Section */}
            <div className="text-center space-y-3 max-w-3xl mx-auto pt-4 sm:pt-6">
              <div className="inline-flex items-center gap-2 bg-blue-950/60 border border-blue-800/60 text-blue-300 px-3.5 py-1 rounded-full text-xs font-semibold">
                <Cpu className="w-3.5 h-3.5 text-blue-400" />
                <span>نظام التشخيص الفني واستخراج أكواد الأعطال الرقمية</span>
              </div>

              <h1 className="text-2xl sm:text-4xl font-bold text-white tracking-tight font-heading leading-tight">
                تحليل تقارير أجهزة فحص السيارات
                <span className="block text-slate-300 text-xl sm:text-2xl font-normal mt-1">
                  بالمصطلحات الفنية المعتمدة في ورش الصيانة الليبية
                </span>
              </h1>

              <p className="text-sm text-slate-400 max-w-2xl mx-auto leading-relaxed">
                ارفع تقارير الفحص من أجهزة (Launch X431, Autel, Ediag) كملف PDF أو صورة شاشة لاستخراج منظومات الأعطال، الأسباب الجذرية، أرقام قطع الـ OEM الأصلية، وخطوات الفحص الميداني.
              </p>
            </div>

            {/* Ingestion Dropzone Hub */}
            <UploadDropzone
              isLoading={isLoading}
              setIsLoading={setIsLoading}
              onReportGenerated={handleReportGenerated}
            />

            {/* Core Capabilities Bar */}
            <div className="grid grid-cols-1 md:grid-cols-3 gap-3.5 max-w-4xl mx-auto pt-2">
              <div className="workbench-panel p-4 rounded-xl flex items-start gap-3">
                <div className="p-2 bg-slate-800 text-blue-400 rounded-lg shrink-0">
                  <ShieldCheck className="w-4 h-4" />
                </div>
                <div>
                  <h4 className="text-xs font-bold text-white mb-0.5 font-heading">
                    قاموس المصطلحات الميدانية
                  </h4>
                  <p className="text-xs text-slate-400 leading-relaxed">
                    مطابقة مصطلحات الورش الحقيقية (بوبينات، مزاطوري، شمعات، بيانتو) لتسهيل التواصل مع العميل.
                  </p>
                </div>
              </div>

              <div className="workbench-panel p-4 rounded-xl flex items-start gap-3">
                <div className="p-2 bg-slate-800 text-blue-400 rounded-lg shrink-0">
                  <Zap className="w-4 h-4" />
                </div>
                <div>
                  <h4 className="text-xs font-bold text-white mb-0.5 font-heading">
                    أرقام قطع الـ OEM والبدائل
                  </h4>
                  <p className="text-xs text-slate-400 leading-relaxed">
                    توليد أرقام الوكالة الأصلية وبدائل الشركات العالمية المعتمدة مع أسعار السوق المحلي.
                  </p>
                </div>
              </div>

              <div className="workbench-panel p-4 rounded-xl flex items-start gap-3">
                <div className="p-2 bg-slate-800 text-blue-400 rounded-lg shrink-0">
                  <CheckCircle2 className="w-4 h-4" />
                </div>
                <div>
                  <h4 className="text-xs font-bold text-white mb-0.5 font-heading">
                    قائمة فحص الأسطى التسلسلية
                  </h4>
                  <p className="text-xs text-slate-400 leading-relaxed">
                    خطوات فحص كهربائية وميكانيكية تسلسلية للورشة قبل الشراء لتفادي التبديل العشوائي.
                  </p>
                </div>
              </div>
            </div>

            {/* Saved Local Inspections History */}
            <InspectionHistory
              history={savedReports}
              onSelectReport={(r) => {
                setActiveReport(r);
                window.scrollTo({ top: 0, behavior: "smooth" });
              }}
              onClearHistory={handleClearHistory}
            />
          </div>
        ) : (
          /* ================= Active Report Dashboard ================= */
          <div className="space-y-6 animate-in fade-in duration-200">
            {/* Export and Actions Bar */}
            <ExportActionBar report={activeReport} />

            {/* Vehicle Profile & Health Overview */}
            <VehicleHealthCard report={activeReport} />

            {/* Priority Faults Matrix */}
            <FaultPriorityMatrix
              report={activeReport}
              onSelectPart={handleSelectPart}
            />

            {/* Diagnostic Workshop Checklist */}
            <DiagnosticChecklist steps={activeReport.workshopChecklist} />

            {/* Spare Parts & OEM Numbers Directory */}
            <SparePartsSection
              spareParts={activeReport.sparePartsRequired}
              selectedPartId={selectedPartId}
              vehicleInfo={activeReport.vehicle}
            />

            {/* Floating AI Mechanic Assistant Chat */}
            <MechanicChatAssistant report={activeReport} />
          </div>
        )}
      </main>

      {/* Workbench Footer */}
      <footer className="w-full border-t border-slate-800/80 bg-[#070B12] mt-12 py-4 no-print">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 flex flex-col sm:flex-row items-center justify-between gap-3 text-xs text-slate-400">
          <div className="flex items-center gap-2">
            <Wrench className="w-3.5 h-3.5 text-blue-400" />
            <span className="font-semibold text-slate-200">كاشف AI</span>
            <span>— منصة التشخيص الفني للسيارات المخصصة لليبيا</span>
          </div>
          <p className="text-slate-400 font-mono text-[11px]">
            محرك التحليل الذكي وقاموس ورش الصيانة الليبية المعتمدة
          </p>
        </div>
      </footer>
    </div>
  );
}
