import 'package:flutter/material.dart';
import '../../core/theme/colors.dart';

/// FuseCell: The single container of the Fuse-Box Lid design system.
/// A silkscreened panel recessed into the board.
class FuseCell extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final Color? backgroundColor;
  final Border? customBorder;
  final VoidCallback? onTap;

  const FuseCell({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(12),
    this.margin,
    this.backgroundColor,
    this.customBorder,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final defaultBg = isDark ? KashifColors.darkCell : KashifColors.lightCell;
    final defaultBorder = isDark ? KashifColors.darkBorder : KashifColors.lightBorder;

    final container = Container(
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor ?? defaultBg,
        borderRadius: BorderRadius.circular(2), // Strict 1-2px plate radius
        border: customBorder ?? Border.all(color: defaultBorder, width: 1),
      ),
      child: child,
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(2),
        child: container,
      );
    }

    return container;
  }
}
