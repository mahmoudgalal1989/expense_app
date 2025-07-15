import 'package:expense_app/theme/app_colors.dart';
import 'package:expense_app/widgets/setting_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

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
