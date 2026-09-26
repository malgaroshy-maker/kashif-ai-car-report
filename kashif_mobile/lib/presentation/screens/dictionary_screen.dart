import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/typography.dart';
import '../../data/models/dictionary_entry.dart';
import '../providers/dictionary_provider.dart';
import '../widgets/fuse_cell.dart';

class DictionaryScreen extends ConsumerStatefulWidget {
  const DictionaryScreen({super.key});

  @override
  ConsumerState<DictionaryScreen> createState() => _DictionaryScreenState();
}

class _DictionaryScreenState extends ConsumerState<DictionaryScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dictState = ref.watch(dictionaryProvider);

    return Scaffold(
      body: Column(
        children: [
          // Search Input
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 6),
            child: TextField(
              controller: _searchController,
              style: KashifTypography.arabic(fontSize: 13),
              decoration: InputDecoration(
                hintText: 'ابحث عن مصطلح (مثال: بوبينة، باطنيات، امبروكم)...',
                hintStyle: KashifTypography.arabic(fontSize: 12, color: Colors.grey),
                prefixIcon: const Icon(Icons.search_rounded),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          ref.read(dictionaryProvider.notifier).search('');
                        },
                      )
                    : null,
                filled: true,
                fillColor: isDark ? KashifColors.darkCell : KashifColors.lightCell,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(2),
                  borderSide: BorderSide(
                    color: isDark ? KashifColors.darkBorder : KashifColors.lightBorder,
                  ),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              ),
              onChanged: (val) {
                ref.read(dictionaryProvider.notifier).search(val);
              },
            ),
          ),

          // Categories Filter Row
          SizedBox(
            height: 42,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              itemCount: dictState.categories.length,
              separatorBuilder: (context, i) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final cat = dictState.categories[index];
                final isSelected = cat == dictState.selectedCategory;

                return ChoiceChip(
                  label: Text(
                    cat,
                    style: KashifTypography.arabic(
                      fontSize: 11,
                      fontWeight: isSelected ? FontWeight.w800 : FontWeight.normal,
                      color: isSelected
                          ? Colors.white
                          : (isDark ? KashifColors.darkTextPrimary : KashifColors.lightTextPrimary),
                    ),
                  ),
                  selected: isSelected,
                  selectedColor: isDark ? KashifColors.fuse15AInkDark : KashifColors.fuse15AInkLight,
                  backgroundColor: isDark ? KashifColors.darkCell : KashifColors.lightCell,
                  side: BorderSide(
                    color: isDark ? KashifColors.darkBorder : KashifColors.lightBorder,
                    width: 0.8,
                  ),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
                  onSelected: (_) {
                    ref.read(dictionaryProvider.notifier).selectCategory(cat);
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 6),

          // Terms List
          Expanded(
            child: dictState.entries.isEmpty
                ? Center(
                    child: Text(
                      'لا توجد مصطلحات مطابقة للبحث.',
                      style: KashifTypography.arabic(fontSize: 13),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    itemCount: dictState.entries.length,
                    itemBuilder: (context, index) {
                      final item = dictState.entries[index];
                      return _buildDictionaryCard(item, isDark);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildDictionaryCard(DictionaryEntry item, bool isDark) {
    return FuseCell(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(11),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  item.libyanTerm,
                  style: KashifTypography.arabic(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: isDark ? KashifColors.darkTextPrimary : KashifColors.lightTextPrimary,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isDark ? KashifColors.darkBoard : KashifColors.lightBoard,
                  borderRadius: BorderRadius.circular(2),
                ),
                child: Text(
                  item.category,
                  style: KashifTypography.arabic(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: isDark ? KashifColors.darkTextMuted : KashifColors.lightTextMuted,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'بالفصحى: ',
                style: KashifTypography.arabic(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: isDark ? KashifColors.darkTextMuted : KashifColors.lightTextMuted,
                ),
              ),
              Expanded(
                child: Text(
                  item.standardArabic,
                  style: KashifTypography.arabic(fontSize: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 3),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'English: ',
                style: KashifTypography.mono(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: isDark ? KashifColors.darkTextMuted : KashifColors.lightTextMuted,
                ),
              ),
              Expanded(
                child: Text(
                  item.english,
                  style: KashifTypography.mono(
                    fontSize: 11,
                    color: isDark ? KashifColors.fuse15AInkDark : KashifColors.fuse15AInkLight,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
