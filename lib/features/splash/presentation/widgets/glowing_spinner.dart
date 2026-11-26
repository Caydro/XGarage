import 'dart:math' as math;
import 'package:flutter/material.dart';

class GlowingCrimsonSpinner extends StatefulWidget {
  final double size;

  const GlowingCrimsonSpinner({super.key, this.size = 56});

  @override
  State<GlowingCrimsonSpinner> createState() => _GlowingCrimsonSpinnerState();
}

class _GlowingCrimsonSpinnerState extends State<GlowingCrimsonSpinner>
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
        return Transform.rotate(
          angle: _controller.value * 2 * math.pi,
          child: CustomPaint(
            size: Size(widget.size, widget.size),
            painter: _GlowingArcPainter(),
          ),
        );
      },
    );
  }
}

class _GlowingArcPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2) - 4;
    final rect = Rect.fromCircle(center: center, radius: radius);

    // Glowing blur paint
    final glowPaint = Paint()
      ..shader = const SweepGradient(
        startAngle: 0.0,
        endAngle: math.pi * 1.5,
        colors: [
          Colors.transparent,
          Color(0x55FF2E55),
          Color(0xFFFF2E55),
        ],
      ).createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5.5
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5.0);

    // Crisp inner core paint
    final corePaint = Paint()
      ..shader = const SweepGradient(
        startAngle: 0.0,
        endAngle: math.pi * 1.5,
        colors: [
          Colors.transparent,
          Color(0x88FF2E55),
          Color(0xFFFF4D6D),
        ],
      ).createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(rect, 0, math.pi * 1.5, false, glowPaint);
    canvas.drawArc(rect, 0, math.pi * 1.5, false, corePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
