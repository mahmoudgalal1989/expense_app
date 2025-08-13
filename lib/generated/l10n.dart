// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values, avoid_escaping_inner_quotes

class S {
  S();

  static S? _current;

  static S get current {
    assert(
      _current != null,
      'No instance of S was loaded. Try to initialize the S delegate before accessing S.current.',
    );
    return _current!;
  }

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<S> load(Locale locale) {
    final name = (locale.countryCode?.isEmpty ?? false)
        ? locale.languageCode
        : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      final instance = S();
      S._current = instance;

      return instance;
    });
  }

  static S of(BuildContext context) {
    final instance = S.maybeOf(context);
    assert(
      instance != null,
      'No instance of S present in the widget tree. Did you add S.delegate in localizationsDelegates?',
    );
    return instance!;
  }

  static S? maybeOf(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  /// `What are your main goals?`
  String get insightsTitle {
    return Intl.message(
      'What are your main goals?',
      name: 'insightsTitle',
      desc: '',
      args: [],
    );
  }

  /// `Feel free to pick more than one.`
  String get insightsSubtitle {
    return Intl.message(
      'Feel free to pick more than one.',
      name: 'insightsSubtitle',
      desc: '',
      args: [],
    );
  }

  /// `Track my expenses`
  String get goalTrackExpenses {
    return Intl.message(
      'Track my expenses',
      name: 'goalTrackExpenses',
      desc: '',
      args: [],
    );
  }

  /// `Track my income`
  String get goalTrackIncome {
    return Intl.message(
      'Track my income',
      name: 'goalTrackIncome',
      desc: '',
      args: [],
    );
  }

  /// `Create and manage budgets`
  String get goalManageBudgets {
    return Intl.message(
      'Create and manage budgets',
      name: 'goalManageBudgets',
      desc: '',
      args: [],
    );
  }

  /// `Increase savings`
  String get goalIncreaseSavings {
    return Intl.message(
      'Increase savings',
      name: 'goalIncreaseSavings',
      desc: '',
      args: [],
    );
  }

  /// `Get rid of debts`
  String get goalGetRidOfDebts {
    return Intl.message(
      'Get rid of debts',
      name: 'goalGetRidOfDebts',
      desc: '',
      args: [],
    );
  }

  /// `Analyze trends and patterns`
  String get goalAnalyzeTrends {
    return Intl.message(
      'Analyze trends and patterns',
      name: 'goalAnalyzeTrends',
      desc: '',
      args: [],
    );
  }

  /// `Continue`
  String get continueButton {
    return Intl.message('Continue', name: 'continueButton', desc: '', args: []);
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[Locale.fromSubtags(languageCode: 'en')];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<S> load(Locale locale) => S.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
  }
}
