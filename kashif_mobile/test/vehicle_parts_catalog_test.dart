import 'package:flutter_test/flutter_test.dart';
import 'package:kashif_mobile/data/models/spare_part.dart';
import 'package:kashif_mobile/data/models/vehicle_info.dart';
import 'package:kashif_mobile/data/repositories/part_number_resolver.dart';
import 'package:kashif_mobile/data/repositories/vehicle_parts_catalog.dart';

void main() {
  group('VehiclePartsCatalog & PartNumberResolver Tests', () {
    test('Corrects 1999 Honda Civic ignition, spark plugs, wires and SRS airbag unit', () {
      final civic1999 = VehicleInfo(
        vin: 'SHHMB4760XU100255',
        make: 'HONDA',
        model: 'CIVIC AERO.',
        year: '1999',
      );

      // 1. Erroneous coil pack from modern generation (30510-PLM-A00)
      final wrongCoil = SparePartItem(
        id: 'part_1',
        relatedCode: 'P0301',
        partNameLibyan: 'بوبينة أصلية',
        partNameStandardArabic: 'ملف إشعال المحرك',
        partNameEnglish: 'Ignition Coil',
        oemPartNumber: '30510-PLM-A00',
        aftermarketReplacements: ['Denso 673-1301', 'Bosch 0986221042'],
      );

      // 2. Erroneous lawnmower plug (98066-69010)
      final wrongPlug = SparePartItem(
        id: 'part_2',
        relatedCode: 'P0302',
        partNameLibyan: 'شمعة احتراق أصلية',
        partNameStandardArabic: 'شمعة إشعال',
        partNameEnglish: 'Spark Plug',
        oemPartNumber: '98066-69010',
        aftermarketReplacements: ['NGK BPR6ES'],
      );

      // 3. Erroneous airbag module code (77510-S6A-003)
      final wrongSrs = SparePartItem(
        id: 'part_3',
        relatedCode: 'SRS-07-02',
        partNameLibyan: 'بوكس وسائد هوائية',
        partNameStandardArabic: 'وحدة تحكم الوسائد الهوائية',
        partNameEnglish: 'Airbag Control Unit',
        oemPartNumber: '77510-S6A-003',
        aftermarketReplacements: ['أصلي'],
      );

      final enriched = PartNumberResolver.enrichList(
        [wrongCoil, wrongPlug, wrongSrs],
        vehicle: civic1999,
      );

      // Verify Coil -> Distributor internal coil / distributor assembly
      final resolvedCoil = enriched.firstWhere((p) => p.partNameLibyan.contains('ديلكو') || p.partNameLibyan.contains('بوبينة'));
      expect(resolvedCoil.oemPartNumber, contains('30510-PT2-006'));
      expect(resolvedCoil.oemPartNumber, contains('30100-P2E-A01'));
      expect(resolvedCoil.aftermarketReplacements, anyElement(contains('Hitachi')));

      // Verify Spark Plug -> Honda Extended Reach NGK ZFR5F-11 / 98079-5514P
      final resolvedPlug = enriched.firstWhere((p) => p.partNameLibyan.contains('شمع'));
      expect(resolvedPlug.oemPartNumber, contains('98079-5514P'));
      expect(resolvedPlug.aftermarketReplacements, anyElement(contains('ZFR5F-11')));

      // Verify SRS Unit -> 77960-ST3
      final resolvedSrs = enriched.firstWhere((p) => p.partNameLibyan.contains('وسائد'));
      expect(resolvedSrs.oemPartNumber, contains('77960-ST3'));

      // Verify that spark plug wires (خيوط البوجيهات) are added for 1999 Civic misfire
      final resolvedWires = enriched.firstWhere((p) => p.partNameLibyan.contains('خيوط'));
      expect(resolvedWires.oemPartNumber, equals('32722-P2A-003'));
      expect(resolvedWires.aftermarketReplacements, anyElement(contains('RC-HE73')));
    });

    test('Resolves 2010 Hyundai Santa Fe EVAP and O2 sensor parts', () {
      final santafe2010 = VehicleInfo(
        vin: '5NMSHDAGXAH370930',
        make: 'HYUNDAI',
        model: 'Santa Fe SE',
        year: '2010',
      );

      final purgePart = SparePartItem(
        id: 'part_p1',
        relatedCode: 'P0442',
        partNameLibyan: 'صمام بخر خزان البنزين',
        partNameStandardArabic: 'صمام التحكم في تصريف الوقود',
        partNameEnglish: 'Purge Valve',
        aftermarketReplacements: [],
      );

      final enriched = PartNumberResolver.enrich(purgePart, vehicle: santafe2010);
      expect(enriched.oemPartNumber, contains('28910-25000'));
      expect(enriched.aftermarketReplacements, anyElement(contains('Bosch 0280142427')));
    });

    test('Resolves 2008 Toyota Camry ignition coil and spark plugs', () {
      final camry2008 = VehicleInfo(
        vin: '4T1BE46K08U123456',
        make: 'TOYOTA',
        model: 'Camry',
        year: '2008',
      );

      final coilPart = SparePartItem(
        id: 'c1',
        relatedCode: 'P0351',
        partNameLibyan: 'بوبينة إشعال أصلية',
        partNameStandardArabic: 'ملف إشعال',
        partNameEnglish: 'Ignition Coil',
        aftermarketReplacements: [],
      );

      final enriched = PartNumberResolver.enrich(coilPart, vehicle: camry2008);
      expect(enriched.oemPartNumber, contains('90919-02244'));
      expect(enriched.aftermarketReplacements, anyElement(contains('Denso 673-1307')));
    });
  });
}
