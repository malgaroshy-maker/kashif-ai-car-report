import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'colors.dart';

class KashifTheme {
  static ThemeData lightTheme() {
    final base = ThemeData.light(useMaterial3: true);
    return base.copyWith(
      scaffoldBackgroundColor: KashifColors.lightBoard,
      colorScheme: ColorScheme.light(
        primary: KashifColors.fuse15AInkLight,
        onPrimary: Colors.white,
        secondary: KashifColors.fuse20ATab,
        surface: KashifColors.lightCell,
        onSurface: KashifColors.lightTextPrimary,
        error: KashifColors.fuse10AInkLight,
        onError: Colors.white,
      ),
      cardTheme: CardThemeData(
        color: KashifColors.lightCell,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(2),
          side: const BorderSide(color: KashifColors.lightBorder, width: 1),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: KashifColors.lightBoard,
        foregroundColor: KashifColors.lightTextPrimary,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.readexPro(
          color: KashifColors.lightTextPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
      ),
      textTheme: GoogleFonts.readexProTextTheme(base.textTheme).apply(
        bodyColor: KashifColors.lightTextPrimary,
        displayColor: KashifColors.lightTextPrimary,
      ),
      dividerColor: KashifColors.lightRib,
    );
  }

  static ThemeData darkTheme() {
    final base = ThemeData.dark(useMaterial3: true);
    return base.copyWith(
      scaffoldBackgroundColor: KashifColors.darkBoard,
      colorScheme: ColorScheme.dark(
        primary: KashifColors.fuse15AInkDark,
        onPrimary: Colors.black,
        secondary: KashifColors.fuse20ATab,
        surface: KashifColors.darkCell,
        onSurface: KashifColors.darkTextPrimary,
        error: KashifColors.fuse10AInkDark,
        onError: Colors.black,
      ),
      cardTheme: CardThemeData(
        color: KashifColors.darkCell,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(2),
          side: const BorderSide(color: KashifColors.darkBorder, width: 1),
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: KashifColors.darkBoard,
        foregroundColor: KashifColors.darkTextPrimary,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.readexPro(
          color: KashifColors.darkTextPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
      ),
      textTheme: GoogleFonts.readexProTextTheme(base.textTheme).apply(
        bodyColor: KashifColors.darkTextPrimary,
        displayColor: KashifColors.darkTextPrimary,
      ),
      dividerColor: KashifColors.darkRib,
    );
  }
}
