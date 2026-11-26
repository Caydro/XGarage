import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTypography {
  static TextStyle getHeading1({bool isArabic = false}) {
    final base = isArabic ? GoogleFonts.cairo() : GoogleFonts.plusJakartaSans();
    return base.copyWith(
      fontSize: 26,
      fontWeight: FontWeight.w800,
      color: AppColors.textPrimary,
      letterSpacing: isArabic ? 0 : -0.5,
    );
  }

  static TextStyle getHeading2({bool isArabic = false}) {
    final base = isArabic ? GoogleFonts.cairo() : GoogleFonts.plusJakartaSans();
    return base.copyWith(
      fontSize: 20,
      fontWeight: FontWeight.w700,
      color: AppColors.textPrimary,
      letterSpacing: isArabic ? 0 : -0.3,
    );
  }

  static TextStyle getHeading3({bool isArabic = false}) {
    final base = isArabic ? GoogleFonts.cairo() : GoogleFonts.plusJakartaSans();
    return base.copyWith(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: AppColors.textPrimary,
    );
  }

  static TextStyle getBodyLarge({bool isArabic = false}) {
    final base = isArabic ? GoogleFonts.cairo() : GoogleFonts.plusJakartaSans();
    return base.copyWith(
      fontSize: 15,
      fontWeight: FontWeight.w500,
      color: AppColors.textSecondary,
    );
  }

  static TextStyle getBodyMedium({bool isArabic = false}) {
    final base = isArabic ? GoogleFonts.cairo() : GoogleFonts.plusJakartaSans();
    return base.copyWith(
      fontSize: 13,
      fontWeight: FontWeight.w400,
      color: AppColors.textSecondary,
    );
  }

  static TextStyle getCaption({bool isArabic = false}) {
    final base = isArabic ? GoogleFonts.cairo() : GoogleFonts.plusJakartaSans();
    return base.copyWith(
      fontSize: 11,
      fontWeight: FontWeight.w500,
      color: AppColors.textMuted,
    );
  }

  static TextStyle getButtonText({bool isArabic = false}) {
    final base = isArabic ? GoogleFonts.cairo() : GoogleFonts.plusJakartaSans();
    return base.copyWith(
      fontSize: 15,
      fontWeight: FontWeight.w700,
      color: Colors.white,
      letterSpacing: isArabic ? 0 : 0.4,
    );
  }
}
