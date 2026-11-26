import 'dart:math' as math;
import 'package:flutter/material.dart';

class GlowingParkingEmblem extends StatefulWidget {
  final double size;

  const GlowingParkingEmblem({super.key, this.size = 110});

  @override
  State<GlowingParkingEmblem> createState() => _GlowingParkingEmblemState();
}

class _GlowingParkingEmblemState extends State<GlowingParkingEmblem>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        final pulse = _pulseController.value;

        return SizedBox(
          width: widget.size,
          height: widget.size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Outer faint decorative orbit ring with particle dots
              CustomPaint(
                size: Size(widget.size, widget.size),
                painter: _OrbitRingPainter(pulse: pulse),
              ),

              // Ambient glowing halo behind center
              Container(
                width: widget.size * 0.76,
                height: widget.size * 0.76,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFF2E55)
                          .withValues(alpha: 0.35 + (0.2 * pulse)),
                      blurRadius: 28 + (10 * pulse),
                      spreadRadius: 2 + (4 * pulse),
                    ),
                  ],
                ),
              ),

              // Concentric neon red ring
              Container(
                width: widget.size * 0.74,
                height: widget.size * 0.74,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFFFF3366)
                        .withValues(alpha: 0.75 + (0.25 * pulse)),
                    width: 1.8,
                  ),
                ),
              ),

              // Center Dark Badge with Tachometer X Brand Emblem
              Container(
                width: widget.size * 0.62,
                height: widget.size * 0.62,
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1B26),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0x33FFFFFF),
                    width: 1.2,
                  ),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black54,
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: ClipOval(
                  child: Image.asset(
                    'assets/images/app_logo_emblem.png',
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const Center(
                      child: Text(
                        'X',
                        style: TextStyle(
                          color: Color(0xFFFF3366),
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _OrbitRingPainter extends CustomPainter {
  final double pulse;

  _OrbitRingPainter({required this.pulse});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width / 2) - 2;

    // Faint outer dashed/dotted orbit ring
    final ringPaint = Paint()
      ..color = const Color(0x2BFF3366)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    canvas.drawCircle(center, radius, ringPaint);

    // Decorative floating neon particle dots around orbit
    final dotPaint = Paint()
      ..color = const Color(0xFFFF4D6D).withValues(alpha: 0.6 + (0.3 * pulse))
      ..style = PaintingStyle.fill;

    const dotCount = 5;
    for (int i = 0; i < dotCount; i++) {
      final angle = (i * (2 * math.pi / dotCount)) + (pulse * 0.2);
      final dx = center.dx + (radius * math.cos(angle));
      final dy = center.dy + (radius * math.sin(angle));
      canvas.drawCircle(Offset(dx, dy), 1.5, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _OrbitRingPainter oldDelegate) =>
      oldDelegate.pulse != pulse;
}
