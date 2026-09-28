import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/typography.dart';
import '../../core/utils/share_service.dart';
import '../../data/models/diagnostic_report.dart';
import '../../data/models/fault_code.dart';
import '../../data/repositories/report_comparison_service.dart';
import '../providers/history_provider.dart';
import '../widgets/fuse_cell.dart';
import '../widgets/molded_rib.dart';

class ReportCompareScreen extends ConsumerStatefulWidget {
  final DiagnosticReport? initialBefore;
  final DiagnosticReport? initialAfter;

  const ReportCompareScreen({super.key, this.initialBefore, this.initialAfter});

  @override
  ConsumerState<ReportCompareScreen> createState() =>
      _ReportCompareScreenState();
}

class _ReportCompareScreenState extends ConsumerState<ReportCompareScreen> {
  DiagnosticReport? _beforeReport;
  DiagnosticReport? _afterReport;

  @override
  void initState() {
    super.initState();
    _beforeReport = widget.initialBefore;
    _afterReport = widget.initialAfter;
  }

  void _pickReport({
    required bool isBefore,
    required List<DiagnosticReport> allReports,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        return Container(
          height: MediaQuery.of(ctx).size.height * 0.7,
          decoration: BoxDecoration(
            color: isDark ? KashifColors.darkBoard : KashifColors.lightBoard,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            border: Border.all(
              color: isDark
                  ? KashifColors.darkBorder
                  : KashifColors.lightBorder,
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Icon(
                    isBefore
                        ? Icons.history_toggle_off_rounded
                        : Icons.check_circle_outline_rounded,
                    color: isBefore
                        ? const Color(0xFFE5A93C)
                        : const Color(0xFF2E9E5B),
                    size: 22,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isBefore
                        ? 'اختر فحص (قبل الصيانة)'
                        : 'اختر فحص (بعد الصيانة)',
                    style: KashifTypography.arabic(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: isDark
                          ? KashifColors.darkTextPrimary
                          : KashifColors.lightTextPrimary,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, size: 20),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const Divider(height: 16),
              Expanded(
                child: allReports.isEmpty
                    ? Center(
                        child: Text(
                          'لا توجد فحوصات أخرى محفوظة في السجل',
                          style: KashifTypography.arabic(
                            fontSize: 13,
                            color: isDark
                                ? KashifColors.darkTextMuted
                                : KashifColors.lightTextMuted,
                          ),
                        ),
                      )
                    : ListView.builder(
                        itemCount: allReports.length,
                        itemBuilder: (context, idx) {
                          final r = allReports[idx];
                          final isSelected = isBefore
                              ? r.reportId == _beforeReport?.reportId
                              : r.reportId == _afterReport?.reportId;

                          return FuseCell(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(12),
                            onTap: () {
                              setState(() {
                                if (isBefore) {
                                  _beforeReport = r;
                                } else {
                                  _afterReport = r;
                                }
                              });
                              Navigator.pop(ctx);
                            },
                            child: Row(
                              children: [
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color:
                                        (r.summary.overallHealthScore >= 70
                                                ? const Color(0xFF2E9E5B)
                                                : const Color(0xFFC62828))
                                            .withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(
                                    '${r.summary.overallHealthScore}%',
                                    style: KashifTypography.arabic(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w900,
                                      color: r.summary.overallHealthScore >= 70
                                          ? const Color(0xFF2E9E5B)
                                          : const Color(0xFFE53935),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        '${r.vehicle.make} ${r.vehicle.model} (${r.vehicle.year})',
                                        style: KashifTypography.arabic(
                                          fontSize: 13.5,
                                          fontWeight: FontWeight.w800,
                                          color: isDark
                                              ? KashifColors.darkTextPrimary
                                              : KashifColors.lightTextPrimary,
                                        ),
                                      ),
                                      const SizedBox(height: 3),
                                      Text(
                                        r.generatedAt,
                                        style: KashifTypography.arabic(
                                          fontSize: 11,
                                          color: isDark
                                              ? KashifColors.darkTextMuted
                                              : KashifColors.lightTextMuted,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (isSelected)
                                  const Icon(
                                    Icons.check_circle_rounded,
                                    color: Color(0xFF2E9E5B),
                                    size: 20,
                                  ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final allReports = ref.watch(historyProvider);

    // Auto-select initial if only 2 reports exist and unselected
    if (_beforeReport == null &&
        _afterReport == null &&
        allReports.length >= 2) {
      _afterReport = allReports.first;
      _beforeReport = allReports[1];
    } else if (_beforeReport == null && allReports.isNotEmpty) {
      _beforeReport = allReports.first;
    }

    ReportComparisonResult? comparison;
    if (_beforeReport != null && _afterReport != null) {
      comparison = ReportComparisonService.compare(
        beforeReport: _beforeReport!,
        afterReport: _afterReport!,
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'مقارنة الفحوصات (قبل وبعد الصيانة)',
          style: KashifTypography.arabic(
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          if (comparison != null)
            IconButton(
              icon: const Icon(Icons.share_rounded, size: 20),
              tooltip: 'مشاركة شهادة إثبات الإصلاح',
              onPressed: () {
                ShareService.shareText(
                  comparison!.generateShareableText(),
                  subject: 'شهادة مقارنة وإثبات الصيانة — كاشف AI',
                );
              },
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Selection row for Before and After
            Row(
              children: [
                Expanded(
                  child: _buildReportSelectCard(
                    title: 'فحص ما قبل الصيانة',
                    report: _beforeReport,
                    isBefore: true,
                    isDark: isDark,
                    onTap: () =>
                        _pickReport(isBefore: true, allReports: allReports),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isDark
                          ? KashifColors.darkCell
                          : KashifColors.lightCell,
                      border: Border.all(
                        color: isDark
                            ? KashifColors.darkBorder
                            : KashifColors.lightBorder,
                      ),
                    ),
                    child: const Icon(
                      Icons.arrow_forward_rounded,
                      size: 18,
                      color: Color(0xFFD4AF37),
                    ),
                  ),
                ),
                Expanded(
                  child: _buildReportSelectCard(
                    title: 'فحص ما بعد الصيانة',
                    report: _afterReport,
                    isBefore: false,
                    isDark: isDark,
                    onTap: () =>
                        _pickReport(isBefore: false, allReports: allReports),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            if (comparison == null)
              Padding(
                padding: const EdgeInsets.all(24),
                child: Center(
                  child: Text(
                    'الرجاء اختيار فحصين مختلفين من السجل للبدء في المقارنة الذكية',
                    textAlign: TextAlign.center,
                    style: KashifTypography.arabic(
                      fontSize: 13,
                      color: isDark
                          ? KashifColors.darkTextMuted
                          : KashifColors.lightTextMuted,
                    ),
                  ),
                ),
              )
            else ...[
              // Comparison Results Header & Score Improvement Card
              _buildScoreComparisonCard(comparison, isDark),
              const SizedBox(height: 14),

              // Overview Metrics Row
              Row(
                children: [
                  Expanded(
                    child: _buildMetricTile(
                      count: comparison.resolvedFaults.length,
                      label: 'أعطال تم حلها',
                      color: const Color(0xFF2E9E5B),
                      icon: Icons.check_circle_rounded,
                      isDark: isDark,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildMetricTile(
                      count: comparison.persistentFaults.length,
                      label: 'أعطال مستمرة',
                      color: const Color(0xFFE5A93C),
                      icon: Icons.warning_amber_rounded,
                      isDark: isDark,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildMetricTile(
                      count: comparison.newFaults.length,
                      label: 'أعطال جديدة',
                      color: const Color(0xFFE53935),
                      icon: Icons.error_outline_rounded,
                      isDark: isDark,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Section 1: Resolved Faults
              if (comparison.resolvedFaults.isNotEmpty) ...[
                MoldedRib(
                  label:
                      'أعطال تم إصلاحها بنجاح (${comparison.resolvedFaults.length})',
                ),
                const SizedBox(height: 8),
                ...comparison.resolvedFaults.map(
                  (fault) => _buildFaultComparisonItem(
                    fault: fault,
                    statusType: _FaultStatusType.resolved,
                    isDark: isDark,
                  ),
                ),
                const SizedBox(height: 14),
              ],

              // Section 2: Persistent Faults
              if (comparison.persistentFaults.isNotEmpty) ...[
                MoldedRib(
                  label:
                      'أعطال لا تزال مستمرة بحاجة لمتابعة (${comparison.persistentFaults.length})',
                ),
                const SizedBox(height: 8),
                ...comparison.persistentFaults.map(
                  (fault) => _buildFaultComparisonItem(
                    fault: fault,
                    statusType: _FaultStatusType.persistent,
                    isDark: isDark,
                  ),
                ),
                const SizedBox(height: 14),
              ],

              // Section 3: New Faults
              if (comparison.newFaults.isNotEmpty) ...[
                MoldedRib(
                  label:
                      'أعطال جديدة ظهرت بالفحص الأخير (${comparison.newFaults.length})',
                ),
                const SizedBox(height: 8),
                ...comparison.newFaults.map(
                  (fault) => _buildFaultComparisonItem(
                    fault: fault,
                    statusType: _FaultStatusType.newFault,
                    isDark: isDark,
                  ),
                ),
                const SizedBox(height: 14),
              ],

              // Action button to share
              Padding(
                padding: const EdgeInsets.only(top: 8, bottom: 20),
                child: ElevatedButton.icon(
                  onPressed: () {
                    ShareService.shareText(
                      comparison!.generateShareableText(),
                      subject: 'شهادة مقارنة وإثبات الصيانة — كاشف AI',
                    );
                  },
                  icon: const Icon(Icons.share_rounded, size: 18),
                  label: Text(
                    'مشاركة شهادة إثبات الإصلاح للزبون (واتساب / نص)',
                    style: KashifTypography.arabic(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E9E5B),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildReportSelectCard({
    required String title,
    required DiagnosticReport? report,
    required bool isBefore,
    required bool isDark,
    required VoidCallback onTap,
  }) {
    final accentColor = isBefore
        ? const Color(0xFFE5A93C)
        : const Color(0xFF2E9E5B);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isDark ? KashifColors.darkCell : KashifColors.lightCell,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: accentColor.withValues(alpha: 0.5),
            width: 1.2,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(radius: 4, backgroundColor: accentColor),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    title,
                    style: KashifTypography.arabic(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w800,
                      color: accentColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            if (report != null) ...[
              Text(
                '${report.vehicle.make} ${report.vehicle.model}',
                style: KashifTypography.arabic(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: isDark
                      ? KashifColors.darkTextPrimary
                      : KashifColors.lightTextPrimary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'صحة: ${report.summary.overallHealthScore}%',
                    style: KashifTypography.arabic(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: report.summary.overallHealthScore >= 70
                          ? const Color(0xFF2E9E5B)
                          : const Color(0xFFE53935),
                    ),
                  ),
                  const Icon(Icons.arrow_drop_down, size: 18),
                ],
              ),
            ] else ...[
              Text(
                'اضغط للاختيار',
                style: KashifTypography.arabic(
                  fontSize: 11.5,
                  color: isDark
                      ? KashifColors.darkTextMuted
                      : KashifColors.lightTextMuted,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildScoreComparisonCard(ReportComparisonResult comp, bool isDark) {
    final diff = comp.healthScoreDiff;
    final isPositive = diff > 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF131D30), const Color(0xFF0F1726)]
              : [const Color(0xFFEAF2FF), const Color(0xFFF4F7FC)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color:
              (isPositive ? const Color(0xFF2E9E5B) : const Color(0xFFD4AF37))
                  .withValues(alpha: 0.4),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              // Before Score
              Column(
                children: [
                  Text(
                    'قبل الإصلاح',
                    style: KashifTypography.arabic(
                      fontSize: 11,
                      color: isDark
                          ? KashifColors.darkTextMuted
                          : KashifColors.lightTextMuted,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${comp.healthScoreBefore}%',
                    style: KashifTypography.arabic(
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFFE5A93C),
                    ),
                  ),
                  Text(
                    comp.beforeReport.summary.severityStatus,
                    style: KashifTypography.arabic(
                      fontSize: 10,
                      color: const Color(0xFFE5A93C),
                    ),
                  ),
                ],
              ),

              // Arrow with diff badge
              Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: isPositive
                          ? const Color(0xFF1B3B2B)
                          : const Color(0xFF3E1F1F),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isPositive
                            ? const Color(0xFF2E9E5B)
                            : const Color(0xFFE53935),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isPositive
                              ? Icons.trending_up_rounded
                              : Icons.trending_down_rounded,
                          size: 16,
                          color: isPositive
                              ? const Color(0xFF2E9E5B)
                              : const Color(0xFFE53935),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          comp.improvementBadge,
                          style: KashifTypography.arabic(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: isPositive
                                ? const Color(0xFF2E9E5B)
                                : const Color(0xFFE53935),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Icon(
                    Icons.arrow_forward_rounded,
                    color: Color(0xFFD4AF37),
                    size: 24,
                  ),
                ],
              ),

              // After Score
              Column(
                children: [
                  Text(
                    'بعد الإصلاح',
                    style: KashifTypography.arabic(
                      fontSize: 11,
                      color: isDark
                          ? KashifColors.darkTextMuted
                          : KashifColors.lightTextMuted,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${comp.healthScoreAfter}%',
                    style: KashifTypography.arabic(
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFF2E9E5B),
                    ),
                  ),
                  Text(
                    comp.afterReport.summary.severityStatus,
                    style: KashifTypography.arabic(
                      fontSize: 10,
                      color: const Color(0xFF2E9E5B),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricTile({
    required int count,
    required String label,
    required Color color,
    required IconData icon,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      decoration: BoxDecoration(
        color: isDark ? KashifColors.darkCell : KashifColors.lightCell,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(
            '$count',
            style: KashifTypography.arabic(
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: color,
            ),
          ),
          Text(
            label,
            style: KashifTypography.arabic(
              fontSize: 10.5,
              fontWeight: FontWeight.w600,
              color: isDark
                  ? KashifColors.darkTextMuted
                  : KashifColors.lightTextMuted,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFaultComparisonItem({
    required DiagnosticFaultCode fault,
    required _FaultStatusType statusType,
    required bool isDark,
  }) {
    Color badgeColor;
    String statusTitle;
    IconData icon;

    switch (statusType) {
      case _FaultStatusType.resolved:
        badgeColor = const Color(0xFF2E9E5B);
        statusTitle = 'تم الإصلاح بنجاح';
        icon = Icons.check_circle_rounded;
        break;
      case _FaultStatusType.persistent:
        badgeColor = const Color(0xFFE5A93C);
        statusTitle = 'عطل مستمر لم يُحل';
        icon = Icons.warning_amber_rounded;
        break;
      case _FaultStatusType.newFault:
        badgeColor = const Color(0xFFE53935);
        statusTitle = 'عطل جديد ظهر بالفحص';
        icon = Icons.error_outline_rounded;
        break;
    }

    return FuseCell(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: badgeColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: badgeColor.withValues(alpha: 0.5)),
            ),
            child: Text(
              fault.code,
              style: TextStyle(
                fontFamily: 'Courier',
                fontWeight: FontWeight.w900,
                fontSize: 13,
                color: badgeColor,
                decoration: statusType == _FaultStatusType.resolved
                    ? TextDecoration.lineThrough
                    : null,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(icon, size: 14, color: badgeColor),
                    const SizedBox(width: 4),
                    Text(
                      statusTitle,
                      style: KashifTypography.arabic(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: badgeColor,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '• ${fault.systemArabic}',
                      style: KashifTypography.arabic(
                        fontSize: 11,
                        color: isDark
                            ? KashifColors.darkTextMuted
                            : KashifColors.lightTextMuted,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  fault.componentDescription,
                  style: KashifTypography.arabic(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? KashifColors.darkTextPrimary
                        : KashifColors.lightTextPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

enum _FaultStatusType { resolved, persistent, newFault }
