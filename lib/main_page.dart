import 'package:expense_app/settings_page.dart';
import 'package:expense_app/summary_page.dart';
import 'package:flutter/material.dart';
import 'dart:ui' as ui;

import 'package:expense_app/transactions_page.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'theme/app_colors.dart';


class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget _getCurrentPage() {
    switch (_selectedIndex) {
      case 0:
        return const TransactionsPage();
      case 1:
        return const SummaryPage();
      case 2:
        return const SettingsPage();
      default:
        return const TransactionsPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: _getCurrentPage()),

      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).colorScheme.shadow,
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
              selectedItemColor: AppColors.textPrimaryDark,
              unselectedItemColor: AppColors.textSecondaryDark,
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
