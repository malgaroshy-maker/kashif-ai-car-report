"use client";

import * as React from "react";
import { Sheet } from "@/components/ui/Sheet";
import { LIBYAN_DICTIONARY, type DictionaryEntry } from "@/lib/dictionary";

/**
 * The workshop glossary: what a part is called here, versus everywhere else.
 *
 * This is the product's actual thesis in one panel. A scanner prints
 * "Oxygen Sensor"; the man who will replace it calls it a حساس مرميطة, and the
 * shop on the ring road will not find it under anything else. The report
 * already speaks the workshop's Arabic — this is where an owner, or a
 * mechanic who learned the trade elsewhere, can check the mapping.
 *
 * Grouped by system rather than alphabetically, because that is how somebody
 * arrives at it: they are looking at the brakes, not at the letter ب.
 */
export function DictionaryPanel({ onClose }: { onClose: () => void }) {
  const [query, setQuery] = React.useState("");

  const term = query.trim().toLowerCase();
  const matches = term
    ? LIBYAN_DICTIONARY.filter(
        (e) =>
          e.libyanTerm.toLowerCase().includes(term) ||
          e.standardArabic.toLowerCase().includes(term) ||
          e.english.toLowerCase().includes(term)
      )
    : LIBYAN_DICTIONARY;

  // Insertion order is the order the source file groups them in, which is by
  // system. Preserving it keeps the panel readable when nothing is typed.
  const groups = new Map<string, DictionaryEntry[]>();
  for (const entry of matches) {
    const list = groups.get(entry.category);
    if (list) list.push(entry);
    else groups.set(entry.category, [entry]);
  }

  return (
    <Sheet title="قاموس الورشة" onClose={onClose}>
      <div className="space-y-[var(--s4)]">
        <div>
          <input
            data-autofocus
            type="search"
            value={query}
            onChange={(e) => setQuery(e.target.value)}
            placeholder="دوّر بالليبي أو بالفصحى أو بالإنجليزي"
            aria-label="بحث في القاموس"
            className="min-h-[var(--tap)] w-full border border-[var(--rib)] bg-[var(--cell)] px-[var(--s3)] text-(color:--ink) outline-none focus-visible:border-[var(--amp-15-ink)]"
          />
          <p className="k-label normal-case mt-[var(--s2)]" role="status" aria-live="polite">
            {term
              ? `${matches.length} من ${LIBYAN_DICTIONARY.length}`
              : `${LIBYAN_DICTIONARY.length} مصطلح`}
          </p>
        </div>

        {matches.length === 0 ? (
          <p className="text-(color:--ink-3) italic">
            ما لقيناش مصطلح مطابق. جرّب كلمة أقصر، أو الاسم بالإنجليزي.
          </p>
        ) : (
          <div className="space-y-[var(--s5)]">
            {Array.from(groups).map(([category, entries]) => (
              <section key={category}>
                <div className="rib-heavy flex items-center gap-[var(--s2)] pt-[var(--s2)]">
                  <h3 className="k-bank uppercase text-(color:--ink)">{category}</h3>
                  <span className="rib mt-[2px] h-px flex-1" aria-hidden />
                  <span data-num className="k-label">
                    {entries.length}
                  </span>
                </div>

                <dl className="mt-[var(--s2)]">
                  {entries.map((entry) => (
                    <div
                      key={`${category}-${entry.libyanTerm}`}
                      className="rib py-[var(--s2)] first:border-t-0 first:shadow-none"
                    >
                      <dt className="font-semibold text-(color:--ink)">
                        {entry.libyanTerm}
                      </dt>
                      <dd className="text-(color:--ink-2)">
                        {entry.standardArabic}
                      </dd>
                      <dd dir="ltr" data-num className="k-label text-start normal-case">
                        {entry.english}
                      </dd>
                    </div>
                  ))}
                </dl>
              </section>
            ))}
          </div>
        )}
      </div>
    </Sheet>
  );
}
