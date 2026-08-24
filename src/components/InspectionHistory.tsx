"use client";

import React from "react";
import { History, Trash2, ArrowLeft, Calendar } from "lucide-react";
import { KashifDiagnosticReport } from "@/lib/types";

interface InspectionHistoryProps {
  history: KashifDiagnosticReport[];
  onSelectReport: (report: KashifDiagnosticReport) => void;
  onClearHistory: () => void;
}

export const InspectionHistory: React.FC<InspectionHistoryProps> = ({
  history,
  onSelectReport,
  onClearHistory,
}) => {
  if (!history || !Array.isArray(history) || history.length === 0) {
    return null;
  }

  return (
    <div className="w-full max-w-4xl mx-auto mt-8 p-5 workbench-panel rounded-2xl no-print">
      <div className="flex items-center justify-between gap-4 mb-3 border-b border-slate-800 pb-2.5">
        <div className="flex items-center gap-2">
          <History className="w-4 h-4 text-blue-400" />
          <h3 className="text-xs sm:text-sm font-bold text-white font-heading">
            سجل الفحوصات المحفوظة محلياً ({history.length})
          </h3>
        </div>

        <button
          onClick={onClearHistory}
          className="text-xs text-slate-400 hover:text-rose-400 flex items-center gap-1 transition-colors cursor-pointer"
        >
          <Trash2 className="w-3.5 h-3.5" />
          <span>مسح السجل</span>
        </button>
      </div>

      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-2.5">
        {history.map((item, idx) => {
          if (!item) return null;
          const make = item.vehicle?.make || "مركبة مفحوصة";
          const model = item.vehicle?.model || "";
          const vin = item.vehicle?.vin || "غير محدد";
          const score =
            typeof item.summary?.overallHealthScore === "number"
              ? item.summary.overallHealthScore
              : 70;
          const dateStr = item.generatedAt
            ? new Date(item.generatedAt).toLocaleDateString("ar-LY")
            : "اليوم";

          return (
            <div
              key={item.reportId || idx}
              onClick={() => onSelectReport(item)}
              className="p-3 bg-slate-900/80 hover:bg-slate-900 border border-slate-800 hover:border-slate-700 rounded-xl cursor-pointer transition-colors flex flex-col justify-between group"
            >
              <div>
                <div className="flex items-center justify-between mb-1.5">
                  <span className="text-xs font-bold text-slate-100 font-heading">
                    {make} {model}
                  </span>
                  <span
                    className={`text-[10px] font-bold px-1.5 py-0.5 rounded font-mono ${
                      score >= 80
                        ? "text-emerald-400 bg-emerald-950/80 border border-emerald-800"
                        : score >= 60
                        ? "text-amber-400 bg-amber-950/80 border border-amber-800"
                        : "text-rose-400 bg-rose-950/80 border border-rose-800"
                    }`}
                  >
                    {score}%
                  </span>
                </div>

                <p className="text-[11px] font-mono text-slate-400 truncate mb-1.5">
                  VIN: {vin}
                </p>
              </div>

              <div className="flex items-center justify-between text-[10px] text-slate-400 pt-2 border-t border-slate-800">
                <span className="flex items-center gap-1">
                  <Calendar className="w-3 h-3 text-slate-500" />
                  {dateStr}
                </span>
                <span className="text-blue-400 group-hover:translate-x-[-3px] transition-transform flex items-center gap-0.5 font-semibold">
                  عرض التقرير <ArrowLeft className="w-3 h-3" />
                </span>
              </div>
            </div>
          );
        })}
      </div>
    </div>
  );
};
