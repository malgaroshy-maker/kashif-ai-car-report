import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../data/models/diagnostic_report.dart';
import '../../data/models/fault_code.dart';
import '../../data/storage/hive_storage.dart';
import 'report_sanitizer.dart';

class KashifPdfGenerator {
  static Future<pw.Font> _loadArabicFont({bool bold = false}) async {
    final assetPath = bold
        ? 'assets/fonts/amiri-bold.ttf'
        : 'assets/fonts/amiri.ttf';
    try {
      final bytes = await rootBundle.load(assetPath);
      return pw.Font.ttf(bytes);
    } catch (_) {
      try {
        return bold
            ? await PdfGoogleFonts.amiriBold()
            : await PdfGoogleFonts.amiriRegular();
      } catch (_) {
        return pw.Font.courier();
      }
    }
  }

  static List<String> _deriveSoundSystems(DiagnosticReport report) =>
      report.soundSystems;

  static pw.Widget _buildVectorCheckmark({
    PdfColor color = const PdfColor(0.18, 0.62, 0.36),
    double size = 13,
    bool isCircle = true,
  }) {
    return pw.Container(
      width: size,
      height: size,
      decoration: pw.BoxDecoration(
        color: color,
        shape: isCircle ? pw.BoxShape.circle : pw.BoxShape.rectangle,
        borderRadius: isCircle
            ? null
            : const pw.BorderRadius.all(pw.Radius.circular(2)),
      ),
      child: pw.Center(
        child: pw.CustomPaint(
          size: const PdfPoint(8, 8),
          painter: (PdfGraphics canvas, PdfPoint s) {
            canvas.setColor(PdfColors.white);
            canvas.setLineWidth(1.3);
            canvas.moveTo(1.2, 4.0);
            canvas.lineTo(3.2, 1.8);
            canvas.lineTo(6.8, 6.2);
            canvas.strokePath();
          },
        ),
      ),
    );
  }

  static Future<Uint8List> generateReportPdf(DiagnosticReport report) async {
    final pdf = pw.Document();

    // Load Amiri font (solves Arabic letter collision/overlap in Cairo)
    final arabicFont = await _loadArabicFont(bold: false);
    final arabicBoldFont = await _loadArabicFont(bold: true);

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
        theme: pw.ThemeData.withFont(base: arabicFont, bold: arabicBoldFont),
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
                    if (workshopName.trim().isNotEmpty &&
                        workshopName.trim() != 'ورشة الفحص الفني')
                      pw.Text(
                        workshopName.trim(),
                        style: pw.TextStyle(
                          font: arabicBoldFont,
                          fontSize: 15,
                          color: PdfColors.blueGrey900,
                        ),
                      ),
                    if (workshopPhone.trim().isNotEmpty) ...[
                      if (workshopName.trim().isNotEmpty &&
                          workshopName.trim() != 'ورشة الفحص الفني')
                        pw.SizedBox(height: 2),
                      pw.Text(
                        'هاتف: ${workshopPhone.trim()}',
                        style: pw.TextStyle(
                          font: arabicFont,
                          fontSize: 10,
                          color: PdfColors.grey700,
                        ),
                      ),
                    ],
                  ],
                ),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Container(
                      padding: const pw.EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      color: PdfColor.fromHex('2E7FC4'), // 15A Interactive Blue
                      child: pw.Text(
                        'Flow Cars | شهادة فحص فني',
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
                      style: pw.TextStyle(
                        font: arabicFont,
                        fontSize: 9,
                        color: PdfColors.grey700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
        footer: (pw.Context context) {
          final techName =
              (workshopName.trim().isNotEmpty &&
                  workshopName.trim() != 'ورشة الفحص الفني')
              ? workshopName.trim()
              : (workshopName.trim().isNotEmpty ? workshopName.trim() : 'فني فحص معتمد');
          final techPhone = workshopPhone.trim();

          return pw.Container(
            padding: const pw.EdgeInsets.only(top: 8),
            decoration: const pw.BoxDecoration(
              border: pw.Border(
                top: pw.BorderSide(color: PdfColors.grey300, width: 1),
              ),
            ),
            child: pw.Row(
              children: [
                // Right: اسم الفني
                pw.Expanded(
                  flex: 3,
                  child: pw.Align(
                    alignment: pw.Alignment.centerRight,
                    child: pw.Row(
                      mainAxisSize: pw.MainAxisSize.min,
                      children: [
                        pw.Text(
                          'اسم الفني: ',
                          style: pw.TextStyle(
                            font: arabicBoldFont,
                            fontSize: 9,
                            color: PdfColors.blueGrey900,
                          ),
                        ),
                        pw.Text(
                          techName,
                          style: pw.TextStyle(
                            font: arabicFont,
                            fontSize: 9,
                            color: PdfColors.blueGrey800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Center: رقم هاتف الفني
                pw.Expanded(
                  flex: 3,
                  child: pw.Center(
                    child: pw.Row(
                      mainAxisSize: pw.MainAxisSize.min,
                      children: [
                        pw.Text(
                          'رقم الهاتف: ',
                          style: pw.TextStyle(
                            font: arabicBoldFont,
                            fontSize: 9,
                            color: PdfColors.blueGrey900,
                          ),
                        ),
                        pw.Text(
                          techPhone.isNotEmpty ? techPhone : '—',
                          textDirection: pw.TextDirection.ltr,
                          style: pw.TextStyle(
                            font: arabicBoldFont,
                            fontSize: 9,
                            color: PdfColors.blueGrey800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Left: رقم الصفحة
                pw.Expanded(
                  flex: 2,
                  child: pw.Align(
                    alignment: pw.Alignment.centerLeft,
                    child: pw.Text(
                      'صفحة ${context.pageNumber} من ${context.pagesCount}',
                      style: pw.TextStyle(
                        font: arabicFont,
                        fontSize: 8.5,
                        color: PdfColors.grey700,
                      ),
                    ),
                  ),
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

          // Clean and format vehicle specs to avoid BiDi parenthesis and colon inversion bugs
          final vMake = report.vehicle.make.trim();
          final vModel = report.vehicle.model
              .replaceAll('(', '')
              .replaceAll(')', '')
              .replaceAll('السلندر', 'البسطوني')
              .replaceAll('سلندر', 'بسطوني')
              .trim();
          final vYear = report.vehicle.year.trim().split('.').first;
          final carTitle = [
            if (vMake.isNotEmpty) vMake,
            if (vModel.isNotEmpty) vModel,
            if (vYear.isNotEmpty) '• موديل $vYear',
          ].join(' ');

          final vinNumber =
              (report.vehicle.vin.isNotEmpty && report.vehicle.vin != 'N/A')
              ? report.vehicle.vin.trim()
              : '';

          String engineTitle = '';
          String transTitle = '';
          if (report.vehicle.engineSpecs != null) {
            final sp = report.vehicle.engineSpecs!;
            var disp = sp.displacement
                .replaceAll('السلندر', 'البسطوني')
                .replaceAll('سلندر', 'بسطوني')
                .replaceAll('(', '- ')
                .replaceAll(')', '')
                .trim();
            if (!disp.contains('بسطوني') && sp.cylinders > 0) {
              disp = disp.isNotEmpty
                  ? '$disp - ${sp.cylinders} بسطوني'
                  : '${sp.cylinders} بسطوني';
            }
            if (sp.fuelType.isNotEmpty && sp.fuelType != 'غير محدد') {
              disp = disp.isNotEmpty ? '$disp • ${sp.fuelType}' : sp.fuelType;
            }
            engineTitle = disp;

            var tr = sp.transmission
                .replaceAll('السلندر', 'البسطوني')
                .replaceAll('سلندر', 'بسطوني')
                .replaceAll('(', '- ')
                .replaceAll(')', '')
                .trim();
            transTitle = tr;
          }

          final mileageTitle = report.vehicle.formattedMileage;

          pw.Widget buildSpecRow(
            String label,
            String value, {
            bool isBoldValue = false,
            PdfColor? valueColor,
          }) {
            if (value.trim().isEmpty) return pw.SizedBox();
            return pw.Padding(
              padding: const pw.EdgeInsets.only(bottom: 3.5),
              child: pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Container(
                    width: 4.5,
                    height: 4.5,
                    margin: const pw.EdgeInsets.only(top: 3.5, left: 5),
                    decoration: pw.BoxDecoration(
                      color: PdfColor.fromHex('2E7FC4'),
                      borderRadius: const pw.BorderRadius.all(
                        pw.Radius.circular(1),
                      ),
                    ),
                  ),
                  pw.SizedBox(
                    width: 66,
                    child: pw.Text(
                      label,
                      style: pw.TextStyle(
                        font: arabicBoldFont,
                        fontSize: 8.5,
                        color: PdfColors.blueGrey900,
                      ),
                    ),
                  ),
                  pw.Expanded(
                    child: pw.Text(
                      value,
                      style: pw.TextStyle(
                        font: isBoldValue ? arabicBoldFont : arabicFont,
                        fontSize: 8.5,
                        color: valueColor ?? PdfColors.blueGrey800,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          return [
            pw.SizedBox(height: 10),

            // Vehicle Specs & Health Score Summary Card
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
                          'بيانات المركبة:',
                          style: pw.TextStyle(
                            font: arabicBoldFont,
                            fontSize: 11,
                            color: PdfColors.blueGrey900,
                          ),
                        ),
                        pw.SizedBox(height: 6),
                        buildSpecRow('السيارة:', carTitle, isBoldValue: true),
                        if (vinNumber.isNotEmpty)
                          buildSpecRow(
                            'رقم الهيكل:',
                            vinNumber,
                            isBoldValue: true,
                            valueColor: PdfColor.fromHex('0F5288'),
                          ),
                        if (engineTitle.isNotEmpty)
                          buildSpecRow('المحرك:', engineTitle),
                        if (transTitle.isNotEmpty)
                          buildSpecRow('ناقل الحركة:', transTitle),
                        if (mileageTitle.isNotEmpty)
                          buildSpecRow('قراءة العداد:', mileageTitle),
                        if (report.generatedAt.isNotEmpty)
                          buildSpecRow(
                            'تاريخ الفحص:',
                            report.generatedAt.split('T').first,
                          ),
                      ],
                    ),
                  ),
                  pw.Container(width: 1, height: 105, color: PdfColors.grey300),
                  pw.SizedBox(width: 12),
                  pw.Expanded(
                    flex: 2,
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.center,
                      mainAxisAlignment: pw.MainAxisAlignment.center,
                      children: [
                        pw.Container(
                          padding: const pw.EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          decoration: pw.BoxDecoration(
                            color: healthColor,
                            borderRadius: const pw.BorderRadius.all(
                              pw.Radius.circular(4),
                            ),
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
                          style: pw.TextStyle(
                            font: arabicBoldFont,
                            fontSize: 11,
                            color: healthColor,
                          ),
                        ),
                        pw.Text(
                          '${report.totalFaultsCount} أعطال مسجلة',
                          style: pw.TextStyle(
                            font: arabicFont,
                            fontSize: 9,
                            color: PdfColors.grey700,
                          ),
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
                    pw.Text(
                      'خلاصة تقييم السيارة:',
                      style: pw.TextStyle(
                        font: arabicBoldFont,
                        fontSize: 11,
                        color: PdfColors.blue900,
                      ),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text(
                      ReportSanitizer.clean(report.summary.briefSummaryArabic)
                          .replaceAll('السلندر', 'البسطوني')
                          .replaceAll('سلندر', 'بسطوني'),
                      style: pw.TextStyle(
                        font: arabicFont,
                        fontSize: 9.5,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 14),
            ],

            // Fault Codes Table (RTL: rightmost is الكود, leftmost is الإجراء المطلوب)
            pw.Text(
              'جدول تشخيص وحصر الأعطال المسجلة:',
              style: pw.TextStyle(font: arabicBoldFont, fontSize: 11),
            ),
            pw.SizedBox(height: 5),
            if (allFaults.isEmpty)
              pw.Text(
                'لا توجد أعطال مسجلة في هذا الفحص.',
                style: pw.TextStyle(font: arabicFont, fontSize: 9.5),
              )
            else
              pw.TableHelper.fromTextArray(
                border: pw.TableBorder.all(
                  color: PdfColors.grey300,
                  width: 0.5,
                ),
                headerStyle: pw.TextStyle(
                  font: arabicBoldFont,
                  fontSize: 8,
                  color: PdfColors.white,
                ),
                headerDecoration: pw.BoxDecoration(
                  color: PdfColor.fromHex('1B1F1D'),
                ),
                headerPadding: const pw.EdgeInsets.symmetric(
                  horizontal: 4,
                  vertical: 5,
                ),
                cellStyle: pw.TextStyle(
                  font: arabicFont,
                  fontSize: 7.5,
                  height: 1.3,
                ),
                cellPadding: const pw.EdgeInsets.symmetric(
                  horizontal: 4,
                  vertical: 4,
                ),
                headers: [
                  'الإجراء الفني المطلوب',
                  'الخطورة',
                  'وصف العطل بالليبي',
                  'الوحدة',
                  'الكود',
                ],
                columnWidths: {
                  0: const pw.FlexColumnWidth(3.3), // الإجراء المطلوب (يسار)
                  1: const pw.FlexColumnWidth(1.1), // الخطورة
                  2: const pw.FlexColumnWidth(2.6), // وصف العطل
                  3: const pw.FlexColumnWidth(1.4), // الوحدة / ECU
                  4: const pw.FlexColumnWidth(1.2), // الكود (يمين)
                },
                cellAlignments: {
                  0: pw.Alignment.centerRight,
                  1: pw.Alignment.center,
                  2: pw.Alignment.centerRight,
                  3: pw.Alignment.center,
                  4: pw.Alignment.center,
                },
                headerAlignments: {
                  0: pw.Alignment.center,
                  1: pw.Alignment.center,
                  2: pw.Alignment.center,
                  3: pw.Alignment.center,
                  4: pw.Alignment.center,
                },
                data: allFaults.map((f) {
                  String sevLabel = 'متوسط';
                  if (f.severity == CodeSeverity.critical) sevLabel = 'حرج';
                  if (f.severity == CodeSeverity.history) sevLabel = 'ذاكرة';
                  final cleanLibyanTerm = ReportSanitizer.clean(f.libyanTerm)
                      .replaceAll('السلندر', 'البسطوني')
                      .replaceAll('سلندر', 'بسطوني');
                  final cleanAction = ReportSanitizer.clean(f.recommendedAction)
                      .replaceAll('السلندر', 'البسطوني')
                      .replaceAll('سلندر', 'بسطوني');
                  return [
                    cleanAction,
                    sevLabel,
                    cleanLibyanTerm,
                    f.module,
                    f.code,
                  ];
                }).toList(),
              ),
            pw.SizedBox(height: 12),

            // Passed & Healthy Inspected Systems Section (المنظومات السليمة)
            ...[
              pw.Container(
                margin: const pw.EdgeInsets.only(top: 4, bottom: 6),
                child: pw.Row(
                  children: [
                    pw.Container(
                      padding: const pw.EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: pw.BoxDecoration(
                        color: PdfColor.fromHex('2E9E5B'), // 30A Green
                        borderRadius: const pw.BorderRadius.all(
                          pw.Radius.circular(3),
                        ),
                      ),
                      child: pw.Text(
                        'الأنظمة السليمة (${_deriveSoundSystems(report).length})',
                        style: pw.TextStyle(
                          font: arabicBoldFont,
                          fontSize: 9.5,
                          color: PdfColors.white,
                        ),
                      ),
                    ),
                    pw.SizedBox(width: 8),
                    pw.Text(
                      'المنظومات التي تم فحصها وتأكيد سلامتها وخلوها التام من الأعطال:',
                      style: pw.TextStyle(
                        font: arabicFont,
                        fontSize: 8.5,
                        color: PdfColors.grey700,
                      ),
                    ),
                  ],
                ),
              ),
              pw.Wrap(
                spacing: 6,
                runSpacing: 5,
                children: _deriveSoundSystems(report).map((sys) {
                  return pw.Container(
                    width: 268,
                    padding: const pw.EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 5,
                    ),
                    decoration: pw.BoxDecoration(
                      color: PdfColor.fromHex('F2FAF5'),
                      border: pw.Border.all(
                        color: PdfColor.fromHex('C3E6D1'),
                        width: 0.8,
                      ),
                      borderRadius: const pw.BorderRadius.all(
                        pw.Radius.circular(3),
                      ),
                    ),
                    child: pw.Row(
                      children: [
                        _buildVectorCheckmark(size: 13, isCircle: true),
                        pw.SizedBox(width: 6),
                        pw.Expanded(
                          child: pw.Text(
                            sys,
                            style: pw.TextStyle(
                              font: arabicBoldFont,
                              fontSize: 8,
                              color: PdfColors.blueGrey900,
                            ),
                          ),
                        ),
                        pw.Container(
                          padding: const pw.EdgeInsets.symmetric(
                            horizontal: 5,
                            vertical: 1.5,
                          ),
                          decoration: pw.BoxDecoration(
                            color: PdfColor.fromHex('E8F5E9'),
                            borderRadius: const pw.BorderRadius.all(
                              pw.Radius.circular(2),
                            ),
                          ),
                          child: pw.Text(
                            'سليم 30A',
                            style: pw.TextStyle(
                              font: arabicBoldFont,
                              fontSize: 7,
                              color: PdfColor.fromHex('2E9E5B'),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
              pw.SizedBox(height: 12),
            ],

            // Spare Parts Guide Table (RTL: rightmost is القطعة بالليبي, leftmost is السعر التقديري)
            if (report.spareParts.isNotEmpty) ...[
              pw.Text(
                'دليل قطع الغيار المطلوبة والأسعار التقديرية بالدينار الليبي:',
                style: pw.TextStyle(font: arabicBoldFont, fontSize: 11),
              ),
              pw.SizedBox(height: 5),
              pw.TableHelper.fromTextArray(
                border: pw.TableBorder.all(
                  color: PdfColors.grey300,
                  width: 0.5,
                ),
                headerStyle: pw.TextStyle(
                  font: arabicBoldFont,
                  fontSize: 8,
                  color: PdfColors.white,
                ),
                headerDecoration: pw.BoxDecoration(
                  color: PdfColor.fromHex('2E9E5B'),
                ), // 30A Green
                headerPadding: const pw.EdgeInsets.symmetric(
                  horizontal: 4,
                  vertical: 5,
                ),
                cellStyle: pw.TextStyle(
                  font: arabicFont,
                  fontSize: 7.5,
                  height: 1.3,
                ),
                cellPadding: const pw.EdgeInsets.symmetric(
                  horizontal: 4,
                  vertical: 4,
                ),
                headers: [
                  'السعر التقديري',
                  'البدائل المعتمدة',
                  'رقم القطعة الأصلي',
                  'القطعة بالليبي',
                ],
                columnWidths: {
                  0: const pw.FlexColumnWidth(1.4), // السعر (يسار)
                  1: const pw.FlexColumnWidth(2.8), // البدائل
                  2: const pw.FlexColumnWidth(2.0), // رقم OEM
                  3: const pw.FlexColumnWidth(2.6), // اسم القطعة (يمين)
                },
                cellAlignments: {
                  0: pw.Alignment.center,
                  1: pw.Alignment.centerRight,
                  2: pw.Alignment.center,
                  3: pw.Alignment.centerRight,
                },
                headerAlignments: {
                  0: pw.Alignment.center,
                  1: pw.Alignment.center,
                  2: pw.Alignment.center,
                  3: pw.Alignment.center,
                },
                data: report.spareParts.map((p) {
                  final price = p.estimatedPriceRangeLYD;
                  final priceStr = price != null
                      ? '${price.min.toInt()} - ${price.max.toInt()} د.ل'
                      : 'حسب السوق';
                  final cleanPartName = p.partNameLibyan
                      .replaceAll('السلندر', 'البسطوني')
                      .replaceAll('سلندر', 'بسطوني');
                  final replacementsStr = p.aftermarketReplacements.isNotEmpty
                      ? p.aftermarketReplacements.join(' • ')
                      : 'أصلي أو حسب المتوفر';
                  return [
                    priceStr,
                    replacementsStr,
                    p.oemPartNumber ?? 'غير محدد',
                    cleanPartName,
                  ];
                }).toList(),
              ),
              pw.SizedBox(height: 12),
            ],

            // Workshop Inspection Checklist
            if (report.checklist.isNotEmpty) ...[
              pw.Text(
                'قائمة خطوات فحص الأسطى والورشة:',
                style: pw.TextStyle(font: arabicBoldFont, fontSize: 12),
              ),
              pw.SizedBox(height: 6),
              ...report.checklist.map((step) {
                return pw.Container(
                  margin: const pw.EdgeInsets.only(bottom: 5),
                  padding: const pw.EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.grey50,
                    border: pw.Border.all(color: PdfColors.grey300, width: 0.5),
                  ),
                  child: pw.Row(
                    children: [
                      step.isCompleted
                          ? _buildVectorCheckmark(size: 14, isCircle: false)
                          : pw.Container(
                              width: 14,
                              height: 14,
                              decoration: pw.BoxDecoration(
                                border: pw.Border.all(
                                  color: PdfColors.grey600,
                                  width: 1,
                                ),
                              ),
                            ),
                      pw.SizedBox(width: 8),
                      pw.Expanded(
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: [
                            pw.Text(
                              'خطوة ${step.stepNumber}: ${ReportSanitizer.clean(step.actionTitle).replaceAll('السلندر', 'البسطوني').replaceAll('سلندر', 'بسطوني')}',
                              style: pw.TextStyle(
                                font: arabicBoldFont,
                                fontSize: 9,
                              ),
                            ),
                            pw.Text(
                              ReportSanitizer.clean(step.actionDescriptionLibyan)
                                  .replaceAll('السلندر', 'البسطوني')
                                  .replaceAll('سلندر', 'بسطوني'),
                              style: pw.TextStyle(
                                font: arabicFont,
                                fontSize: 8,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (step.toolingNeeded.isNotEmpty)
                        pw.Text(
                          'العدة: ${ReportSanitizer.clean(step.toolingNeeded).replaceAll('السلندر', 'البسطوني').replaceAll('سلندر', 'بسطوني')}',
                          style: pw.TextStyle(
                            font: arabicFont,
                            fontSize: 8,
                            color: PdfColors.grey700,
                          ),
                        ),
                    ],
                  ),
                );
              }),
              pw.SizedBox(height: 16),
            ],

            // Technician Info & Endorsement Box
            pw.Container(
              margin: const pw.EdgeInsets.only(top: 14),
              padding: const pw.EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 12,
              ),
              decoration: pw.BoxDecoration(
                color: PdfColor.fromHex('F8FAFC'),
                border: pw.Border.all(color: PdfColor.fromHex('CBD5E1'), width: 0.9),
                borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text(
                        'بيانات الفني واعتماد فحص التقرير',
                        style: pw.TextStyle(
                          font: arabicBoldFont,
                          fontSize: 10,
                          color: PdfColor.fromHex('1E3A8A'),
                        ),
                      ),
                      pw.Text(
                        'Flow Cars Inspection Report',
                        style: pw.TextStyle(
                          font: arabicFont,
                          fontSize: 8,
                          color: PdfColors.grey600,
                        ),
                      ),
                    ],
                  ),
                  pw.Divider(color: PdfColor.fromHex('E2E8F0'), thickness: 0.8, height: 10),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Row(
                        children: [
                          pw.Text(
                            'اسم الفني: ',
                            style: pw.TextStyle(
                              font: arabicBoldFont,
                              fontSize: 10,
                              color: PdfColors.blueGrey900,
                            ),
                          ),
                          pw.Text(
                            (workshopName.trim().isNotEmpty &&
                                    workshopName.trim() != 'ورشة الفحص الفني')
                                ? workshopName.trim()
                                : (workshopName.trim().isNotEmpty ? workshopName.trim() : 'فني فحص معتمد'),
                            style: pw.TextStyle(
                              font: arabicBoldFont,
                              fontSize: 10,
                              color: PdfColors.blueGrey800,
                            ),
                          ),
                        ],
                      ),
                      pw.Row(
                        children: [
                          pw.Text(
                            'رقم الهاتف: ',
                            style: pw.TextStyle(
                              font: arabicBoldFont,
                              fontSize: 10,
                              color: PdfColors.blueGrey900,
                            ),
                          ),
                          pw.Text(
                            workshopPhone.trim().isNotEmpty
                                ? workshopPhone.trim()
                                : '—',
                            textDirection: pw.TextDirection.ltr,
                            style: pw.TextStyle(
                              font: arabicBoldFont,
                              fontSize: 10,
                              color: PdfColors.blueGrey800,
                            ),
                          ),
                        ],
                      ),
                      pw.Row(
                        children: [
                          pw.Text(
                            'التوقيع / الختم: ',
                            style: pw.TextStyle(
                              font: arabicBoldFont,
                              fontSize: 9.5,
                              color: PdfColors.blueGrey700,
                            ),
                          ),
                          pw.Container(
                            width: 90,
                            height: 18,
                            decoration: const pw.BoxDecoration(
                              border: pw.Border(
                                bottom: pw.BorderSide(
                                  color: PdfColors.blueGrey400,
                                  width: 1,
                                  style: pw.BorderStyle.dashed,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
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
      name: 'تقرير_flowcars_${report.vehicle.make}_${report.vehicle.model}.pdf',
    );
  }
}
