import 'package:flutter/material.dart';

/// ISO/DIN 72581-3 Blade-fuse color specification and Fuse-Box Lid design tokens.
class KashifColors {
  // Blade Fuse Tiers (ISO/DIN 72581-3)
  // 10A Red (Critical)
  static const Color fuse10ATab = Color(0xFFDE3B2F);
  static const Color fuse10AInkLight = Color(0xFFA81F15);
  static const Color fuse10AInkDark = Color(0xFFFF6B5E);

  // 20A Yellow (Moderate)
  static const Color fuse20ATab = Color(0xFFF2C200);
  static const Color fuse20AInkLight = Color(0xFF7A5500);
  static const Color fuse20AInkDark = Color(0xFFFFD84D);

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
  static const Color fuse15AInkLight = Color(0xFF0F5288);
  static const Color fuse15AInkDark = Color(0xFF60A5FA);

  // Light Lid (Daylight Workshop) Board Tokens
  static const Color lightBoard = Color(0xFFD5D7CF);
  static const Color lightCell = Color(0xFFE5E7E1);
  static const Color lightCellSubtle = Color(0xFFECEEE9);
  static const Color lightRib = Color(0xFFA9ADA5);
  static const Color lightRibLit = Color(0xFFF4F5F2);
  static const Color lightTextPrimary = Color(0xFF1B1F1D);
  static const Color lightTextMuted = Color(0xFF5C635F);
  static const Color lightBorder = Color(0xFFBCC0B8);

  // Dark Lid (Night Bay) Board Tokens
  static const Color darkBoard = Color(0xFF17191A);
  static const Color darkCell = Color(0xFF202324);
  static const Color darkCellSubtle = Color(0xFF272A2C);
  static const Color darkRib = Color(0xFF0B0D0E);
  static const Color darkRibLit = Color(0xFF2D3133);
  static const Color darkTextPrimary = Color(0xFFF0F2F1);
  static const Color darkTextMuted = Color(0xFF9BA29F);
  static const Color darkBorder = Color(0xFF2E3235);
}
