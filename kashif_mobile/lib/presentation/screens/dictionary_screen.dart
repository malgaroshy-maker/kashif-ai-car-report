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

  void _showAddTermDialog(BuildContext context, bool isDark) {
    final libyanController = TextEditingController();
    final standardController = TextEditingController();
    final englishController = TextEditingController();
    String selectedCategory = 'عام';

    final defaultCategories = [
      'عام',
      'المحرك',
      'الكهرباء والإلكترونيات',
      'الشاسيه والتعليق',
      'ناقل الحركة (الكمبيو)',
      'الفرامل (المكابح)',
      'التبريد والتكييف',
      'الهيكل والإيرباق',
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: EdgeInsets.only(
                left: 18,
                right: 18,
                top: 18,
                bottom: MediaQuery.of(context).viewInsets.bottom + 18,
              ),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF0F1E38) : Colors.white,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                border: Border(
                  top: BorderSide(
                    color: isDark ? KashifColors.goldPrimary : KashifColors.royalBlue,
                    width: 2,
                  ),
                ),
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Header
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: (isDark
                                    ? KashifColors.goldPrimary
                                    : KashifColors.royalBlue)
                                .withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.post_add_rounded,
                            color: isDark
                                ? KashifColors.goldLight
                                : KashifColors.royalBlue,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'إضافة مصطلح جديد للقاموس',
                                style: KashifTypography.arabic(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              Text(
                                'سيتم حفظ المصطلح محلياً والتعرف عليه فورياً بالتطبيق',
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
                        IconButton(
                          icon: const Icon(Icons.close, size: 20),
                          onPressed: () => Navigator.pop(ctx),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Libyan Term Field (Required)
                    Text(
                      'المصطلح بالعامية الفنية الليبية *',
                      style: KashifTypography.arabic(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    TextField(
                      controller: libyanController,
                      style: KashifTypography.arabic(fontSize: 13),
                      decoration: InputDecoration(
                        hintText: 'مثال: بوبينة، باطنيات، كاطالايزر...',
                        filled: true,
                        fillColor: isDark
                            ? KashifColors.darkBoard
                            : KashifColors.lightBoard,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Standard Arabic Field (Required)
                    Text(
                      'المعنى بالعربية الفصحى *',
                      style: KashifTypography.arabic(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    TextField(
                      controller: standardController,
                      style: KashifTypography.arabic(fontSize: 13),
                      decoration: InputDecoration(
                        hintText: 'مثال: ملف الإشعال، ممتص الصدمات...',
                        filled: true,
                        fillColor: isDark
                            ? KashifColors.darkBoard
                            : KashifColors.lightBoard,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // English Name Field (Optional)
                    Text(
                      'الاسم بالإنجليزية (اختياري)',
                      style: KashifTypography.arabic(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    TextField(
                      controller: englishController,
                      style: KashifTypography.mono(fontSize: 13),
                      decoration: InputDecoration(
                        hintText: 'e.g. Ignition Coil, Shock Absorber',
                        filled: true,
                        fillColor: isDark
                            ? KashifColors.darkBoard
                            : KashifColors.lightBoard,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Category Selection
                    Text(
                      'تصنيف المنظومة',
                      style: KashifTypography.arabic(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    DropdownButtonFormField<String>(
                      value: selectedCategory,
                      dropdownColor: isDark
                          ? const Color(0xFF0F1E38)
                          : Colors.white,
                      style: KashifTypography.arabic(
                        fontSize: 13,
                        color: isDark
                            ? KashifColors.darkTextPrimary
                            : KashifColors.lightTextPrimary,
                      ),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: isDark
                            ? KashifColors.darkBoard
                            : KashifColors.lightBoard,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      items: defaultCategories.map((c) {
                        return DropdownMenuItem(
                          value: c,
                          child: Text(c),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) {
                          setModalState(() {
                            selectedCategory = val;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 18),

                    // Save Button
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isDark
                            ? KashifColors.goldPrimary
                            : KashifColors.royalBlue,
                        foregroundColor: isDark
                            ? const Color(0xFF070E1E)
                            : Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () {
                        final libyan = libyanController.text.trim();
                        final standard = standardController.text.trim();
                        final english = englishController.text.trim();

                        if (libyan.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('يرجى كتابة المصطلح بالليبي أولاً.'),
                              backgroundColor: Colors.redAccent,
                            ),
                          );
                          return;
                        }
                        if (standard.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('يرجى كتابة المعنى بالعربية الفصحى.'),
                              backgroundColor: Colors.redAccent,
                            ),
                          );
                          return;
                        }

                        final newEntry = DictionaryEntry(
                          libyanTerm: libyan,
                          standardArabic: standard,
                          english: english.isNotEmpty ? english : libyan,
                          category: selectedCategory,
                          isCustom: true,
                        );

                        ref.read(dictionaryProvider.notifier).addEntry(newEntry);
                        Navigator.pop(ctx);

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Row(
                              children: [
                                const Icon(
                                  Icons.check_circle_rounded,
                                  color: Color(0xFF4ADE80),
                                  size: 18,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'تمت إضافة مصطلح "$libyan" إلى القاموس بنجاح',
                                  style: KashifTypography.arabic(fontSize: 12),
                                ),
                              ],
                            ),
                            backgroundColor: const Color(0xFF0F1E38),
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.save_rounded, size: 18),
                      label: Text(
                        'حفظ المصطلح بالقاموس',
                        style: KashifTypography.arabic(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _confirmDelete(BuildContext context, String libyanTerm) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          'حذف المصطلح المضاف',
          style: KashifTypography.arabic(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'هل تريد بالتأكيد حذف مصطلح "$libyanTerm" من القاموس المحلي؟',
          style: KashifTypography.arabic(fontSize: 12.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(dictionaryProvider.notifier).deleteEntry(libyanTerm);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'تم حذف مصطلح "$libyanTerm"',
                    style: KashifTypography.arabic(fontSize: 12),
                  ),
                ),
              );
            },
            child: const Text('حذف'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dictState = ref.watch(dictionaryProvider);

    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddTermDialog(context, isDark),
        backgroundColor: isDark ? KashifColors.goldPrimary : KashifColors.royalBlue,
        foregroundColor: isDark ? const Color(0xFF070E1E) : Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: Text(
          'إضافة مصطلح',
          style: KashifTypography.arabic(
            fontSize: 12.5,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: Column(
        children: [
          // Search & Add Row
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 6),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    style: KashifTypography.arabic(fontSize: 13),
                    decoration: InputDecoration(
                      hintText: 'ابحث عن مصطلح (مثال: بوبينة، باطنيات، امبروكم)...',
                      hintStyle: KashifTypography.arabic(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
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
                      fillColor: isDark
                          ? KashifColors.darkCell
                          : KashifColors.lightCell,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(
                          color: isDark
                              ? KashifColors.goldPrimary.withValues(alpha: 0.4)
                              : KashifColors.royalBlue.withValues(alpha: 0.3),
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                    ),
                    onChanged: (val) {
                      ref.read(dictionaryProvider.notifier).search(val);
                    },
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filledTonal(
                  tooltip: 'إضافة مصطلح يدوي',
                  onPressed: () => _showAddTermDialog(context, isDark),
                  icon: const Icon(Icons.add_rounded),
                  style: IconButton.styleFrom(
                    backgroundColor: (isDark
                            ? KashifColors.goldPrimary
                            : KashifColors.royalBlue)
                        .withValues(alpha: 0.15),
                    foregroundColor: isDark
                        ? KashifColors.goldLight
                        : KashifColors.royalBlue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(
                        color: isDark
                            ? KashifColors.goldPrimary.withValues(alpha: 0.4)
                            : KashifColors.royalBlue.withValues(alpha: 0.3),
                      ),
                    ),
                  ),
                ),
              ],
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
                      fontWeight: isSelected
                          ? FontWeight.w800
                          : FontWeight.normal,
                      color: isSelected
                          ? (isDark ? const Color(0xFF070E1E) : Colors.white)
                          : (isDark
                                ? KashifColors.darkTextPrimary
                                : KashifColors.lightTextPrimary),
                    ),
                  ),
                  selected: isSelected,
                  selectedColor: isDark
                      ? KashifColors.goldPrimary
                      : KashifColors.royalBlue,
                  backgroundColor: isDark
                      ? const Color(0xFF0F1E3D)
                      : const Color(0xFFEBF2FD),
                  side: BorderSide(
                    color: isSelected
                        ? (isDark
                              ? KashifColors.goldLight
                              : KashifColors.royalBlue)
                        : (isDark
                              ? KashifColors.darkBorder
                              : KashifColors.lightBorder),
                    width: 0.8,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
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
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.search_off_rounded,
                          size: 48,
                          color: Colors.grey.withValues(alpha: 0.5),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'لا توجد مصطلحات مطابقة للبحث.',
                          style: KashifTypography.arabic(fontSize: 13),
                        ),
                        const SizedBox(height: 10),
                        OutlinedButton.icon(
                          onPressed: () => _showAddTermDialog(context, isDark),
                          icon: const Icon(Icons.add, size: 16),
                          label: Text(
                            'إضافة هذا المصطلح للقاموس',
                            style: KashifTypography.arabic(fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(14, 8, 14, 80),
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
                child: Row(
                  children: [
                    Flexible(
                      child: Text(
                        item.libyanTerm,
                        style: KashifTypography.arabic(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: isDark
                              ? KashifColors.darkTextPrimary
                              : KashifColors.lightTextPrimary,
                        ),
                      ),
                    ),
                    if (item.isCustom) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 5,
                          vertical: 1.5,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2E9E5B).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(3),
                          border: Border.all(
                            color: const Color(0xFF2E9E5B).withValues(alpha: 0.4),
                            width: 0.7,
                          ),
                        ),
                        child: Text(
                          'مضاف يدوياً',
                          style: KashifTypography.arabic(
                            fontSize: 8.5,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF2E9E5B),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isDark
                      ? KashifColors.darkBoard
                      : KashifColors.lightBoard,
                  borderRadius: BorderRadius.circular(2),
                ),
                child: Text(
                  item.category,
                  style: KashifTypography.arabic(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? KashifColors.darkTextMuted
                        : KashifColors.lightTextMuted,
                  ),
                ),
              ),
              if (item.isCustom)
                IconButton(
                  icon: const Icon(
                    Icons.delete_outline_rounded,
                    size: 18,
                    color: Colors.redAccent,
                  ),
                  tooltip: 'حذف المصطلح',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: () => _confirmDelete(context, item.libyanTerm),
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
                  color: isDark
                      ? KashifColors.darkTextMuted
                      : KashifColors.lightTextMuted,
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
          if (item.english.isNotEmpty) ...[
            const SizedBox(height: 3),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'English: ',
                  style: KashifTypography.mono(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: isDark
                        ? KashifColors.darkTextMuted
                        : KashifColors.lightTextMuted,
                  ),
                ),
                Expanded(
                  child: Text(
                    item.english,
                    style: KashifTypography.mono(
                      fontSize: 11,
                      color: isDark
                          ? KashifColors.fuse15AInkDark
                          : KashifColors.fuse15AInkLight,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
