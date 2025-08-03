import 'dart:async';

import 'package:expense_app/features/currency/domain/entities/currency.dart';
import 'package:expense_app/features/currency/presentation/bloc/currency_bloc/currency_bloc.dart';
import 'package:expense_app/features/currency/presentation/bloc/currency_bloc/currency_event.dart';
import 'package:expense_app/features/currency/presentation/bloc/currency_bloc/currency_state.dart';
import 'package:rxdart/rxdart.dart';
import 'package:expense_app/main_page.dart' as app;
import 'package:expense_app/settings_page.dart' as app;
import 'package:expense_app/summary_page.dart' as app;
import 'package:expense_app/transactions_page.dart' as app;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';

class MockCurrencyBloc extends Mock implements CurrencyBloc {
  final BehaviorSubject<CurrencyState> _stateController =
      BehaviorSubject<CurrencyState>.seeded(const CurrencyInitial());

  @override
  CurrencyState get state => _stateController.value;

  @override
  Stream<CurrencyState> get stream => _stateController.stream;

  @override
  void add(CurrencyEvent event) {
    if (event is LoadCurrencies) {
      _stateController.add(const CurrencyLoading());
      // Emit a state with some test currencies
      const usd = Currency(
        code: 'USD',
        countryName: 'United States',
        flagIconPath: 'assets/flags/us.png',
        isMostUsed: true,
        isSelected: true,
      );
      const eur = Currency(
        code: 'EUR',
        countryName: 'European Union',
        flagIconPath: 'assets/flags/eu.png',
        isMostUsed: true,
        isSelected: false,
      );
      final currencies = [usd, eur];
      _stateController.add(CurrenciesLoaded(
        currencies: currencies,
        mostUsedCurrencies: currencies.where((c) => c.isMostUsed).toList(),
        selectedCurrency: usd,
      ));
    }
  }

  @override
  Future<void> close() async {
    await _stateController.close();
    return super.noSuchMethod(Invocation.method(#close, []));
  }
}

// Helper function to create a testable widget with all necessary providers
Widget createTestableWidgetWithDependencies(Widget child) {
  return MultiBlocProvider(
    providers: [
      BlocProvider<CurrencyBloc>(
        create: (context) => MockCurrencyBloc()..add(const LoadCurrencies()),
      ),
    ],
    child: MaterialApp(
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
    ),
  );
}

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
    // Create a test app with the MainPage and proper dependencies
    await tester
        .pumpWidget(createTestableWidgetWithDependencies(const app.MainPage()));

    // Wait for the app to finish building and animations to complete
    await tester.pumpAndSettle(const Duration(seconds: 1));

    // Get the localizations
    final localizations =
        await AppLocalizations.delegate.load(const Locale('en'));

    // Verify initial page shows the welcome message
    expect(
      find.text(localizations.startJourney, skipOffstage: false),
      findsOneWidget,
      reason: 'Welcome message should be visible on initial load',
    );
    expect(
      find.text(localizations.addFirstTransaction, skipOffstage: false),
      findsOneWidget,
      reason: 'Add first transaction message should be visible',
    );

    // Find and tap the Summary tab using its label
    final summaryLabel = find.text(localizations.summary);
    expect(summaryLabel, findsOneWidget);
    await tester.tap(summaryLabel);

    // Wait for the navigation animation to complete
    await tester.pumpAndSettle(const Duration(seconds: 1));

    // Verify we see the summary page content
    expect(
      find.byType(app.SummaryPage),
      findsOneWidget,
      reason: 'SummaryPage should be visible after tapping summary tab',
    );

    // Find and tap the Settings tab using its label
    final settingsLabel = find.text(localizations.settings);
    expect(settingsLabel, findsOneWidget);
    await tester.tap(settingsLabel);

    // Wait for the navigation animation and any async operations to complete
    await tester.pumpAndSettle(const Duration(seconds: 2));

    // Verify we see the settings page content
    expect(
      find.byType(app.SettingsPage),
      findsOneWidget,
      reason: 'SettingsPage should be visible after tapping settings tab',
    );

    // Find and tap the Transactions tab using its label
    final transactionsLabel = find.text(localizations.transactions);
    expect(transactionsLabel, findsOneWidget);
    await tester.tap(transactionsLabel);

    // Wait for the navigation animation to complete
    await tester.pumpAndSettle(const Duration(seconds: 1));

    // The welcome message should be visible again
    expect(find.text(localizations.startJourney, skipOffstage: false),
        findsOneWidget);
    expect(find.text(localizations.addFirstTransaction, skipOffstage: false),
        findsOneWidget);
  });
}
