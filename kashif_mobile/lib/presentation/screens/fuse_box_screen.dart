import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/typography.dart';
import '../../data/models/car_fuse_box.dart';
import '../../data/models/diagnostic_report.dart';
import '../../data/repositories/car_fuse_repository.dart';
import '../providers/report_provider.dart';
import '../widgets/car_fuse_box_diagram.dart';

class FuseBoxScreen extends ConsumerStatefulWidget {
  final String? initialDtcFilter;
  final String? initialVehicleMake;
  final String? initialVehicleModel;
  final String? initialVehicleYear;
  final bool showAppBar;

  const FuseBoxScreen({
    super.key,
    this.initialDtcFilter,
    this.initialVehicleMake,
    this.initialVehicleModel,
    this.initialVehicleYear,
    this.showAppBar = true,
  });

  @override
  ConsumerState<FuseBoxScreen> createState() => _FuseBoxScreenState();
}

class _FuseBoxScreenState extends ConsumerState<FuseBoxScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  late CarVehicleModel _selectedCar;
  late VehicleFuseBox _selectedBox;
  FuseSlot? _selectedSlot;

  String? _dtcFilter;
  String _searchQuery = '';
  bool? _relaysFilter; // null = all, false = fuses only, true = relays only
  bool _showVisualDiagram = true;
  String? _lastSyncedReportId;
  bool _manuallyChangedCar = false;
  bool _filterByReportDtcs = false;

  @override
  void initState() {
    super.initState();
    DiagnosticReport? activeReport;
    try {
      activeReport = ref.read(reportProvider).report;
    } catch (_) {
      activeReport = null;
    }
    final make = widget.initialVehicleMake ?? activeReport?.vehicle.make;
    final model = widget.initialVehicleModel ?? activeReport?.vehicle.model;
    final year = widget.initialVehicleYear ?? activeReport?.vehicle.year;

    _selectedCar = CarFuseRepository.matchCar(
      make: make,
      model: model,
      year: year,
    ) ?? CarFuseRepository.supportedCars.first;

    _selectedBox = _selectedCar.fuseBoxes.first;
    _lastSyncedReportId = activeReport?.reportId;

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
    _scrollController.dispose();
    super.dispose();
  }

  void _onCarChanged(CarVehicleModel newCar) {
    setState(() {
      _manuallyChangedCar = true;
      _selectedCar = newCar;
      _selectedBox = newCar.fuseBoxes.first;
      _selectedSlot = null;
    });
  }

  void _onBoxChanged(VehicleFuseBox newBox) {
    setState(() {
      _selectedBox = newBox;
      _selectedSlot = null;
    });
  }

  void _onSlotSelected(FuseSlot slot) {
    setState(() {
      _selectedSlot = slot;
    });
    _showSlotDetailSheet(context, slot);
  }

  void _openCarSearchModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _CarSearchBottomSheet(
        selectedCar: _selectedCar,
        onCarSelected: (car) {
          Navigator.pop(ctx);
          _onCarChanged(car);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    DiagnosticReport? activeReport;
    try {
      activeReport = ref.watch(reportProvider).report;
    } catch (_) {
      activeReport = null;
    }

    // Auto-sync car when active report exists and hasn't been synced to _selectedCar yet
    if (activeReport != null &&
        activeReport.reportId != _lastSyncedReportId &&
        !_manuallyChangedCar) {
      _lastSyncedReportId = activeReport.reportId;
      final matched = CarFuseRepository.matchCar(
        make: activeReport.vehicle.make,
        model: activeReport.vehicle.model,
        year: activeReport.vehicle.year,
      );
      if (matched != null && matched.id != _selectedCar.id) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            setState(() {
              _selectedCar = matched;
              _selectedBox = matched.fuseBoxes.first;
              _selectedSlot = null;
            });
          }
        });
      }
    }

    final reportDtcs = activeReport?.allFaultCodes ?? [];

    final matchingReportSlotsCount =
        activeReport != null && reportDtcs.isNotEmpty
            ? CarFuseRepository.searchFuses(
                car: _selectedCar,
                dtcCodes: reportDtcs,
              ).length
            : 0;

    final filteredSlots = CarFuseRepository.searchFuses(
      car: _selectedCar,
      boxId: _selectedBox.id,
      query: _searchQuery,
      relaysOnly: _relaysFilter,
      dtcCode: _dtcFilter,
      dtcCodes: _filterByReportDtcs ? reportDtcs : null,
    );

    return Scaffold(
      appBar: widget.showAppBar
          ? AppBar(
              title: Text(
                'خرائط ومخططات علب الفيوزات للسيارات',
                style: KashifTypography.arabic(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              actions: [
                IconButton(
                  icon: const Icon(
                    Icons.search_rounded,
                    size: 20,
                    color: Color(0xFFD4AF37),
                  ),
                  tooltip: 'البحث عن سيارة',
                  onPressed: _openCarSearchModal,
                ),
                IconButton(
                  icon: Icon(
                    _showVisualDiagram
                        ? Icons.view_headline_rounded
                        : Icons.grid_view_rounded,
                    size: 20,
                    color: const Color(0xFFD4AF37),
                  ),
                  tooltip: _showVisualDiagram
                      ? 'إخفاء المخطط المصور'
                      : 'عرض المخطط المصور',
                  onPressed: () {
                    setState(() => _showVisualDiagram = !_showVisualDiagram);
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.info_outline_rounded, size: 20),
                  tooltip: 'إرشادات السلامة وفحص الفيوزات',
                  onPressed: () => _showSafetyGuide(context, isDark),
                ),
              ],
            )
          : null,
      body: Column(
        children: [
          // 1. Compact Unified Vehicle Bar (Only ~68px, Sleek & High-Tech)
          _buildCompactVehicleHeader(isDark),

          // 1.b. Active Report Direct Connection Banner
          if (activeReport != null)
            _buildReportSyncBanner(
              context,
              activeReport,
              matchingReportSlotsCount,
              isDark,
            ),

          // 2. Compact Location Switcher Pills (حوض المحرك / المقصورة / الشنطة / موقع فريد)
          _buildCompactLocationBar(isDark),

          // 3. Main Body: Realistic Diagram Front & Center + Detailed Directory
          Expanded(
            child: ListView(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              children: [
                // Detailed Physical Location Card (Clean & informative)
                _buildLocationInfoCard(isDark),
                const SizedBox(height: 10),

                // Realistic Visual Automotive Diagram (The Core Feature!)
                if (_showVisualDiagram) ...[
                  CarFuseBoxDiagram(
                    fuseBox: _selectedBox,
                    selectedSlot: _selectedSlot,
                    onSlotTapped: _onSlotSelected,
                    searchQuery: _searchQuery,
                  ),
                  const SizedBox(height: 14),
                ],

                // Search Bar & Filter Chips for Directory
                _buildSearchAndFilters(isDark),
                const SizedBox(height: 10),

                // Section Title for Arabic Fuse Directory
                Row(
                  children: [
                    const Icon(
                      Icons.format_list_bulleted_rounded,
                      size: 16,
                      color: Color(0xFFD4AF37),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'دليل وجدول الفيوزات بالعربي (${filteredSlots.length}):',
                        style: KashifTypography.arabic(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w800,
                          color: isDark
                              ? KashifColors.darkTextPrimary
                              : KashifColors.lightTextPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Fuse Cards List
                if (filteredSlots.isEmpty)
                  _buildEmptyState(isDark)
                else
                  ...filteredSlots.map(
                    (slot) => _buildFuseSlotCard(context, slot, isDark),
                  ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 1.b. Active Report Sync Banner (Auto-grounded to report vehicle & DTCs)
  Widget _buildReportSyncBanner(
    BuildContext context,
    DiagnosticReport activeReport,
    int matchingFusesCount,
    bool isDark,
  ) {
    final v = activeReport.vehicle;
    final primaryColor =
        isDark ? const Color(0xFFD4AF37) : const Color(0xFF1E40AF);

    return Container(
      margin: const EdgeInsets.fromLTRB(14, 6, 14, 4),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: primaryColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(9),
        border: Border.all(
          color: primaryColor.withValues(alpha: 0.35),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.auto_awesome_rounded,
            size: 16,
            color: primaryColor,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'سيارة الفحص بالتقرير الحالي (ربط تلقائي مباشر):',
                  style: KashifTypography.arabic(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                    color: primaryColor,
                  ),
                ),
                Text(
                  '${v.formattedTitle} ${v.cleanVin.isNotEmpty ? "• هيكل " + v.cleanVin : ""}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: KashifTypography.arabic(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w800,
                    color: isDark ? Colors.white : const Color(0xFF0F172A),
                  ),
                ),
              ],
            ),
          ),
          if (matchingFusesCount > 0)
            InkWell(
              onTap: () {
                setState(() {
                  _filterByReportDtcs = !_filterByReportDtcs;
                  if (_filterByReportDtcs) {
                    _searchQuery = '';
                    _searchController.clear();
                  }
                });
              },
              borderRadius: BorderRadius.circular(6),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _filterByReportDtcs ? primaryColor : Colors.transparent,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: primaryColor),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _filterByReportDtcs
                          ? Icons.check_circle_rounded
                          : Icons.filter_alt_rounded,
                      size: 12,
                      color: _filterByReportDtcs
                          ? (isDark ? Colors.black : Colors.white)
                          : primaryColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'أعطال الفحص ($matchingFusesCount)',
                      style: KashifTypography.arabic(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: _filterByReportDtcs
                            ? (isDark ? Colors.black : Colors.white)
                            : primaryColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// 1. Compact, Modern Unified Vehicle Header Bar
  Widget _buildCompactVehicleHeader(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F1726) : const Color(0xFFF1F5F9),
        border: Border(
          bottom: BorderSide(
            color: isDark ? const Color(0xFF1E293B) : const Color(0xFFCBD5E1),
          ),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              // Brand Pill Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFD4AF37).withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: const Color(0xFFD4AF37).withValues(alpha: 0.5),
                  ),
                ),
                child: Text(
                  _selectedCar.makeArabic,
                  style: KashifTypography.arabic(
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFFD4AF37),
                  ),
                ),
              ),
              const SizedBox(width: 8),

              // Model & Year
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _selectedCar.modelArabic,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: KashifTypography.arabic(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w800,
                        color: isDark ? Colors.white : const Color(0xFF0F172A),
                      ),
                    ),
                    Text(
                      _selectedCar.yearRange,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: KashifTypography.arabic(
                        fontSize: 10,
                        color: isDark ? Colors.white60 : Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),

              // Clean "Search Car" Action Button
              InkWell(
                onTap: _openCarSearchModal,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD4AF37),
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.search_rounded,
                        size: 14,
                        color: Colors.black,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'بحث عن سيارة',
                        style: KashifTypography.arabic(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),

          // OBD-II location indicator line
          Row(
            children: [
              const Icon(
                Icons.cable_rounded,
                size: 13,
                color: Color(0xFF10B981),
              ),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  'مدخل الفحص OBD-II: ${_selectedCar.obdLocation}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: KashifTypography.arabic(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                    color: isDark
                        ? const Color(0xFFA7F3D0)
                        : const Color(0xFF065F46),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// 2. Compact Location Switcher Pills Bar
  Widget _buildCompactLocationBar(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      color: isDark ? const Color(0xFF0A0F18) : const Color(0xFFE2E8F0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: _selectedCar.fuseBoxes.map((box) {
            final isSelected = box.id == _selectedBox.id;
            final isSpecial = box.isSpecialLocation;

            return Padding(
              padding: const EdgeInsets.only(left: 6),
              child: InkWell(
                onTap: () => _onBoxChanged(box),
                borderRadius: BorderRadius.circular(20),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFFD4AF37)
                        : (isDark
                            ? const Color(0xFF162032)
                            : const Color(0xFFCBD5E1)),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected
                          ? const Color(0xFFD4AF37)
                          : (isSpecial
                              ? const Color(0xFFFFD54F)
                              : Colors.transparent),
                      width: isSpecial ? 1.5 : 1.0,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isSpecial ? Icons.stars_rounded : box.locationType.icon,
                        size: 14,
                        color: isSelected
                            ? Colors.black
                            : (isSpecial
                                ? const Color(0xFFFFD54F)
                                : (isDark ? Colors.white70 : Colors.black87)),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        box.nameArabic,
                        style: KashifTypography.arabic(
                          fontSize: 11,
                          fontWeight:
                              isSelected ? FontWeight.w900 : FontWeight.w600,
                          color: isSelected
                              ? Colors.black
                              : (isDark ? Colors.white : Colors.black87),
                        ),
                      ),
                      if (isSpecial) ...[
                        const SizedBox(width: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 4, vertical: 1),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Colors.black26
                                : const Color(0xFFD4AF37).withValues(alpha: 0.25),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            '[موقع فريد وحساس]',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: isSelected
                                  ? Colors.black
                                  : const Color(0xFFFFD54F),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  /// Physical Location Info Card (Clean & informative)
  Widget _buildLocationInfoCard(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F1728) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: _selectedBox.isSpecialLocation
              ? const Color(0xFFD4AF37).withValues(alpha: 0.5)
              : const Color(0xFF10B981).withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                _selectedBox.isSpecialLocation
                    ? Icons.stars_rounded
                    : Icons.location_on_rounded,
                size: 15,
                color: _selectedBox.isSpecialLocation
                    ? const Color(0xFFD4AF37)
                    : const Color(0xFF10B981),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  _selectedBox.isSpecialLocation
                      ? 'مكان علبة الفيوزات [موقع فريد وحساس]:'
                      : 'مكان علبة الفيوزات في السيارة:',
                  style: KashifTypography.arabic(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w800,
                    color: _selectedBox.isSpecialLocation
                        ? const Color(0xFFD4AF37)
                        : const Color(0xFF10B981),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 3),
          Text(
            _selectedBox.detailedLocationArabic,
            style: KashifTypography.arabic(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: isDark
                  ? KashifColors.darkTextPrimary
                  : KashifColors.lightTextPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              const Icon(
                Icons.lock_open_rounded,
                size: 13,
                color: Color(0xFFD4AF37),
              ),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  'طريقة الفتح: ${_selectedBox.accessInstructions}',
                  style: KashifTypography.arabic(
                    fontSize: 10.5,
                    color: isDark ? Colors.white70 : Colors.black87,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Search Bar & Filter Chips in current box
  Widget _buildSearchAndFilters(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F1728) : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            onChanged: (val) {
              setState(() {
                _searchQuery = val;
                _dtcFilter = null;
              });
            },
            style: KashifTypography.arabic(
              fontSize: 12,
              color: isDark
                  ? KashifColors.darkTextPrimary
                  : KashifColors.lightTextPrimary,
            ),
            decoration: InputDecoration(
              hintText:
                  'ابحث في هذه العلبة (بومبة، OBD، مروحة، رشاشات أو رقم الفيوز)...',
              hintStyle: KashifTypography.arabic(
                fontSize: 11,
                color: isDark ? Colors.white38 : Colors.black38,
              ),
              prefixIcon: const Icon(Icons.search_rounded, size: 16),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, size: 14),
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
                horizontal: 10,
                vertical: 6,
              ),
              filled: true,
              fillColor: isDark
                  ? const Color(0xFF162032)
                  : Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 6),

          // Filters Row
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip(
                  label: 'الكل',
                  isSelected: _relaysFilter == null && _dtcFilter == null,
                  onTap: () => setState(() {
                    _relaysFilter = null;
                    _dtcFilter = null;
                  }),
                  isDark: isDark,
                ),
                const SizedBox(width: 6),
                _buildFilterChip(
                  label: 'الفيوزات فقط',
                  isSelected: _relaysFilter == false,
                  onTap: () => setState(() => _relaysFilter = false),
                  isDark: isDark,
                ),
                const SizedBox(width: 6),
                _buildFilterChip(
                  label: 'المرحلات (Relays)',
                  isSelected: _relaysFilter == true,
                  onTap: () => setState(() => _relaysFilter = true),
                  isDark: isDark,
                ),
                if (_dtcFilter != null) ...[
                  const SizedBox(width: 6),
                  _buildFilterChip(
                    label: 'كود: $_dtcFilter',
                    isSelected: true,
                    onTap: () => setState(() => _dtcFilter = null),
                    isDark: isDark,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFFD4AF37)
              : (isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0)),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          label,
          style: KashifTypography.arabic(
            fontSize: 10.5,
            fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
            color: isSelected
                ? Colors.black
                : (isDark ? Colors.white70 : Colors.black87),
          ),
        ),
      ),
    );
  }

  /// Fuse Slot Card in the list below diagram
  Widget _buildFuseSlotCard(BuildContext context, FuseSlot slot, bool isDark) {
    final fuseColor = Color(slot.colorValue);
    final isSelected = _selectedSlot?.slotId == slot.slotId;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F1728) : Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isSelected
              ? const Color(0xFFD4AF37)
              : (isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0)),
          width: isSelected ? 2.0 : 1.0,
        ),
      ),
      child: InkWell(
        onTap: () => _onSlotSelected(slot),
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Row: Code, Amp Badge, and Label
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: fuseColor,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      slot.isRelay ? 'RELAY' : '${slot.ratingAmps}A',
                      style: TextStyle(
                        fontFamily: 'Courier',
                        fontSize: 10.5,
                        fontWeight: FontWeight.w900,
                        color: slot.ratingAmps == 25
                            ? Colors.black87
                            : Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: isDark
                          ? const Color(0xFF1E293B)
                          : const Color(0xFFE2E8F0),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      slot.slotId,
                      style: const TextStyle(
                        fontFamily: 'Courier',
                        fontSize: 10.5,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFFD4AF37),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      slot.label,
                      style: const TextStyle(
                        fontFamily: 'Courier',
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF38BDF8),
                      ),
                    ),
                  ),
                  const Icon(
                    Icons.chevron_left_rounded,
                    size: 16,
                    color: Color(0xFFD4AF37),
                  ),
                ],
              ),
              const SizedBox(height: 5),

              // Arabic Name
              Text(
                slot.nameArabic,
                style: KashifTypography.arabic(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : const Color(0xFF0F172A),
                ),
              ),

              // First Symptom
              if (slot.symptoms.isNotEmpty) ...[
                const SizedBox(height: 3),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.warning_amber_rounded,
                      size: 13,
                      color: Color(0xFFEF4444),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        'عند احتراقه: ${slot.symptoms.first}',
                        style: KashifTypography.arabic(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w600,
                          color: isDark
                              ? const Color(0xFFFCA5A5)
                              : const Color(0xFFDC2626),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// Detailed Bottom Sheet with full circuit, symptoms, DTCs, and test tips
  void _showSlotDetailSheet(BuildContext context, FuseSlot slot) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fuseColor = Color(slot.colorValue);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF0F1724) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            border: Border.all(
              color: const Color(0xFFD4AF37).withValues(alpha: 0.5),
              width: 1.5,
            ),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 14),

              // Title Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: fuseColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      slot.isRelay ? 'RELAY' : '${slot.ratingAmps}A',
                      style: TextStyle(
                        fontFamily: 'Courier',
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                        color: slot.ratingAmps == 25
                            ? Colors.black87
                            : Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${slot.slotId}: ${slot.label}',
                          style: const TextStyle(
                            fontFamily: 'Courier',
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF38BDF8),
                          ),
                        ),
                        Text(
                          slot.nameArabic,
                          style: KashifTypography.arabic(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Circuit Function
              Text(
                'الوظيفة والدائرة الكهربائية:',
                style: KashifTypography.arabic(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFFD4AF37),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                slot.descriptionArabic,
                style: KashifTypography.arabic(
                  fontSize: 12,
                  color: isDark ? Colors.white70 : Colors.black87,
                ),
              ),
              const SizedBox(height: 12),

              // Symptoms
              if (slot.symptoms.isNotEmpty) ...[
                Text(
                  'أعراض تلف واحتراق هذا الفيوز:',
                  style: KashifTypography.arabic(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFFEF4444),
                  ),
                ),
                const SizedBox(height: 6),
                ...slot.symptoms.map(
                  (s) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('• ', style: TextStyle(color: Color(0xFFEF4444))),
                        Expanded(
                          child: Text(
                            s,
                            style: KashifTypography.arabic(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                              color: isDark
                                  ? const Color(0xFFFCA5A5)
                                  : const Color(0xFFDC2626),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],

              // Testing Tip
              if (slot.testingTip.isNotEmpty) ...[
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2E9E5B).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: const Color(0xFF2E9E5B).withValues(alpha: 0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.lightbulb_outline_rounded,
                        size: 16,
                        color: Color(0xFF2E9E5B),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'نصيحة الفحص: ${slot.testingTip}',
                          style: KashifTypography.arabic(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: isDark
                                ? const Color(0xFFA7F3D0)
                                : const Color(0xFF065F46),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD4AF37),
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () => Navigator.pop(ctx),
                  child: Text(
                    'تم - إغلاق',
                    style: KashifTypography.arabic(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyState(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(24),
      alignment: Alignment.center,
      child: Column(
        children: [
          const Icon(
            Icons.search_off_rounded,
            size: 36,
            color: Color(0xFF94A3B8),
          ),
          const SizedBox(height: 8),
          Text(
            'لم يتم العثور على فيوز مطابق للبحث في هذه العلبة',
            style: KashifTypography.arabic(
              fontSize: 11.5,
              color: isDark ? Colors.white60 : Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  void _showSafetyGuide(BuildContext context, bool isDark) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          'قواعد وإرشادات فحص الفيوزات بأمان',
          style: KashifTypography.arabic(
            fontSize: 14,
            fontWeight: FontWeight.w800,
          ),
        ),
        content: Text(
          '1. أطفئ السويتش وافصل الكونتاكت تماماً قبل نزع أي فيوز.\n'
          '2. لا تستبدل أبداً فيوزاً محترقاً بفيوز ذي أمبير أعلى لتجنب احتراق الأسلاك.\n'
          '3. استخدم ملقط الفيوزات البلاستيكي الموجود في غطاء العلبة.\n'
          '4. استخدم لمبة الفحص (Test Light) على النقطتين المعدنيتين أعلى الفيوز.\n'
          '5. إذا احترق الفيوز الجديد فور تركيبه، يوجد شورت صريح في الدائرة.',
          style: KashifTypography.arabic(fontSize: 11.5, height: 1.6),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('فهمت ذلك'),
          ),
        ],
      ),
    );
  }
}

/// Searchable Bottom Sheet for Selecting Cars
class _CarSearchBottomSheet extends StatefulWidget {
  final CarVehicleModel selectedCar;
  final ValueChanged<CarVehicleModel> onCarSelected;

  const _CarSearchBottomSheet({
    required this.selectedCar,
    required this.onCarSelected,
  });

  @override
  State<_CarSearchBottomSheet> createState() => _CarSearchBottomSheetState();
}

class _CarSearchBottomSheetState extends State<_CarSearchBottomSheet> {
  final TextEditingController _queryController = TextEditingController();
  String _query = '';
  String _activeMake = 'الكل';

  @override
  void dispose() {
    _queryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    var results = CarFuseRepository.searchCars(_query);
    if (_activeMake != 'الكل') {
      results = results
          .where((c) =>
              c.make.toLowerCase() == _activeMake.toLowerCase() ||
              c.makeArabic == _activeMake)
          .toList();
    }

    final makes = [
      'الكل',
      'مرسيدس-بنز',
      'بي إم دبليو',
      'تويوتا',
      'هيونداي',
      'نيسان',
      'أوبل',
      'فولكس فاجن',
    ];

    return Container(
      height: MediaQuery.of(context).size.height * 0.82,
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F1724) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        border: Border.all(
          color: const Color(0xFFD4AF37).withValues(alpha: 0.5),
          width: 1.5,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Column(
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Header
          Row(
            children: [
              const Icon(
                Icons.directions_car_filled_rounded,
                size: 20,
                color: Color(0xFFD4AF37),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'البحث عن سيارة وموديل (${results.length}):',
                  style: KashifTypography.arabic(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Search Field
          TextField(
            controller: _queryController,
            autofocus: true,
            onChanged: (val) => setState(() => _query = val),
            style: KashifTypography.arabic(fontSize: 13),
            decoration: InputDecoration(
              hintText: 'ابحث (مرسيدس، BMW، E39، W204، E90، F30، كامري، كورولا...)',
              hintStyle: KashifTypography.arabic(
                fontSize: 11.5,
                color: isDark ? Colors.white38 : Colors.black38,
              ),
              prefixIcon: const Icon(Icons.search_rounded, size: 18),
              suffixIcon: _query.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, size: 16),
                      onPressed: () {
                        _queryController.clear();
                        setState(() => _query = '');
                      },
                    )
                  : null,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              filled: true,
              fillColor: isDark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Brand Filter Pills in Modal
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: makes.map((m) {
                final isSelected = _activeMake == m;
                return Padding(
                  padding: const EdgeInsets.only(left: 6),
                  child: ChoiceChip(
                    label: Text(m),
                    selected: isSelected,
                    labelStyle: KashifTypography.arabic(
                      fontSize: 10,
                      fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                      color: isSelected
                          ? Colors.black
                          : (isDark ? Colors.white70 : Colors.black87),
                    ),
                    selectedColor: const Color(0xFFD4AF37),
                    backgroundColor: isDark
                        ? const Color(0xFF1E293B)
                        : const Color(0xFFE2E8F0),
                    visualDensity: VisualDensity.compact,
                    onSelected: (val) {
                      setState(() => _activeMake = m);
                    },
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 8),

          // Results List
          Expanded(
            child: results.isEmpty
                ? Center(
                    child: Text(
                      'لا توجد سيارة مطابقة للبحث',
                      style: KashifTypography.arabic(fontSize: 12),
                    ),
                  )
                : ListView.builder(
                    itemCount: results.length,
                    itemBuilder: (context, index) {
                      final car = results[index];
                      final isSelected = car.id == widget.selectedCar.id;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFFD4AF37).withValues(alpha: 0.15)
                              : (isDark
                                  ? const Color(0xFF162032)
                                  : const Color(0xFFF8FAFC)),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isSelected
                                ? const Color(0xFFD4AF37)
                                : (isDark
                                    ? const Color(0xFF26354A)
                                    : const Color(0xFFE2E8F0)),
                            width: isSelected ? 1.8 : 1.0,
                          ),
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: ListTile(
                            onTap: () => widget.onCarSelected(car),
                            leading: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: const Color(0xFFD4AF37)
                                    .withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                car.makeArabic,
                                style: KashifTypography.arabic(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w800,
                                  color: const Color(0xFFD4AF37),
                                ),
                              ),
                            ),
                            title: Text(
                              car.modelArabic,
                              style: KashifTypography.arabic(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            subtitle: Text(
                              '${car.yearRange} • ${car.fuseBoxes.length} علب فيوزات',
                              style: KashifTypography.arabic(
                                fontSize: 10.5,
                                color: isDark ? Colors.white60 : Colors.black54,
                              ),
                            ),
                            trailing: isSelected
                                ? const Icon(
                                    Icons.check_circle_rounded,
                                    color: Color(0xFFD4AF37),
                                  )
                                : const Icon(
                                    Icons.chevron_left_rounded,
                                    color: Colors.grey,
                                  ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
