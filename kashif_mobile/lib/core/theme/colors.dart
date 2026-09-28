import 'package:flutter/material.dart';

/// ISO/DIN 72581-3 Blade-fuse color specification and Fuse-Box Lid design tokens.
class KashifColors {
  // Brand Signature: Royal Blue & Luxury Gold (matching the Flow Cars logo)
  static const Color royalBlue = Color(0xFF15489D);
  static const Color royalBlueLight = Color(0xFF2563EB);
  static const Color royalBlueElectric = Color(
    0xFF38BDF8,
  ); // Logo neon circuit glow
  static const Color royalBlueDark = Color(0xFF0F3B82); // Dark Royal Blue
  static const Color royalBlueDeep = Color(0xFF070E1E); // Midnight Royal Navy

  // Luxury Gold
  static const Color goldPrimary = Color(0xFFD4AF37); // Classic Metallic Gold
  static const Color goldLight = Color(0xFFF5C84C); // Sunburst Bright Gold
  static const Color goldDark = Color(0xFFA67C1E); // Burnished Royal Gold
  static const Color goldGlow = Color(0x33D4AF37); // Subtle gold radiance

  // Blade Fuse Tiers (ISO/DIN 72581-3)
  // 10A Red (Critical)
  static const Color fuse10ATab = Color(0xFFDE3B2F);
  static const Color fuse10AInkLight = Color(0xFFA81F15);
  static const Color fuse10AInkDark = Color(0xFFFF6B5E);

  // 20A Yellow / Gold (Moderate)
  static const Color fuse20ATab = Color(0xFFF2C200);
  static const Color fuse20AInkLight = Color(0xFFA67C1E);
  static const Color fuse20AInkDark = Color(0xFFF5C84C);

  // 30A Green (Passed / Healthy)
  static const Color fuse30ATab = Color(0xFF2E9E5B);
  static const Color fuse30AInkLight = Color(0xFF125B2F);
  static const Color fuse30AInkDark = Color(0xFF4ADE80);

  // 25A Grey (History / Stored)
  static const Color fuse25ATab = Color(0xFFC8CBC5);
  static const Color fuse25AInkLight = Color(0xFF565C59);
  static const Color fuse25AInkDark = Color(0xFF9CA3AF);

  // 15A Blue (Interactive / Primary Action)
  static const Color fuse15ATab = Color(0xFF2E7FC4);
  static const Color fuse15AInkLight = Color(0xFF103B8F); // Rich Royal Navy
  static const Color fuse15AInkDark = Color(
    0xFF38BDF8,
  ); // Electric Circuit Blue

  // Light Lid (Royal Daylight) Board Tokens
  static const Color lightBoard = Color(0xFFF0F4FA);
  static const Color lightCell = Color(0xFFFFFFFF);
  static const Color lightCellSubtle = Color(0xFFF5F8FD);
  static const Color lightRib = Color(0xFFD2E0F2);
  static const Color lightRibLit = Color(0xFFFFFFFF);
  static const Color lightTextPrimary = Color(0xFF0B1938);
  static const Color lightTextMuted = Color(0xFF4C658D);
  static const Color lightBorder = Color(0xFFCAD8EC);

  // Dark Lid (Royal Midnight Bay) Board Tokens
  static const Color darkBoard = Color(0xFF070E1E);
  static const Color darkCell = Color(0xFF0E1C38);
  static const Color darkCellSubtle = Color(0xFF15274D);
  static const Color darkRib = Color(0xFF040812);
  static const Color darkRibLit = Color(0xFF1C3462);
  static const Color darkTextPrimary = Color(0xFFF8FAFC);
  static const Color darkTextMuted = Color(0xFF8EA6CE);
  static const Color darkBorder = Color(0xFF1D3564);
}
