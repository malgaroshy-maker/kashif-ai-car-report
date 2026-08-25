"use client";

import React from "react";
import {
  Printer,
  Share2,
  Download,
} from "lucide-react";
import { KashifDiagnosticReport, orUnknown } from "@/lib/types";
import { escapeDeep, safeFilenamePart } from "@/lib/html-escape";
import { getPartSvg } from "@/lib/part-visuals";
import { getElectricalDiagnosticsForCode } from "@/lib/sensor-locator";

interface ExportActionBarProps {
  report: KashifDiagnosticReport;
}

export const ExportActionBar: React.FC<ExportActionBarProps> = ({ report }) => {

  // 1. Trigger Print to PDF
  const handlePrint = () => {
    window.print();
  };

  // 2. Generate and open WhatsApp message
  const handleWhatsAppShare = () => {
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
  };

  // 3. Download standalone, highly styled, self-contained HTML report with HD parts SVG
  const handleDownloadHtml = () => {
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
    const healthColor =
      score >= 80
        ? "#10B981"
        : score >= 60
        ? "#F59E0B"
        : "#EF4444";

    const htmlContent = `<!DOCTYPE html>
<html lang="ar" dir="rtl">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>تقرير فحص فني معتمد - ${orUnknown(safe.vehicle.make, 'مركبة')} ${orUnknown(safe.vehicle.model, '')} (${orUnknown(safe.vehicle.year, '')})</title>
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;600;700;800&family=Rubik:wght@400;500;700&display=swap" rel="stylesheet">
  <style>
    :root {
      --bg: #090D16;
      --surface-1: #0F172A;
      --surface-2: #1E293B;
      --border: #1E293B;
      --border-card: #283548;
      --blue: #3B82F6;
      --amber: #F59E0B;
      --red: #EF4444;
      --emerald: #10B981;
      --text: #F8FAFC;
      --text-muted: #94A3B8;
    }
    * { box-sizing: border-box; margin: 0; padding: 0; }
    body {
      font-family: 'Rubik', system-ui, -apple-system, sans-serif;
      background-color: var(--bg);
      color: var(--text);
      line-height: 1.6;
      padding: 24px 16px;
      direction: rtl;
    }
    .font-latin { font-family: 'Plus Jakarta Sans', monospace; }
    .container { max-width: 1050px; margin: 0 auto; }
    
    /* Top Action Bar */
    .top-actions {
      display: flex;
      justify-content: space-between;
      align-items: center;
      margin-bottom: 20px;
      padding: 12px 18px;
      background: var(--surface-1);
      border: 1px solid var(--border);
      border-radius: 12px;
    }
    .btn-action {
      background: var(--blue);
      color: #FFFFFF;
      font-weight: 700;
      font-size: 12px;
      border: none;
      padding: 8px 18px;
      border-radius: 8px;
      cursor: pointer;
      display: inline-flex;
      align-items: center;
      gap: 6px;
    }
    .btn-action:hover { opacity: 0.9; }

    /* Workshop Header & Vehicle Banner */
    .header-card {
      background: var(--surface-1);
      border: 1px solid var(--border-card);
      border-radius: 16px;
      padding: 24px;
      margin-bottom: 20px;
    }
    .header-top {
      display: flex;
      justify-content: space-between;
      align-items: center;
      border-bottom: 1px solid var(--border);
      padding-bottom: 16px;
      margin-bottom: 20px;
      flex-wrap: wrap;
      gap: 12px;
    }
    .brand-group { display: flex; align-items: center; gap: 12px; }
    .logo-badge {
      width: 44px;
      height: 44px;
      border-radius: 10px;
      background: var(--blue);
      display: flex;
      align-items: center;
      justify-content: center;
      color: #FFFFFF;
      font-size: 20px;
      font-weight: 800;
    }
    .workshop-seal {
      display: flex;
      align-items: center;
      gap: 10px;
      background: rgba(16, 185, 129, 0.1);
      border: 1px solid rgba(16, 185, 129, 0.3);
      padding: 6px 14px;
      border-radius: 8px;
      font-size: 11px;
      color: var(--emerald);
      font-weight: 600;
    }
    
    .hero-content {
      display: flex;
      justify-content: space-between;
      align-items: center;
      flex-wrap: wrap;
      gap: 20px;
    }
    .car-title { font-size: 22px; font-weight: 800; color: #FFFFFF; margin-bottom: 2px; }
    .car-vin { font-family: 'Plus Jakarta Sans', monospace; font-size: 12px; color: var(--text-muted); margin-bottom: 12px; }
    .telemetry-row { display: flex; flex-wrap: wrap; gap: 10px; }
    .telemetry-chip {
      background: #090D16;
      border: 1px solid var(--border);
      padding: 6px 12px;
      border-radius: 8px;
      font-size: 11px;
      color: var(--text-muted);
    }
    .telemetry-chip strong { color: var(--text); font-family: 'Plus Jakarta Sans', monospace; }

    /* Score Box */
    .gauge-wrapper { display: flex; align-items: center; gap: 14px; }
    .health-gauge {
      width: 72px;
      height: 72px;
      border-radius: 50%;
      border: 5px solid ${healthColor};
      display: flex;
      flex-direction: column;
      align-items: center;
      justify-content: center;
      background: #090D16;
    }
    .gauge-score { font-family: 'Plus Jakarta Sans', monospace; font-size: 20px; font-weight: 800; color: #FFFFFF; line-height: 1; }
    .gauge-label { font-size: 9px; color: var(--text-muted); margin-top: 2px; }

    /* Summary Card */
    .summary-card {
      background: #0D1527;
      border: 1px solid #1F2E47;
      border-radius: 12px;
      padding: 16px;
      margin-bottom: 24px;
    }
    .summary-title { font-size: 12px; font-weight: 700; color: var(--blue); margin-bottom: 6px; }
    .summary-text { font-size: 13px; line-height: 1.7; color: var(--text); }

    /* Matrix & Sections */
    .section-title { font-size: 16px; font-weight: 700; color: #FFFFFF; margin-bottom: 12px; display: flex; align-items: center; gap: 8px; }
    .matrix-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(220px, 1fr)); gap: 12px; margin-bottom: 24px; }
    .matrix-card {
      background: var(--surface-1);
      border: 1px solid var(--border);
      border-radius: 12px;
      padding: 14px;
    }
    .matrix-card.critical { border-color: rgba(239, 68, 68, 0.4); }
    .matrix-card.moderate { border-color: rgba(245, 158, 11, 0.4); }
    .matrix-card.passed { border-color: rgba(16, 185, 129, 0.4); }
    .matrix-badge { font-size: 10px; font-weight: 700; padding: 3px 8px; border-radius: 6px; margin-bottom: 8px; display: inline-block; }

    /* DTC Faults Grid */
    .fault-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(300px, 1fr)); gap: 14px; margin-bottom: 24px; }
    .fault-card {
      background: var(--surface-1);
      border: 1px solid var(--border);
      border-radius: 14px;
      padding: 16px;
    }
    .fault-header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 8px; }
    .dtc-code { font-family: 'Plus Jakarta Sans', monospace; font-size: 13px; font-weight: 700; color: var(--amber); background: #090D16; padding: 3px 8px; border-radius: 6px; border: 1px solid var(--border); }
    .fault-title { font-size: 14px; font-weight: 700; color: #FFFFFF; margin-bottom: 4px; }
    .fault-box { background: rgba(0,0,0,0.3); border-radius: 8px; padding: 10px; margin-top: 8px; font-size: 11px; }

    /* Spare Parts Grid */
    .parts-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(300px, 1fr)); gap: 14px; margin-bottom: 24px; }
    .part-card {
      background: var(--surface-1);
      border: 1px solid var(--border);
      border-radius: 14px;
      padding: 16px;
      display: flex;
      flex-direction: column;
      justify-content: space-between;
    }
    .part-visual-container {
      width: 100%;
      height: 120px;
      background: #090D16;
      border-radius: 10px;
      overflow: hidden;
      margin-bottom: 12px;
      border: 1px solid var(--border);
      display: flex;
      align-items: center;
      justify-content: center;
    }

    /* Checklist & Sign-off */
    .checklist-card { background: var(--surface-1); border: 1px solid var(--border); border-radius: 14px; padding: 18px; margin-bottom: 24px; }
    .check-step { display: flex; align-items: flex-start; gap: 10px; padding: 10px 0; border-bottom: 1px solid rgba(255,255,255,0.05); }
    .check-step:last-child { border-bottom: none; }
    .check-box { width: 16px; height: 16px; border: 1px solid #475569; border-radius: 4px; margin-top: 3px; shrink-0; }

    .signoff-box {
      margin-top: 30px;
      padding: 20px;
      background: #0B101D;
      border: 1px solid var(--border);
      border-radius: 14px;
      display: flex;
      justify-content: space-between;
      align-items: center;
      flex-wrap: wrap;
      gap: 16px;
    }
    .sign-line { border-bottom: 1px dashed var(--border); min-width: 160px; height: 24px; display: inline-block; }

    /* Print Styles */
    @media print {
      body { background: #fff !important; color: #0f172a !important; padding: 0 !important; }
      .top-actions { display: none !important; }
      .header-card, .matrix-card, .fault-card, .part-card, .checklist-card, .summary-card, .signoff-box {
        background: #fff !important;
        border: 1px solid #cbd5e1 !important;
        color: #0f172a !important;
        box-shadow: none !important;
      }
      .car-title, .fault-title, .section-title, h1, h2, h3, h4 { color: #0f172a !important; }
      .telemetry-chip, .dtc-code, .fault-box { background: #f8fafc !important; border-color: #e2e8f0 !important; color: #0f172a !important; }
      .part-visual-container { background: #f8fafc !important; border-color: #cbd5e1 !important; }
    }
  </style>
</head>
<body>
  <div class="container">
    <!-- Action Bar -->
    <div class="top-actions">
      <div>
        <span style="font-weight: 700; color: var(--blue);">كاشف الذكي (Kashif AI)</span>
        <span style="font-size: 11px; color: var(--text-muted); margin-right: 6px;">منظومة التشخيص الفني الرقمي</span>
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
            <h1 style="font-size: 18px; font-weight: 800; color: #fff;">مركز الفحص والتشخيص الفني المعتمد</h1>
            <p style="font-size: 11px; color: var(--text-muted);">تقرير فحص وتشخيص إلكتروني معتمد بالمصطلحات الفنية الميدانية</p>
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
          <div class="health-gauge">
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
        <span class="matrix-badge" style="background: rgba(239,68,68,0.15); color: var(--red);">أعطال حرجة (${safe.faultCategories.criticalFaults.length})</span>
        <div style="font-size: 11px; color: var(--text-muted);">
          ${
            report.faultCategories.criticalFaults.length === 0
              ? "لا توجد أعطال حرجة مسجلة"
              : report.faultCategories.criticalFaults
                  .map((f) => `<div style="margin-top: 4px; color: #fff;">• <strong>${f.code}</strong>: ${f.libyanTerm}</div>`)
                  .join("")
          }
        </div>
      </div>

      <div class="matrix-card moderate">
        <span class="matrix-badge" style="background: rgba(245,158,11,0.15); color: var(--amber);">أعطال متوسطة للصيانة (${safe.faultCategories.moderateFaults.length})</span>
        <div style="font-size: 11px; color: var(--text-muted);">
          ${
            report.faultCategories.moderateFaults.length === 0
              ? "لا توجد أعطال متوسطة"
              : report.faultCategories.moderateFaults
                  .map((f) => `<div style="margin-top: 4px; color: #fff;">• <strong>${f.code}</strong>: ${f.libyanTerm}</div>`)
                  .join("")
          }
        </div>
      </div>

      <div class="matrix-card passed">
        <span class="matrix-badge" style="background: rgba(16,185,129,0.15); color: var(--emerald);">أنظمة سليمة واجتازت الفحص (${safe.passedSystems.length})</span>
        <div style="font-size: 11px; color: var(--text-muted);">
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
            return `
        <div class="fault-card">
          <div class="fault-header">
            <span class="dtc-code">${f.code}</span>
            <span style="font-size: 11px; font-weight: 600; color: var(--blue); background: rgba(59,130,246,0.1); padding: 3px 6px; border-radius: 4px;">
              ${f.moduleNameArabic || f.module}
            </span>
          </div>
          <div class="fault-title">${f.libyanTerm}</div>
          <p style="font-size: 11px; color: var(--text-muted);">${f.standardArabicDescription}</p>

          <div class="fault-box">
            <strong style="color: var(--amber); display: block; margin-bottom: 2px;">الأعراض الملاحظة:</strong>
            ${f.driverSymptoms.map((s) => `• ${s}`).join("<br>")}
          </div>

          <div style="background: rgba(15,23,42,0.9); border: 1px dashed rgba(59,130,246,0.4); padding: 8px 10px; border-radius: 8px; margin-top: 8px; font-size: 11px;">
            <div style="color: #60A5FA; font-weight: bold; margin-bottom: 3px;">⚡ مخطط الحساس والفيوز (Pinout & Fuse):</div>
            <div style="color: #E2E8F0; margin-bottom: 2px;">📍 <strong>موقع الحساس:</strong> ${elec.sensorLocation.areaName}</div>
            <div style="color: #FCD34D; margin-bottom: 2px;">🔌 <strong>الفيوز المخصص:</strong> ${elec.fuseInfo.fuseNumber} (${elec.fuseInfo.rating}) - ${elec.fuseInfo.boxLocation}</div>
            <div style="color: #A7F3D0;">🔋 <strong>فحص الأفوميتر:</strong> ${elec.multimeterTest.powerPin} | ${elec.multimeterTest.groundPin}</div>
          </div>

          <div style="margin-top: 8px; font-size: 11px; color: #E2E8F0;">
            <strong style="color: var(--emerald);">توجيه الفني:</strong> ${f.recommendedAction}
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
              <span style="font-size: 11px; color: var(--blue); font-weight: 600;">منظومة ${p.diagramCategory}</span>
              <span style="font-size: 10px; font-family: monospace; color: var(--amber);">كود: ${p.relatedCode}</span>
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

            <div style="font-size: 14px; font-weight: 700; color: #fff; margin-bottom: 2px;">${p.partNameLibyan}</div>
            <div style="font-size: 11px; color: var(--text-muted); margin-bottom: 8px;">${p.partNameStandardArabic}</div>

            <div style="background: #090D16; padding: 8px 10px; border-radius: 8px; border: 1px solid var(--border); margin-bottom: 8px;">
              <div style="font-size: 10px; color: var(--text-muted);">رقم القطعة الأصلي (OEM):</div>
              <div style="font-family: monospace; font-size: 12px; font-weight: 700; color: var(--amber);">${p.oemPartNumber}</div>
            </div>

            ${
              p.aftermarketReplacements.length > 0
                ? `<div style="font-size: 10px; color: var(--text-muted); margin-bottom: 8px;">
                    <strong>البدائل المعتمدة:</strong> ${p.aftermarketReplacements.join(", ")}
                   </div>`
                : ""
            }
          </div>

          <div style="border-top: 1px solid var(--border); padding-top: 8px; margin-top: 8px;">
            <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 4px;">
              <span style="font-size: 11px; color: var(--text-muted);">السعر التقديري في ليبيا:</span>
              <span style="font-family: monospace; font-size: 12px; font-weight: 700; color: var(--emerald);">${p.estimatedPriceRangeLYD ? `${p.estimatedPriceRangeLYD.min} - ${p.estimatedPriceRangeLYD.max} د.ل` : 'غير مسعّرة'}</span>
            </div>
            <div style="font-size: 10px; color: var(--text-muted);">${p.estimatedPriceRangeLYD?.marketNote || 'ما وصلنا سعر تقديري لهذي القطعة.'}</div>
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
            <div style="font-size: 12px; font-weight: 700; color: #fff; margin-bottom: 2px;">
              خطوة ${step.stepNumber}: ${step.targetComponent} <span style="font-size: 10px; font-weight: normal; color: var(--text-muted); margin-right: 6px;">(الأداة: ${step.toolNeeded})</span>
            </div>
            <div style="font-size: 11px; color: var(--text-muted);">${step.actionRequiredLibyan}</div>
          </div>
        </div>
      `
        )
        .join("")}
    </div>

    <!-- Official Workshop Sign-off -->
    <div class="signoff-box">
      <div>
        <div style="font-size: 13px; font-weight: 700; color: #fff; margin-bottom: 2px;">اعتماد وتوثيق مركز الصيانة</div>
        <p style="font-size: 11px; color: var(--text-muted);">تم فحص هذه المركبة واستخراج التقرير بواسطة فني معتمد</p>
      </div>

      <div style="display: flex; gap: 20px; font-size: 11px; color: var(--text-muted);">
        <div>التاريخ: <strong style="color: #fff;">${safe.generatedAt.slice(0, 10)}</strong></div>
        <div>توقيع الفاحص: <span class="sign-line"></span></div>
      </div>
    </div>

    <div style="text-align: center; margin-top: 20px; font-size: 10px; color: var(--text-muted);">
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
  };

  return (
    <div className="w-full workbench-panel rounded-2xl p-4 flex flex-col sm:flex-row items-start sm:items-center justify-between gap-3 no-print">
      <div>
        <h3 className="text-xs sm:text-sm font-bold text-white font-heading">
          خيارات التصدير والمشاركة الفنية
        </h3>
        <p className="text-[11px] text-slate-400">
          تصدير تقرير شامل مستقل (Standalone HTML) أو مشاركته مع العميل عبر واتساب
        </p>
      </div>

      <div className="flex items-center gap-2 flex-wrap w-full sm:w-auto">
        {/* Standalone HTML Export */}
        <button
          onClick={handleDownloadHtml}
          className="flex-1 sm:flex-initial flex items-center justify-center gap-1.5 bg-blue-600 hover:bg-blue-500 text-white px-3.5 py-1.5 rounded-lg text-xs font-bold transition-colors cursor-pointer"
          title="تنزيل ملف تقرير كامل ومستقل يعمل بدون إنترنت"
        >
          <Download className="w-3.5 h-3.5" />
          <span>تنزيل تقرير HTML</span>
        </button>

        {/* Print / Save PDF */}
        <button
          onClick={handlePrint}
          className="flex items-center justify-center gap-1.5 bg-slate-800 hover:bg-slate-700 text-slate-200 border border-slate-700 px-3 py-1.5 rounded-lg text-xs font-semibold transition-colors cursor-pointer"
        >
          <Printer className="w-3.5 h-3.5" />
          <span>طباعة / PDF</span>
        </button>

        {/* WhatsApp Share */}
        <button
          onClick={handleWhatsAppShare}
          className="flex items-center justify-center gap-1.5 bg-emerald-700 hover:bg-emerald-600 text-white px-3 py-1.5 rounded-lg text-xs font-semibold transition-colors cursor-pointer"
        >
          <Share2 className="w-3.5 h-3.5" />
          <span>واتساب</span>
        </button>
      </div>
    </div>
  );
};
