import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../theme/app_colors.dart';
import '../../widgets/quanto_text.dart';
import '../../widgets/quanto_button.dart';
import '../../features/currency/presentation/screens/currency_screen.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class InsightsScreen extends StatefulWidget {
  const InsightsScreen({super.key});

  @override
  State<InsightsScreen> createState() => _InsightsScreenState();
}

class _InsightsScreenState extends State<InsightsScreen> {
  final List<String> _selectedGoals = [];

  List<String> _getGoals(BuildContext context) {
    return [
      AppLocalizations.of(context)!.goalTrackExpenses,
      AppLocalizations.of(context)!.goalTrackIncome,
      AppLocalizations.of(context)!.goalManageBudgets,
      AppLocalizations.of(context)!.goalIncreaseSavings,
      AppLocalizations.of(context)!.goalGetRidOfDebts,
      AppLocalizations.of(context)!.goalAnalyzeTrends,
    ];
  }

  void _toggleGoal(String goal) {
    setState(() {
      if (_selectedGoals.contains(goal)) {
        _selectedGoals.remove(goal);
      } else {
        _selectedGoals.add(goal);
      }
    });
  }

  void _navigateToCurrencySelection() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) => const CurrencyScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Set transparent status bar
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
    );

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: AppColors.backgroundGradient,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(
                  height: 80), // Increased height to account for status bar

              // Title - Header/H1 with 600 weight, size 25, line height 32
              QuantoText(
                AppLocalizations.of(context)!.insightsTitle,
                styleVariant: 'Header/H1',
                color: AppColors.textPrimaryDark,
              ),

              const SizedBox(height: 8),

              // Subtitle
              QuantoText(
                AppLocalizations.of(context)!.insightsSubtitle,
                styleVariant: 'Body/B1-L',
                color: AppColors.textSecondaryDark,
              ),

              // const SizedBox(height: 16),

              // Goals List
              Expanded(
                child: Builder(
                  builder: (context) {
                    final goals = _getGoals(context);
                    return ListView.separated(
                      itemCount: goals.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final goal = goals[index];
                        final isSelected = _selectedGoals.contains(goal);

                        return GestureDetector(
                          onTap: () => _toggleGoal(goal),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: AppColors.opacity8,
                              borderRadius: BorderRadius.circular(16),
                              border: isSelected
                                  ? Border.all(
                                      color: AppColors.borderSelectedDark,
                                      width: 1,
                                    )
                                  : null,
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: QuantoText(
                                    goal,
                                    styleVariant: 'Body/B1-R',
                                    color: AppColors.textPrimaryDark,
                                  ),
                                ),
                                if (isSelected) ...[
                                  const SizedBox(width: 24),
                                  SvgPicture.asset(
                                    'assets/svg/check_ic.svg',
                                    width: 16,
                                    height: 16,
                                  ),
                                ],
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),

              const SizedBox(height: 16),

              // Continue Button (if any goals selected)
              if (_selectedGoals.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 40),
                  child: QuantoButton(
                    onPressed: _navigateToCurrencySelection,
                    text: AppLocalizations.of(context)!.continueButton,
                    buttonType: QuantoButtonType.primary,
                    size: QuantoButtonSize.large,
                    isExpanded: true,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
