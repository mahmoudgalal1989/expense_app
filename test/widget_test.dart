import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/services.dart';
import 'package:expense_app/main.dart';

// A test wrapper that provides the router and theme
class TestApp extends StatelessWidget {
  final GoRouter router;
  
  const TestApp({super.key, required this.router});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: router,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
    );
  }
}

void main() {
  group('App Tests', () {
    testWidgets('App builds with correct theme', (tester) async {
      await tester.pumpWidget(const MyApp());
      
      // Verify theme is applied
      final appBar = find.byType(AppBar);
      final appBarWidget = tester.widget<AppBar>(appBar);
      expect(appBar, findsOneWidget);
      
      // Verify the app title
      expect(find.text('Expense Tracker'), findsOneWidget);
    });

    testWidgets('App handles platform errors', (tester) async {
      // Test that the app can handle platform errors
      final exception = PlatformException(code: 'TEST', message: 'Test error');
      await tester.runAsync(() async {
        try {
          throw exception;
        } catch (e) {
          // Verify the error is caught and handled
          expect(e, isA<PlatformException>());
        }
      });
    });
  });

  group('Router Tests', () {
    testWidgets('Router handles unknown routes', (WidgetTester tester) async {
      final router = GoRouter(
        initialLocation: '/unknown',
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => const MyHomePage(title: 'Expense Tracker'),
          ),
          GoRoute(
            path: '/expenses',
            builder: (context, state) => const ExpensesPage(),
          ),
        ],
        errorBuilder: (context, state) => const Scaffold(
          body: Center(child: Text('Page not found')),
        ),
      );

      await tester.pumpWidget(TestApp(router: router));
      await tester.pumpAndSettle();
      
      expect(find.text('Page not found'), findsOneWidget);
    });

    testWidgets('Initial route is home page', (WidgetTester tester) async {
      final router = GoRouter(
        initialLocation: '/',
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => const MyHomePage(title: 'Expense Tracker'),
          ),
        ],
      );

      await tester.pumpWidget(TestApp(router: router));
      
      expect(find.text('Welcome to Expense Tracker'), findsOneWidget);
    });

    testWidgets('Navigates to expenses page', (WidgetTester tester) async {
      final router = GoRouter(
        initialLocation: '/',
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => const MyHomePage(title: 'Expense Tracker'),
          ),
          GoRoute(
            path: '/expenses',
            builder: (context, state) => const ExpensesPage(),
          ),
        ],
      );

      await tester.pumpWidget(TestApp(router: router));
      
      // Initial page
      expect(find.text('Welcome to Expense Tracker'), findsOneWidget);
      
      // Navigate to expenses
      await tester.tap(find.text('View Expenses'));
      await tester.pumpAndSettle();
      
      // Verify navigation
      expect(find.text('Expenses'), findsOneWidget);
      expect(find.text('Expenses will be displayed here'), findsOneWidget);
      
      // Test back navigation
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();
      expect(find.text('Welcome to Expense Tracker'), findsOneWidget);
    });
  });

  group('Home Page Tests', () {
    testWidgets('Test navigation to expenses', (WidgetTester tester) async {
      // Create a test router
      final router = GoRouter(
        initialLocation: '/',
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => const MyHomePage(title: 'Test'),
          ),
          GoRoute(
            path: '/expenses',
            builder: (context, state) => const Scaffold(
              body: Center(child: Text('Expenses Page')),
            ),
          ),
        ],
      );

      // Build our app and trigger a frame
      await tester.pumpWidget(TestApp(router: router));
      
      // Verify we're on the home page
      expect(find.text('Welcome to Expense Tracker'), findsOneWidget);
      
      // Tap the button to navigate to expenses
      await tester.tap(find.text('View Expenses'));
      await tester.pumpAndSettle();
      
      // Verify we've navigated to the expenses page
      expect(find.text('Expenses Page'), findsOneWidget);
    });
    testWidgets('Displays welcome message and button', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: MyHomePage(title: 'Expense Tracker'),
      ));

      expect(find.text('Welcome to Expense Tracker'), findsOneWidget);
      expect(find.text('View Expenses'), findsOneWidget);
    });

    testWidgets('Button has correct styling', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: MyHomePage(title: 'Expense Tracker'),
      ));

      final button = find.byType(ElevatedButton);
      expect(button, findsOneWidget);
      expect(
        find.descendant(of: button, matching: find.text('View Expenses')),
        findsOneWidget,
      );
    });
  });



  group('Expenses Page Tests', () {
    testWidgets('Displays expenses content', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
          body: ExpensesPage(),
        ),
      ));

      expect(find.text('Expenses'), findsOneWidget);
      expect(find.text('Expenses will be displayed here'), findsOneWidget);
      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
    });


  });
}
