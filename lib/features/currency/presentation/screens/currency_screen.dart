import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:expense_app/features/currency/domain/entities/currency.dart';
import 'package:expense_app/features/currency/presentation/bloc/currency_bloc/currency_bloc.dart';

class CurrencyScreen extends StatefulWidget {
  const CurrencyScreen({super.key});

  @override
  State<CurrencyScreen> createState() => _CurrencyScreenState();
}

class _CurrencyScreenState extends State<CurrencyScreen> {
  @override
  void initState() {
    super.initState();
    // Load currencies when the screen is first opened
    context.read<CurrencyBloc>().add(const LoadCurrencies());
  }

  @override
  void dispose() {
    super.dispose();
    // No need to close the bloc here as it's managed by the provider
  }

  Widget _buildCurrencyItem(Currency currency, bool isSelected) {
    return ListTile(
      leading: Text(
        currency.flagIconPath,
        style: const TextStyle(fontSize: 24),
      ),
      title: Text(
        '${currency.countryName} (${currency.code})',
        style: TextStyle(
          color: isSelected
              ? Theme.of(context).primaryColor
              : Theme.of(context).textTheme.bodyLarge?.color,
        ),
      ),
      trailing: isSelected
          ? Icon(
              Icons.check_circle,
              color: Theme.of(context).primaryColor,
            )
          : null,
      onTap: () {
        if (!isSelected) {
          context.read<CurrencyBloc>().add(SelectCurrency(currency.code));
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CurrencyBloc, CurrencyState>(
      listener: (context, state) {
        if (state is CurrencyError) {
          // Only show error if it's not already being shown
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
        return PopScope(
          canPop: true,
          onPopInvokedWithResult: (didPop, result) {
            if (didPop) return;
            // Get the selected currency before popping
            final selectedCurrency = state is CurrenciesLoaded
                ? state.currencies.firstWhere(
                    (c) => c.isSelected,
                    orElse: () => state.currencies.first,
                  )
                : null;

            Navigator.of(context).pop(selectedCurrency);
          },
          child: _buildScaffold(state),
        );
      },
    );
  }

  Widget _buildScaffold(CurrencyState state) {
    // Show loading indicator
    if (state is CurrencyLoading) {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        ),
      );
    }

    // Show error state
    if (state is CurrencyError) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Failed to load currencies',
                style: Theme.of(context).textTheme.titleMedium,
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
      );
    }

    // Show initial state (empty state)
    if (state is! CurrenciesLoaded || state.currencies.isEmpty) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('No currencies available'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () =>
                    context.read<CurrencyBloc>().add(const LoadCurrencies()),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    // Show loaded state
    final currencies = state.currencies;
    final selectedCurrency = currencies.firstWhere(
      (c) => c.isSelected,
      orElse: () => currencies.first,
    );

    // Get most used currencies from state
    final mostUsedCurrencies = state.mostUsedCurrencies;
    // Get other currencies by filtering out the most used ones
    final otherCurrencies = currencies.where(
      (c) => !mostUsedCurrencies.any((mu) => mu.code == c.code)
    ).toList();

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text(
          'Select Currency',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
            fontFamily: 'Sora',
          ),
        ),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context, selectedCurrency),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search Bar
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextField(
                  style: TextStyle(
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Search currency',
                    hintStyle: TextStyle(color: Colors.grey[400]),
                    border: InputBorder.none,
                    prefixIcon: const Icon(Icons.search, color: Colors.grey),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.close, color: Colors.grey, size: 20),
                      onPressed: () {
                        // Clear search and reload all currencies
                        context.read<CurrencyBloc>().add(const LoadCurrencies());
                      },
                    ),
                  ),
                  onChanged: (value) {
                    // Could be implemented with a SearchCurrencies event
                    // context.read<CurrencyBloc>().add(SearchCurrencies(query: value));
                  },
                ),
              ),

              const SizedBox(height: 24),

              // Most Used Currencies Section
              if (mostUsedCurrencies.isNotEmpty) ...[
                const Padding(
                  padding: EdgeInsets.only(left: 16.0, top: 24.0, bottom: 16.0),
                  child: Text(
                    'Most Used Currencies',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: mostUsedCurrencies.length,
                  separatorBuilder: (context, index) => Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16.0),
                    height: 1,
                    color: Theme.of(context).dividerColor,
                  ),
                  itemBuilder: (context, index) {
                    final currency = mostUsedCurrencies[index];
                    return _buildCurrencyItem(currency, currency.isSelected);
                  },
                ),
              ],

              // All Other Currencies Section
              if (otherCurrencies.isNotEmpty) ...[
                const Padding(
                  padding: EdgeInsets.only(left: 16.0, top: 24.0, bottom: 16.0),
                  child: Text(
                    'All Currencies',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: otherCurrencies.length,
                  separatorBuilder: (context, index) => Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16.0),
                    height: 1,
                    color: Theme.of(context).dividerColor,
                  ),
                  itemBuilder: (context, index) {
                    final currency = otherCurrencies[index];
                    return _buildCurrencyItem(currency, currency.isSelected);
                  },
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
