import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/typography.dart';
import '../../data/models/spare_part.dart';
import '../../data/repositories/part_number_resolver.dart';
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
                      errorBuilder: (context, error, stackTrace) =>
                          const SizedBox(
                            height: 150,
                            child: Center(
                              child: Icon(Icons.broken_image_rounded, size: 48),
                            ),
                          ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    part.partNameLibyan,
                    style: KashifTypography.arabic(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
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
    final p = PartNumberResolver.enrich(part);
    final hasImage = p.partImageUrl != null && p.partImageUrl!.isNotEmpty;

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
                onTap: hasImage
                    ? () => _showImageDialog(context, p.partImageUrl!)
                    : null,
                child: Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF132347)
                        : const Color(0xFFE8F0FC),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isDark
                          ? KashifColors.goldPrimary.withValues(alpha: 0.4)
                          : KashifColors.royalBlue.withValues(alpha: 0.3),
                    ),
                  ),
                  child: hasImage
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(7),
                          child: Stack(
                            fit: StackFit.expand,
                            children: [
                                Image.network(
                                p.partImageUrl!,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    Icon(
                                      Icons.settings_suggest_rounded,
                                      size: 28,
                                      color: isDark
                                          ? KashifColors.goldLight
                                          : KashifColors.royalBlue,
                                    ),
                              ),
                              Positioned(
                                bottom: 2,
                                right: 2,
                                child: Container(
                                  padding: const EdgeInsets.all(2),
                                  decoration: BoxDecoration(
                                    color: Colors.black54,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Icon(
                                    Icons.zoom_in_rounded,
                                    size: 12,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      : Icon(
                          Icons.build_rounded,
                          size: 28,
                          color: isDark
                              ? KashifColors.goldLight
                              : KashifColors.royalBlue,
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
                            p.partNameLibyan,
                            style: KashifTypography.arabic(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: isDark
                                  ? KashifColors.darkTextPrimary
                                  : KashifColors.lightTextPrimary,
                            ),
                          ),
                        ),
                        if (p.estimatedPriceRangeLYD != null) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? const Color(0xFF221D0E)
                                  : const Color(0xFFFFF9E6),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: isDark
                                    ? KashifColors.goldLight
                                    : KashifColors.goldDark,
                                width: 0.8,
                              ),
                            ),
                            child: Text(
                              '${p.estimatedPriceRangeLYD!.min.toInt()} - ${p.estimatedPriceRangeLYD!.max.toInt()} د.ل',
                              style: KashifTypography.mono(
                                fontSize: 12,
                                fontWeight: FontWeight.w900,
                                color: isDark
                                    ? KashifColors.goldLight
                                    : KashifColors.goldDark,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      p.partNameEnglish,
                      style: KashifTypography.mono(
                        fontSize: 11,
                        color: isDark
                            ? KashifColors.darkTextMuted
                            : KashifColors.lightTextMuted,
                      ),
                    ),
                    const SizedBox(height: 4),

                    // Category & Urgency Badges
                    Row(
                      children: [
                        if (p.diagramCategory.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? KashifColors.darkBoard
                                  : KashifColors.lightBoard,
                              borderRadius: BorderRadius.circular(2),
                            ),
                            child: Text(
                              p.diagramCategory,
                              style: KashifTypography.arabic(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: isDark
                                    ? KashifColors.fuse15AInkDark
                                    : KashifColors.fuse15AInkLight,
                              ),
                            ),
                          ),
                        if (p.relatedCode.isNotEmpty) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 5,
                              vertical: 1,
                            ),
                            decoration: BoxDecoration(
                              color: isDark ? Colors.white10 : Colors.black12,
                              borderRadius: BorderRadius.circular(2),
                            ),
                            child: Text(
                              p.relatedCode,
                              style: KashifTypography.mono(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                        if (p.replacementUrgency != null &&
                            p.replacementUrgency!.isNotEmpty) ...[
                          const SizedBox(width: 6),
                          Text(
                            p.replacementUrgency!,
                            style: KashifTypography.arabic(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color:
                                  p.replacementUrgency!.contains('حرج') ||
                                      p.replacementUrgency!.contains('عاجل')
                                  ? (isDark
                                        ? KashifColors.fuse10AInkDark
                                        : KashifColors.fuse10AInkLight)
                                  : (isDark
                                        ? KashifColors.fuse20AInkDark
                                        : KashifColors.fuse20AInkLight),
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
          if (p.oemPartNumber != null &&
              p.oemPartNumber!.trim().isNotEmpty &&
              p.oemPartNumber!.toUpperCase() != 'N/A' &&
              p.oemPartNumber != 'null') ...[
            const SizedBox(height: 8),
            Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 6,
              runSpacing: 4,
              children: [
                Text(
                  'رقم الوكالة الأصلي (OEM): ',
                  style: KashifTypography.arabic(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? KashifColors.darkTextMuted
                        : KashifColors.lightTextMuted,
                  ),
                ),
                InkWell(
                  borderRadius: BorderRadius.circular(6),
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: p.oemPartNumber!));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'تم نسخ رقم القطعة OEM: ${p.oemPartNumber}',
                        ),
                        duration: const Duration(seconds: 1),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
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
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          p.oemPartNumber!,
                          style: KashifTypography.mono(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: isDark
                                ? KashifColors.goldLight
                                : KashifColors.royalBlue,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          Icons.copy_rounded,
                          size: 13,
                          color: isDark
                              ? KashifColors.goldLight
                              : KashifColors.royalBlue,
                        ),
                      ],
                    ),
                  ),
                ),
                // Direct Google Search Action
                InkWell(
                  borderRadius: BorderRadius.circular(6),
                  onTap: () async {
                    final query = '${p.oemPartNumber!} ${p.partNameEnglish}'.trim();
                    final uri = Uri.parse(
                      'https://www.google.com/search?q=${Uri.encodeComponent(query)}',
                    );
                    try {
                      if (await canLaunchUrl(uri)) {
                        await launchUrl(uri, mode: LaunchMode.externalApplication);
                      }
                    } catch (_) {}
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF1B281B)
                          : const Color(0xFFEAF5EA),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: isDark
                            ? const Color(0xFF388E3C)
                            : const Color(0xFF4CAF50),
                        width: 0.8,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.travel_explore_rounded,
                          size: 13,
                          color: isDark
                              ? const Color(0xFF81C784)
                              : const Color(0xFF2E7D32),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'بحث في Google 🔍',
                          style: KashifTypography.arabic(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: isDark
                                ? const Color(0xFF81C784)
                                : const Color(0xFF2E7D32),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],

          // Aftermarket Alternatives with Interactive Search/Copy
          if (p.aftermarketReplacements.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              'الشركات البديلة المعتمدة (اضغط للبحث في Google أو النسخ):',
              style: KashifTypography.arabic(
                fontSize: 11,
                color: isDark
                    ? KashifColors.darkTextMuted
                    : KashifColors.lightTextMuted,
              ),
            ),
            const SizedBox(height: 4),
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: p.aftermarketReplacements.map((alt) {
                return InkWell(
                  borderRadius: BorderRadius.circular(4),
                  onTap: () async {
                    final uri = Uri.parse(
                      'https://www.google.com/search?q=${Uri.encodeComponent(alt)}',
                    );
                    try {
                      if (await canLaunchUrl(uri)) {
                        await launchUrl(uri, mode: LaunchMode.externalApplication);
                      }
                    } catch (_) {}
                  },
                  onLongPress: () {
                    Clipboard.setData(ClipboardData(text: alt));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('تم نسخ كود البديل: $alt'),
                        duration: const Duration(seconds: 1),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2.5,
                    ),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.white10
                          : Colors.black.withValues(alpha: 0.04),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: isDark ? Colors.white24 : Colors.black12,
                        width: 0.7,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          alt,
                          style: KashifTypography.mono(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.open_in_new_rounded,
                          size: 10.5,
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }
}
