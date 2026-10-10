import 'package:flutter/material.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/typography.dart';
import '../../data/models/fuse_item.dart';
import '../../data/repositories/fuse_box_repository.dart';
import '../widgets/fuse_cell.dart';

class FuseBoxScreen extends StatefulWidget {
  final String? initialDtcFilter;
  final bool showAppBar;

  const FuseBoxScreen({
    super.key,
    this.initialDtcFilter,
    this.showAppBar = true,
  });

  @override
  State<FuseBoxScreen> createState() => _FuseBoxScreenState();
}

class _FuseBoxScreenState extends State<FuseBoxScreen> {
  final TextEditingController _searchController = TextEditingController();
  FuseLocation? _selectedLocation;
  String? _dtcFilter;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    if (widget.initialDtcFilter != null &&
        widget.initialDtcFilter!.isNotEmpty) {
      _dtcFilter = widget.initialDtcFilter;
      _searchController.text = widget.initialDtcFilter!;
      _searchQuery = widget.initialDtcFilter!;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final filteredFuses = FuseBoxRepository.searchFuses(
      query: _searchQuery,
      locationFilter: _selectedLocation,
      dtcCode: _dtcFilter,
    );

    return Scaffold(
      appBar: widget.showAppBar
          ? AppBar(
              title: Text(
                'دليل ومكتشف علبة الفيوزات',
                style: KashifTypography.arabic(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.info_outline_rounded, size: 20),
                  tooltip: 'إرشادات السلامة والفحص',
                  onPressed: () => _showSafetyGuide(context, isDark),
                ),
              ],
            )
          : null,
      body: Column(
        children: [
          // Search & Filters Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            color: isDark ? KashifColors.darkBoard : KashifColors.lightBoard,
            child: Column(
              children: [
                // Search Input
                TextField(
                  controller: _searchController,
                  onChanged: (val) {
                    setState(() {
                      _searchQuery = val;
                      _dtcFilter = null;
                    });
                  },
                  style: KashifTypography.arabic(
                    fontSize: 13,
                    color: isDark
                        ? KashifColors.darkTextPrimary
                        : KashifColors.lightTextPrimary,
                  ),
                  decoration: InputDecoration(
                    hintText:
                        'ابحث بالاسم، الدائرة، العطل (بومبة، OBD، P0135)...',
                    hintStyle: KashifTypography.arabic(
                      fontSize: 12,
                      color: isDark
                          ? KashifColors.darkTextMuted
                          : KashifColors.lightTextMuted,
                    ),
                    prefixIcon: const Icon(Icons.search_rounded, size: 20),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 18),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {
                                _searchQuery = '';
                                _dtcFilter = null;
                              });
                            },
                          )
                        : null,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    filled: true,
                    fillColor: isDark
                        ? KashifColors.darkCell
                        : KashifColors.lightCell,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        color: isDark
                            ? KashifColors.darkBorder
                            : KashifColors.lightBorder,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(
                        color: isDark
                            ? KashifColors.darkBorder
                            : KashifColors.lightBorder,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                // Location Filter Chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip(
                        label: 'الكل (${FuseBoxRepository.allFuses.length})',
                        isSelected:
                            _selectedLocation == null && _dtcFilter == null,
                        onTap: () => setState(() {
                          _selectedLocation = null;
                          _dtcFilter = null;
                        }),
                        isDark: isDark,
                      ),
                      const SizedBox(width: 6),
                      _buildFilterChip(
                        label: 'حوض المحرك',
                        icon: Icons.directions_car_rounded,
                        isSelected: _selectedLocation == FuseLocation.engineBay,
                        onTap: () => setState(() {
                          _selectedLocation = FuseLocation.engineBay;
                        }),
                        isDark: isDark,
                      ),
                      const SizedBox(width: 6),
                      _buildFilterChip(
                        label: 'كابينة القيادة',
                        icon: Icons.airline_seat_recline_normal_rounded,
                        isSelected: _selectedLocation == FuseLocation.interior,
                        onTap: () => setState(() {
                          _selectedLocation = FuseLocation.interior;
                        }),
                        isDark: isDark,
                      ),
                      if (_dtcFilter != null) ...[
                        const SizedBox(width: 6),
                        _buildFilterChip(
                          label: 'كود: $_dtcFilter',
                          icon: Icons.bolt_rounded,
                          isSelected: true,
                          accentColor: const Color(0xFFD4AF37),
                          onTap: () => setState(() {
                            _dtcFilter = null;
                          }),
                          isDark: isDark,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Standard Amperage Color Bar Legend
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            color: isDark ? const Color(0xFF0E1626) : const Color(0xFFE8EEF5),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  Text(
                    'دليل الألوان المعياري:',
                    style: KashifTypography.arabic(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                      color: isDark
                          ? KashifColors.darkTextMuted
                          : KashifColors.lightTextMuted,
                    ),
                  ),
                  const SizedBox(width: 8),
                  _buildColorLegendItem('5A', 0xFFFFB74D),
                  _buildColorLegendItem('10A', 0xFFE53935),
                  _buildColorLegendItem('15A (OBD)', 0xFF1E88E5),
                  _buildColorLegendItem('20A (وقود)', 0xFFFDD835),
                  _buildColorLegendItem('25A', 0xFFE0E0E0),
                  _buildColorLegendItem('30A (مروحة)', 0xFF43A047),
                ],
              ),
            ),
          ),

          // Fuse Items List
          Expanded(
            child: filteredFuses.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.electric_bolt_outlined,
                            size: 48,
                            color: isDark
                                ? KashifColors.darkTextMuted
                                : KashifColors.lightTextMuted,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'لم يتم العثور على فيوز مطابق للبحث',
                            style: KashifTypography.arabic(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: isDark
                                  ? KashifColors.darkTextPrimary
                                  : KashifColors.lightTextPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'جرب البحث باسم الدائرة أو كود العطل باللغة العربية أو الإنجليزية.',
                            textAlign: TextAlign.center,
                            style: KashifTypography.arabic(
                              fontSize: 11.5,
                              color: isDark
                                  ? KashifColors.darkTextMuted
                                  : KashifColors.lightTextMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    itemCount: filteredFuses.length,
                    itemBuilder: (context, index) {
                      final item = filteredFuses[index];
                      return _buildFuseCard(context, item, isDark);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    IconData? icon,
    required bool isSelected,
    required VoidCallback onTap,
    required bool isDark,
    Color? accentColor,
  }) {
    final activeColor =
        accentColor ??
        (isDark ? KashifColors.goldLight : KashifColors.royalBlue);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: isSelected
              ? activeColor.withValues(alpha: 0.18)
              : (isDark ? KashifColors.darkCell : KashifColors.lightCell),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? activeColor
                : (isDark ? KashifColors.darkBorder : KashifColors.lightBorder),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 14,
                color: isSelected
                    ? activeColor
                    : (isDark ? Colors.white70 : Colors.black54),
              ),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: KashifTypography.arabic(
                fontSize: 11.5,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                color: isSelected
                    ? activeColor
                    : (isDark
                          ? KashifColors.darkTextMuted
                          : KashifColors.lightTextMuted),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildColorLegendItem(String label, int colorHex) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Color(colorHex).withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Color(colorHex), width: 1),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 9.5,
          fontWeight: FontWeight.w800,
          color: Color(colorHex),
        ),
      ),
    );
  }

  Widget _buildFuseCard(BuildContext context, FuseItem item, bool isDark) {
    final fuseColor = Color(item.colorValue);

    return FuseCell(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Rating Badge + Arabic Name + English Circuit
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Fuse Amperage Badge (Blade shape look)
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: fuseColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: fuseColor, width: 1.5),
                ),
                alignment: Alignment.center,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${item.ratingAmps}A',
                      style: TextStyle(
                        fontFamily: 'Courier',
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        color: fuseColor,
                      ),
                    ),
                    Text(
                      'FUSE',
                      style: TextStyle(
                        fontSize: 8,
                        fontWeight: FontWeight.w800,
                        color: fuseColor.withValues(alpha: 0.8),
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.nameArabic,
                      style: KashifTypography.arabic(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: isDark
                            ? KashifColors.darkTextPrimary
                            : KashifColors.lightTextPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Text(
                          item.circuitEnglish,
                          style: TextStyle(
                            fontFamily: 'Courier',
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                            color: isDark
                                ? const Color(0xFFD4AF37)
                                : const Color(0xFF0F3B82),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 1,
                          ),
                          decoration: BoxDecoration(
                            color: isDark
                                ? Colors.white10
                                : Colors.black.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            item.location.labelArabic,
                            style: KashifTypography.arabic(
                              fontSize: 10,
                              color: isDark
                                  ? KashifColors.darkTextMuted
                                  : KashifColors.lightTextMuted,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Symptoms
          Text(
            'أعراض احتراق الفيوز:',
            style: KashifTypography.arabic(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: const Color(0xFFE5A93C),
            ),
          ),
          const SizedBox(height: 4),
          ...item.symptoms.map(
            (sym) => Padding(
              padding: const EdgeInsets.only(bottom: 2, right: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('• ', style: TextStyle(color: Color(0xFFE5A93C))),
                  Expanded(
                    child: Text(
                      sym,
                      style: KashifTypography.arabic(
                        fontSize: 11.5,
                        color: isDark
                            ? KashifColors.darkTextMuted
                            : KashifColors.lightTextMuted,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Associated DTC Codes (if any)
          if (item.associatedDTCs.isNotEmpty) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: item.associatedDTCs.map((code) {
                return InkWell(
                  onTap: () {
                    setState(() {
                      _dtcFilter = code;
                      _searchQuery = code;
                      _searchController.text = code;
                    });
                  },
                  borderRadius: BorderRadius.circular(4),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF1E2838)
                          : const Color(0xFFEEF3F8),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color:
                            (isDark
                                    ? KashifColors.goldLight
                                    : KashifColors.royalBlue)
                                .withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.bolt_rounded,
                          size: 12,
                          color: Color(0xFFD4AF37),
                        ),
                        const SizedBox(width: 2),
                        Text(
                          code,
                          style: const TextStyle(
                            fontFamily: 'Courier',
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFFD4AF37),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ],

          // Mechanic Testing Tip Box
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF142019) : const Color(0xFFF0F9F3),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: const Color(0xFF2E9E5B).withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.tips_and_updates_rounded,
                  size: 16,
                  color: Color(0xFF2E9E5B),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    item.testingTip,
                    style: KashifTypography.arabic(
                      fontSize: 11,
                      color: isDark
                          ? const Color(0xFFC8E6C9)
                          : const Color(0xFF1B5E20),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showSafetyGuide(BuildContext context, bool isDark) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: BoxDecoration(
          color: isDark ? KashifColors.darkBoard : KashifColors.lightBoard,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          border: Border.all(
            color: isDark ? KashifColors.darkBorder : KashifColors.lightBorder,
          ),
        ),
        padding: const EdgeInsets.all(18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.warning_amber_rounded,
                  color: Color(0xFFE53935),
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'قواعد سلامة فحص واستبدال الفيوزات',
                  style: KashifTypography.arabic(
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    color: isDark
                        ? KashifColors.darkTextPrimary
                        : KashifColors.lightTextPrimary,
                  ),
                ),
              ],
            ),
            const Divider(height: 18),
            _buildSafetyPoint(
              '1. لا تركب أبداً فيوز أعلى من المقاس الموصى به:',
              'تركيب فيوز 30A مكان 15A قد يمنع الفيوز من الاحتراق عند حدوث التماس، مما يؤدي إلى اشتعال الأسلاك أو احتراق كمبيوتر السيارة!',
              isDark,
            ),
            const SizedBox(height: 8),
            _buildSafetyPoint(
              '2. فحص الفيوز دون فكه:',
              'استخدم لمبة الفحص (Test Light) على النقطتين المعدنيتين أعلى الفيوز مع فتح السويتش (ON). يجب أن تضيء في كلتا النقطتين. إذا أضاءت في جهة واحدة فقط فالفيوز مقطوع.',
              isDark,
            ),
            const SizedBox(height: 8),
            _buildSafetyPoint(
              '3. انقطاع فيوز مدخل OBD-II:',
              'في معظم السيارات الحديثة، مخرج ولاعة السجائر 12V وفيشة الفحص OBD-II مشتركان في نفس الفيوز (CIG / AUX - 15A). تأكد منه إذا لم يشتغل جهاز الكشف.',
              isDark,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD4AF37),
                foregroundColor: const Color(0xFF070E1E),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'فهمت، إغلاق',
                style: KashifTypography.arabic(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSafetyPoint(String title, String desc, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: KashifTypography.arabic(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: const Color(0xFFD4AF37),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          desc,
          style: KashifTypography.arabic(
            fontSize: 11.5,
            color: isDark
                ? KashifColors.darkTextMuted
                : KashifColors.lightTextMuted,
          ),
        ),
      ],
    );
  }
}
