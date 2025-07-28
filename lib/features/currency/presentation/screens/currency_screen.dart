import 'dart:async';
import 'package:expense_app/features/currency/presentation/bloc/currency_bloc/currency_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:expense_app/features/currency/domain/entities/currency.dart';
import 'package:expense_app/features/currency/presentation/bloc/currency_bloc/currency_bloc.dart';
import 'package:expense_app/features/currency/presentation/bloc/currency_bloc/currency_state.dart';

class CurrencyScreen extends StatefulWidget {
  const CurrencyScreen({super.key});

  @override
  State<CurrencyScreen> createState() => _CurrencyScreenState();
}

class _CurrencyScreenState extends State<CurrencyScreen> {
  // Controller for the search text field
  final _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    // Load currencies when the screen is first opened
    context.read<CurrencyBloc>().add(const LoadCurrencies());
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    // Cancel the previous timer if it exists
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    // Set a new timer to debounce the search
    _debounce = Timer(const Duration(milliseconds: 300), () {
      setState(() {
        // Rebuild the UI with filtered results
      });
    });
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
              : Colors.white,
          fontSize: 16,
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
          Navigator.of(context).pop(currency);
        }
      },
    );
  }

  Widget _buildScaffold(CurrencyState state) {
    // Show loading state
    if (state is CurrencyLoading) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
          ),
        ),
      );
    }

    // Show error state
    if (state is CurrencyError) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
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
      );
    }

    // Show initial state (empty state)
    if (state is! CurrenciesLoaded || state.currencies.isEmpty) {
      return const Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Text(
            'No currencies available',
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    }

    // Get the current search query
    final searchQuery = _searchController.text.toLowerCase();
    
    // Filter currencies based on search query
    final filteredCurrencies = state.currencies.where((currency) {
      if (searchQuery.isEmpty) return true;
      return currency.code.toLowerCase().contains(searchQuery) ||
            currency.countryName.toLowerCase().contains(searchQuery);
    }).toList();
    
    // Filter most used currencies based on search query
    final filteredMostUsed = state.mostUsedCurrencies.where((currency) {
      if (searchQuery.isEmpty) return true;
      return currency.code.toLowerCase().contains(searchQuery) ||
            currency.countryName.toLowerCase().contains(searchQuery);
    }).toList();

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          style: const TextStyle(color: Colors.white, fontSize: 16),
          decoration: InputDecoration(
            hintText: 'Search by code or country',
            hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
            border: InputBorder.none,
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear, color: Colors.white70, size: 20),
                    onPressed: () {
                      _searchController.clear();
                      setState(() {
                        // Rebuild with all currencies
                      });
                    },
                  )
                : null,
          ),
          onChanged: _onSearchChanged,
        ),
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
          onPressed: () => Navigator.of(context).pop(state.selectedCurrency),
        ),
      ),
      body: CustomScrollView(
        slivers: [
          // Most Used Currencies Section (only show if there are results)
          if (filteredMostUsed.isNotEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 8.0, bottom: 8.0),
                child: Text(
                  'Most Used',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                ),
              ),
            ),
          
          if (filteredMostUsed.isNotEmpty)
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => _buildCurrencyItem(
                  filteredMostUsed[index],
                  filteredMostUsed[index].code == state.selectedCurrency.code,
                ),
                childCount: filteredMostUsed.length,
              ),
            ),
          
          // Divider between most used and all currencies
          if (filteredMostUsed.isNotEmpty && filteredCurrencies.isNotEmpty)
            const SliverToBoxAdapter(
              child: Divider(
                height: 8,
                thickness: 1,
                color: Color(0xFF2A2D2E),
              ),
            ),
          
          // All Currencies Section
          if (filteredCurrencies.isNotEmpty && searchQuery.isEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(left: 16.0, right: 16.0, top: 8.0, bottom: 8.0),
                child: Text(
                  'All Currencies',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                ),
              ),
            ),
          
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) => _buildCurrencyItem(
                filteredCurrencies[index],
                filteredCurrencies[index].code == state.selectedCurrency.code,
              ),
              childCount: filteredCurrencies.length,
            ),
          ),
          
          // Empty state when no results
          if (filteredCurrencies.isEmpty && filteredMostUsed.isEmpty)
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
        return _buildScaffold(state);
      },
    );
  }
}
