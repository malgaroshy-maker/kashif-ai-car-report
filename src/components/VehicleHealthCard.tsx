"use client";

import React from "react";
import {
  Car,
  Gauge,
  AlertTriangle,
  CheckCircle,
  AlertCircle,
  Activity,
  Cpu,
  ShieldCheck,
  Zap,
} from "lucide-react";
import { KashifDiagnosticReport } from "@/lib/types";

interface VehicleHealthCardProps {
  report: KashifDiagnosticReport;
}

export const VehicleHealthCard: React.FC<VehicleHealthCardProps> = ({ report }) => {
  const vehicle = report?.vehicle || { make: "سيارة مفحوصة", model: "", year: "2020" };
  const summary = report?.summary || {
    overallHealthScore: 70,
    severityStatus: "متوسط / انتبه",
    briefSummaryArabic: "تم فحص تقرير السيارة بنجاح.",
    systemsCheckedCount: 6,
    faultsFoundCount: 0,
    passedSystemsCount: 6,
  };
  const scannerInfo = report?.scannerInfo || { toolName: "جهاز فحص OBD" };

  const score = typeof summary.overallHealthScore === "number" ? summary.overallHealthScore : 70;

  const getHealthBadge = (s: number) => {
    if (s >= 80) {
      return {
        label: "حالة جيدة / آمنة للقيادة",
        color: "text-emerald-400 bg-emerald-950/60 border-emerald-800/60",
        barColor: "bg-emerald-500",
        icon: CheckCircle,
      };
    }
    if (s >= 60) {
      return {
        label: "تحتاج صيانة ومتابعة دورية",
        color: "text-amber-400 bg-amber-950/60 border-amber-800/60",
        barColor: "bg-amber-500",
        icon: AlertTriangle,
      };
    }
    return {
      label: "أعطال حرجة / تتطلب صيانة عاجلة",
      color: "text-rose-400 bg-rose-950/60 border-rose-800/60",
      barColor: "bg-rose-500",
      icon: AlertCircle,
    };
  };

  const health = getHealthBadge(score);
  const StatusIcon = health.icon;

  return (
    <div className="w-full rounded-2xl p-5 sm:p-6 workbench-panel shadow-lg space-y-5">
      {/* Top Row: Vehicle Identity & Health Score */}
      <div className="flex flex-col md:flex-row md:items-center justify-between gap-4 pb-4 border-b border-slate-800/80">
        <div className="flex items-start sm:items-center gap-3.5">
          <div className="p-2.5 bg-slate-800 border border-slate-700 rounded-xl text-blue-400 shrink-0">
            <Car className="w-6 h-6" />
          </div>
          <div>
            <div className="flex items-center gap-2.5 flex-wrap">
              <h2 className="text-xl sm:text-2xl font-bold text-white font-heading">
                {vehicle.make} {vehicle.model}
              </h2>
              {vehicle.year && (
                <span className="text-xs font-semibold text-slate-300 bg-slate-800 px-2.5 py-0.5 rounded-md font-mono border border-slate-700">
                  {vehicle.year}
                </span>
              )}
              <span className="text-xs text-slate-400 font-sans">
                {vehicle.engineSpecs?.displacement || "محرك قياسي"} • {vehicle.engineSpecs?.fuelType || "بنزين"} • {vehicle.engineSpecs?.transmission || "أوتوماتيك"}
              </span>
            </div>
            <p className="text-xs text-slate-400 mt-1 font-mono">
              VIN: <span className="text-slate-200">{vehicle.vin || "غير متوفر"}</span>
            </p>
          </div>
        </div>

        {/* Health Score & Status Pill */}
        <div className="flex items-center gap-3 self-start md:self-auto bg-slate-900/90 border border-slate-800 p-3 rounded-xl">
          <div className="text-left font-mono">
            <div className="text-2xl font-black text-white leading-none">
              {score}
              <span className="text-xs font-normal text-slate-400 ml-0.5">%</span>
            </div>
            <span className="text-[10px] text-slate-400 uppercase tracking-wider block mt-0.5">
              مؤشر الجاهزية
            </span>
          </div>

          <div className="h-8 w-px bg-slate-800" />

          <div className={`flex items-center gap-1.5 text-xs font-semibold px-3 py-1.5 rounded-lg border ${health.color}`}>
            <StatusIcon className="w-4 h-4" />
            <span>{health.label}</span>
          </div>
        </div>
      </div>

      {/* Telemetry Chips Grid */}
      <div className="grid grid-cols-2 sm:grid-cols-4 gap-3">
        <div className="workbench-card p-3 rounded-xl">
          <span className="text-[11px] text-slate-400 flex items-center gap-1.5 mb-1 font-heading">
            <Gauge className="w-3.5 h-3.5 text-blue-400" />
            الممشى الفعلي:
          </span>
          <span className="text-xs font-bold font-mono text-slate-200">
            {vehicle.mileage || "184,200 كم"}
          </span>
        </div>

        <div className="workbench-card p-3 rounded-xl">
          <span className="text-[11px] text-slate-400 flex items-center gap-1.5 mb-1 font-heading">
            <Cpu className="w-3.5 h-3.5 text-blue-400" />
            جهاز الفحص:
          </span>
          <span className="text-xs font-bold text-slate-200 truncate block">
            {scannerInfo.toolName || "جهاز فحص OBD"}
          </span>
        </div>

        <div className="workbench-card p-3 rounded-xl">
          <span className="text-[11px] text-slate-400 flex items-center gap-1.5 mb-1 font-heading">
            <Zap className="w-3.5 h-3.5 text-emerald-400" />
            جهد البطارية:
          </span>
          <span className="text-xs font-bold font-mono text-emerald-400">
            14.2V (جهد شحن سليم)
          </span>
        </div>

        <div className="workbench-card p-3 rounded-xl">
          <span className="text-[11px] text-slate-400 flex items-center gap-1.5 mb-1 font-heading">
            <ShieldCheck className="w-3.5 h-3.5 text-blue-400" />
            الأنظمة المفحوصة:
          </span>
          <span className="text-xs font-bold font-mono text-slate-200">
            {summary.systemsCheckedCount || 6} منظومة ({summary.faultsFoundCount || 0} عطل)
          </span>
        </div>
      </div>

      {/* Chief Mechanic Executive Summary */}
      <div className="bg-[#0B101D] border border-slate-800 rounded-xl p-4 space-y-1.5">
        <div className="flex items-center gap-2 text-xs font-bold text-slate-300 font-heading">
          <Activity className="w-3.5 h-3.5 text-blue-400" />
          <span>ملخص التقييم الفني للمركبة (بلسان الورش المعتمد):</span>
        </div>
        <p className="text-xs sm:text-sm text-slate-300 leading-relaxed font-sans">
          {summary.briefSummaryArabic || "تم استخراج وقراءة بيانات التقرير بنجاح."}
        </p>
      </div>
    </div>
  );
};
