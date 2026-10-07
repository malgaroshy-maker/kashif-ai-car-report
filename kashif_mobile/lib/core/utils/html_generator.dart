import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:open_filex/open_filex.dart';
import '../../data/models/diagnostic_report.dart';
import '../../data/storage/hive_storage.dart';
import '../../data/models/report_sections_config.dart';
import '../../data/repositories/part_number_resolver.dart';
import '../theme/colors.dart';
import '../theme/typography.dart';
import 'web_downloader.dart';
import 'report_sanitizer.dart';
import 'report_qr_helper.dart';

class KashifHtmlGenerator {
  // HTML escape helper
  static String esc(String? s) {
    if (s == null) return '';
    return s
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;')
        .replaceAll("'", '&#39;');
  }

  /// Generates a standalone, fully self-contained HTML report with offline styling
  /// Generates a standalone, fully self-contained HTML report with offline styling
  static String buildHtml(
    DiagnosticReport report, {
    String? iconBase64,
    bool forPrint = false,
    ReportSectionsConfig? sectionsConfig,
  }) {
    final config = sectionsConfig ?? KashifStorage.reportSectionsConfig;
    final v = report.vehicle;
    final summary = report.summary;
    final workshopName = KashifStorage.workshopName;
    final workshopPhone = KashifStorage.workshopPhone;

    final qrSvg = ReportQrHelper.generateQrSvg(
      ReportQrHelper.buildQrInspectionSummary(report),
      size: 125,
    );

    final technicianName =
        (workshopName.trim().isNotEmpty &&
            workshopName.trim() != 'ورشة الفحص الفني')
        ? workshopName.trim()
        : '';
    final technicianPhone = workshopPhone.trim();

    final headerTechInfo = [
      if (technicianName.isNotEmpty)
        '<div class="workshop-name">${esc(technicianName)}</div>',
      if (technicianPhone.isNotEmpty)
        '<div class="workshop-phone">هاتف: <span dir="ltr">${esc(technicianPhone)}</span></div>',
    ].join('\n');

    final score = summary.overallHealthScore;
    final healthColor = score >= 80
        ? '#2E9E5B'
        : score >= 50
        ? '#F2C200'
        : '#DE3B2F';

    final critFaults = report.criticalFaults;
    final modFaults = report.moderateFaults;
    final histFaults = report.historyFaults;
    final allFaults = [...critFaults, ...modFaults, ...histFaults];
    final multiCauseFaults = allFaults.where((f) => f.rootCauses.length > 1).toList();
    final passedSystems = report.soundSystems;
    final spareParts = PartNumberResolver.enrichList(report.spareParts, vehicle: report.vehicle);
    final checklist = report.checklist;

    return '''<!DOCTYPE html>
<html lang="ar" dir="rtl">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>تقرير فحص فني - ${esc(v.make)} ${esc(v.model)} (${esc(v.year)})</title>
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=Readex+Pro:wght@300;400;500;600;700;800&display=swap" rel="stylesheet">
  <style>
    :root {
      --amp-10: #DE3B2F;
      --amp-20: #F2C200;
      --amp-30: #2E9E5B;
      --amp-25: #C8CBC5;
      --amp-15: #2E7FC4;
      --bg: #F4F6F9;
      --card-bg: #FFFFFF;
      --card-inner: #F8FAFC;
      --text: #0F172A;
      --text-muted: #475569;
      --border: #CBD5E1;
      --gold: #D4AF37;
    }
    @media (prefers-color-scheme: dark) {
      :root {
        --bg: #070E1E;
        --card-bg: #0F172A;
        --card-inner: #131E33;
        --text: #F8FAFC;
        --text-muted: #94A3B8;
        --border: #1E293B;
      }
    }
    * { box-sizing: border-box; margin: 0; padding: 0; }
    body {
      font-family: 'Readex Pro', -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Cairo", "Tahoma", sans-serif;
      background: var(--bg);
      color: var(--text);
      line-height: 1.6;
      padding: 16px;
      -webkit-font-smoothing: antialiased;
    }
    .container { max-width: 900px; margin: 0 auto; }
    .card {
      background: var(--card-bg);
      border: 1px solid var(--border);
      border-radius: 6px;
      padding: 16px;
      margin-bottom: 16px;
    }
    .header-bar {
      display: flex;
      justify-content: space-between;
      align-items: center;
      border-bottom: 2px solid var(--border);
      padding-bottom: 12px;
      margin-bottom: 14px;
    }
    .header-brand {
      display: flex;
      align-items: center;
      gap: 12px;
    }
    .brand-text {
      text-align: left;
    }
    .brand-sub {
      font-size: 10px;
      color: var(--text-muted);
      margin-top: 2px;
    }
    .header-logo {
      width: 48px;
      height: 48px;
      border-radius: 50%;
      border: 2px solid #D4AF37;
      box-shadow: 0 2px 8px rgba(212, 175, 55, 0.25);
      object-fit: cover;
    }
    .workshop-name { font-size: 17px; font-weight: 800; color: var(--text); }
    .workshop-phone { font-size: 13px; color: var(--text-muted); font-family: monospace; }
    .brand-badge {
      background: #0F172A;
      color: #fff;
      padding: 4px 10px;
      border-radius: 4px;
      border: 1px solid #D4AF37;
      font-weight: 700;
      font-size: 13px;
    }
    .vehicle-specs-card {
      background: var(--card-inner);
      border: 1px solid var(--border);
      border-radius: 6px;
      padding: 12px 16px;
      margin: 12px 0 16px 0;
    }
    .vehicle-specs-title {
      font-size: 13.5px;
      font-weight: 800;
      color: var(--text);
      margin-bottom: 8px;
    }
    .vehicle-specs-grid {
      display: grid;
      grid-template-columns: repeat(auto-fit, minmax(260px, 1fr));
      gap: 6px 16px;
      font-size: 12.5px;
    }
    .spec-row {
      display: flex;
      align-items: center;
      gap: 6px;
    }
    .spec-bullet {
      color: var(--amp-15);
      font-size: 9px;
      line-height: 1;
    }
    .spec-label {
      font-weight: 700;
      color: var(--text-muted);
      min-width: 75px;
    }
    .spec-value {
      color: var(--text);
    }
    .font-bold {
      font-weight: 800;
    }
    .vin-code {
      font-family: monospace;
      font-weight: bold;
      color: var(--amp-15);
      background: rgba(46,127,196,0.12);
      padding: 2px 6px;
      border-radius: 3px;
    }
    .score-box {
      display: flex;
      align-items: center;
      gap: 16px;
      background: var(--card-inner);
      border: 1px solid var(--border);
      padding: 14px;
      border-radius: 6px;
      margin-top: 12px;
    }
    .score-circle {
      width: 72px;
      height: 72px;
      border-radius: 50%;
      border: 5px solid $healthColor;
      display: flex;
      flex-direction: column;
      align-items: center;
      justify-content: center;
      font-weight: 900;
      font-size: 20px;
      flex-shrink: 0;
    }
    .score-label { font-size: 10px; font-weight: normal; }
    .summary-heading {
      font-weight: 800;
      font-size: 12.5px;
      color: var(--amp-15);
      margin-bottom: 3px;
    }
    .summary-text { font-size: 13px; line-height: 1.6; color: var(--text); }
    .section-title {
      font-size: 15px;
      font-weight: 800;
      margin: 18px 0 10px 0;
      padding-bottom: 4px;
      border-bottom: 1px solid var(--border);
      display: flex;
      align-items: center;
      gap: 8px;
    }
    .badge {
      display: inline-block;
      padding: 2px 8px;
      border-radius: 3px;
      font-size: 11px;
      font-weight: bold;
      color: #fff;
    }
    .badge-crit { background: var(--amp-10); }
    .badge-mod { background: var(--amp-20); color: #000; }
    .badge-hist { background: var(--amp-25); color: #000; }
    .badge-pass { background: var(--amp-30); }
    .code-row {
      border: 1px solid var(--border);
      border-right: 4px solid var(--border);
      background: var(--card-bg);
      padding: 12px;
      margin-bottom: 8px;
      border-radius: 4px;
    }
    .code-row.crit { border-right-color: var(--amp-10); }
    .code-row.mod { border-right-color: var(--amp-20); }
    .code-row.hist { border-right-color: var(--amp-25); }
    .code-dtc {
      font-family: monospace;
      font-weight: 900;
      font-size: 14px;
      padding: 2px 6px;
      background: rgba(0,0,0,0.06);
      border-radius: 3px;
      display: inline-block;
      color: var(--text);
    }
    .code-term { font-size: 14px; font-weight: 800; margin: 4px 0; color: var(--text); }
    .code-desc { font-size: 12px; color: var(--text-muted); font-family: monospace; }
    .action-box {
      margin-top: 6px;
      padding: 6px 10px;
      background: rgba(46,158,91,0.08);
      border-right: 2px solid var(--amp-30);
      font-size: 12px;
      font-weight: 600;
      color: var(--text);
    }
    table { width: 100%; border-collapse: collapse; margin-top: 8px; font-size: 12px; }
    th, td { padding: 8px 10px; text-align: right; border: 1px solid var(--border); color: var(--text); }
    th { background: rgba(0,0,0,0.04); font-weight: 800; }
    .passed-grid {
      display: grid;
      grid-template-columns: repeat(auto-fill, minmax(180px, 1fr));
      gap: 8px;
      margin-top: 8px;
    }
    .passed-item {
      padding: 8px;
      border: 1px solid var(--border);
      border-right: 3px solid var(--amp-30);
      background: rgba(46,158,91,0.06);
      border-radius: 3px;
      font-size: 12px;
      font-weight: 600;
      color: var(--text);
    }
    .qr-verification-card {
      display: flex;
      align-items: center;
      gap: 16px;
      background: var(--card-bg);
      border: 1px solid var(--border);
      border-right: 4px solid #D4AF37;
      border-radius: 6px;
      padding: 14px 16px;
      margin-top: 18px;
    }
    .qr-svg-container {
      flex-shrink: 0;
      background: #FFFFFF !important;
      padding: 6px;
      border-radius: 6px;
      border: 1px solid rgba(0,0,0,0.12);
      display: flex;
      align-items: center;
      justify-content: center;
    }
    .qr-info {
      flex: 1;
    }
    .qr-heading {
      font-size: 13.5px;
      font-weight: 800;
      color: var(--text);
      margin-bottom: 4px;
    }
    .qr-subtext {
      font-size: 11.5px;
      color: var(--text-muted);
      line-height: 1.5;
      margin-bottom: 4px;
    }
    .qr-specs {
      font-size: 10px;
      color: #D4AF37;
      font-weight: 700;
      letter-spacing: 0.5px;
    }
    .footer {
      text-align: center;
      font-size: 11px;
      color: var(--text-muted);
      margin-top: 24px;
      padding-top: 12px;
      border-top: 1px solid var(--border);
    }
    @media (max-width: 500px) {
      .header-bar {
        flex-direction: column-reverse;
        align-items: flex-start;
        gap: 10px;
      }
      .qr-verification-card {
        flex-direction: column;
        text-align: center;
      }
    }
    /* Specific overrides for Dark Mode */
    @media (prefers-color-scheme: dark) {
      .vehicle-specs-card {
        background: #111A2E !important;
        border-color: #1E293B !important;
      }
      .vehicle-specs-title {
        color: #F8FAFC !important;
      }
      .spec-label {
        color: #94A3B8 !important;
      }
      .spec-value {
        color: #FFFFFF !important;
      }
      .score-box {
        background: #111A2E !important;
        border-color: #1E293B !important;
      }
      .summary-heading {
        color: #60A5FA !important;
      }
      .summary-text {
        color: #F1F5F9 !important;
      }
      .code-row {
        background: #0F172A !important;
        border-color: #1E293B !important;
      }
      .code-dtc {
        background: rgba(255, 255, 255, 0.08) !important;
        color: #F8FAFC !important;
      }
      .code-term {
        color: #FFFFFF !important;
      }
      .code-desc {
        color: #94A3B8 !important;
      }
      th {
        background: #162032 !important;
        color: #F8FAFC !important;
      }
      td {
        color: #F1F5F9 !important;
        border-color: #1E293B !important;
      }
      .action-box {
        background: rgba(46, 158, 91, 0.14) !important;
        color: #4ADE80 !important;
      }
      .passed-item {
        background: rgba(46, 158, 91, 0.12) !important;
        color: #4ADE80 !important;
      }
    }
    /* Comprehensive Print & PDF Formatting Rules */
    @media print {
      @page {
        size: A4;
        margin: 8mm 10mm;
      }
      :root {
        --bg: #FFFFFF !important;
        --card-bg: #FFFFFF !important;
        --card-inner: #F8FAFC !important;
        --text: #0F172A !important;
        --text-muted: #475569 !important;
        --border: #CBD5E1 !important;
      }
      body {
        background: #FFFFFF !important;
        color: #0F172A !important;
        padding: 0 !important;
        font-size: 10.5px !important;
        line-height: 1.4 !important;
        -webkit-print-color-adjust: exact !important;
        print-color-adjust: exact !important;
      }
      .container {
        max-width: 100% !important;
        width: 100% !important;
        margin: 0 !important;
      }
      .card {
        border-color: #CBD5E1 !important;
        padding: 8px 12px !important;
        margin-bottom: 8px !important;
        page-break-inside: avoid;
        break-inside: avoid;
      }
      .header-bar {
        padding-bottom: 8px !important;
        margin-bottom: 8px !important;
      }
      .workshop-name { font-size: 15px !important; color: #0F172A !important; }
      .vehicle-specs-card {
        background: #F8FAFC !important;
        border: 1px solid #CBD5E1 !important;
        padding: 6px 10px !important;
        margin: 6px 0 8px 0 !important;
      }
      .vehicle-specs-title {
        color: #0F172A !important;
        font-size: 11.5px !important;
        margin-bottom: 4px !important;
      }
      .spec-label { color: #475569 !important; }
      .spec-value { color: #0F172A !important; }
      .score-box {
        padding: 6px 10px !important;
        margin-top: 6px !important;
        background: #F8FAFC !important;
      }
      .score-circle {
        width: 52px !important;
        height: 52px !important;
        font-size: 16px !important;
        border-width: 4px !important;
      }
      .summary-text { font-size: 11.5px !important; color: #0F172A !important; }
      .section-title {
        margin: 8px 0 4px 0 !important;
        font-size: 12px !important;
      }
      .code-row {
        padding: 6px 8px !important;
        margin-bottom: 5px !important;
        background: #FFFFFF !important;
        page-break-inside: avoid;
        break-inside: avoid;
      }
      .code-dtc { color: #0F172A !important; font-size: 12px !important; }
      .code-term { font-size: 12px !important; color: #0F172A !important; }
      .code-desc { font-size: 10.5px !important; color: #475569 !important; }
      .action-box {
        padding: 3px 6px !important;
        font-size: 10px !important;
        color: #0F172A !important;
      }
      table {
        margin-top: 4px !important;
        font-size: 10px !important;
        page-break-inside: avoid;
        break-inside: avoid;
      }
      th, td {
        padding: 4px 6px !important;
        color: #0F172A !important;
      }
      th {
        background: #F1F5F9 !important;
      }
      .passed-grid {
        gap: 5px !important;
        margin-top: 4px !important;
      }
      .passed-item {
        padding: 4px 6px !important;
        font-size: 10px !important;
        color: #0F172A !important;
      }
      .qr-verification-card {
        padding: 6px 10px !important;
        margin-top: 8px !important;
        background: #FFFFFF !important;
        page-break-inside: avoid;
        break-inside: avoid;
      }
      .footer {
        margin-top: 8px !important;
        font-size: 9px !important;
        color: #64748B !important;
      }
    }
    ${forPrint ? '''
    :root {
      --bg: #FFFFFF !important;
      --card-bg: #FFFFFF !important;
      --card-inner: #F8FAFC !important;
      --text: #0F172A !important;
      --text-muted: #475569 !important;
      --border: #CBD5E1 !important;
    }
    body {
      background: #FFFFFF !important;
      color: #0F172A !important;
      padding: 0 !important;
      font-size: 10.5px !important;
      line-height: 1.4 !important;
    }
    .card {
      background: #FFFFFF !important;
      border-color: #CBD5E1 !important;
      page-break-inside: avoid;
      break-inside: avoid;
    }
    .vehicle-specs-card, .score-box {
      background: #F8FAFC !important;
      border-color: #CBD5E1 !important;
    }
    .vehicle-specs-title, .spec-value, .summary-text, .code-term, .code-dtc, th, td {
      color: #0F172A !important;
    }
    .spec-label, .code-desc {
      color: #475569 !important;
    }
    ''' : ''}
  </style>
</head>
<body>
  <div class="container">
    <div class="card">
      <div class="header-bar">
        <div>
          $headerTechInfo
        </div>
        <div class="header-brand">
          <div class="brand-text">
            <div class="brand-badge">Flow Cars | فحص وتشخيص</div>
            <div class="brand-sub">منظومة كاشف الذكي للكشف عن الأعطال</div>
          </div>
          ${iconBase64 != null && iconBase64.isNotEmpty ? '''
          <img src="data:image/png;base64,$iconBase64" class="header-logo" alt="Flow Cars Logo" />
          ''' : ''}
        </div>
      </div>

      <div class="vehicle-specs-card">
        <div class="vehicle-specs-title">بيانات المركبة:</div>
        <div class="vehicle-specs-grid">
          <div class="spec-row">
            <span class="spec-bullet">■</span>
            <span class="spec-label">السيارة:</span>
            <span class="spec-value font-bold">${esc(v.formattedTitle)}</span>
          </div>
          ${v.cleanVin.isNotEmpty ? '''
          <div class="spec-row">
            <span class="spec-bullet">■</span>
            <span class="spec-label">رقم الهيكل:</span>
            <span class="spec-value vin-code">${esc(v.cleanVin)}</span>
          </div>
          ''' : ''}
          ${v.formattedEngine.isNotEmpty ? '''
          <div class="spec-row">
            <span class="spec-bullet">■</span>
            <span class="spec-label">المحرك:</span>
            <span class="spec-value">${esc(v.formattedEngine)}</span>
          </div>
          ''' : ''}
          ${v.formattedTransmission.isNotEmpty ? '''
          <div class="spec-row">
            <span class="spec-bullet">■</span>
            <span class="spec-label">الكمبيو:</span>
            <span class="spec-value">${esc(v.formattedTransmission)}</span>
          </div>
          ''' : ''}
          ${v.formattedMileage.isNotEmpty ? '''
          <div class="spec-row">
            <span class="spec-bullet">■</span>
            <span class="spec-label">قراءة العداد:</span>
            <span class="spec-value">${esc(v.formattedMileage)}</span>
          </div>
          ''' : ''}
          ${report.generatedAt.isNotEmpty ? '''
          <div class="spec-row">
            <span class="spec-bullet">■</span>
            <span class="spec-label">تاريخ الفحص:</span>
            <span class="spec-value">${esc(report.generatedAt.split('T').first)}</span>
          </div>
          ''' : ''}
        </div>
      </div>

      <div class="score-box">
        <div class="score-circle">
          $score%
          <span class="score-label">الجاهزية</span>
        </div>
        <div style="flex: 1;">
          <div style="font-weight: 800; font-size: 14px; margin-bottom: 4px;">الحالة: ${esc(summary.severityStatus)}</div>
          ${config.includeTechnicalAssessment ? '''
          <div class="summary-heading">خلاصة تقييم السيارة:</div>
          <div class="summary-text">${esc(ReportSanitizer.clean(summary.briefSummaryArabic))}</div>
          ''' : ''}
        </div>
      </div>
    </div>

    ${config.includeFaultsTable && critFaults.isNotEmpty ? '''
    <div class="card">
      <div class="section-title">
        <span class="badge badge-crit">أعطال حرجة (${critFaults.length})</span>
        <span>تتطلب تدخل فوري</span>
      </div>
      ${critFaults.map((f) => '''
      <div class="code-row crit">
        <span class="code-dtc">${esc(f.code)}</span>
        <span style="font-size: 11px; color: var(--text-muted); margin-right: 6px;">${esc(f.moduleNameArabic.isNotEmpty ? f.moduleNameArabic : f.module)}</span>
        <div class="code-term">${esc(ReportSanitizer.clean(f.libyanTerm))}</div>
        <div class="code-desc">${esc(f.standardDescriptionEn)}</div>
        <div class="action-box">🛠️ التوجيه: ${esc(ReportSanitizer.clean(f.recommendedAction))}</div>
      </div>
      ''').join('')}
    </div>
    ''' : ''}

    ${config.includeFaultsTable && modFaults.isNotEmpty ? '''
    <div class="card">
      <div class="section-title">
        <span class="badge badge-mod">أعطال متوسطة (${modFaults.length})</span>
        <span>صيانة مجدولة</span>
      </div>
      ${modFaults.map((f) => '''
      <div class="code-row mod">
        <span class="code-dtc">${esc(f.code)}</span>
        <span style="font-size: 11px; color: var(--text-muted); margin-right: 6px;">${esc(f.moduleNameArabic.isNotEmpty ? f.moduleNameArabic : f.module)}</span>
        <div class="code-term">${esc(ReportSanitizer.clean(f.libyanTerm))}</div>
        <div class="code-desc">${esc(f.standardDescriptionEn)}</div>
        <div class="action-box">🛠️ التوجيه: ${esc(ReportSanitizer.clean(f.recommendedAction))}</div>
      </div>
      ''').join('')}
    </div>
    ''' : ''}

    ${config.includeFaultsTable && histFaults.isNotEmpty ? '''
    <div class="card">
      <div class="section-title">
        <span class="badge badge-hist">أعطال الذاكرة (${histFaults.length})</span>
        <span>أكواد مسجلة سابقاً</span>
      </div>
      ${histFaults.map((f) => '''
      <div class="code-row hist">
        <span class="code-dtc">${esc(f.code)}</span>
        <span style="font-size: 11px; color: var(--text-muted); margin-right: 6px;">${esc(f.moduleNameArabic.isNotEmpty ? f.moduleNameArabic : f.module)}</span>
        <div class="code-term">${esc(ReportSanitizer.clean(f.libyanTerm))}</div>
        <div class="code-desc">${esc(f.standardDescriptionEn)}</div>
      </div>
      ''').join('')}
    </div>
    ''' : ''}

    ${config.includePassedSystems && passedSystems.isNotEmpty ? '''
    <div class="card">
      <div class="section-title">
        <span class="badge badge-pass">الأنظمة السليمة (${passedSystems.length})</span>
        <span>لا توجد بها أعطال مسجلة</span>
      </div>
      <div class="passed-grid">
        ${passedSystems.map((s) => '''
        <div class="passed-item">✓ ${esc(ReportSanitizer.clean(s))}</div>
        ''').join('')}
      </div>
    </div>
    ''' : ''}

    ${config.includeSpareParts && spareParts.isNotEmpty ? '''
    <div class="card">
      <div class="section-title">
        <span>📦 قطع الغيار المطلوبة (${spareParts.length})</span>
      </div>
      <table>
        <thead>
          <tr>
            <th>القطعة (بالمصطلح الليبي)</th>
            <th>الاسم بالإنجليزية</th>
            <th>رقم الوكالة (OEM)</th>
            <th>السعر التقديري (د.ل)</th>
            <th>البدائل</th>
          </tr>
        </thead>
        <tbody>
          ${spareParts.map((p) {
            final rawOem = p.oemPartNumber?.trim() ?? '';
            final oemDisplay = (rawOem.isEmpty || rawOem.toUpperCase() == 'N/A' || rawOem == 'null') ? 'أصلي وكالة' : rawOem;
            return '''
          <tr>
            <td><strong>${esc(ReportSanitizer.clean(p.partNameLibyan))}</strong></td>
            <td>${esc(p.partNameEnglish)}</td>
            <td style="font-family: monospace; font-weight: bold;">${esc(oemDisplay)}</td>
            <td style="font-weight: bold; color: var(--amp-30);">${p.estimatedPriceRangeLYD != null ? '${p.estimatedPriceRangeLYD!.min.toInt()} - ${p.estimatedPriceRangeLYD!.max.toInt()} د.ل' : 'غير مسعر'}</td>
            <td>${esc(p.aftermarketReplacements.join(', '))}</td>
          </tr>
          ''';
          }).join('')}
        </tbody>
      </table>
    </div>
    ''' : ''}

    ${config.includeProbabilitiesTable && multiCauseFaults.isNotEmpty ? '''
    <div class="card">
      <div class="section-title">
        <span>🔀 جدول احتمالات ومسببات الأعطال (فحص متسلسل)</span>
      </div>
      <table>
        <thead>
          <tr>
            <th style="width: 14%; text-align: center;">الكود</th>
            <th style="width: 28%;">وصف العطل بالليبي</th>
            <th>الاحتمالات وسلسلة الفحص المقترحة</th>
          </tr>
        </thead>
        <tbody>
          ${multiCauseFaults.map((f) {
            final causesChain = f.rootCauses.asMap().entries.map((e) {
              final cleanCause = esc(ReportSanitizer.clean(e.value));
              return '<label style="display: inline-flex; align-items: center; gap: 6px; margin: 2px 14px 2px 0; cursor: pointer;"><input type="checkbox" style="accent-color: var(--amp-30); width: 14px; height: 14px; cursor: pointer; margin: 0;" /> <span><strong>${e.key + 1}.</strong> $cleanCause</span></label>';
            }).join('');
            return '''
            <tr>
              <td style="font-family: monospace; font-weight: bold; text-align: center; color: var(--text); vertical-align: middle;">${esc(f.code)}</td>
              <td style="vertical-align: middle;"><strong>${esc(ReportSanitizer.clean(f.libyanTerm))}</strong></td>
              <td style="color: var(--text); line-height: 1.6; vertical-align: middle;"><div style="display: flex; flex-wrap: wrap; align-items: center; gap: 4px 10px;">$causesChain</div></td>
            </tr>
            ''';
          }).join('')}
        </tbody>
      </table>
    </div>
    ''' : ''}

    ${config.includeChecklist && checklist.isNotEmpty ? '''
    <div class="card">
      <div class="section-title">
        <span>📋 قائمة خطوات الفحص الفني (خطوات المعاينة)</span>
      </div>
      <table>
        <thead>
          <tr>
            <th>#</th>
            <th>الإجراء المطلوب</th>
            <th>التفاصيل الفنية</th>
            <th>العدة المطلوبة</th>
          </tr>
        </thead>
        <tbody>
          ${checklist.map((c) => '''
          <tr>
            <td style="text-align: center; font-weight: bold;">${c.stepNumber}</td>
            <td><strong>${esc(ReportSanitizer.clean(c.actionTitle))}</strong></td>
            <td>${esc(ReportSanitizer.clean(c.actionDescriptionLibyan))}</td>
            <td>${esc(ReportSanitizer.clean(c.toolingNeeded))}</td>
          </tr>
          ''').join('')}
        </tbody>
      </table>
    </div>
    ''' : ''}

    <div style="display: flex; justify-content: space-between; align-items: center; padding: 12px 16px; background: var(--card-bg); border: 1px solid var(--border); border-radius: 6px; margin-top: 16px; font-size: 13px;">
      <div><strong>اسم الفني:</strong> ${technicianName.isNotEmpty ? esc(technicianName) : 'فني فحص معتمد'}</div>
      <div><strong>رقم الهاتف:</strong> <span dir="ltr">${technicianPhone.isNotEmpty ? esc(technicianPhone) : '—'}</span></div>
      <div><strong>التوقيع / الختم:</strong> ____________________</div>
    </div>

    <div class="qr-verification-card">
      <div class="qr-svg-container">
        $qrSvg
      </div>
      <div class="qr-info">
        <div class="qr-heading">رمز التحقق الذكي والمشاركة (QR Code)</div>
        <div class="qr-subtext">امسح الكود بكاميرا أي هاتف محمول لقراءة وتأكيد ملخص الفحص الفني وحالة الأعطال فوراً دون الحاجة إلى إنترنت.</div>
        <div class="qr-specs">Flow Cars Certified Diagnostic Summary</div>
      </div>
    </div>

    <div class="footer">
      تم إنشاء هذا التقرير الفني المعتمد آلياً بواسطة نظام <strong>Flow Cars</strong>
    </div>
  </div>
</body>
</html>''';
  }

  /// Saves the HTML report to device Downloads/Documents and shows action dialog
  static Future<void> generateAndSave(
    BuildContext context,
    DiagnosticReport report,
  ) async {
    try {
      String? iconBase64;
      try {
        final iconByteData = await rootBundle.load('assets/images/app_icon.png');
        iconBase64 = base64Encode(iconByteData.buffer.asUint8List());
      } catch (_) {}

      final htmlContent = buildHtml(report, iconBase64: iconBase64);
      final cleanMake = report.vehicle.make.replaceAll(
        RegExp(r'[^\w\u0621-\u064A]'),
        '_',
      );
      final cleanModel = report.vehicle.model.replaceAll(
        RegExp(r'[^\w\u0621-\u064A]'),
        '_',
      );
      final filename =
          'تقرير_flowcars_${cleanMake}_${cleanModel}_${DateTime.now().millisecondsSinceEpoch}.html';

      if (kIsWeb) {
        final bytes = utf8.encode(htmlContent);
        downloadWebFile(bytes, filename, 'text/html;charset=utf-8');

        if (!context.mounted) return;

        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (ctx) {
            final isDark = Theme.of(ctx).brightness == Brightness.dark;
            return SafeArea(
              child: SingleChildScrollView(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: isDark
                        ? KashifColors.darkBoard
                        : KashifColors.lightBoard,
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                    border: Border.all(
                      color: isDark
                          ? KashifColors.darkBorder
                          : KashifColors.lightBorder,
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: KashifColors.fuse30ATab.withValues(
                                alpha: 0.15,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.check_circle_rounded,
                              color: KashifColors.fuse30ATab,
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'تم تنزيل تقرير HTML بنجاح',
                                  style: KashifTypography.arabic(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w800,
                                    color: isDark
                                        ? KashifColors.darkTextPrimary
                                        : KashifColors.lightTextPrimary,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'تم حفظ الملف في مجلد التنزيلات (Downloads) ويعمل بدون إنترنت.',
                                  style: KashifTypography.arabic(
                                    fontSize: 12,
                                    color: isDark
                                        ? KashifColors.darkTextMuted
                                        : KashifColors.lightTextMuted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isDark
                              ? KashifColors.darkCell
                              : KashifColors.lightCell,
                          borderRadius: BorderRadius.circular(2),
                        ),
                        child: Text(
                          filename,
                          style: KashifTypography.mono(fontSize: 12),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isDark
                              ? KashifColors.fuse15AInkDark
                              : KashifColors.fuse15AInkLight,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        onPressed: () {
                          Navigator.pop(ctx);
                          downloadWebFile(
                            bytes,
                            filename,
                            'text/html;charset=utf-8',
                          );
                        },
                        icon: const Icon(Icons.download_rounded, size: 20),
                        label: Text(
                          'إعادة تنزيل الملف',
                          style: KashifTypography.arabic(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
        return;
      }

      // Determine directory to save: Try public downloads, fallback to external or app documents
      Directory? dir;
      if (Platform.isAndroid) {
        try {
          final publicDownload = Directory('/storage/emulated/0/Download');
          if (await publicDownload.exists()) {
            final testFile = File('${publicDownload.path}/.test_probe');
            await testFile.writeAsString('probe');
            await testFile.delete();
            dir = publicDownload;
          }
        } catch (_) {
          dir = null;
        }

        if (dir == null) {
          try {
            dir = await getExternalStorageDirectory();
          } catch (_) {}
        }
      }

      dir ??= await getApplicationDocumentsDirectory();

      final file = File('${dir.path}/$filename');
      await file.writeAsString(htmlContent);

      if (!context.mounted) return;

      // Show success modal with Open & Share options
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (ctx) {
          final isDark = Theme.of(ctx).brightness == Brightness.dark;
          return SafeArea(
            child: SingleChildScrollView(
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDark
                      ? KashifColors.darkBoard
                      : KashifColors.lightBoard,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                  border: Border.all(
                    color: isDark
                        ? KashifColors.darkBorder
                        : KashifColors.lightBorder,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: KashifColors.fuse30ATab.withValues(
                              alpha: 0.15,
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.check_circle_rounded,
                            color: KashifColors.fuse30ATab,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'تم تصدير تقرير HTML المستقل بنجاح',
                                style: KashifTypography.arabic(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                  color: isDark
                                      ? KashifColors.darkTextPrimary
                                      : KashifColors.lightTextPrimary,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'تم حفظ الملف في مجلد التنزيلات (يخدم بدون نت)',
                                style: KashifTypography.arabic(
                                  fontSize: 12,
                                  color: isDark
                                      ? KashifColors.darkTextMuted
                                      : KashifColors.lightTextMuted,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isDark
                            ? KashifColors.darkCell
                            : KashifColors.lightCell,
                        borderRadius: BorderRadius.circular(2),
                      ),
                      child: Text(
                        file.path,
                        style: KashifTypography.mono(fontSize: 11),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Button 1: Open in Browser
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isDark
                            ? KashifColors.fuse15AInkDark
                            : KashifColors.fuse15AInkLight,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      onPressed: () async {
                        Navigator.pop(ctx);
                        await OpenFilex.open(file.path);
                      },
                      icon: const Icon(Icons.open_in_browser_rounded, size: 20),
                      label: Text(
                        'فتح التقرير فوراً في المتصفح',
                        style: KashifTypography.arabic(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Button 2: Share file
                    OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: isDark
                            ? KashifColors.darkTextPrimary
                            : KashifColors.lightTextPrimary,
                        side: BorderSide(
                          color: isDark
                              ? KashifColors.darkBorder
                              : KashifColors.lightBorder,
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      onPressed: () async {
                        Navigator.pop(ctx);
                        await SharePlus.instance.share(
                          ShareParams(
                            files: [XFile(file.path, mimeType: 'text/html')],
                            text:
                                'تقرير فحص Flow Cars للسيارة ${report.vehicle.make} ${report.vehicle.model}',
                          ),
                        );
                      },
                      icon: const Icon(Icons.share_rounded, size: 20),
                      label: Text(
                        'مشاركة الملف (واتساب / بلوتوث / درايف)',
                        style: KashifTypography.arabic(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
          );
        },
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تعذر حفظ ملف الـ HTML: $e'),
          backgroundColor: Colors.red.shade800,
        ),
      );
    }
  }
}

typedef HtmlReportGenerator = KashifHtmlGenerator;
