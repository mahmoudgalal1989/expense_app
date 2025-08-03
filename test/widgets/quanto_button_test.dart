import 'package:expense_app/widgets/quanto_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> _loadFonts() async {
  final fontLoader = FontLoader('Sora');
  fontLoader.addFont(rootBundle.load('assets/fonts/Sora-Regular.ttf'));
  fontLoader.addFont(rootBundle.load('assets/fonts/Sora-Medium.ttf'));
  fontLoader.addFont(rootBundle.load('assets/fonts/Sora-SemiBold.ttf'));
  await fontLoader.load();
}

void main() {
  group('QuantoButton Golden Tests', () {
    setUpAll(() async {
      // Ensure fonts are loaded before tests
      await _loadFonts();
    });
    testWidgets('should match golden file - small primary button (CategoryScreen AppBar)',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            backgroundColor: const Color(0xFF283339), // Match app background
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: 16.0, top: 4.0, bottom: 4.0),
                  child: RepaintBoundary(
                    key: const Key('new_button_boundary'),
                    child: Container(
                      width: 67,
                      height: 38,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        gradient: const LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Color(0xFFEFF2F6), // #EFF2F6 at start
                            Color(0xFFDFDFDF), // #DFDFDF at end
                          ],
                        ),
                        border: Border.all(
                          width: 2.0,
                          color: Colors.transparent,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          'Button',
                          style: const TextStyle(
                            fontFamily: 'Sora',
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            height: 18.0 / 12.0,
                            letterSpacing: 0.1,
                            color: Color(0xFF151A1F),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            body: Container(), // Empty body to focus on the button
          ),
        ),
      );

      await tester.pumpAndSettle();

      await expectLater(
        find.byKey(const Key('new_button_boundary')),
        matchesGoldenFile('goldens/quanto_button_small_primary_category_screen.png'),
      );
    });

    testWidgets('should match golden file - small primary button pressed state',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            backgroundColor: const Color(0xFF283339), // Match app background
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: 16.0, top: 4.0, bottom: 4.0),
                  child: RepaintBoundary(
                    key: const Key('new_button_pressed_boundary'),
                    child: QuantoButton(
                      onPressed: () {},
                      text: 'Button',
                      buttonType: QuantoButtonType.primary,
                      size: QuantoButtonSize.small,
                    ),
                  ),
                ),
              ],
            ),
            body: Container(), // Empty body to focus on the button
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Simulate button press
      await tester.press(find.byType(QuantoButton));
      await tester.pump(); // Capture the pressed state

      await expectLater(
        find.byKey(const Key('new_button_pressed_boundary')),
        matchesGoldenFile('goldens/quanto_button_small_primary_pressed.png'),
      );
    });

    testWidgets('should match golden file - small secondary button',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            backgroundColor: const Color(0xFF283339), // Match app background
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: 16.0, top: 4.0, bottom: 4.0),
                  child: RepaintBoundary(
                    key: const Key('secondary_button_boundary'),
                    child: QuantoButton(
                      onPressed: () {},
                      text: 'Button',
                      buttonType: QuantoButtonType.secondary,
                      size: QuantoButtonSize.small,
                    ),
                  ),
                ),
              ],
            ),
            body: Container(), // Empty body to focus on the button
          ),
        ),
      );

      await tester.pumpAndSettle();

      await expectLater(
        find.byKey(const Key('secondary_button_boundary')),
        matchesGoldenFile('goldens/quanto_button_small_secondary.png'),
      );
    });

    testWidgets('should have correct dimensions for small size', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: QuantoButton(
                onPressed: () {},
                text: 'New',
                buttonType: QuantoButtonType.primary,
                size: QuantoButtonSize.small,
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final buttonFinder = find.byType(QuantoButton);
      expect(buttonFinder, findsOneWidget);

      final RenderBox renderBox = tester.renderObject(buttonFinder);
      expect(renderBox.size.width, 67.0); // Small size width
      expect(renderBox.size.height, 42.0); // Small size height (38 + 4 for shadow)
    });

    testWidgets('should respond to tap', (WidgetTester tester) async {
      bool wasPressed = false;
      
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: QuantoButton(
                onPressed: () {
                  wasPressed = true;
                },
                text: 'New',
                buttonType: QuantoButtonType.primary,
                size: QuantoButtonSize.small,
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Initially should not be pressed
      expect(wasPressed, false);

      // Tap the button
      await tester.tap(find.byType(QuantoButton));
      await tester.pumpAndSettle();

      expect(wasPressed, true);
    });

    testWidgets('should display correct text', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: QuantoButton(
                onPressed: () {},
                text: 'New',
                buttonType: QuantoButtonType.primary,
                size: QuantoButtonSize.small,
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Button'), findsOneWidget);
    });

    testWidgets('should match provided reference design',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            // Remove background color to test without background
            body: Center(
              child: RepaintBoundary(
                key: const Key('reference_button_boundary'),
                child: Container(
                  // Match your reference image dimensions: 67×38
                  width: 67, // Match reference image width
                  height: 38,  // Match reference image height
                  color: Colors.transparent, // Try transparent background
                  child: Center(
                    child: QuantoButton(
                      onPressed: () {},
                      text: 'Button',
                      buttonType: QuantoButtonType.primary,
                      size: QuantoButtonSize.small,
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
        find.byKey(const Key('reference_button_boundary')),
        matchesGoldenFile('goldens/button_reference.png'),
      );
    });
  });
}
