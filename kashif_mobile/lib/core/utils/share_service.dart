import 'package:share_plus/share_plus.dart';
import '../../data/models/diagnostic_report.dart';
import '../../data/repositories/dashboard_lights_repository.dart';
import '../../data/storage/hive_storage.dart';
import 'report_sanitizer.dart';

class KashifShareService {
  static Future<void> shareReportViaWhatsApp(DiagnosticReport report) async {
    final buffer = StringBuffer();
    final workshop = KashifStorage.workshopName;
    final phone = KashifStorage.workshopPhone;

    buffer.writeln('🚗 *تقرير كشف وتشخيص أعطال السيارة*');
    buffer.writeln('🏢 *$workshop*');
    if (phone.isNotEmpty) buffer.writeln('📞 هاتف: $phone');
    final v = report.vehicle;
    buffer.writeln('📋 *بيانات المركبة:*');
    buffer.writeln('• *السيارة:* ${v.formattedTitle}');
    if (v.cleanVin.isNotEmpty) {
      buffer.writeln('• *رقم الهيكل:* ${v.cleanVin}');
    }
    if (v.formattedEngine.isNotEmpty) {
      buffer.writeln('• *المحرك:* ${v.formattedEngine}');
    }
    if (v.formattedTransmission.isNotEmpty) {
      buffer.writeln('• *ناقل الحركة:* ${v.formattedTransmission}');
    }
    if (v.formattedMileage.isNotEmpty) {
      buffer.writeln('• *قراءة العداد:* ${v.formattedMileage}');
    }
    final testDate = report.generatedAt.isNotEmpty
        ? report.generatedAt.split('T').first
        : '';
    if (testDate.isNotEmpty) {
      buffer.writeln('• *تاريخ الفحص:* $testDate');
    }
    buffer.writeln(
      '• *مؤشر الجاهزية والحالة:* ${report.summary.overallHealthScore}% (${report.summary.severityStatus})',
    );
    buffer.writeln('──────────────────');

    if (report.activeWarningLightIds.isNotEmpty) {
      buffer.writeln('⚠️ *لمبات الطبلون المشتعلة:*');
      for (final id in report.activeWarningLightIds) {
        final light = DashboardLightsRepository.getById(id);
        if (light != null) {
          buffer.writeln(
            '• ${light.nameArabic} [${light.canDrive.labelArabic.split('(').first.trim()}]',
          );
        }
      }
      buffer.writeln('──────────────────');
    }

    if (report.criticalFaults.isNotEmpty) {
      buffer.writeln('🚨 *أعطال حرجة (10A - وقف السيارة):*');
      for (var f in report.criticalFaults) {
        buffer.writeln('• ${f.code}: ${f.libyanTerm}');
      }
      buffer.writeln('──────────────────');
    }

    if (report.moderateFaults.isNotEmpty) {
      buffer.writeln('⚠️ *أعطال متوسطة (20A - تحتاج فحص وصيانة):*');
      for (var f in report.moderateFaults) {
        buffer.writeln('• ${f.code}: ${f.libyanTerm}');
      }
      buffer.writeln('──────────────────');
    }

    final soundSystems = report.soundSystems;
    if (soundSystems.isNotEmpty) {
      buffer.writeln('✅ *الأنظمة والمنظومات السليمة (30A - خالية من الأعطال):*');
      for (var s in soundSystems) {
        buffer.writeln('• $s');
      }
      buffer.writeln('──────────────────');
    }

    if (report.spareParts.isNotEmpty) {
      buffer.writeln('🔧 *قطع الغيار المطلوبة والأسعار التقديرية:*');
      for (var p in report.spareParts) {
        final price = p.estimatedPriceRangeLYD;
        final priceStr = price != null
            ? ' (${price.min.toInt()} - ${price.max.toInt()} د.ل)'
            : '';
        final oem = p.oemPartNumber != null ? ' [OEM: ${p.oemPartNumber}]' : '';
        buffer.writeln('• ${p.partNameLibyan}$oem$priceStr');
      }
      buffer.writeln('──────────────────');
    }

    buffer.writeln('💡 *خلاصة تقييم السيارة:*');
    buffer.writeln(ReportSanitizer.clean(report.summary.briefSummaryArabic));

    await SharePlus.instance.share(
      ShareParams(
        text: buffer.toString(),
        subject:
            'تقرير فحص سيارة ${report.vehicle.make} ${report.vehicle.model}',
      ),
    );
  }

  static Future<void> shareText(String text, {String? subject}) async {
    await SharePlus.instance.share(ShareParams(text: text, subject: subject));
  }
}

typedef ShareService = KashifShareService;
