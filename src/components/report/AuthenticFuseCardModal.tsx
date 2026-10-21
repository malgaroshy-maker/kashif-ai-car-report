"use client";

import React, { useState, useMemo } from "react";
import {
  ALL_SUPPORTED_CARS_FUSE_DATA,
  EquipmentMapping,
  FuseSlotDetail,
  VehicleFuseCard,
  getFuseColor,
} from "@/lib/fuse-card-data";
import { FuseMapViewer } from "./FuseMapViewer";

export function AuthenticFuseCardModal({ onClose }: { onClose: () => void }) {
  const [selectedCarId, setSelectedCarId] = useState<string>("bmw_e39");
  const [selectedBoxId, setSelectedBoxId] = useState<string>("glovebox");
  const [searchQuery, setSearchQuery] = useState<string>("");
  const [languageMode, setLanguageMode] = useState<"bilingual" | "arabic" | "english">("bilingual");
  const [highlightedFuseNumber, setHighlightedFuseNumber] = useState<number | null>(null);
  const [selectedEquipment, setSelectedEquipment] = useState<EquipmentMapping | null>(null);
  const [activeSlotDetail, setActiveSlotDetail] = useState<FuseSlotDetail | null>(null);

  const selectedCar = useMemo(() => {
    return ALL_SUPPORTED_CARS_FUSE_DATA.find((c) => c.id === selectedCarId) || ALL_SUPPORTED_CARS_FUSE_DATA[0];
  }, [selectedCarId]);

  const selectedBox = useMemo(() => {
    return selectedCar.boxes.find((b) => b.boxId === selectedBoxId) || selectedCar.boxes[0];
  }, [selectedCar, selectedBoxId]);

  const filteredEquipment = useMemo(() => {
    const q = searchQuery.trim().toLowerCase();
    if (!q) return selectedBox.equipmentList;

    const num = parseInt(q.replace(/\D/g, ""), 10);
    return selectedBox.equipmentList.filter((item) => {
      const matchEn = item.equipmentEnglish.toLowerCase().includes(q);
      const matchAr = item.equipmentArabic.toLowerCase().includes(q);
      const matchNum = !isNaN(num) && item.fuses.includes(num);
      return matchEn || matchAr || matchNum;
    });
  }, [selectedBox, searchQuery]);

  const handleEquipmentClick = (item: EquipmentMapping) => {
    if (selectedEquipment === item) {
      setSelectedEquipment(null);
      setHighlightedFuseNumber(null);
      setActiveSlotDetail(null);
    } else {
      setSelectedEquipment(item);
      const firstFuse = item.fuses[0];
      setHighlightedFuseNumber(firstFuse);
      if (selectedBox.slots[firstFuse]) {
        setActiveSlotDetail(selectedBox.slots[firstFuse]);
      } else {
        const amps = selectedBox.amperesMap[firstFuse] || 15;
        const color = getFuseColor(amps);
        setActiveSlotDetail({
          id: `F${firstFuse}`,
          number: firstFuse,
          label: item.equipmentEnglish,
          nameArabic: item.equipmentArabic,
          ratingAmps: amps,
          descriptionArabic: `يغذي دائرة ${item.equipmentArabic} (${item.equipmentEnglish})`,
          colorName: color.name,
          hexColor: color.hex,
          symptoms: ["انقطاع التيار عن هذا الجهاز في حال احتراق الفيوز"],
        });
      }
    }
  };

  const handleFuseCellClick = (fuseNum: number) => {
    setHighlightedFuseNumber(fuseNum);
    const mapped = selectedBox.equipmentList.find((e) => e.fuses.includes(fuseNum));
    setSelectedEquipment(mapped || null);

    if (selectedBox.slots[fuseNum]) {
      setActiveSlotDetail(selectedBox.slots[fuseNum]);
    } else {
      const amps = selectedBox.amperesMap[fuseNum] || 15;
      const color = getFuseColor(amps);
      const label = mapped ? mapped.equipmentEnglish : `FUSE ${fuseNum}`;
      const nameAr = mapped ? mapped.equipmentArabic : `فيوز رقم ${fuseNum}`;
      setActiveSlotDetail({
        id: `F${fuseNum}`,
        number: fuseNum,
        label,
        nameArabic: nameAr,
        ratingAmps: amps,
        descriptionArabic: `فيوز الدائرة رقم ${fuseNum} - يغذي ${nameAr}`,
        colorName: color.name,
        hexColor: color.hex,
        symptoms: [`تعطل الأجهزة المرتبطة بفيوز رقم ${fuseNum}`],
      });
    }
  };

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/80 backdrop-blur-sm p-2 sm:p-4 overflow-y-auto">
      <div className="relative w-full max-w-5xl max-h-[95vh] flex flex-col bg-slate-900 border border-slate-700 rounded-2xl shadow-2xl overflow-hidden text-slate-100 font-sans">
        
        {/* Top Header & Car Selection */}
        <div className="flex flex-wrap items-center justify-between gap-3 p-4 bg-slate-950 border-b border-slate-800">
          <div className="flex items-center gap-3">
            <span className="flex h-9 w-9 items-center justify-center rounded-lg bg-cyan-500/20 text-cyan-400 text-lg border border-cyan-500/30">
              ⚡
            </span>
            <div>
              <h2 className="text-base sm:text-lg font-bold text-slate-100 flex items-center gap-2">
                <span>خرائط وبطاقات الفيوزات الأصلية للسيارات</span>
                <span className="text-xs px-2 py-0.5 rounded-full bg-cyan-500/20 text-cyan-300 border border-cyan-500/40">
                  OEM Genuine Cards
                </span>
              </h2>
              <p className="text-xs text-slate-400">
                مخططات فيوزات السيارات الأصلية مترجمة بالكامل للعربية ومطابقة لبطاقات المصنع
              </p>
            </div>
          </div>

          <button
            onClick={onClose}
            className="px-3 py-1.5 rounded-lg bg-slate-800 hover:bg-slate-700 text-slate-300 hover:text-white text-xs font-semibold transition"
          >
            إغلاق ✕
          </button>
        </div>

        {/* Vehicle & Box Selection Strip */}
        <div className="flex flex-wrap items-center justify-between gap-3 px-4 py-3 bg-slate-900/90 border-b border-slate-800 text-xs">
          {/* Car Picker */}
          <div className="flex items-center gap-2">
            <label className="text-slate-400 font-semibold">اختر السيارة:</label>
            <select
              value={selectedCarId}
              onChange={(e) => {
                setSelectedCarId(e.target.value);
                const car = ALL_SUPPORTED_CARS_FUSE_DATA.find((c) => c.id === e.target.value);
                if (car && car.boxes.length > 0) {
                  setSelectedBoxId(car.boxes[0].boxId);
                }
                setHighlightedFuseNumber(null);
                setSelectedEquipment(null);
                setActiveSlotDetail(null);
              }}
              className="bg-slate-800 border border-slate-700 rounded-lg px-2.5 py-1.5 text-slate-200 font-bold focus:outline-none focus:border-cyan-500"
            >
              {ALL_SUPPORTED_CARS_FUSE_DATA.map((car) => (
                <option key={car.id} value={car.id}>
                  {car.makeArabic} - {car.modelArabic} ({car.yearRange})
                </option>
              ))}
            </select>
          </div>

          {/* Box Picker */}
          <div className="flex items-center gap-2">
            <label className="text-slate-400 font-semibold">موقع العلبة:</label>
            <div className="flex items-center gap-1.5">
              {selectedCar.boxes.map((box) => (
                <button
                  key={box.boxId}
                  onClick={() => {
                    setSelectedBoxId(box.boxId);
                    setHighlightedFuseNumber(null);
                    setSelectedEquipment(null);
                    setActiveSlotDetail(null);
                  }}
                  className={`px-2.5 py-1 rounded-md text-xs font-bold transition border ${
                    selectedBoxId === box.boxId
                      ? "bg-cyan-600/30 text-cyan-300 border-cyan-500"
                      : "bg-slate-800/80 text-slate-400 border-slate-700 hover:bg-slate-800"
                  }`}
                >
                  {box.boxNameArabic}
                </button>
              ))}
            </div>
          </div>

          {/* Search Bar */}
          <div className="relative min-w-[220px]">
            <input
              type="text"
              placeholder="ابحث عن جهاز أو رقم فيوز (مثال: بنزين، مكيف، 17)..."
              value={searchQuery}
              onChange={(e) => setSearchQuery(e.target.value)}
              className="w-full bg-slate-950 border border-slate-700 rounded-lg px-3 py-1.5 text-xs text-slate-200 placeholder-slate-500 focus:outline-none focus:border-cyan-500"
            />
            {searchQuery && (
              <button
                onClick={() => setSearchQuery("")}
                className="absolute left-2.5 top-1/2 -translate-y-1/2 text-slate-500 hover:text-slate-300 text-xs"
              >
                ✕
              </button>
            )}
          </div>
        </div>

        {/* Main Content Area */}
        <div className="flex-1 overflow-y-auto p-4 space-y-4">
          
          {/* خرائط الفيوزات الحقيقية (صور من الكتالوج) */}
          {selectedBox.fuseMapImages && selectedBox.fuseMapImages.length > 0 && (
            <FuseMapViewer
              images={selectedBox.fuseMapImages}
              boxNameArabic={selectedBox.boxNameArabic}
            />
          )}

          {/* Authentic Printed Card (Designed strictly to replicate the physical photo!) */}
          <div className="bg-[#FAF9F6] text-black rounded-xl p-4 sm:p-6 shadow-2xl border-2 border-slate-900 relative">
            
            {/* Card Header Stamp */}
            <div className="flex flex-wrap items-center justify-between border-b-2 border-black pb-3 mb-4 gap-2">
              <div>
                <h3 className="font-extrabold text-sm sm:text-base tracking-wide text-black uppercase font-mono">
                  {selectedCar.make} {selectedCar.model} · {selectedBox.boxNameArabic}
                </h3>
                <p className="text-xs text-neutral-600 font-medium">
                  {selectedBox.locationArabic} — {selectedBox.accessInstructionsArabic}
                </p>
              </div>

              <div className="flex items-center gap-2">
                {/* Language Toggles */}
                <div className="flex items-center bg-neutral-200 rounded p-0.5 text-[11px] font-bold">
                  <button
                    onClick={() => setLanguageMode("bilingual")}
                    className={`px-2 py-0.5 rounded ${
                      languageMode === "bilingual" ? "bg-black text-white" : "text-neutral-700"
                    }`}
                  >
                    عربي + EN
                  </button>
                  <button
                    onClick={() => setLanguageMode("arabic")}
                    className={`px-2 py-0.5 rounded ${
                      languageMode === "arabic" ? "bg-black text-white" : "text-neutral-700"
                    }`}
                  >
                    عربي فقط
                  </button>
                  <button
                    onClick={() => setLanguageMode("english")}
                    className={`px-2 py-0.5 rounded ${
                      languageMode === "english" ? "bg-black text-white" : "text-neutral-700"
                    }`}
                  >
                    Original EN
                  </button>
                </div>

                {selectedBox.cardPartNumber && (
                  <span className="font-mono text-xs font-black bg-neutral-100 border border-black px-2 py-1 rounded">
                    {selectedBox.cardPartNumber}
                  </span>
                )}
              </div>
            </div>

            {/* Equipment Index Table (3 Columns like original card) */}
            <div className="mb-6">
              <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-x-6 gap-y-1 text-xs">
                {filteredEquipment.map((item, idx) => {
                  const isSelected =
                    selectedEquipment === item ||
                    (highlightedFuseNumber !== null && item.fuses.includes(highlightedFuseNumber));

                  return (
                    <div
                      key={idx}
                      onClick={() => handleEquipmentClick(item)}
                      className={`flex items-center justify-between py-1 px-1.5 rounded cursor-pointer transition select-none border ${
                        isSelected
                          ? "bg-amber-100 border-amber-500 font-bold shadow-sm"
                          : "border-transparent hover:bg-neutral-100"
                      }`}
                    >
                      <div className="flex flex-col pr-1">
                        {languageMode !== "arabic" && (
                          <span className="font-mono font-bold text-neutral-900 leading-tight">
                            {item.equipmentEnglish}
                          </span>
                        )}
                        {languageMode !== "english" && (
                          <span className="text-neutral-700 text-[11px] font-semibold leading-tight">
                            {item.equipmentArabic}
                          </span>
                        )}
                      </div>

                      {/* Fuse Numbers Badge */}
                      <div className="flex items-center gap-1 font-mono font-extrabold text-xs">
                        {item.fuses.map((fNum) => {
                          const isActiveFuse = highlightedFuseNumber === fNum;
                          const amps = selectedBox.amperesMap[fNum] || 15;
                          const color = getFuseColor(amps);

                          return (
                            <span
                              key={fNum}
                              onClick={(e) => {
                                e.stopPropagation();
                                handleFuseCellClick(fNum);
                              }}
                              style={{
                                backgroundColor: isActiveFuse ? color.hex : undefined,
                                color: isActiveFuse ? (amps === 20 || amps === 25 ? "#000" : "#fff") : "#000",
                                borderColor: color.hex,
                              }}
                              className={`px-1.5 py-0.5 rounded border text-[11px] transition hover:scale-110 ${
                                isActiveFuse ? "font-black ring-2 ring-black" : "bg-white"
                              }`}
                              title={`فيوز رقم ${fNum} (${amps}A)`}
                            >
                              {fNum}
                            </span>
                          );
                        })}
                      </div>
                    </div>
                  );
                })}
              </div>
            </div>

            {/* Physical Fuse Number and Amperes Grid (Exact replica of lower half of image) */}
            <div className="space-y-3 pt-3 border-t-2 border-black">
              <div className="flex items-center justify-between text-xs font-bold text-neutral-800">
                <span>جدول أرقام الفيوزات وقيم الأمبير المطابقة تماماً لكارت الوكالة:</span>
                <span className="text-[11px] text-neutral-500 font-normal">
                  (اضغط على أي خلية لتحديدها ومعرفة الدائرة)
                </span>
              </div>

              {/* Row 1: 1 - 20 (+ 75, 76 for BMW E39) */}
              <div className="overflow-x-auto pb-1">
                <table className="border-collapse border-2 border-black text-center font-mono text-xs w-full min-w-[700px]">
                  <tbody>
                    <tr className="bg-neutral-100">
                      <td className="border border-black px-2 py-1 font-black text-left w-24">Fuse Nr.</td>
                      {selectedBox.row1.map((fNum) => (
                        <td
                          key={fNum}
                          onClick={() => handleFuseCellClick(fNum)}
                          className={`border border-black px-1.5 py-1 cursor-pointer font-bold transition hover:bg-neutral-200 ${
                            highlightedFuseNumber === fNum ? "bg-amber-300 font-black text-black" : ""
                          }`}
                        >
                          {fNum}
                        </td>
                      ))}
                      {selectedBox.row1Special && (
                        <>
                          <td className="border border-black bg-neutral-300 w-4"></td>
                          {selectedBox.row1Special.map((fNum) => (
                            <td
                              key={fNum}
                              onClick={() => handleFuseCellClick(fNum)}
                              className={`border border-black px-2 py-1 cursor-pointer font-bold transition hover:bg-neutral-200 ${
                                highlightedFuseNumber === fNum ? "bg-amber-300 font-black text-black" : ""
                              }`}
                            >
                              {fNum}
                            </td>
                          ))}
                        </>
                      )}
                    </tr>
                    <tr>
                      <td className="border border-black px-2 py-1 font-black text-left w-24">Amperes</td>
                      {selectedBox.row1.map((fNum) => {
                        const amps = selectedBox.amperesMap[fNum];
                        const color = getFuseColor(amps);
                        const isCurrent = highlightedFuseNumber === fNum;
                        return (
                          <td
                            key={fNum}
                            onClick={() => handleFuseCellClick(fNum)}
                            style={{
                              backgroundColor: isCurrent ? color.hex : undefined,
                              color: isCurrent ? (amps === 20 || amps === 25 ? "#000" : "#fff") : undefined,
                            }}
                            className="border border-black px-1.5 py-1 cursor-pointer font-extrabold transition"
                          >
                            {amps === 7.5 ? "7,5" : amps === 0 ? "-" : amps}
                          </td>
                        );
                      })}
                      {selectedBox.row1Special && (
                        <>
                          <td className="border border-black bg-neutral-300 w-4"></td>
                          {selectedBox.row1Special.map((fNum) => {
                            const amps = selectedBox.amperesMap[fNum];
                            const color = getFuseColor(amps);
                            const isCurrent = highlightedFuseNumber === fNum;
                            return (
                              <td
                                key={fNum}
                                onClick={() => handleFuseCellClick(fNum)}
                                style={{
                                  backgroundColor: isCurrent ? color.hex : undefined,
                                  color: isCurrent ? "#fff" : undefined,
                                }}
                                className="border border-black px-2 py-1 cursor-pointer font-black transition"
                              >
                                {amps}
                              </td>
                            );
                          })}
                        </>
                      )}
                    </tr>
                  </tbody>
                </table>
              </div>

              {/* Row 2: 21 - 45 */}
              {selectedBox.row2 && selectedBox.row2.length > 0 && (
                <div className="overflow-x-auto pb-1">
                  <table className="border-collapse border-2 border-black text-center font-mono text-xs w-full min-w-[700px]">
                    <tbody>
                      <tr className="bg-neutral-100">
                        <td className="border border-black px-2 py-1 font-black text-left w-24">Fuse Nr.</td>
                        {selectedBox.row2.map((fNum) => (
                          <td
                            key={fNum}
                            onClick={() => handleFuseCellClick(fNum)}
                            className={`border border-black px-1.5 py-1 cursor-pointer font-bold transition hover:bg-neutral-200 ${
                              highlightedFuseNumber === fNum ? "bg-amber-300 font-black text-black" : ""
                            }`}
                          >
                            {fNum}
                          </td>
                        ))}
                      </tr>
                      <tr>
                        <td className="border border-black px-2 py-1 font-black text-left w-24">Amperes</td>
                        {selectedBox.row2.map((fNum) => {
                          const amps = selectedBox.amperesMap[fNum];
                          const color = getFuseColor(amps);
                          const isCurrent = highlightedFuseNumber === fNum;
                          return (
                            <td
                              key={fNum}
                              onClick={() => handleFuseCellClick(fNum)}
                              style={{
                                backgroundColor: isCurrent ? color.hex : undefined,
                                color: isCurrent ? (amps === 20 || amps === 25 ? "#000" : "#fff") : undefined,
                              }}
                              className="border border-black px-1.5 py-1 cursor-pointer font-extrabold transition"
                            >
                              {amps === 0 ? "-" : amps === 7.5 ? "7,5" : amps}
                            </td>
                          );
                        })}
                      </tr>
                    </tbody>
                  </table>
                </div>
              )}

              {/* Card Bottom: Part number and Pull Tab Handle */}
              <div className="flex flex-col items-center pt-2">
                <div className="w-full flex justify-end font-mono text-xs font-black text-black">
                  <span>8377 849</span>
                </div>
                <div className="w-full flex justify-end font-mono text-xs font-black text-black -mt-1">
                  <span>E 6957.J</span>
                </div>

                {selectedBox.hasPullTab && (
                  <div className="mt-2 flex flex-col items-center">
                    <div className="w-16 h-8 bg-neutral-200 border-2 border-black border-t-0 rounded-b-full flex items-center justify-center shadow-inner">
                      <span className="text-black font-black text-base">↓</span>
                    </div>
                  </div>
                )}
              </div>
            </div>
          </div>

          {/* Active Fuse Inspection Sheet (When a fuse is tapped) */}
          {activeSlotDetail && (
            <div className="p-4 rounded-xl bg-slate-950 border border-cyan-500/40 shadow-xl space-y-2">
              <div className="flex flex-wrap items-center justify-between gap-2 border-b border-slate-800 pb-2">
                <div className="flex items-center gap-2">
                  <span
                    style={{ backgroundColor: activeSlotDetail.hexColor }}
                    className="w-4 h-4 rounded-full border border-white/50"
                  />
                  <span className="font-mono font-bold text-sm text-cyan-300">
                    {activeSlotDetail.id} ({activeSlotDetail.ratingAmps}A)
                  </span>
                  <span className="font-bold text-sm text-slate-100">
                    {activeSlotDetail.nameArabic}
                  </span>
                  <span className="text-xs text-slate-400 font-mono">
                    [{activeSlotDetail.label}]
                  </span>
                </div>

                <div className="flex items-center gap-2 text-xs">
                  <span className="px-2 py-0.5 rounded bg-slate-800 text-slate-300 border border-slate-700">
                    لون الفيوز: {activeSlotDetail.colorName}
                  </span>
                </div>
              </div>

              <p className="text-xs text-slate-300 leading-relaxed">
                {activeSlotDetail.descriptionArabic}
              </p>

              {activeSlotDetail.symptoms && activeSlotDetail.symptoms.length > 0 && (
                <div className="text-xs text-rose-300 pt-1">
                  <span className="font-bold text-rose-400">أعراض احتراق هذا الفيوز: </span>
                  {activeSlotDetail.symptoms.join(" · ")}
                </div>
              )}

              {activeSlotDetail.testingTip && (
                <div className="text-xs text-amber-300 bg-amber-500/10 p-2 rounded-lg border border-amber-500/30">
                  <span className="font-bold text-amber-400">💡 طريقة الفحص السريع: </span>
                  {activeSlotDetail.testingTip}
                </div>
              )}
            </div>
          )}

        </div>

        {/* Footer */}
        <div className="p-3 bg-slate-950 border-t border-slate-800 flex items-center justify-between text-xs text-slate-400">
          <span>كاشف AI · خريطة الفيوزات الأصلية المعتمدة لورش فحص وصيانة السيارات</span>
          <button
            onClick={onClose}
            className="px-4 py-1.5 rounded-lg bg-cyan-600 hover:bg-cyan-500 text-white font-bold transition"
          >
            تم
          </button>
        </div>

      </div>
    </div>
  );
}
