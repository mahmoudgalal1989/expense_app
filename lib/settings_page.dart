import 'package:expense_app/theme/app_colors.dart';
import 'package:expense_app/widgets/setting_item.dart';
import 'package:expense_app/currency_screen.dart';
import 'package:expense_app/services/currency_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String selectedCurrency = ''; // Will be loaded from storage

  @override
  void initState() {
    super.initState();
    _loadSelectedCurrency();
  }

  Future<void> _loadSelectedCurrency() async {
    try {
      final currency = await CurrencyService.getSelectedCurrency();
      if (mounted) {
        setState(() {
          selectedCurrency = currency ?? 'USD'; // Default to USD if null
        });
      }
    } catch (e) {
      // Theme changed
      if (mounted) {
        setState(() {
          selectedCurrency = 'USD'; // Default to USD on error
        });
      }
    }
  }

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
                          SettingItem(
                            title: 'Currency',
                            subtitle: selectedCurrency,
                            svgAsset: 'assets/svg/settings_currency.svg',
                            iconColor: Colors.white,
                            textColor: Colors.white,
                            subtitleColor: AppColors.textSecondary,
                            arrowColor: Colors.white,
                            onTap: () async {
                              final result = await Navigator.push<String>(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const CurrencyScreen(),
                                ),
                              );

                              if (result != null && mounted) {
                                setState(() {
                                  selectedCurrency = result;
                                });
                                // The currency is already saved in the CurrencyScreen
                              }
                            },
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
