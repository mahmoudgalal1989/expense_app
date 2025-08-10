import 'package:expense_app/core/bloc/app_settings_bloc.dart';
import 'package:expense_app/core/bloc/app_settings_state.dart';
import 'package:expense_app/theme/app_colors.dart';
import 'package:expense_app/widgets/setting_item.dart';
import 'package:expense_app/widgets/quanto_divider.dart';
import 'package:expense_app/widgets/quanto_text.dart';

import 'package:expense_app/features/currency/presentation/screens/currency_screen.dart';
import 'package:expense_app/features/category/presentation/screens/category_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  @override
  void initState() {
    super.initState();
    // App settings are already initialized by the global BLoC
  }

  String _getCurrencyDisplayText(AppSettingsState state) {
    if (state is AppSettingsLoaded) {
      try {
        final currency = state.selectedCurrency;
        return currency.code;
      } catch (e) {
        return 'Error loading currency';
      }
    } else if (state is AppSettingsLoading) {
      return 'Loading currency...';
    } else if (state is AppSettingsError) {
      return 'Error: ${state.message}';
    } else {
      return 'Select currency';
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppSettingsBloc, AppSettingsState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          body: Stack(
            children: [
              // Background gradient
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppColors.backgroundGradient[0],
                      AppColors.backgroundGradient[1],
                    ],
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
                        const SizedBox(height: 40),
                        QuantoText.h1(
                          AppLocalizations.of(context)!.settingsPageTitle,
                          color: Colors.white,
                        ),
                        const SizedBox(height: 24),

                        // Main Settings Container
                        Container(
                          decoration: BoxDecoration(
                            color: AppColors.opacity8,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Currency Section
                              SettingItem(
                                title: 'Currency',
                                subtitle: _getCurrencyDisplayText(state),
                                svgAsset: 'assets/svg/settings_currency.svg',
                                iconColor: Colors.white,
                                textColor: AppColors.textPrimaryDark,
                                subtitleColor: AppColors.textSecondaryLight,
                                arrowColor: Colors.white,
                                onTap: () async {
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const CurrencyScreen(),
                                    ),
                                  );
                                  // The BLoC listener will handle the update
                                },
                              ),
                              const QuantoDivider(),
                              // Theme Section
                              SettingItem(
                                title: 'Categories',
                                subtitle: '',
                                svgAsset: 'assets/svg/settings_categories.svg',
                                iconColor: Colors.white,
                                textColor: Colors.white,
                                subtitleColor: AppColors.textSecondaryDark,
                                arrowColor: Colors.white,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const CategoryScreen(),
                                    ),
                                  );
                                },
                              ),
                              const QuantoDivider(),
                              SettingItem(
                                title: 'Accounts',
                                subtitle: '',
                                svgAsset: 'assets/svg/Accounts.svg',
                                iconColor: Colors.white,
                                textColor: Colors.white,
                                subtitleColor: AppColors.textSecondaryDark,
                                arrowColor: Colors.white,
                                onTap: () {
                                  // TODO: Implement theme selection
                                },
                              ),
                              const QuantoDivider(),
                              SettingItem(
                                title: 'Reminder',
                                subtitle: 'Never',
                                svgAsset: 'assets/svg/settings_remiders.svg',
                                iconColor: Colors.white,
                                textColor: Colors.white,
                                subtitleColor: AppColors.textSecondaryDark,
                                arrowColor: Colors.white,
                                onTap: () {
                                  // TODO: Implement theme selection
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        Container(
                          decoration: BoxDecoration(
                            color: AppColors.opacity8,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            children: [
                              SettingItem(
                                title: 'Erase data',
                                svgAsset: 'assets/svg/settings_trash.svg',
                                iconColor: Colors.white,
                                textColor: Colors.white,
                                subtitleColor: AppColors.textSecondaryDark,
                                arrowColor: Colors.white,
                                onTap: () {
                                  // TODO: Implement help center
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Support Section
                        Container(
                          decoration: BoxDecoration(
                            color: AppColors.opacity8,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            children: [
                              SettingItem(
                                title: 'Report a bug',
                                svgAsset: 'assets/svg/settings_bug.svg',
                                iconColor: Colors.white,
                                textColor: Colors.white,
                                subtitleColor: AppColors.textSecondaryDark,
                                arrowColor: Colors.white,
                                onTap: () {
                                  // TODO: Implement help center
                                },
                              ),
                              const QuantoDivider(),
                              SettingItem(
                                title: 'Feature request',
                                svgAsset: 'assets/svg/settings_feature.svg',
                                iconColor: Colors.white,
                                textColor: Colors.white,
                                subtitleColor: AppColors.textSecondaryDark,
                                arrowColor: Colors.white,
                                onTap: () {
                                  // TODO: Implement contact us
                                },
                              ),
                              const QuantoDivider(),
                              SettingItem(
                                title: 'Rate on App Store',
                                svgAsset: 'assets/svg/settings_star.svg',
                                iconColor: Colors.white,
                                textColor: Colors.white,
                                subtitleColor: AppColors.textSecondaryDark,
                                arrowColor: Colors.white,
                                onTap: () {
                                  // TODO: Implement privacy policy
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // App Info Section
                        Center(
                          child: Column(
                            children: [
                              const QuantoText(
                                'Version 1.0.0',
                                styleVariant: 'Body/B1-R',
                                color: AppColors.textSecondaryDark,
                              ),
                              const SizedBox(height: 16),
                              RichText(
                                text: TextSpan(
                                  style: QuantoText.getTextStyle(
                                      'Body/B1-R', AppColors.textSecondaryDark),
                                  children: const <TextSpan>[
                                    TextSpan(text: 'Made with '),
                                    TextSpan(
                                        text: '❤️',
                                        style: TextStyle(
                                            color: Color(0xFFF44336))),
                                    TextSpan(text: ' by Alejandro Ausejo'),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
