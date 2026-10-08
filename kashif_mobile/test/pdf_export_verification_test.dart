import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:kashif_mobile/core/utils/pdf_generator.dart';
import 'package:kashif_mobile/data/models/report_sections_config.dart';
import 'package:kashif_mobile/data/repositories/offline_report_service.dart';

void main() {
  setUpAll(() {
    OfflineReportService.loadFromJsonString(
      File('assets/data/offline_dtc.json').readAsStringSync(),
    );
  });

  test('PDF generator renders multi-manufacturer report with Libyan spare parts and probabilities table', () async {
    TestWidgetsFlutterBinding.ensureInitialized();

    // Generate comprehensive report for top manufacturer-specific codes
    final report = OfflineReportService.tryBuildOfflineReport(
      'P0011, P2714, P17BF, P1450, C1201, B1801',
      vin: '1FADP5CU8DTEST99',
      make: 'Ford',
      model: 'Fusion',
      year: '2016',
    );

    expect(report, isNotNull);
    expect(report!.summary.faultsFoundCount, 6);
    expect(report.spareParts, isNotEmpty);
    expect(report.spareParts.length, greaterThanOrEqualTo(5));

    // Verify PDF generation produces non-empty, high-fidelity bytes
    final pdfBytes = await KashifPdfGenerator.generateReportPdf(report);
    expect(pdfBytes, isNotEmpty);
    expect(pdfBytes.length, greaterThan(15000));
  });

  test('PDF generator handles single-code and multi-code edge cases cleanly', () async {
    TestWidgetsFlutterBinding.ensureInitialized();

    for (final code in ['P0087', 'P0299', 'P0741', 'U0100', 'B1620']) {
      final report = OfflineReportService.tryBuildOfflineReport(
        code,
        make: 'Hyundai',
        model: 'Tucson',
        year: '2021',
      );

      expect(report, isNotNull, reason: 'Failed for code: $code');
      final pdfBytes = await KashifPdfGenerator.generateReportPdf(report!);
      expect(pdfBytes.length, greaterThan(5000), reason: 'Failed bytes for code: $code');
    }
  });

  test('PDF generator renders workshop branding and toggles technician signature section', () async {
    TestWidgetsFlutterBinding.ensureInitialized();

    final report = OfflineReportService.tryBuildOfflineReport(
      'P0300, P0171',
      vin: '1G1JC5444RTEST123',
      make: 'Chevrolet',
      model: 'Cruze',
      year: '2015',
    );
    expect(report, isNotNull);

    // Test with technician signature enabled (default)
    final withSignatureBytes = await KashifPdfGenerator.generateReportPdf(
      report!,
      sectionsConfig: const ReportSectionsConfig(includeTechnicianSignature: true),
    );
    expect(withSignatureBytes, isNotEmpty);

    // Test with technician signature disabled
    final withoutSignatureBytes = await KashifPdfGenerator.generateReportPdf(
      report,
      sectionsConfig: const ReportSectionsConfig(includeTechnicianSignature: false),
    );
    expect(withoutSignatureBytes, isNotEmpty);
    expect(withSignatureBytes.length, greaterThan(withoutSignatureBytes.length));
  });
}
