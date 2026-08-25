"use client";

import * as React from "react";
import { Button } from "@/components/ui/primitives";
import { ThemeToggle } from "@/components/ui/ThemeToggle";
import { ACCENT } from "@/lib/design/severity";

/**
 * The lid's masthead: the plate riveted to the top of the box.
 *
 * A fuse box lid names itself once, in stamped type, and then gets out of the
 * way — it is not a navigation bar and it does not follow you down the page.
 * The one thing it holds besides the name is the way back to a new scan, and
 * that only exists while there is something to go back from.
 */
export function Masthead({
  onNewScan,
  onOpenSettings,
  onOpenDictionary,
}: {
  onNewScan?: () => void;
  onOpenSettings: () => void;
  onOpenDictionary: () => void;
}) {
  return (
    <header className="border-b border-[var(--rib)] bg-[var(--board-sunk)]">
      <div className="mx-auto flex max-w-[1180px] items-center gap-[var(--s3)] px-[var(--s4)] py-[var(--s3)]">
        <Wordmark />

        <span className="flex-1" aria-hidden />

        <Button onClick={onOpenDictionary} className="text-(length:--t-plate)">
          القاموس
        </Button>
        <Button onClick={onOpenSettings} className="text-(length:--t-plate)">
          الإعدادات
        </Button>
        <ThemeToggle />
        {onNewScan && (
          <Button variant="primary" onClick={onNewScan} className="text-(length:--t-plate)">
            فحص جديد
          </Button>
        )}
      </div>
    </header>
  );
}

/**
 * The name, stamped.
 *
 * The mark is a seated 15A blade — the interactive amp rating, the one colour
 * in the system that is not a status — because the product is the thing that
 * reads the box, not one of the faults in it.
 */
function Wordmark() {
  return (
    <div className="flex items-center gap-[var(--s2)]">
      <span
        aria-hidden
        className="k-seat"
        style={{ backgroundColor: ACCENT.ink, minWidth: 26 }}
      >
        15A
      </span>
      <span className="flex flex-col leading-none">
        <span className="text-(length:--t-body) font-bold tracking-tight text-(color:--ink)">
          كاشف
        </span>
        <span data-num className="k-label uppercase">
          OBD Report
        </span>
      </span>
    </div>
  );
}
