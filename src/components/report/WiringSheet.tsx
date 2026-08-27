"use client";

import * as React from "react";
import { CodePlate, Field } from "@/components/ui/primitives";
import { Sheet } from "@/components/ui/Sheet";
import { getElectricalDiagnosticsForCode } from "@/lib/sensor-locator";
import type { DiagnosticCodeDetail, ElectricalProvenance } from "@/lib/types";

/**
 * The fuse, the connector, and what the meter should read.
 *
 * This is the one screen in the product where a reader acts physically on what
 * it says — they pull a fuse, and they put a probe on a pin. So it is also the
 * one screen where being wrong is expensive, and where the source of every
 * claim has to be visible before the claim is.
 *
 * The version this replaces printed a sixteen-cell "FUSE BOX SCHEMATIC MATRIX"
 * — F01 (10A) through F16 (7.5A), hardcoded, identical for every car — and
 * pulsed an amber "المستهدف ⭐" over one of them. No car has that layout except
 * by coincidence. It also dropped a marker at the centre of a generic engine
 * bay drawing whenever it had no real coordinate, which pointed at whichever
 * component happened to be drawn there.
 *
 * Both are gone. What is left is what can be said honestly, labelled with
 * where it came from.
 */
export function WiringSheet({
  fault,
  vehicleMake,
  vehicleModel,
  onClose,
}: {
  fault: DiagnosticCodeDetail;
  vehicleMake?: string;
  vehicleModel?: string;
  onClose: () => void;
}) {
  const diag =
    fault.electricalDiagnostics ??
    getElectricalDiagnosticsForCode(fault.code, vehicleMake);

  const { fuseInfo, sensorLocation, multimeterTest, provenance, warning } = diag;
  const source = PROVENANCE[provenance];

  return (
    <Sheet title="الفيوز والفيشة" onClose={onClose}>
      <div className="space-y-[var(--s5)]">
        <header className="flex flex-wrap items-center gap-[var(--s2)]">
          <CodePlate>{fault.code}</CodePlate>
          <span className="k-label uppercase">
            {fault.moduleNameArabic || fault.module}
          </span>
          {(vehicleMake || vehicleModel) && (
            <span className="k-label uppercase">
              {[vehicleMake, vehicleModel].filter(Boolean).join(" ")}
            </span>
          )}
          <h3 className="w-full font-bold text-(color:--ink)">{fault.libyanTerm}</h3>
        </header>

        {/* Where this came from, before anything it says. */}
        <div
          className="border-s-[3px] bg-[var(--board-sunk)] p-[var(--s3)] ps-[var(--s3)]"
          style={{ borderColor: source.ink }}
        >
          <div className="k-label uppercase" style={{ color: source.ink }}>
            {source.label}
          </div>
          <p className="mt-[var(--s1)] leading-relaxed text-(color:--ink)">
            {source.note}
          </p>
        </div>

        {/* A hazard in the work comes before every reading on the sheet. On the
            airbag family the readings are exactly what it overrides. */}
        {warning && (
          <div
            className="border border-s-[5px] p-[var(--s3)] font-bold leading-relaxed text-(color:--ink)"
            style={{ borderColor: "var(--amp-10)" }}
            role="alert"
          >
            ⚠ {warning}
          </div>
        )}

        <Section title="الفيوز">
          <Field label="موقع علبة الفيوزات" value={fuseInfo.boxLocation} />
          <Field
            label="رقم الفيوز"
            value={fuseInfo.fuseNumber}
            mono
          />
          <Field label="الأمبير" value={fuseInfo.rating} mono />
          {fuseInfo.relayName && (
            <Field label="الكتاوت المرتبط" value={fuseInfo.relayName} />
          )}
          <Field label="الدائرة" value={fuseInfo.circuitDescription} />
        </Section>

        <Section title="موقع الحساس">
          <Field label="المنطقة" value={sensorLocation.areaName} />
          <Field label="الوصول والفك" value={sensorLocation.accessTip} />
        </Section>

        <Section title="قياس الأفوميتر">
          <Field label="خط الكهرباء" value={multimeterTest.powerPin} mono />
          <Field label="خط الأرضي" value={multimeterTest.groundPin} mono />
          <Field label="خط الإشارة" value={multimeterTest.signalPin} mono />
          {multimeterTest.referenceVoltage && (
            <Field
              label="الجهد المرجعي"
              value={multimeterTest.referenceVoltage}
              mono
            />
          )}
          <p className="mt-[var(--s2)] leading-relaxed text-(color:--ink)">
            {multimeterTest.testingTipLibyan}
          </p>
        </Section>

        <p className="rib pt-[var(--s3)] leading-relaxed text-(color:--ink-2)">
          افحص الفيوز والفيشة قبل ما تشري أي قطعة. رقم الفيوز وترتيب العلبة
          مطبوعين على غطا علبة الفيوزات في سيارتك — وهو المرجع الأكيد.
        </p>
      </div>
    </Sheet>
  );
}

function Section({
  title,
  children,
}: {
  title: string;
  children: React.ReactNode;
}) {
  return (
    <section>
      <div className="rib-heavy flex items-center gap-[var(--s2)] pt-[var(--s2)]">
        <h4 className="k-bank uppercase text-(color:--ink)">{title}</h4>
        <span className="rib mt-[2px] h-px flex-1" aria-hidden />
      </div>
      <div className="mt-[var(--s3)] space-y-[var(--s2)]">{children}</div>
    </section>
  );
}

/**
 * How much the reader is entitled to trust what follows.
 *
 * `general` is deliberately the loud one — 10A red, the critical ink — because
 * it is the case where the app knows least and the old version said most.
 */
const PROVENANCE: Record<
  ElectricalProvenance,
  { label: string; note: string; ink: string }
> = {
  scan: {
    label: "من فحص سيارتك",
    note: "البيانات هذي مقروءة مباشرة من تقرير فحص سيارتك.",
    ink: "var(--amp-30-ink)",
  },
  reference: {
    label: "من مرجع الأكواد",
    note: "بيانات مرجعية للرمز نفسه، مش مقروءة من سيارتك. تأكد منها على السيارة قبل الفك أو القياس — الترقيم يختلف بين الموديلات والسنوات.",
    ink: "var(--amp-15-ink)",
  },
  general: {
    label: "إرشاد عام — مش مخطط سيارتك",
    note: "الرمز مش موجود في المرجع عندنا. اللي مكتوب تحت إرشاد ورشة عام لعائلة الرمز: ما فيهش رقم فيوز ولا أمبير ولا موقع محدد، لأنها تختلف من سيارة لسيارة.",
    ink: "var(--amp-10-ink)",
  },
};
