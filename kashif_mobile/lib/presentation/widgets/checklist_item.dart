import 'package:flutter/material.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/typography.dart';
import '../../data/models/checklist_step.dart';
import 'fuse_cell.dart';

class ChecklistItemWidget extends StatefulWidget {
  final DiagnosticChecklistStep step;
  final ValueChanged<bool>? onStatusChanged;

  const ChecklistItemWidget({
    super.key,
    required this.step,
    this.onStatusChanged,
  });

  @override
  State<ChecklistItemWidget> createState() => _ChecklistItemWidgetState();
}

class _ChecklistItemWidgetState extends State<ChecklistItemWidget> {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final step = widget.step;

    return FuseCell(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Checkbox(
            value: step.isCompleted,
            activeColor: isDark
                ? KashifColors.goldPrimary
                : KashifColors.royalBlue,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
            onChanged: (val) {
              setState(() {
                step.isCompleted = val ?? false;
              });
              widget.onStatusChanged?.call(step.isCompleted);
            },
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF132347)
                            : const Color(0xFFE8F0FC),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: isDark
                              ? KashifColors.goldPrimary.withValues(alpha: 0.5)
                              : KashifColors.royalBlue.withValues(alpha: 0.4),
                          width: 0.8,
                        ),
                      ),
                      child: Text(
                        'خطوة ${step.stepNumber}',
                        style: KashifTypography.arabic(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: isDark
                              ? KashifColors.goldLight
                              : KashifColors.royalBlue,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        step.actionTitle,
                        style: KashifTypography.arabic(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: step.isCompleted
                              ? (isDark
                                    ? KashifColors.darkTextMuted
                                    : KashifColors.lightTextMuted)
                              : (isDark
                                    ? KashifColors.darkTextPrimary
                                    : KashifColors.lightTextPrimary),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  step.actionDescriptionLibyan,
                  style: KashifTypography.arabic(
                    fontSize: 12,
                    color: isDark
                        ? KashifColors.darkTextMuted
                        : KashifColors.lightTextMuted,
                  ),
                ),
                if (step.toolingNeeded.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.handyman_outlined,
                        size: 13,
                        color: isDark
                            ? KashifColors.fuse20AInkDark
                            : KashifColors.fuse20AInkLight,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'العدة: ${step.toolingNeeded}',
                        style: KashifTypography.arabic(
                          fontSize: 11,
                          color: isDark
                              ? KashifColors.fuse20AInkDark
                              : KashifColors.fuse20AInkLight,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
