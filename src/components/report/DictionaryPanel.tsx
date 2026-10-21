"use client";

import * as React from "react";
import { Sheet } from "@/components/ui/Sheet";
import { LIBYAN_DICTIONARY, type DictionaryEntry } from "@/lib/dictionary";

const CUSTOM_DICT_KEY = "kashif_custom_dictionary";

export function DictionaryPanel({ onClose }: { onClose: () => void }) {
  const [query, setQuery] = React.useState("");
  const [showAddForm, setShowAddForm] = React.useState(false);
  const [customEntries, setCustomEntries] = React.useState<DictionaryEntry[]>([]);

  // Form state
  const [newLibyan, setNewLibyan] = React.useState("");
  const [newArabic, setNewArabic] = React.useState("");
  const [newEnglish, setNewEnglish] = React.useState("");
  const [newCategory, setNewCategory] = React.useState("عام وإداري");

  React.useEffect(() => {
    try {
      const raw = localStorage.getItem(CUSTOM_DICT_KEY);
      if (raw) {
        const parsed = JSON.parse(raw);
        if (Array.isArray(parsed)) setCustomEntries(parsed);
      }
    } catch (_) {}
  }, []);

  const handleSaveCustom = (e: React.FormEvent) => {
    e.preventDefault();
    if (!newLibyan.trim() || !newArabic.trim()) return;

    const entry: DictionaryEntry = {
      libyanTerm: newLibyan.trim(),
      standardArabic: newArabic.trim(),
      english: newEnglish.trim() || newArabic.trim(),
      category: newCategory,
    };

    const updated = [entry, ...customEntries.filter((x) => x.libyanTerm !== entry.libyanTerm)];
    setCustomEntries(updated);
    try {
      localStorage.setItem(CUSTOM_DICT_KEY, JSON.stringify(updated));
    } catch (_) {}

    setNewLibyan("");
    setNewArabic("");
    setNewEnglish("");
    setShowAddForm(false);
  };

  const handleDeleteCustom = (term: string) => {
    const updated = customEntries.filter((x) => x.libyanTerm !== term);
    setCustomEntries(updated);
    try {
      localStorage.setItem(CUSTOM_DICT_KEY, JSON.stringify(updated));
    } catch (_) {}
  };

  const allEntries = React.useMemo(() => {
    return [...customEntries, ...LIBYAN_DICTIONARY];
  }, [customEntries]);

  const term = query.trim().toLowerCase();
  const matches = term
    ? allEntries.filter(
        (e) =>
          e.libyanTerm.toLowerCase().includes(term) ||
          e.standardArabic.toLowerCase().includes(term) ||
          e.english.toLowerCase().includes(term)
      )
    : allEntries;

  const groups = new Map<string, DictionaryEntry[]>();
  for (const entry of matches) {
    const list = groups.get(entry.category);
    if (list) list.push(entry);
    else groups.set(entry.category, [entry]);
  }

  return (
    <Sheet title="قاموس ورش صيانة السيارات الليبية" onClose={onClose}>
      <div className="space-y-[var(--s4)]">
        {/* Search & Add Button Bar */}
        <div className="space-y-2">
          <div className="flex items-center gap-2">
            <input
              data-autofocus
              type="search"
              value={query}
              onChange={(e) => setQuery(e.target.value)}
              placeholder="ابحث بالليبي (كمبيو، باطنيات، مرميطة...) أو بالفصحى أو بالإنجليزي"
              aria-label="بحث في القاموس"
              className="min-h-[var(--tap)] flex-1 rounded border border-[var(--rib)] bg-[var(--cell)] px-3 text-sm text-(color:--ink) outline-none focus:border-[var(--royal-blue)]"
            />
            <button
              type="button"
              onClick={() => setShowAddForm((v) => !v)}
              className="min-h-[var(--tap)] rounded bg-[var(--royal-blue)]/15 border border-[var(--royal-blue-light)]/40 px-3 text-xs font-bold text-[var(--royal-blue-light)] transition hover:bg-[var(--royal-blue)]/25 shrink-0"
            >
              {showAddForm ? "إلغاء ✕" : "+ إضافة مصطلح"}
            </button>
          </div>

          <p className="k-label normal-case text-xs" role="status" aria-live="polite">
            {term
              ? `${matches.length} من إجمالي ${allEntries.length} مصطلح`
              : `${allEntries.length} مصطلح معتمد`}
            {customEntries.length > 0 && ` (${customEntries.length} مصطلحات مضافة محلياً)`}
          </p>
        </div>

        {/* Add Custom Term Form */}
        {showAddForm && (
          <form
            onSubmit={handleSaveCustom}
            className="rounded-xl border border-[var(--gold-primary)]/40 bg-[var(--board-sunk)] p-4 space-y-3"
          >
            <h4 className="font-bold text-xs text-(color:--ink) flex items-center gap-1.5">
              <span>✨</span>
              <span>إضافة مصطلح ورشة جديد (يحفظ في ذاكرة المتصفح):</span>
            </h4>
            <div className="grid grid-cols-1 sm:grid-cols-2 gap-2 text-xs">
              <div>
                <label className="text-[11px] font-semibold text-(color:--ink-2) block mb-1">
                  المصطلح الليبي المتداول:
                </label>
                <input
                  type="text"
                  required
                  value={newLibyan}
                  onChange={(e) => setNewLibyan(e.target.value)}
                  placeholder="مثال: دينمو الشحن / بوبينة"
                  className="w-full rounded border border-[var(--rib)] bg-[var(--cell)] px-2.5 py-1.5 text-xs text-(color:--ink) outline-none focus:border-[var(--royal-blue)]"
                />
              </div>

              <div>
                <label className="text-[11px] font-semibold text-(color:--ink-2) block mb-1">
                  المعنى باللغة العربية الفصحى:
                </label>
                <input
                  type="text"
                  required
                  value={newArabic}
                  onChange={(e) => setNewArabic(e.target.value)}
                  placeholder="مثال: مولد الكهرباء / ملف الإشعال"
                  className="w-full rounded border border-[var(--rib)] bg-[var(--cell)] px-2.5 py-1.5 text-xs text-(color:--ink) outline-none focus:border-[var(--royal-blue)]"
                />
              </div>

              <div>
                <label className="text-[11px] font-semibold text-(color:--ink-2) block mb-1">
                  الاسم التقني بالإنجليزي (اختياري):
                </label>
                <input
                  type="text"
                  value={newEnglish}
                  onChange={(e) => setNewEnglish(e.target.value)}
                  placeholder="e.g. Alternator / Ignition Coil"
                  className="w-full rounded border border-[var(--rib)] bg-[var(--cell)] px-2.5 py-1.5 text-xs text-(color:--ink) outline-none focus:border-[var(--royal-blue)]"
                  dir="ltr"
                />
              </div>

              <div>
                <label className="text-[11px] font-semibold text-(color:--ink-2) block mb-1">
                  التصنيف:
                </label>
                <select
                  value={newCategory}
                  onChange={(e) => setNewCategory(e.target.value)}
                  className="w-full rounded border border-[var(--rib)] bg-[var(--cell)] px-2.5 py-1.5 text-xs text-(color:--ink) outline-none focus:border-[var(--royal-blue)]"
                >
                  <option value="عام وإداري">عام وإداري</option>
                  <option value="المحرك وأجزاؤه">المحرك وأجزاؤه</option>
                  <option value="ناقل الحركة (الكمبيو)">ناقل الحركة (الكمبيو)</option>
                  <option value="نظام التعليق (الصالة)">نظام التعليق (الصالة)</option>
                  <option value="الفرامل والأمان">الفرامل والأمان</option>
                  <option value="الكهرباء والحساسات">الكهرباء والحساسات</option>
                  <option value="الهيكل والمقصورة">الهيكل والمقصورة</option>
                  <option value="التبريد والتكييف">التبريد والتكييف</option>
                </select>
              </div>
            </div>

            <div className="flex justify-end pt-1">
              <button
                type="submit"
                className="rounded bg-[var(--royal-blue)] px-4 py-1.5 text-xs font-bold text-white shadow-sm transition hover:bg-[var(--royal-blue-electric)]"
              >
                حفظ المصطلح في القاموس
              </button>
            </div>
          </form>
        )}

        {/* Results */}
        {matches.length === 0 ? (
          <p className="text-(color:--ink-3) italic py-6 text-center text-xs">
            ما لقيناش مصطلح مطابق. جرّب كلمة أقصر، أو يمكنك إضافته عبر زر (+ إضافة مصطلح).
          </p>
        ) : (
          <div className="space-y-[var(--s5)]">
            {Array.from(groups).map(([category, entries]) => (
              <section key={category}>
                <div className="rib-heavy flex items-center gap-[var(--s2)] pt-[var(--s2)]">
                  <h3 className="k-bank uppercase text-(color:--ink)">{category}</h3>
                  <span className="rib mt-[2px] h-px flex-1" aria-hidden />
                  <span data-num className="k-label text-xs">
                    {entries.length}
                  </span>
                </div>

                <dl className="mt-[var(--s2)] space-y-1">
                  {entries.map((entry) => {
                    const isCustom = customEntries.some((c) => c.libyanTerm === entry.libyanTerm);
                    return (
                      <div
                        key={`${category}-${entry.libyanTerm}`}
                        className="rib py-[var(--s2)] first:border-t-0 first:shadow-none flex items-start justify-between gap-3"
                      >
                        <div className="min-w-0 flex-1">
                          <div className="flex items-center gap-2">
                            <dt className="font-bold text-(color:--ink) text-xs">
                              {entry.libyanTerm}
                            </dt>
                            {isCustom && (
                              <span className="rounded bg-[var(--gold-primary)]/15 px-1.5 py-0.2 font-bold text-[9px] text-[var(--gold-primary)]">
                                مخصص
                              </span>
                            )}
                          </div>
                          <dd className="text-xs text-(color:--ink-2) mt-0.5">
                            {entry.standardArabic}
                          </dd>
                          <dd dir="ltr" data-num className="k-label text-start normal-case text-[11px] text-(color:--ink-3)">
                            {entry.english}
                          </dd>
                        </div>

                        {isCustom && (
                          <button
                            type="button"
                            onClick={() => handleDeleteCustom(entry.libyanTerm)}
                            className="text-red-400 hover:text-red-500 text-xs p-1"
                            title="حذف هذا المصطلح المخصص"
                          >
                            ✕
                          </button>
                        )}
                      </div>
                    );
                  })}
                </dl>
              </section>
            ))}
          </div>
        )}
      </div>
    </Sheet>
  );
}
