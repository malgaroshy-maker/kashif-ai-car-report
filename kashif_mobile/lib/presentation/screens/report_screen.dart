import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/typography.dart';
import '../../data/models/diagnostic_report.dart';
import '../../data/models/fault_code.dart';
import '../../data/models/spare_part.dart';
import '../../data/models/checklist_step.dart';
import '../providers/report_provider.dart';
import '../widgets/fuse_cell.dart';
import '../widgets/molded_rib.dart';
import '../widgets/health_score_gauge.dart';
import '../widgets/severity_seat.dart';
import '../widgets/code_card.dart';
import '../widgets/spare_part_card.dart';
import '../widgets/checklist_item.dart';
import '../widgets/export_options_sheet.dart';

class ReportScreen extends ConsumerStatefulWidget {
  final VoidCallback onOpenChat;

  const ReportScreen({super.key, required this.onOpenChat});

  @override
  ConsumerState<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends ConsumerState<ReportScreen> with SingleTickerProviderStateMixin {
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

    if (report == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.assignment_outlined,
              size: 54,
              color: isDark ? KashifColors.darkTextMuted : KashifColors.lightTextMuted,
            ),
            const SizedBox(height: 12),
            Text(
              'لا يوجد تقرير فحص مفتوح حالياً',
              style: KashifTypography.arabic(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: isDark ? KashifColors.darkTextPrimary : KashifColors.lightTextPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'ابدأ تصوير أو رفع تقرير من تبويب "الفحص"',
              style: KashifTypography.arabic(
                fontSize: 12,
                color: isDark ? KashifColors.darkTextMuted : KashifColors.lightTextMuted,
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
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Vehicle Header Card
                    _buildVehicleHeader(report, isDark),
                    const SizedBox(height: 12),

                    // Health Score & Priority Summary
                    _buildHealthScoreCard(report, isDark),
                    const SizedBox(height: 12),

                    // Mechanic Summary Alert
                    _buildMechanicSummary(report, isDark),
                    const SizedBox(height: 12),

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
                  indicatorColor: isDark ? KashifColors.fuse15AInkDark : KashifColors.fuse15AInkLight,
                  labelColor: isDark ? KashifColors.fuse15AInkDark : KashifColors.fuse15AInkLight,
                  unselectedLabelColor: isDark ? KashifColors.darkTextMuted : KashifColors.lightTextMuted,
                  labelStyle: KashifTypography.arabic(fontSize: 13, fontWeight: FontWeight.w800),
                  unselectedLabelStyle: KashifTypography.arabic(fontSize: 12),
                  tabs: [
                    Tab(text: 'أعطال حرجة (${report.criticalFaults.length})'),
                    Tab(text: 'أعطال متوسطة (${report.moderateFaults.length})'),
                    Tab(text: 'في الذاكرة (${report.historyFaults.length})'),
                    Tab(text: 'الأنظمة السليمة (${report.passedSystems.length})'),
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
            _buildFaultsList(report.criticalFaults, 'لا توجد أعطال حرجة تهدد أمان السيارة بحمد الله.', CodeSeverity.critical),
            // Tab 2: Moderate Faults (20A)
            _buildFaultsList(report.moderateFaults, 'لا توجد أعطال متوسطة مسجلة.', CodeSeverity.moderate),
            // Tab 3: History Faults (25A)
            _buildFaultsList(report.historyFaults, 'لا توجد أكواد أعطال قديمة في الذاكرة.', CodeSeverity.history),
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
                // Unified Export & Share Button
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: KashifColors.fuse30ATab,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
                      padding: const EdgeInsets.symmetric(vertical: 11),
                    ),
                    onPressed: () => ExportOptionsSheet.show(context, report),
                    icon: const Icon(Icons.ios_share_rounded, size: 18),
                    label: Text(
                      'تصدير ومشاركة التقرير 📤',
                      style: KashifTypography.arabic(fontSize: 13, fontWeight: FontWeight.w800),
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
                  backgroundColor: isDark ? KashifColors.fuse15AInkDark : KashifColors.fuse15AInkLight,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                ),
                onPressed: widget.onOpenChat,
                icon: const Icon(Icons.chat_bubble_outline_rounded, size: 18),
                label: Text(
                  'استشارة الأسطى (مساعد الذكاء الاصطناعي)',
                  style: KashifTypography.arabic(fontSize: 13, fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVehicleHeader(DiagnosticReport report, bool isDark) {
    final v = report.vehicle;
    return FuseCell(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.directions_car_rounded, size: 20, color: isDark ? KashifColors.fuse15AInkDark : KashifColors.fuse15AInkLight),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${v.make} ${v.model} (${v.year})',
                  style: KashifTypography.arabic(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: isDark ? KashifColors.darkTextPrimary : KashifColors.lightTextPrimary,
                  ),
                ),
              ),
              IconButton(
                icon: Icon(
                  Icons.ios_share_rounded,
                  size: 20,
                  color: isDark ? KashifColors.fuse15AInkDark : KashifColors.fuse15AInkLight,
                ),
                tooltip: 'تصدير ومشاركة التقرير',
                padding: const EdgeInsets.all(4),
                constraints: const BoxConstraints(),
                onPressed: () => ExportOptionsSheet.show(context, report),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isDark ? KashifColors.darkBoard : KashifColors.lightBoard,
                  borderRadius: BorderRadius.circular(2),
                ),
                child: Text(
                  report.scannerInfo.toolName,
                  style: KashifTypography.mono(fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Text(
                'رقم الهيكل (VIN): ',
                style: KashifTypography.arabic(
                  fontSize: 11,
                  color: isDark ? KashifColors.darkTextMuted : KashifColors.lightTextMuted,
                ),
              ),
              Text(
                v.vin,
                style: KashifTypography.mono(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: isDark ? KashifColors.fuse15AInkDark : KashifColors.fuse15AInkLight,
                ),
              ),
            ],
          ),
          if (v.engineSpecs != null) ...[
            const SizedBox(height: 4),
            Text(
              'المحرك: ${v.engineSpecs!.displacement} | ${v.engineSpecs!.fuelType} | ${v.engineSpecs!.transmission}',
              style: KashifTypography.arabic(
                fontSize: 11,
                color: isDark ? KashifColors.darkTextMuted : KashifColors.lightTextMuted,
              ),
            ),
          ],
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
                _buildPriorityRow('حرج (10A)', report.criticalFaults.length, CodeSeverity.critical),
                const SizedBox(height: 4),
                _buildPriorityRow('متوسط (20A)', report.moderateFaults.length, CodeSeverity.moderate),
                const SizedBox(height: 4),
                _buildPriorityRow('في الذاكرة (25A)', report.historyFaults.length, CodeSeverity.history),
                const SizedBox(height: 4),
                _buildPriorityRow('أنظمة سليمة (30A)', report.passedSystems.length, CodeSeverity.passed),
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
        Text(
          label,
          style: KashifTypography.arabic(fontSize: 12),
        ),
        const Spacer(),
        Text(
          '$count',
          style: KashifTypography.mono(fontSize: 13, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildMechanicSummary(DiagnosticReport report, bool isDark) {
    return FuseCell(
      backgroundColor: isDark ? const Color(0xFF16232F) : const Color(0xFFE9F2FA),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.lightbulb_outline_rounded, size: 18, color: isDark ? KashifColors.fuse15AInkDark : KashifColors.fuse15AInkLight),
              const SizedBox(width: 6),
              Text(
                'خلاصة تشخيص الأسطى:',
                style: KashifTypography.arabic(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: isDark ? KashifColors.fuse15AInkDark : KashifColors.fuse15AInkLight,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            report.summary.briefSummaryArabic,
            style: KashifTypography.arabic(
              fontSize: 12,
              height: 1.5,
              color: isDark ? KashifColors.darkTextPrimary : KashifColors.lightTextPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFaultsList(List<DiagnosticFaultCode> faults, String emptyMsg, CodeSeverity sev) {
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
                style: KashifTypography.arabic(fontSize: 13, fontWeight: FontWeight.w600),
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
                style: KashifTypography.arabic(fontSize: 13, fontWeight: FontWeight.w600),
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
                    color: isDark ? KashifColors.darkTextPrimary : KashifColors.lightTextPrimary,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: (isDark ? KashifColors.fuse30AInkDark : KashifColors.fuse30AInkLight).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(2),
                ),
                child: Text(
                  'سليم 30A',
                  style: KashifTypography.arabic(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: isDark ? KashifColors.fuse30AInkDark : KashifColors.fuse30AInkLight,
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
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
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
