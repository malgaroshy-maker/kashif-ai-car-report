"use client";

import * as React from "react";
import Image from "next/image";
import { Sheet } from "@/components/ui/Sheet";
import { DASHBOARD_LIGHTS, type DashboardLightItem } from "@/lib/dashboard-lights";

export function DashboardLightsPanel({ onClose }: { onClose: () => void }) {
  const [search, setSearch] = React.useState("");
  const [activeTab, setActiveTab] = React.useState<"all" | "critical" | "warning" | "info">("all");
  const [showChart, setShowChart] = React.useState(false);
  const [selectedLight, setSelectedLight] = React.useState<DashboardLightItem | null>(null);

  const filtered = React.useMemo(() => {
    const q = search.trim().toLowerCase();
    const queryNum = parseInt(q.replace("#", ""), 10);

    return DASHBOARD_LIGHTS.filter((item) => {
      if (activeTab !== "all" && item.severity !== activeTab) {
        return false;
      }
      if (!q) return true;
      if (!isNaN(queryNum) && item.number === queryNum) return true;

      return (
        item.nameArabic.toLowerCase().includes(q) ||
        item.nameEnglish.toLowerCase().includes(q) ||
        item.meaningArabic.toLowerCase().includes(q) ||
        item.symbolCode.toLowerCase().includes(q) ||
        item.associatedDTCs.some((c) => c.toLowerCase().includes(q))
      );
    });
  }, [search, activeTab]);

  return (
    <Sheet
      title="موسوعة لمبات ومؤشرات الطبلون (64 علامة تحذيرية معتمدة)"
      onClose={onClose}
    >
      <div className="space-y-[var(--s4)]">
        {/* Navigation & Controls Bar */}
        <div className="flex flex-wrap items-center justify-between gap-[var(--s2)] border-b border-[var(--rib)] pb-[var(--s3)]">
          <div className="flex flex-wrap items-center gap-[var(--s2)]">
            <button
              onClick={() => setActiveTab("all")}
              className={`rounded px-3 py-1.5 text-xs font-bold transition ${
                activeTab === "all"
                  ? "bg-[var(--royal-blue)] text-white"
                  : "border border-[var(--rib)] hover:bg-[var(--board-sunk)]"
              }`}
            >
              الكل (64)
            </button>
            <button
              onClick={() => setActiveTab("critical")}
              className={`rounded px-3 py-1.5 text-xs font-bold transition ${
                activeTab === "critical"
                  ? "bg-red-600 text-white"
                  : "border border-red-500/30 text-red-500 hover:bg-red-500/10"
              }`}
            >
              🔴 حرجة (توقف فوراً)
            </button>
            <button
              onClick={() => setActiveTab("warning")}
              className={`rounded px-3 py-1.5 text-xs font-bold transition ${
                activeTab === "warning"
                  ? "bg-amber-600 text-white"
                  : "border border-amber-500/30 text-amber-500 hover:bg-amber-500/10"
              }`}
            >
              🟡 تحذيرية (افحص بالورشة)
            </button>
            <button
              onClick={() => setActiveTab("info")}
              className={`rounded px-3 py-1.5 text-xs font-bold transition ${
                activeTab === "info"
                  ? "bg-emerald-600 text-white"
                  : "border border-emerald-500/30 text-emerald-500 hover:bg-emerald-500/10"
              }`}
            >
              🟢 إرشادية وتشغيلية
            </button>
          </div>

          <button
            onClick={() => setShowChart((v) => !v)}
            className="inline-flex items-center gap-1.5 rounded border border-[var(--gold-primary)]/50 bg-[var(--gold-primary)]/10 px-3 py-1.5 text-xs font-bold text-[var(--gold-primary)] transition hover:bg-[var(--gold-primary)]/20"
          >
            <span>📊</span>
            <span>{showChart ? "إخفاء المخطط المصور" : "عرض المخطط المصور للطبلون"}</span>
          </button>
        </div>

        {/* Visual Chart Section */}
        {showChart && (
          <div className="space-y-4 rounded-lg border border-[var(--rib)] bg-[var(--board-sunk)] p-4">
            <h4 className="text-sm font-bold text-(color:--ink)">
              مخطط لمبات الطبلون الـ 64 المعتمد دولياً:
            </h4>
            <div className="relative aspect-video w-full overflow-hidden rounded border border-[var(--rib)] bg-black/20">
              <Image
                src="/images/dashboard_lights_chart_64.jpg"
                alt="مخطط لمبات الطبلون الـ 64"
                fill
                className="object-contain"
                sizes="(max-width: 1200px) 100vw, 1200px"
              />
            </div>
            <div className="relative aspect-2/1 w-full overflow-hidden rounded border border-[var(--rib)] bg-black/20">
              <Image
                src="/images/dashboard_lights_cluster_diagram.jpg"
                alt="موقع لمبات الطبلون في العداد"
                fill
                className="object-contain"
                sizes="(max-width: 1200px) 100vw, 1200px"
              />
            </div>
          </div>
        )}

        {/* Search input */}
        <div className="relative">
          <input
            type="search"
            value={search}
            onChange={(e) => setSearch(e.target.value)}
            placeholder="ابحث برقم اللمبة (مثلاً 54)، أو اسمها (حرارة الزيت، البطارية، الدومان)، أو كود العطل (P0700)..."
            className="min-h-[var(--tap)] w-full rounded border border-[var(--rib)] bg-[var(--cell)] px-4 text-sm text-(color:--ink) outline-none focus:border-[var(--royal-blue)]"
          />
        </div>

        {/* Modal Sheet for Details if a light is selected */}
        {selectedLight && (
          <div className="rounded-lg border-2 border-[var(--gold-primary)] bg-[var(--cell)] p-4 shadow-xl">
            <div className="flex items-start justify-between border-b border-[var(--rib)] pb-3">
              <div className="flex items-center gap-3">
                <div className="relative flex h-14 w-14 shrink-0 items-center justify-center rounded-xl border border-[var(--gold-primary)]/50 bg-black/60 p-1.5 shadow-md">
                  <img
                    src={`/lights/light_${selectedLight.number}.png`}
                    alt={selectedLight.nameArabic}
                    className="h-full w-full object-contain"
                  />
                </div>
                <div>
                  <div className="flex items-center gap-2">
                    <span className="rounded bg-[var(--royal-blue)]/20 px-1.5 py-0.5 font-mono text-xs font-black text-[var(--royal-blue-light)]">
                      #{selectedLight.number}
                    </span>
                  </div>
                  <h3 className="text-base font-bold text-(color:--ink)">
                    {selectedLight.nameArabic}
                  </h3>
                  <p className="font-mono text-xs text-(color:--ink-2)">
                    {selectedLight.nameEnglish} • {selectedLight.symbolCode}
                  </p>
                </div>
              </div>
              <button
                onClick={() => setSelectedLight(null)}
                className="rounded p-1 text-sm font-bold text-(color:--ink-2) hover:bg-[var(--board-sunk)]"
              >
                ✕ إغلاق
              </button>
            </div>

            <div className="mt-3 space-y-3 text-sm">
              <div className="flex flex-wrap items-center gap-2">
                <span
                  className={`rounded px-2.5 py-1 text-xs font-bold ${
                    selectedLight.severity === "critical"
                      ? "bg-red-500/20 text-red-500"
                      : selectedLight.severity === "warning"
                      ? "bg-amber-500/20 text-amber-500"
                      : "bg-emerald-500/20 text-emerald-500"
                  }`}
                >
                  {selectedLight.severity === "critical"
                    ? "🔴 مستوى الخطر: عالي جداً"
                    : selectedLight.severity === "warning"
                    ? "🟡 مستوى الخطر: تحذيري متوسط"
                    : "🟢 مستوى الخطر: تشغيلي عادي"}
                </span>

                <span className="rounded bg-[var(--board-sunk)] px-2.5 py-1 text-xs font-semibold text-(color:--ink)">
                  {selectedLight.canDrive === "stopImmediately"
                    ? "⛔ توقف فوراً في مكان آمن ولا تواصل السير"
                    : selectedLight.canDrive === "driveCarefully"
                    ? "⚠️ يمكنك المتابعة بحذر شديد حتى أقرب ورشة"
                    : "🟢 حالة قيادة طبيعية وآمنة"}
                </span>
              </div>

              <div>
                <h5 className="font-bold text-(color:--ink)">المعنى والتشخيص الفني:</h5>
                <p className="mt-1 leading-relaxed text-(color:--ink-2)">
                  {selectedLight.meaningArabic}
                </p>
              </div>

              {selectedLight.commonCauses.length > 0 && (
                <div>
                  <h5 className="font-bold text-(color:--ink)">الأسباب الشائعة للعطل:</h5>
                  <ul className="mt-1 list-inside list-disc space-y-1 text-(color:--ink-2)">
                    {selectedLight.commonCauses.map((cause, i) => (
                      <li key={i}>{cause}</li>
                    ))}
                  </ul>
                </div>
              )}

              <div>
                <h5 className="font-bold text-(color:--ink)">الإجراء المطلوب من السائق والفني:</h5>
                <p className="mt-1 leading-relaxed text-amber-600 dark:text-amber-400 font-medium">
                  {selectedLight.actionRequired}
                </p>
              </div>

              {selectedLight.associatedDTCs.length > 0 && (
                <div>
                  <h5 className="font-bold text-(color:--ink)">أكواد الفحص المرتبطة (OBD-II DTCs):</h5>
                  <div className="mt-1.5 flex flex-wrap gap-1.5">
                    {selectedLight.associatedDTCs.map((dtc) => (
                      <span
                        key={dtc}
                        className="rounded border border-[var(--rib)] bg-[var(--board-sunk)] px-2 py-0.5 font-mono text-xs font-bold text-[var(--royal-blue-light)]"
                      >
                        {dtc}
                      </span>
                    ))}
                  </div>
                </div>
              )}
            </div>
          </div>
        )}

        {/* Lights Grid */}
        <div className="grid grid-cols-1 gap-2.5 sm:grid-cols-2 md:grid-cols-3">
          {filtered.map((light) => {
            const isSelected = selectedLight?.number === light.number;
            return (
              <div
                key={light.id}
                onClick={() => setSelectedLight(light)}
                className={`cursor-pointer rounded-lg border p-3 transition hover:shadow-md ${
                  isSelected
                    ? "border-[var(--gold-primary)] bg-[var(--board-sunk)] shadow-sm"
                    : "border-[var(--rib)] bg-[var(--cell)] hover:border-[var(--royal-blue)]"
                }`}
              >
                <div className="flex items-start justify-between gap-2">
                  <div className="flex items-center gap-2.5">
                    <div className="relative flex h-9 w-9 shrink-0 items-center justify-center rounded-lg border border-slate-700/60 bg-black/50 p-1 shadow-inner">
                      <img
                        src={`/lights/light_${light.number}.png`}
                        alt={light.nameArabic}
                        className="h-full w-full object-contain"
                        loading="lazy"
                        onError={(e) => {
                          (e.target as HTMLElement).style.display = "none";
                        }}
                      />
                    </div>
                    <div>
                      <div className="flex items-center gap-1.5">
                        <span className="font-mono text-[10px] font-bold text-(color:--ink-3)">
                          #{light.number}
                        </span>
                        <span
                          className="h-2 w-2 shrink-0 rounded-full"
                          style={{ backgroundColor: light.colorHex }}
                          title={light.severity}
                        />
                      </div>
                      <h4 className="line-clamp-1 text-xs font-bold text-(color:--ink)">
                        {light.nameArabic}
                      </h4>
                    </div>
                  </div>
                  <span className="shrink-0 text-[10px] font-mono font-semibold text-(color:--ink-3)">
                    {light.symbolCode}
                  </span>
                </div>

                <p className="mt-2 line-clamp-2 text-[11px] leading-relaxed text-(color:--ink-2)">
                  {light.meaningArabic}
                </p>

                <div className="mt-2.5 flex items-center justify-between border-t border-[var(--rib)] pt-1.5 text-[10px]">
                  <span
                    className={
                      light.severity === "critical"
                        ? "font-bold text-red-500"
                        : light.severity === "warning"
                        ? "font-bold text-amber-500"
                        : "font-bold text-emerald-500"
                    }
                  >
                    {light.canDrive === "stopImmediately"
                      ? "⛔ توقف فوراً"
                      : light.canDrive === "driveCarefully"
                      ? "⚠️ قد بحذر"
                      : "🟢 عادي"}
                  </span>
                  {light.associatedDTCs.length > 0 && (
                    <span className="font-mono text-[9px] text-(color:--ink-3)">
                      {light.associatedDTCs.slice(0, 2).join(", ")}
                      {light.associatedDTCs.length > 2 ? "..." : ""}
                    </span>
                  )}
                </div>
              </div>
            );
          })}
        </div>

        {filtered.length === 0 && (
          <div className="py-12 text-center text-(color:--ink-2)">
            <p className="text-base font-bold">لا توجد لمبة تطابق بحثك</p>
            <p className="mt-1 text-xs">جرب البحث برقم اللمبة من 1 إلى 64 أو اسم العطل</p>
          </div>
        )}
      </div>
    </Sheet>
  );
}
