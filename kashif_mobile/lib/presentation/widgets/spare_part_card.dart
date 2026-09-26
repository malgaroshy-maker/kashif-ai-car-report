import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/typography.dart';
import '../../data/models/spare_part.dart';
import 'fuse_cell.dart';

class SparePartCard extends StatelessWidget {
  final SparePartItem part;

  const SparePartCard({super.key, required this.part});

  void _showImageDialog(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        child: Stack(
          alignment: Alignment.topRight,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: Image.network(
                      imageUrl,
                      fit: BoxFit.contain,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return const SizedBox(
                          height: 200,
                          child: Center(child: CircularProgressIndicator()),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) => const SizedBox(
                        height: 150,
                        child: Center(child: Icon(Icons.broken_image_rounded, size: 48)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    part.partNameLibyan,
                    style: KashifTypography.arabic(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  if (part.oemPartNumber != null)
                    Text(
                      'OEM: ${part.oemPartNumber}',
                      style: KashifTypography.mono(fontSize: 12),
                    ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close_rounded, color: Colors.white),
              onPressed: () => Navigator.pop(ctx),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final hasImage = part.partImageUrl != null && part.partImageUrl!.isNotEmpty;

    return FuseCell(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Photo Thumbnail or Visual Schematic Icon
              GestureDetector(
                onTap: hasImage ? () => _showImageDialog(context, part.partImageUrl!) : null,
                child: Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: isDark ? KashifColors.darkBoard : KashifColors.lightBoard,
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: isDark ? KashifColors.darkBorder : KashifColors.lightBorder,
                    ),
                  ),
                  child: hasImage
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(3),
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                              Image.network(
                                part.partImageUrl!,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => Icon(
                                  Icons.settings_suggest_rounded,
                                  size: 28,
                                  color: isDark ? Colors.white38 : Colors.black38,
                                ),
                              ),
                              Positioned(
                                bottom: 2,
                                right: 2,
                                child: Container(
                                  padding: const EdgeInsets.all(2),
                                  decoration: BoxDecoration(
                                    color: Colors.black54,
                                    borderRadius: BorderRadius.circular(2),
                                  ),
                                  child: const Icon(Icons.zoom_in_rounded, size: 12, color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                        )
                      : Icon(
                          Icons.build_rounded,
                          size: 28,
                          color: isDark ? KashifColors.fuse15AInkDark : KashifColors.fuse15AInkLight,
                        ),
                ),
              ),
              const SizedBox(width: 10),

              // Part Names & Category
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            part.partNameLibyan,
                            style: KashifTypography.arabic(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: isDark ? KashifColors.darkTextPrimary : KashifColors.lightTextPrimary,
                            ),
                          ),
                        ),
                        if (part.estimatedPriceRangeLYD != null) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                            decoration: BoxDecoration(
                              color: isDark ? const Color(0xFF1E2822) : const Color(0xFFEBF5EE),
                              borderRadius: BorderRadius.circular(2),
                              border: Border.all(
                                color: isDark ? KashifColors.fuse30AInkDark : KashifColors.fuse30AInkLight,
                                width: 0.8,
                              ),
                            ),
                            child: Text(
                              '${part.estimatedPriceRangeLYD!.min.toInt()} - ${part.estimatedPriceRangeLYD!.max.toInt()} د.ل',
                              style: KashifTypography.mono(
                                fontSize: 12,
                                fontWeight: FontWeight.w900,
                                color: isDark ? KashifColors.fuse30AInkDark : KashifColors.fuse30AInkLight,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      part.partNameEnglish,
                      style: KashifTypography.mono(
                        fontSize: 11,
                        color: isDark ? KashifColors.darkTextMuted : KashifColors.lightTextMuted,
                      ),
                    ),
                    const SizedBox(height: 4),

                    // Category & Urgency Badges
                    Row(
                      children: [
                        if (part.diagramCategory.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: isDark ? KashifColors.darkBoard : KashifColors.lightBoard,
                              borderRadius: BorderRadius.circular(2),
                            ),
                            child: Text(
                              part.diagramCategory,
                              style: KashifTypography.arabic(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: isDark ? KashifColors.fuse15AInkDark : KashifColors.fuse15AInkLight,
                              ),
                            ),
                          ),
                        if (part.relatedCode.isNotEmpty) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                            decoration: BoxDecoration(
                              color: isDark ? Colors.white10 : Colors.black12,
                              borderRadius: BorderRadius.circular(2),
                            ),
                            child: Text(
                              part.relatedCode,
                              style: KashifTypography.mono(fontSize: 10, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                        if (part.replacementUrgency != null && part.replacementUrgency!.isNotEmpty) ...[
                          const SizedBox(width: 6),
                          Text(
                            part.replacementUrgency!,
                            style: KashifTypography.arabic(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: part.replacementUrgency!.contains('حرج') || part.replacementUrgency!.contains('عاجل')
                                  ? (isDark ? KashifColors.fuse10AInkDark : KashifColors.fuse10AInkLight)
                                  : (isDark ? KashifColors.fuse20AInkDark : KashifColors.fuse20AInkLight),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          // OEM Part Number Row
          if (part.oemPartNumber != null && part.oemPartNumber!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                  'رقم الوكالة الأصلي (OEM): ',
                  style: KashifTypography.arabic(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: isDark ? KashifColors.darkTextMuted : KashifColors.lightTextMuted,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: isDark ? KashifColors.darkBoard : KashifColors.lightBoard,
                    borderRadius: BorderRadius.circular(2),
                    border: Border.all(
                      color: isDark ? KashifColors.darkBorder : KashifColors.lightBorder,
                    ),
                  ),
                  child: Text(
                    part.oemPartNumber!,
                    style: KashifTypography.mono(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: isDark ? KashifColors.fuse15AInkDark : KashifColors.fuse15AInkLight,
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.copy_rounded, size: 14),
                  padding: const EdgeInsets.all(4),
                  constraints: const BoxConstraints(),
                  tooltip: 'نسخ رقم القطعة',
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: part.oemPartNumber!));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('تم نسخ رقم القطعة OEM: ${part.oemPartNumber}'),
                        duration: const Duration(seconds: 1),
                      ),
                    );
                  },
                ),
              ],
            ),
          ],

          // Aftermarket Alternatives
          if (part.aftermarketReplacements.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              'الشركات البديلة (تجارية): ${part.aftermarketReplacements.join(", ")}',
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
}
