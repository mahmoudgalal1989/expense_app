import 'package:expense_app/theme/app_colors.dart';
import 'package:expense_app/widgets/animated_toggle_switch.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AnimatedToggleSwitch Golden Tests', () {
    testWidgets('should match golden file - default state (Expense selected)',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            backgroundColor: const Color(0xFF283339), // Match app background
            body: Center(
              child: AnimatedToggleSwitch(
                values: const ['Expense', 'Income'],
                onToggleCallback: (index) {},
                backgroundColor: AppColors.dark800,
                buttonColor: AppColors.dark600,
                selectedTextColor: AppColors.textPrimaryDark,
                unselectedTextColor: AppColors.textTertiaryDark,
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      await expectLater(
        find.byType(AnimatedToggleSwitch),
        matchesGoldenFile('goldens/animated_toggle_switch_expense_selected.png'),
      );
    });

    testWidgets('should match golden file - Income selected',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            backgroundColor: const Color(0xFF283339), // Match app background
            body: Center(
              child: AnimatedToggleSwitch(
                values: const ['Expense', 'Income'],
                onToggleCallback: (index) {},
                backgroundColor: AppColors.dark800,
                buttonColor: AppColors.dark600,
                selectedTextColor: AppColors.textPrimaryDark,
                unselectedTextColor: AppColors.textTertiaryDark,
              ),
            ),
          ),
        ),
      );

      // Tap on Income to switch
      await tester.tap(find.text('Income'));
      await tester.pumpAndSettle();

      await expectLater(
        find.byType(AnimatedToggleSwitch),
        matchesGoldenFile('goldens/animated_toggle_switch_income_selected.png'),
      );
    });

    testWidgets('should have correct dimensions', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: AnimatedToggleSwitch(
                values: const ['Expense', 'Income'],
                onToggleCallback: (index) {},
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final toggleFinder = find.byType(AnimatedToggleSwitch);
      expect(toggleFinder, findsOneWidget);

      final RenderBox renderBox = tester.renderObject(toggleFinder);
      expect(renderBox.size.width, 166.0);
      expect(renderBox.size.height, 40.0);
    });

    testWidgets('should animate between states', (WidgetTester tester) async {
      int selectedIndex = 0;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: AnimatedToggleSwitch(
                values: const ['Expense', 'Income'],
                onToggleCallback: (index) {
                  selectedIndex = index;
                },
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Initially should be at index 0 (Expense)
      expect(selectedIndex, 0);

      // Tap on Income
      await tester.tap(find.text('Income'));
      await tester.pump(); // Start animation
      await tester.pump(const Duration(milliseconds: 100)); // Mid animation
      await tester.pumpAndSettle(); // Complete animation

      expect(selectedIndex, 1);

      // Tap back on Expense
      await tester.tap(find.text('Expense'));
      await tester.pumpAndSettle();

      expect(selectedIndex, 0);
    });

    testWidgets('should match provided reference design',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Material(
            color: const Color(0xFF283339), // Match app background
            child: Center(
              child: RepaintBoundary(
                key: const Key('toggle_boundary'),
                child: Container(
                  width: 348, // Match your reference image width
                  height: 76,  // Match your reference image height
                  color: const Color(0xFF283339), // Match background
                  child: Center(
                    child: SizedBox(
                      width: 300, // Make toggle switch much larger
                      height: 60,  // Make it taller too
                      child: AnimatedToggleSwitch(
                        values: const ['Expense', 'Income'],
                        onToggleCallback: (index) {},
                        backgroundColor: const Color(0xFF2D3748), // Darker background
                        buttonColor: const Color(0xFF4A5568), // Medium gray button
                        selectedTextColor: Colors.white,
                        unselectedTextColor: const Color(0xFF718096),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Compare against your provided reference image
      await expectLater(
        find.byKey(const Key('toggle_boundary')),
        matchesGoldenFile('goldens/image.png'),
      );
    });
  });
}
