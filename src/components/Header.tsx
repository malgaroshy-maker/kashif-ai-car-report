"use client";

import React, { useState, useEffect } from "react";
import {
  Wrench,
  FileText,
  BookOpen,
  Search,
  X,
  Key,
  CheckCircle,
  Eye,
  EyeOff,
  ExternalLink,
  Cpu,
  RefreshCw,
  ShieldCheck,
} from "lucide-react";
import { LIBYAN_DICTIONARY } from "@/lib/dictionary";
import { AvailableModelItem } from "@/lib/gemini";

interface HeaderProps {
  onNewScanClick?: () => void;
  hasActiveReport?: boolean;
}

export const Header: React.FC<HeaderProps> = ({
  onNewScanClick,
  hasActiveReport,
}) => {
  const [isDictionaryOpen, setIsDictionaryOpen] = useState(false);
  const [isSettingsOpen, setIsSettingsOpen] = useState(false);
  const [searchTerm, setSearchTerm] = useState("");
  const [selectedCategory, setSelectedCategory] = useState<string>("الكل");

  // API Key & Provider State
  const [provider, setProvider] = useState<"gemini" | "agy">("gemini");
  const [agyStatus, setAgyStatus] = useState<{ available: boolean; cliPath?: string; statusNote?: string } | null>(null);
  const [apiKey, setApiKey] = useState("");
  const [hasEnvKey, setHasEnvKey] = useState(false);
  const [selectedModel, setSelectedModel] = useState("gemini-3.7-flash");
  const [availableModels, setAvailableModels] = useState<AvailableModelItem[]>([
    { id: "gemini-3.7-flash", displayName: "Gemini 3.7 Flash", description: "النموذج الافتراضي الأحدث والأعلى كفاءة", isRecommended: true },
    { id: "gemini-3.5-flash-lite", displayName: "Gemini 3.5 Flash-Lite", description: "نموذج خفيف وفائق السرعة (490ms)" },
    { id: "gemini-3.6-flash", displayName: "Gemini 3.6 Flash", description: "معالجة متعددة الوسائط سريعة" },
    { id: "gemini-3.5-flash", displayName: "Gemini 3.5 Flash", description: "استنتاج متقدم وسريع" },
    { id: "gemini-3.1-flash-lite", displayName: "Gemini 3.1 Flash-Lite", description: "معالجة خفيفة سريعة وموفرة للحصة" },
    { id: "gemini-2.5-flash", displayName: "Gemini 2.5 Flash", description: "معالجة سريعة للمستندات" },
  ]);
  const [isLoadingModels, setIsLoadingModels] = useState(false);
  const [showKey, setShowKey] = useState(false);
  const [savedStatus, setSavedStatus] = useState<string | null>(null);

  useEffect(() => {
    const savedProvider = localStorage.getItem("kashif_ai_provider") as "gemini" | "agy" | null;
    if (savedProvider) {
      setProvider(savedProvider);
    }
    const savedKey = localStorage.getItem("kashif_gemini_api_key");
    if (savedKey) {
      setApiKey(savedKey);
    }
    const savedModel = localStorage.getItem("kashif_gemini_model");
    if (savedModel) {
      setSelectedModel(savedModel);
    }

    // Check server env key and AGY CLI status
    fetch("/api/models")
      .then((r) => r.json())
      .then((data) => {
        if (data.hasEnvKey) {
          setHasEnvKey(true);
        }
        if (data.agyStatus) {
          setAgyStatus(data.agyStatus);
        }
        if (data.success && Array.isArray(data.models) && data.models.length > 0) {
          setAvailableModels(data.models);
        }
      })
      .catch(() => {});
  }, []);

  const handleToggleProvider = (newProvider: "gemini" | "agy") => {
    setProvider(newProvider);
    localStorage.setItem("kashif_ai_provider", newProvider);
  };

  // Fetch live models from /api/models
  const loadLiveModels = async () => {
    setIsLoadingModels(true);
    try {
      const headers: Record<string, string> = {};
      if (apiKey.trim()) {
        headers["x-gemini-api-key"] = apiKey.trim();
      }
      const res = await fetch("/api/models", { headers });
      const data = await res.json();
      if (data.hasEnvKey) {
        setHasEnvKey(true);
      }
      if (data.agyStatus) {
        setAgyStatus(data.agyStatus);
      }
      if (data.success && Array.isArray(data.models) && data.models.length > 0) {
        setAvailableModels(data.models);
      }
    } catch (e) {
      console.warn("Could not load live models:", e);
    } finally {
      setIsLoadingModels(false);
    }
  };

  useEffect(() => {
    if (isSettingsOpen) {
      loadLiveModels();
    }
  }, [isSettingsOpen]);

  const handleSaveApiKey = () => {
    localStorage.setItem("kashif_ai_provider", provider);
    if (apiKey.trim()) {
      localStorage.setItem("kashif_gemini_api_key", apiKey.trim());
      localStorage.setItem("kashif_gemini_model", selectedModel);
      setSavedStatus(`تم الحفظ بنجاح! المحرك: ${provider === "agy" ? "Antigravity CLI" : "Gemini API"}`);
    } else {
      localStorage.removeItem("kashif_gemini_api_key");
      setSavedStatus(`تم الحفظ! المحرك: ${provider === "agy" ? "Antigravity CLI" : "Gemini .env"}`);
    }
    setTimeout(() => setSavedStatus(null), 3000);
  };

  const isCloudConnected = hasEnvKey || Boolean(apiKey.trim());

  const categories = [
    "الكل",
    "الكهرباء والحساسات",
    "المحرك ونقل الحركة",
    "التعليق والصالة",
    "الفرامل والعادم",
    "التبريد والتكييف",
    "الهيكل والمقصورة",
    "عام وإداري",
  ];

  const filteredDictionary = LIBYAN_DICTIONARY.filter((item) => {
    const matchesSearch =
      item.libyanTerm.toLowerCase().includes(searchTerm.toLowerCase()) ||
      item.standardArabic.toLowerCase().includes(searchTerm.toLowerCase()) ||
      item.english.toLowerCase().includes(searchTerm.toLowerCase());
    const matchesCategory =
      selectedCategory === "الكل" || item.category === selectedCategory;
    return matchesSearch && matchesCategory;
  });

  return (
    <>
      <header className="w-full border-b border-slate-800 bg-[#090D16]/90 backdrop-blur-md sticky top-0 z-40">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 h-16 flex items-center justify-between">
          {/* Logo & Branding */}
          <div className="flex items-center gap-3">
            <div className="w-9 h-9 rounded-xl bg-blue-600 flex items-center justify-center text-white shadow-sm">
              <Wrench className="w-4 h-4" />
            </div>

            <div>
              <div className="flex items-center gap-2">
                <span className="text-base sm:text-lg font-bold tracking-tight text-white font-heading">
                  كاشف <span className="text-blue-400">AI</span>
                </span>
                <span className="text-[10px] font-semibold px-2 py-0.5 rounded bg-slate-800 text-slate-300 border border-slate-700 font-mono">
                  OBD DIAGNOSTICS
                </span>
              </div>
              <p className="text-[11px] text-slate-400 font-sans hidden sm:block">
                فاحص أعطال السيارات بالمصطلحات الفنية المعتمدة
              </p>
            </div>
          </div>

          {/* Actions */}
          <div className="flex items-center gap-2">
            {/* AI Engine Switcher Toggle */}
            <div className="hidden sm:flex items-center bg-slate-900 p-0.5 rounded-lg border border-slate-800 text-[11px] font-mono">
              <button
                onClick={() => handleToggleProvider("gemini")}
                className={`px-2.5 py-1 rounded-md transition-all cursor-pointer flex items-center gap-1 ${
                  provider === "gemini"
                    ? "bg-blue-600 text-white font-bold shadow-sm"
                    : "text-slate-400 hover:text-slate-200"
                }`}
                title="Google Gemini Cloud API"
              >
                <span>🌐 Gemini</span>
              </button>
              <button
                onClick={() => handleToggleProvider("agy")}
                className={`px-2.5 py-1 rounded-md transition-all cursor-pointer flex items-center gap-1 ${
                  provider === "agy"
                    ? "bg-purple-600 text-white font-bold shadow-sm"
                    : "text-slate-400 hover:text-slate-200"
                }`}
                title="Antigravity CLI (agy) Local Engine"
              >
                <span>💻 agy CLI</span>
              </button>
            </div>

            {/* Dictionary Explorer */}
            <button
              onClick={() => setIsDictionaryOpen(true)}
              className="flex items-center gap-1.5 text-xs font-semibold px-3 py-1.5 rounded-lg bg-slate-900 hover:bg-slate-800 text-slate-300 hover:text-white border border-slate-800 transition-colors cursor-pointer"
            >
              <BookOpen className="w-3.5 h-3.5 text-blue-400" />
              <span className="hidden sm:inline">القاموس الفني</span>
            </button>

            {/* API Key Settings */}
            <button
              onClick={() => setIsSettingsOpen(true)}
              className="flex items-center gap-1.5 text-xs font-semibold px-3 py-1.5 rounded-lg bg-slate-900 hover:bg-slate-800 text-slate-300 hover:text-white border border-slate-800 transition-colors cursor-pointer"
            >
              <Key className="w-3.5 h-3.5 text-amber-400" />
              <span className="hidden md:inline font-mono">
                {provider === "agy" ? "Antigravity CLI" : (isCloudConnected ? selectedModel : "إعدادات API")}
              </span>
              <span
                className={`w-1.5 h-1.5 rounded-full ${
                  provider === "agy"
                    ? agyStatus?.available
                      ? "bg-purple-400"
                      : "bg-amber-400"
                    : isCloudConnected
                    ? "bg-emerald-400"
                    : "bg-slate-500"
                }`}
              />
            </button>

            {/* New Scan */}
            {hasActiveReport && onNewScanClick && (
              <button
                onClick={onNewScanClick}
                className="flex items-center gap-1.5 text-xs font-bold px-3.5 py-1.5 rounded-lg bg-blue-600 hover:bg-blue-500 text-white transition-colors cursor-pointer"
              >
                <FileText className="w-3.5 h-3.5" />
                <span>فحص جديد</span>
              </button>
            )}
          </div>
        </div>
      </header>

      {/* API Key Modal */}
      {isSettingsOpen && (
        <div
          onClick={() => setIsSettingsOpen(false)}
          className="fixed inset-0 z-50 bg-slate-950/80 backdrop-blur-sm flex items-center justify-center p-4"
        >
          <div
            onClick={(e) => e.stopPropagation()}
            className="bg-[#0F172A] border border-slate-800 rounded-2xl max-w-md w-full p-5 shadow-2xl space-y-4 relative"
          >
            <div className="flex items-center justify-between border-b border-slate-800 pb-3">
              <div className="flex items-center gap-2">
                <Key className="w-4 h-4 text-blue-400" />
                <h3 className="text-sm font-bold text-white font-heading">
                  إعدادات مفتاح ونماذج الذكاء الاصطناعي (Gemini)
                </h3>
              </div>
              <button
                onClick={() => setIsSettingsOpen(false)}
                className="text-slate-400 hover:text-white p-1 rounded hover:bg-slate-800 cursor-pointer"
              >
                <X className="w-4 h-4" />
              </button>
            </div>

            <div className="space-y-3 text-xs">
              {/* AI Engine Mode Selector Card */}
              <div className="p-3 rounded-xl bg-slate-950 border border-slate-800 space-y-2">
                <span className="font-semibold text-slate-300 block">محرك الذكاء الاصطناعي الفعّال:</span>
                <div className="grid grid-cols-2 gap-2">
                  <button
                    type="button"
                    onClick={() => handleToggleProvider("gemini")}
                    className={`p-2.5 rounded-lg border text-right transition-all cursor-pointer ${
                      provider === "gemini"
                        ? "bg-blue-950/70 border-blue-500 text-blue-300 font-bold"
                        : "bg-slate-900 border-slate-800 text-slate-400 hover:text-slate-200"
                    }`}
                  >
                    <div className="text-xs">🌐 Gemini Cloud API</div>
                    <div className="text-[10px] text-slate-400 font-normal mt-0.5">سحابي مباشر وفائق السرعة</div>
                  </button>

                  <button
                    type="button"
                    onClick={() => handleToggleProvider("agy")}
                    className={`p-2.5 rounded-lg border text-right transition-all cursor-pointer ${
                      provider === "agy"
                        ? "bg-purple-950/70 border-purple-500 text-purple-300 font-bold"
                        : "bg-slate-900 border-slate-800 text-slate-400 hover:text-slate-200"
                    }`}
                  >
                    <div className="text-xs">💻 Antigravity (agy)</div>
                    <div className="text-[10px] text-slate-400 font-normal mt-0.5">
                      {agyStatus?.available ? "محرك وكيل محلي جاهز ✅" : "أداة CLI في الخادم"}
                    </div>
                  </button>
                </div>

                {provider === "agy" && (
                  <div className="p-2.5 rounded-lg bg-purple-950/40 border border-purple-800/50 text-[11px] text-purple-200 space-y-1 font-mono">
                    <div className="flex items-center justify-between">
                      <span>حالة CLI:</span>
                      <span className="font-bold text-emerald-400">{agyStatus?.available ? "متصل ومتاح" : "غير متاح (تحويل لـ Gemini)"}</span>
                    </div>
                    {agyStatus?.cliPath && (
                      <div className="text-[10px] text-slate-400 truncate">
                        المسار: {agyStatus.cliPath}
                      </div>
                    )}
                  </div>
                )}
              </div>

              <div className="p-3 rounded-xl bg-slate-950 border border-slate-800 space-y-1.5">
                <div className="flex items-center justify-between">
                  <span className="font-semibold text-slate-300">مصدر المفتاح الفعال:</span>
                  <span
                    className={`font-semibold px-2 py-0.5 rounded text-[11px] font-mono flex items-center gap-1 ${
                      hasEnvKey
                        ? "bg-emerald-950 text-emerald-300 border border-emerald-800"
                        : apiKey
                        ? "bg-blue-950 text-blue-300 border border-blue-800"
                        : "bg-slate-800 text-slate-300 border border-slate-700"
                    }`}
                  >
                    {hasEnvKey ? (
                      <>
                        <ShieldCheck className="w-3 h-3 text-emerald-400" />
                        <span>ملف .env.local (أولوية أولى)</span>
                      </>
                    ) : apiKey ? (
                      "إعدادات المتصفح (احتياطي)"
                    ) : (
                      "المحرك المحلي المدمج"
                    )}
                  </span>
                </div>
                <p className="text-slate-400 text-[11px] leading-relaxed">
                  {hasEnvKey
                    ? "يتم استخدام مفتاح .env.local تلقائياً كأولوية أولى. النموذج المعتمد: "
                    : "يمكنك إدخال مفتاح API احتياطي هنا في حال عدم وجوده في ملف .env: "}
                  <strong className="text-white">{selectedModel}</strong>
                </p>
              </div>

              {/* Model Selector */}
              <div>
                <div className="flex items-center justify-between mb-1">
                  <label className="text-slate-300 font-semibold flex items-center gap-1.5">
                    <Cpu className="w-3.5 h-3.5 text-blue-400" />
                    <span>النماذج السحابية المتاحة ({availableModels.length}):</span>
                  </label>
                  <button
                    onClick={loadLiveModels}
                    disabled={isLoadingModels}
                    className="text-[10px] text-blue-400 hover:text-blue-300 flex items-center gap-1 cursor-pointer disabled:opacity-50"
                  >
                    <RefreshCw className={`w-3 h-3 ${isLoadingModels ? "animate-spin" : ""}`} />
                    تحديث
                  </button>
                </div>
                <select
                  value={selectedModel}
                  onChange={(e) => setSelectedModel(e.target.value)}
                  className="w-full bg-slate-950 border border-slate-700 rounded-lg px-3 py-2 text-xs text-white font-mono focus:outline-none focus:border-blue-500 cursor-pointer"
                >
                  {availableModels.map((m) => (
                    <option key={m.id} value={m.id}>
                      {m.id} {m.isRecommended ? "(الافتراضي ⭐)" : `(${m.displayName})`}
                    </option>
                  ))}
                </select>
              </div>

              <div>
                <label className="block text-slate-300 font-semibold mb-1">
                  مفتاح Gemini API الاحتياطي (اختياري إذا تم تعيينه في .env):
                </label>
                <div className="relative">
                  <input
                    type={showKey ? "text" : "password"}
                    placeholder={hasEnvKey ? "المفتاح محمل بالفعل من .env.local" : "AIzaSy..."}
                    value={apiKey}
                    onChange={(e) => setApiKey(e.target.value)}
                    className="w-full bg-slate-950 border border-slate-700 rounded-lg pr-3 pl-9 py-2 text-xs text-white font-mono placeholder-slate-600 focus:outline-none focus:border-blue-500"
                  />
                  <button
                    type="button"
                    onClick={() => setShowKey(!showKey)}
                    className="absolute left-2.5 top-1/2 -translate-y-1/2 text-slate-400 hover:text-white cursor-pointer"
                  >
                    {showKey ? <EyeOff className="w-3.5 h-3.5" /> : <Eye className="w-3.5 h-3.5" />}
                  </button>
                </div>
              </div>

              <div className="pt-1">
                <a
                  href="https://aistudio.google.com/app/apikey"
                  target="_blank"
                  rel="noreferrer"
                  className="text-blue-400 hover:underline flex items-center gap-1 text-[11px]"
                >
                  <ExternalLink className="w-3 h-3" />
                  الحصول على مفتاح مجاني من Google AI Studio
                </a>
              </div>

              {savedStatus && (
                <div className="p-2.5 bg-emerald-950/80 border border-emerald-800 rounded-lg text-emerald-300 text-xs flex items-center gap-1.5">
                  <CheckCircle className="w-3.5 h-3.5 shrink-0" />
                  <span>{savedStatus}</span>
                </div>
              )}

              <div className="pt-2 flex gap-2">
                <button
                  onClick={handleSaveApiKey}
                  className="flex-1 bg-blue-600 hover:bg-blue-500 text-white font-bold py-2 px-3 rounded-lg transition-colors cursor-pointer text-xs"
                >
                  حفظ الإعدادات
                </button>
                <button
                  onClick={() => {
                    setApiKey("");
                    localStorage.removeItem("kashif_gemini_api_key");
                    setSavedStatus("تمت الإزالة والاعتماد على .env / المحرك المحلي");
                  }}
                  className="bg-slate-800 hover:bg-slate-700 text-slate-300 py-2 px-3 rounded-lg transition-colors cursor-pointer text-xs border border-slate-700"
                >
                  مسح
                </button>
              </div>
            </div>
          </div>
        </div>
      )}

      {/* Dictionary Modal */}
      {isDictionaryOpen && (
        <div
          onClick={() => setIsDictionaryOpen(false)}
          className="fixed inset-0 z-50 bg-slate-950/80 backdrop-blur-sm flex items-center justify-center p-4"
        >
          <div
            onClick={(e) => e.stopPropagation()}
            className="bg-[#0F172A] border border-slate-800 rounded-2xl max-w-2xl w-full max-h-[85vh] flex flex-col shadow-2xl overflow-hidden"
          >
            {/* Modal Header */}
            <div className="p-4 border-b border-slate-800 flex items-center justify-between">
              <div className="flex items-center gap-2">
                <BookOpen className="w-4 h-4 text-blue-400" />
                <div>
                  <h3 className="text-sm font-bold text-white font-heading">
                    قاموس مصطلحات صيانة السيارات المعتمدة
                  </h3>
                  <p className="text-[11px] text-slate-400">
                    المصطلحات الميدانية المتداولة في ورش الصيانة الليبية
                  </p>
                </div>
              </div>
              <button
                onClick={() => setIsDictionaryOpen(false)}
                className="text-slate-400 hover:text-white p-1 rounded hover:bg-slate-800 cursor-pointer"
              >
                <X className="w-4 h-4" />
              </button>
            </div>

            {/* Search and Category Filters */}
            <div className="p-3.5 border-b border-slate-800 bg-slate-950/60 space-y-2.5">
              <div className="relative">
                <Search className="w-3.5 h-3.5 text-slate-400 absolute right-3 top-1/2 -translate-y-1/2" />
                <input
                  type="text"
                  placeholder="ابحث عن أي مصطلح (مثل: باطنيات، بوبينة، شمعات، بيانتو)..."
                  value={searchTerm}
                  onChange={(e) => setSearchTerm(e.target.value)}
                  className="w-full bg-slate-900 border border-slate-700 rounded-lg pr-9 pl-3 py-1.5 text-xs text-white placeholder-slate-500 focus:outline-none focus:border-blue-500"
                />
              </div>

              <div className="flex flex-wrap gap-1">
                {categories.map((cat) => (
                  <button
                    key={cat}
                    onClick={() => setSelectedCategory(cat)}
                    className={`text-[11px] px-2 py-0.5 rounded transition-colors cursor-pointer ${
                      selectedCategory === cat
                        ? "bg-blue-600 text-white font-semibold"
                        : "bg-slate-900 hover:bg-slate-800 text-slate-400 border border-slate-800"
                    }`}
                  >
                    {cat}
                  </button>
                ))}
              </div>
            </div>

            {/* Dictionary List */}
            <div className="flex-1 overflow-y-auto p-3.5 space-y-2">
              {filteredDictionary.length === 0 ? (
                <div className="text-center py-8 text-slate-500 text-xs">
                  لا توجد نتائج مطابقة لبحثك.
                </div>
              ) : (
                filteredDictionary.map((item, idx) => (
                  <div
                    key={idx}
                    className="p-3 rounded-xl bg-slate-950 border border-slate-800/90 flex flex-col sm:flex-row sm:items-center justify-between gap-2"
                  >
                    <div>
                      <div className="flex items-center gap-2">
                        <span className="font-bold text-white text-xs sm:text-sm font-heading">
                          {item.libyanTerm}
                        </span>
                        <span className="text-[10px] text-blue-300 bg-slate-800 px-1.5 py-0.5 rounded">
                          {item.category}
                        </span>
                      </div>
                      <p className="text-xs text-slate-400 mt-0.5">
                        {item.standardArabic}
                      </p>
                    </div>

                    <span className="text-[11px] font-mono text-slate-300 bg-slate-900 px-2 py-0.5 rounded border border-slate-800 self-start sm:self-center shrink-0">
                      {item.english}
                    </span>
                  </div>
                ))
              )}
            </div>

            {/* Footer */}
            <div className="p-2.5 border-t border-slate-800 bg-slate-950 text-center text-[11px] text-slate-500">
              إجمالي المصطلحات: {LIBYAN_DICTIONARY.length} مصطلح فني
            </div>
          </div>
        </div>
      )}
    </>
  );
};
