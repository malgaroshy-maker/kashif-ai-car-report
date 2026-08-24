"use client";

import React, { useState } from "react";
import {
  AlertCircle,
  AlertTriangle,
  Info,
  ChevronDown,
  ChevronUp,
  Fuel,
  ShieldAlert,
  Gauge,
  Wrench,
  Package,
  Zap,
} from "lucide-react";
import { DiagnosticCodeDetail } from "@/lib/types";
import { SensorFuseLocatorModal } from "./SensorFuseLocatorModal";

interface FaultCodeCardProps {
  fault: DiagnosticCodeDetail;
  vehicleMake?: string;
  vehicleModel?: string;
  onSelectPart?: (partId?: string) => void;
}

export const FaultCodeCard: React.FC<FaultCodeCardProps> = ({
  fault,
  vehicleMake,
  vehicleModel,
  onSelectPart,
}) => {
  const [isExpanded, setIsExpanded] = useState(false);
  const [showLocatorModal, setShowLocatorModal] = useState(false);

  const getUrgencyBadge = () => {
    switch (fault.urgencyLevel) {
      case "عالي جداً":
        return (
          <span className="inline-flex items-center gap-1 text-xs font-semibold px-2.5 py-1 rounded-md bg-rose-950/70 text-rose-300 border border-rose-800/80">
            <AlertCircle className="w-3.5 h-3.5" />
            حرج وعاجل
          </span>
        );
      case "متوسط":
        return (
          <span className="inline-flex items-center gap-1 text-xs font-semibold px-2.5 py-1 rounded-md bg-amber-950/70 text-amber-300 border border-amber-800/80">
            <AlertTriangle className="w-3.5 h-3.5" />
            متوسط الأولوية
          </span>
        );
      case "منخفض":
      default:
        return (
          <span className="inline-flex items-center gap-1 text-xs font-medium px-2.5 py-1 rounded-md bg-slate-800 text-slate-300 border border-slate-700">
            <Info className="w-3.5 h-3.5 text-blue-400" />
            ملاحظة / تاريخي
          </span>
        );
    }
  };

  return (
    <>
      <div
        className={`rounded-xl border transition-colors overflow-hidden ${
          fault.urgencyLevel === "عالي جداً"
            ? "border-rose-900/60 bg-[#0F1422]"
            : fault.urgencyLevel === "متوسط"
            ? "border-amber-900/50 bg-[#0F1422]"
            : "border-slate-800/90 bg-[#0D121F]"
        }`}
      >
        {/* Header Row */}
        <div
          onClick={() => setIsExpanded(!isExpanded)}
          className="p-4 flex flex-col sm:flex-row items-start sm:items-center justify-between gap-3 cursor-pointer hover:bg-slate-800/40 transition-colors"
        >
          <div className="flex items-start sm:items-center gap-3">
            {/* DTC Code Badge */}
            <div className="bg-slate-900 px-3 py-1.5 rounded-lg border border-slate-700 text-amber-400 font-mono font-bold text-xs tracking-wider shrink-0">
              {fault.code}
            </div>

            <div>
              <div className="flex items-center gap-2 flex-wrap">
                <h3 className="text-sm sm:text-base font-bold text-white font-heading">
                  {fault.libyanTerm}
                </h3>
                <span className="text-[11px] font-semibold bg-slate-800 text-blue-300 px-2 py-0.5 rounded border border-slate-700 font-mono">
                  {fault.moduleNameArabic || fault.module}
                </span>
              </div>
              <p className="text-xs text-slate-400 mt-0.5 font-mono">
                {fault.standardDescriptionEn}
              </p>
            </div>
          </div>

          <div className="flex items-center justify-between sm:justify-end gap-2.5 w-full sm:w-auto pt-2 sm:pt-0 border-t sm:border-t-0 border-slate-800">
            {/* Sensor & Fuse Quick Button */}
            <button
              onClick={(e) => {
                e.stopPropagation();
                setShowLocatorModal(true);
              }}
              className="bg-blue-950/80 hover:bg-blue-900/90 text-blue-300 border border-blue-700/60 text-[11px] font-bold px-2.5 py-1 rounded-md transition-colors cursor-pointer flex items-center gap-1 font-heading shadow-sm"
              title="عرض موقع الحساس ومخطط علبة الفيوزات وطريقة القياس بالأفوميتر"
            >
              <Zap className="w-3 h-3 text-amber-400" />
              <span>مخطط الفيوز والفيشة 🔌</span>
            </button>

            {getUrgencyBadge()}
            <button className="text-slate-400 hover:text-white p-1">
              {isExpanded ? (
                <ChevronUp className="w-4 h-4 text-blue-400" />
              ) : (
                <ChevronDown className="w-4 h-4 text-slate-400" />
              )}
            </button>
          </div>
        </div>

        {/* Expanded Details Body */}
        {isExpanded && (
          <div className="p-4 pt-0 border-t border-slate-800/80 space-y-3.5 bg-[#090E1A]">
            {/* Engineering Explanation */}
            <div className="bg-slate-900/90 p-3.5 rounded-xl border border-slate-800">
              <span className="text-[11px] font-bold text-blue-400 block mb-1 font-heading">
                الوصف الهندسي القياسي:
              </span>
              <p className="text-xs sm:text-sm text-slate-200 leading-relaxed font-sans">
                {fault.standardArabicDescription}
              </p>
            </div>

            {/* Grid: Symptoms & Causes */}
            <div className="grid grid-cols-1 md:grid-cols-2 gap-3">
              {/* Symptoms */}
              <div className="bg-slate-900/90 p-3.5 rounded-xl border border-slate-800">
                <span className="text-xs font-bold text-amber-300 flex items-center gap-1.5 mb-2 font-heading">
                  <AlertTriangle className="w-3.5 h-3.5 text-amber-400" />
                  الأعراض الملاحظة ميدانياً:
                </span>
                <ul className="space-y-1.5">
                  {fault.driverSymptoms.map((symptom, idx) => (
                    <li
                      key={idx}
                      className="text-xs text-slate-300 flex items-start gap-2 leading-relaxed"
                    >
                      <span className="w-1 h-1 rounded-full bg-amber-400 mt-2 shrink-0" />
                      <span>{symptom}</span>
                    </li>
                  ))}
                </ul>
              </div>

              {/* Root Causes */}
              <div className="bg-slate-900/90 p-3.5 rounded-xl border border-slate-800">
                <span className="text-xs font-bold text-blue-300 flex items-center gap-1.5 mb-2 font-heading">
                  <Wrench className="w-3.5 h-3.5 text-blue-400" />
                  الأسباب الجذرية المحتملة:
                </span>
                <ul className="space-y-1.5">
                  {fault.rootCauses.map((cause, idx) => (
                    <li
                      key={idx}
                      className="text-xs text-slate-300 flex items-start gap-2 leading-relaxed"
                    >
                      <span className="w-1 h-1 rounded-full bg-blue-400 mt-2 shrink-0" />
                      <span>{cause}</span>
                    </li>
                  ))}
                </ul>
              </div>
            </div>

            {/* Impact Badges */}
            <div className="flex flex-wrap items-center gap-2 pt-1 text-xs">
              <span className="text-slate-400 text-xs font-heading font-medium">مستوى التأثير:</span>
              <span className="inline-flex items-center gap-1.5 bg-slate-900 px-2.5 py-1 rounded-lg border border-slate-800 text-slate-300">
                <ShieldAlert className="w-3 h-3 text-rose-400" />
                الأمان: <strong className="text-slate-100">{fault.impactOnVehicle.safety}</strong>
              </span>
              <span className="inline-flex items-center gap-1.5 bg-slate-900 px-2.5 py-1 rounded-lg border border-slate-800 text-slate-300">
                <Fuel className="w-3 h-3 text-amber-400" />
                الوقود: <strong className="text-slate-100">{fault.impactOnVehicle.fuelEconomy}</strong>
              </span>
              <span className="inline-flex items-center gap-1.5 bg-slate-900 px-2.5 py-1 rounded-lg border border-slate-800 text-slate-300">
                <Gauge className="w-3 h-3 text-blue-400" />
                القيادة: <strong className="text-slate-100">{fault.impactOnVehicle.drivability}</strong>
              </span>
            </div>

            {/* Recommended Action, Pinout & Spare Part Button */}
            <div className="bg-slate-900 border border-slate-800 p-3.5 rounded-xl flex flex-col sm:flex-row items-start sm:items-center justify-between gap-3">
              <div className="text-xs text-slate-200">
                <strong className="block text-amber-400 font-bold mb-0.5 font-heading">
                  توجيه الفني الفاحص:
                </strong>
                {fault.recommendedAction}
              </div>

              <div className="flex items-center gap-2 shrink-0 w-full sm:w-auto">
                <button
                  onClick={() => setShowLocatorModal(true)}
                  className="bg-slate-800 hover:bg-slate-700 text-amber-300 text-xs font-bold px-3 py-2 rounded-lg transition-colors cursor-pointer flex items-center gap-1.5 font-heading border border-amber-500/30 flex-1 sm:flex-initial justify-center"
                >
                  <Zap className="w-3.5 h-3.5 text-amber-400" />
                  مخطط الفيوز والفيشة 🔌
                </button>

                {fault.recommendedPartId && (
                  <button
                    onClick={() => onSelectPart?.(fault.recommendedPartId)}
                    className="bg-blue-600 hover:bg-blue-500 text-white text-xs font-bold px-3.5 py-2 rounded-lg transition-colors cursor-pointer flex items-center gap-1.5 font-heading flex-1 sm:flex-initial justify-center"
                  >
                    <Package className="w-3.5 h-3.5" />
                    عرض قطعة الغيار
                  </button>
                )}
              </div>
            </div>
          </div>
        )}
      </div>

      {/* Sensor & Fuse Locator Modal */}
      {showLocatorModal && (
        <SensorFuseLocatorModal
          fault={fault}
          vehicleMake={vehicleMake}
          vehicleModel={vehicleModel}
          onClose={() => setShowLocatorModal(false)}
        />
      )}
    </>
  );
};
