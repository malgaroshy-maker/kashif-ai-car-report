"use client";

import React, { useState } from "react";
import Link from "next/link";
import {
  Bell,
  Cpu,
  FileText,
  Wrench,
  Calendar,
  AlertTriangle,
  Home,
  MapPin,
  User,
  Gauge,
  Car,
  CheckCircle2,
  Camera,
  Layers,
  Search,
  BookOpen,
  Settings,
  Sparkles,
} from "lucide-react";
import { Intake } from "@/components/report/Intake";
import { FaultBoard } from "@/components/report/FaultBoard";
import { Checklist } from "@/components/report/Checklist";
import { PartsBank } from "@/components/report/PartsBank";
import { HistoryBank } from "@/components/report/HistoryBank";
import { SettingsPanel } from "@/components/report/SettingsPanel";
import { DictionaryPanel } from "@/components/report/DictionaryPanel";
import { AssistantPanel } from "@/components/report/AssistantPanel";
import { KashifDiagnosticReport } from "@/lib/types";
import { removeLocal, useLocalJson, writeLocal } from "@/lib/local-store";

const HISTORY_KEY = "kashif_saved_reports";
const EMPTY_HISTORY: KashifDiagnosticReport[] = [];
const HISTORY_LIMIT = 15;

function isUsableStoredReport(value: unknown): value is KashifDiagnosticReport {
  if (!value || typeof value !== "object") return false;
  const r = value as Partial<KashifDiagnosticReport>;
  return (
    typeof r.reportId === "string" &&
    !!r.vehicle &&
    !!r.summary &&
    typeof r.summary.overallHealthScore === "number" &&
    !!r.faultCategories
  );
}

function readHistory(value: unknown): KashifDiagnosticReport[] | null {
  if (!Array.isArray(value)) return null;
  return value.filter(isUsableStoredReport);
}

export default function MobileAppScreen() {
  const [activeTab, setActiveTab] = useState<"home" | "faults" | "map" | "profile">("home");
  const [activeReport, setActiveReport] = useState<KashifDiagnosticReport | null>(null);
  const [isLoading, setIsLoading] = useState(false);
  const [showScanModal, setShowScanModal] = useState(false);
  const [settingsOpen, setSettingsOpen] = useState(false);
  const [dictionaryOpen, setDictionaryOpen] = useState(false);
  const [assistantOpen, setAssistantOpen] = useState(false);

  const savedReports = useLocalJson<KashifDiagnosticReport[]>(
    HISTORY_KEY,
    readHistory,
    EMPTY_HISTORY
  );

  const handleReportGenerated = (report: KashifDiagnosticReport) => {
    setActiveReport(report);
    setShowScanModal(false);
    setActiveTab("faults");
    const filtered = savedReports.filter((r) => r.reportId !== report.reportId);
    writeLocal(
      HISTORY_KEY,
      JSON.stringify([report, ...filtered].slice(0, HISTORY_LIMIT))
    );
  };

  const healthScore = activeReport ? activeReport.summary.overallHealthScore : 65;

  return (
    <div className="flex min-h-dvh flex-col bg-[#071321] text-slate-100 font-sans selection:bg-amber-500 selection:text-black">
      {/* Mobile App Container (Centered on desktop, full width on mobile) */}
      <div className="mx-auto w-full max-w-md flex-1 flex flex-col shadow-2xl relative border-x border-slate-800/60 pb-20">
        
        {/* Top App Bar */}
        <header className="sticky top-0 z-30 flex items-center justify-between px-4 py-3 bg-[#0a192f]/95 backdrop-blur-md border-b border-slate-800/80">
          <button 
            type="button" 
            onClick={() => setAssistantOpen(true)}
            className="p-2 rounded-full hover:bg-slate-800 transition text-amber-400 relative"
            title="المساعد الذكي"
          >
            <Sparkles className="w-5 h-5" />
          </button>

          <div className="flex items-center gap-2">
            <span className="font-bold text-lg text-slate-100">فحص الرئيسية</span>
            <div className="w-7 h-7 rounded-full bg-gradient-to-tr from-amber-500 to-yellow-300 flex items-center justify-center shadow-md">
              <CheckCircle2 className="w-4 h-4 text-slate-950 font-black" />
            </div>
          </div>

          <button 
            type="button" 
            onClick={() => setSettingsOpen(true)}
            className="p-2 rounded-full hover:bg-slate-800 transition text-slate-300 relative"
            title="الإعدادات والتنبيهات"
          >
            <Bell className="w-5 h-5" />
            <span className="absolute top-1 right-1 w-2 h-2 rounded-full bg-amber-500 ring-2 ring-[#0a192f]" />
          </button>
        </header>

        {/* Dynamic Content Based on Active Tab */}
        <main className="flex-1 p-4 space-y-4">
          {activeTab === "home" && (
            <>
              {/* Central Speedometer Gauge Card */}
              <div className="relative rounded-2xl bg-gradient-to-b from-[#0c223c] to-[#0a192f] p-6 border border-cyan-500/20 shadow-lg text-center overflow-hidden">
                <div className="absolute inset-0 opacity-10 pointer-events-none bg-[radial-gradient(#38bdf8_1px,transparent_1px)] [background-size:16px_16px]" />
                
                {/* Gauge visualization */}
                <div className="relative mx-auto w-44 h-44 flex items-center justify-center">
                  <svg className="w-full h-full -rotate-90 transform" viewBox="0 0 100 100">
                    <circle
                      cx="50"
                      cy="50"
                      r="40"
                      className="stroke-slate-800/80"
                      strokeWidth="9"
                      fill="transparent"
                    />
                    <circle
                      cx="50"
                      cy="50"
                      r="40"
                      className="stroke-cyan-400 transition-all duration-1000 ease-out"
                      strokeWidth="9"
                      strokeDasharray={251.2}
                      strokeDashoffset={251.2 * (1 - (healthScore / 100) * 0.75)}
                      strokeLinecap="round"
                      fill="transparent"
                    />
                  </svg>
                  
                  {/* Gauge Center Text */}
                  <div className="absolute flex flex-col items-center justify-center">
                    <Gauge className="w-7 h-7 text-cyan-400 mb-1 animate-pulse" />
                    <span className="text-3xl font-extrabold tracking-tight text-white">
                      {healthScore}%
                    </span>
                    <span className="text-xs text-cyan-200/80 mt-0.5">
                      {activeReport ? "درجة سلامة السيارة" : "فحص كامل - متصل"}
                    </span>
                  </div>
                </div>

                <div className="mt-2 space-y-1">
                  <h2 className="text-sm font-semibold text-cyan-300">
                    {activeReport 
                      ? `${activeReport.vehicle.make || "سيارة"} ${activeReport.vehicle.model || ""} (${activeReport.vehicle.year || ""})`
                      : "فحص كامل - جاهز للتشخيص"}
                  </h2>
                  <p className="text-xs text-slate-400">
                    {activeReport 
                      ? `تم رصد ${activeReport.faultCategories.criticalFaults.length} أعطال خطيرة و ${activeReport.faultCategories.moderateFaults.length} متوسطة`
                      : "اربط جهاز OBD-II أو ارفع صورة تقرير الكشف للبدء"}
                  </p>
                </div>
              </div>

              {/* Banner: "فحص الكمبيوتر" */}
              <button
                type="button"
                onClick={() => setShowScanModal(true)}
                className="w-full rounded-xl bg-gradient-to-r from-blue-700 via-indigo-700 to-blue-900 p-4 text-right flex items-center justify-between shadow-md hover:brightness-110 active:scale-[0.99] transition border border-blue-400/30"
              >
                <div className="w-12 h-12 rounded-lg bg-blue-500/20 border border-blue-400/30 flex items-center justify-center text-blue-200">
                  <Cpu className="w-6 h-6" />
                </div>
                <div className="flex-1 pr-3">
                  <div className="flex items-center gap-1.5 justify-end">
                    <span className="w-2 h-2 rounded-full bg-emerald-400 animate-ping" />
                    <span className="text-xs text-blue-200">خدمات الكشف الذكي</span>
                  </div>
                  <h3 className="font-bold text-base text-white">فحص الكمبيوتر وقراءة الأعطال</h3>
                  <p className="text-xs text-blue-200/80">رفع صورة الفحص أو ملف PDF أو كتابة الأكواد</p>
                </div>
              </button>

              {/* Quick Actions Grid (4 Tiles) */}
              <div className="grid grid-cols-2 gap-3">
                {/* 1: تقارير الأعطال */}
                <button
                  type="button"
                  onClick={() => setActiveTab("faults")}
                  className="rounded-xl bg-[#0e2137] p-4 text-center border border-slate-700/60 hover:border-cyan-500/40 hover:bg-[#132d4b] transition flex flex-col items-center justify-center gap-2 group"
                >
                  <div className="w-11 h-11 rounded-lg bg-blue-500/10 border border-blue-500/30 flex items-center justify-center text-blue-400 group-hover:scale-110 transition">
                    <FileText className="w-6 h-6" />
                  </div>
                  <span className="font-semibold text-sm text-slate-200">تقارير الأعطال</span>
                  <span className="text-[11px] text-slate-400">
                    {activeReport ? `${activeReport.faultCategories.criticalFaults.length + activeReport.faultCategories.moderateFaults.length} عطل مسجل` : "السجلات والنتائج"}
                  </span>
                </button>

                {/* 2: قطع الغيار */}
                <button
                  type="button"
                  onClick={() => {
                    if (activeReport) {
                      setActiveTab("faults");
                      setTimeout(() => {
                        document.getElementById("mobile-parts-section")?.scrollIntoView({ behavior: "smooth" });
                      }, 200);
                    } else {
                      setShowScanModal(true);
                    }
                  }}
                  className="rounded-xl bg-[#0e2137] p-4 text-center border border-slate-700/60 hover:border-cyan-500/40 hover:bg-[#132d4b] transition flex flex-col items-center justify-center gap-2 group"
                >
                  <div className="w-11 h-11 rounded-lg bg-emerald-500/10 border border-emerald-500/30 flex items-center justify-center text-emerald-400 group-hover:scale-110 transition">
                    <Wrench className="w-6 h-6" />
                  </div>
                  <span className="font-semibold text-sm text-slate-200">قطع الغيار</span>
                  <span className="text-[11px] text-slate-400">
                    {activeReport ? `${activeReport.sparePartsRequired.length} قطعة مطلوبة` : "أرقام وتكلفة القطع"}
                  </span>
                </button>

                {/* 3: حجز موعد / فحص الورشة */}
                <button
                  type="button"
                  onClick={() => {
                    if (activeReport) {
                      setActiveTab("faults");
                      setTimeout(() => {
                        document.getElementById("mobile-checklist-section")?.scrollIntoView({ behavior: "smooth" });
                      }, 200);
                    } else {
                      alert("قم بعمل فحص أولاً لعرض خطوات وتوصيات فحص الورشة.");
                    }
                  }}
                  className="rounded-xl bg-[#0e2137] p-4 text-center border border-slate-700/60 hover:border-amber-500/40 hover:bg-[#132d4b] transition flex flex-col items-center justify-center gap-2 group"
                >
                  <div className="w-11 h-11 rounded-lg bg-amber-500/10 border border-amber-500/30 flex items-center justify-center text-amber-400 group-hover:scale-110 transition">
                    <Calendar className="w-6 h-6" />
                  </div>
                  <span className="font-semibold text-sm text-slate-200">حجز موعد وفحص</span>
                  <span className="text-[11px] text-slate-400">خطوات فحص الأسطى</span>
                </button>

                {/* 4: تنبيهات وقاموس الورش */}
                <button
                  type="button"
                  onClick={() => setDictionaryOpen(true)}
                  className="rounded-xl bg-[#0e2137] p-4 text-center border border-slate-700/60 hover:border-yellow-500/40 hover:bg-[#132d4b] transition flex flex-col items-center justify-center gap-2 group"
                >
                  <div className="w-11 h-11 rounded-lg bg-yellow-500/10 border border-yellow-500/30 flex items-center justify-center text-yellow-400 group-hover:scale-110 transition">
                    <BookOpen className="w-6 h-6" />
                  </div>
                  <span className="font-semibold text-sm text-slate-200">قاموس الورش</span>
                  <span className="text-[11px] text-slate-400">مصطلحات الصيانة</span>
                </button>
              </div>

              {/* Stored Reports History Preview */}
              {savedReports.length > 0 && (
                <div className="pt-2">
                  <div className="flex items-center justify-between mb-2">
                    <button 
                      type="button" 
                      onClick={() => removeLocal(HISTORY_KEY)}
                      className="text-xs text-rose-400 hover:underline"
                    >
                      مسح السجل
                    </button>
                    <h4 className="text-xs font-bold uppercase tracking-wider text-slate-400">الفحوصات السابقة</h4>
                  </div>
                  <div className="space-y-2">
                    {savedReports.slice(0, 3).map((rep) => (
                      <button
                        type="button"
                        key={rep.reportId}
                        onClick={() => {
                          setActiveReport(rep);
                          setActiveTab("faults");
                        }}
                        className="w-full text-right p-3 rounded-lg bg-[#0a192f] border border-slate-800 hover:border-slate-700 flex items-center justify-between text-xs"
                      >
                        <span className="font-mono px-2 py-0.5 rounded bg-blue-950 text-cyan-300 font-bold">
                          {rep.summary.overallHealthScore}%
                        </span>
                        <div>
                          <div className="font-bold text-slate-200">
                            {rep.vehicle.make} {rep.vehicle.model} {rep.vehicle.year}
                          </div>
                          <div className="text-[11px] text-slate-400">
                            {new Date(rep.generatedAt).toLocaleDateString("ar-LY")}
                          </div>
                        </div>
                      </button>
                    ))}
                  </div>
                </div>
              )}
            </>
          )}

          {/* Faults Tab */}
          {activeTab === "faults" && (
            <div className="space-y-4">
              {activeReport ? (
                <>
                  <div className="p-3 bg-[#0d2139] rounded-xl border border-cyan-500/30 flex items-center justify-between">
                    <button
                      type="button"
                      onClick={() => setShowScanModal(true)}
                      className="text-xs bg-cyan-600 hover:bg-cyan-500 text-white px-3 py-1.5 rounded-lg font-bold"
                    >
                      فحص جديد
                    </button>
                    <div>
                      <div className="font-bold text-sm text-cyan-200">
                        {activeReport.vehicle.make} {activeReport.vehicle.model}
                      </div>
                      <div className="text-xs text-slate-400">
                        درجة الصحة: {activeReport.summary.overallHealthScore}%
                      </div>
                    </div>
                  </div>

                  <FaultBoard report={activeReport} onSelectPart={() => {}} />
                  
                  <div id="mobile-checklist-section">
                    <Checklist steps={activeReport.workshopChecklist} />
                  </div>

                  <div id="mobile-parts-section">
                    <PartsBank
                      parts={activeReport.sparePartsRequired}
                      vehicle={{
                        make: activeReport.vehicle.make ?? undefined,
                        model: activeReport.vehicle.model ?? undefined,
                        year: activeReport.vehicle.year ?? undefined,
                      }}
                    />
                  </div>
                </>
              ) : (
                <div className="text-center py-12 space-y-3">
                  <FileText className="w-12 h-12 text-slate-600 mx-auto" />
                  <p className="text-slate-400 text-sm">لا يوجد فحص نشط حالياً</p>
                  <button
                    type="button"
                    onClick={() => setShowScanModal(true)}
                    className="px-4 py-2 rounded-lg bg-cyan-600 text-white font-bold text-sm"
                  >
                    ابدأ فحص الكمبيوتر الآن
                  </button>
                </div>
              )}
            </div>
          )}

          {/* Map Tab */}
          {activeTab === "map" && (
            <div className="text-center py-10 space-y-4">
              <div className="w-16 h-16 rounded-full bg-blue-500/10 border border-blue-500/20 mx-auto flex items-center justify-center text-cyan-400">
                <MapPin className="w-8 h-8" />
              </div>
              <h3 className="font-bold text-base text-slate-200">ورش كشف الكمبيوتر المعتمدة</h3>
              <p className="text-xs text-slate-400 max-w-xs mx-auto leading-relaxed">
                قريباً: خريطة تفاعلية لأفضل مراكز فحص السيارات بأجهزة الكمبيوتر (Launch, Autel, Bosch) ومحلات قطع الغيار في ليبيا.
              </p>
            </div>
          )}

          {/* Profile Tab */}
          {activeTab === "profile" && (
            <div className="space-y-4">
              <div className="p-4 rounded-xl bg-[#0c223c] border border-slate-700/60 flex items-center gap-3">
                <div className="w-12 h-12 rounded-full bg-gradient-to-tr from-cyan-500 to-blue-600 flex items-center justify-center font-bold text-lg text-white">
                  ك
                </div>
                <div>
                  <h3 className="font-bold text-slate-100">كاشف AI - فاحص السيارات</h3>
                  <p className="text-xs text-cyan-400">نسخة تطبيق أندرويد (Mobile PWA / Native)</p>
                </div>
              </div>

              <div className="space-y-2">
                <button
                  type="button"
                  onClick={() => setSettingsOpen(true)}
                  className="w-full text-right p-3 rounded-lg bg-[#0e2137] border border-slate-800 flex items-center justify-between text-sm hover:bg-[#132d4b]"
                >
                  <Settings className="w-5 h-5 text-slate-400" />
                  <span>إعدادات مفتاح الذكاء الاصطناعي (Gemini API)</span>
                </button>
                <button
                  type="button"
                  onClick={() => setDictionaryOpen(true)}
                  className="w-full text-right p-3 rounded-lg bg-[#0e2137] border border-slate-800 flex items-center justify-between text-sm hover:bg-[#132d4b]"
                >
                  <BookOpen className="w-5 h-5 text-slate-400" />
                  <span>قاموس مصطلحات صيانة السيارات الليبية</span>
                </button>
                <Link
                  href="/"
                  className="w-full text-right p-3 rounded-lg bg-[#0e2137] border border-slate-800 flex items-center justify-between text-sm hover:bg-[#132d4b] text-cyan-300 block"
                >
                  <Car className="w-5 h-5 text-cyan-400" />
                  <span>التبديل إلى واجهة سطح المكتب (الموقع الكامل)</span>
                </Link>
              </div>
            </div>
          )}
        </main>

        {/* Scan Modal Dialog */}
        {showScanModal && (
          <div className="fixed inset-0 z-50 bg-black/80 backdrop-blur-sm flex items-center justify-center p-4">
            <div className="w-full max-w-lg bg-[#0a192f] border border-cyan-500/30 rounded-2xl p-4 max-h-[90vh] overflow-y-auto">
              <div className="flex items-center justify-between pb-3 border-b border-slate-800 mb-3">
                <button
                  type="button"
                  onClick={() => setShowScanModal(false)}
                  className="text-xs px-2.5 py-1 rounded bg-slate-800 text-slate-300 hover:bg-slate-700"
                >
                  إغلاق
                </button>
                <h3 className="font-bold text-sm text-cyan-300">رفع أو إدخال تقرير الفحص</h3>
              </div>
              <Intake
                busy={isLoading}
                setBusy={setIsLoading}
                onReport={handleReportGenerated}
              />
            </div>
          </div>
        )}

        {/* Bottom Navigation Bar */}
        <nav className="fixed bottom-0 left-0 right-0 z-40 bg-[#0a192f]/95 backdrop-blur-md border-t border-slate-800/80 max-w-md mx-auto">
          <div className="grid grid-cols-4 h-16">
            {/* 1: الرئيسية */}
            <button
              type="button"
              onClick={() => setActiveTab("home")}
              className={`flex flex-col items-center justify-center gap-1 transition ${
                activeTab === "home" ? "text-cyan-400 font-bold" : "text-slate-400 hover:text-slate-200"
              }`}
            >
              <Home className="w-5 h-5" />
              <span className="text-[10px]">الرئيسية</span>
            </button>

            {/* 2: أعطالي */}
            <button
              type="button"
              onClick={() => setActiveTab("faults")}
              className={`flex flex-col items-center justify-center gap-1 transition ${
                activeTab === "faults" ? "text-cyan-400 font-bold" : "text-slate-400 hover:text-slate-200"
              }`}
            >
              <CheckCircle2 className="w-5 h-5" />
              <span className="text-[10px]">أعطالي</span>
            </button>

            {/* 3: الخريطة */}
            <button
              type="button"
              onClick={() => setActiveTab("map")}
              className={`flex flex-col items-center justify-center gap-1 transition ${
                activeTab === "map" ? "text-cyan-400 font-bold" : "text-slate-400 hover:text-slate-200"
              }`}
            >
              <MapPin className="w-5 h-5" />
              <span className="text-[10px]">الخريطة</span>
            </button>

            {/* 4: الملف الشخصي */}
            <button
              type="button"
              onClick={() => setActiveTab("profile")}
              className={`flex flex-col items-center justify-center gap-1 transition ${
                activeTab === "profile" ? "text-cyan-400 font-bold" : "text-slate-400 hover:text-slate-200"
              }`}
            >
              <User className="w-5 h-5" />
              <span className="text-[10px]">الملف الشخصي</span>
            </button>
          </div>
        </nav>

        {/* Global Panels */}
        {settingsOpen && <SettingsPanel onClose={() => setSettingsOpen(false)} />}
        {dictionaryOpen && <DictionaryPanel onClose={() => setDictionaryOpen(false)} />}
        {assistantOpen && activeReport && (
          <div className="fixed inset-0 z-50 bg-black/80 backdrop-blur-sm flex items-center justify-center p-4">
            <div className="w-full max-w-md bg-[#0a192f] border border-cyan-500/30 rounded-2xl p-4 max-h-[90vh] overflow-y-auto">
              <div className="flex justify-between items-center mb-2">
                <button
                  type="button"
                  onClick={() => setAssistantOpen(false)}
                  className="text-xs bg-slate-800 px-2 py-1 rounded"
                >
                  إغلاق
                </button>
                <span className="text-sm font-bold text-amber-400">مساعد كاشف الذكي</span>
              </div>
              <AssistantPanel report={activeReport} />
            </div>
          </div>
        )}
      </div>
    </div>
  );
}
