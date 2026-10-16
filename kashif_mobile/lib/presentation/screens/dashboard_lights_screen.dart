import 'package:flutter/material.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/typography.dart';
import '../../data/models/dashboard_light.dart';
import '../../data/repositories/dashboard_lights_repository.dart';
import '../widgets/fuse_cell.dart';
import '../widgets/car_dashboard_symbol.dart';

class DashboardLightsScreen extends StatefulWidget {
  final List<String>? initialSelectedIds;
  final ValueChanged<List<String>>? onLightsSelected;
  final String? initialDtcFilter;

  const DashboardLightsScreen({
    super.key,
    this.initialSelectedIds,
    this.onLightsSelected,
    this.initialDtcFilter,
  });

  @override
  State<DashboardLightsScreen> createState() => _DashboardLightsScreenState();
}

class _DashboardLightsScreenState extends State<DashboardLightsScreen> {
  final TextEditingController _searchController = TextEditingController();
  late Set<String> _selectedIds;
  LightSeverity? _selectedSeverity;
  String? _dtcFilter;
  String _searchQuery = '';
  bool _isGridView = false;

  bool get _isSelectionMode => widget.onLightsSelected != null;

  @override
  void initState() {
    super.initState();
    _selectedIds = Set<String>.from(widget.initialSelectedIds ?? []);
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

    final filteredLights = DashboardLightsRepository.searchLights(
      query: _searchQuery,
      severityFilter: _selectedSeverity,
      dtcCode: _dtcFilter,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isSelectionMode
              ? 'تحديد لمبات الطبلون المضاءة'
              : 'دليل لمبات طبلون السيارة (64 لمبة)',
          style: KashifTypography.arabic(
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _isGridView
                  ? Icons.view_agenda_rounded
                  : Icons.grid_view_rounded,
              color: const Color(0xFFD4AF37),
            ),
            tooltip: _isGridView
                ? 'عرض القائمة المفصلة'
                : 'عرض شبكة الطبلون (64 لمبة)',
            onPressed: () {
              setState(() => _isGridView = !_isGridView);
            },
          ),
          if (_isSelectionMode && _selectedIds.isNotEmpty)
            TextButton(
              onPressed: () {
                setState(() => _selectedIds.clear());
              },
              child: Text(
                'مسح التحديد',
                style: KashifTypography.arabic(
                  fontSize: 12,
                  color: const Color(0xFFE53935),
                ),
              ),
            ),
        ],
      ),
      bottomNavigationBar: _isSelectionMode
          ? Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isDark
                    ? KashifColors.darkBoard
                    : KashifColors.lightBoard,
                border: Border(
                  top: BorderSide(
                    color: isDark
                        ? KashifColors.darkBorder
                        : KashifColors.lightBorder,
                  ),
                ),
              ),
              child: SafeArea(
                child: ElevatedButton.icon(
                  onPressed: () {
                    widget.onLightsSelected!(_selectedIds.toList());
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.check_circle_rounded, size: 18),
                  label: Text(
                    'تأكيد لمبات الطبلون (${_selectedIds.length}) وإرفاقها بالتقرير',
                    style: KashifTypography.arabic(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD4AF37),
                    foregroundColor: const Color(0xFF070E1E),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            )
          : null,
      body: Column(
        children: [
          // Search & Filter header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            color: isDark ? KashifColors.darkBoard : KashifColors.lightBoard,
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
                    fontSize: 13,
                    color: isDark
                        ? KashifColors.darkTextPrimary
                        : KashifColors.lightTextPrimary,
                  ),
                  decoration: InputDecoration(
                    hintText:
                        'ابحث برقم اللمبة (مثل: 62) أو بالاسم (المحرك، الزيت، ABS)...',
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

                // Severity Filter Chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildSeverityChip(
                        label:
                            'الكل (${DashboardLightsRepository.allLights.length})',
                        isSelected:
                            _selectedSeverity == null && _dtcFilter == null,
                        onTap: () => setState(() {
                          _selectedSeverity = null;
                          _dtcFilter = null;
                        }),
                        isDark: isDark,
                      ),
                      const SizedBox(width: 6),
                      _buildSeverityChip(
                        label: 'أحمر (خطر داهم)',
                        icon: Icons.dangerous_rounded,
                        color: const Color(0xFFE53935),
                        isSelected:
                            _selectedSeverity == LightSeverity.criticalRed,
                        onTap: () => setState(() {
                          _selectedSeverity = LightSeverity.criticalRed;
                        }),
                        isDark: isDark,
                      ),
                      const SizedBox(width: 6),
                      _buildSeverityChip(
                        label: 'أصفر (تحذير وفحص)',
                        icon: Icons.warning_amber_rounded,
                        color: const Color(0xFFFDD835),
                        isSelected:
                            _selectedSeverity == LightSeverity.warningAmber,
                        onTap: () => setState(() {
                          _selectedSeverity = LightSeverity.warningAmber;
                        }),
                        isDark: isDark,
                      ),
                      const SizedBox(width: 6),
                      _buildSeverityChip(
                        label: 'أخضر/أزرق (أنظمة)',
                        icon: Icons.check_circle_outline_rounded,
                        color: const Color(0xFF43A047),
                        isSelected:
                            _selectedSeverity == LightSeverity.infoGreenBlue,
                        onTap: () => setState(() {
                          _selectedSeverity = LightSeverity.infoGreenBlue;
                        }),
                        isDark: isDark,
                      ),
                      if (_dtcFilter != null) ...[
                        const SizedBox(width: 6),
                        _buildSeverityChip(
                          label: 'كود: $_dtcFilter',
                          icon: Icons.bolt_rounded,
                          color: const Color(0xFFD4AF37),
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
          ),

          // Instructions Banner if in selection mode
          if (_isSelectionMode)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              color: const Color(0xFFD4AF37).withValues(alpha: 0.15),
              child: Row(
                children: [
                  const Icon(
                    Icons.touch_app_rounded,
                    size: 18,
                    color: Color(0xFFD4AF37),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'اضغط على أي لمبة مشتعلة في طبلون السيارة لتضمينها في التقرير ومطابقتها مع كود العطل.',
                      style: KashifTypography.arabic(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? const Color(0xFFF5C84C)
                            : const Color(0xFF7A5807),
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // Lights list or grid
          Expanded(
            child: filteredLights.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.lightbulb_outline_rounded,
                            size: 48,
                            color: isDark
                                ? KashifColors.darkTextMuted
                                : KashifColors.lightTextMuted,
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'لم يتم العثور على لمبة مطابقة',
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
                            'جرب البحث برقم اللمبة (مثل: 62) أو باسمها (الزيت، الفرامل، ABS، الكمبيو، المحرك).',
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
                : _isGridView
                    ? GridView.builder(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 3,
                          childAspectRatio: 0.78,
                          crossAxisSpacing: 8,
                          mainAxisSpacing: 8,
                        ),
                        itemCount: filteredLights.length,
                        itemBuilder: (context, index) {
                          final item = filteredLights[index];
                          final isSelected = _selectedIds.contains(item.id);
                          return _buildLightGridCard(
                            context,
                            item,
                            isSelected,
                            isDark,
                          );
                        },
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 12,
                        ),
                        itemCount: filteredLights.length,
                        itemBuilder: (context, index) {
                          final item = filteredLights[index];
                          final isSelected = _selectedIds.contains(item.id);
                          return _buildLightCard(
                            context,
                            item,
                            isSelected,
                            isDark,
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildSeverityChip({
    required String label,
    IconData? icon,
    Color? color,
    required bool isSelected,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    final activeColor =
        color ?? (isDark ? KashifColors.goldLight : KashifColors.royalBlue);

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

  Widget _buildLightGridCard(
    BuildContext context,
    DashboardLightItem item,
    bool isSelected,
    bool isDark,
  ) {
    final lightColor = Color(item.colorValue);

    return InkWell(
      onTap: () {
        if (_isSelectionMode) {
          setState(() {
            if (isSelected) {
              _selectedIds.remove(item.id);
            } else {
              _selectedIds.add(item.id);
            }
          });
        } else {
          _showLightDetailSheet(context, item, isDark);
        }
      },
      borderRadius: BorderRadius.circular(10),
      child: Container(
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFFD4AF37).withValues(alpha: 0.16)
              : (isDark ? KashifColors.darkCell : KashifColors.lightCell),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected
                ? const Color(0xFFD4AF37)
                : (isDark ? KashifColors.darkBorder : KashifColors.lightBorder),
            width: isSelected ? 2.0 : 1.0,
          ),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: const Color(0xFFD4AF37).withValues(alpha: 0.25),
                blurRadius: 6,
              ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Top Row: Number badge and selection
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                  decoration: BoxDecoration(
                    color: lightColor.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(
                      color: lightColor.withValues(alpha: 0.5),
                    ),
                  ),
                  child: Text(
                    '#${item.number}',
                    style: TextStyle(
                      fontFamily: 'Courier',
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      color: lightColor,
                    ),
                  ),
                ),
                if (_isSelectionMode)
                  Icon(
                    isSelected
                        ? Icons.check_circle_rounded
                        : Icons.radio_button_unchecked_rounded,
                    size: 16,
                    color: isSelected
                        ? const Color(0xFFD4AF37)
                        : (isDark ? Colors.white38 : Colors.black26),
                  )
                else
                  Text(
                    item.symbolCode,
                    style: TextStyle(
                      fontFamily: 'Courier',
                      fontSize: 8.5,
                      fontWeight: FontWeight.w700,
                      color: lightColor.withValues(alpha: 0.8),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),

            // Center Real Icon inside dark automotive pod
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: lightColor.withValues(alpha: 0.5),
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: lightColor.withValues(alpha: 0.25),
                    blurRadius: 6,
                  ),
                ],
              ),
              clipBehavior: Clip.antiAlias,
              child: Center(
                child: Image.asset(
                  item.imageAsset,
                  width: 44,
                  height: 44,
                  fit: BoxFit.contain,
                  errorBuilder: (ctx, err, stack) => CarDashboardSymbol(
                    symbolId: item.id,
                    color: lightColor,
                    size: 26,
                    fallbackIcon: item.icon,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 4),

            // Bottom Name (centered)
            Text(
              item.nameArabic,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: KashifTypography.arabic(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: isDark
                    ? KashifColors.darkTextPrimary
                    : KashifColors.lightTextPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLightCard(
    BuildContext context,
    DashboardLightItem item,
    bool isSelected,
    bool isDark,
  ) {
    final lightColor = Color(item.colorValue);
    final canDriveColor = Color(item.canDrive.colorValue);

    return FuseCell(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      onTap: _isSelectionMode
          ? () {
              setState(() {
                if (isSelected) {
                  _selectedIds.remove(item.id);
                } else {
                  _selectedIds.add(item.id);
                }
              });
            }
          : () => _showLightDetailSheet(context, item, isDark),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Real Warning Light Icon in dark automotive cluster bezel
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: lightColor.withValues(alpha: 0.6),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: lightColor.withValues(alpha: 0.35),
                      blurRadius: 6,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                clipBehavior: Clip.antiAlias,
                child: Center(
                  child: Image.asset(
                    item.imageAsset,
                    width: 46,
                    height: 46,
                    fit: BoxFit.contain,
                    errorBuilder: (ctx, err, stack) => CarDashboardSymbol(
                      symbolId: item.id,
                      color: lightColor,
                      size: 28,
                      fallbackIcon: item.icon,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Title, number, and explanation
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 1.5,
                          ),
                          decoration: BoxDecoration(
                            color: lightColor.withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                              color: lightColor.withValues(alpha: 0.5),
                            ),
                          ),
                          child: Text(
                            '#${item.number}',
                            style: TextStyle(
                              fontFamily: 'Courier',
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                              color: lightColor,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            item.nameArabic,
                            style: KashifTypography.arabic(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: isDark
                                  ? KashifColors.darkTextPrimary
                                  : KashifColors.lightTextPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.nameEnglish,
                      style: TextStyle(
                        fontFamily: 'Courier',
                        fontSize: 10.5,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? KashifColors.darkTextMuted
                            : KashifColors.lightTextMuted,
                      ),
                    ),
                  ],
                ),
              ),

              // Checkbox (in selection mode) or Severity Badge
              if (_isSelectionMode)
                Checkbox(
                  value: isSelected,
                  activeColor: const Color(0xFFD4AF37),
                  checkColor: const Color(0xFF070E1E),
                  onChanged: (val) {
                    setState(() {
                      if (val == true) {
                        _selectedIds.add(item.id);
                      } else {
                        _selectedIds.remove(item.id);
                      }
                    });
                  },
                )
              else
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 7,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: lightColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: lightColor.withValues(alpha: 0.6),
                    ),
                  ),
                  child: Text(
                    item.symbolCode,
                    style: TextStyle(
                      fontFamily: 'Courier',
                      fontSize: 9.5,
                      fontWeight: FontWeight.w800,
                      color: lightColor,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),

          // Explanation / Meaning from Image 2
          Text(
            item.meaningArabic,
            style: KashifTypography.arabic(
              fontSize: 12,
              color: isDark
                  ? KashifColors.darkTextPrimary
                  : KashifColors.lightTextPrimary,
            ),
          ),
          const SizedBox(height: 8),

          // Can Drive status badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
            decoration: BoxDecoration(
              color: canDriveColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: canDriveColor.withValues(alpha: 0.4)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  item.canDrive == CanDriveStatus.stopImmediately
                      ? Icons.dangerous_rounded
                      : (item.canDrive == CanDriveStatus.driveCarefully
                            ? Icons.warning_amber_rounded
                            : Icons.check_circle_rounded),
                  size: 14,
                  color: canDriveColor,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    item.canDrive.labelArabic,
                    style: KashifTypography.arabic(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: canDriveColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Bottom Action Row: Details & Causes button + DTCs
          Row(
            children: [
              // Prominent Details Button (التفاصيل والمسببات)
              InkWell(
                onTap: () => _showLightDetailSheet(context, item, isDark),
                borderRadius: BorderRadius.circular(6),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD4AF37).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: const Color(0xFFD4AF37).withValues(alpha: 0.45),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.info_outline_rounded,
                        size: 14,
                        color: Color(0xFFD4AF37),
                      ),
                      const SizedBox(width: 5),
                      Text(
                        'التفاصيل والمسببات',
                        style: KashifTypography.arabic(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFFD4AF37),
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 10,
                        color: Color(0xFFD4AF37),
                      ),
                    ],
                  ),
                ),
              ),

              if (item.associatedDTCs.isNotEmpty) ...[
                const SizedBox(width: 8),
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: item.associatedDTCs.map((code) {
                        return Padding(
                          padding: const EdgeInsets.only(left: 4),
                          child: InkWell(
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
                                horizontal: 5,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: isDark
                                    ? const Color(0xFF1E2838)
                                    : const Color(0xFFEEF3F8),
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(
                                  color: const Color(0xFFD4AF37)
                                      .withValues(alpha: 0.35),
                                ),
                              ),
                              child: Text(
                                code,
                                style: const TextStyle(
                                  fontFamily: 'Courier',
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFFD4AF37),
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
            ],
          ),
        ],
      ),
    );
  }

  void _showLightDetailSheet(
    BuildContext context,
    DashboardLightItem item,
    bool isDark,
  ) {
    final lightColor = Color(item.colorValue);
    final canDriveColor = Color(item.canDrive.colorValue);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
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
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header with real icon
              Row(
                children: [
                  Container(
                    width: 58,
                    height: 58,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: lightColor, width: 1.8),
                      boxShadow: [
                        BoxShadow(
                          color: lightColor.withValues(alpha: 0.4),
                          blurRadius: 8,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    clipBehavior: Clip.antiAlias,
                    child: Center(
                      child: Image.asset(
                        item.imageAsset,
                        width: 50,
                        height: 50,
                        fit: BoxFit.contain,
                        errorBuilder: (ctx2, err, stack) => CarDashboardSymbol(
                          symbolId: item.id,
                          color: lightColor,
                          size: 30,
                          fallbackIcon: item.icon,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: lightColor.withValues(alpha: 0.18),
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(
                                  color: lightColor.withValues(alpha: 0.5),
                                ),
                              ),
                              child: Text(
                                '#${item.number}',
                                style: TextStyle(
                                  fontFamily: 'Courier',
                                  fontSize: 11,
                                  fontWeight: FontWeight.w900,
                                  color: lightColor,
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                item.nameArabic,
                                style: KashifTypography.arabic(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                  color: isDark
                                      ? KashifColors.darkTextPrimary
                                      : KashifColors.lightTextPrimary,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Text(
                          item.nameEnglish,
                          style: TextStyle(
                            fontFamily: 'Courier',
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
                    icon: const Icon(Icons.close_rounded, size: 20),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const Divider(height: 20),

              // Can-Drive status
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: canDriveColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                  border:
                      Border.all(color: canDriveColor.withValues(alpha: 0.5)),
                ),
                child: Row(
                  children: [
                    Icon(
                      item.canDrive == CanDriveStatus.stopImmediately
                          ? Icons.dangerous_rounded
                          : (item.canDrive == CanDriveStatus.driveCarefully
                                ? Icons.warning_amber_rounded
                                : Icons.check_circle_rounded),
                      color: canDriveColor,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        item.canDrive.labelArabic,
                        style: KashifTypography.arabic(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: canDriveColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // Explanation / Meaning
              Text(
                'الشرح ودلالة اللمبة:',
                style: KashifTypography.arabic(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFFD4AF37),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                item.meaningArabic,
                style: KashifTypography.arabic(
                  fontSize: 12.5,
                  color: isDark
                      ? KashifColors.darkTextPrimary
                      : KashifColors.lightTextPrimary,
                ),
              ),
              const SizedBox(height: 14),

              // Common Causes (مسبباتها)
              if (item.commonCauses.isNotEmpty) ...[
                Row(
                  children: [
                    const Icon(
                      Icons.help_outline_rounded,
                      size: 15,
                      color: Color(0xFFD4AF37),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'مسببات ظهور اللمبة المحتملة:',
                      style: KashifTypography.arabic(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFFD4AF37),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: isDark
                        ? const Color(0xFF131D2E)
                        : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isDark
                          ? KashifColors.darkBorder
                          : KashifColors.lightBorder,
                    ),
                  ),
                  child: Column(
                    children: item.commonCauses.map(
                      (cause) => Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              '⚠️ ',
                              style: TextStyle(fontSize: 12),
                            ),
                            Expanded(
                              child: Text(
                                cause,
                                style: KashifTypography.arabic(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: isDark
                                      ? KashifColors.darkTextPrimary
                                      : KashifColors.lightTextPrimary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ).toList(),
                  ),
                ),
                const SizedBox(height: 14),
              ],

              // Action required (الإجراء المطلوب)
              Row(
                children: [
                  const Icon(
                    Icons.build_circle_rounded,
                    size: 15,
                    color: Color(0xFF2E9E5B),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'الإجراء الفوري الموصى به:',
                    style: KashifTypography.arabic(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF2E9E5B),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color:
                      isDark ? const Color(0xFF142019) : const Color(0xFFF0F9F3),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: const Color(0xFF2E9E5B).withValues(alpha: 0.3),
                  ),
                ),
                child: Text(
                  item.actionRequired,
                  style: KashifTypography.arabic(
                    fontSize: 11.5,
                    color: isDark
                        ? const Color(0xFFC8E6C9)
                        : const Color(0xFF1B5E20),
                  ),
                ),
              ),

              // Associated DTCs
              if (item.associatedDTCs.isNotEmpty) ...[
                const SizedBox(height: 14),
                Text(
                  'أكواد الـ DTC المرتبطة:',
                  style: KashifTypography.arabic(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: isDark
                        ? KashifColors.darkTextMuted
                        : KashifColors.lightTextMuted,
                  ),
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: item.associatedDTCs.map((code) {
                    return InkWell(
                      onTap: () {
                        Navigator.pop(ctx);
                        setState(() {
                          _dtcFilter = code;
                          _searchQuery = code;
                          _searchController.text = code;
                        });
                      },
                      borderRadius: BorderRadius.circular(4),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: isDark
                              ? const Color(0xFF1E2838)
                              : const Color(0xFFEEF3F8),
                          borderRadius: BorderRadius.circular(4),
                          border: Border.all(
                            color: const Color(0xFFD4AF37).withValues(alpha: 0.5),
                          ),
                        ),
                        child: Text(
                          code,
                          style: const TextStyle(
                            fontFamily: 'Courier',
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFFD4AF37),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],

              // Toggle Selection button if in selection mode
              if (_isSelectionMode) ...[
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      if (_selectedIds.contains(item.id)) {
                        _selectedIds.remove(item.id);
                      } else {
                        _selectedIds.add(item.id);
                      }
                    });
                    Navigator.pop(ctx);
                  },
                  icon: Icon(
                    _selectedIds.contains(item.id)
                        ? Icons.check_circle_rounded
                        : Icons.add_circle_outline_rounded,
                    size: 16,
                  ),
                  label: Text(
                    _selectedIds.contains(item.id)
                        ? 'إلغاء تحديد هذه اللمبة'
                        : 'تحديد هذه اللمبة للتقرير',
                    style: KashifTypography.arabic(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _selectedIds.contains(item.id)
                        ? const Color(0xFFE53935)
                        : const Color(0xFFD4AF37),
                    foregroundColor: _selectedIds.contains(item.id)
                        ? Colors.white
                        : const Color(0xFF070E1E),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
