import 'package:flutter/material.dart';

class LicensePlateBadge extends StatelessWidget {
  final String letters;
  final String numbers;
  final bool isCompact;

  const LicensePlateBadge({
    super.key,
    required this.letters,
    required this.numbers,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(isCompact ? 8 : 10),
        border: Border.all(color: const Color(0xFFCBD5E1), width: 1.5),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(isCompact ? 7 : 9),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Country / Garage header strip (Egyptian / GCC style)
            Container(
              width: isCompact ? 100 : 130,
              padding: EdgeInsets.symmetric(vertical: isCompact ? 2 : 3),
              color: const Color(0xFF0F172A),
              child: Center(
                child: Text(
                  'EGYPT  •  مصر',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: isCompact ? 8 : 9,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
            ),
            // Plate body (Letters + Numbers with divider)
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: isCompact ? 8 : 12,
                vertical: isCompact ? 4 : 6,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    numbers,
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      color: const Color(0xFF0F172A),
                      fontSize: isCompact ? 14 : 17,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.2,
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    height: isCompact ? 14 : 18,
                    width: 1.5,
                    color: const Color(0xFF94A3B8),
                  ),
                  Text(
                    letters,
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      color: const Color(0xFF0F172A),
                      fontSize: isCompact ? 14 : 17,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
