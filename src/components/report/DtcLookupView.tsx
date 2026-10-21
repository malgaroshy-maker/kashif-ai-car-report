"use client";

import React, { useState, useMemo } from "react";
import {
  OFFLINE_DTC_DATABASE,
  QUICK_CODES,
  OfflineDtcKnowledge,
} from "@/lib/offline-dtc";
import { CodePlate, Button } from "@/components/ui/primitives";

interface DtcLookupViewProps {
  onGenerateReport?: (codes: string[]) => void;
  onOpenFuseMap?: (code?: string) => void;
}

export function DtcLookupView({
  onGenerateReport,
  onOpenFuseMap,
}: DtcLookupViewProps) {
  const [searchQuery, setSearchQuery] = useState("");
  const [selectedCategory, setSelectedCategory] = useState<
    "all" | "P" | "C" | "B" | "U"
  >("all");
  const [selectedBasket, setSelectedBasket] = useState<string[]>([]);
  const [expandedCode, setExpandedCode] = useState<string | null>(null);

  const categories = [
    { id: "all", label: "الكل" },
    { id: "P", label: "المحرك (P)" },
    { id: "C", label: "الهيكل والفرامل (C)" },
    { id: "B", label: "الهيكل والوسائد (B)" },
    { id: "U", label: "الشبكة والاتصال (U)" },
  ] as const;

  const toggleBasket = (code: string) => {
    setSelectedBasket((prev) =>
      prev.includes(code) ? prev.filter((c) => c !== code) : [...prev, code]
    );
  };

  const handleGenerate = (codes: string[]) => {
    if (codes.length === 0) return;
    if (onGenerateReport) {
      onGenerateReport(codes);
    }
  };

  const filteredList = useMemo(() => {
    const q = searchQuery.trim().toLowerCase();
    return OFFLINE_DTC_DATABASE.filter((item) => {
      if (selectedCategory !== "all" && !item.code.startsWith(selectedCategory)) {
        return false;
      }
      if (!q) return true;
      return (
        item.code.toLowerCase().includes(q) ||
        item.libyanTerm.toLowerCase().includes(q) ||
        item.standardArabicDescription.toLowerCase().includes(q) ||
        item.standardDescriptionEn.toLowerCase().includes(q) ||
        item.module.toLowerCase().includes(q) ||
        item.driverSymptoms.some((s) => s.toLowerCase().includes(q)) ||
        item.rootCauses.some((r) => r.toLowerCase().includes(q)) ||
        (item.partNameLibyan && item.partNameLibyan.toLowerCase().includes(q))
      );
    });
  }, [searchQuery, selectedCategory]);

  const cleanQuery = searchQuery.trim().toUpperCase();
  const isExactInDb = OFFLINE_DTC_DATABASE.some((k) => k.code === cleanQuery);
  const isObdPattern = /^[PCBU][0-9A-F]{4}$/.test(cleanQuery);
  const showCustomPrompt = isObdPattern && !isExactInDb;

  return (
    <div className="space-y-[var(--s4)]">
      {/* Header Banner */}
      <div className="flex flex-wrap items-center justify-between gap-3 rounded-xl border border-[var(--rib)] bg-[var(--cell)] p-4 shadow-sm">
        <div>
          <div className="flex items-center gap-2">
            <span className="flex h-7 w-7 items-center justify-center rounded-lg bg-[var(--royal-blue)] text-xs font-black text-white">
              DTC
            </span>
            <h2 className="text-base font-bold text-(color:--ink)">
              موسوعة وفاحص أكواد الأعطال (OBD-II Encyclopedia)
            </h2>
          </div>
          <p className="mt-1 text-xs text-(color:--ink-2)">
            دليل تشخيصي شامل لمصطلحات الورش الليبية مع الأعراض الشائعة والقطع والأسعار التقديرية بالدينار
          </p>
        </div>

        {/* Selected Basket Action */}
        {selectedBasket.length > 0 && (
          <div className="flex items-center gap-2 rounded-lg border border-[var(--gold-primary)]/50 bg-[var(--gold-primary)]/10 px-3 py-2">
            <div className="text-xs">
              <span className="font-bold text-(color:--ink)">سلة الفحص:</span>{" "}
              <span className="font-mono font-bold text-amber-500">
                {selectedBasket.length} أكواد
              </span>
            </div>
            <button
              onClick={() => handleGenerate(selectedBasket)}
              className="inline-flex items-center gap-1.5 rounded bg-[var(--royal-blue)] px-3 py-1.5 text-xs font-bold text-white shadow-sm transition hover:bg-[var(--royal-blue-electric)]"
            >
              <span>⚡</span>
              <span>تحليل وبناء تقرير فحص</span>
            </button>
            <button
              onClick={() => setSelectedBasket([])}
              className="text-xs text-(color:--ink-3) hover:text-(color:--ink)"
              title="إفراغ السلة"
            >
              ✕
            </button>
          </div>
        )}
      </div>

      {/* Search Input & Quick Chips */}
      <div className="space-y-3 rounded-xl border border-[var(--rib)] bg-[var(--board-sunk)] p-4">
        <div className="relative">
          <input
            type="search"
            value={searchQuery}
            onChange={(e) => setSearchQuery(e.target.value)}
            placeholder="ابحث بكود العطل (P0300، P0171، C0035...) أو اسم القطعة، أو العرض (خنقة، فطفطة، تفتفة)..."
            className="min-h-[var(--tap)] w-full rounded-lg border border-[var(--rib)] bg-[var(--cell)] px-4 text-sm text-(color:--ink) outline-none focus:border-[var(--royal-blue)]"
          />
        </div>

        {/* Categories Tabs & Quick Code Chips */}
        <div className="flex flex-wrap items-center justify-between gap-2 pt-1">
          {/* Categories */}
          <div className="flex flex-wrap items-center gap-1.5">
            {categories.map((cat) => (
              <button
                key={cat.id}
                onClick={() => setSelectedCategory(cat.id)}
                className={`rounded-md px-3 py-1 text-xs font-bold transition border ${
                  selectedCategory === cat.id
                    ? "border-[var(--royal-blue)] bg-[var(--royal-blue)] text-white shadow-sm"
                    : "border-[var(--rib)] bg-[var(--cell)] text-(color:--ink-2) hover:text-(color:--ink)"
                }`}
              >
                {cat.label}
              </button>
            ))}
          </div>

          {/* Quick Common Codes */}
          <div className="flex flex-wrap items-center gap-1.5 text-xs">
            <span className="text-[11px] font-semibold text-(color:--ink-3)">أكواد شائعة:</span>
            {QUICK_CODES.map((code) => (
              <button
                key={code}
                onClick={() => setSearchQuery(code)}
                className="rounded border border-[var(--rib)] bg-[var(--cell)] px-2 py-0.5 font-mono text-[11px] font-bold text-[var(--royal-blue-light)] hover:border-[var(--royal-blue)]"
              >
                {code}
              </button>
            ))}
          </div>
        </div>
      </div>

      {/* Custom OBD Code Prompt */}
      {showCustomPrompt && (
        <div className="flex items-center justify-between rounded-lg border border-amber-500/40 bg-amber-500/10 p-3 text-xs">
          <div>
            <span className="font-bold text-amber-500">كود مخصص [{cleanQuery}]:</span>{" "}
            <span className="text-(color:--ink-2)">
              الكود غير مسجل في الموسوعة المدمجة، ولكن يمكنك إضافته للسلة لتحليله آلياً بالمساعد الذكي
            </span>
          </div>
          <button
            onClick={() => {
              toggleBasket(cleanQuery);
              setSearchQuery("");
            }}
            className="rounded bg-amber-500 px-3 py-1 font-bold text-black transition hover:bg-amber-400"
          >
            {selectedBasket.includes(cleanQuery) ? "✓ مضاف في السلة" : "+ إضافة للسلة"}
          </button>
        </div>
      )}

      {/* Results Count */}
      <div className="flex items-center justify-between text-xs text-(color:--ink-3) px-1">
        <span>نتائج البحث: {filteredList.length} عطل</span>
        {selectedBasket.length > 0 && (
          <span className="font-bold text-amber-500">
            الأكواد في السلة: {selectedBasket.join(", ")}
          </span>
        )}
      </div>

      {/* DTC Cards Grid */}
      <div className="grid grid-cols-1 gap-3 md:grid-cols-2">
        {filteredList.map((dtc) => {
          const isExpanded = expandedCode === dtc.code;
          const isInBasket = selectedBasket.includes(dtc.code);

          const severityBadge =
            dtc.severity === "critical"
              ? { label: "عطل حرج 10A", bg: "bg-red-500/15 text-red-500 border-red-500/30" }
              : dtc.severity === "moderate"
              ? { label: "عطل متوسط 20A", bg: "bg-amber-500/15 text-amber-500 border-amber-500/30" }
              : { label: "مسجل 25A", bg: "bg-slate-500/15 text-slate-400 border-slate-500/30" };

          return (
            <div
              key={dtc.code}
              className={`rounded-xl border p-4 transition ${
                isInBasket
                  ? "border-[var(--gold-primary)] bg-[var(--cell)] shadow-md"
                  : "border-[var(--rib)] bg-[var(--cell)] hover:border-[var(--royal-blue-light)]"
              }`}
            >
              {/* Top Row: Code, Module, Severity, Basket Checkbox */}
              <div className="flex items-start justify-between gap-2 border-b border-[var(--rib)] pb-2.5">
                <div className="flex items-center gap-2">
                  <span className="rounded bg-[var(--royal-blue)] px-2.5 py-1 font-mono text-sm font-black text-white">
                    {dtc.code}
                  </span>
                  <span className="rounded bg-[var(--board-sunk)] px-2 py-0.5 font-mono text-[11px] font-bold text-(color:--ink-2)">
                    {dtc.module}
                  </span>
                  <span
                    className={`rounded border px-2 py-0.5 text-[10px] font-bold ${severityBadge.bg}`}
                  >
                    {severityBadge.label}
                  </span>
                </div>

                <div className="flex items-center gap-2">
                  <button
                    type="button"
                    onClick={() => toggleBasket(dtc.code)}
                    className={`rounded-md px-2.5 py-1 text-xs font-bold transition border ${
                      isInBasket
                        ? "bg-amber-500 text-black border-amber-600"
                        : "border-[var(--rib)] bg-[var(--board-sunk)] text-(color:--ink-2) hover:text-(color:--ink)"
                    }`}
                  >
                    {isInBasket ? "✓ في السلة" : "+ سلة"}
                  </button>
                  <button
                    type="button"
                    onClick={() => handleGenerate([dtc.code])}
                    className="rounded-md border border-[var(--royal-blue-light)]/40 bg-[var(--royal-blue)]/10 px-2.5 py-1 text-xs font-bold text-[var(--royal-blue-light)] transition hover:bg-[var(--royal-blue)]/20"
                    title="تحليل مباشر لهذا الكود"
                  >
                    ⚡ فحص
                  </button>
                </div>
              </div>

              {/* Middle Row: Titles */}
              <div className="mt-2.5 space-y-1">
                <h3 className="text-sm font-bold text-(color:--ink) leading-snug">
                  {dtc.libyanTerm}
                </h3>
                <p className="text-xs text-(color:--ink-2) leading-relaxed">
                  {dtc.standardArabicDescription}
                </p>
                <p className="font-mono text-[11px] text-(color:--ink-3)">
                  {dtc.standardDescriptionEn}
                </p>
              </div>

              {/* Symptoms Chips */}
              {dtc.driverSymptoms.length > 0 && (
                <div className="mt-3 flex flex-wrap gap-1.5">
                  {dtc.driverSymptoms.map((sym, idx) => (
                    <span
                      key={idx}
                      className="rounded bg-[var(--board-sunk)] px-2 py-0.5 text-[11px] text-(color:--ink-2) border border-[var(--rib)]"
                    >
                      {sym}
                    </span>
                  ))}
                </div>
              )}

              {/* Expand Toggle */}
              <button
                type="button"
                onClick={() => setExpandedCode(isExpanded ? null : dtc.code)}
                className="mt-3 flex w-full items-center justify-between border-t border-[var(--rib)] pt-2 text-xs font-bold text-[var(--royal-blue-light)] hover:underline"
              >
                <span>{isExpanded ? "إخفاء التفاصيل الفنية ▲" : "عرض الأسباب والحلول وقطع الغيار ▼"}</span>
                {dtc.partPriceMin && (
                  <span className="font-mono text-[11px] text-amber-500">
                    تقريباً {dtc.partPriceMin} - {dtc.partPriceMax} د.ل
                  </span>
                )}
              </button>

              {/* Expanded Details */}
              {isExpanded && (
                <div className="mt-3 space-y-2.5 rounded-lg border border-[var(--rib)] bg-[var(--board-sunk)] p-3 text-xs">
                  {/* Causes */}
                  {dtc.rootCauses.length > 0 && (
                    <div>
                      <h4 className="font-bold text-(color:--ink) mb-1">الأسباب المحتملة:</h4>
                      <ul className="list-inside list-disc space-y-0.5 text-(color:--ink-2)">
                        {dtc.rootCauses.map((cause, i) => (
                          <li key={i}>{cause}</li>
                        ))}
                      </ul>
                    </div>
                  )}

                  {/* Recommended Action */}
                  {dtc.recommendedAction && (
                    <div>
                      <h4 className="font-bold text-(color:--ink) mb-0.5">خطوة الفحص الموصى بها:</h4>
                      <p className="text-amber-500 font-medium leading-relaxed">
                        {dtc.recommendedAction}
                      </p>
                    </div>
                  )}

                  {/* Spare Part & Price */}
                  {dtc.partNameLibyan && (
                    <div className="border-t border-[var(--rib)] pt-2 flex flex-wrap items-center justify-between gap-2">
                      <div>
                        <span className="text-(color:--ink-3)">القطعة المطلوبة:</span>{" "}
                        <strong className="text-(color:--ink)">{dtc.partNameLibyan}</strong>
                        {dtc.partNameEnglish && (
                          <span className="font-mono text-[10px] text-(color:--ink-3) mr-1">
                            ({dtc.partNameEnglish})
                          </span>
                        )}
                      </div>
                      {dtc.partPriceMin && (
                        <div className="font-mono font-bold text-amber-500">
                          {dtc.partPriceMin} - {dtc.partPriceMax} د.ل
                        </div>
                      )}
                    </div>
                  )}

                  {/* Aftermarket Brands */}
                  {dtc.aftermarketBrands && dtc.aftermarketBrands.length > 0 && (
                    <div className="text-[11px] text-(color:--ink-3)">
                      <span>الماركات المعتمدة: </span>
                      <span className="font-mono text-(color:--ink-2)">
                        {dtc.aftermarketBrands.join(" • ")}
                      </span>
                    </div>
                  )}

                  {onOpenFuseMap && (
                    <button
                      type="button"
                      onClick={() => onOpenFuseMap(dtc.code)}
                      className="mt-1 inline-flex items-center gap-1 text-[11px] font-bold text-cyan-400 hover:underline"
                    >
                      <span>⚡ فحص فيوز وريلي هذا العطل في خريطة الفيوزات</span>
                    </button>
                  )}
                </div>
              )}
            </div>
          );
        })}
      </div>

      {filteredList.length === 0 && (
        <div className="rounded-xl border border-[var(--rib)] bg-[var(--cell)] p-12 text-center text-(color:--ink-2)">
          <p className="text-base font-bold">لا يوجد كود عطل يطابق بحثك</p>
          <p className="mt-1 text-xs">
            يمكنك كتابة كود OBD-II مباشر مثل P0100 أو البحث باسم العطل أو القطعة
          </p>
        </div>
      )}
    </div>
  );
}
