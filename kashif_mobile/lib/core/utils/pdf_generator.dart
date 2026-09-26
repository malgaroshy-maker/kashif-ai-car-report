import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../data/models/diagnostic_report.dart';
import '../../data/models/fault_code.dart';
import '../../data/storage/hive_storage.dart';

class KashifPdfGenerator {
  static Future<Uint8List> generateReportPdf(DiagnosticReport report) async {
    final pdf = pw.Document();

    // Load Arabic Font from Google Fonts via Printing package
    final arabicFont = await PdfGoogleFonts.cairoRegular();
    final arabicBoldFont = await PdfGoogleFonts.cairoBold();

    final workshopName = KashifStorage.workshopName;
    final workshopPhone = KashifStorage.workshopPhone;

    // Determine colors
    final score = report.summary.overallHealthScore;
    PdfColor healthColor;
    if (score >= 80) {
      healthColor = PdfColor.fromHex('2E9E5B'); // 30A Green
    } else if (score >= 50) {
      healthColor = PdfColor.fromHex('F2C200'); // 20A Yellow
    } else {
      healthColor = PdfColor.fromHex('DE3B2F'); // 10A Red
    }

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(24),
        textDirection: pw.TextDirection.rtl,
        theme: pw.ThemeData.withFont(
          base: arabicFont,
          bold: arabicBoldFont,
        ),
        header: (pw.Context context) {
          return pw.Container(
            padding: const pw.EdgeInsets.only(bottom: 12),
            decoration: const pw.BoxDecoration(
              border: pw.Border(
                bottom: pw.BorderSide(color: PdfColors.grey400, width: 1.5),
              ),
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      workshopName,
                      style: pw.TextStyle(
                        font: arabicBoldFont,
                        fontSize: 16,
                        color: PdfColors.blueGrey900,
                      ),
                    ),
                    if (workshopPhone.isNotEmpty)
                      pw.Text(
                        'هاتف الورشة: $workshopPhone',
                        style: pw.TextStyle(
                          font: arabicFont,
                          fontSize: 10,
                          color: PdfColors.grey700,
                        ),
                      ),
                  ],
                ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Container(
                      padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      color: PdfColor.fromHex('2E7FC4'), // 15A Interactive Blue
                      child: pw.Text(
                        'كاشف AI | شهادة فحص فني',
                        style: pw.TextStyle(
                          font: arabicBoldFont,
                          fontSize: 11,
                          color: PdfColors.white,
                        ),
                      ),
                    ),
                    pw.SizedBox(height: 3),
                    pw.Text(
                      'تاريخ الفحص: ${report.generatedAt.split('T').first}',
                      style: pw.TextStyle(font: arabicFont, fontSize: 9, color: PdfColors.grey700),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
        footer: (pw.Context context) {
          return pw.Container(
            padding: const pw.EdgeInsets.only(top: 8),
            decoration: const pw.BoxDecoration(
              border: pw.Border(top: pw.BorderSide(color: PdfColors.grey300, width: 1)),
            ),
            child: pw.Row(
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                pw.Text(
                  'منظومة كاشف AI لفحص وتشخيص أعطال السيارات الليبية',
                  style: pw.TextStyle(font: arabicFont, fontSize: 8, color: PdfColors.grey600),
                ),
                pw.Text(
                  'صفحة ${context.pageNumber} من ${context.pagesCount}',
                  style: pw.TextStyle(font: arabicFont, fontSize: 8, color: PdfColors.grey600),
                ),
              ],
            ),
          );
        },
        build: (pw.Context context) {
          final allFaults = [
            ...report.criticalFaults,
            ...report.moderateFaults,
            ...report.historyFaults,
          ];

          return [
            pw.SizedBox(height: 10),

            // Vehicle Specs & Health Score Summary
            pw.Container(
              padding: const pw.EdgeInsets.all(12),
              decoration: pw.BoxDecoration(
                color: PdfColors.grey100,
                border: pw.Border.all(color: PdfColors.grey400, width: 1),
              ),
              child: pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Expanded(
                    flex: 3,
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          'بيانات المركبة المفحوصة:',
                          style: pw.TextStyle(font: arabicBoldFont, fontSize: 12, color: PdfColors.blueGrey900),
                        ),
                        pw.SizedBox(height: 4),
                        pw.Text('• السيارة: ${report.vehicle.make} ${report.vehicle.model} (${report.vehicle.year})',
                            style: pw.TextStyle(font: arabicFont, fontSize: 10)),
                        if (report.vehicle.vin.isNotEmpty && report.vehicle.vin != 'N/A')
                          pw.Text('• رقم الهيكل (VIN): ${report.vehicle.vin}',
                              style: pw.TextStyle(font: arabicBoldFont, fontSize: 10, color: PdfColor.fromHex('0F5288'))),
                        if (report.vehicle.engineSpecs != null)
                          pw.Text(
                              '• المحرك: ${report.vehicle.engineSpecs!.displacement} (${report.vehicle.engineSpecs!.cylinders} سلندر) | ${report.vehicle.engineSpecs!.fuelType} | ${report.vehicle.engineSpecs!.transmission}',
                              style: pw.TextStyle(font: arabicFont, fontSize: 9)),
                        if (report.vehicle.mileage.isNotEmpty)
                          pw.Text('• العداد: ${report.vehicle.mileage}', style: pw.TextStyle(font: arabicFont, fontSize: 9)),
                        pw.Text('• جهاز الفحص: ${report.scannerInfo.toolName}',
                            style: pw.TextStyle(font: arabicFont, fontSize: 9, color: PdfColors.grey700)),
                      ],
                    ),
                  ),
                  pw.Container(width: 1, height: 75, color: PdfColors.grey300),
                  pw.SizedBox(width: 12),
                  pw.Expanded(
                    flex: 2,
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.center,
                      mainAxisAlignment: pw.MainAxisAlignment.center,
                      children: [
                        pw.Container(
                          padding: const pw.EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: pw.BoxDecoration(
                            color: healthColor,
                            borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
                          ),
                          child: pw.Text(
                            '${report.summary.overallHealthScore}%',
                            style: pw.TextStyle(
                              font: arabicBoldFont,
                              fontSize: 22,
                              color: PdfColors.white,
                            ),
                          ),
                        ),
                        pw.SizedBox(height: 4),
                        pw.Text(
                          report.summary.severityStatus,
                          style: pw.TextStyle(font: arabicBoldFont, fontSize: 11, color: healthColor),
                        ),
                        pw.Text(
                          '${report.totalFaultsCount} أعطال مسجلة',
                          style: pw.TextStyle(font: arabicFont, fontSize: 9, color: PdfColors.grey700),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            pw.SizedBox(height: 12),

            // Brief summary
            if (report.summary.briefSummaryArabic.isNotEmpty) ...[
              pw.Container(
                padding: const pw.EdgeInsets.all(10),
                decoration: pw.BoxDecoration(
                  color: PdfColors.blue50,
                  border: pw.Border.all(color: PdfColors.blue200, width: 0.8),
                ),
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text('خلاصة تقييم الأسطى:', style: pw.TextStyle(font: arabicBoldFont, fontSize: 11, color: PdfColors.blue900)),
                    pw.SizedBox(height: 4),
                    pw.Text(report.summary.briefSummaryArabic, style: pw.TextStyle(font: arabicFont, fontSize: 9.5, height: 1.4)),
                  ],
                ),
              ),
              pw.SizedBox(height: 14),
            ],

            // Fault Codes Table
            pw.Text('جدول تشخيص الأعطال المسجلة (ISO/DIN 72581-3):', style: pw.TextStyle(font: arabicBoldFont, fontSize: 12)),
            pw.SizedBox(height: 6),
            if (allFaults.isEmpty)
              pw.Text('لا توجد أعطال مسجلة في هذا الفحص.', style: pw.TextStyle(font: arabicFont, fontSize: 10))
            else
              pw.TableHelper.fromTextArray(
                border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
                headerStyle: pw.TextStyle(font: arabicBoldFont, fontSize: 9, color: PdfColors.white),
                headerDecoration: pw.BoxDecoration(color: PdfColor.fromHex('1B1F1D')),
                cellStyle: pw.TextStyle(font: arabicFont, fontSize: 8.5),
                headers: ['الكود', 'الكمبيوتر', 'المصطلح الليبي / العطل', 'درجة الخطورة', 'الإجراء المطلوب'],
                data: allFaults.map((f) {
                  String sevLabel = 'متوسط';
                  if (f.severity == CodeSeverity.critical) sevLabel = 'حرج (10A)';
                  if (f.severity == CodeSeverity.history) sevLabel = 'ذاكرة (25A)';
                  return [
                    f.code,
                    f.module,
                    f.libyanTerm,
                    sevLabel,
                    f.recommendedAction,
                  ];
                }).toList(),
              ),
            pw.SizedBox(height: 14),

            // Spare Parts Guide Table
            if (report.spareParts.isNotEmpty) ...[
              pw.Text('دليل قطع الغيار المطلوبة والأسعار التقديرية بالدينار الليبي:', style: pw.TextStyle(font: arabicBoldFont, fontSize: 12)),
              pw.SizedBox(height: 6),
              pw.TableHelper.fromTextArray(
                border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
                headerStyle: pw.TextStyle(font: arabicBoldFont, fontSize: 9, color: PdfColors.white),
                headerDecoration: pw.BoxDecoration(color: PdfColor.fromHex('2E9E5B')), // 30A Green
                cellStyle: pw.TextStyle(font: arabicFont, fontSize: 8.5),
                headers: ['القطعة بالليبي', 'رقم القطعة الأصلي (OEM)', 'البدائل الموثوقة', 'السعر التقديري (د.ل)'],
                data: report.spareParts.map((p) {
                  final price = p.estimatedPriceRangeLYD;
                  final priceStr = price != null ? '${price.min.toInt()} - ${price.max.toInt()} د.ل' : 'حسب السوق';
                  return [
                    p.partNameLibyan,
                    p.oemPartNumber ?? 'غير محدد',
                    p.aftermarketReplacements.join('، '),
                    priceStr,
                  ];
                }).toList(),
              ),
              pw.SizedBox(height: 14),
            ],

            // Workshop Inspection Checklist
            if (report.checklist.isNotEmpty) ...[
              pw.Text('قائمة خطوات فحص الأسطى والورشة:', style: pw.TextStyle(font: arabicBoldFont, fontSize: 12)),
              pw.SizedBox(height: 6),
              ...report.checklist.map((step) {
                return pw.Container(
                  margin: const pw.EdgeInsets.only(bottom: 5),
                  padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.grey50,
                    border: pw.Border.all(color: PdfColors.grey300, width: 0.5),
                  ),
                  child: pw.Row(
                    children: [
                      pw.Container(
                        width: 14,
                        height: 14,
                        decoration: pw.BoxDecoration(
                          border: pw.Border.all(color: PdfColors.grey600, width: 1),
                        ),
                        child: step.isCompleted
                            ? pw.Center(child: pw.Text('✓', style: pw.TextStyle(font: arabicBoldFont, fontSize: 9)))
                            : null,
                      ),
                      pw.SizedBox(width: 8),
                      pw.Expanded(
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text('خطوة ${step.stepNumber}: ${step.actionTitle}',
                                style: pw.TextStyle(font: arabicBoldFont, fontSize: 9)),
                            pw.Text(step.actionDescriptionLibyan, style: pw.TextStyle(font: arabicFont, fontSize: 8)),
                          ],
                        ),
                      ),
                      if (step.toolingNeeded.isNotEmpty)
                        pw.Text('العدة: ${step.toolingNeeded}',
                            style: pw.TextStyle(font: arabicFont, fontSize: 8, color: PdfColors.grey700)),
                    ],
                  ),
                );
              }),
              pw.SizedBox(height: 16),
            ],

            // Stamp & Signature section
            pw.Container(
              padding: const pw.EdgeInsets.all(12),
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.grey400, width: 1),
              ),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('اسم وتوقيع الفني المسئول:', style: pw.TextStyle(font: arabicBoldFont, fontSize: 10)),
                      pw.SizedBox(height: 25),
                      pw.Text('التوقيع: ............................', style: pw.TextStyle(font: arabicFont, fontSize: 9)),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.center,
                    children: [
                      pw.Text('ختم واعتماد الورشة الفنية:', style: pw.TextStyle(font: arabicBoldFont, fontSize: 10)),
                      pw.SizedBox(height: 35),
                      pw.Text('[ الختم المعتمد ]', style: pw.TextStyle(font: arabicFont, fontSize: 9, color: PdfColors.grey500)),
                    ],
                  ),
                ],
              ),
            ),
          ];
        },
      ),
    );

    return pdf.save();
  }

  /// Print or show native PDF print preview directly on Android
  static Future<void> printOrShareReport(DiagnosticReport report) async {
    final pdfBytes = await generateReportPdf(report);
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdfBytes,
      name: 'تقرير_كاشف_${report.vehicle.make}_${report.vehicle.model}.pdf',
    );
  }
}
