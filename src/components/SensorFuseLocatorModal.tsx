"use client";

import React, { useState } from "react";
import {
  X,
  Zap,
  Activity,
  MapPin,
  CheckCircle2,
  AlertTriangle,
  Cpu,
  Wrench,
  Gauge,
} from "lucide-react";
import { DiagnosticCodeDetail } from "@/lib/types";
import { Info } from "lucide-react";
import { getElectricalDiagnosticsForCode } from "@/lib/sensor-locator";

interface SensorFuseLocatorModalProps {
  fault: DiagnosticCodeDetail;
  vehicleMake?: string;
  vehicleModel?: string;
  onClose: () => void;
}

export const SensorFuseLocatorModal: React.FC<SensorFuseLocatorModalProps> = ({
  fault,
  vehicleMake,
  vehicleModel,
  onClose,
}) => {
  const [activeTab, setActiveTab] = useState<"engine" | "fuse" | "multimeter">("engine");

  const diag =
    fault.electricalDiagnostics ||
    getElectricalDiagnosticsForCode(fault.code, vehicleMake);

  const { fuseInfo, sensorLocation, multimeterTest, provenance } = diag;

  // What this screen is allowed to claim. Everything below is drawn from one
  // of three sources and the reader is told which, because they act on it
  // physically: they pull a fuse, and they put a probe on a pin.
  const PROVENANCE = {
    scan: {
      label: "من فحص سيارتك",
      note: "هذه البيانات مستخرجة من تقرير الفحص الخاص بسيارتك.",
    },
    reference: {
      label: "من مرجع الأكواد",
      note: "بيانات مرجعية للرمز نفسه. تأكد منها على سيارتك قبل الفك أو القياس — الترقيم يختلف بين الموديلات والسنوات.",
    },
    general: {
      label: "إرشاد عام — مش مخطط سيارتك",
      note: "الرمز مش موجود في المرجع عندنا. اللي تحت إرشاد ورشة عام لعائلة هذا الرمز: ما فيهش رقم فيوز ولا أمبير ولا موقع محدد، لأن دي تختلف من سيارة لسيارة. رقم الفيوز الصحيح مطبوع على غطاء علبة الفيوزات في سيارتك.",
    },
  }[provenance];

  const isGeneral = provenance === "general";

  return (
    <div
      onClick={onClose}
      className="fixed inset-0 z-50 bg-slate-950/85 backdrop-blur-md flex items-center justify-center p-3 sm:p-5 overflow-y-auto"
    >
      <div
        onClick={(e) => e.stopPropagation()}
        className="bg-[#0B111E] border border-slate-800/90 rounded-2xl max-w-3xl w-full shadow-2xl overflow-hidden flex flex-col my-auto border-t-2 border-t-blue-500"
      >
        {/* Modal Header */}
        <div className="p-4 sm:p-5 border-b border-slate-800 bg-slate-900/60 flex items-start justify-between gap-3">
          <div className="flex items-start gap-3">
            <div className="w-10 h-10 rounded-xl bg-blue-950 border border-blue-800/80 flex items-center justify-center text-blue-400 shrink-0 shadow-inner">
              <Zap className="w-5 h-5" />
            </div>
            <div>
              <div className="flex items-center gap-2 flex-wrap">
                <span className="text-xs font-bold font-mono px-2 py-0.5 rounded bg-blue-900/40 text-blue-300 border border-blue-700/50">
                  {fault.code}
                </span>
                <span className="text-xs font-semibold px-2 py-0.5 rounded bg-slate-800 text-slate-300">
                  {fault.moduleNameArabic || fault.module}
                </span>
                <span className="text-xs font-mono text-slate-400">
                  {vehicleMake} {vehicleModel}
                </span>
              </div>
              <h3 className="text-base sm:text-lg font-bold text-white font-heading mt-1">
                مخطط موقع الحساس والفيوز: {fault.libyanTerm}
              </h3>
              <p className="text-xs text-slate-400 font-sans mt-0.5">
                {fault.standardDescriptionEn}
              </p>
            </div>
          </div>

          <button
            onClick={onClose}
            className="text-slate-400 hover:text-white p-1.5 rounded-lg hover:bg-slate-800 transition-colors cursor-pointer shrink-0"
          >
            <X className="w-5 h-5" />
          </button>
        </div>

        {/* Tab Navigation */}
        <div className="flex border-b border-slate-800 bg-slate-950/40 px-4 sm:px-5 gap-2">
          <button
            onClick={() => setActiveTab("engine")}
            className={`flex items-center gap-2 py-3 px-3 text-xs font-bold border-b-2 transition-all cursor-pointer ${
              activeTab === "engine"
                ? "border-blue-500 text-blue-400 bg-blue-500/5"
                : "border-transparent text-slate-400 hover:text-slate-200"
            }`}
          >
            <MapPin className="w-4 h-4" />
            <span>موقع الحساس بالمحرك</span>
          </button>

          <button
            onClick={() => setActiveTab("fuse")}
            className={`flex items-center gap-2 py-3 px-3 text-xs font-bold border-b-2 transition-all cursor-pointer ${
              activeTab === "fuse"
                ? "border-amber-500 text-amber-400 bg-amber-500/5"
                : "border-transparent text-slate-400 hover:text-slate-200"
            }`}
          >
            <Cpu className="w-4 h-4" />
            <span>مخطط علبة الفيوزات</span>
          </button>

          <button
            onClick={() => setActiveTab("multimeter")}
            className={`flex items-center gap-2 py-3 px-3 text-xs font-bold border-b-2 transition-all cursor-pointer ${
              activeTab === "multimeter"
                ? "border-emerald-500 text-emerald-400 bg-emerald-500/5"
                : "border-transparent text-slate-400 hover:text-slate-200"
            }`}
          >
            <Activity className="w-4 h-4" />
            <span>فحص الفيشة بالأفوميتر</span>
          </button>
        </div>

        {/* Tab Content */}
        <div className="p-4 sm:p-6 overflow-y-auto max-h-[65vh] space-y-4">
          {/* Where this came from. Never hidden behind a tab. */}
          <div
            className={`p-3 rounded-xl border flex items-start gap-2 text-xs ${
              isGeneral
                ? "bg-amber-950/40 border-amber-700/60 text-amber-100"
                : "bg-slate-900/80 border-slate-800 text-slate-300"
            }`}
          >
            <Info
              className={`w-4 h-4 shrink-0 mt-0.5 ${
                isGeneral ? "text-amber-400" : "text-blue-400"
              }`}
            />
            <span>
              <strong className={isGeneral ? "text-amber-200" : "text-white"}>
                {PROVENANCE.label}:{" "}
              </strong>
              {PROVENANCE.note}
            </span>
          </div>
          {/* TAB 1: Engine Bay Schematic */}
          {activeTab === "engine" && (
            <div className="space-y-4">
              <div className="relative w-full h-64 sm:h-72 bg-[#060911] border border-slate-800 rounded-xl overflow-hidden flex items-center justify-center">
                {/* 2D High-Tech Engine Bay SVG Layout */}
                <svg
                  viewBox="0 0 500 300"
                  className="w-full h-full text-slate-700 select-none opacity-80"
                >
                  {/* Grid Lines */}
                  <defs>
                    <pattern id="grid" width="20" height="20" patternUnits="userSpaceOnUse">
                      <path d="M 20 0 L 0 0 0 20" fill="none" stroke="#1E293B" strokeWidth="0.5" />
                    </pattern>
                  </defs>
                  <rect width="500" height="300" fill="url(#grid)" />

                  {/* Engine Bay Outer Perimeter */}
                  <path
                    d="M 50 30 Q 250 15 450 30 L 460 270 Q 250 285 40 270 Z"
                    fill="#0D1424"
                    stroke="#334155"
                    strokeWidth="2"
                  />

                  {/* Front Bumper & Radiator */}
                  <rect x="70" y="35" width="360" height="20" rx="4" fill="#1E293B" stroke="#475569" strokeWidth="1" />
                  <text x="250" y="49" fill="#94A3B8" fontSize="10" textAnchor="middle" fontFamily="monospace">
                    FRONT RADIATOR / المبرد الأمامي
                  </text>

                  {/* Air Filter Box (Front Left) */}
                  <rect x="70" y="70" width="80" height="60" rx="6" fill="#1E293B" stroke="#38BDF8" strokeWidth="1.5" strokeDasharray="3 3" />
                  <text x="110" y="105" fill="#38BDF8" fontSize="9" textAnchor="middle" fontWeight="bold">
                    علبة الفيلترو (AIR BOX)
                  </text>

                  {/* Air Intake Hose */}
                  <path d="M 150 100 Q 200 95 210 130" fill="none" stroke="#0284C7" strokeWidth="12" strokeLinecap="round" />

                  {/* Engine Block / Cylinder Head */}
                  <rect x="180" y="110" width="160" height="120" rx="10" fill="#1E293B" stroke="#64748B" strokeWidth="2" />
                  <text x="260" y="145" fill="#E2E8F0" fontSize="12" textAnchor="middle" fontWeight="bold">
                    ENGINE BLOCK
                  </text>
                  <text x="260" y="160" fill="#94A3B8" fontSize="10" textAnchor="middle">
                    بلوك المحرك والتاكيهات
                  </text>

                  {/* Spark Plugs / Coils Indicator */}
                  <circle cx="210" cy="185" r="8" fill="#F59E0B" opacity="0.8" />
                  <circle cx="240" cy="185" r="8" fill="#F59E0B" opacity="0.8" />
                  <circle cx="270" cy="185" r="8" fill="#F59E0B" opacity="0.8" />
                  <circle cx="300" cy="185" r="8" fill="#F59E0B" opacity="0.8" />

                  {/* Battery (Front Right) */}
                  <rect x="360" y="70" width="70" height="50" rx="4" fill="#1E293B" stroke="#64748B" strokeWidth="1" />
                  <text x="395" y="98" fill="#94A3B8" fontSize="9" textAnchor="middle">
                    BATTERY 12V
                  </text>

                  {/* Main Under-hood Fuse Box */}
                  <rect x="360" y="140" width="75" height="70" rx="6" fill="#1E293B" stroke="#F59E0B" strokeWidth="1.5" strokeDasharray="3 3" />
                  <text x="397" y="178" fill="#F59E0B" fontSize="9" textAnchor="middle" fontWeight="bold">
                    علبة الفيوزات
                  </text>

                  {/* Exhaust Manifold (Downpipe) */}
                  <path d="M 340 180 Q 370 200 370 250" fill="none" stroke="#DC2626" strokeWidth="10" strokeLinecap="round" opacity="0.85" />
                  <text x="400" y="245" fill="#F87171" fontSize="9" textAnchor="start">
                    المرميطة / EXHAUST
                  </text>
                </svg>

                {/* The marker is drawn only when something actually located
                    the sensor. It used to default to the middle of the engine
                    bay, which pointed at a component at random. */}
                {sensorLocation.coordinatePct ? (
                  <div
                    className="absolute z-20 -translate-x-1/2 -translate-y-1/2 flex flex-col items-center pointer-events-none"
                    style={{
                      left: `${sensorLocation.coordinatePct.x}%`,
                      top: `${sensorLocation.coordinatePct.y}%`,
                    }}
                  >
                    <div className="relative flex items-center justify-center">
                      <span className="animate-ping absolute inline-flex h-8 w-8 rounded-full bg-blue-400 opacity-75" />
                      <span className="relative inline-flex rounded-full h-5 w-5 bg-blue-500 border-2 border-white shadow-lg shadow-blue-500/50" />
                    </div>
                    <span className="mt-1 px-2 py-0.5 rounded bg-blue-950/90 border border-blue-500 text-blue-200 text-[10px] font-bold whitespace-nowrap shadow-md">
                      موقع: {fault.code}
                    </span>
                  </div>
                ) : (
                  <div className="absolute inset-x-0 bottom-0 z-20 p-2 bg-slate-950/85 border-t border-slate-800 text-center pointer-events-none">
                    <span className="text-[11px] text-slate-300">
                      رسم عام للتوضيح — ما عندناش موقع محدد لهذا الرمز على هذه
                      السيارة
                    </span>
                  </div>
                )}
              </div>

              {/* Location Details Card */}
              <div className="p-4 rounded-xl bg-slate-900/80 border border-slate-800 space-y-2 text-xs">
                <div className="flex items-center gap-2 text-blue-400 font-bold">
                  <MapPin className="w-4 h-4" />
                  <span>الموقع الفعلي في السيارة:</span>
                </div>
                <p className="text-slate-200 font-medium">
                  {sensorLocation.areaName}
                </p>

                <div className="p-3 rounded-lg bg-blue-950/40 border border-blue-800/40 text-slate-300 text-xs flex items-start gap-2">
                  <Wrench className="w-4 h-4 text-blue-400 shrink-0 mt-0.5" />
                  <div>
                    <span className="font-bold text-white">طريقة الوصول والفك (نصيحة أسطى): </span>
                    <span>{sensorLocation.accessTip}</span>
                  </div>
                </div>
              </div>
            </div>
          )}

          {/* TAB 2: Fuse Box & Relay Diagram */}
          {activeTab === "fuse" && (
            <div className="space-y-4">
              <div className="p-4 rounded-xl bg-slate-900/80 border border-slate-800 space-y-3">
                <div className="flex items-center justify-between border-b border-slate-800 pb-2">
                  <div className="flex items-center gap-2">
                    <Cpu className="w-4 h-4 text-amber-400" />
                    <span className="font-bold text-white text-xs sm:text-sm font-heading">
                      بيانات الفيوز المخصص للمنظومة
                    </span>
                  </div>
                  {fuseInfo.rating ? (
                    <span className="text-xs font-mono font-bold px-2 py-0.5 rounded bg-amber-950 text-amber-300 border border-amber-800">
                      {fuseInfo.rating}
                    </span>
                  ) : (
                    <span className="text-xs font-mono px-2 py-0.5 rounded bg-slate-900 text-slate-400 border border-slate-700">
                      الأمبير غير محدد
                    </span>
                  )}
                </div>

                <div className="grid grid-cols-1 sm:grid-cols-2 gap-3 text-xs">
                  <div className="p-3 rounded-lg bg-slate-950 border border-slate-800/80">
                    <span className="text-slate-400 block mb-1">موقع علبة الفيوزات:</span>
                    <span className="text-white font-semibold">{fuseInfo.boxLocation}</span>
                  </div>

                  <div className="p-3 rounded-lg bg-slate-950 border border-slate-800/80">
                    <span className="text-slate-400 block mb-1">رقم ورمز الفيوز (Fuse ID):</span>
                    {fuseInfo.fuseNumber ? (
                      <span className="text-amber-300 font-mono font-bold">{fuseInfo.fuseNumber}</span>
                    ) : (
                      <span className="text-slate-400">
                        غير محدد — اقرا الرسم المطبوع على غطاء علبة الفيوزات
                      </span>
                    )}
                  </div>

                  {fuseInfo.relayName && (
                    <div className="p-3 rounded-lg bg-slate-950 border border-slate-800/80 sm:col-span-2">
                      <span className="text-slate-400 block mb-1">الكتاوت المرتبط (Relay):</span>
                      <span className="text-blue-300 font-semibold">{fuseInfo.relayName}</span>
                    </div>
                  )}

                  <div className="p-3 rounded-lg bg-slate-950 border border-slate-800/80 sm:col-span-2">
                    <span className="text-slate-400 block mb-1">الدائرة المحمية:</span>
                    <span className="text-slate-300">{fuseInfo.circuitDescription}</span>
                  </div>
                </div>

                <div className="p-3 bg-amber-950/40 border border-amber-800/40 rounded-lg text-amber-200 text-xs flex items-start gap-2">
                  <AlertTriangle className="w-4 h-4 text-amber-400 shrink-0 mt-0.5" />
                  <span>
                    <strong>تنبيه فني:</strong> قبل شراء أي حساس جديد، افحص فيوز
                    الدائرة بلمبة فحص (Test Light) أو الأفوميتر وتأكد أنه مش
                    محروق. رقم الفيوز وترتيب العلبة مطبوعين على غطاء علبة
                    الفيوزات في سيارتك — هذا هو المرجع الصحيح.
                  </span>
                </div>
              </div>
            </div>
          )}

          {/* TAB 3: Multimeter & Pinout Testing */}
          {activeTab === "multimeter" && (
            <div className="space-y-4">
              <div className="p-4 rounded-xl bg-slate-900/80 border border-slate-800 space-y-3 text-xs">
                <div className="flex items-center gap-2 text-emerald-400 font-bold">
                  <Gauge className="w-4 h-4" />
                  <span className="text-sm font-heading">طريقة فحص الفيشة والبيانتو بالأفوميتر (Pinout Test):</span>
                </div>

                <div className="grid grid-cols-1 sm:grid-cols-3 gap-2.5">
                  <div className="p-3 rounded-lg bg-slate-950 border border-red-900/40 space-y-1">
                    <div className="flex items-center gap-1.5 text-red-400 font-bold">
                      <span className="w-2.5 h-2.5 rounded-full bg-red-500 inline-block" />
                      <span>1. خط التغذية (Power 12V):</span>
                    </div>
                    <p className="text-slate-300 font-mono text-[11px]">
                      {multimeterTest.powerPin}
                    </p>
                  </div>

                  <div className="p-3 rounded-lg bg-slate-950 border border-slate-700/60 space-y-1">
                    <div className="flex items-center gap-1.5 text-slate-300 font-bold">
                      <span className="w-2.5 h-2.5 rounded-full bg-slate-400 inline-block" />
                      <span>2. خط الأرضي (Ground):</span>
                    </div>
                    <p className="text-slate-300 font-mono text-[11px]">
                      {multimeterTest.groundPin}
                    </p>
                  </div>

                  <div className="p-3 rounded-lg bg-slate-950 border border-blue-900/40 space-y-1">
                    <div className="flex items-center gap-1.5 text-blue-400 font-bold">
                      <span className="w-2.5 h-2.5 rounded-full bg-blue-500 inline-block" />
                      <span>3. خط الإشارة (Signal):</span>
                    </div>
                    <p className="text-slate-300 font-mono text-[11px]">
                      {multimeterTest.signalPin}
                    </p>
                  </div>
                </div>

                {multimeterTest.referenceVoltage && (
                  <div className="p-2.5 rounded-lg bg-slate-950 border border-slate-800 text-[11px]">
                    <span className="text-slate-400">الجهد المرجعي للكمبيوتر (Reference Voltage): </span>
                    <span className="text-emerald-300 font-mono font-bold">{multimeterTest.referenceVoltage}</span>
                  </div>
                )}

                {/* Practical Libyan Workshop Step-by-Step */}
                <div className="p-3.5 rounded-xl bg-emerald-950/30 border border-emerald-800/50 space-y-2">
                  <span className="font-bold text-emerald-300 text-xs flex items-center gap-1.5">
                    <CheckCircle2 className="w-4 h-4 text-emerald-400" />
                    خطوات الفحص الميداني الموصى بها:
                  </span>
                  <p className="text-slate-200 text-xs leading-relaxed">
                    {multimeterTest.testingTipLibyan}
                  </p>
                </div>
              </div>
            </div>
          )}
        </div>

        {/* Modal Footer */}
        <div className="p-3.5 sm:p-4 border-t border-slate-800 bg-slate-900/60 flex items-center justify-between text-xs">
          <span className="text-slate-400 text-[11px] font-sans">
            كاشف AI • مخطط الفحص الكهربائي والمطابقة الميدانية
          </span>
          <button
            onClick={onClose}
            className="px-4 py-1.5 bg-blue-600 hover:bg-blue-500 text-white font-bold rounded-lg transition-colors cursor-pointer text-xs"
          >
            إغلاق المخطط
          </button>
        </div>
      </div>
    </div>
  );
};
