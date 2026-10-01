import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/typography.dart';
import '../../core/utils/share_service.dart';
import '../../core/utils/report_qr_helper.dart';
import '../../data/models/diagnostic_report.dart';

class ReportQrSheet extends StatelessWidget {
  final DiagnosticReport report;

  const ReportQrSheet({super.key, required this.report});

  static void show(BuildContext context, DiagnosticReport report) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => ReportQrSheet(report: report),
    );
  }

  /// Generates an elegant, human-readable Arabic inspection summary for QR scanning
  String _buildQrPayload() {
    return ReportQrHelper.buildQrInspectionSummary(report);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final qrData = _buildQrPayload();
    final v = report.vehicle;
    final score = report.summary.overallHealthScore;
    final isHealthy = score >= 70;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? KashifColors.darkBoard : KashifColors.lightBoard,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        border: Border.all(
          color: isDark ? KashifColors.darkBorder : KashifColors.lightBorder,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            width: 44,
            height: 4,
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: isDark ? Colors.white24 : Colors.black26,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          Row(
            children: [
              const Icon(
                Icons.qr_code_2_rounded,
                size: 24,
                color: Color(0xFFD4AF37),
              ),
              const SizedBox(width: 8),
              Text(
                'رمز QR لمشاركة الفحص الفوري',
                style: KashifTypography.arabic(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: isDark
                      ? KashifColors.darkTextPrimary
                      : KashifColors.lightTextPrimary,
                ),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.close_rounded, size: 20),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const Divider(height: 16),

          // Vehicle & Score mini header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isDark ? KashifColors.darkCell : KashifColors.lightCell,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isDark
                    ? KashifColors.darkBorder
                    : KashifColors.lightBorder,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${v.make} ${v.model} (${v.year})',
                        style: KashifTypography.arabic(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w800,
                          color: isDark
                              ? KashifColors.darkTextPrimary
                              : KashifColors.lightTextPrimary,
                        ),
                      ),
                      if (v.vin.isNotEmpty)
                        Text(
                          'VIN: ${v.vin}',
                          style: const TextStyle(
                            fontFamily: 'Courier',
                            fontSize: 11,
                            color: Colors.grey,
                          ),
                        ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color:
                        (isHealthy
                                ? const Color(0xFF2E9E5B)
                                : const Color(0xFFE53935))
                            .withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isHealthy
                          ? const Color(0xFF2E9E5B)
                          : const Color(0xFFE53935),
                    ),
                  ),
                  child: Text(
                    '$score% صحة',
                    style: KashifTypography.arabic(
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      color: isHealthy
                          ? const Color(0xFF2E9E5B)
                          : const Color(0xFFE53935),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // QR Code Frame with Gold Glow
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFD4AF37).withValues(alpha: 0.35),
                  blurRadius: 16,
                  spreadRadius: 2,
                ),
              ],
              border: Border.all(color: const Color(0xFFD4AF37), width: 2),
            ),
            child: QrImageView(
              data: qrData,
              version: QrVersions.auto,
              errorCorrectionLevel: QrErrorCorrectLevel.M,
              size: 210.0,
              backgroundColor: Colors.white,
              padding: const EdgeInsets.all(10),
            ),
          ),
          const SizedBox(height: 12),

          Text(
            'امسح الرمز بكاميرا أي هاتف لقراءة ملخص الفحص فوراً دون إنترنت',
            textAlign: TextAlign.center,
            style: KashifTypography.arabic(
              fontSize: 11.5,
              color: isDark
                  ? KashifColors.darkTextMuted
                  : KashifColors.lightTextMuted,
            ),
          ),
          const SizedBox(height: 16),

          // Action buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    ShareService.shareText(
                      qrData,
                      subject: 'تقرير فحص كاشف (${v.make} ${v.model})',
                    );
                  },
                  icon: const Icon(Icons.share_rounded, size: 16),
                  label: Text(
                    'مشاركة ملخص الفحص',
                    style: KashifTypography.arabic(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    side: BorderSide(
                      color: isDark
                          ? KashifColors.goldLight
                          : KashifColors.royalBlue,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.check_rounded, size: 16),
                  label: Text(
                    'تم',
                    style: KashifTypography.arabic(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD4AF37),
                    foregroundColor: const Color(0xFF070E1E),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
