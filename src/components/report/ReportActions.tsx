"use client";

import * as React from "react";
import { Button, Cell } from "@/components/ui/primitives";
import {
  downloadReportHtml,
  printReport,
  shareReportToWhatsApp,
} from "@/lib/export-report";
import type { KashifDiagnosticReport } from "@/lib/types";

/**
 * Getting the report off this screen and into the world.
 *
 * A workshop report is not read once on a phone and forgotten. It is printed
 * and put in the folder with the car, forwarded to the owner who is deciding
 * whether to buy, and carried to the parts shop. So the three ways out are
 * peers on one rule, not a primary button with two afterthoughts — which one
 * matters depends entirely on who is standing there.
 *
 * The bar carries `no-print`: it is furniture, and the printed sheet is the
 * report itself.
 */
export function ReportActions({ report }: { report: KashifDiagnosticReport }) {
  // The download now fetches and embeds the part photos before it writes the
  // file, so it takes a moment and has to be able to fail. Without a pending
  // state the button looks broken and gets pressed four more times, which is
  // four more rounds of fetching the same photographs.
  const [state, setState] = React.useState<"idle" | "working" | "failed">("idle");

  const download = async () => {
    if (state === "working") return;
    setState("working");
    try {
      await downloadReportHtml(report);
      setState("idle");
    } catch {
      setState("failed");
    }
  };

  return (
    <Cell
      as="section"
      className="no-print flex flex-col gap-[var(--s3)] p-[var(--s3)] sm:flex-row sm:items-center"
      aria-label="تصدير التقرير"
    >
      <p className="k-label normal-case flex-1">
        {state === "failed"
          ? "ما نجحش التنزيل — عاود مرة ثانية."
          : "الملف المنزّل يخدم بدون نت — افتحه على أي جهاز في الورشة."}
      </p>

      <div className="flex flex-wrap gap-[var(--s2)]">
        <Button onClick={download} disabled={state === "working"}>
          {state === "working" ? "جاري التحضير…" : "تنزيل الملف"}
        </Button>
        <Button onClick={printReport}>طباعة / PDF</Button>
        <Button onClick={() => shareReportToWhatsApp(report)}>واتساب</Button>
      </div>
    </Cell>
  );
}
