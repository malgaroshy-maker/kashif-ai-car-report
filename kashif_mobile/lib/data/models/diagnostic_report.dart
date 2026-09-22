import 'vehicle_info.dart';
import 'fault_code.dart';
import 'spare_part.dart';
import 'checklist_step.dart';

class ScannerInfo {
  final String toolName;
  final String serialNumber;
  final String testTime;

  ScannerInfo({
    this.toolName = 'OBD-II Scanner',
    this.serialNumber = '',
    this.testTime = '',
  });

  factory ScannerInfo.fromJson(Map<String, dynamic> json) {
    return ScannerInfo(
      toolName: json['toolName'] as String? ?? 'OBD-II Scanner',
      serialNumber: json['serialNumber'] as String? ?? '',
      testTime: json['testTime'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'toolName': toolName,
        'serialNumber': serialNumber,
        'testTime': testTime,
      };
}

class ReportSummary {
  final int overallHealthScore;
  final String severityStatus;
  final String briefSummaryArabic;
  final int systemsCheckedCount;
  final int faultsFoundCount;
  final int passedSystemsCount;

  ReportSummary({
    this.overallHealthScore = 100,
    this.severityStatus = 'سليم / خفيف',
    this.briefSummaryArabic = '',
    this.systemsCheckedCount = 0,
    this.faultsFoundCount = 0,
    this.passedSystemsCount = 0,
  });

  factory ReportSummary.fromJson(Map<String, dynamic> json) {
    return ReportSummary(
      overallHealthScore: (json['overallHealthScore'] is num)
          ? (json['overallHealthScore'] as num).toInt()
          : int.tryParse(json['overallHealthScore']?.toString() ?? '') ?? 100,
      severityStatus: json['severityStatus'] as String? ?? 'سليم / خفيف',
      briefSummaryArabic: json['briefSummaryArabic'] as String? ?? '',
      systemsCheckedCount: (json['systemsCheckedCount'] is num)
          ? (json['systemsCheckedCount'] as num).toInt()
          : 0,
      faultsFoundCount: (json['faultsFoundCount'] is num)
          ? (json['faultsFoundCount'] as num).toInt()
          : 0,
      passedSystemsCount: (json['passedSystemsCount'] is num)
          ? (json['passedSystemsCount'] as num).toInt()
          : 0,
    );
  }

  Map<String, dynamic> toJson() => {
        'overallHealthScore': overallHealthScore,
        'severityStatus': severityStatus,
        'briefSummaryArabic': briefSummaryArabic,
        'systemsCheckedCount': systemsCheckedCount,
        'faultsFoundCount': faultsFoundCount,
        'passedSystemsCount': passedSystemsCount,
      };
}

class DiagnosticReport {
  final String reportId;
  final String generatedAt;
  final ScannerInfo scannerInfo;
  final VehicleInfo vehicle;
  final ReportSummary summary;
  final List<DiagnosticFaultCode> criticalFaults;
  final List<DiagnosticFaultCode> moderateFaults;
  final List<DiagnosticFaultCode> historyFaults;
  final List<String> passedSystems;
  final List<SparePartItem> spareParts;
  final List<DiagnosticChecklistStep> checklist;

  DiagnosticReport({
    required this.reportId,
    required this.generatedAt,
    required this.scannerInfo,
    required this.vehicle,
    required this.summary,
    required this.criticalFaults,
    required this.moderateFaults,
    required this.historyFaults,
    required this.passedSystems,
    required this.spareParts,
    required this.checklist,
  });

  factory DiagnosticReport.fromJson(Map<String, dynamic> json) {
    final vehicleJson = json['vehicle'] as Map<String, dynamic>? ?? {};
    final scannerJson = json['scannerInfo'] as Map<String, dynamic>? ?? {};
    final summaryJson = json['summary'] as Map<String, dynamic>? ?? {};
    final categories = json['faultCategories'] as Map<String, dynamic>? ?? {};

    final critList = (categories['criticalFaults'] as List<dynamic>?)
            ?.map((e) => DiagnosticFaultCode.fromJson(e as Map<String, dynamic>,
                defaultSeverity: CodeSeverity.critical))
            .toList() ??
        [];

    final modList = (categories['moderateFaults'] as List<dynamic>?)
            ?.map((e) => DiagnosticFaultCode.fromJson(e as Map<String, dynamic>,
                defaultSeverity: CodeSeverity.moderate))
            .toList() ??
        [];

    final rawHist = categories['historyFaults'] ??
        categories['minorOrHistoricalFaults'] ??
        json['minorOrHistoricalFaults'];
    final histList = (rawHist as List<dynamic>?)
            ?.map((e) => DiagnosticFaultCode.fromJson(e as Map<String, dynamic>,
                defaultSeverity: CodeSeverity.history))
            .toList() ??
        [];

    final rawPassed = json['passedSystems'] ?? categories['passedSystems'];
    final passedList = (rawPassed as List<dynamic>?)?.map((e) {
          if (e is Map) {
            final code = e['systemCode']?.toString() ?? '';
            final ar = e['systemNameArabic']?.toString() ?? '';
            return code.isNotEmpty && ar.isNotEmpty ? '$code ($ar)' : (ar.isNotEmpty ? ar : code);
          }
          return e.toString();
        }).toList() ??
        [];

    final rawParts = json['sparePartsRequired'] ??
        json['sparePartsGuide'] ??
        json['spareParts'];
    final partsList = (rawParts as List<dynamic>?)
            ?.map((e) => SparePartItem.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];

    final rawChecklist = json['workshopChecklist'] ??
        json['diagnosticChecklist'] ??
        json['checklist'];
    final checkList = (rawChecklist as List<dynamic>?)
            ?.map((e) => DiagnosticChecklistStep.fromJson(e as Map<String, dynamic>))
            .toList() ??
        [];

    return DiagnosticReport(
      reportId: json['reportId'] as String? ?? 'KASHIF-${DateTime.now().millisecondsSinceEpoch}',
      generatedAt: json['generatedAt'] as String? ?? DateTime.now().toIso8601String(),
      scannerInfo: ScannerInfo.fromJson(scannerJson),
      vehicle: VehicleInfo.fromJson(vehicleJson),
      summary: ReportSummary.fromJson(summaryJson),
      criticalFaults: critList,
      moderateFaults: modList,
      historyFaults: histList,
      passedSystems: passedList,
      spareParts: partsList,
      checklist: checkList,
    );
  }

  Map<String, dynamic> toJson() => {
        'reportId': reportId,
        'generatedAt': generatedAt,
        'scannerInfo': scannerInfo.toJson(),
        'vehicle': vehicle.toJson(),
        'summary': summary.toJson(),
        'faultCategories': {
          'criticalFaults': criticalFaults.map((e) => e.toJson()).toList(),
          'moderateFaults': moderateFaults.map((e) => e.toJson()).toList(),
          'historyFaults': historyFaults.map((e) => e.toJson()).toList(),
          'passedSystems': passedSystems,
        },
        'sparePartsGuide': spareParts.map((e) => e.toJson()).toList(),
        'diagnosticChecklist': checklist.map((e) => e.toJson()).toList(),
      };

  int get totalFaultsCount => criticalFaults.length + moderateFaults.length + historyFaults.length;
}
