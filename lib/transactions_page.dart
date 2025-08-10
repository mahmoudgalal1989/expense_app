import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import '../core/bloc/app_settings_bloc.dart';
import '../core/bloc/app_settings_state.dart';
import '../features/transaction/domain/entities/transaction.dart';
import '../features/transaction/domain/entities/transaction_type.dart';
import '../features/category/domain/entities/category.dart';
import '../features/transaction/presentation/bloc/transaction_bloc.dart';
import '../features/transaction/presentation/bloc/transaction_event.dart' as transaction_events;
import '../features/transaction/presentation/bloc/transaction_state.dart';
import '../features/transaction/presentation/pages/add_transaction_screen.dart';
import '../theme/app_colors.dart';
import '../widgets/setting_item.dart';
import '../widgets/quanto_divider.dart';

class TransactionsPage extends StatelessWidget {
  const TransactionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<TransactionBloc>(
      create: (context) => GetIt.instance<TransactionBloc>(),
      child: const _TransactionsPageContent(),
    );
  }
}

class _TransactionsPageContent extends StatefulWidget {
  const _TransactionsPageContent();

  @override
  State<_TransactionsPageContent> createState() => _TransactionsPageState();
}

class _TransactionsPageState extends State<_TransactionsPageContent> {
  bool _hasLoadedInitialData = false;
  int _selectedTabIndex = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_hasLoadedInitialData) {
      _hasLoadedInitialData = true;
      context.read<TransactionBloc>().add(const transaction_events.LoadTransactions());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimaryDark, // Dark background from AppColors
      body: SafeArea(
        child: Column(
          children: [
            // Top navigation tabs
            _buildTopNavigation(context),
            
            // Main content
            Expanded(
              child: BlocConsumer<TransactionBloc, TransactionState>(
                listener: (context, state) {
                  if (state is TransactionError) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(state.message),
                        backgroundColor: Colors.red,
                      ),
                    );
                  } else if (state is TransactionOperationSuccess) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(state.message),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                },
                builder: (context, state) {
                  if (state is TransactionLoading) {
                    return const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    );
                  } else if (state is TransactionsLoaded) {
                    return _buildMainContent(context, state);
                  } else if (state is TransactionError) {
                    return _buildErrorState(context, state);
                  } else {
                    return _buildMainContent(context, null);
                  }
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: _buildFloatingActionButton(context),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  /// Builds the top navigation tabs
  Widget _buildTopNavigation(BuildContext context) {
    return Container(
      height: 56.0,
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.borderPrimaryDark),
        ),
      ),
      child: Row(
        children: [
          _buildNavTab('Expenses', 0),
          const SizedBox(width: 24),
          _buildNavTab('Monthly', 1),
          const SizedBox(width: 24),
          _buildNavTab('Accounts', 2),
          const SizedBox(width: 24),
          _buildNavTab('Categories', 3),
        ],
      ),
    );
  }

  Widget _buildNavTab(String title, int index) {
    final isSelected = _selectedTabIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedTabIndex = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.bgSecondaryDark : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: isSelected ? AppColors.textPrimaryDark : AppColors.textSecondaryDark,
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }

  /// Builds the main content area
  Widget _buildMainContent(BuildContext context, TransactionsLoaded? state) {
    return BlocBuilder<AppSettingsBloc, AppSettingsState>(
      builder: (context, appState) {
        String currencySymbol = 'AED';
        if (appState is AppSettingsLoaded) {
          currencySymbol = appState.selectedCurrency.symbol;
        }

        return Column(
          children: [
            // Amount display section
            _buildAmountSection(currencySymbol, state),
            
            // Chart section
            _buildChartSection(),
            
            // Transactions list
            Expanded(
              child: _buildTransactionsList(state, currencySymbol, appState is AppSettingsLoaded ? appState : null),
            ),
          ],
        );
      },
    );
  }

  Widget _buildAmountSection(String currencySymbol, TransactionsLoaded? state) {
    // Calculate total expenses for the month
    double totalExpenses = 0;
    if (state != null) {
      final now = DateTime.now();
      final thisMonth = DateTime(now.year, now.month);
      final nextMonth = DateTime(now.year, now.month + 1);
      
      totalExpenses = state.transactions
          .where((t) => t.type == TransactionType.expense && 
                      t.createdAt.isAfter(thisMonth) && 
                      t.createdAt.isBefore(nextMonth))
          .fold(0, (sum, t) => sum + t.amount);
    }

    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$currencySymbol ${totalExpenses.toStringAsFixed(0).replaceAllMapped(
              RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), 
              (Match m) => '${m[1]},',
            )}',
            style: const TextStyle(
              color: AppColors.textPrimaryDark,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Expenses this month',
            style: TextStyle(
              color: Color(0xFF8A9BA8),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartSection() {
    return Container(
      height: 120,
      margin: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Chart bars - simplified representation
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(31, (index) {
                final height = (index % 7 == 0 || index % 7 == 1) ? 80.0 : 20.0;
                return Expanded(
                  child: Container(
                    height: height,
                    margin: const EdgeInsets.symmetric(horizontal: 1),
                    decoration: BoxDecoration(
                      color: (index % 7 == 0 || index % 7 == 1) 
                          ? AppColors.textPrimaryDark 
                          : AppColors.bgSecondaryDark,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                );
              }),
            ),
          ),
          // Y-axis labels
          const SizedBox(width: 16),
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text('5.0k', style: TextStyle(color: Color(0xFF8A9BA8), fontSize: 12)),
              Text('2.5k', style: TextStyle(color: Color(0xFF8A9BA8), fontSize: 12)),
              Text('0', style: TextStyle(color: Color(0xFF8A9BA8), fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionsList(TransactionsLoaded? state, String currencySymbol, AppSettingsLoaded? settingsState) {
    if (state == null || state.transactions.isEmpty) {
      return _buildEmptyState();
    }

    // Group transactions by date
    final groupedTransactions = <String, List<Transaction>>{};
    for (final transaction in state.transactions) {
      final dateKey = _formatDateKey(transaction.createdAt);
      groupedTransactions.putIfAbsent(dateKey, () => []).add(transaction);
    }

    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: groupedTransactions.length,
      itemBuilder: (context, index) {
        final dateKey = groupedTransactions.keys.elementAt(index);
        final transactions = groupedTransactions[dateKey]!;
        final totalForDay = transactions.fold(0.0, (sum, t) => sum + t.amount);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date header
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    dateKey,
                    style: const TextStyle(
                      color: Color(0xFF8A9BA8),
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    '$currencySymbol ${totalForDay.toStringAsFixed(0).replaceAllMapped(
                      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), 
                      (Match m) => '${m[1]},',
                    )}',
                    style: const TextStyle(
                      color: Color(0xFF8A9BA8),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            // Transaction items container
            Container(
              decoration: BoxDecoration(
                color: AppColors.opacity8,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: transactions.asMap().entries.map((entry) {
                  final index = entry.key;
                  final transaction = entry.value;
                  return Column(
                    children: [
                      _buildTransactionItem(transaction, currencySymbol, settingsState!),
                      if (index < transactions.length - 1)
                        const QuantoDivider(),
                    ],
                  );
                }).toList(),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTransactionItem(Transaction transaction, String currencySymbol, AppSettingsLoaded settingsState) {
    final formattedAmount = '$currencySymbol ${transaction.amount.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), 
      (Match m) => '${m[1]},',
    )}';
    
    // Get category information
    String categoryName = 'Uncategorized';
    String categoryIcon = '👻'; // Ghost emoji for uncategorized
    
    if (transaction.categoryIds.isNotEmpty) {
      // Get the first category (since we're moving to single selection)
      final categoryId = transaction.categoryIds.first;
      final allCategories = [...settingsState.expenseCategories, ...settingsState.incomeCategories];
      final category = allCategories.firstWhere(
        (cat) => cat.id == categoryId,
        orElse: () => Category(
          id: 'unknown',
          name: 'Unknown Category',
          icon: '❓',
          type: transaction.type == TransactionType.expense ? CategoryType.expense : CategoryType.income,
        ),
      );
      categoryName = category.name;
      categoryIcon = category.icon;
    }
    
    final subtitle = transaction.note?.isNotEmpty == true ? transaction.note : null;

    return SettingItem(
      title: categoryName,
      subtitle: subtitle,
      prefixText: formattedAmount,
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: AppColors.bgSecondaryDark,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            categoryIcon,
            style: const TextStyle(
              fontSize: 20,
            ),
          ),
        ),
      ),
      textColor: AppColors.textPrimaryDark,
      subtitleColor: AppColors.textSecondaryDark,
      prefixTextColor: AppColors.textPrimaryDark,
      showTrailingArrow: false,
      onTap: () => _showTransactionOptions(context, transaction),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long,
            size: 64,
            color: Color(0xFF8A9BA8),
          ),
          SizedBox(height: 16),
          Text(
            'No transactions yet',
            style: TextStyle(
              color: Color(0xFF8A9BA8),
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Add your first transaction to get started',
            style: TextStyle(
              color: Color(0xFF8A9BA8),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, TransactionError state) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red,
          ),
          const SizedBox(height: 16),
          Text(
            'Error loading transactions',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            state.message,
            style: const TextStyle(
              color: Color(0xFF8A9BA8),
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              context.read<TransactionBloc>().add(const transaction_events.LoadTransactions());
            },
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingActionButton(BuildContext context) {
    return FloatingActionButton(
      onPressed: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const AddTransactionScreen(),
          ),
        );
        
        if (result == true && mounted) {
          context.read<TransactionBloc>().add(const transaction_events.LoadTransactions());
        }
      },
      backgroundColor: Colors.white,
      child: const Icon(
        Icons.add,
        color: Color(0xFF1E2A3A),
        size: 28,
      ),
    );
  }

  /// Shows transaction options (edit, delete)
  void _showTransactionOptions(BuildContext context, Transaction transaction) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.bgSecondaryDark,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(
                Icons.edit,
                color: AppColors.textPrimaryDark,
              ),
              title: Text(
                'Edit Transaction',
                style: TextStyle(
                  color: AppColors.textPrimaryDark,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Edit transaction coming soon!'),
                  ),
                );
              },
            ),
            ListTile(
              leading: Icon(
                Icons.delete,
                color: AppColors.error300,
              ),
              title: Text(
                'Delete Transaction',
                style: TextStyle(
                  color: AppColors.error300,
                ),
              ),
              onTap: () {
                Navigator.pop(context);
                _confirmDeleteTransaction(context, transaction);
              },
            ),
          ],
        ),
      ),
    );
  }

  /// Confirms transaction deletion
  void _confirmDeleteTransaction(BuildContext context, Transaction transaction) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.bgSecondaryDark,
        title: Text(
          'Delete Transaction',
          style: TextStyle(color: AppColors.textPrimaryDark),
        ),
        content: Text(
          'Are you sure you want to delete this transaction?',
          style: TextStyle(color: AppColors.textSecondaryDark),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(color: AppColors.textSecondaryDark),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<TransactionBloc>().add(
                    transaction_events.DeleteTransaction(transactionId: transaction.id),
                  );
            },
            child: Text(
              'Delete',
              style: TextStyle(color: AppColors.error300),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateKey(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date).inDays;

    if (difference == 0) {
      return 'Today';
    } else if (difference == 1) {
      return 'Yesterday';
    } else if (difference < 7) {
      final weekdays = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
      return weekdays[date.weekday - 1];
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
