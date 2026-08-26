"use client";

import * as React from "react";
import { Button } from "@/components/ui/primitives";
import { ThemeToggle } from "@/components/ui/ThemeToggle";

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
      <svg
        viewBox="0 0 32 32"
        width={26}
        height={26}
        role="img"
        aria-hidden="true"
        className="shrink-0"
      >
        {/* Terminal Blades */}
        <path d="M7 19 H13 V29 L11.5 31 H10 L8.5 29 H7 V19 Z" fill="var(--rib)" />
        <rect x="9" y="24" width="2" height="2" fill="var(--board-sunk)" />

        <path d="M19 19 H25 V29 L23.5 31 H22 L20.5 29 H19 V19 Z" fill="var(--rib)" />
        <rect x="21" y="24" width="2" height="2" fill="var(--board-sunk)" />

        {/* Moulded Body in 15A Blue */}
        <path d="M3 3 H29 V11 L28 12 V20 H4 V12 L3 11 Z" fill="var(--amp-15-tab)" />
        <rect x="3" y="3" width="26" height="1.5" fill="var(--amp-15-ink)" />
        <rect x="4" y="18.5" width="24" height="1.5" fill="var(--amp-15-ink)" />

        {/* Test Probe Apertures */}
        <rect x="8" y="3" width="4" height="1.5" fill="var(--rib)" />
        <rect x="20" y="3" width="4" height="1.5" fill="var(--rib)" />

        {/* Central Cavity & Stamped Element */}
        <rect x="6" y="6" width="20" height="10" fill="var(--amp-15-ink)" />
        <rect x="6" y="12" width="4" height="4" fill="var(--rib)" />
        <rect x="22" y="12" width="4" height="4" fill="var(--rib)" />
        <path
          d="M8 14 H10 V9 H15 L17 15 H22 V14"
          fill="none"
          stroke="var(--cell)"
          strokeWidth="1.8"
          strokeLinecap="square"
          strokeLinejoin="miter"
        />
      </svg>
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
