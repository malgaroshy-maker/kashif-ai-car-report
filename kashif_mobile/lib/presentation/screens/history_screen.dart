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

import 'report_compare_screen.dart';

class HistoryScreen extends ConsumerWidget {
  final VoidCallback onReportSelected;
  final bool showAppBar;

  const HistoryScreen({
    super.key,
    required this.onReportSelected,
    this.showAppBar = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final savedReports = ref.watch(historyProvider);

    if (savedReports.isEmpty) {
      return Scaffold(
        appBar: showAppBar
            ? AppBar(
                title: Text(
                  'سجل الفحوصات والتقارير',
                  style: KashifTypography.arabic(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              )
            : null,
        body: RefreshIndicator(
          onRefresh: () async =>
              ref.read(historyProvider.notifier).loadHistory(),
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
            children: [
              const SizedBox(height: 40),
              Icon(
                Icons.history_toggle_off_rounded,
                size: 64,
                color: isDark
                    ? KashifColors.darkTextMuted
                    : KashifColors.lightTextMuted,
              ),
              const SizedBox(height: 16),
              Text(
                'لا توجد فحوصات محفوظة في السجل',
                textAlign: TextAlign.center,
                style: KashifTypography.arabic(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: isDark
                      ? KashifColors.darkTextPrimary
                      : KashifColors.lightTextPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'يمكنك فحص أي سيارة والضغط على زر "حفظ في السجل 💾" داخل تبويب التقرير لحفظ التقرير هنا للرجوع إليه دون إنترنت.',
                textAlign: TextAlign.center,
                style: KashifTypography.arabic(
                  fontSize: 12.5,
                  height: 1.5,
                  color: isDark
                      ? KashifColors.darkTextMuted
                      : KashifColors.lightTextMuted,
                ),
              ),
              const SizedBox(height: 24),
              Center(
                child: ElevatedButton.icon(
                  onPressed: () =>
                      ref.read(historyProvider.notifier).loadHistory(),
                  icon: const Icon(Icons.refresh_rounded, size: 18),
                  label: Text(
                    'تحديث السجل',
                    style: KashifTypography.arabic(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDark
                        ? KashifColors.goldPrimary
                        : KashifColors.goldDark,
                    foregroundColor: isDark
                        ? const Color(0xFF070E1E)
                        : Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 11,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: showAppBar
          ? AppBar(
              title: Text(
                'سجل الفحوصات والتقارير',
                style: KashifTypography.arabic(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            )
          : null,
      body: RefreshIndicator(
        onRefresh: () async => ref.read(historyProvider.notifier).loadHistory(),
        child: ListView.builder(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          itemCount: savedReports.length + 1,
          itemBuilder: (context, index) {
            if (index == 0) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: MoldedRib(
                          label: 'سجل الفحوصات المحفوظة (${savedReports.length})',
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () => _confirmClearAll(context, ref),
                        icon: const Icon(Icons.delete_sweep_outlined, size: 16),
                        label: Text(
                          'مسح الكل',
                          style: KashifTypography.arabic(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        style: TextButton.styleFrom(
                          foregroundColor: isDark
                              ? KashifColors.fuse10AInkDark
                              : KashifColors.fuse10AInkLight,
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (savedReports.length >= 2) ...[
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ReportCompareScreen(
                              initialBefore: savedReports.length > 1
                                  ? savedReports[1]
                                  : null,
                              initialAfter: savedReports.first,
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.compare_arrows_rounded, size: 18),
                      label: Text(
                        'مقارنة فحصين (قبل وبعد الصيانة)',
                        style: KashifTypography.arabic(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(
                          0xFFD4AF37,
                        ).withValues(alpha: 0.15),
                        foregroundColor: const Color(0xFFD4AF37),
                        side: const BorderSide(
                          color: Color(0xFFD4AF37),
                          width: 1,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                      ),
                    ),
                    const SizedBox(height: 10),
                  ],
                ],
              );
            }

            final report = savedReports[index - 1];
            return _buildReportItem(context, ref, report, isDark);
          },
        ),
      ),
    );
  }

  Widget _buildReportItem(
    BuildContext context,
    WidgetRef ref,
    DiagnosticReport report,
    bool isDark,
  ) {
    final title = report.vehicle.formattedTitle.isNotEmpty
        ? report.vehicle.formattedTitle
        : '${report.vehicle.make} ${report.vehicle.model} (${report.vehicle.year})';
    final dateStr = report.generatedAt.contains('T')
        ? report.generatedAt.split('T').first
        : report.generatedAt;

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
                      title,
                      style: KashifTypography.arabic(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: isDark
                            ? KashifColors.darkTextPrimary
                            : KashifColors.lightTextPrimary,
                      ),
                    ),
                    const SizedBox(height: 3),
                    if (report.vehicle.cleanVin.isNotEmpty)
                      Text(
                        'VIN: ${report.vehicle.cleanVin}',
                        style: KashifTypography.mono(
                          fontSize: 11,
                          color: isDark
                              ? KashifColors.fuse15AInkDark
                              : KashifColors.fuse15AInkLight,
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
              Icon(
                Icons.calendar_today_outlined,
                size: 12,
                color: isDark
                    ? KashifColors.darkTextMuted
                    : KashifColors.lightTextMuted,
              ),
              const SizedBox(width: 4),
              Text(
                dateStr,
                style: KashifTypography.mono(
                  fontSize: 11,
                  color: isDark
                      ? KashifColors.darkTextMuted
                      : KashifColors.lightTextMuted,
                ),
              ),
              const Spacer(),
              Text(
                '${report.totalFaultsCount} أعطال مسجلة',
                style: KashifTypography.arabic(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: report.criticalFaults.isNotEmpty
                      ? (isDark
                            ? KashifColors.fuse10AInkDark
                            : KashifColors.fuse10AInkLight)
                      : (isDark
                            ? KashifColors.darkTextMuted
                            : KashifColors.lightTextMuted),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.delete_outline_rounded, size: 18),
                color: isDark
                    ? KashifColors.fuse10AInkDark
                    : KashifColors.fuse10AInkLight,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                tooltip: 'حذف من السجل',
                onPressed: () {
                  ref
                      .read(historyProvider.notifier)
                      .deleteReport(report.reportId);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('تم حذف التقرير من السجل المحلي'),
                      duration: Duration(seconds: 1),
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _confirmClearAll(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('مسح سجل الفحوصات'),
        content: const Text(
          'هل أنت متأكد من حذف جميع الفحوصات المحفوظة من الذاكرة المحلية؟',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(historyProvider.notifier).clearAll();
            },
            child: const Text(
              'حذف الكل',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
