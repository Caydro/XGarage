import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

/// Senior-Grade Automotive Design System Typography.
/// English: [Outfit] - Ultra-sleek, aerodynamic geometric luxury font.
/// Arabic:  [Tajawal] - Precision geometric Arabic sans-serif with zero vertical clipping.
/// Numbers: [Rajdhani] - Telemetry & instrument cluster digital display.
class AppTypography {
  static TextStyle getHeading1({bool isArabic = false}) {
    final base = isArabic ? GoogleFonts.tajawal() : GoogleFonts.outfit();
    return base.copyWith(
      fontSize: 25,
      fontWeight: FontWeight.w800,
      color: AppColors.textPrimary,
      letterSpacing: isArabic ? 0 : -0.4,
      height: 1.25,
    );
  }

  static TextStyle getHeading2({bool isArabic = false}) {
    final base = isArabic ? GoogleFonts.tajawal() : GoogleFonts.outfit();
    return base.copyWith(
      fontSize: 19,
      fontWeight: FontWeight.w700,
      color: AppColors.textPrimary,
      letterSpacing: isArabic ? 0 : -0.2,
      height: 1.25,
    );
  }

  static TextStyle getHeading3({bool isArabic = false}) {
    final base = isArabic ? GoogleFonts.tajawal() : GoogleFonts.outfit();
    return base.copyWith(
      fontSize: 15.5,
      fontWeight: FontWeight.w600,
      color: AppColors.textPrimary,
      height: 1.25,
    );
  }

  static TextStyle getBodyLarge({bool isArabic = false}) {
    final base = isArabic ? GoogleFonts.tajawal() : GoogleFonts.outfit();
    return base.copyWith(
      fontSize: 14.5,
      fontWeight: FontWeight.w500,
      color: AppColors.textSecondary,
      height: 1.3,
    );
  }

  static TextStyle getBodyMedium({bool isArabic = false}) {
    final base = isArabic ? GoogleFonts.tajawal() : GoogleFonts.outfit();
    return base.copyWith(
      fontSize: 13,
      fontWeight: FontWeight.w400,
      color: AppColors.textSecondary,
      height: 1.3,
    );
  }

  static TextStyle getCaption({bool isArabic = false}) {
    final base = isArabic ? GoogleFonts.tajawal() : GoogleFonts.outfit();
    return base.copyWith(
      fontSize: 11,
      fontWeight: FontWeight.w500,
      color: AppColors.textMuted,
      height: 1.2,
    );
  }

  static TextStyle getButtonText({bool isArabic = false}) {
    final base = isArabic ? GoogleFonts.tajawal() : GoogleFonts.outfit();
    return base.copyWith(
      fontSize: 14.5,
      fontWeight: FontWeight.w700,
      color: Colors.white,
      letterSpacing: isArabic ? 0 : 0.4,
      height: 1.2,
    );
  }

  static TextStyle getTelemetry({double fontSize = 14, FontWeight fontWeight = FontWeight.w700, Color color = Colors.white}) {
    return GoogleFonts.rajdhani(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      letterSpacing: 0.8,
    );
  }
}
