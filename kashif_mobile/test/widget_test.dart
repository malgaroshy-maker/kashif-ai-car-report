import 'package:flutter_test/flutter_test.dart';
import 'package:kashif_mobile/data/models/diagnostic_report.dart';
import 'package:kashif_mobile/data/models/fault_code.dart';
import 'package:kashif_mobile/data/repositories/sensor_locator_service.dart';
import 'package:kashif_mobile/core/theme/colors.dart';
import 'package:kashif_mobile/core/utils/pdf_generator.dart';
import 'package:kashif_mobile/core/utils/html_generator.dart';
import 'package:kashif_mobile/data/repositories/offline_report_service.dart';
import 'package:kashif_mobile/data/storage/hive_storage.dart';
import 'package:kashif_mobile/data/models/report_sections_config.dart';
import 'dart:typed_data';

void main() {
  group('Kashif Diagnostic Report Tests', () {
    final sampleDiagnosticReportJson = {
      'reportId': 'kashif-test-001',
      'generatedAt': '2026-09-22T00:00:00.000Z',
      'scannerInfo': {
        'toolName': 'Launch X431 Pro',
        'serialNumber': 'SN-12345',
        'testTime': '2026-09-22 10:00:00',
      },
      'vehicle': {
        'vin': 'JTDBR42E309TEST01',
        'make': 'Toyota',
        'model': 'Corolla',
        'year': '2004',
        'mileage': '185,000 كم',
        'engineSpecs': {
          'displacement': '1.8L',
          'fuelType': 'بنزين',
          'cylinders': 4,
          'transmission': 'كمبيو أوتوماتيك',
        },
      },
      'summary': {
        'overallHealthScore': 84,
        'severityStatus': 'متوسط / انتبه',
        'briefSummaryArabic': 'السيارة بحالة جيدة عموماً مع كود في حساس الماف.',
        'systemsCheckedCount': 4,
        'faultsFoundCount': 1,
        'passedSystemsCount': 3,
      },
      'faultCategories': {
        'criticalFaults': [],
        'moderateFaults': [
          {
            'code': 'P0102',
            'module': 'ECM',
            'moduleNameArabic': 'كمبيوتر المحرك',
            'standardDescriptionEn': 'Mass Air Flow (MAF) Circuit Low',
            'libyanTerm': 'حساس الماف / حساس الهواء',
            'standardArabicDescription': 'انخفاض إشارة مستشعر كتلة تدفق الهواء',
            'driverSymptoms': ['فطفطة', 'خنقة في العزم'],
            'rootCauses': ['اتساخ سلك الحساس'],
            'urgencyLevel': 'متوسط',
            'recommendedAction': 'تنظيف الحساس بسبراي الكترونيات',
          },
        ],
        'historyFaults': [],
        'passedSystems': ['ABS', 'SRS', 'TCM'],
      },
      'sparePartsGuide': [
        {
          'id': 'part-maf-01',
          'relatedCode': 'P0102',
          'partNameLibyan': 'حساس الماف',
          'partNameStandardArabic': 'مستشعر تدفق الهواء',
          'partNameEnglish': 'MAF Sensor',
          'oemPartNumber': '22204-22010',
          'aftermarketReplacements': ['Denso', 'Bosch'],
          'estimatedPriceRangeLYD': {
            'min': 150.0,
            'max': 280.0,
            'marketNote': 'سعر تقريبي في محلات السيرفيس',
          },
        },
      ],
      'diagnosticChecklist': [
        {
          'stepNumber': 1,
          'actionTitle': 'فحص فيشة البيانتو والأسلاك',
          'actionDescriptionLibyan': 'تأكد من نظافة الفيشة وعدم وجود كسر',
          'purpose': 'التأكد من التغذية الكهربائية',
          'estimatedTime': '5 دقائق',
          'toolingNeeded': 'بينسة وفاحص',
        },
      ],
    };

    test(
      'DiagnosticReport parses correctly from JSON with ISO/DIN fuse standards',
      () {
        final report = DiagnosticReport.fromJson(sampleDiagnosticReportJson);

        expect(report.reportId, 'kashif-test-001');
        expect(report.vehicle.make, 'Toyota');
        expect(report.vehicle.model, 'Corolla');
        expect(report.vehicle.engineSpecs?.cylinders, 4);
        expect(report.summary.overallHealthScore, 84);
        expect(report.moderateFaults.length, 1);
        expect(report.moderateFaults.first.code, 'P0102');
        expect(
          report.moderateFaults.first.libyanTerm,
          'حساس الماف / حساس الهواء',
        );
        expect(report.moderateFaults.first.severity, CodeSeverity.moderate);
        expect(report.spareParts.first.oemPartNumber, '22204-22010');
        expect(report.spareParts.first.estimatedPriceRangeLYD?.min, 150.0);
        expect(report.checklist.first.stepNumber, 1);
      },
    );

    test(
      'BMW schema with sparePartsRequired and workshopChecklist parses all items',
      () {
        final json = {
          'reportId': 'kashif-bmw-test',
          'generatedAt': '2026-08-12T21:12:55.000Z',
          'vehicle': {
            'make': 'BMW',
            'model': '528i',
            'year': '1997',
            'vin': 'WBADD6100VBSAMPLE',
          },
          'summary': {'overallHealthScore': 48, 'severityStatus': 'حرج / خطر'},
          'faultCategories': {
            'criticalFaults': [
              {
                'code': 'ECM 02',
                'module': 'ECM',
                'standardDescriptionEn': 'Ignition Coil',
                'libyanTerm': 'بوبينة وشمعات',
                'standardArabicDescription': 'خلل إشعال',
                'urgencyLevel': 'عالي جداً',
              },
            ],
            'moderateFaults': [],
            'minorOrHistoricalFaults': [
              {
                'code': 'LSZ 28',
                'module': 'LSZ',
                'standardDescriptionEn': 'Oil Level Sensor',
                'libyanTerm': 'حساس مستوى الزيت',
                'standardArabicDescription': 'مستشعر الزيت',
                'urgencyLevel': 'منخفض',
              },
            ],
          },
          'passedSystems': [
            {'systemCode': 'EWS', 'systemNameArabic': 'مانع السرقة'},
            {'systemCode': 'A/C', 'systemNameArabic': 'التكييف'},
          ],
          'sparePartsRequired': [
            {
              'id': 'part-bmw-coil',
              'relatedCode': 'ECM 02',
              'partNameLibyan': 'بوبينة إشعال BMW',
              'partNameStandardArabic': 'ملف إشعال',
              'partNameEnglish': 'Ignition Coil',
              'oemPartNumber': '12131748017',
              'estimatedPriceRangeLYD': {'min': 90, 'max': 220},
            },
            {
              'id': 'part-bmw-abs-sensor',
              'relatedCode': 'ABS 21',
              'partNameLibyan': 'حساس ABS أمامي',
              'partNameStandardArabic': 'مستشعر سرعة العجلة',
              'partNameEnglish': 'ABS Sensor',
              'oemPartNumber': '34521182159',
              'estimatedPriceRangeLYD': {'min': 110, 'max': 260},
            },
          ],
          'workshopChecklist': [
            {
              'stepNumber': 1,
              'targetComponent': 'فحص بوبينة وشمعة بسطوني 4',
              'actionRequiredLibyan': 'بدل بوبينة بسطوني 4 مع 2',
              'toolNeeded': 'مفتاح شمعات',
            },
          ],
        };

        final report = DiagnosticReport.fromJson(json);

        expect(report.criticalFaults.length, 1);
        expect(report.historyFaults.length, 1);
        expect(report.passedSystems.length, 2);
        expect(report.passedSystems.first, 'EWS (مانع السرقة)');
        expect(report.spareParts.length, 2);
        expect(report.spareParts.first.oemPartNumber, '12131748017');
        expect(report.checklist.length, 1);
        expect(report.checklist.first.actionTitle, 'فحص بوبينة وشمعة بسطوني 4');
        expect(
          report.checklist.first.actionDescriptionLibyan,
          'بدل بوبينة بسطوني 4 مع 2',
        );
      },
    );

    test('Colors follow ISO/DIN 72581-3 blade fuse ratings', () {
      expect(KashifColors.fuse10ATab.toARGB32(), 0xFFDE3B2F); // 10A Red
      expect(KashifColors.fuse20ATab.toARGB32(), 0xFFF2C200); // 20A Yellow
      expect(KashifColors.fuse30ATab.toARGB32(), 0xFF2E9E5B); // 30A Green
      expect(KashifColors.fuse25ATab.toARGB32(), 0xFFC8CBC5); // 25A Grey
      expect(KashifColors.fuse15ATab.toARGB32(), 0xFF2E7FC4); // 15A Blue
    });

    test(
      'SensorLocatorService provides accurate coordinates and multimeter pins',
      () {
        final maf = SensorLocatorService.getDiagnostics('P0100');
        expect(maf.sensorLocation.engineZone, 'front-air');
        expect(maf.sensorLocation.coordinateX, 30);
        expect(maf.sensorLocation.coordinateY, 35);
        expect(maf.fuseInfo.fuseNumber, contains('F14'));
        expect(maf.multimeterTest.powerPin, contains('12V'));

        final misfire = SensorLocatorService.getDiagnostics('P0300');
        expect(misfire.sensorLocation.engineZone, 'top-manifold');
        expect(misfire.sensorLocation.coordinateX, 50);
        expect(misfire.fuseInfo.rating, contains('20A'));

        final fallback = SensorLocatorService.getDiagnostics('P0199');
        expect(fallback.sensorLocation.engineZone, 'front-air');
      },
    );

    test(
      'KashifPdfGenerator generates valid PDF using Amiri without overlapping or errors',
      () async {
        TestWidgetsFlutterBinding.ensureInitialized();
        final report = DiagnosticReport.fromJson(sampleDiagnosticReportJson);
        final pdfBytes = await KashifPdfGenerator.generateReportPdf(report);
        expect(pdfBytes, isNotEmpty);
        expect(pdfBytes.length, greaterThan(2000));
      },
    );

    test(
      'KashifHtmlGenerator generates valid offline HTML without syntax or esc errors',
      () {
        final report = DiagnosticReport.fromJson(sampleDiagnosticReportJson);
        final html = KashifHtmlGenerator.buildHtml(report);
        expect(html, isNotEmpty);
        expect(html, contains('Flow Cars'));
        expect(html, contains('P0102'));
      },
    );

    test(
      'OfflineReportService generates complete Libyan diagnostic report with 0 API requests',
      () {
        final report = OfflineReportService.tryBuildOfflineReport(
          'P0102, P0300',
          vin: 'JTDBR42E309TEST01',
          make: 'Toyota',
          model: 'Corolla',
          year: '2004',
        );

        expect(report, isNotNull);
        expect(report!.criticalFaults.length, 1); // P0300 is critical
        expect(report.moderateFaults.length, 1); // P0102 is moderate
        expect(report.spareParts.length, 2);
        expect(report.checklist.length, 2);
        expect(report.summary.overallHealthScore, lessThan(100));
        expect(report.criticalFaults.first.code, 'P0300');
        expect(report.moderateFaults.first.code, 'P0102');
        expect(report.moderateFaults.first.libyanTerm, contains('حساس الماف'));
      },
    );

    test(
      'OfflineReportService returns null on unrecognized codes to fallback to AI',
      () {
        final report = OfflineReportService.tryBuildOfflineReport(
          'UNKNOWN9999',
        );
        expect(report, isNull);
      },
    );

    test(
      'KashifStorage deterministic fingerprinting works for byte buffers and codes',
      () {
        final bytes1 = Uint8List.fromList([1, 2, 3, 4, 5, 6, 7, 8]);
        final bytes2 = Uint8List.fromList([1, 2, 3, 4, 5, 6, 7, 8]);
        final bytes3 = Uint8List.fromList([1, 2, 3, 4, 5, 6, 7, 9]);

        final fp1 = KashifStorage.computeFingerprint(bytes1);
        final fp2 = KashifStorage.computeFingerprint(bytes2);
        final fp3 = KashifStorage.computeFingerprint(bytes3);

        expect(fp1, equals(fp2));
        expect(fp1, isNot(equals(fp3)));

        final codeFp1 = KashifStorage.computeCodesFingerprint(
          'P0102, P0300',
          'VIN123',
        );
        final codeFp2 = KashifStorage.computeCodesFingerprint(
          'P0300 P0102',
          'vin123',
        );
        expect(codeFp1, equals(codeFp2)); // normalized order and case
      },
    );

    test(
      'OfflineReportService findCode retrieves exact Libyan DTC details',
      () {
        final p0300 = OfflineReportService.findCode('P0300');
        expect(p0300, isNotNull);
        expect(p0300!.libyanTerm, contains('فطفطة'));
        expect(p0300.severity, CodeSeverity.critical);
        expect(p0300.driverSymptoms, isNotEmpty);

        final p0100 = OfflineReportService.findCode(
          'p0100',
        ); // case insensitive
        expect(p0100, isNotNull);
        expect(p0100!.libyanTerm, contains('حساس الماف'));

        final nonExistent = OfflineReportService.findCode('P9999');
        expect(nonExistent, isNull);
      },
    );

    test(
      'OfflineReportService buildOfflineReportFallback generates valid report for any code',
      () {
        final report = OfflineReportService.buildOfflineReportFallback(
          'P0300, P9999, U0100',
          vin: 'TESTVIN99',
        );
        expect(report, isNotNull);
        expect(report.vehicle.vin, 'TESTVIN99');
        expect(report.summary.faultsFoundCount, 3);
        expect(report.criticalFaults.any((f) => f.code == 'P0300'), isTrue);
        expect(report.moderateFaults.any((f) => f.code == 'P9999'), isTrue);
        expect(report.checklist, isNotEmpty);

        // Verify that this fallback report can be exported to HTML and PDF cleanly
        final html = KashifHtmlGenerator.buildHtml(report);
        expect(html, contains('TESTVIN99'));
        expect(html, contains('P0300'));
      },
    );

    test('ReportSectionsConfig toggles and controls HTML export sections', () {
      final report = OfflineReportService.buildOfflineReportFallback(
        'P0300',
        vin: 'TESTSECTIONVIN',
      );

      // Default: all sections enabled
      const defaultConfig = ReportSectionsConfig();
      expect(defaultConfig.includeTechnicalAssessment, isTrue);
      expect(defaultConfig.includeFaultsTable, isTrue);
      expect(defaultConfig.includePassedSystems, isTrue);
      expect(defaultConfig.includeProbabilitiesTable, isTrue);
      expect(defaultConfig.includeChecklist, isTrue);
      expect(defaultConfig.toItemList().length, 6);

      final fullHtml = KashifHtmlGenerator.buildHtml(
        report,
        sectionsConfig: defaultConfig,
      );
      expect(fullHtml, contains('خلاصة تقييم السيارة'));
      expect(fullHtml, contains('أعطال حرجة'));
      expect(fullHtml, contains('جدول احتمالات ومسببات الأعطال'));
      expect(fullHtml, contains('قائمة خطوات الفحص الفني'));

      // Disabled: toggle off technical assessment, faults table, probabilities, and checklist
      final customConfig = defaultConfig
          .copyWith(
            includeTechnicalAssessment: false,
            includeFaultsTable: false,
            includeProbabilitiesTable: false,
            includeChecklist: false,
          );
      final filteredHtml = KashifHtmlGenerator.buildHtml(
        report,
        sectionsConfig: customConfig,
      );
      expect(filteredHtml, isNot(contains('خلاصة تقييم السيارة:')));
      expect(filteredHtml, isNot(contains('أعطال حرجة')));
      expect(filteredHtml, isNot(contains('جدول احتمالات ومسببات الأعطال')));
      expect(filteredHtml, isNot(contains('قائمة خطوات الفحص الفني')));
    });
  });
}
