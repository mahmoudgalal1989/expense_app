import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'theme/app_colors.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppLocalizations.of(context)!.appTitle,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
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
      home: const MainPage(),
    );
  }
}

// Main page with bottom navigation
class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;

  // List of pages to display
  static final List<Widget> _pages = <Widget>[
    const TransactionsPage(),
    const SummaryPage(),
    const SettingsPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: _pages.elementAt(_selectedIndex)),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.bottomNavBar,
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 22,
              offset: const Offset(0, -1),
            ),
          ],
        ),
        child: ClipRRect(
          child: BackdropFilter(
            filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: BottomNavigationBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              type: BottomNavigationBarType.fixed,
              selectedItemColor: AppColors.textPrimary,
              unselectedItemColor: AppColors.navBarUnselected,
              selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500),
              items: [
                BottomNavigationBarItem(
                  icon: const Icon(Icons.receipt),
                  label: AppLocalizations.of(context)!.transactions,
                ),
                BottomNavigationBarItem(
                  icon: const Icon(Icons.bar_chart),
                  label: AppLocalizations.of(context)!.summary,
                ),
                BottomNavigationBarItem(
                  icon: const Icon(Icons.settings),
                  label: AppLocalizations.of(context)!.settings,
                ),
              ],
              currentIndex: _selectedIndex,
              onTap: _onItemTapped,
            ),
          ),
        ),
      ),
    );
  }
}

// Placeholder pages
class TransactionsPage extends StatelessWidget {
  const TransactionsPage({super.key});

  // Font family constant for consistent usage
  static const String fontFamily = 'Sora';

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.backgroundDark,
      child: Stack(
        children: [
          // Background gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: AppColors.backgroundGradient,
              ),
            ),
          ),

          // Main content - Centered with Stack
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Progress Items Container Image
                    Image.asset(
                      'assets/svg/Progress Items Container.png',
                      width: 244.0,
                      height: 192.0,
                      fit: BoxFit.contain,
                    ),

                    const SizedBox(height: 24.0),

                    // Main message
                    Text(
                      AppLocalizations.of(context)!.startJourney,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15.0,
                        fontWeight: FontWeight.w400,
                        height: 1.3,
                        fontFamily: fontFamily,
                      ),
                    ),

                    const SizedBox(height: 8.0),

                    // Subtitle
                    Text(
                      AppLocalizations.of(context)!.addFirstTransaction,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13.0,
                        height: 1.5,
                        fontFamily: fontFamily,
                      ),
                    ),

                    const SizedBox(height: 24.0),

                    // Add expense button
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40.0),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {},
                          borderRadius: BorderRadius.circular(16.0),
                          child: Ink(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 16.0),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16.0),
                              border: Border.all(
                                color: AppColors.borderLight,
                                width: 2.0,
                              ),
                              gradient: const LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: AppColors.buttonGradient,
                                stops: [0.01, 1.0],
                              ),
                            ),
                            child: Text(
                              AppLocalizations.of(context)!.addExpense,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: AppColors.textDark,
                                fontFamily: fontFamily,
                                fontSize: 14.0,
                                fontWeight: FontWeight.w600,
                                height: 24.0 / 14.0,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // TODO: Implement transaction card widget
  // Widget _buildPlaceholderCard() {
  //   return Container(
  //     height: 80.0,
  //     decoration: BoxDecoration(
  //       color: AppColors.cardBackground,
  //       borderRadius: BorderRadius.circular(12.0),
  //       border: Border.all(color: AppColors.divider, width: 1.0),
  //     ),
  //     child: const Opacity(
  //       opacity: 0.3,
  //       child: Center(
  //         child: Text(
  //           'Transaction Card',
  //           style: TextStyle(color: Colors.white),
  //         ),
  //       ),
  //     ),
  //   );
  // }
}

class SummaryPage extends StatelessWidget {
  const SummaryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        AppLocalizations.of(context)!.summaryPageTitle,
        style: const TextStyle(color: Colors.white, fontSize: 24),
      ),
    );
  }
}

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        AppLocalizations.of(context)!.settingsPageTitle,
        style: const TextStyle(color: Colors.white, fontSize: 24),
      ),
    );
  }
}
