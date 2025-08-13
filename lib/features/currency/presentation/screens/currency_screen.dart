import 'dart:async';
import 'package:expense_app/theme/app_colors.dart';
import 'package:expense_app/widgets/country_item.dart';
import 'package:expense_app/widgets/quanto_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:expense_app/features/currency/domain/entities/currency.dart';
import 'package:expense_app/core/bloc/app_settings_bloc.dart';
import 'package:expense_app/core/bloc/app_settings_event.dart';
import 'package:expense_app/core/bloc/app_settings_state.dart';
import 'package:flutter_svg/svg.dart';
import 'package:expense_app/widgets/quanto_divider.dart';
import 'package:expense_app/widgets/quanto_button.dart';
import 'package:expense_app/main_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CurrencyScreen extends StatefulWidget {
  const CurrencyScreen({super.key});

  @override
  State<CurrencyScreen> createState() => _CurrencyScreenState();
}

class _CurrencyScreenState extends State<CurrencyScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  Currency? _selectedCurrency;

  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    // Don't initialize here - data should already be loaded from previous screens
    _focusNode.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _focusNode.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      setState(() {});
    });
  }

  Widget _buildCurrencyItem(Currency currency, bool isSelected) {
    return CountryItem(
      title: currency.countryName,
      prefixText: currency.code,
      flagIcon: currency.flagIconPath,
      showTrailingArrow: false,
      textColor: Colors.white,
      prefixTextColor: const Color(0xFF868A8D),
      trailing: isSelected
          ? SizedBox(
              width: 16,
              height: 16,
              child: SvgPicture.asset(
                'assets/svg/check_ic.svg',
              ),
            )
          : null,
      onTap: () {
        if (!isSelected) {
          // Update the selected currency in the global BLoC
          context.read<AppSettingsBloc>().add(CurrencyChanged(currency));

          // Update local state to show the Next button
          setState(() {
            _selectedCurrency = currency;
          });
        }
      },
    );
  }

  Future<void> _completeOnboardingAndNavigate() async {
    // Save onboarding completion status
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_completed', true);

    if (!mounted) return;

    // Navigate to main app with smooth transition
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const MainPage(),
        transitionDuration: const Duration(milliseconds: 600),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
      ),
    );
  }

  Widget _buildScaffold(AppSettingsState state) {
    // If data is not loaded, initialize it but show the UI immediately with cached data
    if (state is AppSettingsLoading || state is AppSettingsInitial) {
      // Trigger initialization if needed
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          context.read<AppSettingsBloc>().add(const InitializeAppSettings());
        }
      });

      // Show loading UI only if absolutely no data is available
      return Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: AppColors.backgroundGradient,
            ),
          ),
          child: const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
        ),
      );
    }

    if (state is AppSettingsError) {
      return Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: AppColors.backgroundGradient,
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                QuantoText(
                  'Failed to load currencies',
                  styleVariant: 'Body/B1-R',
                  color: Colors.white,
                ),
                const SizedBox(height: 16),
                QuantoButton(
                  text: 'Retry',
                  onPressed: () => context
                      .read<AppSettingsBloc>()
                      .add(const InitializeAppSettings()),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (state is AppSettingsLoaded) {
      final currencies = state.availableCurrencies;
      final selectedCurrency = state.selectedCurrency;
      final searchQuery = _searchController.text.toLowerCase();

      // Filter currencies based on search query
      final filteredCurrencies = currencies
          .where((currency) =>
              currency.countryName.toLowerCase().contains(searchQuery) ||
              currency.code.toLowerCase().contains(searchQuery))
          .toList();

      // Get most used currencies (filtered)
      final filteredMostUsed =
          filteredCurrencies.where((currency) => currency.isMostUsed).toList();

      return Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: AppColors.backgroundGradient,
            ),
          ),
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with back button
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: SvgPicture.asset(
                          'assets/svg/back_btn.svg',
                          width: 38,
                          height: 38,
                          colorFilter: const ColorFilter.mode(
                            Colors.white,
                            BlendMode.srcIn,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Title below back button
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                  child: QuantoText(
                    'Select your main currency',
                    styleVariant: 'Header/H1',
                    color: AppColors.textPrimaryDark,
                  ),
                ),

                // Search Bar
                Container(
                  margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  decoration: BoxDecoration(
                    color: AppColors.opacity8,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: TextField(
                    controller: _searchController,
                    focusNode: _focusNode,
                    onChanged: _onSearchChanged,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Search currency',
                      hintStyle: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 16,
                      ),
                      prefixIcon: Icon(
                        Icons.search,
                        color: Colors.grey[400],
                        size: 20,
                      ),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      errorBorder: InputBorder.none,
                      disabledBorder: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                  ),
                ),

                // Currency List
                Expanded(
                  child: CustomScrollView(
                    slivers: [
                      // Most Used Section
                      if (filteredMostUsed.isNotEmpty)
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(
                                16.0, 0.0, 16.0, 10.0),
                            child: QuantoText(
                              'Most used',
                              styleVariant: 'Body/B1-L',
                              color: const Color(0xFF868A8D),
                            ),
                          ),
                        ),
                      SliverToBoxAdapter(
                        child: Container(
                          margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                          decoration: BoxDecoration(
                            color: AppColors.opacity8,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            children:
                                List.generate(filteredMostUsed.length, (index) {
                              final currency = filteredMostUsed[index];
                              final isLast =
                                  index == filteredMostUsed.length - 1;
                              return Column(
                                children: [
                                  _buildCurrencyItem(
                                    currency,
                                    currency.code == selectedCurrency.code ||
                                        _selectedCurrency?.code ==
                                            currency.code,
                                  ),
                                  if (!isLast) const QuantoDivider(),
                                ],
                              );
                            }),
                          ),
                        ),
                      ),
                      // All Currencies
                      if (filteredCurrencies.isNotEmpty)
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(
                                16.0, 24.0, 16.0, 10.0),
                            child: QuantoText(
                              'All currencies',
                              styleVariant: 'Body/B1-L',
                              color: const Color(0xFF868A8D),
                            ),
                          ),
                        ),
                      SliverToBoxAdapter(
                        child: Container(
                          margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                          decoration: BoxDecoration(
                            color: AppColors.opacity8,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            children: List.generate(filteredCurrencies.length,
                                (index) {
                              final currency = filteredCurrencies[index];
                              final isLast =
                                  index == filteredCurrencies.length - 1;
                              return Column(
                                children: [
                                  _buildCurrencyItem(
                                    currency,
                                    currency.code == selectedCurrency.code ||
                                        _selectedCurrency?.code ==
                                            currency.code,
                                  ),
                                  if (!isLast) const QuantoDivider(),
                                ],
                              );
                            }),
                          ),
                        ),
                      ),
                      // No Results
                      if (filteredCurrencies.isEmpty &&
                          filteredMostUsed.isEmpty)
                        SliverFillRemaining(
                          hasScrollBody: false,
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: QuantoText(
                                'No currencies found for "$searchQuery"',
                                styleVariant: 'Body/B1-R',
                                color: Colors.grey[400]!,
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ),
                      // Add bottom padding for the Next button
                      const SliverToBoxAdapter(
                        child: SizedBox(height: 100),
                      ),
                    ],
                  ),
                ),

                // Next Button (shown when currency is selected)
                if (_selectedCurrency != null)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                    child: QuantoButton(
                      text: 'Next',
                      onPressed: _completeOnboardingAndNavigate,
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
    return const SizedBox.shrink(); // Should not happen
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AppSettingsBloc, AppSettingsState>(
      listener: (context, state) {
        if (state is AppSettingsError) {
          if (!ScaffoldMessenger.of(context).mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      builder: (context, state) {
        return _buildScaffold(state);
      },
    );
  }
}
