import 'package:flutter/material.dart';
import '../../core/theme/typography.dart';
import '../../data/models/car_fuse_box.dart';

/// Authentic Real-Life Printed Fuse Card Replica Widget
///
/// Reproduces the exact physical paper card tucked into car fuse compartments
/// (such as BMW E39 Glovebox Card Part # 8 377 849 / E 6957.J).
///
/// Features:
/// - Exact 3-column / responsive Equipment-to-Fuse index table translated to Arabic + English.
/// - Exact physical Fuse Number & Amperes grid table (Row 1: 1-20 + 75,76; Row 2: 21-45).
/// - Downward pull tab handle with arrow.
/// - Authentic OEM part number stamp.
/// - Bi-directional interactive highlighting:
///     * Tap any equipment item -> Highlights its fuses in the grid with real automotive colors.
///     * Tap any fuse cell in the grid -> Highlights all equipment depending on it in the list.
/// - Live search in Arabic & English.
class AuthenticFuseCardWidget extends StatefulWidget {
  final VehicleFuseBox fuseBox;
  final FuseSlot? selectedSlot;
  final ValueChanged<FuseSlot> onSlotTapped;
  final String searchQuery;

  const AuthenticFuseCardWidget({
    super.key,
    required this.fuseBox,
    this.selectedSlot,
    required this.onSlotTapped,
    this.searchQuery = '',
  });

  @override
  State<AuthenticFuseCardWidget> createState() =>
      _AuthenticFuseCardWidgetState();
}

class _AuthenticFuseCardWidgetState extends State<AuthenticFuseCardWidget> {
  int? _highlightedFuseNumber;
  EquipmentFuseMapping? _selectedEquipment;
  String _languageMode = 'bilingual'; // 'bilingual', 'arabic', 'english'

  @override
  void didUpdateWidget(covariant AuthenticFuseCardWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedSlot != null) {
      final slotNum = int.tryParse(
          widget.selectedSlot!.slotId.replaceAll(RegExp(r'[^0-9]'), ''));
      if (slotNum != null && slotNum != _highlightedFuseNumber) {
        setState(() {
          _highlightedFuseNumber = slotNum;
        });
      }
    }
  }

  void _onEquipmentSelected(EquipmentFuseMapping equip) {
    setState(() {
      if (_selectedEquipment == equip) {
        _selectedEquipment = null;
        _highlightedFuseNumber = null;
      } else {
        _selectedEquipment = equip;
        _highlightedFuseNumber =
            equip.fuseNumbers.isNotEmpty ? equip.fuseNumbers.first : null;
      }
    });

    if (equip.fuseNumbers.isNotEmpty) {
      final targetSlotId = 'F${equip.fuseNumbers.first}';
      final match = widget.fuseBox.slots.firstWhere(
        (s) =>
            s.slotId == targetSlotId ||
            s.slotId == '${equip.fuseNumbers.first}',
        orElse: () => FuseSlot(
          slotId: targetSlotId,
          label: equip.equipmentEnglish,
          nameArabic: equip.equipmentArabic,
          ratingAmps: _getFuseAmps(equip.fuseNumbers.first),
          descriptionArabic:
              'يغذي دائرة ${equip.equipmentArabic} (${equip.equipmentEnglish})',
        ),
      );
      widget.onSlotTapped(match);
    }
  }

  void _onFuseNumberTapped(int fuseNum) {
    setState(() {
      _highlightedFuseNumber = fuseNum;
      // Find matching equipment that contains this fuse
      final matches = widget.fuseBox.equipmentMappings
          .where((e) => e.fuseNumbers.contains(fuseNum))
          .toList();
      _selectedEquipment = matches.isNotEmpty ? matches.first : null;
    });

    final targetSlotId = 'F$fuseNum';
    final match = widget.fuseBox.slots.firstWhere(
      (s) => s.slotId == targetSlotId || s.slotId == '$fuseNum',
      orElse: () => FuseSlot(
        slotId: targetSlotId,
        label: 'FUSE $fuseNum',
        nameArabic: 'فيوز رقم $fuseNum',
        ratingAmps: _getFuseAmps(fuseNum),
        descriptionArabic: 'فيوز الدائرة الكهربائية رقم $fuseNum',
      ),
    );
    widget.onSlotTapped(match);
  }

  int _getFuseAmps(int fuseNum) {
    final slotMatch = widget.fuseBox.slots.where((s) {
      final num = int.tryParse(s.slotId.replaceAll(RegExp(r'[^0-9]'), ''));
      return num == fuseNum;
    });
    if (slotMatch.isNotEmpty) {
      return slotMatch.first.ratingAmps;
    }
    return 15;
  }

  Color _getFuseColor(int amps) {
    switch (amps) {
      case 5:
        return const Color(0xFFFF9800); // 5A Orange
      case 7:
      case 8:
        return const Color(0xFF8D6E63); // 7.5A Brown
      case 10:
        return const Color(0xFFE53935); // 10A Red
      case 15:
        return const Color(0xFF1E88E5); // 15A Blue
      case 20:
        return const Color(0xFFFDD835); // 20A Yellow
      case 25:
        return const Color(0xFFE0E0E0); // 25A Clear / White
      case 30:
        return const Color(0xFF43A047); // 30A Green
      case 40:
        return const Color(0xFFFB8C00); // 40A Orange Maxi
      case 50:
        return const Color(0xFFD32F2F); // 50A Red Maxi
      default:
        return const Color(0xFF94A3B8);
    }
  }

  List<EquipmentFuseMapping> _getFilteredMappings() {
    final q = widget.searchQuery.trim().toLowerCase();
    final all = widget.fuseBox.equipmentMappings;
    if (q.isEmpty) return all;

    final searchNum = int.tryParse(q.replaceAll(RegExp(r'[^0-9]'), ''));

    return all.where((m) {
      final matchesEn = m.equipmentEnglish.toLowerCase().contains(q);
      final matchesAr = m.equipmentArabic.toLowerCase().contains(q);
      final matchesNum = searchNum != null && m.fuseNumbers.contains(searchNum);
      return matchesEn || matchesAr || matchesNum;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final filteredMappings = _getFilteredMappings();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Mode & Language Switcher Bar
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF131D2D) : const Color(0xFFF1F5F9),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            border: Border.all(
              color: isDark ? const Color(0xFF26354A) : const Color(0xFFCBD5E1),
            ),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.picture_as_pdf_rounded,
                size: 16,
                color: Color(0xFF0284C7),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'خريطة بطاقة المصنع الرسمية (OEM Fuse Chart):',
                  style: KashifTypography.arabic(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                  ),
                ),
              ),
              // Language Switch Pills
              _buildLanguagePill('عربي + إنجليزي', 'bilingual'),
              const SizedBox(width: 4),
              _buildLanguagePill('عربي فقط', 'arabic'),
              const SizedBox(width: 4),
              _buildLanguagePill('Original', 'english'),
            ],
          ),
        ),

        // The Authentic Card Canvas
        Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF0C131F) : const Color(0xFFFBFBFA),
            border: Border.all(
              color: isDark ? const Color(0xFF2B3A4F) : const Color(0xFF1E293B),
              width: 2.0,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: isDark ? 0.6 : 0.15),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Card Top Title & Header
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF162032)
                      : const Color(0xFFFFFFFF),
                  border: Border(
                    bottom: BorderSide(
                      color: isDark
                          ? const Color(0xFF334155)
                          : const Color(0xFF0F172A),
                      width: 1.5,
                    ),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.fuseBox.nameArabic,
                            style: KashifTypography.arabic(
                              fontSize: 13,
                              fontWeight: FontWeight.w900,
                              color:
                                  isDark ? Colors.white : const Color(0xFF0F172A),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            widget.fuseBox.detailedLocationArabic,
                            style: KashifTypography.arabic(
                              fontSize: 10,
                              color: isDark
                                  ? const Color(0xFF94A3B8)
                                  : const Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (widget.fuseBox.cardPartNumber != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF1E293B)
                              : const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: isDark
                                ? const Color(0xFF475569)
                                : const Color(0xFF94A3B8),
                          ),
                        ),
                        child: Text(
                          widget.fuseBox.cardPartNumber!,
                          style: const TextStyle(
                            fontFamily: 'Courier',
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              // Equipment to Fuse Mapping Table (The authentic printed index)
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Table Column Headers
                    _buildTableHeaders(isDark),
                    const SizedBox(height: 6),

                    // Filtered Equipment List / Grid
                    if (filteredMappings.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 24),
                        child: Center(
                          child: Text(
                            'لا توجد نتائج مطابقة لبحثك في جدول الفيوزات.',
                            style: KashifTypography.arabic(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                      )
                    else
                      _buildEquipmentGrid(filteredMappings, isDark),
                  ],
                ),
              ),

              const SizedBox(height: 8),

              // Physical Fuse Number & Amperes Grid Table (أسفل الكارت تماماً مثل الصورة)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: _buildPhysicalFuseGrids(isDark),
              ),

              const SizedBox(height: 12),

              // Bottom Metadata & Authentic Pull Tab
              _buildCardBottom(isDark),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLanguagePill(String label, String code) {
    final isSelected = _languageMode == code;
    return InkWell(
      onTap: () {
        setState(() {
          _languageMode = code;
        });
      },
      borderRadius: BorderRadius.circular(4),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF0284C7)
              : Colors.black.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 9.5,
            fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
            color: isSelected ? Colors.white : const Color(0xFF64748B),
          ),
        ),
      ),
    );
  }

  Widget _buildTableHeaders(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 5,
            child: Text(
              _languageMode == 'english'
                  ? 'Equipment / System'
                  : (_languageMode == 'arabic'
                      ? 'الجهاز / المنظومة الكهربائية'
                      : 'Equipment / الجهاز والمنظومة'),
              style: KashifTypography.arabic(
                fontSize: 11,
                fontWeight: FontWeight.w900,
                color: isDark ? Colors.white : const Color(0xFF0F172A),
              ),
            ),
          ),
          Container(
            width: 70,
            alignment: Alignment.center,
            child: Text(
              _languageMode == 'english' ? 'Fuse Nr.' : 'رقم الفيوز',
              style: KashifTypography.arabic(
                fontSize: 11,
                fontWeight: FontWeight.w900,
                color: isDark ? Colors.white : const Color(0xFF0F172A),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEquipmentGrid(
      List<EquipmentFuseMapping> mappings, bool isDark) {
    return LayoutBuilder(builder: (context, constraints) {
      // Split into 2 or 3 columns on wide screens, 1 column on narrow phones
      final isWide = constraints.maxWidth >= 600;

      if (isWide) {
        final half = (mappings.length / 2).ceil();
        final col1 = mappings.sublist(0, half);
        final col2 = mappings.sublist(half);

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _buildEquipmentColumn(col1, isDark)),
            const SizedBox(width: 8),
            Expanded(child: _buildEquipmentColumn(col2, isDark)),
          ],
        );
      }

      return _buildEquipmentColumn(mappings, isDark);
    });
  }

  Widget _buildEquipmentColumn(
      List<EquipmentFuseMapping> items, bool isDark) {
    return Column(
      children: items.map((item) {
        final isSelected = _selectedEquipment == item ||
            (item.fuseNumbers.contains(_highlightedFuseNumber));

        return InkWell(
          onTap: () => _onEquipmentSelected(item),
          child: Container(
            margin: const EdgeInsets.only(bottom: 2),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
            decoration: BoxDecoration(
              color: isSelected
                  ? (isDark
                      ? const Color(0xFF0369A1).withValues(alpha: 0.35)
                      : const Color(0xFFBAE6FD).withValues(alpha: 0.6))
                  : (isDark
                      ? const Color(0xFF0F172A)
                      : const Color(0xFFFFFFFF)),
              border: Border.all(
                color: isSelected
                    ? const Color(0xFF0284C7)
                    : (isDark
                        ? const Color(0xFF1E293B)
                        : const Color(0xFFE2E8F0)),
                width: isSelected ? 1.5 : 0.8,
              ),
              borderRadius: BorderRadius.circular(3),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_languageMode != 'arabic')
                        Text(
                          item.equipmentEnglish,
                          style: TextStyle(
                            fontFamily: 'Courier',
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: isDark
                                ? Colors.white
                                : const Color(0xFF0F172A),
                          ),
                        ),
                      if (_languageMode != 'english')
                        Text(
                          item.equipmentArabic,
                          style: KashifTypography.arabic(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w600,
                            color: isDark
                                ? const Color(0xFF94A3B8)
                                : const Color(0xFF334155),
                          ),
                        ),
                    ],
                  ),
                ),
                Wrap(
                  spacing: 4,
                  children: item.fuseNumbers.map((fuseNo) {
                    final isThisFuseActive = _highlightedFuseNumber == fuseNo;
                    final amps = _getFuseAmps(fuseNo);
                    final color = _getFuseColor(amps);

                    return GestureDetector(
                      onTap: () => _onFuseNumberTapped(fuseNo),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: isThisFuseActive
                              ? color
                              : color.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: color,
                            width: isThisFuseActive ? 2 : 1,
                          ),
                        ),
                        child: Text(
                          '$fuseNo',
                          style: TextStyle(
                            fontFamily: 'Courier',
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                            color: isThisFuseActive
                                ? (amps == 20 || amps == 25
                                    ? Colors.black87
                                    : Colors.white)
                                : (isDark ? Colors.white : Colors.black87),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  /// Authentic physical Fuse Number & Amperes Grid Table
  Widget _buildPhysicalFuseGrids(bool isDark) {
    // BMW E39 Glovebox:
    // Row 1: F1 - F20 + F75, F76
    // Row 2: F21 - F45
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Section Title: Fuse Numbers & Ratings
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
            border: Border.all(
              color: isDark ? const Color(0xFF334155) : const Color(0xFFCBD5E1),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  'جدول أرقام الفيوزات وقيم الأمبير المطابقة للملصق (Fuse Nr. & Amperes):',
                  style: KashifTypography.arabic(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'اضغط على أي فيوز لتحديده',
                style: KashifTypography.arabic(
                  fontSize: 9.5,
                  color: isDark
                      ? const Color(0xFF94A3B8)
                      : const Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 6),

        // Row 1: 1 to 20 + 75, 76
        _buildFuseGridTable(
          rowTitle: 'صف علوي (1 - 20)',
          fuses: [
            1, 2, 3, 4, 5, 6, 7, 8, 9, 10,
            11, 12, 13, 14, 15, 16, 17, 18, 19, 20
          ],
          specialFuses: [75, 76],
          isDark: isDark,
        ),
        const SizedBox(height: 8),

        // Row 2: 21 to 45
        _buildFuseGridTable(
          rowTitle: 'صف سفلي (21 - 45)',
          fuses: [
            21, 22, 23, 24, 25, 26, 27, 28, 29, 30,
            31, 32, 33, 34, 35, 36, 37, 38, 39, 40,
            41, 42, 43, 44, 45
          ],
          isDark: isDark,
        ),
      ],
    );
  }

  Widget _buildFuseGridTable({
    required String rowTitle,
    required List<int> fuses,
    List<int>? specialFuses,
    required bool isDark,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : Colors.white,
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFF0F172A),
          width: 1.2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Column (Fuse Nr. / Amperes)
                Column(
                  children: [
                    Container(
                      width: 72,
                      height: 26,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF1E293B)
                            : const Color(0xFFF1F5F9),
                        border: Border(
                          bottom: BorderSide(
                            color: isDark
                                ? const Color(0xFF334155)
                                : const Color(0xFF0F172A),
                          ),
                          left: BorderSide(
                            color: isDark
                                ? const Color(0xFF334155)
                                : const Color(0xFF0F172A),
                          ),
                        ),
                      ),
                      child: const Text(
                        'Fuse Nr.',
                        style: TextStyle(
                          fontFamily: 'Courier',
                          fontSize: 10.5,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    Container(
                      width: 72,
                      height: 26,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF1E293B)
                            : const Color(0xFFF1F5F9),
                        border: Border(
                          left: BorderSide(
                            color: isDark
                                ? const Color(0xFF334155)
                                : const Color(0xFF0F172A),
                          ),
                        ),
                      ),
                      child: const Text(
                        'Amperes',
                        style: TextStyle(
                          fontFamily: 'Courier',
                          fontSize: 10.5,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ],
                ),

                // Fuse Cells
                ...fuses.map((fNum) => _buildFuseCell(fNum, isDark)),

                // Gap & Special Maxi Fuses (75, 76 for BMW E39)
                if (specialFuses != null && specialFuses.isNotEmpty) ...[
                  Container(
                    width: 16,
                    height: 52,
                    color: isDark
                        ? const Color(0xFF1E293B).withValues(alpha: 0.5)
                        : const Color(0xFFE2E8F0).withValues(alpha: 0.5),
                  ),
                  ...specialFuses.map((fNum) => _buildFuseCell(fNum, isDark)),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFuseCell(int fuseNum, bool isDark) {
    final amps = _getFuseAmps(fuseNum);
    final isSelected = _highlightedFuseNumber == fuseNum;
    final color = _getFuseColor(amps);
    final isEmptySlot = (fuseNum == 26 ||
        fuseNum == 28 ||
        fuseNum == 33 ||
        fuseNum == 35 ||
        fuseNum == 36);

    final displayAmps = isEmptySlot
        ? '-'
        : (amps == 7 ? '7,5' : (amps == 8 ? '7,5' : '$amps'));

    return InkWell(
      onTap: isEmptySlot ? null : () => _onFuseNumberTapped(fuseNum),
      child: Container(
        width: 34,
        decoration: BoxDecoration(
          color: isSelected
              ? color.withValues(alpha: isDark ? 0.35 : 0.25)
              : Colors.transparent,
          border: Border(
            left: BorderSide(
              color: isDark ? const Color(0xFF334155) : const Color(0xFF0F172A),
              width: 0.8,
            ),
            bottom: isSelected
                ? BorderSide(color: color, width: 2.5)
                : BorderSide.none,
          ),
        ),
        child: Column(
          children: [
            // Top: Fuse Number
            Container(
              height: 26,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: isDark
                        ? const Color(0xFF334155)
                        : const Color(0xFF0F172A),
                    width: 0.8,
                  ),
                ),
              ),
              child: Text(
                '$fuseNum',
                style: TextStyle(
                  fontFamily: 'Courier',
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.w900 : FontWeight.w700,
                  color: isSelected
                      ? const Color(0xFF0284C7)
                      : (isDark ? Colors.white : const Color(0xFF0F172A)),
                ),
              ),
            ),

            // Bottom: Amperes (Clean, bold Courier text matching photo)
            Container(
              height: 26,
              alignment: Alignment.center,
              child: Text(
                displayAmps,
                style: TextStyle(
                  fontFamily: 'Courier',
                  fontSize: 10.5,
                  fontWeight: FontWeight.w900,
                  color: isSelected
                      ? color
                      : (isEmptySlot
                          ? Colors.grey
                          : (isDark
                              ? Colors.white70
                              : const Color(0xFF0F172A))),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Bottom Section: Card OEM number stamp and pull tab
  Widget _buildCardBottom(bool isDark) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'BMW 5-Series (E39) Glovebox Fuse Legend',
                style: TextStyle(
                  fontFamily: 'Courier',
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: isDark
                      ? const Color(0xFF64748B)
                      : const Color(0xFF94A3B8),
                ),
              ),
              const Text(
                '8 377 849\nE 6957.J',
                textAlign: TextAlign.right,
                style: TextStyle(
                  fontFamily: 'Courier',
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  height: 1.1,
                  color: Color(0xFF0F172A),
                ),
              ),
            ],
          ),
        ),

        // Downward Pull Tab (مثل لسان السحب في الصورة تماماً)
        if (widget.fuseBox.hasPullTab)
          Center(
            child: Container(
              width: 58,
              height: 40,
              decoration: BoxDecoration(
                color:
                    isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(29),
                ),
                border: Border.all(
                  color: isDark
                      ? const Color(0xFF475569)
                      : const Color(0xFF0F172A),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.15),
                    blurRadius: 4,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: const Center(
                child: Icon(
                  Icons.arrow_downward_rounded,
                  size: 22,
                  color: Color(0xFF0F172A),
                ),
              ),
            ),
          ),
        const SizedBox(height: 6),
      ],
    );
  }
}
