import 'dart:async';
import 'package:expense_app/features/currency/presentation/bloc/currency_bloc/currency_event.dart';
import 'package:expense_app/theme/app_colors.dart';
import 'package:expense_app/widgets/country_item.dart';
import 'package:expense_app/widgets/quanto_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:expense_app/features/currency/domain/entities/currency.dart';
import 'package:expense_app/features/currency/presentation/bloc/currency_bloc/currency_bloc.dart';
import 'package:expense_app/features/currency/presentation/bloc/currency_bloc/currency_state.dart';
import 'package:flutter_svg/svg.dart';
import 'package:expense_app/widgets/quanto_divider.dart';

class CurrencyScreen extends StatefulWidget {
  const CurrencyScreen({super.key});

  @override
  State<CurrencyScreen> createState() => _CurrencyScreenState();
}

class _CurrencyScreenState extends State<CurrencyScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    context.read<CurrencyBloc>().add(const LoadCurrencies());
    _focusNode.addListener(() {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
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
          // Update the selected currency in the BLoC
          context.read<CurrencyBloc>().add(SelectCurrency(currency.code));
        }
      },
    );
  }

  Widget _buildScaffold(CurrencyState state) {
    final background = Container(
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
    );

    if (state is CurrencyLoading || state is CurrencyInitial) {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: Stack(
          children: [
            background,
            const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
          ],
        ),
      );
    }

    if (state is CurrencyError) {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: Stack(
          children: [
            background,
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Failed to load currencies',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                        ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () =>
                        context.read<CurrencyBloc>().add(const LoadCurrencies()),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    if (state is CurrenciesLoaded) {
      final searchQuery = _searchController.text.toLowerCase();
      final filteredCurrencies = state.currencies
          .where((c) =>
              c.countryName.toLowerCase().contains(searchQuery) ||
              c.code.toLowerCase().contains(searchQuery))
          .toList();
      final filteredMostUsed = state.mostUsedCurrencies
          .where((c) =>
              c.countryName.toLowerCase().contains(searchQuery) ||
              c.code.toLowerCase().contains(searchQuery))
          .toList();

      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: Stack(
          children: [
            background,
            SafeArea(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Align(
                    alignment: Alignment.topLeft,
                    child: IconButton(
                      icon: SvgPicture.asset('assets/svg/back_btn.svg'),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: QuantoText.h1(
                      'Currency',
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: TextField(
                      controller: _searchController,
                      focusNode: _focusNode,
                      onChanged: _onSearchChanged,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Search currency',
                        hintStyle: QuantoText.getTextStyle(
                            'Body/B1-R', AppColors.textSecondaryDark),
                        prefixIcon: Padding(
                          padding: const EdgeInsets.only(
                              left: 16, top: 8, bottom: 8, right: 8),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              SvgPicture.asset(
                                'assets/svg/search_ic.svg',
                                color: _isFocused
                                    ? AppColors.bgFgInvertedDark
                                    : AppColors.dark300,
                              ),
                            ],
                          ),
                        ),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.08),
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 14, horizontal: 16),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(
                              color: AppColors.bgFgInvertedDark),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: CustomScrollView(
                      slivers: [
                        if (filteredMostUsed.isNotEmpty)
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16.0, vertical: 8.0),
                              child: QuantoText.bodyLarge(
                                'Most Used',
                                color: const Color(0xFF868A8D),
                              ),
                            ),
                          ),
                        if (filteredMostUsed.isNotEmpty)
                          SliverToBoxAdapter(
                            child: Container(
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              decoration: BoxDecoration(
                                color: AppColors.opacity8,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Column(
                                children: List.generate(filteredMostUsed.length,
                                    (index) {
                                  final currency = filteredMostUsed[index];
                                  final isLast =
                                      index == filteredMostUsed.length - 1;
                                  return Column(
                                    children: [
                                      _buildCurrencyItem(
                                        currency,
                                        currency.code ==
                                            state.selectedCurrency.code,
                                      ),
                                      if (!isLast) const QuantoDivider(),
                                    ],
                                  );
                                }),
                              ),
                            ),
                          ),
                        if (filteredCurrencies.isNotEmpty)
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(
                                  16.0, 24.0, 16.0, 10.0),
                              child: QuantoText.bodyLarge(
                                'All Currencies',
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
                                      currency.code ==
                                          state.selectedCurrency.code,
                                    ),
                                    if (!isLast) const QuantoDivider(),
                                  ],
                                );
                              }),
                            ),
                          ),
                        ),
                        if (filteredCurrencies.isEmpty &&
                            filteredMostUsed.isEmpty)
                          SliverFillRemaining(
                            hasScrollBody: false,
                            child: Center(
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Text(
                                  'No currencies found for "$searchQuery"',
                                  style: TextStyle(
                                    color: Colors.grey[400],
                                    fontSize: 14,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }
    return const SizedBox.shrink(); // Should not happen
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CurrencyBloc, CurrencyState>(
      listener: (context, state) {
        if (state is CurrencyError) {
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
