import 'package:flutter/material.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/typography.dart';
import '../../core/utils/pdf_generator.dart';
import '../../core/utils/html_generator.dart';
import '../../core/utils/share_service.dart';
import '../../data/models/diagnostic_report.dart';
import 'fuse_cell.dart';

/// Bottom sheet offering unified export options: PDF, Offline HTML, and WhatsApp
class ExportOptionsSheet extends StatelessWidget {
  final DiagnosticReport report;

  const ExportOptionsSheet({super.key, required this.report});

  static void show(BuildContext context, DiagnosticReport report) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => ExportOptionsSheet(report: report),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? KashifColors.darkBoard : KashifColors.lightBoard,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        border: Border.all(
          color: isDark ? KashifColors.darkBorder : KashifColors.lightBorder,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
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
              Icon(
                Icons.ios_share_rounded,
                size: 22,
                color: isDark ? KashifColors.fuse15AInkDark : KashifColors.fuse15AInkLight,
              ),
              const SizedBox(width: 8),
              Text(
                'خيارات تصدير ومشاركة التقرير',
                style: KashifTypography.arabic(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: isDark ? KashifColors.darkTextPrimary : KashifColors.lightTextPrimary,
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

          // Option 1: PDF Export & Print
          _buildOptionTile(
            context: context,
            icon: Icons.picture_as_pdf_rounded,
            iconColor: const Color(0xFFC62828),
            title: 'طباعة وتصدير PDF (A4)',
            subtitle: 'وثيقة رسمية معتمدة تدعم الطباعة المباشرة، الختم والتوقيع',
            isDark: isDark,
            onTap: () async {
              Navigator.pop(context);
              await KashifPdfGenerator.printOrShareReport(report);
            },
          ),
          const SizedBox(height: 8),

          // Option 2: Offline HTML Download
          _buildOptionTile(
            context: context,
            icon: Icons.code_rounded,
            iconColor: isDark ? KashifColors.fuse15AInkDark : KashifColors.fuse15AInkLight,
            title: 'تنزيل تقرير HTML مستقل (أوفلاين)',
            subtitle: 'ملف يفتح على أي كمبيوتر أو شاشة بالورشة بدون اتصال إنترنت',
            isDark: isDark,
            onTap: () async {
              Navigator.pop(context);
              await KashifHtmlGenerator.generateAndSave(context, report);
            },
          ),
          const SizedBox(height: 8),

          // Option 3: WhatsApp Share
          _buildOptionTile(
            context: context,
            icon: Icons.share_rounded,
            iconColor: KashifColors.fuse30ATab,
            title: 'مشاركة ملخص الفحص عبر واتساب',
            subtitle: 'إرسال رسالة جاهزة للزبون تضم الأعطال والقطع المطلوبة والأسعار',
            isDark: isDark,
            onTap: () {
              Navigator.pop(context);
              KashifShareService.shareReportViaWhatsApp(report);
            },
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildOptionTile({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: FuseCell(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: KashifTypography.arabic(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: isDark ? KashifColors.darkTextPrimary : KashifColors.lightTextPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: KashifTypography.arabic(
                      fontSize: 11,
                      color: isDark ? KashifColors.darkTextMuted : KashifColors.lightTextMuted,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 14,
              color: isDark ? KashifColors.darkTextMuted : KashifColors.lightTextMuted,
            ),
          ],
        ),
      ),
    );
  }
}
