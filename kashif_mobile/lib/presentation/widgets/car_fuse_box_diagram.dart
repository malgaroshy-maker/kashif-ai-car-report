import 'package:flutter/material.dart';
import '../../core/theme/typography.dart';
import '../../data/models/car_fuse_box.dart';
import 'authentic_fuse_card_widget.dart';

enum FuseDiagramViewMode {
  card,
  tray,
  sticker,
}

class CarFuseBoxDiagram extends StatefulWidget {
  final VehicleFuseBox fuseBox;
  final FuseSlot? selectedSlot;
  final ValueChanged<FuseSlot> onSlotTapped;
  final String searchQuery;

  const CarFuseBoxDiagram({
    super.key,
    required this.fuseBox,
    this.selectedSlot,
    required this.onSlotTapped,
    this.searchQuery = '',
  });

  @override
  State<CarFuseBoxDiagram> createState() => _CarFuseBoxDiagramState();
}

class _CarFuseBoxDiagramState extends State<CarFuseBoxDiagram> {
  final TransformationController _transformController =
      TransformationController();
  FuseDiagramViewMode _viewMode = FuseDiagramViewMode.card;

  @override
  void initState() {
    super.initState();
    if (widget.fuseBox.equipmentMappings.isEmpty) {
      _viewMode = FuseDiagramViewMode.tray;
    }
  }

  @override
  void didUpdateWidget(covariant CarFuseBoxDiagram oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.fuseBox.id != widget.fuseBox.id) {
      if (widget.fuseBox.equipmentMappings.isNotEmpty) {
        _viewMode = FuseDiagramViewMode.card;
      } else {
        _viewMode = FuseDiagramViewMode.tray;
      }
    }
  }

  @override
  void dispose() {
    _transformController.dispose();
    super.dispose();
  }

  void _resetZoom() {
    setState(() {
      _transformController.value = Matrix4.identity();
    });
  }

  IconData _getSlotIcon(FuseSlot slot) {
    if (slot.isRelay) return Icons.developer_board_rounded;
    final text = '${slot.label} ${slot.nameArabic}'.toLowerCase();
    if (text.contains('pump') || text.contains('بومبة') || text.contains('وقود') || text.contains('بنزين')) {
      return Icons.local_gas_station_rounded;
    }
    if (text.contains('fan') || text.contains('مروحة') || text.contains('رداتوري')) {
      return Icons.toys_rounded;
    }
    if (text.contains('ecu') || text.contains('dme') || text.contains('كمبيوتر') || text.contains('عقل') || text.contains('بوكس')) {
      return Icons.memory_rounded;
    }
    if (text.contains('obd') || text.contains('فحص') || text.contains('سكنر')) {
      return Icons.cable_rounded;
    }
    if (text.contains('wiper') || text.contains('مساح')) {
      return Icons.water_drop_rounded;
    }
    if (text.contains('light') || text.contains('hlp') || text.contains('مصباح') || text.contains('كشاف')) {
      return Icons.light_mode_rounded;
    }
    if (text.contains('horn') || text.contains('بوق') || text.contains('كلاكس') || text.contains('هرن')) {
      return Icons.volume_up_rounded;
    }
    if (text.contains('starter') || text.contains('سلف') || text.contains('موتورينو') || text.contains('ign')) {
      return Icons.electric_bolt_rounded;
    }
    if (text.contains('brake') || text.contains('abs') || text.contains('esp') || text.contains('فرامل')) {
      return Icons.do_not_disturb_on_total_silence_rounded;
    }
    if (text.contains('airbag') || text.contains('srs') || text.contains('وسائد')) {
      return Icons.airline_seat_recline_normal_rounded;
    }
    return Icons.electric_meter_rounded;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final allSlots = widget.fuseBox.slots;

    final bladeSlots = allSlots
        .where((s) => !s.isRelay && !(s.isSpecial && s.ratingAmps >= 50) && s.ratingAmps < 80)
        .toList();
    final relaySlots = allSlots.where((s) => s.isRelay).toList();
    final megaSlots = allSlots
        .where((s) => !s.isRelay && ((s.isSpecial && s.ratingAmps >= 50) || s.ratingAmps >= 80))
        .toList();

    final hasCardMappings = widget.fuseBox.equipmentMappings.isNotEmpty;

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF070B12), // Deep automotive molded casing
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: widget.fuseBox.isSpecialLocation
              ? const Color(0xFFD4AF37)
              : const Color(0xFF1E293B),
          width: widget.fuseBox.isSpecialLocation ? 2.0 : 1.5,
        ),
        boxShadow: const [
          BoxShadow(
            color: Colors.black87,
            blurRadius: 18,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. Diagram Control Bar (Switch Authentic Card vs Tray vs Sticker)
          _buildControlBar(isDark, hasCardMappings),

          // Special Unique Location Gold Tag
          if (widget.fuseBox.isSpecialLocation)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
              color: const Color(0xFFD4AF37).withValues(alpha: 0.15),
              child: Row(
                children: [
                  const Icon(
                    Icons.stars_rounded,
                    size: 16,
                    color: Color(0xFFD4AF37),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      widget.fuseBox.specialBadgeText ??
                          'موقع فريد وحساس: مصهرات طاقة رئيسية لحماية شبكة السيارة.',
                      style: KashifTypography.arabic(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFFFFD54F),
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // 2. Main Content based on active mode
          if (_viewMode == FuseDiagramViewMode.card && hasCardMappings)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: AuthenticFuseCardWidget(
                fuseBox: widget.fuseBox,
                selectedSlot: widget.selectedSlot,
                onSlotTapped: widget.onSlotTapped,
                searchQuery: widget.searchQuery,
              ),
            )
          else
            ClipRRect(
              child: Container(
                color: _viewMode == FuseDiagramViewMode.sticker
                    ? const Color(0xFF0F172A)
                    : const Color(0xFF0A0F19),
                child: Stack(
                  children: [
                    // Tray Corner Hex Mounting Screws (4 corners)
                    if (_viewMode == FuseDiagramViewMode.tray) ...[
                      Positioned(top: 8, left: 8, child: _buildCornerScrew()),
                      Positioned(top: 8, right: 8, child: _buildCornerScrew()),
                      Positioned(bottom: 8, left: 8, child: _buildCornerScrew()),
                      Positioned(bottom: 8, right: 8, child: _buildCornerScrew()),
                    ],

                    // Main Canvas with Pinch-to-Zoom
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 12),
                      child: InteractiveViewer(
                        transformationController: _transformController,
                        minScale: 0.8,
                        maxScale: 3.0,
                        child: Center(
                          child: _viewMode == FuseDiagramViewMode.sticker
                              ? _buildStickerLayout(allSlots)
                              : _buildRealisticTrayLayout(
                                  bladeSlots: bladeSlots,
                                  relaySlots: relaySlots,
                                  megaSlots: megaSlots,
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          // 3. Live Mechanical HUD / Quick Inspector Banner
          _buildQuickDiagnosticHUD(isDark),
        ],
      ),
    );
  }

  /// Control Bar: Title, Toggle Mode, and Zoom Reset
  Widget _buildControlBar(bool isDark, bool hasCardMappings) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: const BoxDecoration(
        color: Color(0xFF111827),
        borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
      ),
      child: Row(
        children: [
          Icon(
            _viewMode == FuseDiagramViewMode.card
                ? Icons.badge_rounded
                : (_viewMode == FuseDiagramViewMode.sticker
                    ? Icons.assignment_rounded
                    : Icons.grid_view_rounded),
            size: 16,
            color: const Color(0xFFD4AF37),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _viewMode == FuseDiagramViewMode.card
                  ? 'بطاقة الوكالة الأصلية المطبوعة (مثل الصورة):'
                  : (_viewMode == FuseDiagramViewMode.sticker
                      ? 'ملصق غطاء الفيوزات بالعربي (Lid Label):'
                      : 'خريطة ومخطط العلبة الهندسي (الواقعي):'),
              style: KashifTypography.arabic(
                fontSize: 11.5,
                fontWeight: FontWeight.w800,
                color: const Color(0xFFE2E8F0),
              ),
            ),
          ),

          // Toggle View Pills
          if (hasCardMappings)
            _buildModePill(
              title: 'بطاقة الوكالة',
              mode: FuseDiagramViewMode.card,
              icon: Icons.assignment_rounded,
            ),
          const SizedBox(width: 4),
          _buildModePill(
            title: 'المجسم',
            mode: FuseDiagramViewMode.tray,
            icon: Icons.grid_view_rounded,
          ),
          const SizedBox(width: 4),
          _buildModePill(
            title: 'الملصق',
            mode: FuseDiagramViewMode.sticker,
            icon: Icons.translate_rounded,
          ),
          const SizedBox(width: 6),

          // Zoom Reset
          if (_viewMode != FuseDiagramViewMode.card)
            IconButton(
              icon: const Icon(Icons.restart_alt_rounded, size: 16),
              tooltip: 'إعادة ضبط الحجم',
              color: const Color(0xFF94A3B8),
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 26, minHeight: 26),
              onPressed: _resetZoom,
            ),
        ],
      ),
    );
  }

  Widget _buildModePill({
    required String title,
    required FuseDiagramViewMode mode,
    required IconData icon,
  }) {
    final isSelected = _viewMode == mode;
    return InkWell(
      onTap: () {
        setState(() {
          _viewMode = mode;
        });
      },
      borderRadius: BorderRadius.circular(6),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFFD4AF37).withValues(alpha: 0.25)
              : const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: isSelected
                ? const Color(0xFFD4AF37)
                : const Color(0xFF334155),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 12,
              color: isSelected
                  ? const Color(0xFFD4AF37)
                  : const Color(0xFF94A3B8),
            ),
            const SizedBox(width: 4),
            Text(
              title,
              style: KashifTypography.arabic(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                color: isSelected
                    ? const Color(0xFFD4AF37)
                    : const Color(0xFF94A3B8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Authentic Realistic Automotive Tray with Partitioned Compartments
  Widget _buildRealisticTrayLayout({
    required List<FuseSlot> bladeSlots,
    required List<FuseSlot> relaySlots,
    required List<FuseSlot> megaSlots,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // 1. Relays & High Power Section (if any exist)
        if (relaySlots.isNotEmpty || megaSlots.isNotEmpty) ...[
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF0D1422), // Molded inner compartment
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFF1F293D), width: 1.5),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.power_rounded,
                      size: 12,
                      color: Color(0xFFD4AF37),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'قسم كتاوت الريليهات وفيوزات القدرة الرئيسية:',
                      style: KashifTypography.arabic(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF94A3B8),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  alignment: WrapAlignment.center,
                  children: [
                    ...megaSlots.map((slot) {
                      final isSelected =
                          widget.selectedSlot?.slotId == slot.slotId;
                      return _buildRealisticFuseCell(slot, isSelected);
                    }),
                    ...relaySlots.map((slot) {
                      final isSelected =
                          widget.selectedSlot?.slotId == slot.slotId;
                      return _buildRealisticFuseCell(slot, isSelected);
                    }),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
        ],

        // 2. Standard & Mini Blade Fuses Section
        if (bladeSlots.isNotEmpty) ...[
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF0D1422),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFF1F293D), width: 1.5),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.grid_3x3_rounded,
                          size: 12,
                          color: Color(0xFF38BDF8),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'قسم المصهرات الشفرية (Blade Fuses Matrix):',
                          style: KashifTypography.arabic(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF94A3B8),
                          ),
                        ),
                      ],
                    ),
                    // Realistic Plastic Fuse Puller Tool in its designated slot
                    _buildFusePullerSocket(),
                  ],
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  alignment: WrapAlignment.center,
                  children: bladeSlots.map((slot) {
                    final isSelected =
                        widget.selectedSlot?.slotId == slot.slotId;
                    return _buildRealisticFuseCell(slot, isSelected);
                  }).toList(),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  /// Stylized Molded Fuse Puller tool socket (ملقط الفيوزات البلاستيكي)
  Widget _buildFusePullerSocket() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: const Color(0xFF334155), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 12,
            decoration: BoxDecoration(
              color: const Color(0xFFFACC15), // Yellow plastic clip
              borderRadius: BorderRadius.circular(1.5),
            ),
          ),
          const SizedBox(width: 4),
          const Text(
            'FUSE PULLER',
            style: TextStyle(
              fontFamily: 'Courier',
              fontSize: 7.5,
              fontWeight: FontWeight.w900,
              color: Color(0xFF94A3B8),
            ),
          ),
        ],
      ),
    );
  }

  /// Stylized corner mounting screw for automotive look
  Widget _buildCornerScrew() {
    return Container(
      width: 9,
      height: 9,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFF475569),
        border: Border.all(color: const Color(0xFF94A3B8), width: 1),
        boxShadow: const [
          BoxShadow(
            color: Colors.black54,
            blurRadius: 2,
            offset: Offset(1, 1),
          ),
        ],
      ),
      child: Center(
        child: Container(
          width: 5,
          height: 1.2,
          color: const Color(0xFF1E293B),
        ),
      ),
    );
  }

  /// Realistic 3D Blade Fuse / Relay / Mega Fuse Cell
  Widget _buildRealisticFuseCell(FuseSlot slot, bool isSelected) {
    final fuseColor = Color(slot.colorValue);
    final isRelay = slot.isRelay;
    final isMega = (slot.isSpecial && slot.ratingAmps >= 50) || slot.ratingAmps >= 80;

    final cellWidth = isMega
        ? 114.0
        : (isRelay ? 96.0 : 72.0);
    final cellHeight = isMega
        ? 72.0
        : (isRelay ? 72.0 : 72.0);

    return InkWell(
      onTap: () => widget.onSlotTapped(slot),
      borderRadius: BorderRadius.circular(8),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: cellWidth,
        height: cellHeight,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(isRelay ? 6 : 8),
          // 3D Plastic Bevel Gradient
          gradient: isRelay
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: isSelected
                      ? [const Color(0xFF384A63), const Color(0xFF1E293B)]
                      : [const Color(0xFF263238), const Color(0xFF10171D)],
                )
              : LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    fuseColor.withValues(alpha: 0.95),
                    fuseColor,
                    fuseColor.withValues(alpha: 0.8),
                  ],
                  stops: const [0.0, 0.4, 1.0],
                ),
          border: Border.all(
            color: isSelected
                ? const Color(0xFFFFD700)
                : (isRelay
                    ? const Color(0xFF475569)
                    : Colors.white.withValues(alpha: 0.4)),
            width: isSelected ? 2.5 : 1.2,
          ),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: const Color(0xFFFFD700).withValues(alpha: 0.65),
                blurRadius: 12,
                spreadRadius: 2,
              )
            else
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.45),
                blurRadius: 5,
                offset: const Offset(0, 3),
              ),
          ],
        ),
        child: isRelay
            ? _buildRealisticRelayContent(slot, isSelected)
            : (isMega
                ? _buildRealisticMegaFuseContent(slot, isSelected)
                : _buildRealisticBladeFuseContent(slot, isSelected)),
      ),
    );
  }

  /// Blade Fuse: Translucent cap with dual silver probe test points + stamped Amp
  Widget _buildRealisticBladeFuseContent(FuseSlot slot, bool isSelected) {
    final textColor =
        slot.ratingAmps == 25 ? Colors.black87 : Colors.white;

    return Column(
      children: [
        // Top Edge with Dual Silver Test Probe Points (مجسات الفحص)
        Container(
          height: 12,
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1.5),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.25),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(7)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildProbePin(),
              Flexible(
                child: Text(
                  slot.slotId,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'Courier',
                    fontSize: 8.5,
                    fontWeight: FontWeight.w900,
                    color: textColor,
                  ),
                ),
              ),
              _buildProbePin(),
            ],
          ),
        ),

        const Spacer(),

        // Bold Stamped Automotive Amp Rating
        Text(
          '${slot.ratingAmps}',
          style: TextStyle(
            fontFamily: 'Courier',
            fontSize: 17,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.5,
            color: textColor,
            shadows: [
              Shadow(
                color: Colors.black.withValues(alpha: 0.6),
                blurRadius: 2,
                offset: const Offset(1, 1),
              ),
            ],
          ),
        ),

        // Circuit Label
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 3),
          child: Text(
            slot.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Courier',
              fontSize: 8.5,
              fontWeight: FontWeight.w800,
              color: textColor.withValues(alpha: 0.9),
            ),
          ),
        ),

        const Spacer(),

        // Bottom Grip Ridge
        Container(
          height: 3,
          margin: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.35),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(height: 3),
      ],
    );
  }

  /// Silver metallic test probe hole on top of blade fuse
  Widget _buildProbePin() {
    return Container(
      width: 4.5,
      height: 4.5,
      decoration: BoxDecoration(
        color: const Color(0xFFD1D5DB),
        borderRadius: BorderRadius.circular(1),
        border: Border.all(color: const Color(0xFF9CA3AF), width: 0.5),
      ),
    );
  }

  /// Relay Block Content with engraved circuit terminal markings
  Widget _buildRealisticRelayContent(FuseSlot slot, bool isSelected) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 3.5),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  slot.slotId,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: 'Courier',
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF94A3B8),
                  ),
                ),
              ),
              const Icon(
                Icons.developer_board_rounded,
                size: 11,
                color: Color(0xFFD4AF37),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            slot.label,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontFamily: 'Courier',
              fontSize: 9.5,
              fontWeight: FontWeight.w900,
              color: Color(0xFFF8FAFC),
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 3),
          // Engraved Terminal Pins: 85 - 86 / 30 - 87
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1.5),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.35),
              borderRadius: BorderRadius.circular(3),
            ),
            child: const Text(
              '85 86 30 87',
              style: TextStyle(
                fontFamily: 'Courier',
                fontSize: 7.5,
                fontWeight: FontWeight.w700,
                color: Color(0xFFD4AF37),
                letterSpacing: 0.8,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Mega Fuse Content (Heavy duty bolt-down fuse)
  Widget _buildRealisticMegaFuseContent(FuseSlot slot, bool isSelected) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Left Brass Lug
          _buildBoltLug(),
          const SizedBox(width: 4),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '${slot.ratingAmps}A MEGA',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: 'Courier',
                    fontSize: 9.0,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFFFFD54F),
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  slot.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: 'Courier',
                    fontSize: 8.0,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 4),
          // Right Brass Lug
          _buildBoltLug(),
        ],
      ),
    );
  }

  Widget _buildBoltLug() {
    return Container(
      width: 10,
      height: 24,
      decoration: BoxDecoration(
        color: const Color(0xFFD4AF37),
        borderRadius: BorderRadius.circular(2),
        border: Border.all(color: const Color(0xFFB8860B), width: 1),
      ),
      child: Center(
        child: Container(
          width: 4,
          height: 4,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Color(0xFF1E293B),
          ),
        ),
      ),
    );
  }

  /// 2. Arabic Lid Sticker Diagram (ملصق غطاء الفيوزات بالعربي)
  Widget _buildStickerLayout(List<FuseSlot> slots) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: WrapAlignment.center,
      children: slots.map((slot) {
        final isSelected = widget.selectedSlot?.slotId == slot.slotId;
        final fuseColor = Color(slot.colorValue);

        return InkWell(
          onTap: () => widget.onSlotTapped(slot),
          borderRadius: BorderRadius.circular(8),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 108,
            height: 72,
            padding: const EdgeInsets.all(5.5),
            decoration: BoxDecoration(
              color: isSelected
                  ? const Color(0xFF1E293B)
                  : const Color(0xFF0F172A),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isSelected
                    ? const Color(0xFFFFD700)
                    : const Color(0xFF334155),
                width: isSelected ? 2.0 : 1.0,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top: Slot ID & Amp color pill
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        slot.slotId,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: 'Courier',
                          fontSize: 9.0,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFFD4AF37),
                        ),
                      ),
                    ),
                    const SizedBox(width: 2),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 3.5, vertical: 1),
                      decoration: BoxDecoration(
                        color: fuseColor,
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: Text(
                        '${slot.ratingAmps}A',
                        style: TextStyle(
                          fontFamily: 'Courier',
                          fontSize: 7.5,
                          fontWeight: FontWeight.w900,
                          color: slot.ratingAmps == 25
                              ? Colors.black87
                              : Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                const Spacer(),

                // Icon + Arabic Name
                Row(
                  children: [
                    Icon(
                      _getSlotIcon(slot),
                      size: 13,
                      color: const Color(0xFF94A3B8),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        slot.nameArabic,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: KashifTypography.arabic(
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: isSelected
                              ? Colors.white
                              : const Color(0xFFCBD5E1),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  /// 3. Live Mechanical Diagnostic HUD / Quick Inspector Banner
  Widget _buildQuickDiagnosticHUD(bool isDark) {
    final slot = widget.selectedSlot;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: const BoxDecoration(
        color: Color(0xFF0F1728),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(15)),
        border: Border(
          top: BorderSide(
            color: Color(0xFF1E293B),
            width: 1,
          ),
        ),
      ),
      child: slot == null
          ? Row(
              children: [
                const Icon(
                  Icons.touch_app_rounded,
                  size: 16,
                  color: Color(0xFFD4AF37),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'المس أي فيوز أو ريلي في الخريطة لمعاينة أمبيره ووظيفته وأعراض تلفه فورا.',
                    style: KashifTypography.arabic(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF94A3B8),
                    ),
                  ),
                ),
              ],
            )
          : Row(
              children: [
                // Amp Badge
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                  decoration: BoxDecoration(
                    color: Color(slot.colorValue),
                    borderRadius: BorderRadius.circular(6),
                    boxShadow: [
                      BoxShadow(
                        color: Color(slot.colorValue).withValues(alpha: 0.5),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        slot.slotId,
                        style: TextStyle(
                          fontFamily: 'Courier',
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                          color: slot.ratingAmps == 25
                              ? Colors.black87
                              : Colors.white,
                        ),
                      ),
                      Text(
                        '${slot.ratingAmps}A',
                        style: TextStyle(
                          fontFamily: 'Courier',
                          fontSize: 11,
                          fontWeight: FontWeight.w900,
                          color: slot.ratingAmps == 25
                              ? Colors.black87
                              : Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),

                // Name & Main Symptom
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '${slot.label}: ${slot.nameArabic}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: KashifTypography.arabic(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        slot.symptoms.isNotEmpty
                            ? 'العَرَض: ${slot.symptoms.first}'
                            : slot.descriptionArabic,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: KashifTypography.arabic(
                          fontSize: 10.5,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFFF87171),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 6),
                // Tap to view full sheet
                InkWell(
                  onTap: () => widget.onSlotTapped(slot),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD4AF37).withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: const Color(0xFFD4AF37).withValues(alpha: 0.5),
                      ),
                    ),
                    child: Text(
                      'التفاصيل كاملة',
                      style: KashifTypography.arabic(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFFD4AF37),
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
