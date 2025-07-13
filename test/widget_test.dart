import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:expense_app/main.dart';

void main() {
  testWidgets('Home page displays welcome message and button', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MaterialApp(
      home: MyHomePage(title: 'Expense Tracker'),
    ));

    // Verify the welcome message is displayed
    expect(find.text('Welcome to Expense Tracker'), findsOneWidget);
    
    // Verify the button is displayed
    expect(find.text('View Expenses'), findsOneWidget);
  });

  testWidgets('Button has correct styling', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: MyHomePage(title: 'Expense Tracker'),
    ));

    // Find the button and verify it's an ElevatedButton
    final button = find.byType(ElevatedButton);
    expect(button, findsOneWidget);
    
    // Verify the button has the correct text
    expect(find.descendant(of: button, matching: find.text('View Expenses')), findsOneWidget);
  });
}
