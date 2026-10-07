import 'dart:io';
import 'dart:convert';
import 'dart:io' as io;
import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:archive/archive.dart';
import 'package:kashif_mobile/core/utils/ediag_pdf_parser.dart';
import 'package:kashif_mobile/data/repositories/offline_report_service.dart';

void main() {
  setUpAll(() {
    OfflineReportService.loadFromJsonString(
        File('assets/data/offline_dtc.json').readAsStringSync());
  });

  test('ZLibDecoder decompresses compressed text stream', () {
    const text = 'Make:TOYOTA\nModel:Camry\nYear:2007\nVIN:4T1BE46K17U046638\n';
    final compressed = ZLibEncoder().encode(utf8.encode(text));
    final decompressed = ZLibDecoder().decodeBytes(compressed);
    final result = utf8.decode(decompressed);
    expect(result, contains('Make:TOYOTA'));
    expect(result, contains('4T1BE46K17U046638'));
  });

  test('Format 1: Extracts Toyota Camry Ediag report accurately', () {
    const reportText = '''
All System Diagnostic Report
The Report is created by Ediag
Vehicle Information
SN:9TBC29728913
Make:TOYOTA
Model:Camry
Year:2007
VIN:4T1BE46K17U046638
Mileage:0 Miles
Test Time:08/05/2026 22:50:36
Inspection Result
SRS-Supplemental Inflatable Restraint System 8 problems exist
1.B1811 Open in Driver's Squib (Dual Stage - 2nd Step) Circuit
2.B1650 Occupant Classification System Malfunction
3.B1653 Driver Side Seat Position Sensor
4.B1655 Seat Belt Buckle Switch (Driver Seat Side)
5.B1660 Passenger Seat Airbag Active Mode Indicator
6.B1811 Open in Driver's Squib (Dual Stage - 2nd Step) Circuit
7.B1821 Open in Side Squib (Driver Seat Side) Circuit
8.B1826 Open in Side Squib (Passenger Seat Side) Circuit
''';

    final extracted = EdiagPdfParser.extractFromText(reportText);

    expect(extracted.isValid, isTrue);
    expect(extracted.serialNumber, '9TBC29728913');
    expect(extracted.make, 'TOYOTA');
    expect(extracted.model, 'Camry');
    expect(extracted.year, '2007');
    expect(extracted.vin, '4T1BE46K17U046638');
    expect(extracted.mileage, '0 Miles');
    expect(extracted.faults.length, 8);
    expect(extracted.faults[0].code, 'B1811');
    expect(extracted.faults[1].code, 'B1650');
    expect(extracted.faults[2].code, 'B1653');
    expect(extracted.faults[3].code, 'B1655');
    expect(extracted.faults[4].code, 'B1660');
    expect(extracted.faults[6].code, 'B1821');
    expect(extracted.faults[7].code, 'B1826');
  });

  test('Format 2: Extracts BMW 528i Ediag multi-module report with OK systems', () {
    const reportText = '''
All System Diagnostic Report
The Report is created by Ediag
Vehicle Information
SN:9TBC29728913
Make:BMW/Rolls Royce/Mini
Model:528i
Year:1997.07
VIN:WBADD6100VBR32540
Mileage:281461 Miles
Test Time:09/24/2026 21:00:40
Inspection Result
ECM-Engine Control Module - DME/DDE 2 problems exist
1.D6 Road - Speed Signal
2.02 Ignition, Cylinder 4
TCM-Transmission Control Module - EGS 1 problems exist
1.29 Wheel Speed,Rear Right
ABS-Anti-Lock Braking System - DSC 2 problems exist
1.05 Wheel Speed,Rear Right,Not Plausible
2.21 Wheel-Speed-Sensor Wire,Front Left,Faulty
IC-Instrument Cluster - INSTR 2 problems exist
1.C7 Tank Sensor 1 (Fuel Pump Side)
2.D7 Tank Sensor 2 (Without Fuel Pump)
SRS-Supplemental Inflatable Restraint System - AIRBAG/SGM-SIM 1 problems exist
1.18 Passenger Seat Occupancy Detector
LSZ/LCM-Light Switching Center 4 problems exist
1.16 Vertical Headlight Control Potentiometer, Wire Open
2.1F Control Of Q21/Q22 HVA
3.20 Control Of Q11/Q12 HVA
4.28 Thermal Sensor For Oillevel Defect
The following systems are OK:
1.EWS-Elec. Immobilize System
2.RAD-Radio
3.ZKE-Central Body Electronic
4.A/C-Air Conditioning - IHKA
5.MFL-Multi-Function Steering Wheel
6.MID-Multi Information Display
''';

    final extracted = EdiagPdfParser.extractFromText(reportText);

    expect(extracted.isValid, isTrue);
    expect(extracted.serialNumber, '9TBC29728913');
    expect(extracted.make, 'BMW/Rolls Royce/Mini');
    expect(extracted.model, '528i');
    expect(extracted.year, '1997.07');
    expect(extracted.vin, 'WBADD6100VBR32540');
    expect(extracted.mileage, '281461 Miles');

    // 2 (ECM) + 1 (TCM) + 2 (ABS) + 2 (IC) + 1 (SRS) + 4 (LSZ) = 12 faults
    expect(extracted.faults.length, 12);
    expect(extracted.faults[0].fullCode, 'ECM D6');
    expect(extracted.faults[1].fullCode, 'ECM 02');
    expect(extracted.faults[2].fullCode, 'TCM 29');
    expect(extracted.faults[3].fullCode, 'ABS 05');
    expect(extracted.faults[4].fullCode, 'ABS 21');
    expect(extracted.faults[5].fullCode, 'IC C7');
    expect(extracted.faults[6].fullCode, 'IC D7');
    expect(extracted.faults[7].fullCode, 'SRS 18');
    expect(extracted.faults[8].fullCode, 'LSZ 16');
    expect(extracted.faults[9].fullCode, 'LSZ 1F');
    expect(extracted.faults[10].fullCode, 'LSZ 20');
    expect(extracted.faults[11].fullCode, 'LSZ 28');

    // Passed systems: 6
    expect(extracted.passedSystems.length, 6);
    expect(extracted.passedSystems[0], 'EWS-Elec. Immobilize System');
    expect(extracted.passedSystems[1], 'RAD-Radio');
    expect(extracted.passedSystems[2], 'ZKE-Central Body Electronic');
    expect(extracted.passedSystems[3], 'A/C-Air Conditioning - IHKA');
    expect(extracted.passedSystems[4], 'MFL-Multi-Function Steering Wheel');
    expect(extracted.passedSystems[5], 'MID-Multi Information Display');
  });

  test('Handles PDF binary stream unpacking and text extraction', () {
    const rawContent = '''BT
/F1 12 Tf
(All System Diagnostic Report) Tj ET
BT
(The Report is created by Ediag) Tj ET
BT
(Make:TOYOTA) Tj ET
BT
(Model:Camry) Tj ET
BT
(VIN:4T1BE46K17U046638) Tj ET
BT
(SRS 1 problems exist) Tj ET
BT
(1.B1811 Squib Circuit) Tj ET
''';
    final compressedStream = ZLibEncoder().encode(utf8.encode(rawContent));
    
    // Build a mock PDF file in memory
    final pdfHeader = ascii.encode('%PDF-1.4\n1 0 obj\n<< /Length ${compressedStream.length} /Filter /FlateDecode >>\nstream\n');
    final pdfFooter = ascii.encode('\nendstream\nendobj\ntrailer\n<<>>\n%%EOF');
    
    final fullPdf = Uint8List.fromList([
      ...pdfHeader,
      ...compressedStream,
      ...pdfFooter,
    ]);

    final extracted = EdiagPdfParser.extractFromPdfBytes(fullPdf);
    expect(extracted.isValid, isTrue);
    expect(extracted.make, 'TOYOTA');
    expect(extracted.model, 'Camry');
    expect(extracted.vin, '4T1BE46K17U046638');
    expect(extracted.faults.length, 1);
    expect(extracted.faults[0].code, 'B1811');
  });

  test('OfflineReportService generates complete report for Toyota Camry SRS Ediag format', () {
    const reportText = '''
All System Diagnostic Report
The Report is created by Ediag
Vehicle Information
SN:9TBC29728913
Make:TOYOTA
Model:Camry
Year:2007
VIN:4T1BE46K17U046638
Mileage:0 Miles
Test Time:08/05/2026 22:50:36
Inspection Result
SRS-Supplemental Inflatable Restraint System 8 problems exist
1.B1811 Open in Driver's Squib (Dual Stage - 2nd Step) Circuit
2.B1650 Occupant Classification System Malfunction
3.B1653 Driver Side Seat Position Sensor
4.B1655 Seat Belt Buckle Switch (Driver Seat Side)
5.B1660 Passenger Seat Airbag Active Mode Indicator
6.B1811 Open in Driver's Squib (Dual Stage - 2nd Step) Circuit
7.B1821 Open in Side Squib (Driver Seat Side) Circuit
8.B1826 Open in Side Squib (Passenger Seat Side) Circuit
''';

    final extracted = EdiagPdfParser.extractFromText(reportText);
    final report = OfflineReportService.buildOfflineReportFromEdiag(extracted);

    expect(report.vehicle.make, 'TOYOTA');
    expect(report.vehicle.model, 'Camry');
    expect(report.vehicle.year, '2007');
    expect(report.vehicle.vin, '4T1BE46K17U046638');
    expect(report.scannerInfo.toolName.contains('Ediag'), isFalse);
    expect(report.criticalFaults.isNotEmpty, isTrue);
    expect(report.spareParts.isNotEmpty, isTrue);
    expect(report.checklist.isNotEmpty, isTrue);
    expect(report.passedSystems.isNotEmpty, isTrue);
    expect(report.summary.faultsFoundCount, 8);
    expect(report.summary.briefSummaryArabic, contains('تويوتا كامري'));
  });

  test('OfflineReportService generates complete report for BMW 528i Ediag format with healthy systems', () {
    const reportText = '''
All System Diagnostic Report
The Report is created by Ediag
Vehicle Information
SN:9TBC29728913
Make:BMW/Rolls Royce/Mini
Model:528i
Year:1997.07
VIN:WBADD6100VBR32540
Mileage:281461 Miles
Test Time:09/24/2026 21:00:40
Inspection Result
ECM-Engine Control Module - DME/DDE 2 problems exist
1.D6 Road - Speed Signal
2.02 Ignition, Cylinder 4
TCM-Transmission Control Module - EGS 1 problems exist
1.29 Wheel Speed,Rear Right
ABS-Anti-Lock Braking System - DSC 2 problems exist
1.05 Wheel Speed,Rear Right,Not Plausible
2.21 Wheel-Speed-Sensor Wire,Front Left,Faulty
IC-Instrument Cluster - INSTR 2 problems exist
1.C7 Tank Sensor 1 (Fuel Pump Side)
2.D7 Tank Sensor 2 (Without Fuel Pump)
SRS-Supplemental Inflatable Restraint System - AIRBAG/SGM-SIM 1 problems exist
1.18 Passenger Seat Occupancy Detector
LSZ/LCM-Light Switching Center 4 problems exist
1.16 Vertical Headlight Control Potentiometer, Wire Open
2.1F Control Of Q21/Q22 HVA
3.20 Control Of Q11/Q12 HVA
4.28 Thermal Sensor For Oillevel Defect
The following systems are OK:
1.EWS-Elec. Immobilize System
2.RAD-Radio
3.ZKE-Central Body Electronic
4.A/C-Air Conditioning - IHKA
5.MFL-Multi-Function Steering Wheel
6.MID-Multi Information Display
''';

    final extracted = EdiagPdfParser.extractFromText(reportText);
    final report = OfflineReportService.buildOfflineReportFromEdiag(extracted);

    expect(report.vehicle.make, 'BMW/Rolls Royce/Mini');
    expect(report.vehicle.model, '528i');
    expect(report.vehicle.year, '1997.07');
    expect(report.vehicle.vin, 'WBADD6100VBR32540');
    expect(report.vehicle.mileage, '281461 Miles');
    expect(report.scannerInfo.toolName, contains('فحص كمبيوتر'));
    expect(report.criticalFaults.isNotEmpty, isTrue);
    expect(report.summary.faultsFoundCount, 12);
    expect(report.summary.passedSystemsCount, 6);
    expect(report.passedSystems.length, 6);
    expect(report.passedSystems[0], contains('EWS'));
    expect(report.passedSystems[1], contains('RAD'));
    expect(report.passedSystems[3], contains('IHKA'));
    expect(report.summary.briefSummaryArabic, contains('BMW 528i'));
    expect(report.spareParts.isNotEmpty, isTrue);
  });

  test('Parses real user uploaded BMW Ediag PDF file', () {
    final pdfFile = io.File(r'C:\Users\Administrator\.gemini\antigravity-ide\brain\30bbd297-517b-4df7-8174-9529b6e2efed\.user_uploaded\media_1790797708531.pdf');
    if (!pdfFile.existsSync()) {
      print('File does not exist');
      return;
    }
    final bytes = pdfFile.readAsBytesSync();
    final extracted = EdiagPdfParser.extractFromPdfBytes(bytes);

    expect(extracted.isValid, isTrue);
    expect(extracted.make, contains('BMW'));
    expect(extracted.model, '528i');
    expect(extracted.vin, 'WBADD6100VBR32540');
    expect(extracted.mileage, '281461 Miles');
    expect(extracted.faults.length, 12);
    expect(extracted.passedSystems.length, 6);

    final report = OfflineReportService.buildOfflineReportFromEdiag(extracted);
    expect(report.vehicle.make, contains('BMW'));
    expect(report.vehicle.model, '528i');
    expect(report.vehicle.vin, 'WBADD6100VBR32540');
    expect(report.summary.faultsFoundCount, 12);
    expect(report.summary.passedSystemsCount, 6);
  });

  test('Format 3: Extracts Hyundai Elantra(HD) EPS report with Present status and OK systems', () {
    const reportText = '''
 All System Diagnostic Report 
The Report is created by Ediag
Vehicle Information
SN:9TBC29728913
Make:HYUNDAI
Model:Elantra(HD)
Year:2010
VIN:KMHDT41BBAU848023
Mileage:0 Miles
Test Time:09/17/2026 14:29:01
 Inspection Result
EPS - Electronic Power Steering 4 problems exist
1.C1259 Steering Angle Sensor-Electrical
Present
2.C1290 Torque Sensor Main Signal Fault
Present
3.C1611 CAN Time-Out EMS
Present
4.C1261 Steering Angle Sensor Not Calibrated
Present
The following systems are OK:
1.ECM - Engine Control Module-Leaded All
2.ECM - Engine Control Module-Unleaded EOBD
3.ECM - Engine Control Module-Unleaded GEN
4.TCM - Transmission Control Module
5.ABS - Anti-lock Braking System
6.SRS - Supplemental Inflatable Restraint System
7.IMM - Immobilizer 
''';

    final extracted = EdiagPdfParser.extractFromText(reportText);

    expect(extracted.isValid, isTrue);
    expect(extracted.serialNumber, '9TBC29728913');
    expect(extracted.make, 'HYUNDAI');
    expect(extracted.model, 'Elantra(HD)');
    expect(extracted.year, '2010');
    expect(extracted.vin, 'KMHDT41BBAU848023');
    expect(extracted.mileage, '0 Miles');

    // 4 EPS faults
    expect(extracted.faults.length, 4);
    expect(extracted.faults[0].code, 'C1259');
    expect(extracted.faults[0].description, 'Steering Angle Sensor-Electrical');
    expect(extracted.faults[0].status, 'Present');

    expect(extracted.faults[1].code, 'C1290');
    expect(extracted.faults[1].description, 'Torque Sensor Main Signal Fault');
    expect(extracted.faults[1].status, 'Present');

    expect(extracted.faults[2].code, 'C1611');
    expect(extracted.faults[2].description, 'CAN Time-Out EMS');
    expect(extracted.faults[2].status, 'Present');

    expect(extracted.faults[3].code, 'C1261');
    expect(extracted.faults[3].description, 'Steering Angle Sensor Not Calibrated');
    expect(extracted.faults[3].status, 'Present');

    // 7 OK systems
    expect(extracted.passedSystems.length, 7);
    expect(extracted.passedSystems, contains('ABS - Anti-lock Braking System'));
    expect(extracted.passedSystems, contains('IMM - Immobilizer'));

    // Check Offline Diagnostic Report Generation
    final report = OfflineReportService.buildOfflineReportFromEdiag(extracted);
    expect(report.vehicle.make, 'HYUNDAI');
    expect(report.vehicle.model, 'Elantra(HD)');
    expect(report.vehicle.year, '2010');
    expect(report.vehicle.vin, 'KMHDT41BBAU848023');
    expect(report.summary.faultsFoundCount, 4);
    expect(report.summary.briefSummaryArabic, contains('هيونداي'));
    expect(report.summary.briefSummaryArabic, contains('EPS'));
    expect(report.spareParts.isNotEmpty, isTrue);
    expect(report.checklist.isNotEmpty, isTrue);
    expect(report.checklist.any((s) => s.actionTitle.contains('معايرة')), isTrue);
    expect(report.passedSystems.any((s) => s.contains('IMM')), isTrue);
  });

  test('Parses newly uploaded user PDFs if present on disk', () {
    final pdf1 = io.File(r'C:\Users\Administrator\.gemini\antigravity-ide\brain\30bbd297-517b-4df7-8174-9529b6e2efed\.user_uploaded\media_1790802325428.pdf');
    final pdf2 = io.File(r'C:\Users\Administrator\.gemini\antigravity-ide\brain\30bbd297-517b-4df7-8174-9529b6e2efed\.user_uploaded\media_1790802331322.pdf');

    if (pdf1.existsSync()) {
      final bytes = pdf1.readAsBytesSync();
      final extracted = EdiagPdfParser.extractFromPdfBytes(bytes);
      expect(extracted.isValid, isTrue);
      expect(extracted.faults.isNotEmpty, isTrue);
      final report = OfflineReportService.buildOfflineReportFromEdiag(extracted);
      expect(report.vehicle.vin, isNotEmpty);
    }

    if (pdf2.existsSync()) {
      final bytes = pdf2.readAsBytesSync();
      final extracted = EdiagPdfParser.extractFromPdfBytes(bytes);
      expect(extracted.isValid, isTrue);
      expect(extracted.faults.isNotEmpty, isTrue);
      final report = OfflineReportService.buildOfflineReportFromEdiag(extracted);
      expect(report.vehicle.vin, isNotEmpty);
    }
  });

  test('Scanner tool brand names (Ediag, Launch) are completely eliminated from customer-facing reports', () {
    const rawReport = '''
All System Diagnostic Report
The Report is created by Ediag
Vehicle Information
SN:9TBC29728913
Make:BMW/Rolls Royce/Mini
Model:528i
Year:1997.07
VIN:WBADD6100VBR32540
Mileage:281461 Miles
Test Time:09/24/2026 21:00:40
Inspection Result
ECM-Engine Control Module - DME/DDE 1 problems exist
1.02 Ignition, Cylinder 4
''';

    final extracted = EdiagPdfParser.extractFromText(rawReport);
    final report = OfflineReportService.buildOfflineReportFromEdiag(extracted);

    // Assert that the customer-facing summary does NOT contain Ediag or Launch
    expect(report.summary.briefSummaryArabic.contains('Ediag'), isFalse);
    expect(report.summary.briefSummaryArabic.contains('Launch'), isFalse);
    expect(report.scannerInfo.toolName.contains('Ediag'), isFalse);

    for (final step in report.checklist) {
      expect(step.actionDescriptionLibyan.contains('Ediag'), isFalse);
      expect(step.toolingNeeded.contains('Ediag'), isFalse);
    }
  });
}
