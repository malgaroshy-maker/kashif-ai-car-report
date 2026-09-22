import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:open_filex/open_filex.dart';
import '../../data/models/diagnostic_report.dart';
import '../../data/storage/hive_storage.dart';
import '../theme/colors.dart';
import '../theme/typography.dart';

class KashifHtmlGenerator {
  /// Generates a standalone, fully self-contained HTML report with offline styling
  static String buildHtml(DiagnosticReport report) {
    final v = report.vehicle;
    final summary = report.summary;
    final workshopName = KashifStorage.workshopName;
    final workshopPhone = KashifStorage.workshopPhone;

    final score = summary.overallHealthScore;
    final healthColor = score >= 80
        ? '#2E9E5B'
        : score >= 50
            ? '#F2C200'
            : '#DE3B2F';

    // HTML escape helper
    String esc(String? s) {
      if (s == null) return '';
      return s
          .replaceAll('&', '&amp;')
          .replaceAll('<', '&lt;')
          .replaceAll('>', '&gt;')
          .replaceAll('"', '&quot;')
          .replaceAll("'", '&#39;');
    }

    final critFaults = report.criticalFaults;
    final modFaults = report.moderateFaults;
    final histFaults = report.historyFaults;
    final passedSystems = report.passedSystems;
    final spareParts = report.spareParts;
    final checklist = report.checklist;

    return '''<!DOCTYPE html>
<html lang="ar" dir="rtl">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1.0">
  <title>تقرير فحص فني - ${esc(v.make)} ${esc(v.model)} (${esc(v.year)})</title>
  <style>
    :root {
      --amp-10: #DE3B2F;
      --amp-20: #F2C200;
      --amp-30: #2E9E5B;
      --amp-25: #C8CBC5;
      --amp-15: #2E7FC4;
      --bg: #F4F6F9;
      --card-bg: #FFFFFF;
      --text: #1E252B;
      --text-muted: #586574;
      --border: #D2D9E2;
    }
    @media (prefers-color-scheme: dark) {
      :root {
        --bg: #0D1217;
        --card-bg: #151C24;
        --text: #EEF2F6;
        --text-muted: #8E9BAE;
        --border: #232E3B;
      }
    }
    * { box-sizing: border-box; margin: 0; padding: 0; }
    body {
      font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, "Cairo", "Tahoma", sans-serif;
      background: var(--bg);
      color: var(--text);
      line-height: 1.6;
      padding: 16px;
    }
    .container { max-width: 900px; margin: 0 auto; }
    .card {
      background: var(--card-bg);
      border: 1px solid var(--border);
      border-radius: 4px;
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
    .workshop-name { font-size: 18px; font-weight: 800; color: var(--text); }
    .workshop-phone { font-size: 13px; color: var(--text-muted); font-family: monospace; }
    .brand-badge {
      background: var(--amp-15);
      color: #fff;
      padding: 4px 10px;
      border-radius: 2px;
      font-weight: 700;
      font-size: 13px;
    }
    .vehicle-title { font-size: 20px; font-weight: 900; margin-bottom: 6px; }
    .vehicle-meta {
      display: flex;
      flex-wrap: wrap;
      gap: 12px;
      font-size: 12px;
      color: var(--text-muted);
    }
    .vin-code {
      font-family: monospace;
      font-weight: bold;
      color: var(--amp-15);
      background: rgba(46,127,196,0.1);
      padding: 2px 6px;
      border-radius: 2px;
    }
    .score-box {
      display: flex;
      align-items: center;
      gap: 16px;
      background: rgba(0,0,0,0.03);
      padding: 14px;
      border-radius: 4px;
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
    }
    .score-label { font-size: 10px; font-weight: normal; }
    .summary-text { font-size: 13px; line-height: 1.6; }
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
      border-radius: 2px;
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
      border-radius: 2px;
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
      border-radius: 2px;
      display: inline-block;
    }
    .code-term { font-size: 14px; font-weight: 800; margin: 4px 0; }
    .code-desc { font-size: 12px; color: var(--text-muted); font-family: monospace; }
    .action-box {
      margin-top: 6px;
      padding: 6px 10px;
      background: rgba(46,158,91,0.08);
      border-right: 2px solid var(--amp-30);
      font-size: 12px;
      font-weight: 600;
    }
    table { width: 100%; border-collapse: collapse; margin-top: 8px; font-size: 12px; }
    th, td { padding: 8px 10px; text-align: right; border: 1px solid var(--border); }
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
      background: rgba(46,158,91,0.05);
      border-radius: 2px;
      font-size: 12px;
      font-weight: 600;
    }
    .stamp-box {
      display: flex;
      justify-content: space-between;
      margin-top: 24px;
      padding: 16px;
      border: 1px dashed var(--border);
      border-radius: 4px;
    }
    .stamp-col { width: 45%; text-align: center; font-size: 12px; }
    .stamp-space { height: 48px; }
    .footer {
      text-align: center;
      font-size: 11px;
      color: var(--text-muted);
      margin-top: 24px;
      padding-top: 12px;
      border-top: 1px solid var(--border);
    }
    @media print {
      body { background: #fff; color: #000; padding: 0; }
      .card { border: none; padding: 0; }
    }
  </style>
</head>
<body>
  <div class="container">
    <div class="card">
      <div class="header-bar">
        <div>
          <div class="workshop-name">${esc(workshopName)}</div>
          <div class="workshop-phone">هاتف: ${esc(workshopPhone)}</div>
        </div>
        <div class="brand-badge">كاشف AI | فحص وتشخيص</div>
      </div>

      <div class="vehicle-title">${esc(v.make)} ${esc(v.model)} (${esc(v.year)})</div>
      <div class="vehicle-meta">
        <div>رقم الهيكل: <span class="vin-code">${esc(v.vin)}</span></div>
        <div>الممشى: ${esc(v.mileage)}</div>
        <div>جهاز الفحص: ${esc(report.scannerInfo.toolName)}</div>
        <div>التاريخ: ${esc(report.generatedAt.split('T')[0])}</div>
      </div>

      <div class="score-box">
        <div class="score-circle">
          $score%
          <span class="score-label">الجاهزية</span>
        </div>
        <div style="flex: 1;">
          <div style="font-weight: 800; font-size: 14px; margin-bottom: 4px;">الحالة: ${esc(summary.severityStatus)}</div>
          <div class="summary-text">${esc(summary.briefSummaryArabic)}</div>
        </div>
      </div>
    </div>

    ${critFaults.isNotEmpty ? '''
    <div class="card">
      <div class="section-title">
        <span class="badge badge-crit">أعطال حرجة (${critFaults.length})</span>
        <span>تتطلب تدخل فوري</span>
      </div>
      ${critFaults.map((f) => '''
      <div class="code-row crit">
        <span class="code-dtc">${esc(f.code)}</span>
        <span style="font-size: 11px; color: var(--text-muted); margin-right: 6px;">${esc(f.moduleNameArabic.isNotEmpty ? f.moduleNameArabic : f.module)}</span>
        <div class="code-term">${esc(f.libyanTerm)}</div>
        <div class="code-desc">${esc(f.standardDescriptionEn)}</div>
        <div class="action-box">🛠️ التوجيه: ${esc(f.recommendedAction)}</div>
      </div>
      ''').join('')}
    </div>
    ''' : ''}

    ${modFaults.isNotEmpty ? '''
    <div class="card">
      <div class="section-title">
        <span class="badge badge-mod">أعطال متوسطة (${modFaults.length})</span>
        <span>صيانة مجدولة</span>
      </div>
      ${modFaults.map((f) => '''
      <div class="code-row mod">
        <span class="code-dtc">${esc(f.code)}</span>
        <span style="font-size: 11px; color: var(--text-muted); margin-right: 6px;">${esc(f.moduleNameArabic.isNotEmpty ? f.moduleNameArabic : f.module)}</span>
        <div class="code-term">${esc(f.libyanTerm)}</div>
        <div class="code-desc">${esc(f.standardDescriptionEn)}</div>
        <div class="action-box">🛠️ التوجيه: ${esc(f.recommendedAction)}</div>
      </div>
      ''').join('')}
    </div>
    ''' : ''}

    ${histFaults.isNotEmpty ? '''
    <div class="card">
      <div class="section-title">
        <span class="badge badge-hist">أعطال الذاكرة (${histFaults.length})</span>
        <span>أكواد مسجلة سابقاً</span>
      </div>
      ${histFaults.map((f) => '''
      <div class="code-row hist">
        <span class="code-dtc">${esc(f.code)}</span>
        <span style="font-size: 11px; color: var(--text-muted); margin-right: 6px;">${esc(f.moduleNameArabic.isNotEmpty ? f.moduleNameArabic : f.module)}</span>
        <div class="code-term">${esc(f.libyanTerm)}</div>
        <div class="code-desc">${esc(f.standardDescriptionEn)}</div>
      </div>
      ''').join('')}
    </div>
    ''' : ''}

    ${passedSystems.isNotEmpty ? '''
    <div class="card">
      <div class="section-title">
        <span class="badge badge-pass">الأنظمة السليمة (${passedSystems.length})</span>
        <span>لا توجد بها أعطال مسجلة</span>
      </div>
      <div class="passed-grid">
        ${passedSystems.map((s) => '''
        <div class="passed-item">✓ ${esc(s)}</div>
        ''').join('')}
      </div>
    </div>
    ''' : ''}

    ${spareParts.isNotEmpty ? '''
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
          ${spareParts.map((p) => '''
          <tr>
            <td><strong>${esc(p.partNameLibyan)}</strong></td>
            <td>${esc(p.partNameEnglish)}</td>
            <td style="font-family: monospace; font-weight: bold;">${esc(p.oemPartNumber ?? 'غير متوفر')}</td>
            <td style="font-weight: bold; color: var(--amp-30);">${p.estimatedPriceRangeLYD != null ? '${p.estimatedPriceRangeLYD!.min.toInt()} - ${p.estimatedPriceRangeLYD!.max.toInt()} د.ل' : 'غير مسعر'}</td>
            <td>${esc(p.aftermarketReplacements.join(', '))}</td>
          </tr>
          ''').join('')}
        </tbody>
      </table>
    </div>
    ''' : ''}

    ${checklist.isNotEmpty ? '''
    <div class="card">
      <div class="section-title">
        <span>📋 قائمة فحص الأسطى (خطوات المعاينة)</span>
      </div>
      <table>
        <thead>
          <tr>
            <th>#</th>
            <th>الإجراء المطلوب</th>
            <th>التفاصيل عند الأسطى</th>
            <th>العدة المطلوبة</th>
          </tr>
        </thead>
        <tbody>
          ${checklist.map((c) => '''
          <tr>
            <td style="text-align: center; font-weight: bold;">${c.stepNumber}</td>
            <td><strong>${esc(c.actionTitle)}</strong></td>
            <td>${esc(c.actionDescriptionLibyan)}</td>
            <td>${esc(c.toolingNeeded)}</td>
          </tr>
          ''').join('')}
        </tbody>
      </table>
    </div>
    ''' : ''}

    <div class="stamp-box">
      <div class="stamp-col">
        <div>اسم وتوقيع الفني المسئول:</div>
        <div class="stamp-space"></div>
        <div style="border-top: 1px solid var(--border); padding-top: 4px;">توقيع الفني: ....................</div>
      </div>
      <div class="stamp-col">
        <div>اعتماد وختم الورشة:</div>
        <div class="stamp-space"></div>
        <div style="border-top: 1px solid var(--border); padding-top: 4px;">[ ختم الورشة المعتمد ]</div>
      </div>
    </div>

    <div class="footer">
      تم إنشاء هذا التقرير الفني آلياً بواسطة تطبيق <strong>كاشف AI</strong> — يعمل هذا الملف محلياً بدون إنترنت على جميع الأجهزة.
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
      final htmlContent = buildHtml(report);
      final cleanMake = report.vehicle.make.replaceAll(RegExp(r'[^\w\u0621-\u064A]'), '_');
      final cleanModel = report.vehicle.model.replaceAll(RegExp(r'[^\w\u0621-\u064A]'), '_');
      final filename = 'تقرير_كاشف_${cleanMake}_${cleanModel}_${DateTime.now().millisecondsSinceEpoch}.html';

      // Determine directory to save: Try downloads directory, fallback to documents
      Directory? dir;
      if (Platform.isAndroid) {
        dir = Directory('/storage/emulated/0/Download');
        if (!await dir.exists()) {
          dir = await getExternalStorageDirectory();
        }
      } else {
        dir = await getApplicationDocumentsDirectory();
      }

      final file = File('${dir!.path}/$filename');
      await file.writeAsString(htmlContent);

      if (!context.mounted) return;

      // Show success modal with Open & Share options
      showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (ctx) {
          final isDark = Theme.of(ctx).brightness == Brightness.dark;
          return Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark ? KashifColors.darkBoard : KashifColors.lightBoard,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              border: Border.all(
                color: isDark ? KashifColors.darkBorder : KashifColors.lightBorder,
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
                        color: KashifColors.fuse30ATab.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.check_circle_rounded, color: KashifColors.fuse30ATab, size: 28),
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
                              color: isDark ? KashifColors.darkTextPrimary : KashifColors.lightTextPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'تم حفظ الملف في مجلد التنزيلات (يخدم بدون نت)',
                            style: KashifTypography.arabic(
                              fontSize: 12,
                              color: isDark ? KashifColors.darkTextMuted : KashifColors.lightTextMuted,
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
                    color: isDark ? KashifColors.darkCell : KashifColors.lightCell,
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
                    backgroundColor: isDark ? KashifColors.fuse15AInkDark : KashifColors.fuse15AInkLight,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                  ),
                  onPressed: () async {
                    Navigator.pop(ctx);
                    await OpenFilex.open(file.path);
                  },
                  icon: const Icon(Icons.open_in_browser_rounded, size: 20),
                  label: Text(
                    'فتح التقرير فوراً في المتصفح',
                    style: KashifTypography.arabic(fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 8),

                // Button 2: Share file
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: isDark ? KashifColors.darkTextPrimary : KashifColors.lightTextPrimary,
                    side: BorderSide(
                      color: isDark ? KashifColors.darkBorder : KashifColors.lightBorder,
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                  ),
                  onPressed: () async {
                    Navigator.pop(ctx);
                    await SharePlus.instance.share(
                      ShareParams(
                        files: [XFile(file.path, mimeType: 'text/html')],
                        text: 'تقرير فحص كاشف AI للسيارة ${report.vehicle.make} ${report.vehicle.model}',
                      ),
                    );
                  },
                  icon: const Icon(Icons.share_rounded, size: 20),
                  label: Text(
                    'مشاركة الملف (واتساب / بلوتوث / درايف)',
                    style: KashifTypography.arabic(fontSize: 13, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 8),
              ],
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
