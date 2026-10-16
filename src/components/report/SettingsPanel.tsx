"use client";

import * as React from "react";
import { Button, CodePlate } from "@/components/ui/primitives";
import { Sheet } from "@/components/ui/Sheet";
import { STORAGE_KEYS } from "@/lib/api-client";
import { removeLocal, useLocalString, writeLocal } from "@/lib/local-store";
import { DEFAULT_MODEL, KNOWN_MODELS, type AvailableModelItem } from "@/lib/models";

export const APINEX_FREE_MODELS = [
  {
    id: "free/deepseek-v4.1-flash",
    name: "DeepSeek V4.1 Flash (مجاني • مستقر ومجرب 3.1 ثانية)",
    desc: "النموذج الشهير المعتمد لتشخيص الأعطال وقراءة أكواد الفحص بدون اشتراك",
  },
  {
    id: "free/deepseek-v4-pro-0813",
    name: "DeepSeek V4 Pro (مجاني • استدلال احترافي عميق)",
    desc: "استدلال منطقي متقدم لأعطال السيارات الشديدة والمتشابكة والأنظمة الهجينة",
  },
  {
    id: "free/gpt-6-luna",
    name: "GPT-6 Luna (مجاني • صياغة تقارير شاملة)",
    desc: "تحليل تفصيلي شامل للأعطال مع مقارنات دقيقة لحساسات الأكسجين والعادم",
  },
  {
    id: "free/qwen-3.8-max",
    name: "Qwen 3.8 Max (مجاني • دقة تشخيص فائقة)",
    desc: "تحليل معمق للأعطال والدوائر الكهربائية والظفيرة",
  },
];

export function SettingsPanel({ onClose }: { onClose: () => void }) {
  // Stored state
  const storedKey = useLocalString(STORAGE_KEYS.apiKey);
  const storedModel = useLocalString(STORAGE_KEYS.model, DEFAULT_MODEL);
  const storedProvider = useLocalString(STORAGE_KEYS.provider, "gemini");

  const storedApinexKey = useLocalString(STORAGE_KEYS.apinexApiKey, "");
  const storedApinexModel = useLocalString(STORAGE_KEYS.apinexModel, "free/deepseek-v4.1-flash");
  const storedUseApinexPrimary = useLocalString(STORAGE_KEYS.useApinexAsPrimary, "false");
  const storedAutoFailover = useLocalString(STORAGE_KEYS.isApinexAutoFailoverEnabled, "true");
  const storedTokenSaver = useLocalString(STORAGE_KEYS.isTokenSaverEnabled, "true");

  const storedWorkshopName = useLocalString(STORAGE_KEYS.workshopName, "");
  const storedWorkshopPhone = useLocalString(STORAGE_KEYS.workshopPhone, "");
  const storedWorkshopAddress = useLocalString(STORAGE_KEYS.workshopAddress, "");
  const storedTechName = useLocalString(STORAGE_KEYS.technicianName, "");

  // Draft state
  const [draftKey, setDraftKey] = React.useState<string | null>(null);
  const [draftModel, setDraftModel] = React.useState<string | null>(null);
  const [draftProvider, setDraftProvider] = React.useState<string | null>(null);

  const [draftApinexKey, setDraftApinexKey] = React.useState<string | null>(null);
  const [draftApinexModel, setDraftApinexModel] = React.useState<string | null>(null);
  const [draftUseApinexPrimary, setDraftUseApinexPrimary] = React.useState<boolean | null>(null);
  const [draftAutoFailover, setDraftAutoFailover] = React.useState<boolean | null>(null);
  const [draftTokenSaver, setDraftTokenSaver] = React.useState<boolean | null>(null);

  const [draftWorkshopName, setDraftWorkshopName] = React.useState<string | null>(null);
  const [draftWorkshopPhone, setDraftWorkshopPhone] = React.useState<string | null>(null);
  const [draftWorkshopAddress, setDraftWorkshopAddress] = React.useState<string | null>(null);
  const [draftTechName, setDraftTechName] = React.useState<string | null>(null);

  const [revealGemini, setRevealGemini] = React.useState(false);
  const [revealApinex, setRevealApinex] = React.useState(false);
  const [saved, setSaved] = React.useState(false);
  const [models, setModels] = React.useState<AvailableModelItem[]>(KNOWN_MODELS);
  const [hasServerKey, setHasServerKey] = React.useState(false);

  // Active values
  const apiKey = draftKey ?? storedKey;
  const model = draftModel ?? storedModel;
  const provider = draftProvider ?? storedProvider;

  const apinexKey = draftApinexKey ?? storedApinexKey;
  const apinexModel = draftApinexModel ?? storedApinexModel;
  const useApinexPrimary = draftUseApinexPrimary ?? (storedUseApinexPrimary === "true");
  const autoFailover = draftAutoFailover ?? (storedAutoFailover !== "false");
  const tokenSaver = draftTokenSaver ?? (storedTokenSaver !== "false");

  const workshopName = draftWorkshopName ?? storedWorkshopName;
  const workshopPhone = draftWorkshopPhone ?? storedWorkshopPhone;
  const workshopAddress = draftWorkshopAddress ?? storedWorkshopAddress;
  const techName = draftTechName ?? storedTechName;

  // Auto-sanitize legacy leaked key if found in browser localStorage
  React.useEffect(() => {
    if (storedApinexKey && storedApinexKey.startsWith("sk-apxa56a82e") && storedApinexKey.endsWith("cbf19")) {
      removeLocal(STORAGE_KEYS.apinexApiKey);
      setDraftApinexKey("");
    }
  }, [storedApinexKey]);

  React.useEffect(() => {
    const controller = new AbortController();
    const headers: Record<string, string> = {};
    const key = (draftKey ?? storedKey).trim();
    if (key) headers["x-gemini-api-key"] = key;

    fetch("/api/models", { headers, signal: controller.signal })
      .then((r) => r.json())
      .then((data: { models?: AvailableModelItem[]; hasEnvKey?: boolean }) => {
        if (Array.isArray(data.models) && data.models.length > 0) {
          setModels(data.models);
        }
        setHasServerKey(Boolean(data.hasEnvKey));
      })
      .catch(() => {});

    return () => controller.abort();
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  const save = () => {
    // Gemini
    if (apiKey.trim()) {
      writeLocal(STORAGE_KEYS.apiKey, apiKey.trim());
    } else {
      removeLocal(STORAGE_KEYS.apiKey);
    }
    writeLocal(STORAGE_KEYS.model, model);
    writeLocal(STORAGE_KEYS.provider, provider);

    // APInex
    if (apinexKey.trim()) {
      writeLocal(STORAGE_KEYS.apinexApiKey, apinexKey.trim());
    } else {
      removeLocal(STORAGE_KEYS.apinexApiKey);
    }
    writeLocal(STORAGE_KEYS.apinexModel, apinexModel);
    writeLocal(STORAGE_KEYS.useApinexAsPrimary, useApinexPrimary ? "true" : "false");
    writeLocal(STORAGE_KEYS.isApinexAutoFailoverEnabled, autoFailover ? "true" : "false");
    writeLocal(STORAGE_KEYS.isTokenSaverEnabled, tokenSaver ? "true" : "false");

    // Workshop
    writeLocal(STORAGE_KEYS.workshopName, workshopName.trim());
    writeLocal(STORAGE_KEYS.workshopPhone, workshopPhone.trim());
    writeLocal(STORAGE_KEYS.workshopAddress, workshopAddress.trim());
    writeLocal(STORAGE_KEYS.technicianName, techName.trim());

    setDraftKey(null);
    setDraftModel(null);
    setDraftProvider(null);
    setDraftApinexKey(null);
    setDraftApinexModel(null);
    setDraftUseApinexPrimary(null);
    setDraftAutoFailover(null);
    setDraftTokenSaver(null);
    setDraftWorkshopName(null);
    setDraftWorkshopPhone(null);
    setDraftWorkshopAddress(null);
    setDraftTechName(null);

    setSaved(true);
    setTimeout(() => setSaved(false), 3000);
  };

  return (
    <Sheet
      title="إعدادات كاشف والمحركات الذكية"
      onClose={onClose}
      footer={
        <div className="flex items-center gap-[var(--s3)]">
          <Button variant="primary" onClick={save} className="flex-1">
            حفظ التغييرات
          </Button>
          <span className="k-label normal-case font-bold text-emerald-500" role="status" aria-live="polite">
            {saved ? "✓ تم حفظ الإعدادات بنجاح" : ""}
          </span>
        </div>
      }
    >
      <div className="space-y-[var(--s5)]">
        {/* 1. اختيار محرك الفحص الأساسي (Engine Cards) */}
        <section>
          <h3 className="k-label uppercase font-bold text-(color:--ink)">
            المحرك الأساسي للتحليل والفحص
          </h3>
          <p className="mt-[var(--s2)] leading-relaxed text-xs text-(color:--ink-2)">
            اختر المحرك الذي يقوم بقراءة تقارير أجهزة الفحص (Launch, Ediag, Autel) واستخراج قطع الغيار.
          </p>

          <div className="mt-[var(--s3)] grid grid-cols-1 gap-2.5 sm:grid-cols-2">
            {/* بطاقة Google Gemini */}
            <div
              onClick={() => {
                setDraftUseApinexPrimary(false);
                setDraftProvider("gemini");
                setSaved(false);
              }}
              className={`cursor-pointer rounded-lg border p-3.5 transition ${
                !useApinexPrimary
                  ? "border-[var(--royal-blue-light)] bg-[var(--royal-blue)]/10 shadow-sm"
                  : "border-[var(--rib)] bg-[var(--cell)] hover:bg-[var(--board-sunk)]"
              }`}
            >
              <div className="flex items-center justify-between">
                <span className="font-bold text-sm text-(color:--ink)">Google Gemini</span>
                {!useApinexPrimary && (
                  <span className="rounded bg-[var(--royal-blue)] px-2 py-0.5 text-[10px] font-bold text-white">
                    المفعل حالياً
                  </span>
                )}
              </div>
              <p className="mt-1.5 text-xs text-(color:--ink-2) leading-relaxed">
                محرك سحابي فائق السرعة، يدعم تحليل الصور والنصوص وقراءة الـ PDF مباشرة.
              </p>
            </div>

            {/* بطاقة APInex Engine */}
            <div
              onClick={() => {
                setDraftUseApinexPrimary(true);
                setDraftProvider("apinex");
                setSaved(false);
              }}
              className={`cursor-pointer rounded-lg border p-3.5 transition ${
                useApinexPrimary
                  ? "border-[var(--gold-primary)] bg-[var(--gold-primary)]/10 shadow-sm"
                  : "border-[var(--rib)] bg-[var(--cell)] hover:bg-[var(--board-sunk)]"
              }`}
            >
              <div className="flex items-center justify-between">
                <span className="font-bold text-sm text-(color:--ink)">
                  APInex / DeepSeek & GPT
                </span>
                {useApinexPrimary && (
                  <span className="rounded bg-[var(--gold-primary)] px-2 py-0.5 text-[10px] font-bold text-black">
                    المفعل حالياً
                  </span>
                )}
              </div>
              <p className="mt-1.5 text-xs text-(color:--ink-2) leading-relaxed">
                بوابة النماذج المباشرة المجانية (DeepSeek V4.1, GPT-6 Luna, Qwen Max).
              </p>
            </div>
          </div>
        </section>

        {/* 2. إعدادات APInex والنماذج المجانية */}
        <section className="rounded-lg border border-[var(--rib)] bg-[var(--cell)] p-4 space-y-4">
          <div className="flex items-center justify-between border-b border-[var(--rib)] pb-2.5">
            <div>
              <h3 className="font-bold text-sm text-(color:--ink)">
                إعدادات محرك APInex والنماذج المجانية
              </h3>
              <p className="text-[11px] text-(color:--ink-2)">
                دعم التبديل السلس للنماذج المجانية والتحويل التلقائي عند نفاذ الكوتة
              </p>
            </div>
            <CodePlate>Free AI Models</CodePlate>
          </div>

          {/* خيار التحويل التلقائي Failover */}
          <label className="flex items-center justify-between gap-3 cursor-pointer">
            <span className="text-xs text-(color:--ink)">
              <span className="font-bold block">التحويل التلقائي لـ APInex عند نفاذ الكوتة (Quota Failover)</span>
              <span className="text-[11px] text-(color:--ink-2) block">
                في حال ظهور خطأ 429 أو نفاذ رصيد Gemini، يتحول الفحص فوراً لـ APInex دون توقف.
              </span>
            </span>
            <input
              type="checkbox"
              checked={autoFailover}
              onChange={(e) => {
                setDraftAutoFailover(e.target.checked);
                setSaved(false);
              }}
              className="h-4 w-4 rounded border-[var(--rib)] text-[var(--royal-blue)]"
            />
          </label>

          {/* حقل مفتاح APInex */}
          <div>
            <div className="flex items-center justify-between mb-1.5">
              <span className="text-xs font-bold text-(color:--ink)">
                مفتاح API الخاص بـ APInex:
              </span>
              {apinexKey && (
                <button
                  type="button"
                  onClick={() => {
                    setDraftApinexKey("");
                    setSaved(false);
                  }}
                  className="text-[11px] text-red-500 hover:underline"
                >
                  مسح المفتاح
                </button>
              )}
            </div>
            <div className="flex gap-2">
              <input
                type={revealApinex ? "text" : "password"}
                value={apinexKey}
                onChange={(e) => {
                  setDraftApinexKey(e.target.value.trim());
                  setSaved(false);
                }}
                placeholder="sk-apx... (أدخل مفتاحك الخاص من apinex.bond)"
                className="min-h-[var(--tap)] flex-1 rounded border border-[var(--rib)] bg-[var(--board-sunk)] px-3 font-mono text-xs text-(color:--ink) outline-none focus:border-[var(--royal-blue)]"
                dir="ltr"
              />
              <Button onClick={() => setRevealApinex((v) => !v)}>
                {revealApinex ? "إخفاء" : "إظهار"}
              </Button>
            </div>
            <div className="mt-2 rounded bg-blue-500/10 border border-blue-500/20 p-2 text-[11px] text-blue-700 dark:text-blue-300">
              🛡️ <strong>حماية الحساب:</strong> يتم حفظ مفتاحك محلياً في متصفحك فقط ولا يتم مشاركته أو رفعه في المستودعات لمنع حظر حسابك في apinex.bond.
            </div>
          </div>

          {/* اختيار النموذج المجاني لـ APInex */}
          <div>
            <span className="text-xs font-bold text-(color:--ink) block mb-2">
              النموذج المجاني المعتمد (APInex Model):
            </span>
            <div className="grid grid-cols-1 gap-2">
              {APINEX_FREE_MODELS.map((m) => {
                const active = apinexModel === m.id;
                return (
                  <label
                    key={m.id}
                    className={`flex cursor-pointer items-start gap-2.5 rounded border p-2.5 transition text-xs ${
                      active
                        ? "border-[var(--gold-primary)] bg-[var(--gold-primary)]/10"
                        : "border-[var(--rib)] hover:bg-[var(--board-sunk)]"
                    }`}
                  >
                    <input
                      type="radio"
                      name="kashif-apinex-model"
                      value={m.id}
                      checked={active}
                      onChange={() => {
                        setDraftApinexModel(m.id);
                        setSaved(false);
                      }}
                      className="mt-0.5 h-3.5 w-3.5 accent-[var(--gold-primary)]"
                    />
                    <div className="min-w-0 flex-1">
                      <span className="font-bold text-(color:--ink) block">{m.name}</span>
                      <span className="text-[11px] text-(color:--ink-2) mt-0.5 block">{m.desc}</span>
                    </div>
                  </label>
                );
              })}
            </div>
          </div>
        </section>

        {/* 3. إعدادات Google Gemini */}
        <section className="rounded-lg border border-[var(--rib)] bg-[var(--cell)] p-4 space-y-4">
          <div className="flex items-center justify-between border-b border-[var(--rib)] pb-2.5">
            <div>
              <h3 className="font-bold text-sm text-(color:--ink)">
                مفتاح Google AI Studio (Gemini)
              </h3>
              <p className="text-[11px] text-(color:--ink-2)">
                المحرك المعتمد للتحليل بالرؤية الحاسوبية وقراءة صور الفحص
              </p>
            </div>
            <CodePlate>Official Gemini</CodePlate>
          </div>

          <div className="flex gap-2">
            <input
              type={revealGemini ? "text" : "password"}
              value={apiKey}
              onChange={(e) => {
                setDraftKey(e.target.value.trim());
                setSaved(false);
              }}
              placeholder="AIzaSy... (الصق مفتاحك هنا)"
              className="min-h-[var(--tap)] flex-1 rounded border border-[var(--rib)] bg-[var(--board-sunk)] px-3 font-mono text-xs text-(color:--ink) outline-none focus:border-[var(--royal-blue)]"
              dir="ltr"
            />
            <Button onClick={() => setRevealGemini((v) => !v)}>
              {revealGemini ? "إخفاء" : "إظهار"}
            </Button>
          </div>

          <p className="text-[11px] text-(color:--ink-2)">
            يمكنك استخراج مفتاح مجاني رسمي من:{" "}
            <a
              href="https://aistudio.google.com/apikey"
              target="_blank"
              rel="noopener noreferrer"
              className="text-[var(--royal-blue-light)] underline font-bold"
            >
              aistudio.google.com/apikey
            </a>
          </p>

          <div>
            <span className="text-xs font-bold text-(color:--ink) block mb-2">
              نموذج Gemini المفضل:
            </span>
            <div className="space-y-1.5">
              {models.map((m) => {
                const active = m.id === model;
                return (
                  <label
                    key={m.id}
                    className={`flex cursor-pointer items-start gap-2.5 rounded border p-2 text-xs transition ${
                      active
                        ? "border-[var(--royal-blue-light)] bg-[var(--royal-blue)]/10"
                        : "border-[var(--rib)] hover:bg-[var(--board-sunk)]"
                    }`}
                  >
                    <input
                      type="radio"
                      name="kashif-gemini-model"
                      value={m.id}
                      checked={active}
                      onChange={() => {
                        setDraftModel(m.id);
                        setSaved(false);
                      }}
                      className="mt-0.5 h-3.5 w-3.5 accent-[var(--royal-blue)]"
                    />
                    <div className="min-w-0 flex-1">
                      <div className="flex items-center gap-2">
                        <span className="font-bold text-(color:--ink)">{m.displayName}</span>
                        {m.isRecommended && <CodePlate>موصى به</CodePlate>}
                      </div>
                      <span className="text-[11px] text-(color:--ink-2) mt-0.5 block">{m.description}</span>
                    </div>
                  </label>
                );
              })}
            </div>
          </div>
        </section>

        {/* 4. بيانات الورشة والفني (Workshop Profile) */}
        <section className="rounded-lg border border-[var(--rib)] bg-[var(--cell)] p-4 space-y-3">
          <div className="border-b border-[var(--rib)] pb-2.5">
            <h3 className="font-bold text-sm text-(color:--ink)">
              بيانات الورشة وتوقيع التقرير (Workshop Profile)
            </h3>
            <p className="text-[11px] text-(color:--ink-2)">
              تظهر هذه البيانات تلقائياً في ترويسة التقارير المطبوعة والمصدرة بصيغة PDF
            </p>
          </div>

          <div className="grid grid-cols-1 sm:grid-cols-2 gap-3">
            <div>
              <label className="text-xs font-bold text-(color:--ink) block mb-1">
                اسم الورشة / مركز الصيانة:
              </label>
              <input
                type="text"
                value={workshopName}
                onChange={(e) => {
                  setDraftWorkshopName(e.target.value);
                  setSaved(false);
                }}
                placeholder="مثال: مركز الفحص الهندسي للسيارات"
                className="w-full rounded border border-[var(--rib)] bg-[var(--board-sunk)] px-3 py-1.5 text-xs text-(color:--ink) outline-none focus:border-[var(--royal-blue)]"
              />
            </div>

            <div>
              <label className="text-xs font-bold text-(color:--ink) block mb-1">
                اسم الفني المسؤول:
              </label>
              <input
                type="text"
                value={techName}
                onChange={(e) => {
                  setDraftTechName(e.target.value);
                  setSaved(false);
                }}
                placeholder="مثال: م. علي المبروك"
                className="w-full rounded border border-[var(--rib)] bg-[var(--board-sunk)] px-3 py-1.5 text-xs text-(color:--ink) outline-none focus:border-[var(--royal-blue)]"
              />
            </div>

            <div>
              <label className="text-xs font-bold text-(color:--ink) block mb-1">
                رقم هاتف الورشة:
              </label>
              <input
                type="text"
                value={workshopPhone}
                onChange={(e) => {
                  setDraftWorkshopPhone(e.target.value);
                  setSaved(false);
                }}
                placeholder="مثال: 091-XXXXXXX"
                className="w-full rounded border border-[var(--rib)] bg-[var(--board-sunk)] px-3 py-1.5 text-xs text-(color:--ink) outline-none focus:border-[var(--royal-blue)]"
                dir="ltr"
              />
            </div>

            <div>
              <label className="text-xs font-bold text-(color:--ink) block mb-1">
                عنوان الورشة / المدينة:
              </label>
              <input
                type="text"
                value={workshopAddress}
                onChange={(e) => {
                  setDraftWorkshopAddress(e.target.value);
                  setSaved(false);
                }}
                placeholder="مثال: طرابلس - طريق الشط"
                className="w-full rounded border border-[var(--rib)] bg-[var(--board-sunk)] px-3 py-1.5 text-xs text-(color:--ink) outline-none focus:border-[var(--royal-blue)]"
              />
            </div>
          </div>
        </section>
      </div>
    </Sheet>
  );
}
