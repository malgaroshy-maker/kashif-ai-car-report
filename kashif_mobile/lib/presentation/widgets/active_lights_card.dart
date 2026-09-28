import 'package:flutter/material.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/typography.dart';
import '../../data/models/dashboard_light.dart';
import '../../data/models/diagnostic_report.dart';
import '../../data/repositories/dashboard_lights_repository.dart';
import '../screens/dashboard_lights_screen.dart';
import 'fuse_cell.dart';
import 'car_dashboard_symbol.dart';

class ActiveLightsCard extends StatelessWidget {
  final DiagnosticReport report;
  final ValueChanged<List<String>> onUpdateLights;

  const ActiveLightsCard({
    super.key,
    required this.report,
    required this.onUpdateLights,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final lightIds = report.activeWarningLightIds;

    // Resolve light items from repository
    final activeItems = lightIds
        .map((id) => DashboardLightsRepository.getById(id))
        .whereType<DashboardLightItem>()
        .toList();

    // Collect all DTC codes from the report to match correlations
    final allReportDtcCodes = [
      ...report.criticalFaults.map((f) => f.code.toUpperCase().trim()),
      ...report.moderateFaults.map((f) => f.code.toUpperCase().trim()),
      ...report.historyFaults.map((f) => f.code.toUpperCase().trim()),
    ];

    void openSelectionScreen() {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => DashboardLightsScreen(
            initialSelectedIds: lightIds,
            onLightsSelected: (newSelected) {
              onUpdateLights(newSelected);
            },
          ),
        ),
      );
    }

    if (activeItems.isEmpty) {
      return FuseCell(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        onTap: openSelectionScreen,
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color:
                    (isDark ? KashifColors.goldLight : KashifColors.royalBlue)
                        .withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.lightbulb_outline_rounded,
                size: 22,
                color: isDark ? KashifColors.goldLight : KashifColors.royalBlue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'لمبات لوحة العدادات (الطبلون)',
                    style: KashifTypography.arabic(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: isDark
                          ? KashifColors.darkTextPrimary
                          : KashifColors.lightTextPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'اضغط هنا لتحديد اللمبات التي كانت مشتعلة أثناء الفحص ومطابقتها بالأعطال',
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
            const Icon(
              Icons.add_circle_outline_rounded,
              size: 20,
              color: Color(0xFFD4AF37),
            ),
          ],
        ),
      );
    }

    return FuseCell(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.warning_amber_rounded,
                size: 20,
                color: Color(0xFFD4AF37),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'لمبات الطبلون المضاءة أثناء الفحص (${activeItems.length})',
                  style: KashifTypography.arabic(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: isDark
                        ? KashifColors.darkTextPrimary
                        : KashifColors.lightTextPrimary,
                  ),
                ),
              ),
              InkWell(
                onTap: openSelectionScreen,
                borderRadius: BorderRadius.circular(6),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF1E2838)
                        : const Color(0xFFEEF3F8),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color:
                          (isDark
                                  ? KashifColors.goldLight
                                  : KashifColors.royalBlue)
                              .withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.edit_rounded,
                        size: 13,
                        color: Color(0xFFD4AF37),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'تعديل',
                        style: KashifTypography.arabic(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: isDark
                              ? KashifColors.goldLight
                              : KashifColors.royalBlue,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Horizontal scroll of glowing lights
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: activeItems.map((item) {
                final lightColor = Color(item.colorValue);
                final hasMatchedDtc = item.associatedDTCs.any(
                  (c) => allReportDtcCodes.contains(c.toUpperCase()),
                );

                return Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: InkWell(
                    onTap: () => _showLightDetailSheet(
                      context,
                      item,
                      hasMatchedDtc,
                      isDark,
                    ),
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: lightColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: lightColor, width: 1.2),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CarDashboardSymbol(
                            symbolId: item.id,
                            color: lightColor,
                            size: 22,
                          ),
                          const SizedBox(width: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.nameArabic.split('(').first.trim(),
                                style: KashifTypography.arabic(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w800,
                                  color: lightColor,
                                ),
                              ),
                              if (hasMatchedDtc)
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.bolt_rounded,
                                      size: 10,
                                      color: Color(0xFFD4AF37),
                                    ),
                                    Text(
                                      'كود عطل مطابق',
                                      style: KashifTypography.arabic(
                                        fontSize: 9.5,
                                        fontWeight: FontWeight.bold,
                                        color: const Color(0xFFD4AF37),
                                      ),
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  void _showLightDetailSheet(
    BuildContext context,
    DashboardLightItem item,
    bool hasMatchedDtc,
    bool isDark,
  ) {
    final lightColor = Color(item.colorValue);
    final canDriveColor = Color(item.canDrive.colorValue);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: BoxDecoration(
          color: isDark ? KashifColors.darkBoard : KashifColors.lightBoard,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          border: Border.all(
            color: isDark ? KashifColors.darkBorder : KashifColors.lightBorder,
          ),
        ),
        padding: const EdgeInsets.all(18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: lightColor.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: lightColor, width: 1.5),
                  ),
                  child: Center(
                    child: CarDashboardSymbol(
                      symbolId: item.id,
                      color: lightColor,
                      size: 28,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.nameArabic,
                        style: KashifTypography.arabic(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w800,
                          color: isDark
                              ? KashifColors.darkTextPrimary
                              : KashifColors.lightTextPrimary,
                        ),
                      ),
                      Text(
                        item.nameEnglish,
                        style: TextStyle(
                          fontFamily: 'Courier',
                          fontSize: 11,
                          color: isDark
                              ? KashifColors.darkTextMuted
                              : KashifColors.lightTextMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, size: 20),
                  onPressed: () => Navigator.pop(ctx),
                ),
              ],
            ),
            const Divider(height: 18),

            // Can-Drive status
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: canDriveColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: canDriveColor.withValues(alpha: 0.5)),
              ),
              child: Row(
                children: [
                  Icon(
                    item.canDrive == CanDriveStatus.stopImmediately
                        ? Icons.dangerous_rounded
                        : Icons.warning_amber_rounded,
                    color: canDriveColor,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      item.canDrive.labelArabic,
                      style: KashifTypography.arabic(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: canDriveColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),

            // Matched DTC notice if found
            if (hasMatchedDtc)
              Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFD4AF37).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: const Color(0xFFD4AF37)),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.bolt_rounded,
                      size: 16,
                      color: Color(0xFFD4AF37),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'تم رصد أكواد أعطال مسجلة في الفحص تتطابق مع سبب إضاءة هذه اللمبة!',
                        style: KashifTypography.arabic(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                          color: isDark
                              ? const Color(0xFFF5C84C)
                              : const Color(0xFF7A5807),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            // Meaning
            Text(
              item.meaningArabic,
              style: KashifTypography.arabic(
                fontSize: 12.5,
                color: isDark
                    ? KashifColors.darkTextPrimary
                    : KashifColors.lightTextPrimary,
              ),
            ),
            const SizedBox(height: 10),

            // Action required
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF142019)
                    : const Color(0xFFF0F9F3),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: const Color(0xFF2E9E5B).withValues(alpha: 0.3),
                ),
              ),
              child: Text(
                item.actionRequired,
                style: KashifTypography.arabic(
                  fontSize: 11.5,
                  color: isDark
                      ? const Color(0xFFC8E6C9)
                      : const Color(0xFF1B5E20),
                ),
              ),
            ),
            const SizedBox(height: 16),

            ElevatedButton(
              onPressed: () => Navigator.pop(ctx),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD4AF37),
                foregroundColor: const Color(0xFF070E1E),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'إغلاق',
                style: KashifTypography.arabic(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
