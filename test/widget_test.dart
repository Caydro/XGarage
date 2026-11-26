import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:garage/core/widgets/app_button.dart';
import 'package:garage/core/widgets/app_logo.dart';
import 'package:garage/core/widgets/license_plate_badge.dart';

void main() {
  testWidgets('LicensePlateBadge renders letters and numbers correctly',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: LicensePlateBadge(
              letters: 'أ ب ج',
              numbers: '١٢٣٤',
            ),
          ),
        ),
      ),
    );

    expect(find.text('EGYPT  •  مصر'), findsOneWidget);
    expect(find.text('أ ب ج'), findsOneWidget);
    expect(find.text('١٢٣٤'), findsOneWidget);
  });

  testWidgets('AppLogo wordmark renders X and GARAGE brand identity',
      (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: AppLogo.wordmark(
              size: 24,
              showSubtitle: true,
            ),
          ),
        ),
      ),
    );

    expect(find.text('X'), findsOneWidget);
    expect(find.text('GARAGE'), findsOneWidget);
    expect(find.text('إدارة مواعيد خروج الجراج والغسيل الذكي'), findsOneWidget);
  });

  testWidgets('AppButton renders text and triggers onPressed callback',
      (tester) async {
    bool tapped = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: AppButton(
              text: 'Take Car Out',
              onPressed: () {
                tapped = true;
              },
            ),
          ),
        ),
      ),
    );

    expect(find.text('Take Car Out'), findsOneWidget);
    await tester.tap(find.text('Take Car Out'));
    await tester.pump();

    expect(tapped, isTrue);
  });
}
