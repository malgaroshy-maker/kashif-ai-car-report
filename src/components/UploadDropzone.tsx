"use client";

import React, { useState, useRef } from "react";
import {
  UploadCloud,
  FileUp,
  Camera,
  FileCode,
  Zap,
  Car,
  CheckCircle2,
  AlertCircle,
  Loader2,
} from "lucide-react";
import { KashifDiagnosticReport } from "@/lib/types";

interface UploadDropzoneProps {
  onReportGenerated: (report: KashifDiagnosticReport) => void;
  isLoading: boolean;
  setIsLoading: (loading: boolean) => void;
}

export const UploadDropzone: React.FC<UploadDropzoneProps> = ({
  onReportGenerated,
  isLoading,
  setIsLoading,
}) => {
  const [activeTab, setActiveTab] = useState<"file" | "image" | "manual">("file");
  const [dragOver, setDragOver] = useState(false);
  const [manualCodes, setManualCodes] = useState("");
  const [manualVin, setManualVin] = useState("");
  const [manualMakeModel, setManualMakeModel] = useState("");
  const [statusMessage, setStatusMessage] = useState("");
  const [errorMsg, setErrorMsg] = useState("");
  const fileInputRef = useRef<HTMLInputElement>(null);
  const imageInputRef = useRef<HTMLInputElement>(null);

  // Quick Demo Trigger
  const handleLoadSample = async (sampleId: "bmw-528i" | "toyota-corolla") => {
    setIsLoading(true);
    setErrorMsg("");
    setStatusMessage(
      sampleId === "bmw-528i"
        ? "جاري تحميل وفحص تقرير BMW 528i..."
        : "جاري تحميل وفحص تقرير Toyota Corolla..."
    );

    try {
      const res = await fetch("/api/analyze", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ sampleId }),
      });
      const data = await res.json();
      if (data.success && data.report) {
        onReportGenerated(data.report);
      } else {
        setErrorMsg(data.error || "تعذر معالجة تقرير العينة");
      }
    } catch (err: any) {
      setErrorMsg(err.message || "حدث خطأ في الاتصال");
    } finally {
      setIsLoading(false);
      setStatusMessage("");
    }
  };

  // Handle PDF/Image File Upload
  const handleFileUpload = async (file: File) => {
    setIsLoading(true);
    setErrorMsg("");
    setStatusMessage("جاري استخراج الأكواد والمطابقة مع القاموس الفني...");

    try {
      const storedApiKey = localStorage.getItem("kashif_gemini_api_key") || "";
      const activeProvider = localStorage.getItem("kashif_ai_provider") || "gemini";
      const formData = new FormData();
      formData.append("file", file);
      formData.append("provider", activeProvider);
      if (storedApiKey) {
        formData.append("apiKey", storedApiKey);
      }

      const headers: Record<string, string> = {
        "x-ai-provider": activeProvider,
      };
      if (storedApiKey) {
        headers["x-gemini-api-key"] = storedApiKey;
      }

      const res = await fetch("/api/analyze", {
        method: "POST",
        headers,
        body: formData,
      });

      const rawText = await res.text();
      let data: any = null;
      try {
        data = JSON.parse(rawText);
      } catch {
        throw new Error(
          res.ok
            ? "تعذر قراءة الرد بصيغة صالحة"
            : `خطأ في الخادم (${res.status}): ${rawText.slice(0, 100) || "يرجى التحقق من إعدادات المفتاح"}`
        );
      }

      if (data && data.success && data.report) {
        onReportGenerated(data.report);
      } else {
        setErrorMsg(data?.error || "تعذر تحليل الملف المرفوع");
      }
    } catch (err: any) {
      setErrorMsg(err.message || "حدث خطأ أثناء رفع الملف");
    } finally {
      setIsLoading(false);
      setStatusMessage("");
    }
  };

  // Handle Manual Input Submit
  const handleManualSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!manualCodes.trim()) {
      setErrorMsg("يرجى إدخال رمز عطل واحد على الأقل (مثل: P0102 أو 02 Ignition)");
      return;
    }

    setIsLoading(true);
    setErrorMsg("");
    setStatusMessage("جاري تحليل الرموز واستخراج أرقام القطع والتشخيص...");

    try {
      const storedApiKey = localStorage.getItem("kashif_gemini_api_key") || "";
      const activeProvider = localStorage.getItem("kashif_ai_provider") || "gemini";
      const headers: Record<string, string> = {
        "Content-Type": "application/json",
        "x-ai-provider": activeProvider,
      };
      if (storedApiKey) {
        headers["x-gemini-api-key"] = storedApiKey;
      }

      const res = await fetch("/api/analyze", {
        method: "POST",
        headers,
        body: JSON.stringify({
          manualCodes,
          apiKey: storedApiKey || undefined,
          provider: activeProvider,
          vehicleInfo: {
            vin: manualVin,
            make: manualMakeModel,
          },
        }),
      });

      const rawText = await res.text();
      let data: any = null;
      try {
        data = JSON.parse(rawText);
      } catch {
        throw new Error(
          res.ok
            ? "تعذر قراءة الرد بصيغة صالحة"
            : `خطأ في الخادم (${res.status}): ${rawText.slice(0, 100) || "يرجى التحقق من المدخلات"}`
        );
      }

      if (data && data.success && data.report) {
        onReportGenerated(data.report);
      } else {
        setErrorMsg(data?.error || "تعذر تحليل الأكواد المدخلة");
      }
    } catch (err: any) {
      setErrorMsg(err.message || "حدث خطأ في المعالجة");
    } finally {
      setIsLoading(false);
      setStatusMessage("");
    }
  };

  return (
    <div className="w-full max-w-4xl mx-auto space-y-4">
      {/* Sample Reports Banner */}
      <div className="p-4 rounded-xl workbench-panel flex flex-col sm:flex-row items-start sm:items-center justify-between gap-3">
        <div>
          <div className="flex items-center gap-2 text-slate-200 font-bold text-xs sm:text-sm font-heading">
            <Zap className="w-4 h-4 text-blue-400" />
            <span>نماذج تقارير فحص جاهزة للاختبار الفوري:</span>
          </div>
          <p className="text-xs text-slate-400 mt-0.5">
            اختر تقريراً حقيقياً لمعاينة استخراج الأعطال ومطابقة قطع الغيار
          </p>
        </div>

        <div className="flex items-center gap-2 w-full sm:w-auto">
          <button
            onClick={() => handleLoadSample("bmw-528i")}
            disabled={isLoading}
            className="flex-1 sm:flex-initial flex items-center justify-center gap-1.5 bg-slate-800 hover:bg-slate-700 text-slate-200 border border-slate-700 px-3.5 py-1.5 rounded-lg text-xs font-semibold transition-colors cursor-pointer disabled:opacity-50"
          >
            <Car className="w-3.5 h-3.5 text-blue-400" />
            <span>BMW 528i (E39)</span>
          </button>

          <button
            onClick={() => handleLoadSample("toyota-corolla")}
            disabled={isLoading}
            className="flex-1 sm:flex-initial flex items-center justify-center gap-1.5 bg-slate-800 hover:bg-slate-700 text-slate-200 border border-slate-700 px-3.5 py-1.5 rounded-lg text-xs font-semibold transition-colors cursor-pointer disabled:opacity-50"
          >
            <Car className="w-3.5 h-3.5 text-blue-400" />
            <span>Toyota Corolla 2004</span>
          </button>
        </div>
      </div>

      {/* Main Ingestion Box */}
      <div className="workbench-panel rounded-2xl p-5 sm:p-6 relative overflow-hidden space-y-4">
        {/* Ingestion Tabs */}
        <div className="flex items-center justify-center gap-1 p-1 bg-slate-900 rounded-xl border border-slate-800 max-w-sm mx-auto">
          <button
            onClick={() => setActiveTab("file")}
            className={`flex-1 flex items-center justify-center gap-1.5 py-1.5 px-3 rounded-lg text-xs font-semibold transition-colors cursor-pointer ${
              activeTab === "file"
                ? "bg-blue-600 text-white"
                : "text-slate-400 hover:text-white"
            }`}
          >
            <FileUp className="w-3.5 h-3.5" />
            تقرير PDF
          </button>
          <button
            onClick={() => setActiveTab("image")}
            className={`flex-1 flex items-center justify-center gap-1.5 py-1.5 px-3 rounded-lg text-xs font-semibold transition-colors cursor-pointer ${
              activeTab === "image"
                ? "bg-blue-600 text-white"
                : "text-slate-400 hover:text-white"
            }`}
          >
            <Camera className="w-3.5 h-3.5" />
            صورة الشاشة
          </button>
          <button
            onClick={() => setActiveTab("manual")}
            className={`flex-1 flex items-center justify-center gap-1.5 py-1.5 px-3 rounded-lg text-xs font-semibold transition-colors cursor-pointer ${
              activeTab === "manual"
                ? "bg-blue-600 text-white"
                : "text-slate-400 hover:text-white"
            }`}
          >
            <FileCode className="w-3.5 h-3.5" />
            إدخال يدوي
          </button>
        </div>

        {/* Tab 1: PDF Upload */}
        {activeTab === "file" && (
          <div
            onDragOver={(e) => {
              e.preventDefault();
              setDragOver(true);
            }}
            onDragLeave={() => setDragOver(false)}
            onDrop={(e) => {
              e.preventDefault();
              setDragOver(false);
              if (e.dataTransfer.files && e.dataTransfer.files[0]) {
                handleFileUpload(e.dataTransfer.files[0]);
              }
            }}
            onClick={() => fileInputRef.current?.click()}
            className={`border border-dashed rounded-xl p-8 text-center cursor-pointer transition-colors ${
              dragOver
                ? "border-blue-500 bg-blue-950/20"
                : "border-slate-700 bg-slate-900/50 hover:bg-slate-900/80"
            }`}
          >
            <input
              ref={fileInputRef}
              type="file"
              accept=".pdf"
              className="hidden"
              onChange={(e) => {
                if (e.target.files && e.target.files[0]) {
                  handleFileUpload(e.target.files[0]);
                }
              }}
            />
            <div className="w-12 h-12 rounded-xl bg-slate-800 flex items-center justify-center mx-auto mb-3 text-blue-400">
              <UploadCloud className="w-6 h-6" />
            </div>
            <h3 className="text-sm sm:text-base font-bold text-white mb-1 font-heading">
              اسحب وأفلت تقرير جهاز الفحص (PDF) هنا
            </h3>
            <p className="text-xs text-slate-400 mb-3">
              يدعم ملفات (Ediag, Launch X431, Autel, ThinkDiag, Topdon)
            </p>
            <div className="inline-flex items-center gap-1.5 text-xs text-slate-300 bg-slate-800 px-2.5 py-1 rounded-md">
              <CheckCircle2 className="w-3.5 h-3.5 text-blue-400" />
              استخراج فوري للأكواد وبيانات المركبة
            </div>
          </div>
        )}

        {/* Tab 2: Image Upload */}
        {activeTab === "image" && (
          <div
            onClick={() => imageInputRef.current?.click()}
            className="border border-dashed border-slate-700 hover:border-slate-600 bg-slate-900/50 hover:bg-slate-900/80 rounded-xl p-8 text-center cursor-pointer transition-colors"
          >
            <input
              ref={imageInputRef}
              type="file"
              accept="image/*"
              className="hidden"
              onChange={(e) => {
                if (e.target.files && e.target.files[0]) {
                  handleFileUpload(e.target.files[0]);
                }
              }}
            />
            <div className="w-12 h-12 rounded-xl bg-slate-800 flex items-center justify-center mx-auto mb-3 text-blue-400">
              <Camera className="w-6 h-6" />
            </div>
            <h3 className="text-sm sm:text-base font-bold text-white mb-1 font-heading">
              التقط صورة لشاشة الفحص أو ارفع لقطة شاشة
            </h3>
            <p className="text-xs text-slate-400 mb-3">
              التعرف البصري الذكي (OCR) على الأكواد الموضحة بالصورة
            </p>
            <div className="inline-flex items-center gap-1.5 text-xs text-slate-300 bg-slate-800 px-2.5 py-1 rounded-md">
              <CheckCircle2 className="w-3.5 h-3.5 text-blue-400" />
              دعم الصور بجودة قياسية أو منخفضة
            </div>
          </div>
        )}

        {/* Tab 3: Manual Input */}
        {activeTab === "manual" && (
          <form onSubmit={handleManualSubmit} className="space-y-3">
            <div className="grid grid-cols-1 sm:grid-cols-2 gap-3">
              <div>
                <label className="block text-xs font-semibold text-slate-300 mb-1">
                  رقم الهيكل VIN (اختياري):
                </label>
                <input
                  type="text"
                  placeholder="مثال: WBADD6100VBSAMPLE"
                  value={manualVin}
                  onChange={(e) => setManualVin(e.target.value)}
                  className="w-full bg-slate-900 border border-slate-700 rounded-lg px-3 py-2 text-xs text-white placeholder-slate-500 focus:outline-none focus:border-blue-500 font-mono uppercase"
                />
              </div>
              <div>
                <label className="block text-xs font-semibold text-slate-300 mb-1">
                  طراز وسنة السيارة (اختياري):
                </label>
                <input
                  type="text"
                  placeholder="مثال: تويوتا كورولا 2004 أو BMW 528i"
                  value={manualMakeModel}
                  onChange={(e) => setManualMakeModel(e.target.value)}
                  className="w-full bg-slate-900 border border-slate-700 rounded-lg px-3 py-2 text-xs text-white placeholder-slate-500 focus:outline-none focus:border-blue-500"
                />
              </div>
            </div>

            <div>
              <label className="block text-xs font-semibold text-slate-300 mb-1">
                أكواد الأعطال (DTC) أو النص المنسوخ من جهاز الفحص:
              </label>
              <textarea
                rows={3}
                placeholder="P0102 Mass Air Flow Circuit Low&#10;P0113 Intake Air Temp High&#10;02 Ignition Cyl 4"
                value={manualCodes}
                onChange={(e) => setManualCodes(e.target.value)}
                className="w-full bg-slate-900 border border-slate-700 rounded-lg p-3 text-xs text-white placeholder-slate-500 focus:outline-none focus:border-blue-500 font-mono"
              />
            </div>

            <button
              type="submit"
              disabled={isLoading}
              className="w-full bg-blue-600 hover:bg-blue-500 text-white font-bold py-2.5 px-4 rounded-lg transition-colors flex items-center justify-center gap-2 cursor-pointer disabled:opacity-50 text-xs"
            >
              <Zap className="w-3.5 h-3.5" />
              تحليل الأكواد وإصدار التقرير
            </button>
          </form>
        )}

        {/* Loading Overlay */}
        {isLoading && (
          <div className="absolute inset-0 bg-slate-950/80 backdrop-blur-sm flex flex-col items-center justify-center p-6 z-20">
            <Loader2 className="w-7 h-7 text-blue-400 animate-spin mb-3" />
            <h4 className="text-sm font-bold text-white mb-1">جاري المعالجة والتحليل الفني</h4>
            <p className="text-xs text-slate-400 text-center max-w-sm">
              {statusMessage || "جاري استخراج البيانات والمطابقة مع القاموس الفني..."}
            </p>
          </div>
        )}

        {/* Error Alert */}
        {errorMsg && (
          <div className="p-3 bg-rose-950/70 border border-rose-800 rounded-lg flex items-center gap-2 text-rose-300 text-xs">
            <AlertCircle className="w-4 h-4 shrink-0 text-rose-400" />
            <span>{errorMsg}</span>
          </div>
        )}
      </div>
    </div>
  );
};
