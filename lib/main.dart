import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_svg/flutter_svg.dart';

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
                    const SizedBox(height: 40),

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
                          Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    const SizedBox(width: 10),
                                    SvgPicture.asset(
                                      'assets/svg/settings_currency.svg',
                                      color: Colors.white,
                                      width: 36,
                                      height: 36,
                                    ),
                                    const SizedBox(width: 12),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          'Currency',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        Text(
                                          'USD',
                                          style: TextStyle(
                                            color: AppColors.textSecondary,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
                              ],
                          ),
                          const SizedBox(height: 1),

                          // Categories Section
                          // _buildSettingItem(
                          //   context,
                          //   icon: SvgPicture.asset(
                          //             'assets/svg/settings_categories.svg',
                          //             color: Colors.white,
                          //             width: 24,
                          //             height: 24,
                          //           ),,
                          //   title: 'Categories',
                          //   subtitle: '12 Categories',
                          //   onTap: () {},
                          // ),
                          // const Divider(color: AppColors.divider),

                          // Accounts Section
                          _buildSettingItem(
                            context,
                            icon: Icons.account_balance_wallet,
                            title: 'Accounts',
                            subtitle: '2 Accounts',
                            onTap: () {},
                          ),
                          const Divider(color: AppColors.divider),

                          // Reminder Section
                          _buildSettingItem(
                            context,
                            icon: Icons.notifications,
                            title: 'Reminder',
                            subtitle: 'Off',
                            onTap: () {},
                          ),
                          const SizedBox(height: 24),
                        ],
                      ),
                    ),

                    // Erase Data Section
                    _buildSettingItem(
                      context,
                      icon: Icons.delete,
                      title: 'Erase Data',
                      subtitle: 'Delete all transactions',
                      onTap: () {},
                    ),
                    const SizedBox(height: 24),

                    // Feedback Section
                    _buildSettingItem(
                      context,
                      icon: Icons.bug_report,
                      title: 'Report a Bug',
                      onTap: () {},
                    ),
                    const Divider(color: AppColors.divider),

                    _buildSettingItem(
                      context,
                      icon: Icons.lightbulb,
                      title: 'Feature Request',
                      onTap: () {},
                    ),
                    const Divider(color: AppColors.divider),

                    _buildSettingItem(
                      context,
                      icon: Icons.star,
                      title: 'Rate on App Store',
                      onTap: () {},
                    ),
                    const SizedBox(height: 24),

                    // Info Section
                    _buildInfoItem(
                      context,
                      title: 'Version',
                      value: '1.0.0',
                    ),
                    _buildInfoItem(
                      context,
                      title: 'Made with ❤️ by',
                      value: 'Your Name',
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

  Widget _buildSettingItem(BuildContext context, {
    required IconData icon,
    required String title,
    String? subtitle,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 24),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: Colors.white, size: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(BuildContext context, {
    required String title,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
