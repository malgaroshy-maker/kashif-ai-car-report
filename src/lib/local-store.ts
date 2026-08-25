"use client";

import { useSyncExternalStore } from "react";

/**
 * Reading localStorage during render, safely.
 *
 * Three components hydrated themselves the same wrong way: render with an
 * empty value, then `useEffect` -> `setState` with what was in storage. That
 * costs a second render pass on every mount, and React's compiler rules flag
 * it, but the real problem was that nothing propagated. Saving a new API key
 * in Settings did not tell the upload panel, and saving a report did not tell
 * the history list — each held its own copy taken at mount.
 *
 * `useSyncExternalStore` is the built-in answer: one snapshot read during
 * render, one server snapshot for the prerender, and a subscription so every
 * reader updates together. `writeLocal` notifies; the `storage` event covers
 * the same app open in another tab.
 */

type Listener = () => void;

const listeners = new Set<Listener>();

/** Cached parsed snapshots. getSnapshot must be referentially stable. */
const cache = new Map<string, { raw: string | null; value: unknown }>();

function subscribe(listener: Listener): () => void {
  listeners.add(listener);
  window.addEventListener("storage", listener);
  return () => {
    listeners.delete(listener);
    window.removeEventListener("storage", listener);
  };
}

function notify() {
  for (const listener of listeners) listener();
}

function read<T>(key: string, parse: (raw: string) => T, fallback: T): T {
  let raw: string | null = null;
  try {
    raw = localStorage.getItem(key);
  } catch {
    // Storage disabled (private mode, or a locked-down browser). The app is
    // usable without it; the user re-enters their key each session.
    return fallback;
  }

  // Returning a fresh object every call makes useSyncExternalStore loop, so a
  // snapshot is reused until the underlying string actually changes.
  const cached = cache.get(key);
  if (cached && cached.raw === raw) return cached.value as T;

  let value = fallback;
  if (raw !== null) {
    try {
      value = parse(raw);
    } catch {
      value = fallback;
    }
  }
  cache.set(key, { raw, value });
  return value;
}

/** Reads a stored string. Every reader of this key re-renders when it changes. */
export function useLocalString(key: string, fallback = ""): string {
  return useSyncExternalStore(
    subscribe,
    () => read(key, (raw) => raw, fallback),
    () => fallback
  );
}

/**
 * Reads stored JSON, validated.
 *
 * `validate` is not optional: what comes back is whatever was in storage the
 * last time any version of this app wrote it, and a report from an older
 * schema must be dropped rather than rendered with holes.
 */
export function useLocalJson<T>(
  key: string,
  validate: (value: unknown) => T | null,
  fallback: T
): T {
  return useSyncExternalStore(
    subscribe,
    () => read(key, (raw) => validate(JSON.parse(raw)) ?? fallback, fallback),
    () => fallback
  );
}

/** Writes a value and tells every reader. Returns false if storage refused. */
export function writeLocal(key: string, value: string): boolean {
  try {
    localStorage.setItem(key, value);
    cache.delete(key);
    notify();
    return true;
  } catch (err) {
    console.warn(`[local-store] could not write ${key}:`, err);
    return false;
  }
}

/** Removes a value and tells every reader. */
export function removeLocal(key: string): void {
  try {
    localStorage.removeItem(key);
  } catch (err) {
    console.warn(`[local-store] could not remove ${key}:`, err);
  }
  cache.delete(key);
  notify();
}
