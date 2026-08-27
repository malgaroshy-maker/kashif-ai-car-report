"use client";

import * as React from "react";
import { Sun, Moon } from "lucide-react";
import { cn } from "@/lib/cn";

type Theme = "light" | "dark";

const STORAGE_KEY = "kashif_theme";
const EVENT = "kashif:themechange";

/**
 * The lid comes in both: pale grey plastic with black print, or charcoal with
 * white silkscreen. Light leads because the scene is a phone held at arm's
 * length in Libyan daylight — dark is the night bay, not the default.
 *
 * The inline script in the root layout has already stamped `data-theme` before
 * first paint, so the DOM is the source of truth here and the component only
 * reads it. That keeps this a subscription rather than an effect that writes
 * state on mount.
 */

function subscribe(onChange: () => void) {
  const media = window.matchMedia("(prefers-color-scheme: dark)");
  media.addEventListener("change", onChange);
  window.addEventListener(EVENT, onChange);
  window.addEventListener("storage", onChange);
  return () => {
    media.removeEventListener("change", onChange);
    window.removeEventListener(EVENT, onChange);
    window.removeEventListener("storage", onChange);
  };
}

function getSnapshot(): Theme {
  const stamped = document.documentElement.getAttribute("data-theme");
  if (stamped === "light" || stamped === "dark") return stamped;
  return window.matchMedia("(prefers-color-scheme: dark)").matches
    ? "dark"
    : "light";
}

/** The server cannot know the viewer's lid; render the light one and let the
 *  subscription correct it on the client. */
const getServerSnapshot = (): Theme => "light";

export function ThemeToggle({ className }: { className?: string }) {
  const theme = React.useSyncExternalStore(
    subscribe,
    getSnapshot,
    getServerSnapshot
  );

  const toggle = () => {
    const next: Theme = theme === "dark" ? "light" : "dark";
    document.documentElement.setAttribute("data-theme", next);
    try {
      window.localStorage.setItem(STORAGE_KEY, next);
    } catch {
      // Private browsing: the choice holds for this page view only.
    }
    window.dispatchEvent(new Event(EVENT));
  };

  const isDark = theme === "dark";

  return (
    <button
      type="button"
      onClick={toggle}
      aria-label={
        isDark ? "التبديل إلى الوضع النهاري" : "التبديل إلى الوضع الليلي"
      }
      className={cn(
        // `shrink-0`, because the header is a flex row: on a 412px phone this
        // button was being squeezed to 33px wide against a 44px tap target it
        // declares itself. The size is the whole point of the token.
        "inline-flex size-[var(--tap)] shrink-0 items-center justify-center",
        "border border-[var(--rib)] bg-[var(--cell)] text-(color:--ink-2)",
        "transition-colors duration-[var(--dur-mark)] ease-[var(--ease)]",
        "hover:bg-[var(--board-sunk)] hover:text-(color:--ink)",
        className
      )}
    >
      {isDark ? (
        <Sun className="size-4" aria-hidden />
      ) : (
        <Moon className="size-4" aria-hidden />
      )}
    </button>
  );
}
