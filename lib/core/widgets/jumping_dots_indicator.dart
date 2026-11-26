import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Senior-Grade Automotive 3 Jumping Dots Loading Indicator.
/// Replaces generic circular spinners with a dynamic, staggered bouncing wave.
class JumpingDotsIndicator extends StatefulWidget {
  final Color color;
  final double dotSize;
  final double jumpHeight;
  final double spacing;

  const JumpingDotsIndicator({
    super.key,
    this.color = Colors.white,
    this.dotSize = 7.0,
    this.jumpHeight = 8.0,
    this.spacing = 5.0,
  });

  @override
  State<JumpingDotsIndicator> createState() => _JumpingDotsIndicatorState();
}

class _JumpingDotsIndicatorState extends State<JumpingDotsIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(3, (index) {
            // Staggered sine wave: index * 0.22 phase shift
            final progress = _controller.value;
            final phase = (progress - (index * 0.22)) % 1.0;
            // Half-wave bounce: jump when phase is in first half [0, 0.5]
            final bounce = phase < 0.5
                ? math.sin(phase * 2 * math.pi)
                : 0.0;
            final dy = -bounce * widget.jumpHeight;
            final scale = 1.0 + (bounce * 0.25);
            final opacity = 0.55 + (bounce * 0.45);

            return Transform.translate(
              offset: Offset(0, dy),
              child: Transform.scale(
                scale: scale,
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: widget.spacing / 2),
                  width: widget.dotSize,
                  height: widget.dotSize,
                  decoration: BoxDecoration(
                    color: widget.color.withValues(alpha: opacity),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: widget.color.withValues(alpha: bounce * 0.6),
                        blurRadius: 6,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}
