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
      make: orUnknown(v?.make, "سيارة"),
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

    const text = `*تقرير فحص فني - كاشف*
----------------------------------
السيارة: ${vehicle.make} ${vehicle.model} (${vehicle.year})
رقم الهيكل VIN: ${vehicle.vin}
مؤشر الجاهزية: ${scoreLine}
الممشى: ${vehicle.mileage}
جهاز الفحص: ${report.scannerInfo?.toolName || "جهاز OBD"}

ملخص الفحص:
${summary.briefSummaryArabic}

${
  (faultCategories.criticalFaults || []).length > 0
    ? `الأعطال الحرجة:\n${critFaults}\n`
    : ""
}${
      (faultCategories.moderateFaults || []).length > 0
        ? `أعطال متوسطة:\n${modFaults}\n`
        : ""
    }
قطع الغيار المطلوبة وأرقام الوكالة (OEM):
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

تم استخراج التقرير عبر كاشف`;

    const encoded = encodeURIComponent(text);
    window.open(`https://api.whatsapp.com/send?text=${encoded}`, "_blank");
}

  // 3. Download standalone, highly styled, self-contained HTML report with HD parts SVG
/** No single report may carry more than this in embedded photographs. */
const PHOTO_BUDGET_BYTES = 1_500_000;
/** One slow host must not hold up the download of the whole report. */
const PHOTO_FETCH_TIMEOUT_MS = 6000;

/**
 * Turns one part photo into a data: URI, or gives up.
 *
 * Giving up is a normal outcome and costs nothing: the schematic is already
 * in the card underneath, so a photo that cannot be fetched simply is not
 * there. It legitimately fails when the reader is offline while exporting, or
 * when the file is larger than the budget left.
 *
 * The fetch goes through this app's own origin rather than straight at the
 * photo host, for two reasons that each rule the direct call out on their own:
 * `connect-src` in the CSP is `'self'` plus Google and nothing else, which is
 * what stops injected script posting a pasted API key anywhere; and two of the
 * three photo hosts send no `Access-Control-Allow-Origin`, so the page could
 * not read their bytes even if the CSP allowed the attempt.
 */
async function photoAsDataUri(url: string, budgetLeft: number): Promise<string> {
  try {
    const res = await fetch(
      `/api/part-photo?url=${encodeURIComponent(url)}`,
      { signal: AbortSignal.timeout(PHOTO_FETCH_TIMEOUT_MS) }
    );
    if (!res.ok) return "";

    const blob = await res.blob();
    // base64 is 4 bytes of text for every 3 of image.
    if (!blob.type.startsWith("image/") || blob.size * 1.37 > budgetLeft) return "";

    return await new Promise<string>((resolve) => {
      const reader = new FileReader();
      reader.onload = () =>
        resolve(typeof reader.result === "string" ? reader.result : "");
      reader.onerror = () => resolve("");
      reader.readAsDataURL(blob);
    });
  } catch {
    return "";
  }
}

/**
 * The standalone certificate: one HTML file that opens with no network.
 *
 * Every value is escaped on the way in (`escapeDeep`), because a fault
 * description is model output and this file is opened as a document.
 *
 * Async because the part photos are pulled in and embedded before the file is
 * written. The promise this returns is what the button awaits; the file lands
 * when it resolves.
 */
export async function downloadReportHtml(
  report: KashifDiagnosticReport
): Promise<void> {
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

    // The photo is embedded, not linked.
    //
    // This file's stated promise is that it opens on a workshop laptop with no
    // internet, and a remote <img> quietly broke that for exactly the parts
    // that had a photo: online the mechanic saw a photograph, in the bay with
    // no signal he saw the drawing. Fetched here, once, at export time.
    //
    // Sequential rather than parallel: the budget below is a running total, so
    // the first photos get the room and a later 4MB one is simply skipped
    // rather than everything being fetched and then thrown away.
    let budgetLeft = PHOTO_BUDGET_BYTES;
    for (const part of partsWithSvg) {
      const src = part.partImageUrl;
      if (
        !src ||
        !(src.startsWith("http://") || src.startsWith("https://")) ||
        src.includes("/parts/")
      ) {
        part.partImageUrl = undefined;
        continue;
      }
      const dataUri = await photoAsDataUri(src, budgetLeft);
      // A data: URI is the only src that ships. Leaving the remote URL as a
      // fallback would put the promise straight back.
      part.partImageUrl = dataUri || undefined;
      budgetLeft -= dataUri.length;
    }

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
  <title>تقرير فحص فني - ${orUnknown(safe.vehicle.make, 'سيارة')} ${orUnknown(safe.vehicle.model, '')} (${orUnknown(safe.vehicle.year, '')})</title>
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
      /* Fixed box: the schematic must not resize the card as it draws. It runs
         the full width of the card because 104px is not enough to recognise a
         part from, and recognising it is the only reason it is drawn. */
      position: relative;
      width: 100%; aspect-ratio: 4 / 3; max-height: 168px;
      margin-bottom: 10px;
      display: flex; align-items: center; justify-content: center; padding: 8px;
      color: var(--ink-2);
    }
    /* The photo sits on top of the schematic, and removing it on error
       simply reveals the drawing underneath. The fallback used to be the SVG
       itself interpolated into the onerror attribute — the SVG's own quotes
       closed the attribute early, so it never ran and its tail printed as
       visible text beside the photo. */
    .part-photo {
      position: absolute; inset: 0;
      width: 100%; height: 100%; object-fit: contain;
      background: var(--board); padding: 6px;
    }

    .check-step { display: flex; align-items: flex-start; gap: 10px; padding: 9px 0; border-bottom: 1px solid var(--rule); }
    .check-step:last-child { border-bottom: none; }
    .check-box { width: 15px; height: 15px; border: 1.5px solid var(--ink-2); margin-top: 3px; flex-shrink: 0; }

    .signoff-box { display: flex; flex-wrap: wrap; justify-content: space-between; align-items: center; gap: 16px; }
    .sign-line { border-bottom: 1px dashed var(--ink-3); min-width: 160px; height: 22px; display: inline-block; }

    /* An LTR run inside an RTL line: a part number must not break across a
       line with its tail orphaned on the next one. */
    .ltr-chunk { unicode-bidi: isolate; white-space: nowrap; }

    /* Screen: the footer is the sheet identifier, and there are no sheets. */
    .print-footer { display: none; }

    /* Bottom margin leaves the band the running footer sits in. */
    @page { margin: 14mm 14mm 24mm; }

    @media print {
      html, body {
        background: var(--paper);
        -webkit-print-color-adjust: exact !important;
        print-color-adjust: exact !important;
      }
      body { padding: 0; font-size: 11pt; }
      .top-actions { display: none !important; }
      /* A single line of a paragraph stranded on its own sheet reads as a
         different finding than the one it belongs to. */
      p, li, div { orphans: 3; widows: 3; }
      /* Fixed position in paged media repeats on every sheet. Without it,
         pages 2..n carry no vehicle at all and loose printouts cannot be
         matched back to the car they were taken from. */
      .print-footer {
        display: block;
        position: fixed;
        /* Inside the page content box, not in the @page margin: Chrome clips
           what sits outside it. The bottom margin below is widened instead so
           this band has room, and the footer paints its own paper behind it. */
        bottom: 0; left: 0; right: 0;
        font-size: 8pt; color: var(--ink-2);
        background: var(--paper);
        border-top: 1px solid var(--rule);
        padding: 3px 0 2px;
        text-align: center;
      }
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
        <span style="font-weight: 700; color: var(--amp-15);">كاشف</span>
        <span style="font-size: 11px; color: var(--ink-2); margin-right: 6px;">تشخيص أعطال السيارات</span>
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
            <h1 style="font-size: 18px; font-weight: 800; color: inherit;">تقرير فحص وتشخيص الأعطال</h1>
            <p style="font-size: 11px; color: var(--ink-2);">تشخيص أعطال بمصطلحات ورش الصيانة الليبية</p>
          </div>
        </div>

        <div class="workshop-seal">
          <span>فحص كمبيوتر</span>
          <span>• جهاز ${orUnknown(safe.scannerInfo.toolName)}</span>
        </div>
      </div>

      <div class="hero-content">
        <div>
          <div class="car-title">${orUnknown(safe.vehicle.make, 'سيارة')} ${orUnknown(safe.vehicle.model, '')} (${orUnknown(safe.vehicle.year, '')})</div>
          <div class="car-vin">VIN: ${orUnknown(safe.vehicle.vin)}</div>
          <div class="telemetry-row">
            <div class="telemetry-chip">الممشى: <strong>${orUnknown(safe.vehicle.mileage)}</strong></div>
            <div class="telemetry-chip">المحرك: <strong>${orUnknown(safe.vehicle.engineSpecs?.displacement)}</strong>${safe.vehicle.engineSpecs?.isInferred ? ` <span style="color: var(--ink-3);">(مستنتج)</span>` : ""}</div>
            <div class="telemetry-chip">تاريخ الفحص: <strong>${safe.generatedAt.slice(0, 10)}</strong></div>
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
      <div class="summary-title">ملخص حالة السيارة:</div>
      <p class="summary-text">${safe.summary.briefSummaryArabic}</p>
    </div>

    <!-- Fault Priority Matrix -->
    <h2 class="section-title">تصنيف الأعطال والمنظومات</h2>
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
        <span class="matrix-badge" style="background: var(--amp-20);">أعطال متوسطة (${safe.faultCategories.moderateFaults.length})</span>
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
        <span class="matrix-badge" style="background: var(--amp-30);">منظومات سليمة (${safe.passedSystems.length})</span>
        <div style="font-size: 11px; color: var(--ink-2);">
          ${
            safe.passedSystems.length === 0
              ? "جهاز الفحص ما ذكرش منظومات طلعت سليمة في هذا الفحص"
              : safe.passedSystems.map((s) => s.systemNameArabic).join(" • ")
          }
        </div>
      </div>
    </div>

    <!-- Detailed DTC Faults -->
    <h2 class="section-title">تفاصيل الأعطال المشخصة والأسباب (${allFaults.length})</h2>
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
              : `غير محدد — اقرا الرسم المطبوع على غطا علبة الفيوزات. ${escapeHtml(elec.fuseInfo.boxLocation)}`;
            const elecNote =
              elec.provenance === "general"
                ? `<div style="color: var(--amp-20); margin-top: 4px; font-size: 10px;">إرشاد عام لعائلة هذا الرمز — مش مخطط سيارتك.</div>`
                : elec.provenance === "reference"
                  ? `<div style="color: var(--ink-2); margin-top: 4px; font-size: 10px;">بيانات مرجعية للرمز — تأكد منها على السيارة قبل الفك.</div>`
                  : "";
            // Four lines that all say غير محدد read, at a glance, like a
            // wiring sheet for this car. On a Camry whose codes are all B-codes
            // that block printed identically on all seven faults and was the
            // largest thing on every card. When there is nothing on file, say
            // so once, in the type weight of a footnote.
            // A hazard in the work is shown at any provenance, and before the
            // readings. On the SRS family the generic "check 12V and the
            // ground" line is the thing it is there to override.
            const elecWarning = elec.warning
              ? `<div style="border: 1px solid var(--amp-10); border-inline-start-width: 5px; background: var(--paper); padding: 8px 10px; margin-top: 8px; font-size: 11px; color: var(--ink); font-weight: 600;">⚠ ${escapeHtml(elec.warning)}</div>`
              : "";
            const haveSheet = Boolean(elec.fuseInfo.fuseNumber) || elec.provenance === "reference";
            const elecBlock = elecWarning + (haveSheet
              ? `<div style="background: var(--board); border: 1px dashed var(--rule); padding: 8px 10px; margin-top: 8px; font-size: 11px;">
            <div style="color: var(--amp-15); font-weight: bold; margin-bottom: 3px;">⚡ فحص الفيوز والفيشة:</div>
            <div style="color: var(--ink); margin-bottom: 2px;">📍 <strong>موقع الحساس:</strong> ${elec.sensorLocation.areaName}</div>
            <div style="color: var(--amp-20); margin-bottom: 2px;">🔌 <strong>الفيوز:</strong> ${fuseLine}</div>
            <div style="color: var(--amp-30);">🔋 <strong>فحص الأفوميتر:</strong> ${elec.multimeterTest.powerPin} | ${elec.multimeterTest.groundPin}</div>
            ${elecNote}
          </div>`
              : `<div style="margin-top: 8px; font-size: 10px; color: var(--ink-3); line-height: 1.5;">
            ⚡ ما عندناش مخطط فيوز وفيشة لهذا الرمز — اقرا الرسم المطبوع على غطا علبة الفيوزات في سيارتك.
            قاعدة عامة بالأفوميتر: ${elec.multimeterTest.powerPin} | ${elec.multimeterTest.groundPin}
          </div>`);
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
            <strong style="color: var(--amp-20); display: block; margin-bottom: 2px;">الأعراض عند السائق:</strong>
            ${f.driverSymptoms.map((s) => `• ${s}`).join("<br>")}
          </div>

          ${elecBlock}

          <div style="margin-top: 8px; font-size: 11px; color: var(--ink);">
            <strong style="color: var(--amp-30);">التوجيه:</strong> ${f.recommendedAction}
          </div>
        </div>
      `;
          }
        )
        .join("")}
    </div>

    <!-- Spare Parts Section -->
    <h2 class="section-title">قطع الغيار المطلوبة وأرقام الوكالة (OEM) (${partsWithSvg.length})</h2>
    <div class="parts-grid">
      ${partsWithSvg
        .map(
          (p) => `
        <div class="part-card">
          <div>
            <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 8px;">
              <span style="font-size: 11px; color: var(--amp-15); font-weight: 600;">${p.diagramCategory ? `منظومة ${p.diagramCategory}` : ""}</span>
              <span style="font-size: 10px; font-family: monospace; color: var(--amp-20);">كود: ${p.relatedCode}</span>
            </div>

            <div class="part-visual-container">
              ${p.svg}
              ${
                p.partImageUrl
                  ? `<img class="part-photo" src="${p.partImageUrl}" alt="${p.partNameLibyan}" onerror="this.remove()">`
                  : ""
              }
            </div>

            <div style="font-size: 14px; font-weight: 700; color: inherit; margin-bottom: 2px;">${p.partNameLibyan}</div>
            <div style="font-size: 11px; color: var(--ink-2); margin-bottom: 8px;">${p.partNameStandardArabic}</div>

            <div style="background: var(--board); padding: 8px 10px; border: 1px solid var(--rule); margin-bottom: 8px;">
              <div style="font-size: 10px; color: var(--ink-2);">رقم الوكالة (OEM):</div>
              <div class="ltr-chunk" style="font-family: monospace; font-size: 12px; font-weight: 700; color: var(--amp-20);">${p.oemPartNumber}</div>
              ${
                p.oemPartNumber && p.isOemNumberUnverified
                  ? `<div style="font-size: 9px; color: var(--ink-3); margin-top: 3px; line-height: 1.4;">من المساعد، مش من جهاز الفحص — أكّده مع المحل على رقم هيكل سيارتك.</div>`
                  : ""
              }
            </div>

            ${
              p.aftermarketReplacements.length > 0
                ? `<div style="font-size: 10px; color: var(--ink-2); margin-bottom: 8px;">
                    <strong>بدائل مقترحة:</strong> ${p.aftermarketReplacements.map((a) => `<span class="ltr-chunk">${a}</span>`).join("، ")}
                   </div>`
                : ""
            }
          </div>

          <div style="border-top: 1px solid var(--rule); padding-top: 8px; margin-top: 8px;">
            <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 4px;">
              <span style="font-size: 11px; color: var(--ink-2);">السعر التقديري:</span>
              <span style="font-family: monospace; font-size: 12px; font-weight: 700; color: var(--amp-30);">${p.estimatedPriceRangeLYD ? `${p.estimatedPriceRangeLYD.min} - ${p.estimatedPriceRangeLYD.max} د.ل` : 'غير مسعّرة'}</span>
            </div>
            <div style="font-size: 10px; color: var(--ink-2);">${p.estimatedPriceRangeLYD?.marketNote || 'غير مسعّرة في السوق.'}</div>
          </div>
        </div>
      `
        )
        .join("")}
    </div>

    <!-- Diagnostic Checklist -->
    <h2 class="section-title">ترتيب الفحص قبل الشراء</h2>
    <div class="checklist-card">
      ${safe.workshopChecklist
        .map(
          (step) => `
        <div class="check-step">
          <div class="check-box"></div>
          <div style="flex: 1;">
            <div style="font-size: 12px; font-weight: 700; color: inherit; margin-bottom: 2px;">
              خطوة ${step.stepNumber}: ${step.targetComponent} <span style="font-size: 10px; font-weight: normal; color: var(--ink-2); margin-right: 6px;">(العدة: ${step.toolNeeded})</span>
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
        <div style="font-size: 13px; font-weight: 700; color: inherit; margin-bottom: 2px;">توقيع الأسطى</div>
        <p style="font-size: 11px; color: var(--ink-2);">كاشف قرا تقرير جهاز الفحص وترجمه. الاعتماد يجي من الأسطى اللي كشف على السيارة.</p>
      </div>

      <div style="display: flex; gap: 20px; font-size: 11px; color: var(--ink-2);">
        <div>التاريخ: <strong style="color: inherit;">${safe.generatedAt.slice(0, 10)}</strong></div>
        <div>توقيع الفاحص: <span class="sign-line"></span></div>
      </div>
    </div>

    <div style="text-align: center; margin-top: 20px; font-size: 10px; color: var(--ink-2);">
      كاشف — تشخيص أعطال السيارات بمصطلحات الورش الليبية
    </div>

    <!-- Repeats on every printed sheet. Screen never shows it. -->
    <div class="print-footer">
      ${orUnknown(safe.vehicle.make, 'سيارة')} ${orUnknown(safe.vehicle.model, '')}
      — VIN <span class="ltr-chunk">${orUnknown(safe.vehicle.vin)}</span>
      — فحص ${safe.generatedAt.slice(0, 10)}
      — كاشف
    </div>
  </div>
</body>
</html>`;

    const blob = new Blob([htmlContent], { type: "text/html;charset=utf-8" });
    const url = URL.createObjectURL(blob);
    const a = document.createElement("a");
    a.href = url;
    a.download = `تقرير_كاشف_${safeFilenamePart(report.vehicle.make, 'سيارة')}_${safeFilenamePart(report.vehicle.model, '')}_${safeFilenamePart(report.generatedAt.slice(0, 10))}.html`;
    document.body.appendChild(a);
    a.click();
    document.body.removeChild(a);
    URL.revokeObjectURL(url);
}
