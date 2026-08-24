"use client";

import React, { useState } from "react";
import {
  AlertCircle,
  AlertTriangle,
  CheckCircle2,
  Layers,
  History,
  ShieldCheck,
} from "lucide-react";
import { KashifDiagnosticReport } from "@/lib/types";
import { FaultCodeCard } from "./FaultCodeCard";

interface FaultPriorityMatrixProps {
  report: KashifDiagnosticReport;
  onSelectPart?: (partId?: string) => void;
}

export const FaultPriorityMatrix: React.FC<FaultPriorityMatrixProps> = ({
  report,
  onSelectPart,
}) => {
  const [activeFilter, setActiveFilter] = useState<
    "all" | "critical" | "moderate" | "minor" | "passed"
  >("all");

  const faultCategories = report?.faultCategories || {
    criticalFaults: [],
    moderateFaults: [],
    minorOrHistoricalFaults: [],
  };
  const criticalFaults = faultCategories.criticalFaults || [];
  const moderateFaults = faultCategories.moderateFaults || [];
  const minorFaults = faultCategories.minorOrHistoricalFaults || [];
  const passedSystems = report?.passedSystems || [];

  const totalFaults =
    criticalFaults.length +
    moderateFaults.length +
    minorFaults.length;

  return (
    <div className="w-full space-y-4">
      {/* Section Title & Filter Tabs */}
      <div className="flex flex-col sm:flex-row items-start sm:items-center justify-between gap-3 border-b border-slate-800 pb-3">
        <div>
          <h3 className="text-base sm:text-lg font-bold text-white font-heading flex items-center gap-2">
            <Layers className="w-4 h-4 text-blue-400" />
            <span>مصفوفة تشخيص الأعطال والأنظمة</span>
          </h3>
          <p className="text-xs text-slate-400 mt-0.5">
            مصنفة حسب درجة الخطورة الميدانية والأولوية الفنية في الورشة
          </p>
        </div>

        {/* Filter Tabs */}
        <div className="flex items-center gap-1 bg-slate-900 p-1 rounded-xl border border-slate-800 overflow-x-auto max-w-full">
          <button
            onClick={() => setActiveFilter("all")}
            className={`px-3 py-1 rounded-lg text-xs font-semibold transition-colors cursor-pointer whitespace-nowrap ${
              activeFilter === "all"
                ? "bg-blue-600 text-white"
                : "text-slate-400 hover:text-white"
            }`}
          >
            الكل ({totalFaults})
          </button>

          {criticalFaults.length > 0 && (
            <button
              onClick={() => setActiveFilter("critical")}
              className={`px-3 py-1 rounded-lg text-xs font-semibold transition-colors cursor-pointer whitespace-nowrap flex items-center gap-1.5 ${
                activeFilter === "critical"
                  ? "bg-rose-600 text-white"
                  : "text-rose-400 hover:text-rose-300"
              }`}
            >
              <AlertCircle className="w-3.5 h-3.5" />
              حرجة ({criticalFaults.length})
            </button>
          )}

          {moderateFaults.length > 0 && (
            <button
              onClick={() => setActiveFilter("moderate")}
              className={`px-3 py-1 rounded-lg text-xs font-semibold transition-colors cursor-pointer whitespace-nowrap flex items-center gap-1.5 ${
                activeFilter === "moderate"
                  ? "bg-amber-600 text-white"
                  : "text-amber-400 hover:text-amber-300"
              }`}
            >
              <AlertTriangle className="w-3.5 h-3.5" />
              متوسطة ({moderateFaults.length})
            </button>
          )}

          {minorFaults.length > 0 && (
            <button
              onClick={() => setActiveFilter("minor")}
              className={`px-3 py-1 rounded-lg text-xs font-semibold transition-colors cursor-pointer whitespace-nowrap flex items-center gap-1.5 ${
                activeFilter === "minor"
                  ? "bg-slate-700 text-white"
                  : "text-slate-400 hover:text-slate-200"
              }`}
            >
              <History className="w-3.5 h-3.5" />
              ذاكرة ({minorFaults.length})
            </button>
          )}

          <button
            onClick={() => setActiveFilter("passed")}
            className={`px-3 py-1 rounded-lg text-xs font-semibold transition-colors cursor-pointer whitespace-nowrap flex items-center gap-1.5 ${
              activeFilter === "passed"
                ? "bg-emerald-600 text-white"
                : "text-emerald-400 hover:text-emerald-300"
            }`}
          >
            <ShieldCheck className="w-3.5 h-3.5" />
            سليمة ({passedSystems.length})
          </button>
        </div>
      </div>

      {/* Content Rendering based on filter */}
      <div className="space-y-3">
        {/* Critical Faults */}
        {(activeFilter === "all" || activeFilter === "critical") &&
          criticalFaults.length > 0 && (
            <div className="space-y-2.5">
              {activeFilter === "all" && (
                <div className="flex items-center gap-2 text-xs font-bold text-rose-400 pt-1 font-heading">
                  <AlertCircle className="w-3.5 h-3.5" />
                  <span>الأعطال الحرجة والعاجلة:</span>
                </div>
              )}
              {criticalFaults.map((fault, idx) => (
                <FaultCodeCard
                  key={`crit-${idx}`}
                  fault={fault}
                  vehicleMake={report?.vehicle?.make ?? undefined}
                  vehicleModel={report?.vehicle?.model ?? undefined}
                  onSelectPart={onSelectPart}
                />
              ))}
            </div>
          )}

        {/* Moderate Faults */}
        {(activeFilter === "all" || activeFilter === "moderate") &&
          moderateFaults.length > 0 && (
            <div className="space-y-2.5">
              {activeFilter === "all" && (
                <div className="flex items-center gap-2 text-xs font-bold text-amber-400 pt-2 font-heading">
                  <AlertTriangle className="w-3.5 h-3.5" />
                  <span>الأعطال متوسطة الأولوية:</span>
                </div>
              )}
              {moderateFaults.map((fault, idx) => (
                <FaultCodeCard
                  key={`mod-${idx}`}
                  fault={fault}
                  vehicleMake={report?.vehicle?.make ?? undefined}
                  vehicleModel={report?.vehicle?.model ?? undefined}
                  onSelectPart={onSelectPart}
                />
              ))}
            </div>
          )}

        {/* Minor or Historical Faults */}
        {(activeFilter === "all" || activeFilter === "minor") &&
          minorFaults.length > 0 && (
            <div className="space-y-2.5">
              {activeFilter === "all" && (
                <div className="flex items-center gap-2 text-xs font-medium text-slate-400 pt-2 font-heading">
                  <History className="w-3.5 h-3.5" />
                  <span>أعطال الذاكرة السابقة (History Log):</span>
                </div>
              )}
              {minorFaults.map((fault, idx) => (
                <FaultCodeCard
                  key={`min-${idx}`}
                  fault={fault}
                  vehicleMake={report?.vehicle?.make ?? undefined}
                  vehicleModel={report?.vehicle?.model ?? undefined}
                  onSelectPart={onSelectPart}
                />
              ))}
            </div>
          )}

        {/* Passed Systems Grid */}
        {(activeFilter === "all" || activeFilter === "passed") &&
          passedSystems.length > 0 && (
            <div className="pt-3">
              <div className="flex items-center gap-2 text-xs font-bold text-emerald-400 mb-2.5 font-heading">
                <CheckCircle2 className="w-3.5 h-3.5" />
                <span>الأنظمة الإلكترونية السليمة ({passedSystems.length}):</span>
              </div>
              <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-2.5">
                {passedSystems.map((sys, idx) => (
                  <div
                    key={idx}
                    className="rounded-xl p-3 border border-slate-800 bg-slate-900/70 flex items-center justify-between"
                  >
                    <div>
                      <h4 className="text-xs font-bold text-slate-200 font-heading">
                        {sys.systemNameArabic}
                      </h4>
                      <p className="text-[10px] text-slate-400 font-mono">
                        {sys.systemNameEnglish}
                      </p>
                    </div>
                    <span className="text-[11px] font-mono font-semibold bg-emerald-950 text-emerald-400 border border-emerald-800/80 px-2 py-0.5 rounded">
                      {sys.systemCode} OK
                    </span>
                  </div>
                ))}
              </div>
            </div>
          )}
      </div>
    </div>
  );
};
