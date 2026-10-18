"use client";

import React, { useState, useRef, useCallback } from "react";
import type { FuseMapImage } from "@/lib/fuse-card-data";

// ─── أيقونات أنواع الصور ───
const TYPE_ICONS: Record<FuseMapImage["type"], string> = {
  card: "📋",
  layout: "🔌",
  location: "📍",
};

const TYPE_LABELS: Record<FuseMapImage["type"], string> = {
  card: "البطاقة",
  layout: "الترتيب",
  location: "الموقع",
};

// ─── حالات التحميل ───
type LoadState = "idle" | "loading" | "loaded" | "error";

interface FuseMapViewerProps {
  images: FuseMapImage[];
  boxNameArabic: string;
}

export function FuseMapViewer({ images, boxNameArabic }: FuseMapViewerProps) {
  const [isOpen, setIsOpen] = useState(false);
  const [currentIndex, setCurrentIndex] = useState(0);
  const [loadStates, setLoadStates] = useState<Record<number, LoadState>>({});
  const [zoomLevel, setZoomLevel] = useState(1);
  const [panPosition, setPanPosition] = useState({ x: 0, y: 0 });
  const [retryKeys, setRetryKeys] = useState<Record<number, number>>({});

  const touchStartRef = useRef<{ x: number; y: number; dist?: number } | null>(null);

  const currentImage = images[currentIndex];

  // ─── التعامل مع حالات التحميل ───
  const handleImageLoad = useCallback((index: number) => {
    setLoadStates((prev) => ({ ...prev, [index]: "loaded" }));
  }, []);

  const handleImageError = useCallback((index: number) => {
    setLoadStates((prev) => ({ ...prev, [index]: "error" }));
  }, []);

  const retryLoad = useCallback((index: number) => {
    setLoadStates((prev) => ({ ...prev, [index]: "loading" }));
    setRetryKeys((prev) => ({ ...prev, [index]: (prev[index] || 0) + 1 }));
  }, []);

  // ─── التنقل في الكاروسيل ───
  const resetZoom = useCallback(() => {
    setZoomLevel(1);
    setPanPosition({ x: 0, y: 0 });
  }, []);

  const goToNext = useCallback(() => {
    setCurrentIndex((prev) => (prev + 1) % images.length);
    resetZoom();
  }, [images.length, resetZoom]);

  const goToPrev = useCallback(() => {
    setCurrentIndex((prev) => (prev - 1 + images.length) % images.length);
    resetZoom();
  }, [images.length, resetZoom]);

  // ─── التكبير والتصغير ───
  const zoomIn = () => setZoomLevel((z) => Math.min(z + 0.5, 4));
  const zoomOut = () => setZoomLevel((z) => Math.max(z - 0.5, 0.5));

  // ─── التعامل مع اللمس (Pinch-to-Zoom + Swipe) ───
  const handleTouchStart = (e: React.TouchEvent) => {
    if (e.touches.length === 2) {
      const dist = Math.hypot(
        e.touches[0].clientX - e.touches[1].clientX,
        e.touches[0].clientY - e.touches[1].clientY
      );
      touchStartRef.current = { x: 0, y: 0, dist };
    } else if (e.touches.length === 1) {
      touchStartRef.current = {
        x: e.touches[0].clientX,
        y: e.touches[0].clientY,
      };
    }
  };

  const handleTouchMove = (e: React.TouchEvent) => {
    if (!touchStartRef.current) return;

    if (e.touches.length === 2 && touchStartRef.current.dist) {
      // Pinch-to-Zoom
      const newDist = Math.hypot(
        e.touches[0].clientX - e.touches[1].clientX,
        e.touches[0].clientY - e.touches[1].clientY
      );
      const scale = newDist / touchStartRef.current.dist;
      setZoomLevel((z) => Math.min(Math.max(z * scale, 0.5), 4));
      touchStartRef.current.dist = newDist;
    } else if (e.touches.length === 1 && zoomLevel > 1) {
      // سحب الصورة المكبّرة (Pan)
      const dx = e.touches[0].clientX - touchStartRef.current.x;
      const dy = e.touches[0].clientY - touchStartRef.current.y;
      setPanPosition((prev) => ({
        x: prev.x + dx,
        y: prev.y + dy,
      }));
      touchStartRef.current = {
        x: e.touches[0].clientX,
        y: e.touches[0].clientY,
      };
    }
  };

  const handleTouchEnd = (e: React.TouchEvent) => {
    if (!touchStartRef.current || e.changedTouches.length === 0) return;

    // اكتشاف السحب الأفقي (Swipe) للتنقل بين الصور
    if (zoomLevel <= 1 && !touchStartRef.current.dist) {
      const dx = e.changedTouches[0].clientX - touchStartRef.current.x;
      if (Math.abs(dx) > 60) {
        if (dx < 0) goToNext();
        else goToPrev();
      }
    }
    touchStartRef.current = null;
  };

  // ─── حفظ الصورة على الهاتف ───
  const handleSaveImage = async () => {
    if (!currentImage) return;
    try {
      const response = await fetch(currentImage.url);
      const blob = await response.blob();
      const url = URL.createObjectURL(blob);
      const link = document.createElement("a");
      link.href = url;
      link.download = `fuse-map-${currentImage.type}-${Date.now()}.jpg`;
      document.body.appendChild(link);
      link.click();
      document.body.removeChild(link);
      URL.revokeObjectURL(url);
    } catch {
      // فتح الصورة في تبويب جديد كبديل
      window.open(currentImage.url, "_blank");
    }
  };

  // ─── عدم العرض إذا لا توجد صور ───
  if (!images || images.length === 0) return null;

  return (
    <div className="mb-4">
      {/* ─── زر "عرض الخريطة الحقيقية" ─── */}
      {!isOpen ? (
        <button
          onClick={() => {
            setIsOpen(true);
            setLoadStates({ 0: "loading" });
          }}
          className="w-full flex items-center justify-center gap-3 py-3 px-4 
                     rounded-xl bg-gradient-to-l from-cyan-600/20 to-emerald-600/20 
                     border-2 border-dashed border-cyan-500/40 
                     hover:border-cyan-400 hover:bg-cyan-500/10 
                     text-cyan-300 font-bold text-sm transition-all duration-300
                     group"
        >
          <span className="text-xl group-hover:scale-110 transition-transform">
            🗺️
          </span>
          <span>عرض خرائط الفيوزات الحقيقية لـ {boxNameArabic}</span>
          <span className="text-xs text-cyan-400/60 font-normal">
            ({images.length} صور)
          </span>
        </button>
      ) : (
        <div className="rounded-xl bg-slate-950 border border-cyan-500/30 overflow-hidden shadow-2xl">
          
          {/* ─── شريط العنوان ─── */}
          <div className="flex items-center justify-between px-4 py-2 bg-gradient-to-l from-cyan-900/40 to-slate-900 border-b border-cyan-500/20">
            <div className="flex items-center gap-2">
              <span className="text-lg">🗺️</span>
              <span className="text-sm font-bold text-cyan-300">
                خريطة الفيوزات الحقيقية
              </span>
              <span className="text-xs text-slate-400">
                {currentIndex + 1} / {images.length}
              </span>
            </div>

            <div className="flex items-center gap-1.5">
              {/* أزرار التكبير */}
              <button
                onClick={zoomOut}
                disabled={zoomLevel <= 0.5}
                className="p-1.5 rounded-lg bg-slate-800 hover:bg-slate-700 text-slate-300 text-xs disabled:opacity-30 transition"
                title="تصغير"
              >
                ➖
              </button>
              <span className="text-xs text-slate-400 min-w-[36px] text-center font-mono">
                {Math.round(zoomLevel * 100)}%
              </span>
              <button
                onClick={zoomIn}
                disabled={zoomLevel >= 4}
                className="p-1.5 rounded-lg bg-slate-800 hover:bg-slate-700 text-slate-300 text-xs disabled:opacity-30 transition"
                title="تكبير"
              >
                ➕
              </button>
              <button
                onClick={resetZoom}
                className="p-1.5 rounded-lg bg-slate-800 hover:bg-slate-700 text-slate-300 text-xs transition"
                title="إعادة الحجم الطبيعي"
              >
                🔄
              </button>

              {/* زر الحفظ */}
              <button
                onClick={handleSaveImage}
                className="p-1.5 rounded-lg bg-emerald-600/20 hover:bg-emerald-600/40 text-emerald-300 text-xs transition border border-emerald-500/30"
                title="حفظ الصورة على الهاتف"
              >
                💾 حفظ
              </button>

              {/* زر الإغلاق */}
              <button
                onClick={() => {
                  setIsOpen(false);
                  resetZoom();
                }}
                className="p-1.5 rounded-lg bg-slate-800 hover:bg-red-600/30 text-slate-400 hover:text-red-300 text-xs transition"
              >
                ✕
              </button>
            </div>
          </div>

          {/* ─── أزرار تصنيف الصور ─── */}
          <div className="flex items-center gap-1.5 px-4 py-2 bg-slate-900/50 border-b border-slate-800/50">
            {images.map((img, idx) => (
              <button
                key={idx}
                onClick={() => {
                  setCurrentIndex(idx);
                  resetZoom();
                  if (!loadStates[idx] || loadStates[idx] === "idle") {
                    setLoadStates((prev) => ({ ...prev, [idx]: "loading" }));
                  }
                }}
                className={`flex items-center gap-1.5 px-3 py-1.5 rounded-lg text-xs font-bold transition border ${
                  currentIndex === idx
                    ? "bg-cyan-600/30 text-cyan-300 border-cyan-500"
                    : "bg-slate-800/80 text-slate-400 border-slate-700 hover:bg-slate-800"
                }`}
              >
                <span>{TYPE_ICONS[img.type]}</span>
                <span>{TYPE_LABELS[img.type]}</span>
              </button>
            ))}
          </div>

          {/* ─── منطقة عرض الصورة ─── */}
          <div
            className="relative w-full min-h-[300px] max-h-[60vh] overflow-hidden bg-slate-950 flex items-center justify-center cursor-grab active:cursor-grabbing select-none"
            onTouchStart={handleTouchStart}
            onTouchMove={handleTouchMove}
            onTouchEnd={handleTouchEnd}
            onDoubleClick={() => {
              if (zoomLevel > 1) resetZoom();
              else setZoomLevel(2);
            }}
          >
            {/* حالة التحميل - Spinner */}
            {(loadStates[currentIndex] === "loading" || !loadStates[currentIndex]) && (
              <div className="absolute inset-0 flex flex-col items-center justify-center gap-3 z-10 bg-slate-950/80">
                <div className="w-10 h-10 border-4 border-cyan-500/30 border-t-cyan-400 rounded-full animate-spin" />
                <span className="text-sm text-cyan-300 font-semibold">
                  جاري تحميل الخريطة...
                </span>
              </div>
            )}

            {/* حالة الخطأ */}
            {loadStates[currentIndex] === "error" && (
              <div className="absolute inset-0 flex flex-col items-center justify-center gap-3 z-10 bg-slate-950/90">
                <span className="text-4xl">⚠️</span>
                <p className="text-sm text-red-300 font-semibold text-center px-4">
                  تعذّر تحميل صورة الخريطة
                </p>
                <p className="text-xs text-slate-400 text-center px-8">
                  تأكد من اتصالك بالإنترنت وحاول مرة أخرى
                </p>
                <button
                  onClick={() => retryLoad(currentIndex)}
                  className="px-4 py-2 rounded-lg bg-cyan-600 hover:bg-cyan-500 text-white text-xs font-bold transition"
                >
                  🔄 إعادة المحاولة
                </button>
              </div>
            )}

            {/* الصورة الفعلية */}
            {currentImage && (
              <img
                key={`${currentIndex}-${retryKeys[currentIndex] || 0}`}
                src={currentImage.url}
                alt={currentImage.titleArabic}
                className="max-w-full max-h-[60vh] object-contain transition-transform duration-200 ease-out"
                style={{
                  transform: `scale(${zoomLevel}) translate(${panPosition.x / zoomLevel}px, ${panPosition.y / zoomLevel}px)`,
                }}
                onLoad={() => handleImageLoad(currentIndex)}
                onError={() => handleImageError(currentIndex)}
                draggable={false}
              />
            )}

            {/* أسهم التنقل */}
            {images.length > 1 && (
              <>
                <button
                  onClick={goToPrev}
                  className="absolute right-2 top-1/2 -translate-y-1/2 w-10 h-10 rounded-full bg-black/50 hover:bg-black/80 text-white text-lg flex items-center justify-center transition z-20 backdrop-blur-sm"
                >
                  ▶
                </button>
                <button
                  onClick={goToNext}
                  className="absolute left-2 top-1/2 -translate-y-1/2 w-10 h-10 rounded-full bg-black/50 hover:bg-black/80 text-white text-lg flex items-center justify-center transition z-20 backdrop-blur-sm"
                >
                  ◀
                </button>
              </>
            )}

            {/* نقاط التنقل (Dots) */}
            {images.length > 1 && (
              <div className="absolute bottom-3 left-1/2 -translate-x-1/2 flex gap-1.5 z-20">
                {images.map((_, idx) => (
                  <button
                    key={idx}
                    onClick={() => {
                      setCurrentIndex(idx);
                      resetZoom();
                    }}
                    className={`w-2.5 h-2.5 rounded-full transition ${
                      currentIndex === idx
                        ? "bg-cyan-400 scale-125"
                        : "bg-slate-500 hover:bg-slate-400"
                    }`}
                  />
                ))}
              </div>
            )}
          </div>

          {/* ─── عنوان ووصف الصورة ─── */}
          {currentImage && (
            <div className="px-4 py-3 border-t border-slate-800/50 bg-gradient-to-l from-slate-900 to-slate-950">
              <h4 className="text-sm font-bold text-slate-100 flex items-center gap-2">
                <span>{TYPE_ICONS[currentImage.type]}</span>
                {currentImage.titleArabic}
              </h4>
              {currentImage.descriptionArabic && (
                <p className="text-xs text-slate-400 mt-1 leading-relaxed">
                  {currentImage.descriptionArabic}
                </p>
              )}
            </div>
          )}
        </div>
      )}
    </div>
  );
}
