import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/typography.dart';
import '../../data/models/diagnostic_report.dart';
import '../providers/history_provider.dart';
import '../providers/report_provider.dart';
import '../widgets/fuse_cell.dart';
import '../widgets/molded_rib.dart';
import '../widgets/health_score_gauge.dart';

class HistoryScreen extends ConsumerWidget {
  final VoidCallback onReportSelected;

  const HistoryScreen({super.key, required this.onReportSelected});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final savedReports = ref.watch(historyProvider);

    if (savedReports.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.history_toggle_off_rounded,
                size: 54,
                color: isDark ? KashifColors.darkTextMuted : KashifColors.lightTextMuted,
              ),
              const SizedBox(height: 12),
              Text(
                'لا توجد فحوصات محفوظة محلياً',
                style: KashifTypography.arabic(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: isDark ? KashifColors.darkTextPrimary : KashifColors.lightTextPrimary,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'كل فحص تجريه بالكاميرا أو الـ PDF يُحفظ تلقائياً في ذاكرة هاتفك للرجوع إليه بدون إنترنت.',
                textAlign: TextAlign.center,
                style: KashifTypography.arabic(
                  fontSize: 12,
                  color: isDark ? KashifColors.darkTextMuted : KashifColors.lightTextMuted,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        itemCount: savedReports.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: MoldedRib(label: 'سجل الفحوصات المحفوظة (${savedReports.length})'),
            );
          }

          final report = savedReports[index - 1];
          return _buildReportItem(context, ref, report, isDark);
        },
      ),
    );
  }

  Widget _buildReportItem(
    BuildContext context,
    WidgetRef ref,
    DiagnosticReport report,
    bool isDark,
  ) {
    return FuseCell(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      onTap: () {
        ref.read(reportProvider.notifier).setReport(report);
        onReportSelected();
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${report.vehicle.make} ${report.vehicle.model} (${report.vehicle.year})',
                      style: KashifTypography.arabic(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: isDark ? KashifColors.darkTextPrimary : KashifColors.lightTextPrimary,
                      ),
                    ),
                    const SizedBox(height: 3),
                    if (report.vehicle.vin.isNotEmpty && report.vehicle.vin != 'N/A')
                      Text(
                        'VIN: ${report.vehicle.vin}',
                        style: KashifTypography.mono(
                          fontSize: 11,
                          color: isDark ? KashifColors.fuse15AInkDark : KashifColors.fuse15AInkLight,
                        ),
                      ),
                  ],
                ),
              ),
              HealthScoreGauge(
                score: report.summary.overallHealthScore,
                status: report.summary.severityStatus,
                size: 56,
              ),
            ],
          ),
          const Divider(height: 16),
          Row(
            children: [
              Icon(Icons.calendar_today_outlined, size: 12, color: isDark ? KashifColors.darkTextMuted : KashifColors.lightTextMuted),
              const SizedBox(width: 4),
              Text(
                report.generatedAt.split('T').first,
                style: KashifTypography.mono(
                  fontSize: 11,
                  color: isDark ? KashifColors.darkTextMuted : KashifColors.lightTextMuted,
                ),
              ),
              const Spacer(),
              Text(
                '${report.totalFaultsCount} أعطال مسجلة',
                style: KashifTypography.arabic(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: report.criticalFaults.isNotEmpty
                      ? (isDark ? KashifColors.fuse10AInkDark : KashifColors.fuse10AInkLight)
                      : (isDark ? KashifColors.darkTextMuted : KashifColors.lightTextMuted),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.delete_outline_rounded, size: 18),
                color: isDark ? KashifColors.fuse10AInkDark : KashifColors.fuse10AInkLight,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                tooltip: 'حذف من السجل',
                onPressed: () {
                  ref.read(historyProvider.notifier).deleteReport(report.reportId);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('تم حذف التقرير من السجل المحلي'), duration: Duration(seconds: 1)),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
