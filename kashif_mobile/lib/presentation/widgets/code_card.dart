import 'package:flutter/material.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/typography.dart';
import '../../data/models/fault_code.dart';
import 'fuse_cell.dart';
import 'severity_seat.dart';
import 'sensor_locator_sheet.dart';
import '../screens/fuse_box_screen.dart';

class CodeCard extends StatefulWidget {
  final DiagnosticFaultCode fault;

  const CodeCard({super.key, required this.fault});

  @override
  State<CodeCard> createState() => _CodeCardState();
}

class _CodeCardState extends State<CodeCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final f = widget.fault;

    return FuseCell(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row: Code, Module, Severity
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF132347)
                      : const Color(0xFFE8F0FC),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: isDark
                        ? KashifColors.goldPrimary.withValues(alpha: 0.6)
                        : KashifColors.royalBlue.withValues(alpha: 0.4),
                  ),
                ),
                child: Text(
                  f.code,
                  style: KashifTypography.mono(
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    color: isDark
                        ? KashifColors.goldLight
                        : KashifColors.royalBlue,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color:
                      (isDark
                              ? KashifColors.royalBlueLight
                              : KashifColors.royalBlue)
                          .withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  f.module,
                  style: KashifTypography.mono(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: isDark
                        ? KashifColors.royalBlueElectric
                        : KashifColors.royalBlue,
                  ),
                ),
              ),
              const Spacer(),
              SeveritySeat(severity: f.severity, compact: true),
            ],
          ),
          const SizedBox(height: 10),

          // Libyan Term
          Text(
            f.libyanTerm,
            style: KashifTypography.arabic(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: isDark
                  ? KashifColors.darkTextPrimary
                  : KashifColors.lightTextPrimary,
            ),
          ),
          const SizedBox(height: 3),

          // English Standard Description
          Text(
            f.standardDescriptionEn,
            style: KashifTypography.mono(
              fontSize: 12,
              color: isDark
                  ? KashifColors.darkTextMuted
                  : KashifColors.lightTextMuted,
            ),
          ),
          const SizedBox(height: 8),

          // Action / Recommendation Box
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E2822) : const Color(0xFFEBF5EE),
              borderRadius: BorderRadius.circular(2),
              border: Border.all(
                color: isDark
                    ? KashifColors.fuse30AInkDark
                    : KashifColors.fuse30AInkLight,
                width: 0.8,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.build_circle_outlined,
                  size: 16,
                  color: isDark
                      ? KashifColors.fuse30AInkDark
                      : KashifColors.fuse30AInkLight,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    f.recommendedAction,
                    style: KashifTypography.arabic(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? KashifColors.fuse30AInkDark
                          : KashifColors.fuse30AInkLight,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Action Buttons: Sensor & Wiring Guide Sheet and Fuse Finder
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: isDark
                        ? KashifColors.goldLight
                        : KashifColors.goldDark,
                    side: BorderSide(
                      color: isDark
                          ? KashifColors.goldPrimary.withValues(alpha: 0.6)
                          : KashifColors.goldDark,
                      width: 1,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 7,
                    ),
                  ),
                  onPressed: () => SensorLocatorSheet.show(context, fault: f),
                  icon: const Icon(Icons.location_on_outlined, size: 15),
                  label: Text(
                    'مكان الحساس والفحص',
                    style: KashifTypography.arabic(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFFD4AF37),
                  side: const BorderSide(color: Color(0xFFD4AF37), width: 1),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 7,
                  ),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => FuseBoxScreen(initialDtcFilter: f.code),
                    ),
                  );
                },
                icon: const Icon(Icons.electric_bolt_rounded, size: 15),
                label: Text(
                  'الفيوزات',
                  style: KashifTypography.arabic(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          // Expand / Collapse details button
          const SizedBox(height: 4),
          InkWell(
            onTap: () => setState(() => _expanded = !_expanded),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _expanded
                        ? 'إخفاء تفاصيل الفحص والأسباب'
                        : 'عرض الأعراض وأسباب العطل والفحص الكهربائي',
                    style: KashifTypography.arabic(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? KashifColors.goldLight
                          : KashifColors.royalBlue,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    _expanded
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    size: 16,
                    color: isDark
                        ? KashifColors.goldLight
                        : KashifColors.royalBlue,
                  ),
                ],
              ),
            ),
          ),

          // Expanded section
          if (_expanded) ...[
            const Divider(height: 16),
            if (f.driverSymptoms.isNotEmpty) ...[
              Text(
                'الأعراض الميكانيكية:',
                style: KashifTypography.arabic(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: isDark
                      ? KashifColors.darkTextMuted
                      : KashifColors.lightTextMuted,
                ),
              ),
              const SizedBox(height: 4),
              ...f.driverSymptoms.map(
                (s) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('• '),
                      Expanded(
                        child: Text(
                          s,
                          style: KashifTypography.arabic(fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
            ],

            if (f.rootCauses.isNotEmpty) ...[
              Text(
                'الأسباب الجذرية المحتملة:',
                style: KashifTypography.arabic(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: isDark
                      ? KashifColors.darkTextMuted
                      : KashifColors.lightTextMuted,
                ),
              ),
              const SizedBox(height: 4),
              ...f.rootCauses.map(
                (c) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('• '),
                      Expanded(
                        child: Text(
                          c,
                          style: KashifTypography.arabic(fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
            ],

            // Electrical Diagnostics Box
            if (f.electricalDiagnostics != null) ...[
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF262217)
                      : const Color(0xFFFFF9E6),
                  borderRadius: BorderRadius.circular(2),
                  border: Border.all(
                    color: isDark
                        ? KashifColors.fuse20AInkDark
                        : KashifColors.fuse20AInkLight,
                    width: 0.8,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.electric_bolt_rounded,
                          size: 16,
                          color: isDark
                              ? KashifColors.fuse20AInkDark
                              : KashifColors.fuse20AInkLight,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'دليل الفحص الكهربائي والفيوزات:',
                          style: KashifTypography.arabic(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: isDark
                                ? KashifColors.fuse20AInkDark
                                : KashifColors.fuse20AInkLight,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    if (f.electricalDiagnostics!.boxLocation.isNotEmpty)
                      Text(
                        '📍 علبة الفيوز: ${f.electricalDiagnostics!.boxLocation} ${f.electricalDiagnostics!.fuseNumber != null ? "(${f.electricalDiagnostics!.fuseNumber})" : ""}',
                        style: KashifTypography.arabic(fontSize: 11),
                      ),
                    if (f.electricalDiagnostics!.sensorArea.isNotEmpty)
                      Text(
                        '🔍 موقع الحساس: ${f.electricalDiagnostics!.sensorArea}',
                        style: KashifTypography.arabic(fontSize: 11),
                      ),
                    if (f.electricalDiagnostics!.multimeterTip.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          '⚡ قياس الفولتية: ${f.electricalDiagnostics!.multimeterTip}',
                          style: KashifTypography.arabic(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }
}
