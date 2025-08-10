import 'package:expense_app/theme/app_colors.dart';
import 'package:expense_app/features/transaction/presentation/bloc/bloc.dart';
import 'package:expense_app/features/transaction/domain/entities/transaction.dart';
import 'package:expense_app/features/transaction/domain/entities/transaction_type.dart';
import 'package:expense_app/features/transaction/presentation/pages/add_transaction_screen.dart';
import 'package:expense_app/core/bloc/app_settings_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:get_it/get_it.dart';

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
  // Font family constant for consistent usage
  static const String fontFamily = 'Sora';

  bool _hasLoadedInitialData = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Load transactions when page initializes (only once)
    if (!_hasLoadedInitialData) {
      _hasLoadedInitialData = true;
      context.read<TransactionBloc>().add(const LoadTransactions());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E2A3A), // Dark blue background
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
          bottom: BorderSide(color: Color(0xFF2F3F4F)),
        ),
          ),
        ],
      ),
    );
  }

  /// Builds the header with title and filter button
  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            AppLocalizations.of(context)?.transactions ?? 'Transactions',
            style: const TextStyle(
              fontSize: 24.0,
              fontWeight: FontWeight.w600,
              color: Colors.white,
              fontFamily: fontFamily,
            ),
          ),
          Row(
            children: [
              // Filter button
              IconButton(
                onPressed: () => _showFilterDialog(context),
                icon: BlocBuilder<TransactionBloc, TransactionState>(
                  builder: (context, state) {
                    final isFiltered = state is TransactionsLoaded && state.isFiltered;
                    return Icon(
                      Icons.filter_list,
                      color: isFiltered 
                          ? Theme.of(context).colorScheme.primary
                          : Colors.white,
                    );
                  },
                ),
              ),
              // Statistics button
              IconButton(
                onPressed: () => _showStatistics(context),
                icon: const Icon(
                  Icons.analytics_outlined,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Builds the transactions list
  Widget _buildTransactionsList(BuildContext context, TransactionsLoaded state) {
    if (state.transactions.isEmpty) {
      return _buildEmptyState(context, isFiltered: state.isFiltered);
    }

    return RefreshIndicator(
      onRefresh: () async {
        context.read<TransactionBloc>().add(const RefreshTransactions());
      },
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        itemCount: state.transactions.length,
        itemBuilder: (context, index) {
          final transaction = state.transactions[index];
          return _buildTransactionItem(context, transaction);
        },
      ),
    );
  }

  /// Builds a single transaction item
  Widget _buildTransactionItem(BuildContext context, Transaction transaction) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8.0),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: transaction.type == TransactionType.expense
              ? Theme.of(context).colorScheme.error.withOpacity(0.1)
              : Theme.of(context).colorScheme.primary.withOpacity(0.1),
          child: Icon(
            transaction.type == TransactionType.expense
                ? Icons.arrow_downward
                : Icons.arrow_upward,
            color: transaction.type == TransactionType.expense
                ? Theme.of(context).colorScheme.error
                : Theme.of(context).colorScheme.primary,
          ),
        ),
        title: Text(
          transaction.note?.isNotEmpty == true
              ? transaction.note!
              : transaction.type.displayName,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontFamily: fontFamily,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (transaction.categoryIds.isNotEmpty)
              Text(
                '${transaction.categoryIds.length} categories',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontSize: 12.0,
                  fontFamily: fontFamily,
                ),
              ),
            Text(
              _formatDate(transaction.createdAt),
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontSize: 12.0,
                fontFamily: fontFamily,
              ),
            ),
          ],
        ),
        trailing: Text(
          '${transaction.signedAmount > 0 ? '+' : ''}${transaction.signedAmount.toStringAsFixed(2)}',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16.0,
            color: transaction.type == TransactionType.expense
                ? Theme.of(context).colorScheme.error
                : Theme.of(context).colorScheme.primary,
            fontFamily: fontFamily,
          ),
        ),
        onTap: () => _showTransactionDetails(context, transaction),
        onLongPress: () => _showTransactionOptions(context, transaction),
      ),
    );
  }

  /// Builds the empty state
  Widget _buildEmptyState(BuildContext context, {bool isFiltered = false}) {
    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Illustration
            SvgPicture.asset(
              'assets/svg/Illustration from Figma.svg',
              width: 343.0,
              height: 217.0,
              fit: BoxFit.contain,
            ),

            const SizedBox(height: 24.0),

            // Main message
            Text(
              isFiltered
                  ? 'No transactions found'
                  : (AppLocalizations.of(context)?.startJourney ??
                      'Let\'s start your journey!'),
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
              isFiltered
                  ? 'Try adjusting your filters'
                  : (AppLocalizations.of(context)?.addFirstTransaction ??
                      'Add your first transaction to start.'),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
                fontSize: 13.0,
                height: 1.5,
                fontFamily: fontFamily,
              ),
            ),

            const SizedBox(height: 24.0),

            // Action button
            if (isFiltered)
              OutlinedButton(
                onPressed: () {
                  context.read<TransactionBloc>().add(const ClearFilters());
                },
                child: const Text('Clear Filters'),
              )
            else
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AddTransactionScreen(),
                    ),
                  );
                },
                child: Text(AppLocalizations.of(context)?.addExpense ?? 'Add expense'),
              ),
          ],
        ),
      ),
    );
  }

  /// Builds the error state
  Widget _buildErrorState(BuildContext context, TransactionError state) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.error_outline,
            size: 64.0,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(height: 16.0),
          Text(
            'Something went wrong',
            style: TextStyle(
              fontSize: 18.0,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).colorScheme.error,
              fontFamily: fontFamily,
            ),
          ),
          const SizedBox(height: 8.0),
          Text(
            state.message,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontFamily: fontFamily,
            ),
          ),
          const SizedBox(height: 24.0),
          OutlinedButton(
            onPressed: () {
              context.read<TransactionBloc>().add(const LoadTransactions());
            },
            child: const Text('Try Again'),
          ),
        ],
      ),
    );
  }

  /// Shows filter dialog
  void _showFilterDialog(BuildContext context) {
    // TODO: Implement filter dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Filter dialog coming soon!'),
      ),
    );
  }

  /// Shows statistics
  void _showStatistics(BuildContext context) {
    context.read<TransactionBloc>().add(const LoadTransactionStatistics());
    // TODO: Navigate to statistics page or show dialog
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Statistics coming soon!'),
      ),
    );
  }

  /// Shows transaction details
  void _showTransactionDetails(BuildContext context, Transaction transaction) {
    // TODO: Navigate to transaction details or show dialog
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Transaction details for ${transaction.id}'),
      ),
    );
  }

  /// Shows transaction options (edit, delete)
  void _showTransactionOptions(BuildContext context, Transaction transaction) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Edit Transaction'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Navigate to edit transaction
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
                color: Theme.of(context).colorScheme.error,
              ),
              title: Text(
                'Delete Transaction',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.error,
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
        title: const Text('Delete Transaction'),
        content: const Text('Are you sure you want to delete this transaction?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<TransactionBloc>().add(
                    DeleteTransaction(transactionId: transaction.id),
                  );
            },
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  /// Formats date for display
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date).inDays;

    if (difference == 0) {
      return 'Today';
    } else if (difference == 1) {
      return 'Yesterday';
    } else if (difference < 7) {
      return '${difference} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
