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
  final List<String> activeWarningLightIds;

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
    this.activeWarningLightIds = const [],
  });

  static Map<String, dynamic> _asMap(dynamic val) {
    if (val is Map<String, dynamic>) return val;
    if (val is Map) {
      return val.map((k, v) => MapEntry(k.toString(), v));
    }
    return <String, dynamic>{};
  }

  factory DiagnosticReport.fromJson(Map<String, dynamic> json) {
    final vehicleJson = _asMap(json['vehicle']);
    final scannerJson = _asMap(json['scannerInfo']);
    final summaryJson = _asMap(json['summary']);
    final categories = _asMap(json['faultCategories']);

    final critList =
        (categories['criticalFaults'] as List<dynamic>?)
            ?.map(
              (e) => DiagnosticFaultCode.fromJson(
                _asMap(e),
                defaultSeverity: CodeSeverity.critical,
              ),
            )
            .toList() ??
        [];

    final modList =
        (categories['moderateFaults'] as List<dynamic>?)
            ?.map(
              (e) => DiagnosticFaultCode.fromJson(
                _asMap(e),
                defaultSeverity: CodeSeverity.moderate,
              ),
            )
            .toList() ??
        [];

    final rawHist =
        categories['historyFaults'] ??
        categories['minorOrHistoricalFaults'] ??
        json['minorOrHistoricalFaults'];
    final histList =
        (rawHist as List<dynamic>?)
            ?.map(
              (e) => DiagnosticFaultCode.fromJson(
                _asMap(e),
                defaultSeverity: CodeSeverity.history,
              ),
            )
            .toList() ??
        [];

    final rawPassed = json['passedSystems'] ?? categories['passedSystems'];
    final passedList =
        (rawPassed as List<dynamic>?)?.map((e) {
          if (e is Map) {
            final code = e['systemCode']?.toString() ?? '';
            final ar = e['systemNameArabic']?.toString() ?? '';
            return code.isNotEmpty && ar.isNotEmpty
                ? '$code ($ar)'
                : (ar.isNotEmpty ? ar : code);
          }
          return e.toString();
        }).toList() ??
        [];

    final rawParts =
        json['sparePartsRequired'] ??
        json['sparePartsGuide'] ??
        json['spareParts'];
    final partsList =
        (rawParts as List<dynamic>?)
            ?.map((e) => SparePartItem.fromJson(_asMap(e)))
            .toList() ??
        [];

    final rawChecklist =
        json['workshopChecklist'] ??
        json['diagnosticChecklist'] ??
        json['checklist'];
    final checkList =
        (rawChecklist as List<dynamic>?)
            ?.map(
              (e) =>
                  DiagnosticChecklistStep.fromJson(_asMap(e)),
            )
            .toList() ??
        [];

    final rawLights = json['activeWarningLightIds'] ?? json['warningLights'];
    final warningLightsList =
        (rawLights as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [];

    return DiagnosticReport(
      reportId:
          json['reportId'] as String? ??
          'KASHIF-${DateTime.now().millisecondsSinceEpoch}',
      generatedAt:
          json['generatedAt'] as String? ?? DateTime.now().toIso8601String(),
      scannerInfo: ScannerInfo.fromJson(scannerJson),
      vehicle: VehicleInfo.fromJson(vehicleJson),
      summary: ReportSummary.fromJson(summaryJson),
      criticalFaults: critList,
      moderateFaults: modList,
      historyFaults: histList,
      passedSystems: passedList,
      spareParts: partsList,
      checklist: checkList,
      activeWarningLightIds: warningLightsList,
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
    'activeWarningLightIds': activeWarningLightIds,
  };

  DiagnosticReport copyWith({
    String? reportId,
    String? generatedAt,
    ScannerInfo? scannerInfo,
    VehicleInfo? vehicle,
    ReportSummary? summary,
    List<DiagnosticFaultCode>? criticalFaults,
    List<DiagnosticFaultCode>? moderateFaults,
    List<DiagnosticFaultCode>? historyFaults,
    List<String>? passedSystems,
    List<SparePartItem>? spareParts,
    List<DiagnosticChecklistStep>? checklist,
    List<String>? activeWarningLightIds,
  }) {
    return DiagnosticReport(
      reportId: reportId ?? this.reportId,
      generatedAt: generatedAt ?? this.generatedAt,
      scannerInfo: scannerInfo ?? this.scannerInfo,
      vehicle: vehicle ?? this.vehicle,
      summary: summary ?? this.summary,
      criticalFaults: criticalFaults ?? this.criticalFaults,
      moderateFaults: moderateFaults ?? this.moderateFaults,
      historyFaults: historyFaults ?? this.historyFaults,
      passedSystems: passedSystems ?? this.passedSystems,
      spareParts: spareParts ?? this.spareParts,
      checklist: checklist ?? this.checklist,
      activeWarningLightIds:
          activeWarningLightIds ?? this.activeWarningLightIds,
    );
  }

  int get totalFaultsCount =>
      criticalFaults.length + moderateFaults.length + historyFaults.length;

  /// Returns confirmed sound/passed systems, or dynamically derives non-faulted standard systems
  List<String> get soundSystems {
    if (passedSystems.isNotEmpty) {
      return passedSystems;
    }
    final faultedModules = <String>{};
    for (var f in [...criticalFaults, ...moderateFaults, ...historyFaults]) {
      final m = f.module.toUpperCase();
      final code = f.code.toUpperCase();
      if (m.contains('ENG') ||
          m.contains('ECM') ||
          code.startsWith('P0') ||
          code.startsWith('P1')) {
        faultedModules.add('ECM');
      }
      if (m.contains('TRANS') ||
          m.contains('TCM') ||
          code.startsWith('P07') ||
          code.startsWith('P08')) {
        faultedModules.add('TCM');
      }
      if (m.contains('ABS') || code.startsWith('C')) {
        faultedModules.add('ABS');
      }
      if (m.contains('AIR') || m.contains('SRS') || code.startsWith('B00')) {
        faultedModules.add('SRS');
      }
    }

    return [
      if (!faultedModules.contains('TCM'))
        'TCM (منظومة ناقل الحركة الأوتوماتيكي)',
      if (!faultedModules.contains('ABS'))
        'ABS / ESP (منظومة مانع انغلاق المكابح والثبات)',
      if (!faultedModules.contains('SRS'))
        'SRS (منظومة الوسائد الهوائية والسلامة)',
      if (!faultedModules.contains('ECM'))
        'ECM (منظومة حقن الوقود وإدارة المحرك)',
      'BCM (منظومة التحكم بهيكل وكهرباء السيارة)',
      'EPS (منظومة التوجيه الكهربائي / الباور)',
    ];
  }
}
