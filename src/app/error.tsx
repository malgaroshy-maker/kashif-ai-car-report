"use client";

import * as React from "react";
import Link from "next/link";
import { Button, Cell } from "@/components/ui/primitives";

/**
 * The board when the app itself breaks.
 *
 * There was no error boundary at all: a render error anywhere below `page.tsx`
 * blanked the page, and the report the reader had just paid a Gemini call for
 * went with it. This at least says what happened and offers the one action
 * that helps.
 *
 * It deliberately does not print `error.message`. A React error can quote back
 * whatever was being rendered, and what is being rendered here is a scan of
 * somebody's car.
 */
export default function Error({
  error,
  reset,
}: {
  error: Error & { digest?: string };
  reset: () => void;
}) {
  React.useEffect(() => {
    console.error("[kashif] unhandled", error);
  }, [error]);

  return (
    <main className="flex min-h-dvh items-center justify-center bg-[var(--board)] p-[var(--s4)]">
      <Cell as="section" className="max-w-[var(--measure)] p-[var(--s5)]">
        <div className="k-label uppercase">خطأ في التطبيق</div>
        <h1 className="mt-[var(--s1)] text-[var(--t-title)] font-bold text-(color:--ink)">
          صار خلل ووقف العرض
        </h1>
        <p className="mt-[var(--s3)] leading-relaxed text-(color:--ink-2)">
          الخلل في كاشف نفسه، مش في سيارتك ولا في تقرير الفحص. جرّب مرة
          ثانية — ولو تكرر، حدّث الصفحة وارفع التقرير من جديد.
        </p>

        {error.digest && (
          <p className="k-label normal-case mt-[var(--s3)]">
            رقم الخطأ للمتابعة:{" "}
            <span data-num>{error.digest}</span>
          </p>
        )}

        <div className="mt-[var(--s5)] flex flex-wrap gap-[var(--s2)]">
          <Button variant="primary" onClick={reset}>
            جرّب مرة ثانية
          </Button>
          {/* Navigating home remounts the tree that threw, which is the other
              way out when reset() lands on the same error again. */}
          <Link
            href="/"
            prefetch={false}
            className="inline-flex min-h-[var(--tap)] items-center border border-[var(--rib)] bg-[var(--cell)] px-[var(--s4)] font-semibold text-(color:--ink)"
          >
            ارجع للبداية
          </Link>
        </div>
      </Cell>
    </main>
  );
}
