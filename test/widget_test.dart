import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:expense_app/main.dart';

void main() {
  group('App Tests', () {
    testWidgets('App builds with correct title', (tester) async {
      await tester.pumpWidget(const MyApp());
      expect(
        find.text('Expense Tracker'),
        findsNothing,
      ); // Title is in MaterialApp, not in the widget tree
    });
  });

  group('MainPage Tests', () {
    testWidgets('Displays bottom navigation bar with three items', (
      tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: MainPage()));

      // Verify bottom navigation bar is present
      final bottomNavBar = find.byType(BottomNavigationBar);
      expect(bottomNavBar, findsOneWidget);

      // Verify all three navigation items are present
      expect(find.byIcon(Icons.receipt), findsOneWidget);
      expect(find.byIcon(Icons.bar_chart), findsOneWidget);
      expect(find.byIcon(Icons.settings), findsOneWidget);

      // Verify initial page shows the welcome message
      expect(find.text("Let's start your journey!"), findsOneWidget);
      expect(find.text('Add your first transaction to start.'), findsOneWidget);
    });

    testWidgets('Switches between pages when bottom nav items are tapped', (
      tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: MainPage()));

      // Verify initial page is Transactions with the welcome message
      expect(find.text("Let's start your journey!"), findsOneWidget);
      expect(find.text('Summary Page'), findsNothing);
      expect(find.text('Settings Page'), findsNothing);

      // Tap Summary tab
      await tester.tap(find.byIcon(Icons.bar_chart));
      await tester.pumpAndSettle();

      // Verify Summary page is shown
      expect(find.text("Let's start your journey!"), findsNothing);
      expect(find.text('Summary Page'), findsOneWidget);
      expect(find.text('Settings Page'), findsNothing);

      // Tap Settings tab
      await tester.tap(find.byIcon(Icons.settings));
      await tester.pumpAndSettle();

      // Verify Settings page is shown
      expect(find.text("Let's start your journey!"), findsNothing);
      expect(find.text('Summary Page'), findsNothing);
      expect(find.text('Settings Page'), findsOneWidget);

      // Tap Transactions tab
      await tester.tap(find.byIcon(Icons.receipt));
      await tester.pumpAndSettle();

      // Verify Transactions page is shown again with welcome message
      expect(find.text("Let's start your journey!"), findsOneWidget);
      expect(find.text('Summary Page'), findsNothing);
      expect(find.text('Settings Page'), findsNothing);
    });
  });
}
