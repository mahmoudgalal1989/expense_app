import 'package:equatable/equatable.dart';
import '../entities/transaction.dart';
import 'filter_criteria.dart';

/// Result object for bulk deletion operations
class BulkDeletionResult extends Equatable {
  /// Number of transactions that were deleted
  final int deletedCount;
  
  /// List of IDs of the deleted transactions
  final List<String> deletedTransactionIds;
  
  /// When the deletion operation was performed
  final DateTime deletionTimestamp;
  
  /// The filter criteria that was applied for the deletion
  final FilterCriteria appliedFilter;
  
  /// Total amount of deleted transactions (signed amounts)
  final double totalDeletedAmount;

  const BulkDeletionResult({
    required this.deletedCount,
    required this.deletedTransactionIds,
    required this.deletionTimestamp,
    required this.appliedFilter,
    required this.totalDeletedAmount,
  });

  /// Returns true if any transactions were deleted
  bool get hasDeletedTransactions => deletedCount > 0;
  
  /// Returns true if no transactions were deleted
  bool get isEmpty => deletedCount == 0;

  @override
  List<Object?> get props => [
        deletedCount,
        deletedTransactionIds,
        deletionTimestamp,
        appliedFilter,
        totalDeletedAmount,
      ];

  @override
  String toString() {
    return 'BulkDeletionResult('
        'deletedCount: $deletedCount, '
        'totalAmount: $totalDeletedAmount, '
        'timestamp: $deletionTimestamp'
        ')';
  }
}

/// Preview object for bulk deletion operations (before actual deletion)
class BulkDeletionPreview extends Equatable {
  /// Number of transactions that would be affected
  final int affectedCount;
  
  /// Sample transactions that would be deleted (limited for performance)
  final List<Transaction> sampleTransactions;
  
  /// Total amount of transactions that would be deleted (signed amounts)
  final double totalAmountAffected;
  
  /// Map of category IDs to count of affected transactions
  final Map<String, int> categoriesAffected;
  
  /// Set of currency codes that would be affected
  final Set<String> currenciesAffected;
  
  /// The filter criteria that would be applied
  final FilterCriteria appliedFilter;
  
  /// Maximum number of sample transactions shown
  final int maxSampleSize;

  const BulkDeletionPreview({
    required this.affectedCount,
    required this.sampleTransactions,
    required this.totalAmountAffected,
    required this.categoriesAffected,
    required this.currenciesAffected,
    required this.appliedFilter,
    this.maxSampleSize = 10,
  });

  /// Returns true if any transactions would be affected
  bool get hasAffectedTransactions => affectedCount > 0;
  
  /// Returns true if no transactions would be affected
  bool get isEmpty => affectedCount == 0;
  
  /// Returns true if there are more transactions than shown in sample
  bool get hasMoreTransactions => affectedCount > sampleTransactions.length;
  
  /// Returns the number of additional transactions not shown in sample
  int get additionalTransactionCount => 
      hasMoreTransactions ? affectedCount - sampleTransactions.length : 0;
  
  /// Returns true if this is considered a high-impact deletion
  bool get isHighImpact => affectedCount > 50;
  
  /// Returns the number of unique categories affected
  int get uniqueCategoriesCount => categoriesAffected.length;
  
  /// Returns the number of unique currencies affected
  int get uniqueCurrenciesCount => currenciesAffected.length;

  @override
  List<Object?> get props => [
        affectedCount,
        sampleTransactions,
        totalAmountAffected,
        categoriesAffected,
        currenciesAffected,
        appliedFilter,
        maxSampleSize,
      ];

  @override
  String toString() {
    return 'BulkDeletionPreview('
        'affectedCount: $affectedCount, '
        'totalAmount: $totalAmountAffected, '
        'categories: ${uniqueCategoriesCount}, '
        'currencies: ${uniqueCurrenciesCount}'
        ')';
  }
}

/// Statistics object for transaction analysis
class TransactionStatistics extends Equatable {
  /// Total amounts by category ID (signed amounts)
  final Map<String, double> totalsByCategory;
  
  /// Transaction counts by category ID
  final Map<String, int> countsByCategory;
  
  /// Total amounts by currency code (signed amounts)
  final Map<String, double> totalsByCurrency;
  
  /// Transaction counts by currency code
  final Map<String, int> countsByCurrency;
  
  /// Overall total of all transactions (signed amounts)
  final double overallTotal;
  
  /// Overall count of all transactions
  final int overallCount;
  
  /// Total amount of expenses (positive number)
  final double totalExpenses;
  
  /// Total amount of income (positive number)
  final double totalIncome;
  
  /// Count of expense transactions
  final int expenseCount;
  
  /// Count of income transactions
  final int incomeCount;

  const TransactionStatistics({
    required this.totalsByCategory,
    required this.countsByCategory,
    required this.totalsByCurrency,
    required this.countsByCurrency,
    required this.overallTotal,
    required this.overallCount,
    required this.totalExpenses,
    required this.totalIncome,
    required this.expenseCount,
    required this.incomeCount,
  });

  /// Creates empty statistics
  const TransactionStatistics.empty()
      : totalsByCategory = const {},
        countsByCategory = const {},
        totalsByCurrency = const {},
        countsByCurrency = const {},
        overallTotal = 0.0,
        overallCount = 0,
        totalExpenses = 0.0,
        totalIncome = 0.0,
        expenseCount = 0,
        incomeCount = 0;

  /// Returns true if there are any transactions
  bool get hasTransactions => overallCount > 0;
  
  /// Returns true if there are no transactions
  bool get isEmpty => overallCount == 0;
  
  /// Returns the net balance (income - expenses, can be negative)
  double get netBalance => totalIncome - totalExpenses;
  
  /// Returns true if net balance is positive
  bool get hasPositiveBalance => netBalance > 0;
  
  /// Returns the number of unique categories
  int get uniqueCategoriesCount => totalsByCategory.length;
  
  /// Returns the number of unique currencies
  int get uniqueCurrenciesCount => totalsByCurrency.length;
  
  /// Returns the average transaction amount (absolute value)
  double get averageTransactionAmount {
    if (overallCount == 0) return 0.0;
    return (totalExpenses + totalIncome) / overallCount;
  }
  
  /// Returns the average expense amount
  double get averageExpenseAmount {
    if (expenseCount == 0) return 0.0;
    return totalExpenses / expenseCount;
  }
  
  /// Returns the average income amount
  double get averageIncomeAmount {
    if (incomeCount == 0) return 0.0;
    return totalIncome / incomeCount;
  }

  @override
  List<Object?> get props => [
        totalsByCategory,
        countsByCategory,
        totalsByCurrency,
        countsByCurrency,
        overallTotal,
        overallCount,
        totalExpenses,
        totalIncome,
        expenseCount,
        incomeCount,
      ];

  @override
  String toString() {
    return 'TransactionStatistics('
        'count: $overallCount, '
        'total: $overallTotal, '
        'expenses: $totalExpenses, '
        'income: $totalIncome, '
        'balance: $netBalance'
        ')';
  }
}
