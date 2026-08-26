"use client";

import * as React from "react";
import { Button, CodePlate } from "@/components/ui/primitives";
import { Sheet } from "@/components/ui/Sheet";
import { STORAGE_KEYS } from "@/lib/api-client";
import { removeLocal, useLocalString, writeLocal } from "@/lib/local-store";
import { DEFAULT_MODEL, KNOWN_MODELS, type AvailableModelItem } from "@/lib/models";

/**
 * The key, and which model spends it.
 *
 * Kashif ships no shared key: the analysis runs on the reader's own Google AI
 * Studio key, which never leaves their browser except as a header on their own
 * requests. That is the single most important thing this panel has to say, so
 * it is the first thing in it rather than a footnote under the input.
 *
 * The panel it replaces had two bugs worth naming, both fixed by reading and
 * writing through `local-store` instead of touching `localStorage` directly:
 * saving a model without pasting a key silently discarded the model choice,
 * and nothing else on the page learned that the key had changed until a
 * reload.
 */
export function SettingsPanel({ onClose }: { onClose: () => void }) {
  const storedKey = useLocalString(STORAGE_KEYS.apiKey);
  const storedModel = useLocalString(STORAGE_KEYS.model, DEFAULT_MODEL);
  const storedProvider = useLocalString(STORAGE_KEYS.provider, "gemini");

  // `null` means untouched, so the saved value shows through.
  const [draftKey, setDraftKey] = React.useState<string | null>(null);
  const [draftModel, setDraftModel] = React.useState<string | null>(null);
  const [draftProvider, setDraftProvider] = React.useState<string | null>(null);
  const [reveal, setReveal] = React.useState(false);
  const [saved, setSaved] = React.useState(false);
  const [models, setModels] = React.useState<AvailableModelItem[]>(KNOWN_MODELS);
  const [hasServerKey, setHasServerKey] = React.useState(false);
  const [agyStatus, setAgyStatus] = React.useState<{
    available: boolean;
    engineName: string;
    statusNote?: string;
  } | null>(null);

  const apiKey = draftKey ?? storedKey;
  const model = draftModel ?? storedModel;
  const provider = draftProvider ?? storedProvider;

  // The live catalogue, so the list is not a hardcoded one that drifts. It is
  // fetched when the panel opens because that is the only time it is read.
  React.useEffect(() => {
    const controller = new AbortController();
    const headers: Record<string, string> = {};
    const key = (draftKey ?? storedKey).trim();
    if (key) headers["x-gemini-api-key"] = key;

    fetch("/api/models", { headers, signal: controller.signal })
      .then((r) => r.json())
      .then(
        (data: {
          models?: AvailableModelItem[];
          hasEnvKey?: boolean;
          agyStatus?: {
            available: boolean;
            engineName: string;
            statusNote?: string;
          };
        }) => {
          if (Array.isArray(data.models) && data.models.length > 0) {
            setModels(data.models);
          }
          setHasServerKey(Boolean(data.hasEnvKey));
          if (data.agyStatus) {
            setAgyStatus(data.agyStatus);
          }
        }
      )
      .catch(() => {
        // Offline, or no key yet. KNOWN_MODELS is a correct list either way.
      });

    return () => controller.abort();
    // Deliberately once per open: refetching on every keystroke would send a
    // half-typed key upstream.
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, []);

  const save = () => {
    if (apiKey.trim()) {
      writeLocal(STORAGE_KEYS.apiKey, apiKey.trim());
    } else {
      removeLocal(STORAGE_KEYS.apiKey);
    }
    // Saved whether or not there is a key. The old panel wrote the model only
    // inside the `if (key)` branch, so choosing a model first threw it away.
    writeLocal(STORAGE_KEYS.model, model);
    writeLocal(STORAGE_KEYS.provider, provider);
    setDraftKey(null);
    setDraftModel(null);
    setDraftProvider(null);
    setSaved(true);
  };

  return (
    <Sheet
      title="الإعدادات"
      onClose={onClose}
      footer={
        <div className="flex items-center gap-[var(--s3)]">
          <Button variant="primary" onClick={save} className="flex-1">
            حفظ
          </Button>
          <span className="k-label normal-case" role="status" aria-live="polite">
            {saved ? "تم الحفظ" : ""}
          </span>
        </div>
      }
    >
      <div className="space-y-[var(--s5)]">
        {/* محرك الذكاء الاصطناعي */}
        {agyStatus && (
          <section>
            <h3 className="k-label uppercase">محرك التحليل</h3>
            <p className="mt-[var(--s2)] leading-relaxed text-(color:--ink-2)">
              اختر محرك الذكاء الاصطناعي المستخدم لتحليل التقارير والمحادثة.
            </p>

            <div className="mt-[var(--s3)] space-y-[var(--s2)]">
              <label
                className={`flex cursor-pointer items-start gap-[var(--s3)] border p-[var(--s3)] transition-colors duration-[var(--dur-mark)] ${
                  provider === "gemini"
                    ? "border-[var(--amp-15-ink)] bg-[var(--board-sunk)]"
                    : "border-[var(--rib)] hover:bg-[var(--board-sunk)]"
                }`}
              >
                <input
                  type="radio"
                  name="kashif-provider"
                  value="gemini"
                  checked={provider === "gemini"}
                  onChange={() => {
                    setDraftProvider("gemini");
                    setSaved(false);
                  }}
                  className="mt-[3px] h-[16px] w-[16px] shrink-0 accent-[var(--amp-15-ink)]"
                />
                <span className="min-w-0 flex-1">
                  <span className="flex flex-wrap items-center gap-[var(--s2)]">
                    <span className="font-semibold text-(color:--ink)">
                      Google Gemini
                    </span>
                    <CodePlate>سحابي / معتمد</CodePlate>
                  </span>
                  <span className="k-label normal-case mt-[2px] block">
                    المحرك السحابي الأساسي، يدعم البث الحي للأجوبة ويتطلب مفتاح AI Studio.
                  </span>
                </span>
              </label>

              <label
                className={`flex cursor-pointer items-start gap-[var(--s3)] border p-[var(--s3)] transition-colors duration-[var(--dur-mark)] ${
                  provider === "agy"
                    ? "border-[var(--amp-15-ink)] bg-[var(--board-sunk)]"
                    : "border-[var(--rib)] hover:bg-[var(--board-sunk)]"
                }`}
              >
                <input
                  type="radio"
                  name="kashif-provider"
                  value="agy"
                  checked={provider === "agy"}
                  onChange={() => {
                    setDraftProvider("agy");
                    setSaved(false);
                  }}
                  className="mt-[3px] h-[16px] w-[16px] shrink-0 accent-[var(--amp-15-ink)]"
                />
                <span className="min-w-0 flex-1">
                  <span className="flex flex-wrap items-center gap-[var(--s2)]">
                    <span className="font-semibold text-(color:--ink)">
                      Antigravity CLI (agy)
                    </span>
                    <CodePlate>محلي / بيئة التطوير</CodePlate>
                    {agyStatus.available ? (
                      <span className="inline-flex items-center text-xs font-semibold text-[var(--amp-30-ink)]">
                        ● جاهز ونشط
                      </span>
                    ) : (
                      <span className="inline-flex items-center text-xs font-semibold text-[var(--ink-2)]">
                        ○ غير متصل
                      </span>
                    )}
                  </span>
                  <span className="k-label normal-case mt-[2px] block">
                    {agyStatus.statusNote || "تشغيل محلي مباشر عبر وكيل agy على جهازك."}
                  </span>
                </span>
              </label>
            </div>
          </section>
        )}

        <section className={agyStatus ? "rib pt-[var(--s4)]" : ""}>
          <h3 className="k-label uppercase">مفتاح Google AI Studio</h3>
          <p className="mt-[var(--s2)] leading-relaxed text-(color:--ink-2)">
            {provider === "agy"
              ? "مفتاح Google AI Studio مطلوب فقط عند استخدام محرك Gemini السحابي."
              : "كاشف ما يوفّرش مفتاح مشترك. مفتاحك يتخزّن في متصفحك أنت، وما يمشيش لأي جهة غير Google وقت التحليل."}
          </p>

          <div className="mt-[var(--s3)] flex gap-[var(--s2)]">
            <input
              data-autofocus
              type={reveal ? "text" : "password"}
              value={apiKey}
              onChange={(e) => {
                setDraftKey(e.target.value);
                setSaved(false);
              }}
              placeholder="AIza..."
              autoComplete="off"
              spellCheck={false}
              dir="ltr"
              aria-label="مفتاح Google AI Studio"
              className="min-h-[var(--tap)] min-w-0 flex-1 border border-[var(--rib)] bg-[var(--cell)] px-[var(--s3)] font-mono text-(length:--t-plate) text-(color:--ink) outline-none focus-visible:border-[var(--amp-15-ink)]"
            />
            <Button
              onClick={() => setReveal((v) => !v)}
              aria-label={reveal ? "إخفاء المفتاح" : "إظهار المفتاح"}
            >
              {reveal ? "إخفاء" : "إظهار"}
            </Button>
          </div>

          <p className="k-label normal-case mt-[var(--s2)]">
            تاخذه من{" "}
            <a
              href="https://aistudio.google.com/apikey"
              target="_blank"
              rel="noopener noreferrer"
              className="underline"
              style={{ color: "var(--amp-15-ink)" }}
            >
              aistudio.google.com/apikey
            </a>{" "}
            — مجاناً.
          </p>

          {hasServerKey && (
            <p className="k-label normal-case mt-[var(--s2)]">
              فيه مفتاح مضبوط على الخادم. لو حطيت مفتاحك هنا، مفتاحك هو
              اللي حينستعمل.
            </p>
          )}
        </section>

        <section className="rib pt-[var(--s4)]">
          <h3 className="k-label uppercase">النموذج</h3>
          <p className="mt-[var(--s2)] leading-relaxed text-(color:--ink-2)">
            لو النموذج المختار مزحوم أو تجاوز الحصة، كاشف ينزل تلقائياً للنموذج
            اللي بعده ويكمل — ما يوقفش التحليل.
          </p>

          <ul className="mt-[var(--s3)] space-y-[var(--s2)]">
            {models.map((m) => {
              const active = m.id === model;
              return (
                <li key={m.id}>
                  <label
                    className={`flex cursor-pointer items-start gap-[var(--s3)] border p-[var(--s3)] transition-colors duration-[var(--dur-mark)] ${
                      active
                        ? "border-[var(--amp-15-ink)] bg-[var(--board-sunk)]"
                        : "border-[var(--rib)] hover:bg-[var(--board-sunk)]"
                    }`}
                  >
                    <input
                      type="radio"
                      name="kashif-model"
                      value={m.id}
                      checked={active}
                      onChange={() => {
                        setDraftModel(m.id);
                        setSaved(false);
                      }}
                      className="mt-[3px] h-[16px] w-[16px] shrink-0 accent-[var(--amp-15-ink)]"
                    />
                    <span className="min-w-0 flex-1">
                      <span className="flex flex-wrap items-center gap-[var(--s2)]">
                        <span className="font-semibold text-(color:--ink)">
                          {m.displayName}
                        </span>
                        {m.isRecommended && (
                          <CodePlate>الافتراضي</CodePlate>
                        )}
                      </span>
                      <span className="k-label normal-case mt-[2px] block">
                        {m.description}
                      </span>
                    </span>
                  </label>
                </li>
              );
            })}
          </ul>
        </section>
      </div>
    </Sheet>
  );
}
