import 'package:flutter/material.dart';
import 'dart:math' as math;

/// Renders authentic, true-to-life ISO 7000 / SAE automotive dashboard symbols
class CarDashboardSymbol extends StatelessWidget {
  final String symbolId;
  final Color color;
  final double size;

  const CarDashboardSymbol({
    super.key,
    required this.symbolId,
    required this.color,
    this.size = 28.0,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _DashboardSymbolPainter(symbolId: symbolId, color: color),
      ),
    );
  }
}

class _DashboardSymbolPainter extends CustomPainter {
  final String symbolId;
  final Color color;

  _DashboardSymbolPainter({required this.symbolId, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;

    final fillPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    final strokePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = math.max(1.6, w * 0.075)
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..isAntiAlias = true;

    switch (symbolId) {
      case 'oil_pressure':
        _drawOilCan(canvas, size, fillPaint, strokePaint);
        break;
      case 'check_engine':
        _drawCheckEngine(canvas, size, fillPaint, strokePaint);
        break;
      case 'coolant_temp':
        _drawCoolantTemp(canvas, size, fillPaint, strokePaint);
        break;
      case 'battery_charge':
        _drawBattery(canvas, size, fillPaint, strokePaint);
        break;
      case 'abs_system':
        _drawAbs(canvas, size, strokePaint);
        break;
      case 'brake_system':
        _drawBrakeWarning(canvas, size, fillPaint, strokePaint);
        break;
      case 'tpms_pressure':
        _drawTpms(canvas, size, fillPaint, strokePaint);
        break;
      case 'esp_tcs':
        _drawEspTcs(canvas, size, fillPaint, strokePaint);
        break;
      case 'airbag_srs':
        _drawAirbag(canvas, size, fillPaint, strokePaint);
        break;
      case 'steering_eps':
        _drawSteeringEps(canvas, size, fillPaint, strokePaint);
        break;
      case 'trans_temp':
        _drawTransTemp(canvas, size, fillPaint, strokePaint);
        break;
      case 'glow_dpf':
        _drawGlowPlug(canvas, size, strokePaint);
        break;
      case 'brake_pads':
        _drawBrakePads(canvas, size, strokePaint);
        break;
      case 'fuel_cap':
        _drawFuelCap(canvas, size, fillPaint, strokePaint);
        break;
      case 'washer_fluid':
        _drawWasherFluid(canvas, size, fillPaint, strokePaint);
        break;
      case 'high_beam':
        _drawHighBeam(canvas, size, fillPaint, strokePaint);
        break;
      case 'cruise_control':
        _drawCruiseControl(canvas, size, strokePaint);
        break;
      case 'eco_mode':
        _drawEcoMode(canvas, size, fillPaint, strokePaint);
        break;
      default:
        _drawGenericWarning(canvas, size, fillPaint, strokePaint);
    }
  }

  /// 1. Authentic ISO Oil Can (إبريق الزيت مع قطرة الزيت)
  void _drawOilCan(Canvas canvas, Size size, Paint fill, Paint stroke) {
    final w = size.width;
    final h = size.height;

    // Oil can body with spout and handle
    final path = Path();
    // Start at bottom left of can body
    path.moveTo(w * 0.18, h * 0.72);
    // Flat bottom
    path.lineTo(w * 0.68, h * 0.72);
    // Right wall curving up into neck
    path.quadraticBezierTo(w * 0.72, h * 0.58, w * 0.76, h * 0.44);
    // Long spout shooting to the right and tilting up
    path.lineTo(w * 0.94, h * 0.38);
    // Spout lip
    path.lineTo(w * 0.94, h * 0.33);
    // Top line of spout returning to can top
    path.lineTo(w * 0.66, h * 0.40);
    // Can top lid
    path.lineTo(w * 0.38, h * 0.40);
    // Left shoulder
    path.quadraticBezierTo(w * 0.22, h * 0.42, w * 0.18, h * 0.56);
    path.close();

    canvas.drawPath(path, fill);

    // Can cap / filler plug on top left
    canvas.drawRect(
      Rect.fromLTWH(w * 0.34, h * 0.32, w * 0.12, h * 0.08),
      fill,
    );

    // Curved handle on the left
    final handle = Path();
    handle.moveTo(w * 0.20, h * 0.46);
    handle.cubicTo(w * 0.02, h * 0.46, w * 0.02, h * 0.68, w * 0.20, h * 0.68);
    canvas.drawPath(handle, stroke);

    // Oil droplet dripping from spout tip
    final drop = Path();
    drop.moveTo(w * 0.92, h * 0.46);
    drop.quadraticBezierTo(w * 0.86, h * 0.58, w * 0.90, h * 0.62);
    drop.arcToPoint(
      Offset(w * 0.95, h * 0.62),
      radius: Radius.circular(w * 0.04),
      clockwise: true,
    );
    drop.quadraticBezierTo(w * 0.97, h * 0.58, w * 0.92, h * 0.46);
    drop.close();
    canvas.drawPath(drop, fill);
  }

  /// 2. Authentic ISO Check Engine Block (شكل محرك السيارة المعياري)
  void _drawCheckEngine(Canvas canvas, Size size, Paint fill, Paint stroke) {
    final w = size.width;
    final h = size.height;

    final path = Path();
    // Air intake / top filter snout
    path.moveTo(w * 0.10, h * 0.42);
    path.lineTo(w * 0.20, h * 0.42);
    path.lineTo(w * 0.20, h * 0.30);
    path.lineTo(w * 0.42, h * 0.30);
    // Valve cover step
    path.lineTo(w * 0.42, h * 0.22);
    path.lineTo(w * 0.70, h * 0.22);
    path.lineTo(w * 0.70, h * 0.34);
    // Fan / front pulley bracket
    path.lineTo(w * 0.88, h * 0.34);
    path.lineTo(w * 0.88, h * 0.46);
    path.lineTo(w * 0.96, h * 0.52);
    path.lineTo(w * 0.96, h * 0.74);
    path.lineTo(w * 0.88, h * 0.74);
    // Right bottom block
    path.lineTo(w * 0.88, h * 0.82);
    // Oil pan bottom
    path.lineTo(w * 0.34, h * 0.82);
    path.lineTo(w * 0.34, h * 0.72);
    path.lineTo(w * 0.20, h * 0.72);
    path.lineTo(w * 0.20, h * 0.56);
    path.lineTo(w * 0.10, h * 0.56);
    path.close();

    canvas.drawPath(path, fill);

    // Inner detail: fan pulley cutouts
    final cutPaint = Paint()
      ..color = const Color(0xFF070E1E)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset(w * 0.62, h * 0.54), w * 0.09, cutPaint);
    canvas.drawRect(
      Rect.fromLTWH(w * 0.32, h * 0.44, w * 0.14, h * 0.16),
      cutPaint,
    );
  }

  /// 3. Authentic ISO Coolant Temperature (ميزان الحرارة في أمواج الماء)
  void _drawCoolantTemp(Canvas canvas, Size size, Paint fill, Paint stroke) {
    final w = size.width;
    final h = size.height;

    // Thermometer stem & bulb
    final thermo = Path();
    // Bulb at bottom of thermometer
    thermo.addOval(
      Rect.fromCircle(center: Offset(w * 0.50, h * 0.56), radius: w * 0.14),
    );
    // Stem
    thermo.addRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.44, h * 0.12, w * 0.12, h * 0.46),
        Radius.circular(w * 0.06),
      ),
    );
    canvas.drawPath(thermo, fill);

    // Thermometer graduations (ticks on the right)
    canvas.drawLine(
      Offset(w * 0.60, h * 0.20),
      Offset(w * 0.72, h * 0.20),
      stroke,
    );
    canvas.drawLine(
      Offset(w * 0.60, h * 0.30),
      Offset(w * 0.70, h * 0.30),
      stroke,
    );
    canvas.drawLine(
      Offset(w * 0.60, h * 0.40),
      Offset(w * 0.72, h * 0.40),
      stroke,
    );

    // Wavy coolant liquid lines below
    final wave1 = Path();
    wave1.moveTo(w * 0.12, h * 0.76);
    wave1.quadraticBezierTo(w * 0.30, h * 0.68, w * 0.50, h * 0.76);
    wave1.quadraticBezierTo(w * 0.70, h * 0.84, w * 0.88, h * 0.76);
    canvas.drawPath(wave1, stroke);

    final wave2 = Path();
    wave2.moveTo(w * 0.18, h * 0.88);
    wave2.quadraticBezierTo(w * 0.36, h * 0.80, w * 0.54, h * 0.88);
    wave2.quadraticBezierTo(w * 0.72, h * 0.96, w * 0.84, h * 0.88);
    canvas.drawPath(wave2, stroke);
  }

  /// 4. Authentic ISO Battery (بطارية السيارة بأقطاب + و -)
  void _drawBattery(Canvas canvas, Size size, Paint fill, Paint stroke) {
    final w = size.width;
    final h = size.height;

    // Battery main box
    final rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.10, h * 0.28, w * 0.80, h * 0.58),
      Radius.circular(w * 0.06),
    );
    canvas.drawRRect(rrect, stroke);

    // Negative post on left top
    canvas.drawRect(
      Rect.fromLTWH(w * 0.24, h * 0.18, w * 0.16, h * 0.10),
      fill,
    );

    // Positive post on right top
    canvas.drawRect(
      Rect.fromLTWH(w * 0.60, h * 0.18, w * 0.16, h * 0.10),
      fill,
    );

    // Negative sign inside left side
    canvas.drawLine(
      Offset(w * 0.26, h * 0.57),
      Offset(w * 0.40, h * 0.57),
      stroke,
    );

    // Positive sign inside right side
    canvas.drawLine(
      Offset(w * 0.62, h * 0.57),
      Offset(w * 0.76, h * 0.57),
      stroke,
    );
    canvas.drawLine(
      Offset(w * 0.69, h * 0.48),
      Offset(w * 0.69, h * 0.66),
      stroke,
    );
  }

  /// 5. Authentic ISO ABS (قوسا الفرامل مع كلمة ABS الصريحة)
  void _drawAbs(Canvas canvas, Size size, Paint stroke) {
    final w = size.width;
    final h = size.height;

    // Left curved caliper shoe
    final leftShoe = Path();
    leftShoe.addArc(
      Rect.fromCircle(center: Offset(w * 0.5, h * 0.5), radius: w * 0.42),
      2.3,
      1.68,
    );
    canvas.drawPath(leftShoe, stroke);

    // Right curved caliper shoe
    final rightShoe = Path();
    rightShoe.addArc(
      Rect.fromCircle(center: Offset(w * 0.5, h * 0.5), radius: w * 0.42),
      -0.84,
      1.68,
    );
    canvas.drawPath(rightShoe, stroke);

    // Center circular rotor outline
    canvas.drawCircle(
      Offset(w * 0.5, h * 0.5),
      w * 0.30,
      Paint()
        ..color = color.withValues(alpha: 0.35)
        ..style = PaintingStyle.stroke
        ..strokeWidth = math.max(1.0, w * 0.04),
    );

    // Text "ABS"
    final textPainter = TextPainter(
      text: TextSpan(
        text: 'ABS',
        style: TextStyle(
          color: color,
          fontSize: w * 0.29,
          fontWeight: FontWeight.w900,
          fontFamily: 'sans-serif',
          letterSpacing: -0.5,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset((w - textPainter.width) / 2, (h - textPainter.height) / 2),
    );
  }

  /// 6. Authentic ISO Brake Warning (قوسا الفرامل مع علامة التعجب داخل دائرة)
  void _drawBrakeWarning(Canvas canvas, Size size, Paint fill, Paint stroke) {
    final w = size.width;
    final h = size.height;

    // Left caliper
    final leftShoe = Path();
    leftShoe.addArc(
      Rect.fromCircle(center: Offset(w * 0.5, h * 0.5), radius: w * 0.44),
      2.3,
      1.68,
    );
    canvas.drawPath(leftShoe, stroke);

    // Right caliper
    final rightShoe = Path();
    rightShoe.addArc(
      Rect.fromCircle(center: Offset(w * 0.5, h * 0.5), radius: w * 0.44),
      -0.84,
      1.68,
    );
    canvas.drawPath(rightShoe, stroke);

    // Inner circle
    canvas.drawCircle(Offset(w * 0.5, h * 0.5), w * 0.30, stroke);

    // Exclamation mark in center
    canvas.drawLine(
      Offset(w * 0.5, h * 0.32),
      Offset(w * 0.5, h * 0.56),
      stroke,
    );
    canvas.drawCircle(Offset(w * 0.5, h * 0.67), w * 0.05, fill);
  }

  /// 7. Authentic ISO TPMS (مقطع الإطار المسطح مع التجاويف السفلية وعلامة التعجب)
  void _drawTpms(Canvas canvas, Size size, Paint fill, Paint stroke) {
    final w = size.width;
    final h = size.height;

    final path = Path();
    // Left upper sidewall
    path.moveTo(w * 0.20, h * 0.26);
    path.cubicTo(w * 0.08, h * 0.40, w * 0.12, h * 0.70, w * 0.20, h * 0.78);
    // Flat bottom tire tread with notches
    path.lineTo(w * 0.26, h * 0.86);
    path.lineTo(w * 0.32, h * 0.78);
    path.lineTo(w * 0.44, h * 0.86);
    path.lineTo(w * 0.50, h * 0.78);
    path.lineTo(w * 0.56, h * 0.86);
    path.lineTo(w * 0.68, h * 0.78);
    path.lineTo(w * 0.74, h * 0.86);
    path.lineTo(w * 0.80, h * 0.78);
    // Right sidewall
    path.cubicTo(w * 0.88, h * 0.70, w * 0.92, h * 0.40, w * 0.80, h * 0.26);
    canvas.drawPath(path, stroke);

    // Exclamation mark in center
    canvas.drawLine(
      Offset(w * 0.5, h * 0.32),
      Offset(w * 0.5, h * 0.54),
      stroke,
    );
    canvas.drawCircle(Offset(w * 0.5, h * 0.65), w * 0.045, fill);
  }

  /// 8. Authentic ISO ESP / Traction Control (السيارة مع آثار الانزلاق المتعرجة)
  void _drawEspTcs(Canvas canvas, Size size, Paint fill, Paint stroke) {
    final w = size.width;
    final h = size.height;

    // Car silhouette from rear
    final car = Path();
    car.moveTo(w * 0.32, h * 0.44);
    car.lineTo(w * 0.40, h * 0.26);
    car.lineTo(w * 0.60, h * 0.26);
    car.lineTo(w * 0.68, h * 0.44);
    car.lineTo(w * 0.74, h * 0.46);
    car.lineTo(w * 0.74, h * 0.58);
    car.lineTo(w * 0.26, h * 0.58);
    car.lineTo(w * 0.26, h * 0.46);
    car.close();
    canvas.drawPath(car, fill);

    // Rear tires
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.24, h * 0.50, w * 0.08, h * 0.16),
        Radius.circular(w * 0.02),
      ),
      fill,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.68, h * 0.50, w * 0.08, h * 0.16),
        Radius.circular(w * 0.02),
      ),
      fill,
    );

    // Wavy tire skid tracks trailing below
    final track1 = Path();
    track1.moveTo(w * 0.28, h * 0.66);
    track1.cubicTo(w * 0.42, h * 0.72, w * 0.16, h * 0.82, w * 0.34, h * 0.94);
    canvas.drawPath(track1, stroke);

    final track2 = Path();
    track2.moveTo(w * 0.72, h * 0.66);
    track2.cubicTo(w * 0.86, h * 0.72, w * 0.58, h * 0.82, w * 0.76, h * 0.94);
    canvas.drawPath(track2, stroke);
  }

  /// 9. Authentic ISO Airbag SRS (الراكب الجالس وأمامه بالون الإيرباق المنتفخ)
  void _drawAirbag(Canvas canvas, Size size, Paint fill, Paint stroke) {
    final w = size.width;
    final h = size.height;

    // Driver head
    canvas.drawCircle(Offset(w * 0.32, h * 0.26), w * 0.10, fill);

    // Driver torso (seated back tilted)
    final body = Path();
    body.moveTo(w * 0.28, h * 0.38);
    body.lineTo(w * 0.38, h * 0.42);
    body.lineTo(w * 0.34, h * 0.78);
    body.lineTo(w * 0.22, h * 0.78);
    body.close();
    canvas.drawPath(body, fill);

    // Thighs / seated legs
    final legs = Path();
    legs.moveTo(w * 0.22, h * 0.74);
    legs.lineTo(w * 0.52, h * 0.74);
    legs.lineTo(w * 0.52, h * 0.84);
    legs.lineTo(w * 0.22, h * 0.84);
    legs.close();
    canvas.drawPath(legs, fill);

    // Seatback
    canvas.drawLine(
      Offset(w * 0.16, h * 0.24),
      Offset(w * 0.16, h * 0.88),
      stroke,
    );

    // Large Deployed Airbag (circle in front of chest)
    canvas.drawCircle(Offset(w * 0.72, h * 0.46), w * 0.22, stroke);
    canvas.drawCircle(Offset(w * 0.72, h * 0.46), w * 0.08, fill);
  }

  /// 10. Authentic ISO Electric Power Steering EPS (مقود دركسيون ومعه علامة تعجب)
  void _drawSteeringEps(Canvas canvas, Size size, Paint fill, Paint stroke) {
    final w = size.width;
    final h = size.height;

    // Steering wheel outer rim
    canvas.drawCircle(Offset(w * 0.44, h * 0.52), w * 0.36, stroke);

    // Center hub
    canvas.drawCircle(Offset(w * 0.44, h * 0.52), w * 0.10, fill);

    // 3 spokes
    canvas.drawLine(
      Offset(w * 0.12, h * 0.52),
      Offset(w * 0.34, h * 0.52),
      stroke,
    );
    canvas.drawLine(
      Offset(w * 0.54, h * 0.52),
      Offset(w * 0.76, h * 0.52),
      stroke,
    );
    canvas.drawLine(
      Offset(w * 0.44, h * 0.62),
      Offset(w * 0.44, h * 0.86),
      stroke,
    );

    // Exclamation mark on the right
    canvas.drawLine(
      Offset(w * 0.90, h * 0.30),
      Offset(w * 0.90, h * 0.58),
      stroke,
    );
    canvas.drawCircle(Offset(w * 0.90, h * 0.72), w * 0.045, fill);
  }

  /// 11. Authentic ISO Automatic Transmission Temp (ترس القير مع ميزان الحرارة الداخلي)
  void _drawTransTemp(Canvas canvas, Size size, Paint fill, Paint stroke) {
    final w = size.width;
    final h = size.height;

    // Outer gear teeth
    final gear = Path();
    const teeth = 8;
    final center = Offset(w * 0.5, h * 0.5);
    final rOuter = w * 0.44;
    final rInner = w * 0.34;

    for (int i = 0; i < teeth; i++) {
      final angle = (i * 2 * math.pi) / teeth;
      final nextAngle = ((i + 1) * 2 * math.pi) / teeth;
      final mid1 = angle + (nextAngle - angle) * 0.25;
      final mid2 = angle + (nextAngle - angle) * 0.75;

      if (i == 0) {
        gear.moveTo(
          center.dx + rInner * math.cos(angle),
          center.dy + rInner * math.sin(angle),
        );
      }
      gear.lineTo(
        center.dx + rOuter * math.cos(mid1),
        center.dy + rOuter * math.sin(mid1),
      );
      gear.lineTo(
        center.dx + rOuter * math.cos(mid2),
        center.dy + rOuter * math.sin(mid2),
      );
      gear.lineTo(
        center.dx + rInner * math.cos(nextAngle),
        center.dy + rInner * math.sin(nextAngle),
      );
    }
    gear.close();
    canvas.drawPath(gear, stroke);

    // Thermometer in center
    canvas.drawCircle(Offset(w * 0.5, h * 0.62), w * 0.09, fill);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.46, h * 0.32, w * 0.08, h * 0.28),
        Radius.circular(w * 0.04),
      ),
      fill,
    );
  }

  /// 12. Authentic ISO Diesel Glow Plug (الوشيعة / السبرنق الحلزوني)
  void _drawGlowPlug(Canvas canvas, Size size, Paint stroke) {
    final w = size.width;
    final h = size.height;

    // Classic twin/triple spiral loops
    final path = Path();
    path.moveTo(w * 0.12, h * 0.70);
    path.cubicTo(w * 0.12, h * 0.24, w * 0.36, h * 0.24, w * 0.36, h * 0.55);
    path.cubicTo(w * 0.36, h * 0.24, w * 0.62, h * 0.24, w * 0.62, h * 0.55);
    path.cubicTo(w * 0.62, h * 0.24, w * 0.88, h * 0.24, w * 0.88, h * 0.70);
    canvas.drawPath(path, stroke);
  }

  /// 13. Authentic ISO Brake Pad Wear (حلقات السفايف المتكسرة)
  void _drawBrakePads(Canvas canvas, Size size, Paint stroke) {
    final w = size.width;
    final h = size.height;

    // Calipers
    final leftShoe = Path();
    leftShoe.addArc(
      Rect.fromCircle(center: Offset(w * 0.5, h * 0.5), radius: w * 0.44),
      2.3,
      1.68,
    );
    canvas.drawPath(leftShoe, stroke);

    final rightShoe = Path();
    rightShoe.addArc(
      Rect.fromCircle(center: Offset(w * 0.5, h * 0.5), radius: w * 0.44),
      -0.84,
      1.68,
    );
    canvas.drawPath(rightShoe, stroke);

    // Inner dashed circle (3 segmented arcs)
    final arc1 = Path()
      ..addArc(
        Rect.fromCircle(center: Offset(w * 0.5, h * 0.5), radius: w * 0.26),
        0.2,
        1.6,
      );
    final arc2 = Path()
      ..addArc(
        Rect.fromCircle(center: Offset(w * 0.5, h * 0.5), radius: w * 0.26),
        2.3,
        1.6,
      );
    final arc3 = Path()
      ..addArc(
        Rect.fromCircle(center: Offset(w * 0.5, h * 0.5), radius: w * 0.26),
        4.4,
        1.6,
      );
    canvas.drawPath(arc1, stroke);
    canvas.drawPath(arc2, stroke);
    canvas.drawPath(arc3, stroke);
  }

  /// 14. Authentic ISO Fuel Cap (طرمبة الوقود مع الغطاء)
  void _drawFuelCap(Canvas canvas, Size size, Paint fill, Paint stroke) {
    final w = size.width;
    final h = size.height;

    // Fuel dispenser body
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.22, h * 0.28, w * 0.42, h * 0.58),
        Radius.circular(w * 0.05),
      ),
      fill,
    );

    // Dispenser top display cutout
    canvas.drawRect(
      Rect.fromLTWH(w * 0.28, h * 0.36, w * 0.30, h * 0.18),
      Paint()..color = const Color(0xFF070E1E),
    );

    // Hose & Nozzle on right
    final hose = Path();
    hose.moveTo(w * 0.64, h * 0.44);
    hose.quadraticBezierTo(w * 0.88, h * 0.44, w * 0.88, h * 0.62);
    hose.lineTo(w * 0.84, h * 0.78);
    canvas.drawPath(hose, stroke);
  }

  /// 15. Authentic ISO Washer Fluid (الزجاج الأمامي مع بخاخ الرش والمساحة)
  void _drawWasherFluid(Canvas canvas, Size size, Paint fill, Paint stroke) {
    final w = size.width;
    final h = size.height;

    // Windshield outline
    final glass = Path();
    glass.moveTo(w * 0.15, h * 0.78);
    glass.lineTo(w * 0.28, h * 0.28);
    glass.lineTo(w * 0.72, h * 0.28);
    glass.lineTo(w * 0.85, h * 0.78);
    glass.close();
    canvas.drawPath(glass, stroke);

    // Wiper blade line
    canvas.drawLine(
      Offset(w * 0.32, h * 0.68),
      Offset(w * 0.68, h * 0.42),
      stroke,
    );

    // Fluid spray droplets radiating up
    canvas.drawCircle(Offset(w * 0.50, h * 0.22), w * 0.04, fill);
    canvas.drawCircle(Offset(w * 0.40, h * 0.16), w * 0.035, fill);
    canvas.drawCircle(Offset(w * 0.60, h * 0.16), w * 0.035, fill);
  }

  /// 16. Authentic ISO High Beam (مصباح الرأس مع خطوط الإضاءة الأفقية المستقيمة)
  void _drawHighBeam(Canvas canvas, Size size, Paint fill, Paint stroke) {
    final w = size.width;
    final h = size.height;

    // D-shaped lamp housing on the right
    final lamp = Path();
    lamp.moveTo(w * 0.56, h * 0.24);
    lamp.cubicTo(w * 0.86, h * 0.24, w * 0.86, h * 0.76, w * 0.56, h * 0.76);
    lamp.close();
    canvas.drawPath(lamp, fill);

    // 5 horizontal light rays shooting forward to the left
    canvas.drawLine(
      Offset(w * 0.12, h * 0.26),
      Offset(w * 0.48, h * 0.26),
      stroke,
    );
    canvas.drawLine(
      Offset(w * 0.12, h * 0.38),
      Offset(w * 0.48, h * 0.38),
      stroke,
    );
    canvas.drawLine(
      Offset(w * 0.12, h * 0.50),
      Offset(w * 0.48, h * 0.50),
      stroke,
    );
    canvas.drawLine(
      Offset(w * 0.12, h * 0.62),
      Offset(w * 0.48, h * 0.62),
      stroke,
    );
    canvas.drawLine(
      Offset(w * 0.12, h * 0.74),
      Offset(w * 0.48, h * 0.74),
      stroke,
    );
  }

  /// 17. Authentic ISO Cruise Control (عداد السرعة مع مؤشر التثبيت)
  void _drawCruiseControl(Canvas canvas, Size size, Paint stroke) {
    final w = size.width;
    final h = size.height;

    // Speedometer dial arc
    final dial = Path();
    dial.addArc(
      Rect.fromCircle(center: Offset(w * 0.5, h * 0.54), radius: w * 0.38),
      2.6,
      4.4,
    );
    canvas.drawPath(dial, stroke);

    // Arrow pointer pointing to top-right
    final arrow = Path();
    arrow.moveTo(w * 0.50, h * 0.54);
    arrow.lineTo(w * 0.72, h * 0.32);
    canvas.drawPath(arrow, stroke);

    // Arrowhead
    final head = Path();
    head.moveTo(w * 0.62, h * 0.30);
    head.lineTo(w * 0.74, h * 0.30);
    head.lineTo(w * 0.74, h * 0.42);
    canvas.drawPath(head, stroke);
  }

  /// 18. Authentic ISO ECO Mode (ورقة الشجرة البيئية الدائرية)
  void _drawEcoMode(Canvas canvas, Size size, Paint fill, Paint stroke) {
    final w = size.width;
    final h = size.height;

    // Eco leaf
    final leaf = Path();
    leaf.moveTo(w * 0.20, h * 0.80);
    leaf.quadraticBezierTo(w * 0.18, h * 0.32, w * 0.80, h * 0.20);
    leaf.quadraticBezierTo(w * 0.82, h * 0.68, w * 0.20, h * 0.80);
    leaf.close();
    canvas.drawPath(leaf, fill);

    // Center vein in contrasting color
    final vein = Path();
    vein.moveTo(w * 0.24, h * 0.76);
    vein.quadraticBezierTo(w * 0.46, h * 0.52, w * 0.74, h * 0.26);
    canvas.drawPath(
      vein,
      Paint()
        ..color = const Color(0xFF070E1E)
        ..style = PaintingStyle.stroke
        ..strokeWidth = math.max(1.2, w * 0.05)
        ..strokeCap = StrokeCap.round,
    );
  }

  /// Generic warning fallback
  void _drawGenericWarning(Canvas canvas, Size size, Paint fill, Paint stroke) {
    final w = size.width;
    final h = size.height;

    final triangle = Path();
    triangle.moveTo(w * 0.50, h * 0.16);
    triangle.lineTo(w * 0.88, h * 0.82);
    triangle.lineTo(w * 0.12, h * 0.82);
    triangle.close();
    canvas.drawPath(triangle, stroke);

    canvas.drawLine(
      Offset(w * 0.50, h * 0.38),
      Offset(w * 0.50, h * 0.60),
      stroke,
    );
    canvas.drawCircle(Offset(w * 0.50, h * 0.72), w * 0.045, fill);
  }

  @override
  bool shouldRepaint(covariant _DashboardSymbolPainter oldDelegate) {
    return oldDelegate.symbolId != symbolId || oldDelegate.color != color;
  }
}
