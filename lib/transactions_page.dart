import 'add_expense_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class TransactionsPage extends StatelessWidget {
  const TransactionsPage({super.key});

  // Font family constant for consistent usage
  static const String fontFamily = 'Sora';

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Stack(
        children: [
          // Background gradient
          Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Theme.of(context).colorScheme.primary,
                    Theme.of(context).colorScheme.secondary,
                  ],
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
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
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
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const AddExpenseScreen(),
                              ),
                            );
                          },
                          borderRadius: BorderRadius.circular(16.0),
                          child: Ink(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 16.0),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16.0),
                              border: Border.all(
                                color: Theme.of(context).colorScheme.outline,
                                width: 2.0,
                              ),
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Theme.of(context).colorScheme.primary,
                                  Theme.of(context).colorScheme.secondary,
                                ],
                                stops: const [0.01, 1.0],
                              ),
                            ),
                            child: Text(
                              AppLocalizations.of(context)?.addExpense ??
                                  'Add expense',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onPrimary,
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
