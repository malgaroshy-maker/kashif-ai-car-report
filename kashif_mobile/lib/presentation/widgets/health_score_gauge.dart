import 'package:flutter/material.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/typography.dart';

class HealthScoreGauge extends StatelessWidget {
  final int score;
  final String status;
  final double size;

  const HealthScoreGauge({
    super.key,
    required this.score,
    required this.status,
    this.size = 110,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Color progressColor;
    Color textColor;
    if (score >= 80) {
      progressColor = KashifColors.fuse30ATab;
      textColor = isDark ? KashifColors.fuse30AInkDark : KashifColors.fuse30AInkLight;
    } else if (score >= 50) {
      progressColor = KashifColors.fuse20ATab;
      textColor = isDark ? KashifColors.fuse20AInkDark : KashifColors.fuse20AInkLight;
    } else {
      progressColor = KashifColors.fuse10ATab;
      textColor = isDark ? KashifColors.fuse10AInkDark : KashifColors.fuse10AInkLight;
    }

    final trackColor = isDark ? KashifColors.darkRibLit : KashifColors.lightBorder;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: size,
          height: size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Track
              SizedBox(
                width: size,
                height: size,
                child: CircularProgressIndicator(
                  value: 1.0,
                  strokeWidth: 9,
                  valueColor: AlwaysStoppedAnimation<Color>(trackColor),
                ),
              ),
              // Value progress
              SizedBox(
                width: size,
                height: size,
                child: CircularProgressIndicator(
                  value: (score.clamp(0, 100)) / 100.0,
                  strokeWidth: 9,
                  strokeCap: StrokeCap.square, // Automotive mechanical square edge
                  valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                ),
              ),
              // Inner text
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$score%',
                    style: KashifTypography.mono(
                      fontSize: size * 0.26,
                      fontWeight: FontWeight.w900,
                      color: textColor,
                    ),
                  ),
                  Text(
                    'سلامة السيارة',
                    style: KashifTypography.arabic(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: isDark ? KashifColors.darkTextMuted : KashifColors.lightTextMuted,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
          decoration: BoxDecoration(
            color: progressColor.withValues(alpha: 0.15),
            border: Border.all(color: textColor, width: 1),
            borderRadius: BorderRadius.circular(2),
          ),
          child: Text(
            status,
            style: KashifTypography.arabic(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: textColor,
            ),
          ),
        ),
      ],
    );
  }
}
