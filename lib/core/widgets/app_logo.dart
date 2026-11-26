import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';

enum LogoVariant { full, emblem, wordmark }

/// A unified, senior-grade Brand Identity widget for XGARAGE.
/// Renders the tachometer X emblem, stylized wordmark, or full composite logo.
class AppLogo extends StatelessWidget {
  final LogoVariant variant;
  final double? size;
  final double? height;
  final double? width;
  final bool showGlow;
  final bool showSubtitle;
  final bool isItalic;
  final String? heroTag;

  const AppLogo.full({
    super.key,
    this.height = 140,
    this.width,
    this.showGlow = true,
    this.showSubtitle = true,
    this.heroTag = 'app_logo_hero',
  })  : variant = LogoVariant.full,
        size = null,
        isItalic = true;

  const AppLogo.emblem({
    super.key,
    this.size = 46,
    this.showGlow = true,
    this.heroTag = 'app_logo_emblem_hero',
  })  : variant = LogoVariant.emblem,
        height = null,
        width = null,
        showSubtitle = false,
        isItalic = false;

  const AppLogo.wordmark({
    super.key,
    this.size = 24,
    this.showSubtitle = false,
    this.isItalic = true,
    this.heroTag,
  })  : variant = LogoVariant.wordmark,
        height = null,
        width = null,
        showGlow = false;

  @override
  Widget build(BuildContext context) {
    Widget content;

    switch (variant) {
      case LogoVariant.emblem:
        content = _buildEmblem(context);
        break;
      case LogoVariant.wordmark:
        content = _buildWordmark(context);
        break;
      case LogoVariant.full:
        content = _buildFull(context);
        break;
    }

    if (heroTag != null) {
      return Hero(
        tag: heroTag!,
        child: Material(
          type: MaterialType.transparency,
          child: content,
        ),
      );
    }

    return content;
  }

  Widget _buildEmblem(BuildContext context) {
    final emblemSize = size ?? 46;

    Widget emblem = Container(
      width: emblemSize,
      height: emblemSize,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: showGlow
            ? [
                BoxShadow(
                  color: AppColors.primaryCrimson.withValues(alpha: 0.35),
                  blurRadius: emblemSize * 0.35,
                  spreadRadius: 1.0,
                ),
              ]
            : null,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(emblemSize / 2),
        child: Image.asset(
          'assets/images/app_logo_emblem.png',
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _buildFallbackEmblem(emblemSize),
        ),
      ),
    );

    return emblem;
  }

  Widget _buildFallbackEmblem(double s) {
    return Container(
      width: s,
      height: s,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.surfaceInput,
        border: Border.all(color: AppColors.primaryCrimson, width: 1.5),
      ),
      child: Center(
        child: Text(
          'X',
          style: GoogleFonts.plusJakartaSans(
            color: AppColors.primaryCrimson,
            fontWeight: FontWeight.w900,
            fontSize: s * 0.5,
          ),
        ),
      ),
    );
  }

  Widget _buildWordmark(BuildContext context) {
    final fontSize = size ?? 24;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              'X',
              style: GoogleFonts.plusJakartaSans(
                color: AppColors.primaryCrimson,
                fontSize: fontSize * 1.08,
                fontWeight: FontWeight.w900,
                fontStyle: isItalic ? FontStyle.italic : FontStyle.normal,
                letterSpacing: 1.2,
                shadows: [
                  Shadow(
                    color: AppColors.primaryCrimson.withValues(alpha: 0.6),
                    blurRadius: 10,
                  ),
                ],
              ),
            ),
            Text(
              'GARAGE',
              style: GoogleFonts.plusJakartaSans(
                color: Colors.white,
                fontSize: fontSize,
                fontWeight: FontWeight.w900,
                fontStyle: isItalic ? FontStyle.italic : FontStyle.normal,
                letterSpacing: 2.2,
              ),
            ),
          ],
        ),
        if (showSubtitle) ...[
          const SizedBox(height: 4),
          Text(
            'إدارة مواعيد خروج الجراج والغسيل الذكي',
            style: GoogleFonts.cairo(
              color: const Color(0xFF9E9AA8),
              fontSize: fontSize * 0.45,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildFull(BuildContext context) {
    return Container(
      decoration: showGlow
          ? BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryCrimson.withValues(alpha: 0.22),
                  blurRadius: 32,
                  spreadRadius: 2,
                ),
              ],
            )
          : null,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Image.asset(
          'assets/images/app_logo.png',
          height: height,
          width: width,
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildFallbackEmblem(height != null ? height! * 0.55 : 80),
              const SizedBox(height: 12),
              _buildWordmark(context),
            ],
          ),
        ),
      ),
    );
  }
}
