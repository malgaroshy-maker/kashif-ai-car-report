import 'package:flutter/material.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/typography.dart';

/// Molded Rib: Depth element reproducing the molded ridges in a car fuse-box lid.
class MoldedRib extends StatelessWidget {
  final String? label;
  final bool heavy;
  final EdgeInsetsGeometry padding;

  const MoldedRib({
    super.key,
    this.label,
    this.heavy = false,
    this.padding = const EdgeInsets.symmetric(vertical: 8),
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final ribDark = isDark ? KashifColors.darkRib : KashifColors.lightRib;
    final ribLit = isDark ? KashifColors.darkRibLit : KashifColors.lightRibLit;
    final thickness = heavy ? 2.5 : 1.0;

    if (label != null && label!.isNotEmpty) {
      return Padding(
        padding: padding,
        child: Row(
          children: [
            Expanded(
              child: Container(
                height: thickness,
                decoration: BoxDecoration(
                  color: ribDark,
                  boxShadow: [
                    BoxShadow(
                      color: ribLit,
                      offset: const Offset(0, 1),
                      blurRadius: 0,
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Text(
                label!,
                style: KashifTypography.arabic(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: isDark ? KashifColors.darkTextMuted : KashifColors.lightTextMuted,
                ),
              ),
            ),
            Expanded(
              child: Container(
                height: thickness,
                decoration: BoxDecoration(
                  color: ribDark,
                  boxShadow: [
                    BoxShadow(
                      color: ribLit,
                      offset: const Offset(0, 1),
                      blurRadius: 0,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Padding(
      padding: padding,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: thickness,
            color: ribDark,
          ),
          Container(
            height: 1,
            color: ribLit,
          ),
        ],
      ),
    );
  }
}
