"use client";

import * as React from "react";
import { cn } from "@/lib/cn";
import { Button } from "./primitives";

/**
 * A panel that slides out over the board.
 *
 * Settings and the dictionary are reference material, not steps in the report,
 * so they arrive over the lid rather than pushing it around. On a phone the
 * sheet takes the full width and rises from the bottom edge, which is where a
 * thumb already is; on a wide screen it sits against the inline-start edge,
 * because the page is RTL and that is the side the eye starts from.
 *
 * The modal behaviour is here rather than in each panel because there is
 * exactly one correct version of it and the incumbent modals had none of it:
 * they closed on Escape and nothing else. Focus fell straight through to the
 * page behind, tab cycled the whole document, and closing left focus on
 * `<body>` so the next Tab restarted from the top of the page.
 */
export function Sheet({
  title,
  onClose,
  children,
  footer,
}: {
  title: string;
  onClose: () => void;
  children: React.ReactNode;
  footer?: React.ReactNode;
}) {
  const panelRef = React.useRef<HTMLDivElement>(null);
  const headingId = React.useId();

  React.useEffect(() => {
    // Where focus came from, so it can be handed back on close. Without this
    // a keyboard user lands on <body> and starts again from the masthead.
    const opener = document.activeElement as HTMLElement | null;

    // Focus the panel's own first field if it names one, otherwise the panel
    // itself — so the first Tab starts inside the sheet, not on the page.
    const panel = panelRef.current;
    const target =
      panel?.querySelector<HTMLElement>("[data-autofocus]") ?? panel;
    target?.focus();

    const onKeyDown = (e: KeyboardEvent) => {
      if (e.key === "Escape") {
        e.stopPropagation();
        onClose();
        return;
      }
      if (e.key !== "Tab" || !panel) return;

      // Keep Tab inside the sheet. `disabled` and `display:none` elements are
      // still matched by the selector, so the list is filtered by whether the
      // element can actually take focus.
      const focusable = Array.from(
        panel.querySelectorAll<HTMLElement>(
          'a[href], button:not([disabled]), input:not([disabled]), select:not([disabled]), textarea:not([disabled]), [tabindex]:not([tabindex="-1"])'
        )
      ).filter((el) => el.offsetParent !== null || el === document.activeElement);

      if (focusable.length === 0) return;
      const first = focusable[0];
      const last = focusable[focusable.length - 1];

      if (e.shiftKey && document.activeElement === first) {
        e.preventDefault();
        last.focus();
      } else if (!e.shiftKey && document.activeElement === last) {
        e.preventDefault();
        first.focus();
      }
    };

    document.addEventListener("keydown", onKeyDown, true);
    const previousOverflow = document.body.style.overflow;
    document.body.style.overflow = "hidden";

    return () => {
      document.removeEventListener("keydown", onKeyDown, true);
      document.body.style.overflow = previousOverflow;
      opener?.focus?.();
    };
  }, [onClose]);

  return (
    <div
      className="fixed inset-0 z-50 flex bg-[var(--scrim)]"
      onMouseDown={(e) => {
        // Only a press that both starts and ends on the scrim closes it, so a
        // drag that began on text inside the sheet does not dismiss it.
        if (e.target === e.currentTarget) onClose();
      }}
    >
      <div
        ref={panelRef}
        role="dialog"
        aria-modal="true"
        aria-labelledby={headingId}
        tabIndex={-1}
        className={cn(
          "k-cell relative flex w-full flex-col outline-none",
          "mt-auto max-h-[88dvh]",
          "sm:mt-0 sm:me-auto sm:h-full sm:max-h-none sm:max-w-[440px]",
          "animate-[sheet-in_var(--dur-sheet)_var(--ease)]"
        )}
      >
        <div className="flex items-center gap-[var(--s3)] border-b border-[var(--rib)] p-[var(--s4)]">
          <h2
            id={headingId}
            className="k-bank uppercase flex-1 text-(color:--ink)"
          >
            {title}
          </h2>
          <Button onClick={onClose} aria-label="إغلاق" className="px-[var(--s3)]">
            ✕
          </Button>
        </div>

        <div className="flex-1 overflow-y-auto p-[var(--s4)]">{children}</div>

        {footer && (
          <div className="border-t border-[var(--rib)] p-[var(--s4)]">{footer}</div>
        )}
      </div>
    </div>
  );
}
