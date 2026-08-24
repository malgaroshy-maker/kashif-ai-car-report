"use client";

import React, { useState } from "react";
import { CheckSquare, Square, Wrench, CheckCircle2 } from "lucide-react";
import { DiagnosticStep } from "@/lib/types";

interface DiagnosticChecklistProps {
  steps: DiagnosticStep[];
}

export const DiagnosticChecklist: React.FC<DiagnosticChecklistProps> = ({
  steps,
}) => {
  const safeSteps = Array.isArray(steps) ? steps : [];
  const [completedSteps, setCompletedSteps] = useState<Record<number, boolean>>(
    {}
  );

  const toggleStep = (stepNumber: number) => {
    setCompletedSteps((prev) => ({
      ...prev,
      [stepNumber]: !prev[stepNumber],
    }));
  };

  const completedCount = Object.values(completedSteps).filter(Boolean).length;
  const progressPercent = safeSteps.length > 0 ? Math.round((completedCount / safeSteps.length) * 100) : 0;

  if (safeSteps.length === 0) {
    return null;
  }

  return (
    <div className="w-full workbench-panel rounded-2xl p-5 space-y-4">
      {/* Header with Progress Bar */}
      <div className="flex flex-col sm:flex-row items-start sm:items-center justify-between gap-3 border-b border-slate-800 pb-3">
        <div>
          <h3 className="text-base sm:text-lg font-bold text-white flex items-center gap-2 font-heading">
            <Wrench className="w-4 h-4 text-blue-400" />
            <span>قائمة فحص الأسطى التسلسلية (Inspection Checklist)</span>
          </h3>
          <p className="text-xs text-slate-400 mt-0.5">
            خطوات فحص تدريجية للورشة قبل استبدال أي قطعة لتجنب التبديل العشوائي
          </p>
        </div>

        {/* Progress Indicator */}
        <div className="flex items-center gap-3 w-full sm:w-auto">
          <div className="w-28 bg-slate-800 h-2 rounded-full overflow-hidden">
            <div
              className="bg-blue-500 h-full transition-all duration-200 rounded-full"
              style={{ width: `${progressPercent}%` }}
            />
          </div>
          <span className="text-xs font-mono font-semibold text-slate-300">
            {completedCount} / {steps.length}
          </span>
        </div>
      </div>

      {/* Steps List */}
      <div className="space-y-2.5">
        {steps.map((step) => {
          const isDone = !!completedSteps[step.stepNumber];
          return (
            <div
              key={step.stepNumber}
              onClick={() => toggleStep(step.stepNumber)}
              className={`p-3.5 rounded-xl border transition-colors cursor-pointer flex items-start gap-3 ${
                isDone
                  ? "bg-emerald-950/30 border-emerald-800/50 text-emerald-200"
                  : "bg-slate-900/80 hover:bg-slate-900 border-slate-800 text-slate-200"
              }`}
            >
              <button
                type="button"
                className="mt-0.5 text-blue-400 shrink-0"
              >
                {isDone ? (
                  <CheckSquare className="w-4 h-4 text-emerald-400" />
                ) : (
                  <Square className="w-4 h-4 text-slate-500" />
                )}
              </button>

              <div className="flex-1 min-w-0">
                <div className="flex items-center gap-2 flex-wrap mb-1">
                  <span className="text-xs font-bold text-amber-400 bg-slate-950 px-2 py-0.5 rounded border border-slate-800 font-heading">
                    خطوة {step.stepNumber}: {step.targetComponent}
                  </span>
                  <span className="text-[10px] text-slate-400 bg-slate-800 px-2 py-0.5 rounded border border-slate-700">
                    الأداة: {step.toolNeeded}
                  </span>
                </div>
                <p
                  className={`text-xs sm:text-sm leading-relaxed ${
                    isDone
                      ? "line-through text-slate-400"
                      : "text-slate-300"
                  }`}
                >
                  {step.actionRequiredLibyan}
                </p>
              </div>
            </div>
          );
        })}
      </div>

      {progressPercent === 100 && (
        <div className="p-3 bg-emerald-950/60 border border-emerald-800/80 rounded-xl flex items-center gap-2 text-emerald-300 text-xs font-bold">
          <CheckCircle2 className="w-4 h-4" />
          <span>تمت جميع خطوات الفحص التشخيصي بنجاح! المركبة جاهزة للاختبار النهائي.</span>
        </div>
      )}
    </div>
  );
};
