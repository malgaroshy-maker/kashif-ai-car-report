import 'package:share_plus/share_plus.dart';
import '../../data/models/diagnostic_report.dart';
import '../../data/storage/hive_storage.dart';

class KashifShareService {
  static Future<void> shareReportViaWhatsApp(DiagnosticReport report) async {
    final buffer = StringBuffer();
    final workshop = KashifStorage.workshopName;
    final phone = KashifStorage.workshopPhone;

    buffer.writeln('🚗 *تقرير كشف وتشخيص أعطال السيارة*');
    buffer.writeln('🏢 *$workshop*');
    if (phone.isNotEmpty) buffer.writeln('📞 هاتف: $phone');
    buffer.writeln('──────────────────');
    buffer.writeln('📋 *بيانات السيارة:*');
    buffer.writeln('• النوع: ${report.vehicle.make} ${report.vehicle.model} (${report.vehicle.year})');
    if (report.vehicle.vin.isNotEmpty && report.vehicle.vin != 'N/A') {
      buffer.writeln('• رقم الهيكل (VIN): ${report.vehicle.vin}');
    }
    buffer.writeln('• مؤشر صحة السيارة: ${report.summary.overallHealthScore}% (${report.summary.severityStatus})');
    buffer.writeln('──────────────────');

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

    if (report.spareParts.isNotEmpty) {
      buffer.writeln('🔧 *قطع الغيار المطلوبة والأسعار التقديرية:*');
      for (var p in report.spareParts) {
        final price = p.estimatedPriceRangeLYD;
        final priceStr = price != null ? ' (${price.min.toInt()} - ${price.max.toInt()} د.ل)' : '';
        final oem = p.oemPartNumber != null ? ' [OEM: ${p.oemPartNumber}]' : '';
        buffer.writeln('• ${p.partNameLibyan}$oem$priceStr');
      }
      buffer.writeln('──────────────────');
    }

    buffer.writeln('💡 *نصيحة الأسطى:*');
    buffer.writeln(report.summary.briefSummaryArabic);
    buffer.writeln('\n_تم الفحص بواسطة كاشف AI — منظومة تشخيص الأعطال بالمصطلحات الليبية_');

    await SharePlus.instance.share(
      ShareParams(
        text: buffer.toString(),
        subject: 'تقرير فحص سيارة ${report.vehicle.make} ${report.vehicle.model}',
      ),
    );
  }
}
