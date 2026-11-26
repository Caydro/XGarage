import 'package:flutter/material.dart';

class AppColors {
  // Backgrounds & Surface Hierarchy
  static const Color bgPrimary = Color(0xFF0F0E13);
  static const Color bgSecondary = Color(0xFF17151E);
  static const Color bgElevated = Color(0xFF1E1B26);
  static const Color surfaceCard = Color(0xB81E1B26); // 72% opacity
  static const Color surfaceInput = Color(0xFF252130);

  // Crimson & Rose Neon Accents
  static const Color primaryCrimson = Color(0xFFD9385A);
  static const Color primaryCrimsonDark = Color(0xFFA31D3B);
  static const Color primaryGlow = Color(0x2EE11D48); // ~18%
  static const Color accentRoseSoft = Color(0xFF3B1825);
  static const Color accentRoseText = Color(0xFFFF6B8B);
  static const Color glassBorderHighlight = Color(0x59FF5C7C); // ~35%
  static const Color glassBorderSubtle = Color(0x14FFFFFF); // ~8%

  // Typography & Text
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB4B0C2);
  static const Color textMuted = Color(0xFF78738A);

  // Operational Status Accents
  static const Color statusReady = Color(0xFF10B981);
  static const Color statusReadyBg = Color(0xFF0F2E24);
  static const Color statusWashing = Color(0xFF38BDF8);
  static const Color statusWashingBg = Color(0xFF0F293A);
  static const Color statusScheduled = Color(0xFFF59E0B);
  static const Color statusScheduledBg = Color(0xFF33240E);
  static const Color statusDanger = Color(0xFFF43F5E);
  static const Color statusDangerBg = Color(0xFF38141F);

  // Gradients
  static const LinearGradient crimsonGradient = LinearGradient(
    colors: [primaryCrimson, primaryCrimsonDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardBorderGradient = LinearGradient(
    colors: [glassBorderHighlight, glassBorderSubtle],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
