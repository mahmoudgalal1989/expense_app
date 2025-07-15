import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'widgets/setting_item.dart';

import 'theme/app_colors.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Expense Tracker', // Fallback title
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
      home: Builder(
        builder: (context) {
          // Initialize localization
          final localizations = AppLocalizations.of(context);
          return MainPage(
            title: localizations?.appTitle ?? 'Expense Tracker',
          );
        },
      ),
    );
  }
}

// Main page with bottom navigation
class MainPage extends StatefulWidget {
  final String title;

  const MainPage({
    super.key,
    required this.title,
  });

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
        decoration: const BoxDecoration(
          color: AppColors.bottomNavBar,
          boxShadow: [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 22,
              offset: Offset(0, -1),
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
                  icon: SvgPicture.asset(
                    _selectedIndex == 0
                        ? 'assets/svg/Transactions_active.svg'
                        : 'assets/svg/Transactions_inactive.svg',
                  ),
                  label: AppLocalizations.of(context)!.transactions,
                ),
                BottomNavigationBarItem(
                  icon: SvgPicture.asset(
                    _selectedIndex == 1
                        ? 'assets/svg/Summary_active.svg'
                        : 'assets/svg/Summary_inactive.svg',
                  ),
                  label: AppLocalizations.of(context)!.summary,
                ),
                BottomNavigationBarItem(
                  icon: SvgPicture.asset(
                    _selectedIndex == 2
                        ? 'assets/svg/Settings_active.svg'
                        : 'assets/svg/Settings_inactive.svg',
                  ),
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
                    SvgPicture.asset(
                      'assets/svg/Illustration from Figma.svg',
                      width: 244.0,
                      height: 192.0,
                      fit: BoxFit.contain,
                    ),

                    const SizedBox(height: 24.0),

                    // Main message
                    Text(
                      AppLocalizations.of(context)?.startJourney ??
                          'Let\'s start your journey!',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
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
                      AppLocalizations.of(context)?.addFirstTransaction ??
                          'Add your first transaction to start.',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
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
                              AppLocalizations.of(context)?.addExpense ??
                                  'Add expense',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
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
}

class SummaryPage extends StatelessWidget {
  const SummaryPage({super.key});

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
          // Main content
          SafeArea(
            child: Center(
              child: Text(
                AppLocalizations.of(context)!.summaryPageTitle,
                style: const TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

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
          // Main content
          SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    const SizedBox(height: 24),
                    Text(
                      AppLocalizations.of(context)!.settingsPageTitle,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 25,
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Sora',
                        height: 32 / 25, // line-height: 32px
                        letterSpacing: 0,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Main Settings Container
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.settingsContainerBg,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Currency Section
                          const SettingItem(
                            title: 'Currency',
                            subtitle: 'AED',
                            svgAsset: 'assets/svg/settings_currency.svg',
                            iconColor: Colors.white,
                            textColor: Colors.white,
                            subtitleColor: AppColors.textSecondary,
                            arrowColor: Colors.white,
                          ),
                          Container(color: AppColors.divider, height: 0.5),

                          // Categories Section
                          SettingItem(
                            title: 'Categories',
                            svgAsset: 'assets/svg/settings_categories.svg',
                            iconColor: Colors.white,
                            textColor: Colors.white,
                            subtitleColor: AppColors.textSecondary,
                            arrowColor: Colors.white,
                            onTap: () {},
                          ),
                          Container(color: AppColors.divider, height: 0.5),

                          // Accounts Section
                          SettingItem(
                            title: 'Accounts',
                            svgAsset: 'assets/svg/settings_account.svg',
                            iconColor: Colors.white,
                            textColor: Colors.white,
                            subtitleColor: AppColors.textSecondary,
                            arrowColor: Colors.white,
                            onTap: () {},
                          ),
                          Container(color: AppColors.divider, height: 0.5),

                          // Reminder Section
                          SettingItem(
                            title: 'Reminder',
                            subtitle: 'Never',
                            svgAsset: 'assets/svg/settings_remiders.svg',
                            iconColor: Colors.white,
                            textColor: Colors.white,
                            subtitleColor: AppColors.textSecondary,
                            arrowColor: Colors.white,
                            onTap: () {},
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Erase Data Section
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.settingsContainerBg,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: SettingItem(
                        title: 'Erase Data',
                        svgAsset: 'assets/svg/settings_trash.svg',
                        iconColor: Colors.white,
                        textColor: Colors.white,
                        subtitleColor: AppColors.textSecondary,
                        arrowColor: Colors.white,
                        onTap: () {},
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Feedback Section
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.settingsContainerBg,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        children: [
                          SettingItem(
                            title: 'Report a Bug',
                            svgAsset: 'assets/svg/settings_bug.svg',
                            iconColor: Colors.white,
                            textColor: Colors.white,
                            subtitleColor: AppColors.textSecondary,
                            arrowColor: Colors.white,
                            onTap: () {},
                          ),
                          Container(color: AppColors.divider, height: 0.5),
                          SettingItem(
                            title: 'Feature Request',
                            svgAsset: 'assets/svg/settings_feature.svg',
                            iconColor: Colors.white,
                            textColor: Colors.white,
                            subtitleColor: AppColors.textSecondary,
                            arrowColor: Colors.white,
                            onTap: () {},
                          ),
                          Container(color: AppColors.divider, height: 0.5),
                          SettingItem(
                            title: 'Rate on App Store',
                            svgAsset: 'assets/svg/settings_star.svg',
                            iconColor: Colors.white,
                            textColor: Colors.white,
                            subtitleColor: AppColors.textSecondary,
                            arrowColor: Colors.white,
                            onTap: () {},
                          ),
                        ],
                      ),
                    ),

                    // Info Section
                    // SettingItem(
                    //   title: 'Version',
                    //   subtitle: '1.0.0',
                    //   svgAsset: 'assets/svg/info.svg',
                    //   iconColor: Colors.white,
                    //   textColor: Colors.white,
                    //   subtitleColor: AppColors.textSecondary,
                    //   arrowColor: Colors.white,
                    // ),
                    // SettingItem(
                    //   title: 'Made with ❤️ by',
                    //   subtitle: 'Your Name',
                    //   svgAsset: 'assets/svg/heart.svg',
                    //   iconColor: Colors.white,
                    //   textColor: Colors.white,
                    //   subtitleColor: AppColors.textSecondary,
                    //   arrowColor: Colors.white,
                    // ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
