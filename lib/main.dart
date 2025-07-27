import 'dart:async';
import 'package:expense_app/core/error/failures.dart';
import 'package:expense_app/features/currency/di/currency_injection_container.dart';
import 'package:expense_app/features/currency/presentation/bloc/currency_bloc/currency_bloc.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:expense_app/screens/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'theme/app_theme.dart';

final logger = Logger(
  printer: PrettyPrinter(
    methodCount: 0,
    errorMethodCount: 5,
    lineLength: 50,
    dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
  ),
);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize error handling
  FlutterError.onError = (details) {
    logger.e('Flutter Error: ${details.exception}',
        error: details.exception,
        stackTrace: details.stack,
        time: DateTime.now());
  };

  // Initialize the app with error handling
  runZonedGuarded(
    () async {
      try {
        // Initialize dependency injection
        await initCurrencyFeature();

        // Run the app
        runApp(const MyApp());
      } catch (error, stackTrace) {
        logger.e('Error during app initialization',
            error: error, stackTrace: stackTrace);
        runApp(const ErrorApp());
      }
    },
    (error, stackTrace) {
      logger.e('Uncaught error', error: error, stackTrace: stackTrace);
    },
  );
}

class ErrorApp extends StatelessWidget {
  const ErrorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 60, color: Colors.red),
              const SizedBox(height: 20),
              Text(
                'Oops! Something went wrong.',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 10),
              const Text('Please restart the app.'),
            ],
          ),
        ),
      ),
    );
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      // Initialize the currency bloc
      final currencyBloc = GetIt.instance<CurrencyBloc>();
      currencyBloc.add(const LoadCurrencies());

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } on CacheFailure catch (e) {
      logger.e('Cache error: ${e.message}');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage =
              'Failed to load app data. Please check your connection.';
        });
      }
    } catch (e, stackTrace) {
      debugPrint('Error initializing app: $e\n$stackTrace');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage =
              'An unexpected error occurred. Please restart the app.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Show splash screen while loading
    if (_isLoading) {
      return const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: SplashScreen(),
      );
    }

    // Show error screen if there was an error
    if (_errorMessage != null) {
      return MaterialApp(
        home: Scaffold(
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline,
                      size: 60, color: Colors.orange),
                  const SizedBox(height: 20),
                  Text(
                    'Initialization Error',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _errorMessage!,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _initializeApp,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    // Main app
    return BlocProvider(
      create: (context) => GetIt.instance<CurrencyBloc>(),
      child: MaterialApp(
        title: 'Quanto',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system, // Use system theme mode
        // Localization setup
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('en', ''), // English, no country code
        ],
        home: const SplashScreen(),
      ),
    );
  }
}
