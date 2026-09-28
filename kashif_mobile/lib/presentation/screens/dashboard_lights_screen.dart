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
              : 'دليل لمبات طبلون السيارة',
          style: KashifTypography.arabic(
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
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
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                    hintText: 'ابحث عن اللمبة (المكينة، الزيت، ABS، P0300)...',
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

          // Lights list
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
                            'جرب البحث باسم آخر مثل: الزيت، الفرامل، ABS، المكينة، أو كود DTC.',
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
                    itemCount: filteredLights.length,
                    itemBuilder: (context, index) {
                      final item = filteredLights[index];
                      final isSelected = _selectedIds.contains(item.id);
                      return _buildLightCard(context, item, isSelected, isDark);
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
          : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon Frame with colored glow
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: lightColor.withValues(alpha: 0.18),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: lightColor, width: 1.5),
                  boxShadow: [
                    BoxShadow(
                      color: lightColor.withValues(alpha: 0.3),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: Center(
                  child: CarDashboardSymbol(
                    symbolId: item.id,
                    color: lightColor,
                    size: 28,
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Title and English name
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
                    Text(
                      item.nameEnglish,
                      style: TextStyle(
                        fontFamily: 'Courier',
                        fontSize: 11,
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
                    horizontal: 8,
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
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: lightColor,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),

          // Can Drive status badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
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
                  size: 15,
                  color: canDriveColor,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    item.canDrive.labelArabic,
                    style: KashifTypography.arabic(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w800,
                      color: canDriveColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Meaning
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

          // Action Required Box
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
                  Icons.build_circle_rounded,
                  size: 16,
                  color: Color(0xFF2E9E5B),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    item.actionRequired,
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

          // Associated DTC Codes (if any)
          if (item.associatedDTCs.isNotEmpty) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                  'أكواد الـ DTC المرتبطة:',
                  style: KashifTypography.arabic(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: isDark
                        ? KashifColors.darkTextMuted
                        : KashifColors.lightTextMuted,
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Wrap(
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
                            horizontal: 5,
                            vertical: 1,
                          ),
                          decoration: BoxDecoration(
                            color: isDark
                                ? const Color(0xFF1E2838)
                                : const Color(0xFFEEF3F8),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                              color: const Color(
                                0xFFD4AF37,
                              ).withValues(alpha: 0.4),
                            ),
                          ),
                          child: Text(
                            code,
                            style: const TextStyle(
                              fontFamily: 'Courier',
                              fontSize: 10.5,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFFD4AF37),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
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
