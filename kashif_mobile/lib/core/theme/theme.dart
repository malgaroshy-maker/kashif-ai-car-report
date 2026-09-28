import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'colors.dart';

class KashifTheme {
  static ThemeData lightTheme() {
    final base = ThemeData.light(useMaterial3: true);
    return base.copyWith(
      scaffoldBackgroundColor: KashifColors.lightBoard,
      colorScheme: ColorScheme.light(
        primary: KashifColors.royalBlue,
        onPrimary: Colors.white,
        secondary: KashifColors.goldDark,
        surface: KashifColors.lightCell,
        onSurface: KashifColors.lightTextPrimary,
        error: KashifColors.fuse10AInkLight,
        onError: Colors.white,
      ),
      cardTheme: CardThemeData(
        color: KashifColors.lightCell,
        elevation: 1,
        shadowColor: const Color(0x0C0B1938),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
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
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: KashifColors.lightCell,
        indicatorColor: KashifColors.goldPrimary.withValues(alpha: 0.18),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: KashifColors.goldDark);
          }
          return const IconThemeData(color: KashifColors.lightTextMuted);
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return GoogleFonts.readexPro(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: KashifColors.goldDark,
            );
          }
          return GoogleFonts.readexPro(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: KashifColors.lightTextMuted,
          );
        }),
      ),
      textTheme: GoogleFonts.readexProTextTheme(base.textTheme).apply(
        bodyColor: KashifColors.lightTextPrimary,
        displayColor: KashifColors.lightTextPrimary,
      ),
      dividerColor: KashifColors.lightRib,
      snackBarTheme: SnackBarThemeData(
        backgroundColor: const Color(0xFF0B1938),
        contentTextStyle: GoogleFonts.readexPro(
          color: Colors.white,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: const BorderSide(
            color: KashifColors.royalBlueLight,
            width: 1.2,
          ),
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  static ThemeData darkTheme() {
    final base = ThemeData.dark(useMaterial3: true);
    return base.copyWith(
      scaffoldBackgroundColor: KashifColors.darkBoard,
      colorScheme: ColorScheme.dark(
        primary: KashifColors.goldLight,
        onPrimary: KashifColors.darkBoard,
        secondary: KashifColors.royalBlueLight,
        surface: KashifColors.darkCell,
        onSurface: KashifColors.darkTextPrimary,
        error: KashifColors.fuse10AInkDark,
        onError: Colors.black,
      ),
      cardTheme: CardThemeData(
        color: KashifColors.darkCell,
        elevation: 2,
        shadowColor: const Color(0x35000000),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
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
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: KashifColors.darkCell,
        indicatorColor: KashifColors.goldPrimary.withValues(alpha: 0.18),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: KashifColors.goldLight);
          }
          return const IconThemeData(color: KashifColors.darkTextMuted);
        }),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return GoogleFonts.readexPro(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: KashifColors.goldLight,
            );
          }
          return GoogleFonts.readexPro(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: KashifColors.darkTextMuted,
          );
        }),
      ),
      textTheme: GoogleFonts.readexProTextTheme(base.textTheme).apply(
        bodyColor: KashifColors.darkTextPrimary,
        displayColor: KashifColors.darkTextPrimary,
      ),
      dividerColor: KashifColors.darkRib,
      snackBarTheme: SnackBarThemeData(
        backgroundColor: const Color(0xFF0F1E38),
        contentTextStyle: GoogleFonts.readexPro(
          color: KashifColors.darkTextPrimary,
          fontSize: 13,
          fontWeight: FontWeight.w600,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: const BorderSide(color: KashifColors.goldPrimary, width: 1.2),
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
