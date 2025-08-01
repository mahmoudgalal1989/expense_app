import 'package:expense_app/features/currency/presentation/bloc/currency_bloc/currency_event.dart';
import 'package:expense_app/features/currency/presentation/bloc/currency_bloc/currency_state.dart';
import 'package:expense_app/theme/app_colors.dart';
import 'package:expense_app/widgets/setting_item.dart';
import 'package:expense_app/widgets/quanto_divider.dart';
import 'package:expense_app/widgets/quanto_text.dart';
import 'package:expense_app/features/currency/presentation/bloc/currency_bloc/currency_bloc.dart';
import 'package:expense_app/features/currency/presentation/screens/currency_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String selectedCurrency = ''; // Default to empty

  @override
  void initState() {
    super.initState();
    // Load currencies when the page initializes
    context.read<CurrencyBloc>().add(const LoadCurrencies());
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CurrencyBloc, CurrencyState>(
      listener: (context, state) {
        if (state is CurrenciesLoaded) {
          final selected = state.currencies.firstWhere(
            (c) => c.isSelected,
            orElse: () => state.currencies.firstWhere(
              (c) => c.code == selectedCurrency,
              orElse: () => state.currencies.firstWhere(
                (c) => c.code == '',
                orElse: () => state.currencies.first,
              ),
            ),
          );
          if (mounted) {
            setState(() {
              selectedCurrency = selected.code;
            });
          }
        }
      },
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
                                subtitle: selectedCurrency,
                                svgAsset: 'assets/svg/settings_currency.svg',
                                iconColor: Colors.white,
                                textColor: AppColors.textPrimaryDark,
                                subtitleColor: AppColors.textSecondaryLight,
                                arrowColor: Colors.white,
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const CurrencyScreen(),
                                    ),
                                  );
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
                                subtitleColor: AppColors.textSecondary,
                                arrowColor: Colors.white,
                                onTap: () {
                                  // TODO: Implement theme selection
                                },
                              ),
                              const QuantoDivider(),
                              SettingItem(
                                title: 'Accounts',
                                subtitle: '',
                                svgAsset: 'assets/svg/Accounts.svg',
                                iconColor: Colors.white,
                                textColor: Colors.white,
                                subtitleColor: AppColors.textSecondary,
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
                                subtitleColor: AppColors.textSecondary,
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
                                subtitleColor: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.color
                                        ?.withOpacity(0.7) ??
                                    Colors.grey,
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
                                subtitleColor: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.color
                                        ?.withOpacity(0.7) ??
                                    Colors.grey,
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
                                subtitleColor: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.color
                                        ?.withOpacity(0.7) ??
                                    Colors.grey,
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
                                subtitleColor: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.color
                                        ?.withOpacity(0.7) ??
                                    Colors.grey,
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
                              QuantoText(
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
