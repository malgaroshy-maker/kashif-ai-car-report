"use client";

import React, { useState, useEffect } from "react";
import {
  Package,
  Copy,
  Check,
  Tag,
  ShoppingBag,
  Layers,
  MapPin,
  Maximize2,
  X,
  ExternalLink,
  ShieldCheck,
  Search,
  RefreshCw,
  ImageIcon,
  Compass,
} from "lucide-react";
import { SparePartItem } from "@/lib/types";
import { getPartSvg } from "@/lib/part-visuals";

interface SparePartsSectionProps {
  spareParts: SparePartItem[];
  selectedPartId?: string;
  vehicleInfo?: {
    make?: string;
    model?: string;
    year?: string | number;
  };
}

export const SparePartsSection: React.FC<SparePartsSectionProps> = ({
  spareParts,
  selectedPartId,
  vehicleInfo,
}) => {
  const [copiedId, setCopiedId] = useState<string | null>(null);
  const [activeImageModal, setActiveImageModal] = useState<SparePartItem | null>(null);
  const [filterCategory, setFilterCategory] = useState<string>("ALL");

  // Dynamic live image search state map: partId -> { url, loading, mode: 'photo' | 'vector' }
  const [partImageMap, setPartImageMap] = useState<
    Record<
      string,
      {
        url: string;
        loading: boolean;
        mode: "photo" | "vector";
      }
    >
  >({});

  // Initialize part images and auto-search missing ones online
  useEffect(() => {
    const list = Array.isArray(spareParts) ? spareParts : [];
    if (list.length === 0) return;

    const initialMap: Record<
      string,
      { url: string; loading: boolean; mode: "photo" | "vector" }
    > = {};

    list.forEach((part) => {
      const hasRealPhoto =
        part.partImageUrl &&
        (part.partImageUrl.startsWith("https://") || part.partImageUrl.startsWith("http://")) &&
        !part.partImageUrl.includes("/parts/");

      initialMap[part.id] = {
        url: hasRealPhoto ? part.partImageUrl! : "",
        loading: false,
        mode: "photo",
      };
    });

    setPartImageMap((prev) => ({ ...initialMap, ...prev }));

    // Trigger auto-search for parts that do not have a live photo
    list.forEach((part) => {
      const hasRealPhoto =
        part.partImageUrl &&
        (part.partImageUrl.startsWith("https://") || part.partImageUrl.startsWith("http://")) &&
        !part.partImageUrl.includes("/parts/");

      if (!hasRealPhoto) {
        fetchPartImageLive(part);
      }
    });
  }, [spareParts, vehicleInfo]);

  // Fetch online image for a specific part
  const fetchPartImageLive = async (part: SparePartItem) => {
    setPartImageMap((prev) => ({
      ...prev,
      [part.id]: {
        url: prev[part.id]?.url || "",
        loading: true,
        mode: "photo",
      },
    }));

    try {
      const params = new URLSearchParams({
        make: vehicleInfo?.make || "",
        model: vehicleInfo?.model || "",
        year: String(vehicleInfo?.year || ""),
        oem: part.oemPartNumber || "",
        partName: part.partNameEnglish || part.partNameLibyan || "",
      });

      const res = await fetch(`/api/parts-image?${params.toString()}`);
      if (res.ok) {
        const data = await res.json();
        if (data.success && data.imageUrl) {
          setPartImageMap((prev) => ({
            ...prev,
            [part.id]: {
              url: data.imageUrl,
              loading: false,
              mode: "photo",
            },
          }));
          return;
        }
      }
    } catch {
      // Fallback
    }

    setPartImageMap((prev) => ({
      ...prev,
      [part.id]: {
        url: prev[part.id]?.url || "",
        loading: false,
        mode: prev[part.id]?.url ? "photo" : "vector",
      },
    }));
  };

  // Toggle between Real Photo & Vector Schematic
  const togglePartVisualMode = (partId: string) => {
    setPartImageMap((prev) => {
      const current = prev[partId] || { url: "", loading: false, mode: "vector" };
      return {
        ...prev,
        [partId]: {
          ...current,
          mode: current.mode === "photo" ? "vector" : "photo",
        },
      };
    });
  };

  // Keyboard accessibility
  useEffect(() => {
    const handleKeyDown = (e: KeyboardEvent) => {
      if (e.key === "Escape") {
        setActiveImageModal(null);
      }
    };
    window.addEventListener("keydown", handleKeyDown);
    return () => window.removeEventListener("keydown", handleKeyDown);
  }, []);

  const handleCopyPartNumber = (text: string, id: string) => {
    navigator.clipboard.writeText(text);
    setCopiedId(id);
    setTimeout(() => setCopiedId(null), 2000);
  };

  const safeParts = Array.isArray(spareParts) ? spareParts : [];

  if (safeParts.length === 0) {
    return null;
  }

  const categories = ["ALL", ...Array.from(new Set(safeParts.map((p) => p.diagramCategory)))];

  const filteredParts =
    filterCategory === "ALL"
      ? safeParts
      : safeParts.filter((p) => p.diagramCategory === filterCategory);

  return (
    <div id="spare-parts-section" className="w-full space-y-4 pt-2">
      {/* Section Header */}
      <div className="flex flex-col sm:flex-row items-start sm:items-center justify-between gap-3 border-b border-slate-800 pb-3">
        <div>
          <h3 className="text-base sm:text-lg font-bold text-white font-heading flex items-center gap-2">
            <Package className="w-4 h-4 text-blue-400" />
            <span>دليل قطع الغيار والصور الحية (OEM Parts Directory)</span>
          </h3>
          <p className="text-xs text-slate-400 mt-0.5">
            صور حقيقية مستخرجة حسب طراز المركبة{" "}
            {vehicleInfo?.make && (
              <span className="text-slate-200 font-mono font-semibold">
                ({vehicleInfo.make} {vehicleInfo.model} {vehicleInfo.year})
              </span>
            )}{" "}
            مع أرقام القطع الأصلية والأسعار بالدينار الليبي
          </p>
        </div>

        {/* Category Filters */}
        <div className="flex items-center gap-1 bg-slate-900 p-1 rounded-xl border border-slate-800 flex-wrap">
          {categories.map((cat) => (
            <button
              key={cat}
              onClick={() => setFilterCategory(cat)}
              className={`text-xs px-3 py-1 rounded-lg font-semibold transition-colors cursor-pointer ${
                filterCategory === cat
                  ? "bg-blue-600 text-white"
                  : "text-slate-400 hover:text-white"
              }`}
            >
              {cat === "ALL" ? "كافة القطع" : `منظومة ${cat}`}
            </button>
          ))}
        </div>
      </div>

      {/* Parts Grid */}
      <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
        {filteredParts.map((part) => {
          const isHighlighted = selectedPartId === part.id;
          const svgCode = getPartSvg(part.partNameLibyan || part.partNameEnglish, part.oemPartNumber);
          const state = partImageMap[part.id] || { url: "", loading: false, mode: "photo" };
          const hasPhotoUrl = Boolean(state.url);
          const isPhotoMode = state.mode === "photo" && hasPhotoUrl;

          return (
            <div
              key={part.id}
              id={part.id}
              className={`rounded-xl p-4.5 border transition-colors flex flex-col justify-between ${
                isHighlighted
                  ? "border-amber-500 bg-[#0F172A] ring-1 ring-amber-500/40"
                  : "border-slate-800 bg-[#0D121F] hover:border-slate-700"
              }`}
            >
              <div className="space-y-3.5">
                {/* Part Category & Related Code */}
                <div className="flex items-center justify-between gap-2">
                  <span className="text-[11px] font-semibold text-blue-300 bg-slate-800/80 px-2.5 py-0.5 rounded border border-slate-700 font-mono flex items-center gap-1.5">
                    <Layers className="w-3 h-3 text-blue-400" />
                    منظومة {part.diagramCategory}
                  </span>
                  <span className="text-[11px] font-mono font-bold text-amber-400 bg-slate-900 px-2 py-0.5 rounded border border-slate-800">
                    كود: {part.relatedCode}
                  </span>
                </div>

                {/* Part Visual & Details Header */}
                <div className="flex gap-3.5">
                  {/* Visual Thumbnail */}
                  <div className="flex flex-col items-center gap-1.5 shrink-0">
                    <div
                      onClick={() => setActiveImageModal(part)}
                      className="relative w-28 h-28 sm:w-32 sm:h-32 rounded-xl overflow-hidden bg-slate-950 border border-slate-800 shrink-0 cursor-pointer group/img flex items-center justify-center p-1 hover:border-slate-600 transition-colors"
                      title="انقر لتكبير صورة القطعة"
                    >
                      {state.loading ? (
                        <div className="flex flex-col items-center justify-center gap-1.5 p-2 text-center">
                          <RefreshCw className="w-5 h-5 text-blue-400 animate-spin" />
                          <span className="text-[9px] text-slate-400 font-sans">
                            جلب من الويب...
                          </span>
                        </div>
                      ) : isPhotoMode ? (
                        <img
                          src={state.url}
                          alt={part.partNameLibyan}
                          referrerPolicy="no-referrer"
                          loading="lazy"
                          onError={() => {
                            setPartImageMap((prev) => ({
                              ...prev,
                              [part.id]: { ...state, mode: "vector" },
                            }));
                          }}
                          className="w-full h-full object-contain rounded-lg group-hover/img:scale-105 transition-transform duration-200"
                        />
                      ) : (
                        <div
                          className="w-full h-full flex items-center justify-center rounded-lg overflow-hidden group-hover/img:scale-105 transition-transform duration-200"
                          dangerouslySetInnerHTML={{ __html: svgCode }}
                        />
                      )}

                      {/* Zoom Indicator */}
                      <div className="absolute inset-0 bg-slate-950/60 opacity-0 group-hover/img:opacity-100 transition-opacity flex items-center justify-center gap-1">
                        <Maximize2 className="w-4 h-4 text-white" />
                      </div>

                      {/* Photo/Vector Badge */}
                      <span className="absolute top-1 right-1 text-[8px] bg-slate-900/90 text-slate-300 px-1 py-0.5 rounded font-mono border border-slate-700">
                        {isPhotoMode ? "LIVE PHOTO" : "VECTOR"}
                      </span>
                    </div>

                    {/* Toggle Controls */}
                    <div className="flex items-center gap-1">
                      {hasPhotoUrl && (
                        <button
                          onClick={(e) => {
                            e.stopPropagation();
                            togglePartVisualMode(part.id);
                          }}
                          className="text-[9px] bg-slate-900 hover:bg-slate-800 text-slate-300 px-1.5 py-0.5 rounded border border-slate-800 transition-colors cursor-pointer flex items-center gap-1"
                        >
                          {state.mode === "photo" ? (
                            <>
                              <Compass className="w-2.5 h-2.5 text-blue-400" />
                              <span>رسم</span>
                            </>
                          ) : (
                            <>
                              <ImageIcon className="w-2.5 h-2.5 text-emerald-400" />
                              <span>صورة</span>
                            </>
                          )}
                        </button>
                      )}

                      <button
                        onClick={(e) => {
                          e.stopPropagation();
                          fetchPartImageLive(part);
                        }}
                        disabled={state.loading}
                        className="text-[9px] bg-slate-900 hover:bg-slate-800 text-slate-400 hover:text-white p-1 rounded border border-slate-800 transition-colors cursor-pointer"
                        title="إعادة البحث عن صورة جديدة"
                      >
                        <RefreshCw
                          className={`w-2.5 h-2.5 ${state.loading ? "animate-spin text-blue-400" : ""}`}
                        />
                      </button>
                    </div>
                  </div>

                  <div className="flex-1 min-w-0">
                    <h4 className="text-sm sm:text-base font-bold text-white font-heading leading-snug">
                      {part.partNameLibyan}
                    </h4>
                    <p className="text-xs text-slate-300 mt-0.5 line-clamp-1">
                      {part.partNameStandardArabic}
                    </p>
                    <p className="text-[11px] font-mono text-slate-400 mt-0.5">
                      {part.partNameEnglish}
                    </p>

                    <div className="mt-2 flex items-center gap-1.5 text-[11px] text-emerald-400 font-medium bg-emerald-950/60 px-2 py-0.5 rounded border border-emerald-800/60 w-fit">
                      <ShieldCheck className="w-3 h-3" />
                      <span>مطابقة لمعايير الوكالة</span>
                    </div>
                  </div>
                </div>

                {/* OEM Part Number Box */}
                <div className="bg-slate-950 p-2.5 rounded-lg border border-slate-800">
                  <div className="flex items-center justify-between text-xs text-slate-400 mb-1">
                    <span className="font-semibold text-slate-300 flex items-center gap-1 font-heading">
                      <Tag className="w-3 h-3 text-blue-400" />
                      رقم القطعة الأصلي (OEM):
                    </span>
                    <div className="flex items-center gap-1">
                      <a
                        href={`https://www.google.com/search?q=${encodeURIComponent(
                          `${vehicleInfo?.make || ""} ${vehicleInfo?.model || ""} ${part.oemPartNumber} auto part`
                        )}`}
                        target="_blank"
                        rel="noreferrer"
                        className="text-slate-400 hover:text-white flex items-center gap-1 text-[10px] font-mono bg-slate-900 px-1.5 py-0.5 rounded border border-slate-800"
                      >
                        <Search className="w-2.5 h-2.5 text-blue-400" />
                        <span>بحث</span>
                      </a>

                      <button
                        onClick={() => handleCopyPartNumber(part.oemPartNumber, part.id)}
                        className="text-slate-400 hover:text-white flex items-center gap-1 text-[10px] font-mono bg-slate-900 px-1.5 py-0.5 rounded border border-slate-800 cursor-pointer"
                      >
                        {copiedId === part.id ? (
                          <>
                            <Check className="w-2.5 h-2.5 text-emerald-400" />
                            <span className="text-emerald-400">تم</span>
                          </>
                        ) : (
                          <>
                            <Copy className="w-2.5 h-2.5" />
                            <span>نسخ</span>
                          </>
                        )}
                      </button>
                    </div>
                  </div>
                  <div className="text-xs sm:text-sm font-mono font-bold text-amber-400 tracking-wide">
                    {part.oemPartNumber}
                  </div>
                </div>

                {/* Aftermarket Cross-References */}
                {part.aftermarketReplacements.length > 0 && (
                  <div className="text-xs">
                    <span className="text-slate-400 font-medium block mb-1">
                      الشركات البديلة المعتمدة:
                    </span>
                    <div className="flex flex-wrap gap-1">
                      {part.aftermarketReplacements.map((alt, i) => (
                        <span
                          key={i}
                          className="bg-slate-950 border border-slate-800 text-slate-300 px-2 py-0.5 rounded text-[10px] font-mono"
                        >
                          {alt}
                        </span>
                      ))}
                    </div>
                  </div>
                )}
              </div>

              {/* Price & Libyan Market Guidance Footer */}
              <div className="pt-3 border-t border-slate-800 mt-3 space-y-2">
                <div className="flex items-center justify-between">
                  <span className="text-xs font-semibold text-slate-300 flex items-center gap-1 font-heading">
                    <ShoppingBag className="w-3.5 h-3.5 text-emerald-400" />
                    السعر التقديري في ليبيا:
                  </span>
                  <span className="text-xs font-bold font-mono text-emerald-400 bg-emerald-950/80 px-2.5 py-0.5 rounded border border-emerald-800/80">
                    {part.estimatedPriceRangeLYD.min} - {part.estimatedPriceRangeLYD.max} د.ل
                  </span>
                </div>

                <div className="text-[11px] text-slate-400 bg-slate-950/90 p-2 rounded-lg border border-slate-800 flex items-start gap-1.5">
                  <MapPin className="w-3.5 h-3.5 text-amber-400 mt-0.5 shrink-0" />
                  <span className="leading-relaxed font-sans">
                    {part.estimatedPriceRangeLYD.marketNote}
                  </span>
                </div>
              </div>
            </div>
          );
        })}
      </div>

      {/* Lightbox Modal */}
      {activeImageModal && (
        <div
          onClick={() => setActiveImageModal(null)}
          className="fixed inset-0 z-50 bg-slate-950/80 backdrop-blur-sm flex items-center justify-center p-4"
        >
          <div
            onClick={(e) => e.stopPropagation()}
            className="bg-[#0F172A] border border-slate-700 rounded-2xl max-w-lg w-full p-5 shadow-2xl space-y-4 relative"
          >
            <div className="flex items-center justify-between border-b border-slate-800 pb-3">
              <div>
                <h4 className="text-base font-bold text-white font-heading">
                  {activeImageModal.partNameLibyan}
                </h4>
                <p className="text-xs font-mono text-amber-400">
                  OEM: {activeImageModal.oemPartNumber}
                </p>
              </div>
              <button
                onClick={() => setActiveImageModal(null)}
                className="text-slate-400 hover:text-white p-1 rounded hover:bg-slate-800 cursor-pointer"
              >
                <X className="w-5 h-5" />
              </button>
            </div>

            <div className="rounded-xl overflow-hidden bg-slate-950 border border-slate-800 h-64 flex items-center justify-center p-2">
              {partImageMap[activeImageModal.id]?.url &&
              partImageMap[activeImageModal.id]?.mode === "photo" ? (
                <img
                  src={partImageMap[activeImageModal.id].url}
                  alt={activeImageModal.partNameLibyan}
                  referrerPolicy="no-referrer"
                  loading="lazy"
                  className="w-full h-full object-contain rounded-lg"
                />
              ) : (
                <div
                  className="w-full h-full flex items-center justify-center"
                  dangerouslySetInnerHTML={{
                    __html: getPartSvg(
                      activeImageModal.partNameLibyan || activeImageModal.partNameEnglish,
                      activeImageModal.oemPartNumber
                    ),
                  }}
                />
              )}
            </div>

            <div className="text-xs text-slate-300 bg-slate-950 p-3 rounded-xl border border-slate-800 space-y-1.5">
              <div className="flex justify-between">
                <span className="text-slate-400 font-heading">المنظومة:</span>
                <span className="font-semibold text-slate-200">
                  منظومة {activeImageModal.diagramCategory}
                </span>
              </div>
              <div className="flex justify-between">
                <span className="text-slate-400 font-heading">الاسم القياسي:</span>
                <span className="font-mono text-slate-200">
                  {activeImageModal.partNameStandardArabic} ({activeImageModal.partNameEnglish})
                </span>
              </div>
              <div className="flex justify-between items-center pt-1 border-t border-slate-800">
                <span className="text-slate-400 font-heading">السعر التقديري:</span>
                <span className="font-bold text-emerald-400 font-mono text-xs sm:text-sm">
                  {activeImageModal.estimatedPriceRangeLYD.min} - {activeImageModal.estimatedPriceRangeLYD.max} د.ل
                </span>
              </div>
            </div>

            <div className="flex justify-between items-center pt-1">
              <button
                onClick={() => fetchPartImageLive(activeImageModal)}
                className="text-xs text-slate-400 hover:text-white flex items-center gap-1.5 cursor-pointer bg-slate-900 px-3 py-1.5 rounded-lg border border-slate-800"
              >
                <RefreshCw className="w-3.5 h-3.5" />
                <span>إعادة البحث من الويب</span>
              </button>

              <a
                href={`https://www.google.com/search?q=${encodeURIComponent(
                  `${vehicleInfo?.make || ""} ${vehicleInfo?.model || ""} ${activeImageModal.oemPartNumber} ${activeImageModal.partNameEnglish} auto part`
                )}`}
                target="_blank"
                rel="noreferrer"
                className="flex items-center gap-1.5 bg-blue-600 hover:bg-blue-500 text-white font-bold px-3.5 py-1.5 rounded-lg text-xs transition-colors"
              >
                <ExternalLink className="w-3.5 h-3.5" />
                الكتالوجات العالمية
              </a>
            </div>
          </div>
        </div>
      )}
    </div>
  );
};
