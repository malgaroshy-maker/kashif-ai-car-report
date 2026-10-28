import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kashif_mobile/data/models/diagnostic_report.dart';
import 'package:kashif_mobile/data/repositories/car_fuse_repository.dart';
import 'package:kashif_mobile/presentation/providers/report_provider.dart';
import 'package:kashif_mobile/presentation/screens/fuse_box_screen.dart';
import 'package:kashif_mobile/presentation/screens/report_screen.dart';

void main() {
  group('Report-to-FuseBox Automatic Synchronization Tests', () {
    test('CarFuseRepository.matchCar matches authentic cars including Honda Civic and Santa Fe', () {
      final civic = CarFuseRepository.matchCar(
        make: 'HONDA',
        model: 'CIVIC AERO.',
        year: '1999',
      );
      expect(civic, isNotNull);
      expect(civic!.id, equals('honda_civic_1996_2005'));
      expect(civic.make, equals('Honda'));
      expect(civic.fuseBoxes.length, greaterThanOrEqualTo(2));

      final santaFe = CarFuseRepository.matchCar(
        make: 'HYUNDAI',
        model: 'Santa Fe SE',
        year: '2010',
      );
      expect(santaFe, isNotNull);
      expect(santaFe!.id, equals('hyundai_santa_fe_cm'));

      final camry = CarFuseRepository.matchCar(
        make: 'TOYOTA',
        model: 'Camry LE',
        year: '2008',
      );
      expect(camry, isNotNull);
      expect(camry!.id, equals('toyota_camry_2007_2017'));
    });

    test('Associates report DTCs with car fuse slots', () {
      final civic = CarFuseRepository.getCarById('honda_civic_1996_2005')!;
      final misfireFuses = CarFuseRepository.searchFuses(
        car: civic,
        dtcCodes: ['P0301', 'P0302', 'P1399', 'SRS-07-02'],
      );
      expect(misfireFuses, isNotEmpty);
      expect(misfireFuses.any((f) => f.slotId == 'F31'), isTrue); // Ignition coil fuse
      expect(misfireFuses.any((f) => f.slotId == 'F42'), isTrue); // SRS Airbag fuse
    });

    testWidgets('FuseBoxScreen automatically initializes with active report vehicle and shows banner', (tester) async {
      final civicReport = DiagnosticReport.fromJson({
        'reportId': 'rep_civic_123',
        'generatedAt': '2026-10-27T10:00:00Z',
        'vehicle': {
          'make': 'HONDA',
          'model': 'CIVIC AERO.',
          'year': '1999',
          'vin': 'SHHMB4760XU100255',
        },
        'summary': {
          'overallHealthScore': 65,
          'severityStatus': 'مهم',
          'briefSummaryArabic': 'فحص هوندا سيفيك',
          'systemsCheckedCount': 4,
          'faultsFoundCount': 2,
          'passedSystemsCount': 2,
        },
        'faultCategories': {
          'criticalFaults': [
            {
              'code': 'P0301',
              'module': 'ECM',
              'moduleNameArabic': 'المحرك',
              'standardDescriptionEn': 'Cylinder 1 Misfire',
              'libyanTerm': 'فطفطة في السلندر الأول',
              'standardArabicDescription': 'فقد إشعال في الأسطوانة 1',
              'driverSymptoms': ['رجفة بالمحرك'],
              'rootCauses': ['تلف بوبينة أو خيط شمعة'],
              'urgencyLevel': 'مهم',
              'recommendedAction': 'فحص خيط الشمعة',
            },
            {
              'code': 'SRS-07-02',
              'module': 'SRS',
              'moduleNameArabic': 'الوسائد الهوائية',
              'standardDescriptionEn': 'SRS Unit Malfunction',
              'libyanTerm': 'عطل في بوكس الوسائد الهوائية',
              'standardArabicDescription': 'خلل وحدة الإيرباق',
              'driverSymptoms': ['لمبة الإيرباق تضيء'],
              'rootCauses': ['فيوز أو بوكس الوسائد'],
              'urgencyLevel': 'مهم',
              'recommendedAction': 'فحص فيوز SRS',
            },
          ],
        },
      });

      final container = ProviderContainer();
      container.read(reportProvider.notifier).setReport(civicReport);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: Scaffold(
              body: FuseBoxScreen(showAppBar: false),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify Honda Civic is automatically selected without user having to search!
      expect(find.text('هوندا'), findsOneWidget);
      expect(find.textContaining('سيفيك'), findsWidgets);
      expect(find.textContaining('سيارة الفحص بالتقرير الحالي'), findsOneWidget);
      expect(find.textContaining('أعطال الفحص'), findsOneWidget);
    });

    testWidgets('ReportScreen has direct button to navigate to vehicle fuses', (tester) async {
      final civicReport = DiagnosticReport.fromJson({
        'reportId': 'rep_civic_999',
        'generatedAt': '2026-10-27T10:00:00Z',
        'vehicle': {
          'make': 'HONDA',
          'model': 'CIVIC AERO.',
          'year': '1999',
          'vin': 'SHHMB4760XU100255',
        },
        'summary': {
          'overallHealthScore': 70,
          'severityStatus': 'مهم',
          'briefSummaryArabic': 'فحص هوندا',
          'systemsCheckedCount': 2,
          'faultsFoundCount': 0,
          'passedSystemsCount': 2,
        },
        'faultCategories': {},
      });

      final container = ProviderContainer();
      container.read(reportProvider.notifier).setReport(civicReport);

      bool navigatedToFuses = false;

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            home: Scaffold(
              body: ReportScreen(
                onNavigateToFuses: () {
                  navigatedToFuses = true;
                },
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final fuseBtn = find.textContaining('فحص مخطط وعلب فيوزات السيارة مباشرة');
      expect(fuseBtn, findsOneWidget);

      await tester.tap(fuseBtn);
      await tester.pumpAndSettle();

      expect(navigatedToFuses, isTrue);
    });
  });
}
