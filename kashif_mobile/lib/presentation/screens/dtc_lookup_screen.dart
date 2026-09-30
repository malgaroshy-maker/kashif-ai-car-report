import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/typography.dart';
import '../../data/models/fault_code.dart';
import '../../data/repositories/offline_report_service.dart';
import '../providers/report_provider.dart';
import 'fuse_box_screen.dart';

class DtcLookupScreen extends ConsumerStatefulWidget {
  final VoidCallback? onReportGenerated;

  const DtcLookupScreen({super.key, this.onReportGenerated});

  @override
  ConsumerState<DtcLookupScreen> createState() => _DtcLookupScreenState();
}

class _DtcLookupScreenState extends ConsumerState<DtcLookupScreen> {
  final TextEditingController _searchController = TextEditingController();
  final Set<String> _selectedBasketCodes = {};
  String _searchQuery = '';
  String _selectedCategory = 'الكل';
  String? _expandedCode;

  final List<String> _categories = [
    'الكل',
    'المحرك (P)',
    'الشاسيه والفرامل (C)',
    'الهيكل والوسائد (B)',
    'الشبكة والاتصال (U)',
  ];

  final List<String> _topQuickCodes = [
    'P0300',
    'P0420',
    'P0171',
    'P0100',
    'P0700',
    'C0035',
    'B0001',
    'U0100',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _toggleBasket(String code) {
    setState(() {
      if (_selectedBasketCodes.contains(code)) {
        _selectedBasketCodes.remove(code);
      } else {
        _selectedBasketCodes.add(code);
      }
    });
  }

  void _generateReport(List<String> codes) {
    if (codes.isEmpty) return;
    final joined = codes.join(', ');
    ref.read(reportProvider.notifier).scanManual(joined, null);
    if (widget.onReportGenerated != null) {
      widget.onReportGenerated!();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'تم تجهيز تقرير الفحص للأكواد: $joined',
            style: KashifTypography.arabic(fontSize: 12),
          ),
          backgroundColor: const Color(0xFF2E9E5B),
        ),
      );
    }
  }

  List<OfflineDtcKnowledge> _getFilteredList(List<OfflineDtcKnowledge> allItems) {
    return allItems.where((item) {
      // Category filter
      if (_selectedCategory == 'المحرك (P)' && !item.code.startsWith('P')) {
        return false;
      }
      if (_selectedCategory == 'الشاسيه والفرامل (C)' && !item.code.startsWith('C')) {
        return false;
      }
      if (_selectedCategory == 'الهيكل والوسائد (B)' && !item.code.startsWith('B')) {
        return false;
      }
      if (_selectedCategory == 'الشبكة والاتصال (U)' && !item.code.startsWith('U')) {
        return false;
      }

      // Search query
      if (_searchQuery.trim().isEmpty) return true;
      final q = _searchQuery.trim().toLowerCase();
      return item.code.toLowerCase().contains(q) ||
          item.libyanTerm.toLowerCase().contains(q) ||
          item.standardArabicDescription.toLowerCase().contains(q) ||
          item.standardDescriptionEn.toLowerCase().contains(q) ||
          item.module.toLowerCase().contains(q) ||
          item.driverSymptoms.any((s) => s.toLowerCase().contains(q)) ||
          item.rootCauses.any((r) => r.toLowerCase().contains(q));
    }).toList();
  }

  Color _getSeverityColor(CodeSeverity severity) {
    switch (severity) {
      case CodeSeverity.critical:
        return const Color(0xFFDE3B2F); // Red 10A
      case CodeSeverity.moderate:
        return const Color(0xFFF2C200); // Yellow 20A
      case CodeSeverity.passed:
        return const Color(0xFF2E9E5B); // Green 30A
      case CodeSeverity.history:
        return const Color(0xFF9CA3AF); // Grey 25A
    }
  }

  String _getSeverityBadge(CodeSeverity severity) {
    switch (severity) {
      case CodeSeverity.critical:
        return 'عطل حرج 10A';
      case CodeSeverity.moderate:
        return 'عطل متوسط 20A';
      case CodeSeverity.passed:
        return 'سليم 30A';
      case CodeSeverity.history:
        return 'عطل مسجل 25A';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final allKnowledge = OfflineReportService.getAllKnowledge();
    final filtered = _getFilteredList(allKnowledge);

    // If query is a custom OBD-II code not in DB
    final cleanQuery = _searchQuery.trim().toUpperCase();
    final isExactMatchInDb = allKnowledge.any((k) => k.code == cleanQuery);
    final isObdCodePattern = RegExp(r'^[PCBU][0-9A-F]{4}$').hasMatch(cleanQuery);
    final showCustomCodePrompt = isObdCodePattern && !isExactMatchInDb;

    return Scaffold(
      backgroundColor: isDark ? KashifColors.darkBoard : KashifColors.lightBoard,
      body: Column(
        children: [
          // Top Search & Quick Selection Header
          Container(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
            decoration: BoxDecoration(
              color: isDark ? KashifColors.darkCell : KashifColors.lightCell,
              border: Border(
                bottom: BorderSide(
                  color: isDark ? KashifColors.darkBorder : KashifColors.lightBorder,
                  width: 1,
                ),
              ),
            ),
            child: Column(
              children: [
                // Search Input Field
                TextField(
                  controller: _searchController,
                  style: KashifTypography.arabic(fontSize: 13),
                  decoration: InputDecoration(
                    hintText: 'ابحث برقم الكود أو العطل (مثال: P0300، بوبينة، حساس ماف)...',
                    hintStyle: KashifTypography.arabic(
                      fontSize: 11.5,
                      color: Colors.grey,
                    ),
                    prefixIcon: const Icon(Icons.manage_search_rounded, size: 22),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 18),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {
                                _searchQuery = '';
                              });
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: isDark ? KashifColors.darkCell : KashifColors.lightCell,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(
                        color: isDark
                            ? KashifColors.goldPrimary.withValues(alpha: 0.3)
                            : KashifColors.royalBlue.withValues(alpha: 0.25),
                      ),
                    ),
                  ),
                  onChanged: (val) {
                    setState(() {
                      _searchQuery = val;
                    });
                  },
                ),
                const SizedBox(height: 8),

                // Category Filter Chips
                SizedBox(
                  height: 36,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _categories.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 6),
                    itemBuilder: (context, idx) {
                      final cat = _categories[idx];
                      final isSelected = cat == _selectedCategory;
                      return ChoiceChip(
                        label: Text(
                          cat,
                          style: KashifTypography.arabic(
                            fontSize: 11,
                            fontWeight: isSelected ? FontWeight.w800 : FontWeight.normal,
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
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        visualDensity: VisualDensity.compact,
                        onSelected: (val) {
                          if (val) {
                            setState(() {
                              _selectedCategory = cat;
                            });
                          }
                        },
                      );
                    },
                  ),
                ),
                const SizedBox(height: 8),

                // Quick Popular Codes Row
                Row(
                  children: [
                    Text(
                      'الأكثر شيوعاً:',
                      style: KashifTypography.arabic(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: isDark ? KashifColors.goldLight : KashifColors.royalBlue,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: _topQuickCodes.map((code) {
                            final isPicked = _searchQuery.toUpperCase() == code;
                            return Padding(
                              padding: const EdgeInsets.only(left: 5),
                              child: InkWell(
                                onTap: () {
                                  _searchController.text = code;
                                  setState(() {
                                    _searchQuery = code;
                                  });
                                },
                                borderRadius: BorderRadius.circular(4),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 7,
                                    vertical: 2.5,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isPicked
                                        ? (isDark
                                            ? KashifColors.goldPrimary
                                            : KashifColors.royalBlue)
                                        : (isDark
                                            ? KashifColors.darkCell
                                            : KashifColors.lightCell),
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(
                                      color: isDark
                                          ? KashifColors.darkBorder
                                          : KashifColors.lightBorder,
                                      width: 0.7,
                                    ),
                                  ),
                                  child: Text(
                                    code,
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: isPicked
                                          ? (isDark
                                              ? const Color(0xFF070E1E)
                                              : Colors.white)
                                          : (isDark
                                              ? KashifColors.darkTextPrimary
                                              : KashifColors.lightTextPrimary),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Multi-DTC Selection Basket Bar (If any selected)
          if (_selectedBasketCodes.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF132242)
                    : const Color(0xFFE8F1FC),
                border: Border(
                  bottom: BorderSide(
                    color: isDark
                        ? KashifColors.goldPrimary.withValues(alpha: 0.4)
                        : KashifColors.royalBlue.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.checklist_rtl_rounded,
                              size: 16,
                              color: Color(0xFF2E9E5B),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'سلة الأكواد المحددة (${_selectedBasketCodes.length}):',
                              style: KashifTypography.arabic(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const Spacer(),
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedBasketCodes.clear();
                                });
                              },
                              child: Text(
                                'تفريغ',
                                style: KashifTypography.arabic(
                                  fontSize: 10.5,
                                  color: Colors.redAccent,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Wrap(
                          spacing: 4,
                          runSpacing: 4,
                          children: _selectedBasketCodes.map((c) {
                            return Chip(
                              label: Text(
                                c,
                                style: const TextStyle(
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              deleteIcon: const Icon(Icons.close, size: 13),
                              onDeleted: () => _toggleBasket(c),
                              visualDensity: VisualDensity.compact,
                              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              padding: EdgeInsets.zero,
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2E9E5B),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 10,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () => _generateReport(_selectedBasketCodes.toList()),
                    icon: const Icon(Icons.picture_as_pdf_rounded, size: 16),
                    label: Text(
                      'تقرير شامل',
                      style: KashifTypography.arabic(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // Main List of Codes
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 20),
              children: [
                // Custom code banner if typed manually and not in local base
                if (showCustomCodePrompt)
                  Card(
                    elevation: 0,
                    color: isDark
                        ? const Color(0xFF1E2838)
                        : const Color(0xFFF0F4FF),
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: BorderSide(
                        color: isDark
                            ? KashifColors.goldPrimary.withValues(alpha: 0.5)
                            : KashifColors.royalBlue.withValues(alpha: 0.4),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? KashifColors.goldPrimary
                                      : KashifColors.royalBlue,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  cleanQuery,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w900,
                                    fontSize: 13,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'كود قياسي OBD-II غير محفوظ محلياً',
                                  style: KashifTypography.arabic(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'يمكنك إنشاء تقرير فحص فوري لهذا الكود وسيقوم التطبيق بتحليله وتوليد شرحه وخطوات فحصه وقطع غياره فورياً.',
                            style: KashifTypography.arabic(
                              fontSize: 11,
                              color: isDark
                                  ? KashifColors.darkTextMuted
                                  : KashifColors.lightTextMuted,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(vertical: 8),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                  ),
                                  onPressed: () => _toggleBasket(cleanQuery),
                                  icon: Icon(
                                    _selectedBasketCodes.contains(cleanQuery)
                                        ? Icons.check
                                        : Icons.add,
                                    size: 16,
                                  ),
                                  label: Text(
                                    _selectedBasketCodes.contains(cleanQuery)
                                        ? 'مضاف للسلة'
                                        : 'إضافة للسلة',
                                    style: KashifTypography.arabic(fontSize: 11),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF2E9E5B),
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(vertical: 8),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                  ),
                                  onPressed: () => _generateReport([cleanQuery]),
                                  icon: const Icon(Icons.assignment_turned_in, size: 16),
                                  label: Text(
                                    'إنشاء تقرير فحص',
                                    style: KashifTypography.arabic(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                // Empty state if nothing matches
                if (filtered.isEmpty && !showCustomCodePrompt)
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 40),
                      child: Column(
                        children: [
                          Icon(
                            Icons.search_off_rounded,
                            size: 54,
                            color: Colors.grey.withValues(alpha: 0.5),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'لم يتم العثور على عطل مطابق لـ "$_searchQuery"',
                            style: KashifTypography.arabic(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'يمكنك كتابة كود العطل مباشرة (مثال: P0301 أو C0040) للتشخيص الفوري.',
                            style: KashifTypography.arabic(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                // Filtered List Cards
                ...filtered.map((item) {
                  final isExpanded = _expandedCode == item.code;
                  final isBasketPicked = _selectedBasketCodes.contains(item.code);
                  final sevColor = _getSeverityColor(item.severity);

                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    decoration: BoxDecoration(
                      color: isDark ? KashifColors.darkCell : KashifColors.lightCell,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isExpanded
                            ? (isDark
                                ? KashifColors.goldPrimary
                                : KashifColors.royalBlue)
                            : (isDark
                                ? KashifColors.darkBorder
                                : KashifColors.lightBorder),
                        width: isExpanded ? 1.2 : 0.8,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Card Header
                        InkWell(
                          borderRadius: BorderRadius.circular(10),
                          onTap: () {
                            setState(() {
                              _expandedCode = isExpanded ? null : item.code;
                            });
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                // Code Badge
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isDark
                                        ? const Color(0xFF0F1E3D)
                                        : const Color(0xFFE8EEF8),
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(
                                      color: isDark
                                          ? KashifColors.goldLight.withValues(alpha: 0.5)
                                          : KashifColors.royalBlue.withValues(alpha: 0.4),
                                    ),
                                  ),
                                  child: Text(
                                    item.code,
                                    style: TextStyle(
                                      fontFamily: 'monospace',
                                      fontSize: 13,
                                      fontWeight: FontWeight.w900,
                                      color: isDark
                                          ? KashifColors.goldLight
                                          : KashifColors.royalBlue,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),

                                // Title and Module
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.libyanTerm,
                                        style: KashifTypography.arabic(
                                          fontSize: 12.5,
                                          fontWeight: FontWeight.w700,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 2),
                                      Row(
                                        children: [
                                          Text(
                                            '${item.module} — ${item.moduleNameArabic}',
                                            style: KashifTypography.arabic(
                                              fontSize: 10,
                                              color: isDark
                                                  ? KashifColors.darkTextMuted
                                                  : KashifColors.lightTextMuted,
                                            ),
                                          ),
                                          const SizedBox(width: 6),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 5,
                                              vertical: 1,
                                            ),
                                            decoration: BoxDecoration(
                                              color: sevColor.withValues(alpha: 0.15),
                                              borderRadius: BorderRadius.circular(3),
                                            ),
                                            child: Text(
                                              _getSeverityBadge(item.severity),
                                              style: TextStyle(
                                                fontSize: 8.5,
                                                fontWeight: FontWeight.w800,
                                                color: sevColor,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),

                                // Expand Icon
                                Icon(
                                  isExpanded
                                      ? Icons.keyboard_arrow_up_rounded
                                      : Icons.keyboard_arrow_down_rounded,
                                  color: Colors.grey,
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Expanded Details Section
                        if (isExpanded) ...[
                          const Divider(height: 1),
                          Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // English Name
                                Text(
                                  item.standardDescriptionEn,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  item.standardArabicDescription,
                                  style: KashifTypography.arabic(
                                    fontSize: 11.5,
                                    color: isDark
                                        ? KashifColors.darkTextMuted
                                        : KashifColors.lightTextMuted,
                                  ),
                                ),
                                const SizedBox(height: 10),

                                // Driver Symptoms
                                if (item.driverSymptoms.isNotEmpty) ...[
                                  Text(
                                    'أعراض القيادة (ما يحس به السائق):',
                                    style: KashifTypography.arabic(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: isDark
                                          ? KashifColors.goldLight
                                          : KashifColors.royalBlue,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  ...item.driverSymptoms.map(
                                    (s) => Padding(
                                      padding: const EdgeInsets.only(bottom: 2),
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Text('• ', style: TextStyle(fontSize: 11)),
                                          Expanded(
                                            child: Text(
                                              s,
                                              style: KashifTypography.arabic(fontSize: 11),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                ],

                                // Root causes
                                if (item.rootCauses.isNotEmpty) ...[
                                  Text(
                                    'الأسباب المحتملة بالعطل:',
                                    style: KashifTypography.arabic(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.orange.shade700,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  ...item.rootCauses.map(
                                    (r) => Padding(
                                      padding: const EdgeInsets.only(bottom: 2),
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Text('• ', style: TextStyle(fontSize: 11)),
                                          Expanded(
                                            child: Text(
                                              r,
                                              style: KashifTypography.arabic(fontSize: 11),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                ],

                                // Workshop Recommended Action
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: isDark
                                        ? const Color(0xFF0F1E3D)
                                        : const Color(0xFFF2F6FC),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'إجراءات الفحص والحل في الورشة:',
                                        style: KashifTypography.arabic(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                          color: isDark
                                              ? KashifColors.goldLight
                                              : KashifColors.royalBlue,
                                        ),
                                      ),
                                      const SizedBox(height: 3),
                                      Text(
                                        item.recommendedAction,
                                        style: KashifTypography.arabic(fontSize: 11),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 8),

                                // Spare Part Info if present
                                if (item.partNameLibyan != null)
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF2E9E5B).withValues(alpha: 0.08),
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(
                                        color: const Color(0xFF2E9E5B).withValues(alpha: 0.3),
                                        width: 0.8,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        const Icon(
                                          Icons.build_circle_outlined,
                                          size: 16,
                                          color: Color(0xFF2E9E5B),
                                        ),
                                        const SizedBox(width: 6),
                                        Expanded(
                                          child: Text(
                                            'القطعة المطلوبة: ${item.partNameLibyan} ' +
                                                (item.partPriceMin != null
                                                    ? '(${item.partPriceMin?.toInt()} - ${item.partPriceMax?.toInt()} د.ل تقريباً)'
                                                    : ''),
                                            style: KashifTypography.arabic(
                                              fontSize: 10.5,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                const SizedBox(height: 12),

                                // Bottom Action Buttons for this code
                                Row(
                                  children: [
                                    // Fuse button if available
                                    IconButton(
                                      tooltip: 'مخطط فيوز العطل',
                                      icon: const Icon(
                                        Icons.electric_bolt_rounded,
                                        color: Color(0xFFF2C200),
                                        size: 20,
                                      ),
                                      onPressed: () {
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (_) => FuseBoxScreen(
                                              initialDtcFilter: item.code,
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                    // Toggle Basket Button
                                    Expanded(
                                      child: OutlinedButton.icon(
                                        style: OutlinedButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(vertical: 8),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          side: BorderSide(
                                            color: isBasketPicked
                                                ? const Color(0xFF2E9E5B)
                                                : (isDark
                                                    ? KashifColors.darkBorder
                                                    : KashifColors.lightBorder),
                                          ),
                                        ),
                                        onPressed: () => _toggleBasket(item.code),
                                        icon: Icon(
                                          isBasketPicked
                                              ? Icons.check_circle_rounded
                                              : Icons.add_circle_outline_rounded,
                                          size: 16,
                                          color: isBasketPicked
                                              ? const Color(0xFF2E9E5B)
                                              : null,
                                        ),
                                        label: Text(
                                          isBasketPicked
                                              ? 'مضاف للسلة'
                                              : 'إضافة للسلة',
                                          style: KashifTypography.arabic(
                                            fontSize: 11,
                                            fontWeight: isBasketPicked
                                                ? FontWeight.w700
                                                : FontWeight.normal,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    // Direct Report Button
                                    Expanded(
                                      flex: 1,
                                      child: ElevatedButton.icon(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: isDark
                                              ? KashifColors.goldPrimary
                                              : KashifColors.royalBlue,
                                          foregroundColor: isDark
                                              ? const Color(0xFF070E1E)
                                              : Colors.white,
                                          padding: const EdgeInsets.symmetric(vertical: 8),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                        ),
                                        onPressed: () => _generateReport([item.code]),
                                        icon: const Icon(
                                          Icons.assignment_turned_in,
                                          size: 16,
                                        ),
                                        label: Text(
                                          'تقرير فحص',
                                          style: KashifTypography.arabic(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
