import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:kashif_mobile/core/utils/ediag_pdf_parser.dart';
import 'package:kashif_mobile/core/utils/report_sanitizer.dart';
import 'package:kashif_mobile/data/repositories/dashboard_lights_repository.dart';
import 'package:kashif_mobile/data/repositories/offline_report_service.dart';

final _banned = RegExp(
  r'ناقل الحركة|(?<![ء-ي])(ال)?(قير|جير|فتيس|طرمبة|راديتر|رديتر|بواجي|شكمان|دركسيون|سلندر)(?![ء-ي])',
);

void main() {
  setUpAll(() {
    OfflineReportService.loadFromJsonString(
        File('assets/data/offline_dtc.json').readAsStringSync());
  });

  const cases = {
    'تغيير طرمبة البنزين وفلتر الزيت وزيت القير': 'تغيير بومبة البنزين وفيلترو الزيت وزيت الكمبيو',
    'الرديتر والمساعدات': 'الرداتوري والمزاطوريات',
    'تلف مضخة الوقود': 'تلف بومبة الوقود',
    'استبدال بواجي وكويلات': 'استبدال شمعات وبوبينات',
    'تسرب من الكرتير': 'تسرب من الستاقوبا',
    'تيل الفرامل متآكل': 'باطنيات ديسكو متآكل',
    'سلندر رقم 3': 'بسطوني رقم 3',
    'حسب رقم الشاصي وتأريض الشاسي': 'حسب رقم الهيكل وتأريض الهيكل',
  };

  for (final e in cases.entries) {
    test('clean: ${e.key}', () => expect(ReportSanitizer.clean(e.key), e.value));
  }

  test('no unexpanded group references leak (regression for \$1 bug)', () {
    for (final k in cases.keys) {
      expect(ReportSanitizer.clean(k).contains(RegExp(r'\$\d')), isFalse);
    }
  });

  test('idempotent', () {
    for (final k in cases.keys) {
      final once = ReportSanitizer.clean(k);
      expect(ReportSanitizer.clean(once), once);
    }
  });

  test('applyTerms keeps whitespace and newlines', () {
    expect(ReportSanitizer.applyTerms('أ\n  طرمبة\n'), 'أ\n  بومبة\n');
  });

  test('offline reports contain no non-Libyan terms', () {
    for (final codes in ['P0300 P0171', 'P0700 P0420 C0035', 'U0100 P0087 B0001']) {
      final r = OfflineReportService.buildOfflineReportFallback(codes);
      expect(r.toJson().toString().contains(_banned), isFalse, reason: codes);
    }
  });

  test('offline DTC dictionary loads and resolves codes', () {
    expect(OfflineReportService.getAllKnowledge().length, greaterThan(50));
    expect(OfflineReportService.findCode('P0300'), isNotNull);
    expect(OfflineReportService.canResolveFullyOffline(['P0300']), isTrue);
  });

  test('dashboard light data uses Libyan terms', () {
    for (final l in DashboardLightsRepository.allLights) {
      final text = '${l.nameArabic} ${l.meaningArabic} ${l.commonCauses.join(" ")} ${l.actionRequired}';
      expect(text.contains(_banned), isFalse, reason: l.id);
    }
  });

  test('real Opel Astra-G Ediag report: all 9 faults parsed, none invented', () {
    const raw = '''
All System Diagnostic Report
Make:OPEL
Model:Astra-G
Year:1999
Inspection Result
Engine 5 problems exist
1.P0340-0 Camshaft Sensor Incorrect Signal
Not Present
2.P0105-1 Manifold Absolute Pressure (MAP) Sensor
Voltage High
Not Present
3.P0200-0 Fuel Injector Circuit(s)
Not Present
4.P0335-8 Incorrect RPM Signal
Not Present
5.P0607-0 Knock Control Module; Replace Electronic
Control Unit (ECU)
Not Present
Airbag SAB6 2 problems exist
1.16 Driver Pre-tensioner belt Signal too  large
Invalid
2.25 Passenger Airbag Squib Circuit Signal High
Invalid
IC-Instrument Cluster 1 problems exist
1.164 Engine Coolant Temperature Incorrect Signal
Not Present
Radio CDR 500 1 problems exist
1.41 No FM Radio Stations Found
Present
The following systems are OK:
1.ABS-5.3/5.4(+TC) -ABS-Antilock Brake Module-5.3/5.4(+TC)
''';
    final ex = EdiagPdfParser.extractFromText(raw);
    expect(ex.faults.map((f) => f.code).toList(),
        ['P0340', 'P0105', 'P0200', 'P0335', 'P0607', '16', '25', '164', '41']);
    expect(ex.faults.first.status, 'Not Present');
    final r = OfflineReportService.buildOfflineReportFromEdiag(ex);
    expect(r.totalFaultsCount, 9);
    final all = r.toJson().toString();
    expect(all.contains('ارتفاع الفنارات'), isFalse); // BMW lighting code must not leak
    expect(all.contains('طقطوقة'), isFalse);
    for (final p in r.spareParts) {
      expect(p.oemPartNumber == null || !RegExp(r'221-824|24801').hasMatch(p.oemPartNumber!), isTrue);
    }
  });
}
