import Link from "next/link";
import { Cell } from "@/components/ui/primitives";

/**
 * A URL that is not a screen.
 *
 * Kashif has one page, so this is almost always a stale link or a typo. It
 * says so and points back, rather than pretending to be a search.
 */
export default function NotFound() {
  return (
    <main className="flex min-h-dvh items-center justify-center bg-[var(--board)] p-[var(--s4)]">
      <Cell as="section" className="max-w-[var(--measure)] p-[var(--s5)]">
        <div data-num className="k-label uppercase">
          404
        </div>
        <h1 className="mt-[var(--s1)] text-[var(--t-title)] font-bold text-(color:--ink)">
          الصفحة مش موجودة
        </h1>
        <p className="mt-[var(--s3)] leading-relaxed text-(color:--ink-2)">
          كاشف صفحة وحدة: ترفع فيها تقرير جهاز الفحص وتقرا النتيجة.
        </p>
        <Link
          href="/"
          className="mt-[var(--s5)] inline-flex min-h-[var(--tap)] items-center border border-transparent bg-[var(--amp-15-ink)] px-[var(--s4)] font-semibold text-(color:--cell)"
        >
          ارجع للبداية
        </Link>
      </Cell>
    </main>
  );
}
