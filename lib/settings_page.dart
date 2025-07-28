import 'package:expense_app/features/currency/presentation/bloc/currency_bloc/currency_event.dart';
import 'package:expense_app/features/currency/presentation/bloc/currency_bloc/currency_state.dart';
import 'package:expense_app/theme/app_colors.dart';
import 'package:expense_app/widgets/setting_item.dart';
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
                            color: Theme.of(context).colorScheme.surface,
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
                              Container(
                                color: Theme.of(context).dividerColor,
                                height: 1,
                              ),
                              // Theme Section
                              SettingItem(
                                title: 'Theme',
                                subtitle: 'System',
                                svgAsset: 'assets/svg/settings_theme.svg',
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

                        // Support Section
                        Container(
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surface,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            children: [
                              SettingItem(
                                title: 'Help Center',
                                svgAsset: 'assets/svg/settings_help.svg',
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
                              Container(
                                color: Theme.of(context).dividerColor,
                                height: 1,
                              ),
                              SettingItem(
                                title: 'Contact Us',
                                svgAsset: 'assets/svg/settings_contact.svg',
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
                              Container(
                                color: Theme.of(context).dividerColor,
                                height: 1,
                              ),
                              SettingItem(
                                title: 'Privacy Policy',
                                svgAsset: 'assets/svg/settings_privacy.svg',
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
                              Container(
                                color: Theme.of(context).dividerColor,
                                height: 1,
                              ),
                              SettingItem(
                                title: 'Terms of Service',
                                svgAsset: 'assets/svg/settings_terms.svg',
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
                                  // TODO: Implement terms of service
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),

                        // App Info Section
                        Container(
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surface,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            children: [
                              SettingItem(
                                title: 'App Version',
                                subtitle: '1.0.0',
                                svgAsset: 'assets/svg/settings_version.svg',
                                iconColor: Colors.white,
                                textColor: Colors.white,
                                subtitleColor: AppColors.textSecondary,
                                arrowColor: Colors.white,
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
