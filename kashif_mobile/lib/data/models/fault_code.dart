enum CodeSeverity {
  critical, // 10A Red
  moderate, // 20A Yellow
  passed,   // 30A Green
  history,  // 25A Grey
}

class ElectricalDiagnosticInfo {
  final String provenance;
  final String boxLocation;
  final String? fuseNumber;
  final String? rating;
  final String? relayName;
  final String circuitDescription;
  final String sensorArea;
  final String multimeterTip;
  final String? powerPin;
  final String? groundPin;
  final String? signalPin;
  final String? warning;

  ElectricalDiagnosticInfo({
    required this.provenance,
    required this.boxLocation,
    this.fuseNumber,
    this.rating,
    this.relayName,
    required this.circuitDescription,
    required this.sensorArea,
    required this.multimeterTip,
    this.powerPin,
    this.groundPin,
    this.signalPin,
    this.warning,
  });

  factory ElectricalDiagnosticInfo.fromJson(Map<String, dynamic> json) {
    final fuse = json['fuseInfo'] as Map<String, dynamic>? ?? {};
    final sensor = json['sensorLocation'] as Map<String, dynamic>? ?? {};
    final multi = json['multimeterTest'] as Map<String, dynamic>? ?? {};

    return ElectricalDiagnosticInfo(
      provenance: json['provenance'] as String? ?? 'general',
      boxLocation: fuse['boxLocation'] as String? ?? '',
      fuseNumber: fuse['fuseNumber'] as String?,
      rating: fuse['rating'] as String?,
      relayName: fuse['relayName'] as String?,
      circuitDescription: fuse['circuitDescription'] as String? ?? '',
      sensorArea: sensor['areaName'] as String? ?? '',
      multimeterTip: multi['testingTipLibyan'] as String? ?? '',
      powerPin: multi['powerPin'] as String?,
      groundPin: multi['groundPin'] as String?,
      signalPin: multi['signalPin'] as String?,
      warning: json['warning'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'provenance': provenance,
        'fuseInfo': {
          'boxLocation': boxLocation,
          'fuseNumber': fuseNumber,
          'rating': rating,
          'relayName': relayName,
          'circuitDescription': circuitDescription,
        },
        'sensorLocation': {
          'areaName': sensorArea,
        },
        'multimeterTest': {
          'testingTipLibyan': multimeterTip,
          'powerPin': powerPin,
          'groundPin': groundPin,
          'signalPin': signalPin,
        },
        'warning': warning,
      };
}

class DiagnosticFaultCode {
  final String code;
  final String module;
  final String moduleNameArabic;
  final String standardDescriptionEn;
  final String libyanTerm;
  final String standardArabicDescription;
  final List<String> driverSymptoms;
  final List<String> rootCauses;
  final String urgencyLevel;
  final String recommendedAction;
  final String? recommendedPartId;
  final CodeSeverity severity;
  final ElectricalDiagnosticInfo? electricalDiagnostics;

  DiagnosticFaultCode({
    required this.code,
    required this.module,
    required this.moduleNameArabic,
    required this.standardDescriptionEn,
    required this.libyanTerm,
    required this.standardArabicDescription,
    required this.driverSymptoms,
    required this.rootCauses,
    required this.urgencyLevel,
    required this.recommendedAction,
    this.recommendedPartId,
    required this.severity,
    this.electricalDiagnostics,
  });

  factory DiagnosticFaultCode.fromJson(Map<String, dynamic> json, {CodeSeverity defaultSeverity = CodeSeverity.moderate}) {
    CodeSeverity sev = defaultSeverity;
    final urgency = json['urgencyLevel']?.toString() ?? '';
    if (urgency.contains('عالي') || urgency.contains('حرج') || urgency.contains('خطر')) {
      sev = CodeSeverity.critical;
    } else if (urgency.contains('تاريخ') || urgency.contains('ذاكرة') || urgency.contains('قديم')) {
      sev = CodeSeverity.history;
    }

    return DiagnosticFaultCode(
      code: json['code'] as String? ?? 'DTC',
      module: json['module'] as String? ?? 'ECM',
      moduleNameArabic: json['moduleNameArabic'] as String? ?? '',
      standardDescriptionEn: json['standardDescriptionEn'] as String? ?? '',
      libyanTerm: json['libyanTerm'] as String? ?? '',
      standardArabicDescription: json['standardArabicDescription'] as String? ?? '',
      driverSymptoms: (json['driverSymptoms'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      rootCauses: (json['rootCauses'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      urgencyLevel: urgency,
      recommendedAction: json['recommendedAction'] as String? ?? '',
      recommendedPartId: json['recommendedPartId'] as String?,
      severity: sev,
      electricalDiagnostics: json['electricalDiagnostics'] != null && json['electricalDiagnostics'] is Map<String, dynamic>
          ? ElectricalDiagnosticInfo.fromJson(json['electricalDiagnostics'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'code': code,
        'module': module,
        'moduleNameArabic': moduleNameArabic,
        'standardDescriptionEn': standardDescriptionEn,
        'libyanTerm': libyanTerm,
        'standardArabicDescription': standardArabicDescription,
        'driverSymptoms': driverSymptoms,
        'rootCauses': rootCauses,
        'urgencyLevel': urgencyLevel,
        'recommendedAction': recommendedAction,
        'recommendedPartId': recommendedPartId,
        'severity': severity.name,
        'electricalDiagnostics': electricalDiagnostics?.toJson(),
      };
}
