"use client";

import * as React from "react";
import { Cell, Field } from "@/components/ui/primitives";
import { SeverityMark } from "@/components/ui/SeverityMark";
import { SEVERITY, severityFromScore, type Severity } from "@/lib/design/severity";
import { orUnknown, type KashifDiagnosticReport } from "@/lib/types";

/**
 * The plate riveted to the lid: which car this board describes.
 *
 * The component it replaces filled every gap it had with something plausible.
 * A missing year printed 2020. A missing drivetrain printed "بنزين •
 * أوتوماتيك". A missing odometer printed "184,200 كم". And regardless of what
 * was scanned, every single report carried a telemetry chip reading
 * "جهد البطارية: 14.2V (جهد شحن سليم)" — a hardcoded string, presented as a
 * measurement of the car in front of you.
 *
 * Nothing here is invented. `Field` prints غير محدد for anything the scan did
 * not say, which is a true statement about the scan.
 */
export function VehiclePlate({ report }: { report: KashifDiagnosticReport }) {
  const { vehicle, summary, scannerInfo } = report;
  const severity = severityFromScore(summary.overallHealthScore);

  const name = [vehicle.make, vehicle.model].filter(Boolean).join(" ");

  // The drivetrain line is built from what is actually known, and disappears
  // entirely rather than being padded out with defaults.
  const spec = [
    vehicle.engineSpecs?.displacement,
    vehicle.engineSpecs?.fuelType,
    vehicle.engineSpecs?.transmission,
  ].filter(Boolean);

  return (
    <Cell as="section" className="p-[var(--s5)]" aria-labelledby="vehicle-plate">
      <div className="flex flex-col gap-[var(--s4)] md:flex-row md:items-start md:justify-between">
        <div className="min-w-0">
          <div className="k-label uppercase">بيانات السيارة</div>
          <h1
            id="vehicle-plate"
            className="mt-[2px] text-(length:--t-title) font-bold leading-tight text-(color:--ink)"
          >
            {name || "سيارة غير محددة"}
            {vehicle.year && (
              <span data-num className="ms-[var(--s2)] text-(length:--t-body) font-semibold text-(color:--ink-2)">
                {vehicle.year}
              </span>
            )}
          </h1>
          {spec.length > 0 && (
            <p className="mt-[var(--s1)] text-(color:--ink-2)">{spec.join(" · ")}</p>
          )}
        </div>

        <ReadinessScore
          score={summary.overallHealthScore}
          estimated={Boolean(summary.isScoreEstimated)}
          status={summary.severityStatus}
          severity={severity}
        />
      </div>

      <dl className="mt-[var(--s5)] grid grid-cols-2 gap-x-[var(--s5)] gap-y-[var(--s1)] lg:grid-cols-4">
        <PlateField label="رقم الهيكل (VIN)" value={vehicle.vin} mono />
        <PlateField label="الممشى" value={vehicle.mileage} mono />
        <PlateField label="جهاز الفحص" value={scannerInfo.toolName} />
        <PlateField
          label="المنظومات المفحوصة"
          value={`${summary.systemsCheckedCount} — ${summary.faultsFoundCount} عطل`}
          mono
        />
      </dl>

      {summary.briefSummaryArabic && (
        <p className="rib mt-[var(--s5)] pt-[var(--s3)] leading-relaxed text-(color:--ink)">
          {summary.briefSummaryArabic}
        </p>
      )}
    </Cell>
  );
}

/** `Field` as a real `<dt>`/`<dd>` pair, so the list reads once. */
function PlateField({
  label,
  value,
  mono,
}: {
  label: string;
  value: string | number | null | undefined;
  mono?: boolean;
}) {
  return (
    <Field
      pair
      label={label}
      value={value ? orUnknown(value) : null}
      mono={mono}
    />
  );
}

/**
 * The readiness figure.
 *
 * It says out loud when the number was derived from the fault counts rather
 * than reported by the scan — `isScoreEstimated` existed for exactly this and
 * nothing on screen was reading it.
 */
function ReadinessScore({
  score,
  estimated,
  status,
  severity,
}: {
  score: number;
  estimated: boolean;
  status: string;
  severity: Severity;
}) {
  const token = SEVERITY[severity];
  return (
    <div className="flex shrink-0 items-center gap-[var(--s3)] self-start">
      <div className="text-end">
        <div
          data-num
          className="text-(length:--t-score) font-bold leading-none text-(color:--ink)"
        >
          {score}
          <span className="text-(length:--t-body) font-normal text-(color:--ink-2)">%</span>
        </div>
        <div className="k-label uppercase mt-[var(--s1)]">
          {estimated ? "الجاهزية (تقديري)" : "الجاهزية"}
        </div>
      </div>

      <span className="h-[var(--s8)] w-px bg-[var(--rib)]" aria-hidden />

      <div className="flex items-center gap-[var(--s2)]">
        <SeverityMark severity={severity} size={16} />
        <span className="font-semibold" style={{ color: token.ink }}>
          {status}
        </span>
      </div>
    </div>
  );
}
