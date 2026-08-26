import { Cell } from "@/components/ui/primitives";

/**
 * The board before it has anything on it.
 *
 * Empty cells at the pitch the real ones use, so the layout does not jump when
 * the content arrives — the shape is the loading indicator. No spinner: a
 * spinner says "working" and tells you nothing about what is coming.
 */
export default function Loading() {
  return (
    <main
      className="mx-auto w-full max-w-[1180px] px-[var(--s4)] py-[var(--s5)]"
      aria-busy="true"
      aria-live="polite"
    >
      <span className="sr-only">جاري التحميل…</span>
      <div className="space-y-[var(--s5)]">
        <Cell className="h-[168px]" aria-hidden />
        <Cell className="h-[64px]" aria-hidden />
        <Cell className="h-[240px]" aria-hidden />
      </div>
    </main>
  );
}
