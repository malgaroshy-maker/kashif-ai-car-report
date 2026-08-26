"use client";

import * as React from "react";
import { Button, Cell, CodePlate, SeverityLegend } from "@/components/ui/primitives";
import {
  analyzeCodes,
  analyzeFile,
  loadSampleReport,
  messageOf,
  readSettings,
} from "@/lib/api-client";
import { SEVERITY } from "@/lib/design/severity";
import type { KashifDiagnosticReport } from "@/lib/types";

/**
 * The empty board, before a scan is loaded.
 *
 * The screen this replaces opened with a marketing hero — a pill badge, a
 * two-line headline, a paragraph of prose, then three feature cards — and put
 * the drop zone below all of it. A mechanic arriving with a PDF had to scroll
 * past an advertisement for the thing he was already using.
 *
 * The board opens empty, with its slots visible and one instruction. The three
 * ways in are three slots, not three tabs with a hidden panel behind each.
 */
export function Intake({
  onReport,
  busy,
  setBusy,
}: {
  onReport: (report: KashifDiagnosticReport) => void;
  busy: boolean;
  setBusy: (v: boolean) => void;
}) {
  const [error, setError] = React.useState("");
  const [status, setStatus] = React.useState("");
  const [codes, setCodes] = React.useState("");
  const [vin, setVin] = React.useState("");
  const [makeModel, setMakeModel] = React.useState("");
  const fileRef = React.useRef<HTMLInputElement>(null);
  const [dragging, setDragging] = React.useState(false);

  const settings = readSettings();
  const isAgy = settings.provider === "agy";
  const hasKey = isAgy || Boolean(settings.apiKey);

  /** Every entry point funnels through here so the states cannot diverge. */
  const run = async (
    label: string,
    work: () => Promise<KashifDiagnosticReport>,
    fallbackError: string
  ) => {
    setBusy(true);
    setError("");
    setStatus(label);
    try {
      onReport(await work());
    } catch (err) {
      setError(messageOf(err, fallbackError));
    } finally {
      setBusy(false);
      setStatus("");
    }
  };

  const upload = (file: File) =>
    run(
      "جاري استخراج الأكواد ومطابقتها بالقاموس…",
      () => analyzeFile(file),
      "تعذر قراءة الملف المرفوع"
    );

  return (
    <div className="space-y-[var(--s5)]">
      {/* One sentence, in the position a lid uses for its printed instruction. */}
      <div className="rib-heavy pt-[var(--s2)]">
        <h1 className="k-bank uppercase text-(color:--ink)">
          ارفع تقرير جهاز الفحص
        </h1>
        <p className="mt-[var(--s1)] text-(color:--ink-2)">
          ملف PDF أو صورة شاشة من Launch X431 أو Autel أو Ediag أو ThinkDiag —
          يطلعلك تقرير بمصطلحات الورش الليبية، بأرقام قطع الغيار والفحص
          المطلوب قبل ما تشري.
        </p>
      </div>

      {busy ? (
        <Analysing status={status} />
      ) : (
        <>
          {error && <Fault message={error} />}
          {!hasKey && <NoKeyNotice />}

          {/* SLOT 1 — the file */}
          <Cell
            as="section"
            className={dragging ? "p-[var(--s6)] bg-[var(--board-sunk)]" : "p-[var(--s6)]"}
            onDragOver={(e: React.DragEvent) => {
              e.preventDefault();
              setDragging(true);
            }}
            onDragLeave={() => setDragging(false)}
            onDrop={(e: React.DragEvent) => {
              e.preventDefault();
              setDragging(false);
              const file = e.dataTransfer.files?.[0];
              if (file) upload(file);
            }}
          >
            <div className="flex flex-col items-center gap-[var(--s3)] text-center">
              <span className="k-label uppercase">اسحب الملف هنا</span>
              <Button variant="primary" onClick={() => fileRef.current?.click()}>
                اختر ملف التقرير
              </Button>
              <span className="k-label normal-case">
                PDF أو صورة — حتى 8 ميجابايت
              </span>
              <input
                ref={fileRef}
                type="file"
                accept="application/pdf,image/jpeg,image/png,image/webp"
                className="sr-only"
                onChange={(e) => {
                  const file = e.target.files?.[0];
                  if (file) upload(file);
                  e.target.value = "";
                }}
              />
            </div>
          </Cell>

          {/* SLOT 2 — codes by hand */}
          <Cell as="section" className="p-[var(--s4)]">
            <h2 className="k-label uppercase">أو اكتب الأكواد يدوياً</h2>
            <form
              className="mt-[var(--s3)] space-y-[var(--s3)]"
              onSubmit={(e) => {
                e.preventDefault();
                if (!codes.trim()) {
                  setError("اكتب كود عطل واحد على الأقل — زي P0102.");
                  return;
                }
                run(
                  "جاري فحص الأكواد واستخراج أرقام القطع…",
                  () => analyzeCodes({ manualCodes: codes, vin, makeModel }),
                  "تعذر قراءة الأكواد المدخلة"
                );
              }}
            >
              <TextInput
                id="codes"
                label="أكواد الأعطال"
                value={codes}
                onChange={setCodes}
                placeholder="P0102, P0301, C1201"
                mono
              />
              <div className="grid gap-[var(--s3)] sm:grid-cols-2">
                <TextInput
                  id="vin"
                  label="رقم الهيكل (اختياري)"
                  value={vin}
                  onChange={setVin}
                  mono
                />
                <TextInput
                  id="makemodel"
                  label="نوع وموديل السيارة (اختياري)"
                  value={makeModel}
                  onChange={setMakeModel}
                />
              </div>
              <Button type="submit" variant="primary">
                حلّل الأكواد
              </Button>
            </form>
          </Cell>

          {/* SLOT 3 — the two demo boards, which need no key */}
          <Cell as="section" className="p-[var(--s4)]">
            <h2 className="k-label uppercase">
              أو افتح تقرير جاهز — ما يحتاجش مفتاح
            </h2>
            <div className="mt-[var(--s3)] flex flex-wrap gap-[var(--s2)]">
              <Button
                onClick={() =>
                  run(
                    "جاري تحميل تقرير BMW 528i…",
                    () => loadSampleReport("bmw-528i"),
                    "تعذر تحميل التقرير الجاهز"
                  )
                }
              >
                BMW 528i (E39)
              </Button>
              <Button
                onClick={() =>
                  run(
                    "جاري تحميل تقرير Toyota Corolla…",
                    () => loadSampleReport("toyota-corolla"),
                    "تعذر تحميل التقرير الجاهز"
                  )
                }
              >
                Toyota Corolla
              </Button>
            </div>
          </Cell>

          {/* The key is printed before it is needed, the way a lid prints its
              legend rather than explaining it after a failure. */}
          <SeverityLegend />
        </>
      )}
    </div>
  );
}

function TextInput({
  id,
  label,
  value,
  onChange,
  placeholder,
  mono,
}: {
  id: string;
  label: string;
  value: string;
  onChange: (v: string) => void;
  placeholder?: string;
  mono?: boolean;
}) {
  return (
    <div>
      <label htmlFor={id} className="k-label uppercase">
        {label}
      </label>
      <input
        id={id}
        value={value}
        placeholder={placeholder}
        onChange={(e) => onChange(e.target.value)}
        {...(mono ? { "data-num": true } : {})}
        className="mt-[var(--s1)] block min-h-[var(--tap)] w-full border border-[var(--rib)] bg-[var(--cell)] px-[var(--s2)] text-(color:--ink) placeholder:text-(color:--ink-3) focus-visible:outline-2 focus-visible:outline-offset-2 focus-visible:outline-[var(--amp-15-ink)]"
      />
    </div>
  );
}

/**
 * The analysing state.
 *
 * No spinner and no progress bar: neither knows how long a model call takes,
 * and a bar that lies is worse than no bar. The board says which step it is
 * on, and the fuse blinks — an object doing something, in the world the rest
 * of the page lives in.
 */
function Analysing({ status }: { status: string }) {
  return (
    <Cell className="p-[var(--s7)]" aria-busy="true" aria-live="polite">
      <div className="flex flex-col items-center gap-[var(--s3)] text-center">
        <span
          className="k-seat k-pulse"
          style={{ backgroundColor: "var(--amp-15-ink)", minWidth: 34 }}
          aria-hidden
        >
          15A
        </span>
        <p className="text-(color:--ink)">{status || "جاري التحليل…"}</p>
        <p className="k-label normal-case">
          التحليل ياخذ عادةً من 15 إلى 40 ثانية حسب حجم التقرير.
        </p>
      </div>
    </Cell>
  );
}

/** A blown fuse: the error state, in the system's own vocabulary. */
function Fault({ message }: { message: string }) {
  return (
    <Cell role="alert" className="p-[var(--s4)]">
      <div className="flex items-start gap-[var(--s3)]">
        <span
          className="k-seat"
          style={{ backgroundColor: SEVERITY.critical.ink }}
          aria-hidden
        >
          10A
        </span>
        <div>
          <div className="k-label uppercase" style={{ color: SEVERITY.critical.ink }}>
            الفحص ما تمّش
          </div>
          <p className="mt-[2px] text-(color:--ink)">{message}</p>
        </div>
      </div>
    </Cell>
  );
}

/**
 * Bring-your-own-key, said once, before the user hits a wall with it.
 *
 * The demo boards work without a key, so this is an explanation rather than a
 * blocker, and it does not stand between anyone and the two sample reports.
 */
function NoKeyNotice() {
  return (
    <Cell className="p-[var(--s4)]">
      <div className="k-label uppercase">المفتاح أو المحرك</div>
      <p className="mt-[var(--s1)] leading-relaxed text-(color:--ink)">
        كاشف يخدم بمفتاح Google AI Studio امتاعك أو محرك Antigravity CLI (agy) المحلي — يتخزّن في متصفحك وما
        يمشيش لأي سيرفر غير Google. حطه من <CodePlate>الإعدادات</CodePlate> فوق،
        والتقارير الجاهزة لوطا تخدم من غير مفتاح.
      </p>
    </Cell>
  );
}
