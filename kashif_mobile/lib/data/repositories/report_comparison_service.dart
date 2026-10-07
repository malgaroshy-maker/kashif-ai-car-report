import '../models/diagnostic_report.dart';
import '../models/fault_code.dart';

class ReportComparisonResult {
  final DiagnosticReport beforeReport;
  final DiagnosticReport afterReport;
  final int healthScoreBefore;
  final int healthScoreAfter;
  final int healthScoreDiff;
  final List<DiagnosticFaultCode> resolvedFaults;
  final List<DiagnosticFaultCode> persistentFaults;
  final List<DiagnosticFaultCode> newFaults;

  ReportComparisonResult({
    required this.beforeReport,
    required this.afterReport,
    required this.healthScoreBefore,
    required this.healthScoreAfter,
    required this.healthScoreDiff,
    required this.resolvedFaults,
    required this.persistentFaults,
    required this.newFaults,
  });

  bool get isImproved => healthScoreDiff > 0 || resolvedFaults.isNotEmpty;

  /// Returns the overall improvement percentage or label
  String get improvementBadge {
    if (healthScoreDiff > 0) {
      return '+$healthScoreDiff% تحسن';
    } else if (healthScoreDiff == 0) {
      return 'لا تغيير في النقاط';
    } else {
      return '$healthScoreDiff% تراجع';
    }
  }

  /// Generates a clean text certificate for WhatsApp or sharing with car owners
  String generateShareableText() {
    final buffer = StringBuffer();
    buffer.writeln('📋 *شهادة مقارنة وإثبات الصيانة — كاشف AI*');
    buffer.writeln('━━━━━━━━━━━━━━━━━━━━━');
    buffer.writeln(
      '🚗 *المركبة:* ${afterReport.vehicle.make} ${afterReport.vehicle.model} (${afterReport.vehicle.year})',
    );
    if (afterReport.vehicle.vin.isNotEmpty) {
      buffer.writeln('🔢 *رقم الهيكل (VIN):* ${afterReport.vehicle.vin}');
    }
    buffer.writeln('');
    buffer.writeln('📅 *فحص ما قبل الصيانة:* ${beforeReport.generatedAt}');
    buffer.writeln(
      '📊 *نسبة الصحة الأولية:* $healthScoreBefore% (${beforeReport.summary.severityStatus})',
    );
    buffer.writeln('');
    buffer.writeln('📅 *فحص ما بعد الصيانة:* ${afterReport.generatedAt}');
    buffer.writeln(
      '📊 *نسبة الصحة الحالية:* $healthScoreAfter% (${afterReport.summary.severityStatus})',
    );
    buffer.writeln('📈 *مستوى التحسن:* $improvementBadge');
    buffer.writeln('━━━━━━━━━━━━━━━━━━━━━');

    if (resolvedFaults.isNotEmpty) {
      buffer.writeln('✅ *أعطال تم إصلاحها بنجاح (${resolvedFaults.length}):*');
      for (final f in resolvedFaults) {
        buffer.writeln(
          '  • [${f.code}] ${f.systemArabic} — ${f.componentDescription}',
        );
      }
      buffer.writeln('');
    }

    if (persistentFaults.isNotEmpty) {
      buffer.writeln(
        '⚠️ *أعطال مستمرة لا تزال بحاجة لمتابعة (${persistentFaults.length}):*',
      );
      for (final f in persistentFaults) {
        buffer.writeln(
          '  • [${f.code}] ${f.systemArabic} — ${f.componentDescription}',
        );
      }
      buffer.writeln('');
    }

    if (newFaults.isNotEmpty) {
      buffer.writeln(
        '🔴 *أعطال جديدة ظهرت بالفحص الأخير (${newFaults.length}):*',
      );
      for (final f in newFaults) {
        buffer.writeln(
          '  • [${f.code}] ${f.systemArabic} — ${f.componentDescription}',
        );
      }
      buffer.writeln('');
    }

    buffer.writeln('━━━━━━━━━━━━━━━━━━━━━');
    buffer.writeln('✨ تم الفحص والمقارنة آلياً عبر تطبيق كاشف Flow Cars');
    return buffer.toString();
  }
}

class ReportComparisonService {
  /// Compares two reports (before vs after)
  static ReportComparisonResult compare({
    required DiagnosticReport beforeReport,
    required DiagnosticReport afterReport,
  }) {
    final beforeCodes = <String, DiagnosticFaultCode>{};
    for (final f in [
      ...beforeReport.criticalFaults,
      ...beforeReport.moderateFaults,
      ...beforeReport.historyFaults,
    ]) {
      beforeCodes[f.code.toUpperCase().trim()] = f;
    }

    final afterCodes = <String, DiagnosticFaultCode>{};
    for (final f in [
      ...afterReport.criticalFaults,
      ...afterReport.moderateFaults,
      ...afterReport.historyFaults,
    ]) {
      afterCodes[f.code.toUpperCase().trim()] = f;
    }

    // Resolved = in before, not in after
    final resolvedFaults = <DiagnosticFaultCode>[];
    beforeCodes.forEach((code, fault) {
      if (!afterCodes.containsKey(code)) {
        resolvedFaults.add(fault);
      }
    });

    // Persistent = in both
    final persistentFaults = <DiagnosticFaultCode>[];
    beforeCodes.forEach((code, fault) {
      if (afterCodes.containsKey(code)) {
        persistentFaults.add(fault);
      }
    });

    // New = in after, not in before
    final newFaults = <DiagnosticFaultCode>[];
    afterCodes.forEach((code, fault) {
      if (!beforeCodes.containsKey(code)) {
        newFaults.add(fault);
      }
    });

    final scoreBefore = beforeReport.summary.overallHealthScore;
    final scoreAfter = afterReport.summary.overallHealthScore;
    final diff = scoreAfter - scoreBefore;

    return ReportComparisonResult(
      beforeReport: beforeReport,
      afterReport: afterReport,
      healthScoreBefore: scoreBefore,
      healthScoreAfter: scoreAfter,
      healthScoreDiff: diff,
      resolvedFaults: resolvedFaults,
      persistentFaults: persistentFaults,
      newFaults: newFaults,
    );
  }
}
