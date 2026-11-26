import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import 'jumping_dots_indicator.dart';

enum AppButtonVariant { primary, secondary, glass, outline, destructive }

class AppButton extends StatefulWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isFullWidth;
  final IconData? icon;
  final AppButtonVariant variant;
  final double height;

  const AppButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.isFullWidth = true,
    this.icon,
    this.variant = AppButtonVariant.primary,
    this.height = 52,
  });

  @override
  State<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton> {
  bool _isPressed = false;

  void _handleTapDown(TapDownDetails _) {
    if (widget.onPressed == null || widget.isLoading) return;
    setState(() => _isPressed = true);
    HapticFeedback.lightImpact();
  }

  void _handleTapUp(TapUpDetails _) {
    if (widget.onPressed == null || widget.isLoading) return;
    setState(() => _isPressed = false);
  }

  void _handleTapCancel() {
    if (widget.onPressed == null || widget.isLoading) return;
    setState(() => _isPressed = false);
  }

  @override
  Widget build(BuildContext context) {
    final bool isDisabled = widget.onPressed == null && !widget.isLoading;

    BoxDecoration decoration;
    Color textColor = Colors.white;

    switch (widget.variant) {
      case AppButtonVariant.primary:
        decoration = BoxDecoration(
          gradient: isDisabled ? null : AppColors.crimsonGradient,
          color: isDisabled ? const Color(0xFF33303D) : null,
          borderRadius: BorderRadius.circular(16),
          boxShadow: isDisabled
              ? null
              : const [
                  BoxShadow(
                    color: Color(0x40D9385A),
                    blurRadius: 14,
                    offset: Offset(0, 4),
                  ),
                ],
        );
        textColor = Colors.white;
        break;
      case AppButtonVariant.secondary:
        decoration = BoxDecoration(
          color: AppColors.surfaceInput,
          borderRadius: BorderRadius.circular(16),
        );
        textColor = AppColors.textPrimary;
        break;
      case AppButtonVariant.glass:
        decoration = BoxDecoration(
          color: AppColors.surfaceCard,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.glassBorderHighlight.withValues(alpha: 0.3)),
        );
        textColor = AppColors.accentRoseText;
        break;
      case AppButtonVariant.outline:
        decoration = BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.primaryCrimson, width: 1.5),
        );
        textColor = AppColors.primaryCrimson;
        break;
      case AppButtonVariant.destructive:
        decoration = BoxDecoration(
          color: AppColors.statusDangerBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.statusDanger.withValues(alpha: 0.4)),
        );
        textColor = AppColors.statusDanger;
        break;
    }

    Widget content = SizedBox(
      height: widget.height,
      width: widget.isFullWidth ? double.infinity : null,
      child: Center(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: widget.isLoading
              ? JumpingDotsIndicator(
                  color: textColor,
                  dotSize: 7.5,
                  jumpHeight: 7.0,
                  spacing: 5.5,
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (widget.icon != null) ...[
                      Icon(widget.icon, size: 20, color: textColor),
                      const SizedBox(width: 8),
                    ],
                    Text(
                      widget.text,
                      style: AppTypography.getButtonText().copyWith(color: textColor),
                    ),
                  ],
                ),
        ),
      ),
    );

    return AnimatedScale(
      scale: _isPressed ? 0.97 : 1.0,
      duration: const Duration(milliseconds: 110),
      curve: Curves.easeOutCubic,
      child: GestureDetector(
        onTapDown: _handleTapDown,
        onTapUp: _handleTapUp,
        onTapCancel: _handleTapCancel,
        onTap: widget.isLoading ? null : widget.onPressed,
        child: Container(
          decoration: decoration,
          child: content,
        ),
      ),
    );
  }
}
