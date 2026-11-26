import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';
import 'app_typography.dart';

class AppTheme {
  static ThemeData getTheme({bool isArabic = false}) {
    final baseTextTheme = ThemeData.dark().textTheme;
    final themedTextTheme = isArabic
        ? GoogleFonts.tajawalTextTheme(baseTextTheme)
        : GoogleFonts.outfitTextTheme(baseTextTheme);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.bgPrimary,
      primaryColor: AppColors.primaryCrimson,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primaryCrimson,
        secondary: AppColors.accentRoseText,
        surface: AppColors.bgElevated,
        error: AppColors.statusDanger,
      ),
      textTheme: themedTextTheme,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: AppColors.textPrimary),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surfaceInput,
        hintStyle: AppTypography.getBodyMedium(isArabic: isArabic)
            .copyWith(color: AppColors.textMuted),
        labelStyle: AppTypography.getBodyMedium(isArabic: isArabic)
            .copyWith(color: AppColors.textSecondary),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0x1AFFFFFF), width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide:
              const BorderSide(color: AppColors.primaryCrimson, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.statusDanger, width: 1),
        ),
      ),
    );
  }

  static ThemeData get darkTheme => getTheme();
}
