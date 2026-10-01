import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/typography.dart';
import '../../data/models/diagnostic_report.dart';
import '../../data/models/fault_code.dart';
import '../../data/models/spare_part.dart';
import '../../data/models/checklist_step.dart';
import '../providers/report_provider.dart';
import '../providers/history_provider.dart';
import '../widgets/fuse_cell.dart';
import '../widgets/molded_rib.dart';
import '../widgets/health_score_gauge.dart';
import '../widgets/severity_seat.dart';
import '../widgets/code_card.dart';
import '../widgets/spare_part_card.dart';
import '../widgets/checklist_item.dart';
import '../widgets/export_options_sheet.dart';
import '../widgets/report_qr_sheet.dart';
import '../widgets/active_lights_card.dart';
import '../../core/utils/share_service.dart';
import 'report_compare_screen.dart';
import 'fuse_box_screen.dart';
import 'dashboard_lights_screen.dart';
import '../../core/utils/report_sanitizer.dart';

class ReportScreen extends ConsumerStatefulWidget {
  final VoidCallback onOpenChat;

  const ReportScreen({super.key, required this.onOpenChat});

  @override
  ConsumerState<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends ConsumerState<ReportScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 6, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final reportState = ref.watch(reportProvider);
    final report = reportState.report;
    final savedReports = ref.watch(historyProvider);
    final isSaved =
        report != null &&
        savedReports.any((r) => r.reportId == report.reportId);

    if (report == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.assignment_outlined,
              size: 54,
              color: isDark
                  ? KashifColors.darkTextMuted
                  : KashifColors.lightTextMuted,
            ),
            const SizedBox(height: 12),
            Text(
              'لا يوجد تقرير فحص مفتوح حالياً',
              style: KashifTypography.arabic(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: isDark
                    ? KashifColors.darkTextPrimary
                    : KashifColors.lightTextPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'ابدأ تصوير أو رفع تقرير من تبويب "الفحص"',
              style: KashifTypography.arabic(
                fontSize: 12,
                color: isDark
                    ? KashifColors.darkTextMuted
                    : KashifColors.lightTextMuted,
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (context, innerBoxIsScrolled) {
          return [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Vehicle Header Card
                    _buildVehicleHeader(report, isDark, isSaved),
                    const SizedBox(height: 12),

                    // Health Score & Priority Summary
                    _buildHealthScoreCard(report, isDark),
                    const SizedBox(height: 12),

                    // Mechanic Summary Alert
                    _buildMechanicSummary(report, isDark),
                    const SizedBox(height: 12),

                    // Active Dashboard Warning Lights
                    ActiveLightsCard(
                      report: report,
                      onUpdateLights: (newLights) {
                        final updated = report.copyWith(
                          activeWarningLightIds: newLights,
                        );
                        ref.read(reportProvider.notifier).setReport(updated);
                      },
                    ),

                    const MoldedRib(label: 'أقسام التقرير التفصيلي'),
                  ],
                ),
              ),
            ),
            SliverPersistentHeader(
              pinned: true,
              delegate: _TabBarDelegate(
                TabBar(
                  controller: _tabController,
                  isScrollable: true,
                  indicatorColor: isDark
                      ? KashifColors.goldLight
                      : KashifColors.royalBlue,
                  labelColor: isDark
                      ? KashifColors.goldLight
                      : KashifColors.royalBlue,
                  unselectedLabelColor: isDark
                      ? KashifColors.darkTextMuted
                      : KashifColors.lightTextMuted,
                  labelStyle: KashifTypography.arabic(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                  unselectedLabelStyle: KashifTypography.arabic(fontSize: 12),
                  tabs: [
                    Tab(text: 'أعطال حرجة (${report.criticalFaults.length})'),
                    Tab(text: 'أعطال متوسطة (${report.moderateFaults.length})'),
                    Tab(text: 'في الذاكرة (${report.historyFaults.length})'),
                    Tab(
                      text: 'الأنظمة السليمة (${report.passedSystems.length})',
                    ),
                    Tab(text: 'قطع الغيار (${report.spareParts.length})'),
                    Tab(text: 'خطوات الفحص (${report.checklist.length})'),
                  ],
                ),
                isDark: isDark,
              ),
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            // Tab 1: Critical Faults (10A)
            _buildFaultsList(
              report.criticalFaults,
              'لا توجد أعطال حرجة تهدد أمان السيارة بحمد الله.',
              CodeSeverity.critical,
            ),
            // Tab 2: Moderate Faults (20A)
            _buildFaultsList(
              report.moderateFaults,
              'لا توجد أعطال متوسطة مسجلة.',
              CodeSeverity.moderate,
            ),
            // Tab 3: History Faults (25A)
            _buildFaultsList(
              report.historyFaults,
              'لا توجد أكواد أعطال قديمة في الذاكرة.',
              CodeSeverity.history,
            ),
            // Tab 4: Passed Systems (30A)
            _buildPassedSystemsList(report.passedSystems, isDark),
            // Tab 5: Spare Parts Guide
            _buildPartsList(report.spareParts, isDark),
            // Tab 6: Diagnostic Checklist
            _buildChecklist(report.checklist, isDark),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isDark ? KashifColors.darkCell : KashifColors.lightCell,
          border: Border(
            top: BorderSide(
              color: isDark ? KashifColors.darkRib : KashifColors.lightRib,
              width: 1,
            ),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                // Save to History Button
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isSaved
                          ? (isDark
                              ? const Color(0xFF1B5E20)
                              : const Color(0xFF2E7D32))
                          : (isDark
                              ? KashifColors.goldPrimary
                              : KashifColors.goldDark),
                      foregroundColor: isSaved
                          ? Colors.white
                          : (isDark
                              ? const Color(0xFF070E1E)
                              : Colors.white),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 11),
                      elevation: isDark ? 2 : 1,
                    ),
                    onPressed: () async {
                      await ref
                          .read(historyProvider.notifier)
                          .saveReport(report);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Row(
                              children: [
                                const Icon(
                                  Icons.check_circle_rounded,
                                  color: Colors.white,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    isSaved
                                        ? 'تم تحديث التقرير في السجل بنجاح!'
                                        : 'تم حفظ التقرير في السجل المحلي بنجاح!',
                                    style: KashifTypography.arabic(
                                      fontSize: 13,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            backgroundColor: const Color(0xFF1E7E34),
                            behavior: SnackBarBehavior.floating,
                            duration: const Duration(seconds: 2),
                          ),
                        );
                      }
                    },
                    icon: Icon(
                      isSaved
                          ? Icons.bookmark_added_rounded
                          : Icons.bookmark_add_rounded,
                      size: 18,
                    ),
                    label: Text(
                      isSaved ? 'محفوظ في السجل ✓' : 'حفظ في السجل 💾',
                      style: KashifTypography.arabic(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),

                // Unified Export & Share Button
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: isDark
                          ? KashifColors.goldLight
                          : KashifColors.royalBlue,
                      side: BorderSide(
                        color: isDark
                            ? KashifColors.goldPrimary
                            : KashifColors.royalBlue,
                        width: 1.2,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 11),
                    ),
                    onPressed: () => ExportOptionsSheet.show(context, report),
                    icon: const Icon(Icons.ios_share_rounded, size: 18),
                    label: Text(
                      'تصدير ومشاركة 📤',
                      style: KashifTypography.arabic(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Ask the Mechanic (Chat) Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDark
                      ? const Color(0xFF132347)
                      : const Color(0xFFE8F0FC),
                  foregroundColor: isDark
                      ? KashifColors.goldLight
                      : KashifColors.royalBlue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(
                      color: isDark
                          ? KashifColors.goldPrimary.withValues(alpha: 0.5)
                          : KashifColors.royalBlue.withValues(alpha: 0.4),
                    ),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                ),
                onPressed: widget.onOpenChat,
                icon: const Icon(Icons.troubleshoot_rounded, size: 18),
                label: Text(
                  'موسوعة وبحث الأعطال (DTC Lookup)',
                  style: KashifTypography.arabic(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVehicleHeader(
    DiagnosticReport report,
    bool isDark,
    bool isSaved,
  ) {
    final v = report.vehicle;
    final primaryColor = isDark
        ? KashifColors.goldLight
        : KashifColors.royalBlue;
    final labelColor = isDark
        ? KashifColors.goldLight
        : KashifColors.royalBlueDark;
    final valueColor = isDark
        ? KashifColors.darkTextPrimary
        : KashifColors.lightTextPrimary;
    final testDate = report.generatedAt.isNotEmpty
        ? report.generatedAt.split('T').first
        : '';

    Widget buildSpecRow({
      required String label,
      required String value,
      bool isMono = false,
      bool isBold = false,
      Color? customValueColor,
    }) {
      if (value.trim().isEmpty) return const SizedBox.shrink();
      return Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 5,
              height: 5,
              margin: const EdgeInsets.only(top: 6, left: 8),
              decoration: BoxDecoration(
                color: isDark
                    ? KashifColors.goldPrimary
                    : const Color(0xFF2E7FC4),
                borderRadius: BorderRadius.circular(1.5),
              ),
            ),
            SizedBox(
              width: 86,
              child: Text(
                label,
                style: KashifTypography.arabic(
                  fontSize: 12.5,
                  fontWeight: FontWeight.bold,
                  color: labelColor,
                ),
              ),
            ),
            Expanded(
              child: Text(
                value,
                style: isMono
                    ? KashifTypography.mono(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color:
                            customValueColor ??
                            (isDark
                                ? KashifColors.goldLight
                                : const Color(0xFF0F5288)),
                      )
                    : KashifTypography.arabic(
                        fontSize: 12.5,
                        fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
                        color: customValueColor ?? valueColor,
                      ),
              ),
            ),
          ],
        ),
      );
    }

    return FuseCell(
      padding: const EdgeInsets.all(14),
      customBorder: Border.all(
        color: isDark
            ? KashifColors.goldPrimary.withValues(alpha: 0.3)
            : KashifColors.royalBlue.withValues(alpha: 0.2),
        width: 1,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.directions_car_rounded, size: 20, color: primaryColor),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'بيانات المركبة:',
                  style: KashifTypography.arabic(
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    color: isDark
                        ? KashifColors.goldLight
                        : KashifColors.royalBlueDark,
                  ),
                ),
              ),
              IconButton(
                icon: Icon(
                  isSaved
                      ? Icons.bookmark_added_rounded
                      : Icons.bookmark_add_outlined,
                  size: 20,
                  color: isSaved
                      ? (isDark
                          ? const Color(0xFF81C784)
                          : const Color(0xFF2E7D32))
                      : primaryColor,
                ),
                tooltip: isSaved ? 'محفوظ في السجل' : 'حفظ التقرير في السجل',
                padding: const EdgeInsets.all(4),
                constraints: const BoxConstraints(),
                onPressed: () async {
                  await ref.read(historyProvider.notifier).saveReport(report);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Row(
                          children: [
                            const Icon(
                              Icons.check_circle_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                isSaved
                                    ? 'تم تحديث التقرير في السجل بنجاح!'
                                    : 'تم حفظ التقرير في السجل المحلي بنجاح!',
                                style: KashifTypography.arabic(
                                  fontSize: 13,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                        backgroundColor: const Color(0xFF1E7E34),
                        behavior: SnackBarBehavior.floating,
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  }
                },
              ),
              const SizedBox(width: 4),
              IconButton(
                icon: Icon(
                  Icons.electric_bolt_rounded,
                  size: 20,
                  color: primaryColor,
                ),
                tooltip: 'دليل ومكتشف الفيوزات',
                padding: const EdgeInsets.all(4),
                constraints: const BoxConstraints(),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const FuseBoxScreen()),
                  );
                },
              ),
              const SizedBox(width: 4),
              IconButton(
                icon: Icon(
                  Icons.compare_arrows_rounded,
                  size: 20,
                  color: primaryColor,
                ),
                tooltip: 'مقارنة مع فحص سابق',
                padding: const EdgeInsets.all(4),
                constraints: const BoxConstraints(),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ReportCompareScreen(initialAfter: report),
                    ),
                  );
                },
              ),
              const SizedBox(width: 4),
              IconButton(
                icon: Icon(
                  Icons.warning_amber_rounded,
                  size: 20,
                  color: primaryColor,
                ),
                tooltip: 'تحديد لمبات الطبلون',
                padding: const EdgeInsets.all(4),
                constraints: const BoxConstraints(),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => DashboardLightsScreen(
                        initialSelectedIds: report.activeWarningLightIds,
                        onLightsSelected: (newLights) {
                          final updated = report.copyWith(
                            activeWarningLightIds: newLights,
                          );
                          ref.read(reportProvider.notifier).setReport(updated);
                        },
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(width: 4),
              IconButton(
                icon: Icon(
                  Icons.qr_code_2_rounded,
                  size: 20,
                  color: primaryColor,
                ),
                tooltip: 'مشاركة برمز QR',
                padding: const EdgeInsets.all(4),
                constraints: const BoxConstraints(),
                onPressed: () => ReportQrSheet.show(context, report),
              ),
              const SizedBox(width: 4),
              IconButton(
                icon: Icon(Icons.share_rounded, size: 20, color: primaryColor),
                tooltip: 'مشاركة التقرير عبر واتساب',
                padding: const EdgeInsets.all(4),
                constraints: const BoxConstraints(),
                onPressed: () =>
                    KashifShareService.shareReportViaWhatsApp(report),
              ),
              const SizedBox(width: 4),
              IconButton(
                icon: Icon(
                  Icons.ios_share_rounded,
                  size: 20,
                  color: primaryColor,
                ),
                tooltip: 'تصدير ومشاركة التقرير',
                padding: const EdgeInsets.all(4),
                constraints: const BoxConstraints(),
                onPressed: () => ExportOptionsSheet.show(context, report),
              ),
            ],
          ),
          const SizedBox(height: 10),
          buildSpecRow(
            label: 'السيارة:',
            value: v.formattedTitle,
            isBold: true,
          ),
          if (v.cleanVin.isNotEmpty)
            buildSpecRow(label: 'رقم الهيكل:', value: v.cleanVin, isMono: true),
          if (v.formattedEngine.isNotEmpty)
            buildSpecRow(label: 'المحرك:', value: v.formattedEngine),
          if (v.formattedTransmission.isNotEmpty)
            buildSpecRow(label: 'ناقل الحركة:', value: v.formattedTransmission),
          if (v.formattedMileage.isNotEmpty)
            buildSpecRow(label: 'قراءة العداد:', value: v.formattedMileage),
          if (testDate.isNotEmpty)
            buildSpecRow(label: 'تاريخ الفحص:', value: testDate),
        ],
      ),
    );
  }

  Widget _buildHealthScoreCard(DiagnosticReport report, bool isDark) {
    return FuseCell(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          HealthScoreGauge(
            score: report.summary.overallHealthScore,
            status: report.summary.severityStatus,
            size: 100,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'مصفوفة أولويات الصيانة',
                  style: KashifTypography.arabic(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                _buildPriorityRow(
                  'حرج (10A)',
                  report.criticalFaults.length,
                  CodeSeverity.critical,
                ),
                const SizedBox(height: 4),
                _buildPriorityRow(
                  'متوسط (20A)',
                  report.moderateFaults.length,
                  CodeSeverity.moderate,
                ),
                const SizedBox(height: 4),
                _buildPriorityRow(
                  'في الذاكرة (25A)',
                  report.historyFaults.length,
                  CodeSeverity.history,
                ),
                const SizedBox(height: 4),
                _buildPriorityRow(
                  'أنظمة سليمة (30A)',
                  report.passedSystems.length,
                  CodeSeverity.passed,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPriorityRow(String label, int count, CodeSeverity severity) {
    return Row(
      children: [
        SeveritySeat(severity: severity, compact: true),
        const SizedBox(width: 8),
        Text(label, style: KashifTypography.arabic(fontSize: 12)),
        const Spacer(),
        Text(
          '$count',
          style: KashifTypography.mono(
            fontSize: 13,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildMechanicSummary(DiagnosticReport report, bool isDark) {
    return FuseCell(
      backgroundColor: isDark
          ? const Color(0xFF101E3A)
          : const Color(0xFFEBF2FD),
      customBorder: Border.all(
        color: isDark
            ? KashifColors.goldPrimary.withValues(alpha: 0.3)
            : KashifColors.royalBlue.withValues(alpha: 0.2),
        width: 1,
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.lightbulb_rounded,
                size: 18,
                color: isDark ? KashifColors.goldLight : KashifColors.goldDark,
              ),
              const SizedBox(width: 6),
              Text(
                'خلاصة تقييم السيارة:',
                style: KashifTypography.arabic(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: isDark
                      ? KashifColors.goldLight
                      : KashifColors.royalBlue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            ReportSanitizer.clean(report.summary.briefSummaryArabic),
            style: KashifTypography.arabic(
              fontSize: 12,
              height: 1.5,
              color: isDark
                  ? KashifColors.darkTextPrimary
                  : KashifColors.lightTextPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFaultsList(
    List<DiagnosticFaultCode> faults,
    String emptyMsg,
    CodeSeverity sev,
  ) {
    if (faults.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SeveritySeat(severity: sev, compact: false),
              const SizedBox(height: 10),
              Text(
                emptyMsg,
                textAlign: TextAlign.center,
                style: KashifTypography.arabic(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: faults.length,
      itemBuilder: (context, index) {
        return CodeCard(fault: faults[index]);
      },
    );
  }

  Widget _buildPassedSystemsList(List<String> passedSystems, bool isDark) {
    if (passedSystems.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SeveritySeat(severity: CodeSeverity.passed, compact: false),
              const SizedBox(height: 10),
              Text(
                'لم تسجل المنظومات السليمة بشكل منفصل بجهاز الفحص.',
                textAlign: TextAlign.center,
                style: KashifTypography.arabic(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: passedSystems.length,
      itemBuilder: (context, index) {
        final sys = passedSystems[index];
        return FuseCell(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              const SeveritySeat(severity: CodeSeverity.passed, compact: true),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  sys,
                  style: KashifTypography.arabic(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: isDark
                        ? KashifColors.darkTextPrimary
                        : KashifColors.lightTextPrimary,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color:
                      (isDark
                              ? KashifColors.fuse30AInkDark
                              : KashifColors.fuse30AInkLight)
                          .withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(2),
                ),
                child: Text(
                  'سليم 30A',
                  style: KashifTypography.arabic(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: isDark
                        ? KashifColors.fuse30AInkDark
                        : KashifColors.fuse30AInkLight,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPartsList(List<SparePartItem> parts, bool isDark) {
    if (parts.isEmpty) {
      return Center(
        child: Text(
          'لا توجد قطع غيار مطلوبة مسجلة في هذا التقرير.',
          style: KashifTypography.arabic(fontSize: 13),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: parts.length,
      itemBuilder: (context, index) {
        return SparePartCard(part: parts[index]);
      },
    );
  }

  Widget _buildChecklist(List<DiagnosticChecklistStep> steps, bool isDark) {
    if (steps.isEmpty) {
      return Center(
        child: Text(
          'لا توجد خطوات فحص إضافية مسجلة.',
          style: KashifTypography.arabic(fontSize: 13),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: steps.length,
      itemBuilder: (context, index) {
        return ChecklistItemWidget(step: steps[index]);
      },
    );
  }
}

class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;
  final bool isDark;

  _TabBarDelegate(this.tabBar, {required this.isDark});

  @override
  double get minExtent => tabBar.preferredSize.height;
  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      color: isDark ? KashifColors.darkBoard : KashifColors.lightBoard,
      child: tabBar,
    );
  }

  @override
  bool shouldRebuild(covariant _TabBarDelegate oldDelegate) {
    return oldDelegate.isDark != isDark;
  }
}
