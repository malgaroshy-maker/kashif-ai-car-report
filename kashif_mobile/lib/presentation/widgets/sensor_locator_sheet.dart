import 'package:flutter/material.dart';
import '../../core/theme/colors.dart';
import '../../core/theme/typography.dart';
import '../../data/models/fault_code.dart';
import '../../data/repositories/sensor_locator_service.dart';
import 'fuse_cell.dart';

/// Modal bottom sheet showing the sensor location in the engine bay,
/// fuse specifications, and multimeter testing pinouts.
class SensorLocatorSheet extends StatefulWidget {
  final DiagnosticFaultCode fault;
  final String? vehicleMake;
  final String? vehicleModel;

  const SensorLocatorSheet({
    super.key,
    required this.fault,
    this.vehicleMake,
    this.vehicleModel,
  });

  static void show(
    BuildContext context, {
    required DiagnosticFaultCode fault,
    String? vehicleMake,
    String? vehicleModel,
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => SensorLocatorSheet(
        fault: fault,
        vehicleMake: vehicleMake,
        vehicleModel: vehicleModel,
      ),
    );
  }

  @override
  State<SensorLocatorSheet> createState() => _SensorLocatorSheetState();
}

class _SensorLocatorSheetState extends State<SensorLocatorSheet>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.85, end: 1.25).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final f = widget.fault;
    final diag = SensorLocatorService.getDiagnostics(
      f.code,
      vehicleMake: widget.vehicleMake,
      module: f.module,
    );

    return DraggableScrollableSheet(
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: isDark ? KashifColors.darkBoard : KashifColors.lightBoard,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
            border: Border.all(
              color: isDark ? KashifColors.darkBorder : KashifColors.lightBorder,
            ),
          ),
          child: Column(
            children: [
              // Grab handle
              Container(
                margin: const EdgeInsets.only(top: 10, bottom: 6),
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: isDark ? Colors.white24 : Colors.black26,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Sheet title bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                child: Row(
                  children: [
                    Icon(
                      Icons.electric_bolt_rounded,
                      color: isDark ? KashifColors.fuse20AInkDark : KashifColors.fuse20AInkLight,
                      size: 22,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'خريطة الحساس والفيوز (الأفوميتر)',
                      style: KashifTypography.arabic(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: isDark ? KashifColors.darkTextPrimary : KashifColors.lightTextPrimary,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close_rounded),
                      onPressed: () => Navigator.pop(context),
                      tooltip: 'إغلاق',
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),

              // Sheet content
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(16),
                  children: [
                    // Code & Title Header
                    _buildHeader(f, isDark),
                    const SizedBox(height: 14),

                    // Safety Warning if present
                    if (diag.warning != null) ...[
                      _buildWarningBox(diag.warning!, isDark),
                      const SizedBox(height: 14),
                    ],

                    // Engine Bay Interactive Map
                    _buildEngineBayMap(diag.sensorLocation, isDark),
                    const SizedBox(height: 14),

                    // Fuse Section
                    _buildFuseSection(diag.fuseInfo, isDark),
                    const SizedBox(height: 14),

                    // Multimeter Pinout Guide
                    _buildMultimeterSection(diag.multimeterTest, isDark),
                    const SizedBox(height: 14),

                    // Mechanic Disclaimer Note
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: isDark ? KashifColors.darkCell : KashifColors.lightCell,
                        borderRadius: BorderRadius.circular(2),
                        border: Border.all(
                          color: isDark ? KashifColors.darkRib : KashifColors.lightRib,
                        ),
                      ),
                      child: Text(
                        '💡 ملاحظة هامة: افحص الفيوز والفيشة بالأفوميتر قبل شراء أي قطعة جديدة. ترتيب الفيوزات المطبوع على غطاء العلبة في سيارتك هو المرجع الأكيد للوكالة.',
                        style: KashifTypography.arabic(
                          fontSize: 11,
                          color: isDark ? KashifColors.darkTextMuted : KashifColors.lightTextMuted,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(DiagnosticFaultCode f, bool isDark) {
    return FuseCell(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isDark ? KashifColors.darkBoard : KashifColors.lightBoard,
                  borderRadius: BorderRadius.circular(2),
                  border: Border.all(
                    color: isDark ? KashifColors.darkBorder : KashifColors.lightBorder,
                  ),
                ),
                child: Text(
                  f.code,
                  style: KashifTypography.mono(
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                decoration: BoxDecoration(
                  color: (isDark ? KashifColors.fuse15AInkDark : KashifColors.fuse15AInkLight)
                      .withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(2),
                ),
                child: Text(
                  f.moduleNameArabic.isNotEmpty ? f.moduleNameArabic : f.module,
                  style: KashifTypography.arabic(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: isDark ? KashifColors.fuse15AInkDark : KashifColors.fuse15AInkLight,
                  ),
                ),
              ),
              const Spacer(),
              if (widget.vehicleMake != null)
                Text(
                  '${widget.vehicleMake} ${widget.vehicleModel ?? ""}',
                  style: KashifTypography.arabic(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: isDark ? KashifColors.darkTextMuted : KashifColors.lightTextMuted,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            f.libyanTerm,
            style: KashifTypography.arabic(
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: isDark ? KashifColors.darkTextPrimary : KashifColors.lightTextPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWarningBox(String warning, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF3B1E1E) : const Color(0xFFFDE8E8),
        borderRadius: BorderRadius.circular(2),
        border: Border.all(
          color: isDark ? KashifColors.fuse10AInkDark : KashifColors.fuse10AInkLight,
          width: 1.2,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.warning_amber_rounded,
            color: isDark ? KashifColors.fuse10AInkDark : KashifColors.fuse10AInkLight,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              warning,
              style: KashifTypography.arabic(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: isDark ? KashifColors.fuse10AInkDark : KashifColors.fuse10AInkLight,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEngineBayMap(SensorLocationData loc, bool isDark) {
    return FuseCell(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.location_searching_rounded,
                size: 18,
                color: isDark ? KashifColors.fuse15AInkDark : KashifColors.fuse15AInkLight,
              ),
              const SizedBox(width: 6),
              Text(
                'خريطة حوض المحرك ومكان التموضع',
                style: KashifTypography.arabic(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: isDark ? KashifColors.darkTextPrimary : KashifColors.lightTextPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Engine Bay Schematic Canvas Container
          Container(
            height: 190,
            width: double.infinity,
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF14191F) : const Color(0xFFE8EEF5),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(
                color: isDark ? KashifColors.darkBorder : KashifColors.lightBorder,
              ),
            ),
            child: Stack(
              children: [
                // Visual Schematic of Engine Bay Components
                CustomPaint(
                  size: Size.infinite,
                  painter: _EngineBaySchematicPainter(isDark: isDark),
                ),

                // Pulsating Marker
                if (loc.coordinateX != null && loc.coordinateY != null)
                  Positioned(
                    left: (loc.coordinateX! / 100) * 280, // approximate width
                    top: (loc.coordinateY! / 100) * 160,
                    child: AnimatedBuilder(
                      animation: _pulseAnimation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _pulseAnimation.value,
                          child: Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: KashifColors.fuse10ATab.withValues(alpha: 0.35),
                              border: Border.all(
                                color: KashifColors.fuse10ATab,
                                width: 2,
                              ),
                            ),
                            child: const Center(
                              child: Icon(
                                Icons.pin_drop_rounded,
                                size: 16,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),

                // Front Indicator
                Positioned(
                  top: 6,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: (isDark ? Colors.black : Colors.white).withValues(alpha: 0.7),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '▲ مقدمة السيارة (الرادياتير والشبك الأمامي) ▲',
                        style: KashifTypography.arabic(fontSize: 9, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),

                // Cabin Indicator
                Positioned(
                  bottom: 4,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Text(
                      '▼ صدر الكابينة والزجاج الأمامي ▼',
                      style: KashifTypography.arabic(
                        fontSize: 9,
                        color: isDark ? Colors.white38 : Colors.black38,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),

          // Area Name & Disassembly Tip
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'المنطقة: ',
                style: KashifTypography.arabic(fontSize: 12, fontWeight: FontWeight.bold),
              ),
              Expanded(
                child: Text(
                  loc.areaName,
                  style: KashifTypography.arabic(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: isDark ? KashifColors.fuse15AInkDark : KashifColors.fuse15AInkLight,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'الفك والوصول: ',
                style: KashifTypography.arabic(fontSize: 12, fontWeight: FontWeight.bold),
              ),
              Expanded(
                child: Text(
                  loc.accessTip,
                  style: KashifTypography.arabic(fontSize: 12),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFuseSection(FuseInfoData fuse, bool isDark) {
    return FuseCell(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.check_box_outline_blank_rounded,
                size: 18,
                color: isDark ? KashifColors.fuse20AInkDark : KashifColors.fuse20AInkLight,
              ),
              const SizedBox(width: 6),
              Text(
                'الفيوز والعلبة المسؤولة',
                style: KashifTypography.arabic(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: isDark ? KashifColors.darkTextPrimary : KashifColors.lightTextPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _buildInfoRow('موقع علبة الفيوزات:', fuse.boxLocation, isDark),
          _buildInfoRow('رقم الفيوز:', fuse.fuseNumber, isDark, mono: true),
          _buildInfoRow('قوة الفيوز (الأمبير):', fuse.rating, isDark, mono: true),
          if (fuse.relayName != null)
            _buildInfoRow('الكتاوت المرتبط:', fuse.relayName!, isDark),
          _buildInfoRow('الدائرة الكهربائية:', fuse.circuitDescription, isDark),
        ],
      ),
    );
  }

  Widget _buildMultimeterSection(MultimeterTestData multi, bool isDark) {
    return FuseCell(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.speed_rounded,
                size: 18,
                color: isDark ? KashifColors.fuse30AInkDark : KashifColors.fuse30AInkLight,
              ),
              const SizedBox(width: 6),
              Text(
                'دليل قياس الأفوميتر (فحص الفيشة والأسلاك)',
                style: KashifTypography.arabic(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: isDark ? KashifColors.darkTextPrimary : KashifColors.lightTextPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          _buildInfoRow('خط الكهرباء (+):', multi.powerPin, isDark, mono: true),
          _buildInfoRow('خط الأرضي (-):', multi.groundPin, isDark, mono: true),
          _buildInfoRow('خط الإشارة (Signal):', multi.signalPin, isDark, mono: true),
          if (multi.referenceVoltage != null)
            _buildInfoRow('الجهد المرجعي (Ref):', multi.referenceVoltage!, isDark, mono: true),
          const Divider(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'طريقة الفحص عند الأسطى: ',
                style: KashifTypography.arabic(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: isDark ? KashifColors.fuse30AInkDark : KashifColors.fuse30AInkLight,
                ),
              ),
              Expanded(
                child: Text(
                  multi.testingTipLibyan,
                  style: KashifTypography.arabic(fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, bool isDark, {bool mono = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: KashifTypography.arabic(
                fontSize: 12,
                color: isDark ? KashifColors.darkTextMuted : KashifColors.lightTextMuted,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: mono
                  ? KashifTypography.mono(fontSize: 12, fontWeight: FontWeight.bold)
                  : KashifTypography.arabic(fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

/// Custom painter to draw a clean top-down outline of an engine bay
class _EngineBaySchematicPainter extends CustomPainter {
  final bool isDark;

  _EngineBaySchematicPainter({required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final borderPaint = Paint()
      ..color = isDark ? Colors.white12 : Colors.black12
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final blockPaint = Paint()
      ..color = (isDark ? const Color(0xFF1E2833) : const Color(0xFFD6E2EE))
      ..style = PaintingStyle.fill;

    final fuseBoxPaint = Paint()
      ..color = (isDark ? const Color(0xFF2E3D4A) : const Color(0xFFBACEDB))
      ..style = PaintingStyle.fill;

    // Engine Block in center
    final blockRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(size.width * 0.5, size.height * 0.52),
        width: size.width * 0.38,
        height: size.height * 0.44,
      ),
      const Radius.circular(6),
    );
    canvas.drawRRect(blockRect, blockPaint);
    canvas.drawRRect(blockRect, borderPaint);

    // Battery / Fuse box on left
    final fuseRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(size.width * 0.12, size.height * 0.30, size.width * 0.18, size.height * 0.28),
      const Radius.circular(4),
    );
    canvas.drawRRect(fuseRect, fuseBoxPaint);
    canvas.drawRRect(fuseRect, borderPaint);

    // Air filter box on right
    final airRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(size.width * 0.70, size.height * 0.28, size.width * 0.20, size.height * 0.32),
      const Radius.circular(4),
    );
    canvas.drawRRect(airRect, fuseBoxPaint);
    canvas.drawRRect(airRect, borderPaint);

    // Radiator on top
    final radRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(size.width * 0.22, size.height * 0.14, size.width * 0.56, size.height * 0.08),
      const Radius.circular(2),
    );
    canvas.drawRRect(radRect, fuseBoxPaint);
    canvas.drawRRect(radRect, borderPaint);

    // Wheels on sides
    final leftWheel = Rect.fromLTWH(size.width * 0.02, size.height * 0.45, size.width * 0.06, size.height * 0.30);
    final rightWheel = Rect.fromLTWH(size.width * 0.92, size.height * 0.45, size.width * 0.06, size.height * 0.30);
    canvas.drawRect(leftWheel, fuseBoxPaint);
    canvas.drawRect(rightWheel, fuseBoxPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
