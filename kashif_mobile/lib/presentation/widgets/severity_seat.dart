import 'package:flutter/material.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/typography.dart';
import '../../data/models/fault_code.dart';

class SeveritySeat extends StatelessWidget {
  final CodeSeverity severity;
  final bool compact;
  final String? customLabel;

  const SeveritySeat({
    super.key,
    required this.severity,
    this.compact = false,
    this.customLabel,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Color tabColor;
    Color inkColor;
    String ampText;
    String labelArabic;
    IconData shapeIcon;

    switch (severity) {
      case CodeSeverity.critical:
        tabColor = KashifColors.fuse10ATab;
        inkColor = isDark ? KashifColors.fuse10AInkDark : KashifColors.fuse10AInkLight;
        ampText = '10A';
        labelArabic = 'حرج';
        shapeIcon = Icons.warning_amber_rounded;
        break;
      case CodeSeverity.moderate:
        tabColor = KashifColors.fuse20ATab;
        inkColor = isDark ? KashifColors.fuse20AInkDark : KashifColors.fuse20AInkLight;
        ampText = '20A';
        labelArabic = 'متوسط';
        shapeIcon = Icons.remove_circle_outline_rounded;
        break;
      case CodeSeverity.passed:
        tabColor = KashifColors.fuse30ATab;
        inkColor = isDark ? KashifColors.fuse30AInkDark : KashifColors.fuse30AInkLight;
        ampText = '30A';
        labelArabic = 'سليم';
        shapeIcon = Icons.check_circle_outline_rounded;
        break;
      case CodeSeverity.history:
        tabColor = KashifColors.fuse25ATab;
        inkColor = isDark ? KashifColors.fuse25AInkDark : KashifColors.fuse25AInkLight;
        ampText = '25A';
        labelArabic = 'ذاكرة';
        shapeIcon = Icons.radio_button_unchecked_rounded;
        break;
    }

    if (compact) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: tabColor.withValues(alpha: 0.15),
          border: Border.all(color: inkColor, width: 1),
          borderRadius: BorderRadius.circular(2),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(shapeIcon, size: 12, color: inkColor),
            const SizedBox(width: 4),
            Text(
              ampText,
              style: KashifTypography.mono(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: inkColor,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: tabColor.withValues(alpha: 0.15),
        border: Border.all(color: inkColor, width: 1.2),
        borderRadius: BorderRadius.circular(2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(shapeIcon, size: 14, color: inkColor),
          const SizedBox(width: 5),
          Text(
            customLabel ?? labelArabic,
            style: KashifTypography.arabic(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: inkColor,
            ),
          ),
          const SizedBox(width: 5),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
            decoration: BoxDecoration(
              color: inkColor,
              borderRadius: BorderRadius.circular(1),
            ),
            child: Text(
              ampText,
              style: KashifTypography.mono(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
