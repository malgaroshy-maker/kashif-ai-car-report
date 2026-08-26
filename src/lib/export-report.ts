import { escapeDeep, escapeHtml, safeFilenamePart } from "./html-escape";
import { getPartSvg } from "./part-visuals";
import { getElectricalDiagnosticsForCode } from "./sensor-locator";
import { orUnknown, type KashifDiagnosticReport } from "./types";

/**
 * The three ways a report leaves the screen.
 *
 * These were 650 lines inside a button bar, so the markup and the document
 * builder could not be worked on separately — and the button bar was the old
 * dark-dashboard design. The builder is the part worth keeping: it produces a
 * file that opens on a workshop laptop with no internet, and it has already
 * been through the escaping and the no-invented-values passes.
 */

/** Hands the page to the browser's print dialog, which is also Save as PDF. */
export function printReport(): void {
    window.print();
}

  // 2. Generate and open WhatsApp message
/**
 * The short text version, for pasting into WhatsApp.
 *
 * This is the copy that actually travels: it gets forwarded to the owner, to
 * the parts shop, and to whoever is being asked for a second opinion. It says
 * `غير محدد` where the scan said nothing, because a number invented here is a
 * number somebody quotes back later as fact.
 */
export function shareReportToWhatsApp(report: KashifDiagnosticReport): void {
    const v = report?.vehicle;
    const vehicle = {
      make: orUnknown(v?.make, "مركبة"),
      model: orUnknown(v?.model, ""),
      year: orUnknown(v?.year, ""),
      vin: orUnknown(v?.vin),
      mileage: orUnknown(v?.mileage, "غير مسجل"),
    };
    // A report with no summary used to be shared as "70% / متوسط / انتبه /
    // تم فحص التقرير بنجاح" — a grade, a severity and a verdict, none of them
    // from this car. Say the score is unknown instead.
    const summary = report?.summary;
    const scoreLine = summary
      ? `${summary.overallHealthScore}%${summary.isScoreEstimated ? " (تقديري من عدد الأعطال)" : ""} (${summary.severityStatus})`
      : "غير محدد";
    const faultCategories = report?.faultCategories || {
      criticalFaults: [],
      moderateFaults: [],
      minorOrHistoricalFaults: [],
    };
    const critFaults = (faultCategories.criticalFaults || [])
      .map((f) => `• [${f.code}] ${f.libyanTerm}`)
      .join("\n");
    const modFaults = (faultCategories.moderateFaults || [])
      .map((f) => `• [${f.code}] ${f.libyanTerm}`)
      .join("\n");

    const text = `*تقرير فحص فني معتمد - كاشف AI*
----------------------------------
المركبة: ${vehicle.make} ${vehicle.model} (${vehicle.year})
رقم الهيكل VIN: ${vehicle.vin}
مؤشر الجاهزية: ${scoreLine}
الممشى: ${vehicle.mileage}
جهاز الفحص: ${report.scannerInfo?.toolName || "جهاز OBD"}

ملخص التقييم الفني:
${summary.briefSummaryArabic}

${
  (faultCategories.criticalFaults || []).length > 0
    ? `الأعطال الحرجة:\n${critFaults}\n`
    : ""
}${
      (faultCategories.moderateFaults || []).length > 0
        ? `أعطال تتطلب صيانة:\n${modFaults}\n`
        : ""
    }
قطع الغيار والـ OEM التقديرية:
${(report.sparePartsRequired || [])
  .map(
    (p) =>
      `• ${p.partNameLibyan} (OEM: ${orUnknown(p.oemPartNumber)}) ~ ${
        p.estimatedPriceRangeLYD
          ? `${p.estimatedPriceRangeLYD.min}-${p.estimatedPriceRangeLYD.max} د.ل`
          : "غير مسعّرة"
      }`
  )
  .join("\n")}

تم الفحص عبر منظومة كاشف AI للتشخيص الرقمي`;

    const encoded = encodeURIComponent(text);
    window.open(`https://api.whatsapp.com/send?text=${encoded}`, "_blank");
}

  // 3. Download standalone, highly styled, self-contained HTML report with HD parts SVG
/**
 * The standalone certificate: one HTML file that opens with no network.
 *
 * Every value is escaped on the way in (`escapeDeep`), because a fault
 * description is model output and this file is opened as a document.
 */
export function downloadReportHtml(report: KashifDiagnosticReport): void {
    // Every string below is model output, interpolated into an HTML file the
    // user forwards to their customer. Escaping once at the source is the only
    // enforceable place: the template has hundreds of interpolation points and
    // one missed call is the whole hole. `svg` is merged in afterwards from the
    // ORIGINAL part, because it is the one value that must stay real markup.
    const safe = escapeDeep(report);

    const faultCats = safe?.faultCategories || {
      criticalFaults: [],
      moderateFaults: [],
      minorOrHistoricalFaults: [],
    };
    const allFaults = [
      ...(faultCats.criticalFaults || []),
      ...(faultCats.moderateFaults || []),
      ...(faultCats.minorOrHistoricalFaults || []),
    ];

    const partsWithSvg = (report?.sparePartsRequired || []).map((p, i) => ({
      ...escapeDeep(p),
      svg: getPartSvg(
        p.partNameLibyan || p.partNameEnglish,
        p.oemPartNumber ?? undefined
      ),
      _key: i,
    }));

    const score =
      typeof report?.summary?.overallHealthScore === "number"
        ? report.summary.overallHealthScore
        : 0;
    // The on-screen report says when a score was derived from the fault counts
    // rather than reported by the scan. The exported certificate — the copy
    // that gets forwarded and printed — was computing this label and then
    // never printing it.
    const scoreNote = report?.summary?.isScoreEstimated
      ? "الجاهزية (تقديري)"
      : "الجاهزية";
    // The gauge ring takes the fuse colour for the tier. It is never the only
    // carrier: the number and the status text are right there, so a monochrome
    // printout loses nothing.
    const healthColor =
      score >= 80
        ? "var(--amp-30)"
        : score >= 60
          ? "var(--amp-20)"
          : "var(--amp-10)";

    const htmlContent = `<!DOCTYPE html>
<html lang="ar" dir="rtl">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>تقرير فحص فني معتمد - ${orUnknown(safe.vehicle.make, 'مركبة')} ${orUnknown(safe.vehicle.model, '')} (${orUnknown(safe.vehicle.year, '')})</title>
  <style>
    /*
      No @font-face and no <link>. This file's whole reason for existing is
      that it opens on a workshop laptop with no internet, and it was linking
      two Google Fonts families — opened offline, the actual usage scene, it
      rendered in whatever the browser felt like.

      System stacks only. On Windows that is Segoe UI, on Android Roboto, on
      iOS/macOS the San Francisco family; all three carry Arabic.
    */
    :root {
      --paper: #ffffff;
      --board: #f2f3ef;
      --ink: #161a15;
      --ink-2: #4c524a;
      --ink-3: #6b716c;
      --rule: #c9ccc4;

      /* ISO/DIN 72581-3 blade fuse colours — the same code printed on every
         fuse in the car, and the same one the app uses on screen. */
      --amp-10: #a81f15; /* حرج    */
      --amp-20: #7a5500; /* متوسط  */
      --amp-30: #125b2f; /* سليم   */
      --amp-25: #565c59; /* ذاكرة  */
      --amp-15: #0f5288; /* الحيادي */
    }

    * { box-sizing: border-box; margin: 0; padding: 0; }

    body {
      font-family: "Segoe UI", Roboto, system-ui, -apple-system, "Helvetica Neue", sans-serif;
      background-color: var(--board);
      color: var(--ink);
      line-height: 1.6;
      font-size: 13px;
      padding: 24px 16px;
      direction: rtl;
      -webkit-print-color-adjust: exact;
      print-color-adjust: exact;
    }

    /* Data — codes, VINs, prices, part numbers. Never used for atmosphere. */
    .font-latin,
    .car-vin,
    .dtc-code,
    .gauge-score,
    .telemetry-chip strong {
      font-family: ui-monospace, "Cascadia Mono", "Consolas", "Courier New", monospace;
      font-variant-numeric: tabular-nums;
    }

    .container { max-width: 1050px; margin: 0 auto; }

    .top-actions { display: flex; gap: 8px; margin-bottom: 16px; }
    .btn-action {
      font: inherit;
      font-weight: 600;
      padding: 10px 16px;
      min-height: 44px;
      border: 1px solid var(--rule);
      background: var(--paper);
      color: var(--ink);
      cursor: pointer;
    }
    .btn-action:hover { background: var(--board); }

    /* A silkscreened panel. Square, hairline, no shadow and no rounding —
       the same rule the app follows. */
    .header-card,
    .matrix-card,
    .fault-card,
    .part-card,
    .checklist-card,
    .summary-card,
    .signoff-box {
      background: var(--paper);
      border: 1px solid var(--rule);
      padding: 16px;
      margin-bottom: 16px;
    }

    .header-top { display: flex; flex-wrap: wrap; justify-content: space-between; align-items: center; gap: 12px; padding-bottom: 12px; border-bottom: 1px solid var(--rule); }
    .brand-group { display: flex; align-items: center; gap: 10px; }
    .logo-badge {
      display: inline-flex; align-items: center; justify-content: center;
      min-width: 34px; padding: 5px 7px;
      background: var(--amp-15); color: var(--paper);
      font-family: ui-monospace, monospace; font-size: 11px; font-weight: 700;
    }
    .workshop-seal { font-size: 11px; color: var(--ink-2); letter-spacing: 0.06em; }

    .hero-content { display: flex; flex-wrap: wrap; justify-content: space-between; align-items: flex-start; gap: 16px; padding-top: 14px; }
    .car-title { font-size: 21px; font-weight: 700; line-height: 1.25; }
    .car-vin { font-size: 12px; color: var(--ink-2); margin-bottom: 10px; }
    .telemetry-row { display: flex; flex-wrap: wrap; gap: 8px; }
    .telemetry-chip {
      font-size: 11px; color: var(--ink-2);
      background: var(--board); border: 1px solid var(--rule);
      padding: 4px 8px;
    }
    .telemetry-chip strong { color: var(--ink); }

    .gauge-wrapper { display: flex; align-items: center; gap: 12px; }
    .health-gauge { text-align: center; padding: 10px 16px; border: 3px solid var(--rule); }
    .gauge-score { font-size: 26px; font-weight: 700; line-height: 1; }
    .gauge-label { font-size: 10px; color: var(--ink-2); margin-top: 3px; letter-spacing: 0.06em; }

    .summary-title { font-size: 11px; font-weight: 700; color: var(--ink-2); letter-spacing: 0.08em; margin-bottom: 6px; text-transform: uppercase; }
    .summary-text { line-height: 1.75; }

    /* A bank rule: the heavy moulded rib that opens a section. */
    .section-title {
      font-size: 14px; font-weight: 700; letter-spacing: 0.05em;
      border-top: 3px solid var(--rule);
      padding-top: 8px; margin-bottom: 12px;
    }

    .matrix-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(210px, 1fr)); gap: 12px; }
    /* Severity is a solid seat on the inline-start edge plus a badge that
       names the tier — it survives a black-and-white printer, which a tinted
       border does not. */
    .matrix-card.critical { border-inline-start: 5px solid var(--amp-10); }
    .matrix-card.moderate { border-inline-start: 5px solid var(--amp-20); }
    .matrix-card.passed   { border-inline-start: 5px solid var(--amp-30); }
    .matrix-badge { font-size: 10px; font-weight: 700; padding: 3px 7px; margin-bottom: 8px; display: inline-block; color: var(--paper); }

    .fault-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(290px, 1fr)); gap: 12px; }
    .fault-header { display: flex; justify-content: space-between; align-items: center; gap: 8px; margin-bottom: 8px; }
    .dtc-code { font-size: 12px; font-weight: 700; background: var(--ink); color: var(--paper); padding: 4px 7px; }
    .fault-title { font-size: 14px; font-weight: 700; margin-bottom: 4px; }
    .fault-box { background: var(--board); border: 1px solid var(--rule); padding: 9px; margin-top: 8px; font-size: 11px; }

    .parts-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(290px, 1fr)); gap: 12px; }
    .part-visual-container {
      background: var(--board); border: 1px solid var(--rule);
      /* Fixed box: the schematic must not resize the card as it draws. */
      width: 104px; height: 104px; flex-shrink: 0;
      display: flex; align-items: center; justify-content: center; padding: 6px;
    }

    .check-step { display: flex; align-items: flex-start; gap: 10px; padding: 9px 0; border-bottom: 1px solid var(--rule); }
    .check-step:last-child { border-bottom: none; }
    .check-box { width: 15px; height: 15px; border: 1.5px solid var(--ink-2); margin-top: 3px; flex-shrink: 0; }

    .signoff-box { display: flex; flex-wrap: wrap; justify-content: space-between; align-items: center; gap: 16px; }
    .sign-line { border-bottom: 1px dashed var(--ink-3); min-width: 160px; height: 22px; display: inline-block; }

    @page { margin: 14mm; }

    @media print {
      body { background: var(--paper); padding: 0; font-size: 11pt; }
      .top-actions { display: none !important; }
      /* Keep a finding whole across a page break. A fault split down the
         middle of a sheet is how a symptom gets read against the wrong code. */
      .fault-card, .part-card, .matrix-card, .check-step, .signoff-box {
        break-inside: avoid;
        page-break-inside: avoid;
      }
      .section-title { break-after: avoid; page-break-after: avoid; }
    }
  </style>
</head>
<body>
  <div class="container">
    <!-- Action Bar -->
    <div class="top-actions">
      <div>
        <span style="font-weight: 700; color: var(--amp-15);">كاشف الذكي (Kashif AI)</span>
        <span style="font-size: 11px; color: var(--ink-2); margin-right: 6px;">منظومة التشخيص الفني الرقمي</span>
      </div>
      <button class="btn-action" onclick="window.print()">
        طباعة التقرير / حفظ PDF
      </button>
    </div>

    <!-- Workshop & Vehicle Executive Header -->
    <div class="header-card">
      <div class="header-top">
        <div class="brand-group">
          <div class="logo-badge font-latin">K</div>
          <div>
            <h1 style="font-size: 18px; font-weight: 800; color: inherit;">مركز الفحص والتشخيص الفني المعتمد</h1>
            <p style="font-size: 11px; color: var(--ink-2);">تقرير فحص وتشخيص إلكتروني معتمد بالمصطلحات الفنية الميدانية</p>
          </div>
        </div>

        <div class="workshop-seal">
          <span>فحص إلكتروني موثق</span>
          <span>• جهاز ${orUnknown(safe.scannerInfo.toolName)}</span>
        </div>
      </div>

      <div class="hero-content">
        <div>
          <div class="car-title">${orUnknown(safe.vehicle.make, 'مركبة')} ${orUnknown(safe.vehicle.model, '')} (${orUnknown(safe.vehicle.year, '')})</div>
          <div class="car-vin">VIN: ${orUnknown(safe.vehicle.vin)}</div>
          <div class="telemetry-row">
            <div class="telemetry-chip">الممشى: <strong>${orUnknown(safe.vehicle.mileage)}</strong></div>
            <div class="telemetry-chip">المحرك: <strong>${orUnknown(safe.vehicle.engineSpecs?.displacement)}</strong></div>
            <div class="telemetry-chip">تاريخ الفحص: <strong>${safe.generatedAt.slice(0, 10)}</strong></div>
            <div class="telemetry-chip">الفني الفاحص: <strong>م. أحمد الفرجاني</strong></div>
          </div>
        </div>

        <div class="gauge-wrapper">
          <div class="health-gauge" style="border-color: ${healthColor};">
            <div class="gauge-score">${safe.summary.overallHealthScore}%</div>
            <div class="gauge-label">${scoreNote}</div>
          </div>
        </div>
      </div>
    </div>

    <!-- Executive Summary -->
    <div class="summary-card">
      <div class="summary-title">ملخص التقييم الفني للمركبة:</div>
      <p class="summary-text">${safe.summary.briefSummaryArabic}</p>
    </div>

    <!-- Fault Priority Matrix -->
    <h2 class="section-title">مصفوفة تصنيف الأنظمة والأعطال</h2>
    <div class="matrix-grid">
      <div class="matrix-card critical">
        <span class="matrix-badge" style="background: var(--amp-10);">أعطال حرجة (${safe.faultCategories.criticalFaults.length})</span>
        <div style="font-size: 11px; color: var(--ink-2);">
          ${
            report.faultCategories.criticalFaults.length === 0
              ? "لا توجد أعطال حرجة مسجلة"
              : report.faultCategories.criticalFaults
                  .map((f) => `<div style="margin-top: 4px;">• <strong>${f.code}</strong>: ${f.libyanTerm}</div>`)
                  .join("")
          }
        </div>
      </div>

      <div class="matrix-card moderate">
        <span class="matrix-badge" style="background: var(--amp-20);">أعطال متوسطة للصيانة (${safe.faultCategories.moderateFaults.length})</span>
        <div style="font-size: 11px; color: var(--ink-2);">
          ${
            report.faultCategories.moderateFaults.length === 0
              ? "لا توجد أعطال متوسطة"
              : report.faultCategories.moderateFaults
                  .map((f) => `<div style="margin-top: 4px;">• <strong>${f.code}</strong>: ${f.libyanTerm}</div>`)
                  .join("")
          }
        </div>
      </div>

      <div class="matrix-card passed">
        <span class="matrix-badge" style="background: var(--amp-30);">أنظمة سليمة واجتازت الفحص (${safe.passedSystems.length})</span>
        <div style="font-size: 11px; color: var(--ink-2);">
          ${safe.passedSystems.map((s) => s.systemNameArabic).join(" • ")}
        </div>
      </div>
    </div>

    <!-- Detailed DTC Faults -->
    <h2 class="section-title">تفاصيل الأعطال المشخصة والأسباب ومخطط الفيوزات (${allFaults.length})</h2>
    <div class="fault-grid">
      ${allFaults
        .map(
          (f) => {
            const elec = f.electricalDiagnostics || getElectricalDiagnosticsForCode(f.code, safe.vehicle?.make ?? undefined);
            // The printed copy is the one that leaves the workshop and gets
            // acted on with a probe, so it carries the same disclosure the
            // screen does. A fuse number we do not have is stated as missing,
            // not filled in.
            const fuseLine = elec.fuseInfo.fuseNumber
              ? `${escapeHtml(elec.fuseInfo.fuseNumber)}${elec.fuseInfo.rating ? ` (${escapeHtml(elec.fuseInfo.rating)})` : ""} — ${escapeHtml(elec.fuseInfo.boxLocation)}`
              : `غير محدد — اقرا الرسم المطبوع على غطاء علبة الفيوزات. ${escapeHtml(elec.fuseInfo.boxLocation)}`;
            const elecNote =
              elec.provenance === "general"
                ? `<div style="color: var(--amp-20); margin-top: 4px; font-size: 10px;">إرشاد عام لعائلة هذا الرمز — مش مخطط هذه السيارة.</div>`
                : elec.provenance === "reference"
                  ? `<div style="color: var(--ink-2); margin-top: 4px; font-size: 10px;">بيانات مرجعية للرمز — تأكد منها على السيارة قبل الفك.</div>`
                  : "";
            return `
        <div class="fault-card">
          <div class="fault-header">
            <span class="dtc-code">${f.code}</span>
            <span style="font-size: 11px; font-weight: 600; color: var(--ink-2);">
              ${f.moduleNameArabic || f.module}
            </span>
          </div>
          <div class="fault-title">${f.libyanTerm}</div>
          <p style="font-size: 11px; color: var(--ink-2);">${f.standardArabicDescription}</p>

          <div class="fault-box">
            <strong style="color: var(--amp-20); display: block; margin-bottom: 2px;">الأعراض الملاحظة:</strong>
            ${f.driverSymptoms.map((s) => `• ${s}`).join("<br>")}
          </div>

          <div style="background: var(--board); border: 1px dashed var(--rule); padding: 8px 10px; margin-top: 8px; font-size: 11px;">
            <div style="color: var(--amp-15); font-weight: bold; margin-bottom: 3px;">⚡ إرشاد الحساس والفيوز:</div>
            <div style="color: var(--ink); margin-bottom: 2px;">📍 <strong>موقع الحساس:</strong> ${elec.sensorLocation.areaName}</div>
            <div style="color: var(--amp-20); margin-bottom: 2px;">🔌 <strong>الفيوز:</strong> ${fuseLine}</div>
            <div style="color: var(--amp-30);">🔋 <strong>فحص الأفوميتر:</strong> ${elec.multimeterTest.powerPin} | ${elec.multimeterTest.groundPin}</div>
            ${elecNote}
          </div>

          <div style="margin-top: 8px; font-size: 11px; color: var(--ink);">
            <strong style="color: var(--amp-30);">توجيه الفني:</strong> ${f.recommendedAction}
          </div>
        </div>
      `;
          }
        )
        .join("")}
    </div>

    <!-- Spare Parts Section -->
    <h2 class="section-title">دليل قطع الغيار التقديرية وأرقام الـ OEM والصور (${partsWithSvg.length})</h2>
    <div class="parts-grid">
      ${partsWithSvg
        .map(
          (p) => `
        <div class="part-card">
          <div>
            <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 8px;">
              <span style="font-size: 11px; color: var(--amp-15); font-weight: 600;">منظومة ${p.diagramCategory}</span>
              <span style="font-size: 10px; font-family: monospace; color: var(--amp-20);">كود: ${p.relatedCode}</span>
            </div>

            <div class="part-visual-container">
              ${
                p.partImageUrl &&
                (p.partImageUrl.startsWith("http://") || p.partImageUrl.startsWith("https://")) &&
                !p.partImageUrl.includes("/parts/")
                  ? `<img src="${p.partImageUrl}" alt="${p.partNameLibyan}" referrerpolicy="no-referrer" loading="lazy" style="width: 100%; height: 100%; object-fit: contain; padding: 4px;" onerror="this.parentElement.innerHTML = \`${p.svg.replace(/`/g, "\\`")}\`;">`
                  : p.svg
              }
            </div>

            <div style="font-size: 14px; font-weight: 700; color: inherit; margin-bottom: 2px;">${p.partNameLibyan}</div>
            <div style="font-size: 11px; color: var(--ink-2); margin-bottom: 8px;">${p.partNameStandardArabic}</div>

            <div style="background: var(--board); padding: 8px 10px; border: 1px solid var(--rule); margin-bottom: 8px;">
              <div style="font-size: 10px; color: var(--ink-2);">رقم القطعة الأصلي (OEM):</div>
              <div style="font-family: monospace; font-size: 12px; font-weight: 700; color: var(--amp-20);">${p.oemPartNumber}</div>
            </div>

            ${
              p.aftermarketReplacements.length > 0
                ? `<div style="font-size: 10px; color: var(--ink-2); margin-bottom: 8px;">
                    <strong>البدائل المعتمدة:</strong> ${p.aftermarketReplacements.join(", ")}
                   </div>`
                : ""
            }
          </div>

          <div style="border-top: 1px solid var(--rule); padding-top: 8px; margin-top: 8px;">
            <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 4px;">
              <span style="font-size: 11px; color: var(--ink-2);">السعر التقديري في ليبيا:</span>
              <span style="font-family: monospace; font-size: 12px; font-weight: 700; color: var(--amp-30);">${p.estimatedPriceRangeLYD ? `${p.estimatedPriceRangeLYD.min} - ${p.estimatedPriceRangeLYD.max} د.ل` : 'غير مسعّرة'}</span>
            </div>
            <div style="font-size: 10px; color: var(--ink-2);">${p.estimatedPriceRangeLYD?.marketNote || 'ما وصلنا سعر تقديري لهذي القطعة.'}</div>
          </div>
        </div>
      `
        )
        .join("")}
    </div>

    <!-- Diagnostic Checklist -->
    <h2 class="section-title">خطوات فحص الأسطى التسلسلية (Checklist)</h2>
    <div class="checklist-card">
      ${safe.workshopChecklist
        .map(
          (step) => `
        <div class="check-step">
          <div class="check-box"></div>
          <div style="flex: 1;">
            <div style="font-size: 12px; font-weight: 700; color: inherit; margin-bottom: 2px;">
              خطوة ${step.stepNumber}: ${step.targetComponent} <span style="font-size: 10px; font-weight: normal; color: var(--ink-2); margin-right: 6px;">(الأداة: ${step.toolNeeded})</span>
            </div>
            <div style="font-size: 11px; color: var(--ink-2);">${step.actionRequiredLibyan}</div>
          </div>
        </div>
      `
        )
        .join("")}
    </div>

    <!-- Official Workshop Sign-off -->
    <div class="signoff-box">
      <div>
        <div style="font-size: 13px; font-weight: 700; color: inherit; margin-bottom: 2px;">اعتماد وتوثيق مركز الصيانة</div>
        <p style="font-size: 11px; color: var(--ink-2);">تم فحص هذه المركبة واستخراج التقرير بواسطة فني معتمد</p>
      </div>

      <div style="display: flex; gap: 20px; font-size: 11px; color: var(--ink-2);">
        <div>التاريخ: <strong style="color: inherit;">${safe.generatedAt.slice(0, 10)}</strong></div>
        <div>توقيع الفاحص: <span class="sign-line"></span></div>
      </div>
    </div>

    <div style="text-align: center; margin-top: 20px; font-size: 10px; color: var(--ink-2);">
      منظومة كاشف الذكي (Kashif AI) — التحليل التشخيصي المطور لسيارات السوق الليبي
    </div>
  </div>
</body>
</html>`;

    const blob = new Blob([htmlContent], { type: "text/html;charset=utf-8" });
    const url = URL.createObjectURL(blob);
    const a = document.createElement("a");
    a.href = url;
    a.download = `تقرير_كاشف_${safeFilenamePart(report.vehicle.make, 'مركبة')}_${safeFilenamePart(report.vehicle.model, '')}_${safeFilenamePart(report.generatedAt.slice(0, 10))}.html`;
    document.body.appendChild(a);
    a.click();
    document.body.removeChild(a);
    URL.revokeObjectURL(url);
}
