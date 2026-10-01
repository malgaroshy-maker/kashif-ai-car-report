import 'package:qr/qr.dart';
import '../../data/models/diagnostic_report.dart';
import '../../data/storage/hive_storage.dart';

class ReportQrHelper {
  /// Generates a concise, high-speed scannable Arabic inspection summary for QR scanning
  static String buildQrInspectionSummary(DiagnosticReport report) {
    final v = report.vehicle;
    final summary = report.summary;
    final workshopPhone = KashifStorage.workshopPhone.trim();
    final testDate = report.generatedAt.isNotEmpty
        ? report.generatedAt.split('T').first
        : '';

    final totalFaults = report.criticalFaults.length +
        report.moderateFaults.length +
        report.historyFaults.length;

    final buffer = StringBuffer();
    buffer.writeln('Flow Cars | كاشف الفحص الفني');
    buffer.writeln('السيارة: ${v.make} ${v.model} ${v.year}'.trim());
    if (v.cleanVin.isNotEmpty && v.cleanVin != 'غير محدد') {
      buffer.writeln('الهيكل: ${v.cleanVin}');
    }
    buffer.writeln('السلامة: ${summary.overallHealthScore}% (${summary.severityStatus})');
    buffer.writeln('الأعطال: $totalFaults عطل');
    if (testDate.isNotEmpty) {
      buffer.writeln('التاريخ: $testDate');
    }
    if (workshopPhone.isNotEmpty) {
      buffer.writeln('هاتف الورشة: $workshopPhone');
    }

    return buffer.toString().trim();
  }

  /// Generates a standalone, crisp SVG string of the QR code with 4-module quiet zone
  static String generateQrSvg(String text, {double size = 130}) {
    final qrCode = QrCode.fromData(
      data: text,
      errorCorrectLevel: QrErrorCorrectLevel.M,
    );
    final qrImage = QrImage(qrCode);
    final count = qrImage.moduleCount;
    // Standard QR specification requires at least 4 modules of quiet zone
    const quietZone = 4;
    final totalCount = count + (quietZone * 2);

    final buffer = StringBuffer();
    buffer.write(
      '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 $totalCount $totalCount" width="$size" height="$size" shape-rendering="crispEdges">',
    );
    buffer.write('<rect width="$totalCount" height="$totalCount" fill="#FFFFFF"/>');
    for (int y = 0; y < count; y++) {
      for (int x = 0; x < count; x++) {
        if (qrImage.isDark(y, x)) {
          final qx = x + quietZone;
          final qy = y + quietZone;
          buffer.write(
            '<rect x="$qx" y="$qy" width="1" height="1" fill="#070E1E"/>',
          );
        }
      }
    }
    buffer.write('</svg>');
    return buffer.toString();
  }
}
