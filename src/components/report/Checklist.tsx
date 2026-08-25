"use client";

import * as React from "react";
import { Cell } from "@/components/ui/primitives";
import { ACCENT } from "@/lib/design/severity";
import type { DiagnosticStep } from "@/lib/types";

/**
 * The order of tests to run before buying anything.
 *
 * This is the part of the report that keeps money in the owner's pocket: it
 * exists so a fault is measured before a part is replaced. It reads as a
 * numbered sequence, not a set of independent tickboxes, because the order is
 * the advice — checking the fuse after replacing the sensor tells you nothing.
 *
 * The tick is state the mechanic holds while working, so it is deliberately
 * not persisted: a checklist that remembers yesterday's ticks on today's car
 * is worse than one that remembers nothing.
 */
export function Checklist({ steps }: { steps: DiagnosticStep[] }) {
  const [done, setDone] = React.useState<Record<number, boolean>>({});

  if (steps.length === 0) return null;

  const doneCount = steps.filter((s) => done[s.stepNumber]).length;

  return (
    <section className="space-y-[var(--s3)]" aria-labelledby="checklist-heading">
      <div className="rib-heavy flex items-center gap-[var(--s2)] pt-[var(--s2)]">
        <h2 id="checklist-heading" className="k-bank uppercase text-(color:--ink)">
          ترتيب الفحص قبل الشراء
        </h2>
        <span className="rib mt-[2px] h-px flex-1" aria-hidden />
        <span data-num className="k-label" aria-live="polite">
          {doneCount} / {steps.length}
        </span>
      </div>

      <Cell as="ol" className="p-0">
        {steps.map((step, i) => {
          const checked = Boolean(done[step.stepNumber]);
          return (
            <li key={`${step.stepNumber}-${i}`} className={i > 0 ? "rib" : undefined}>
              <label
                className="flex cursor-pointer items-start gap-[var(--s3)] p-[var(--s3)]"
                style={checked ? { color: "var(--ink-3)" } : undefined}
              >
                <input
                  type="checkbox"
                  checked={checked}
                  onChange={() =>
                    setDone((prev) => ({
                      ...prev,
                      [step.stepNumber]: !prev[step.stepNumber],
                    }))
                  }
                  className="mt-[3px] h-[18px] w-[18px] shrink-0 accent-[var(--amp-15-ink)]"
                />

                <span
                  data-num
                  className="mt-[1px] w-[var(--s5)] shrink-0 text-end font-semibold"
                  style={{ color: checked ? "var(--ink-3)" : ACCENT.ink }}
                  aria-hidden
                >
                  {step.stepNumber}
                </span>

                <span className="min-w-0 flex-1">
                  <span
                    className={
                      checked
                        ? "block font-semibold line-through"
                        : "block font-semibold text-(color:--ink)"
                    }
                  >
                    {step.targetComponent}
                  </span>
                  {step.actionRequiredLibyan && (
                    <span className="mt-[2px] block leading-relaxed">
                      {step.actionRequiredLibyan}
                    </span>
                  )}
                  {step.toolNeeded && (
                    <span className="k-label mt-[var(--s1)] block uppercase">
                      العدة: {step.toolNeeded}
                    </span>
                  )}
                </span>
              </label>
            </li>
          );
        })}
      </Cell>
    </section>
  );
}
