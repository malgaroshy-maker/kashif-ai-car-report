import '../../core/utils/report_sanitizer.dart';

class DiagnosticChecklistStep {
  final int stepNumber;
  final String actionTitle;
  final String actionDescriptionLibyan;
  final String purpose;
  final String estimatedTime;
  final String toolingNeeded;
  bool isCompleted;

  DiagnosticChecklistStep({
    required this.stepNumber,
    required this.actionTitle,
    required this.actionDescriptionLibyan,
    required this.purpose,
    required this.estimatedTime,
    required this.toolingNeeded,
    this.isCompleted = false,
  });

  factory DiagnosticChecklistStep.fromJson(Map<String, dynamic> json) {
    return DiagnosticChecklistStep(
      stepNumber: json['stepNumber'] is int
          ? json['stepNumber'] as int
          : int.tryParse(json['stepNumber']?.toString() ?? '') ?? 1,
      actionTitle: ReportSanitizer.clean(
        (json['actionTitle'] ?? json['targetComponent'] ?? '') as String,
      ),
      actionDescriptionLibyan: ReportSanitizer.clean(
        (json['actionDescriptionLibyan'] ??
                json['actionRequiredLibyan'] ??
                '')
            as String,
      ),
      purpose: ReportSanitizer.clean(
        (json['purpose'] ?? json['testPurpose'] ?? '') as String,
      ),
      estimatedTime:
          (json['estimatedTime'] ?? json['timeEstimated'] ?? '') as String,
      toolingNeeded: ReportSanitizer.clean(
        (json['toolingNeeded'] ?? json['toolNeeded'] ?? '') as String,
      ),
      isCompleted: json['isCompleted'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    'stepNumber': stepNumber,
    'actionTitle': actionTitle,
    'actionDescriptionLibyan': actionDescriptionLibyan,
    'purpose': purpose,
    'estimatedTime': estimatedTime,
    'toolingNeeded': toolingNeeded,
    'isCompleted': isCompleted,
  };
}
