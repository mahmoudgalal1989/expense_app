import 'package:expense_app/settings_page.dart' as app;
import 'package:expense_app/summary_page.dart' as app;
import 'package:expense_app/transactions_page.dart' as app;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:expense_app/main.dart' as app;

// Helper function to create a testable widget with localization support
MaterialApp createTestableWidget(Widget child) {
  return MaterialApp(
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: const [
      Locale('en', ''), // English, no country code
    ],
    home: child,
  );
}

void main() {
  testWidgets('App builds and shows initial screen', (tester) async {
    // Build our app and trigger a frame with proper localization
    await tester.pumpWidget(
      const MaterialApp(
        localizationsDelegates: [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: [
          Locale('en'), // English, no country code
        ],
        home: app.TransactionsPage(),
      ),
    );

    // Wait for the app to finish building
    await tester.pumpAndSettle();

    // Verify the welcome message is displayed
    final localizations =
        await AppLocalizations.delegate.load(const Locale('en'));

    // Find the welcome message in the widget tree
    expect(find.text(localizations.startJourney, skipOffstage: false),
        findsOneWidget);
  });

  testWidgets('Bottom navigation switches between pages', (tester) async {
    // Create a test app with the MainPage and proper localization
    await tester.pumpWidget(
        createTestableWidget(const app.MainPage(title: 'Expense Tracker')));
    await tester.pumpAndSettle();

    // Get the localizations
    final localizations =
        await AppLocalizations.delegate.load(const Locale('en'));

    // Verify initial page shows the welcome message
    expect(find.text(localizations.startJourney, skipOffstage: false),
        findsOneWidget);
    expect(find.text(localizations.addFirstTransaction, skipOffstage: false),
        findsOneWidget);

    // Find and tap the Summary tab using its label
    final summaryLabel = find.text(localizations.summary);
    await tester.tap(summaryLabel);
    await tester.pumpAndSettle();

    // Verify we see the summary page content (using find.byType to be more specific)
    expect(find.byType(app.SummaryPage), findsOneWidget);

    // The welcome message should not be visible in the summary page
    expect(find.text(localizations.startJourney, skipOffstage: false),
        findsNothing);

    // Find and tap the Settings tab using its label
    final settingsLabel = find.text(localizations.settings);
    await tester.tap(settingsLabel);
    await tester.pumpAndSettle();

    // Verify we see the settings page content (using find.byType to be more specific)
    expect(find.byType(app.SettingsPage), findsOneWidget);

    // The welcome message and summary should not be visible in settings
    expect(find.text(localizations.startJourney, skipOffstage: false),
        findsNothing);
    expect(find.byType(app.SummaryPage), findsNothing);

    // Find and tap the Transactions tab using its label
    final transactionsLabel = find.text(localizations.transactions);
    await tester.tap(transactionsLabel);
    await tester.pumpAndSettle();

    // The welcome message should be visible again
    expect(find.text(localizations.startJourney, skipOffstage: false),
        findsOneWidget);
    expect(find.text(localizations.addFirstTransaction, skipOffstage: false),
        findsOneWidget);
  });
}
