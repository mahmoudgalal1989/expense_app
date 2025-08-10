import '../../domain/entities/transaction.dart';
import '../../domain/entities/transaction_type.dart';
import '../../domain/enums/category_filter_type.dart';
import '../../domain/repositories/transaction_repository.dart';
import '../../domain/value_objects/filter_criteria.dart';
import '../../domain/value_objects/result_objects.dart';
import '../datasources/transaction_local_data_source.dart';
import '../models/transaction_model.dart';

/// Implementation of TransactionRepository
/// 
/// This implementation delegates to the local data source and handles
/// business logic, data transformation, and error handling.
class TransactionRepositoryImpl implements TransactionRepository {
  final TransactionLocalDataSource localDataSource;

  const TransactionRepositoryImpl(this.localDataSource);

  // ============================================================================
  // READ OPERATIONS
  // ============================================================================

  @override
  Future<List<Transaction>> getAllTransactions() async {
    try {
      final models = await localDataSource.getAllTransactions();
      return models.map((model) => model.toEntity()).toList();
    } catch (e) {
      throw Exception('Failed to get all transactions: $e');
    }
  }

  @override
  Future<Transaction?> getTransactionById(String id) async {
    if (id.isEmpty) {
      throw ArgumentError('Transaction ID cannot be empty');
    }

    try {
      final model = await localDataSource.getTransactionById(id);
      return model?.toEntity();
    } catch (e) {
      throw Exception('Failed to get transaction by ID: $e');
    }
  }

  @override
  Future<List<Transaction>> getTransactionsByFilter(FilterCriteria criteria) async {
    try {
      final models = await localDataSource.getTransactionsByFilter(criteria);
      return models.map((model) => model.toEntity()).toList();
    } catch (e) {
      throw Exception('Failed to get transactions by filter: $e');
    }
  }

  @override
  Future<List<Transaction>> getTransactionsByCategories(
    List<String> categoryIds, {
    CategoryFilterType filterType = CategoryFilterType.any,
  }) async {
    if (categoryIds.isEmpty) {
      throw ArgumentError('Category IDs list cannot be empty');
    }

    try {
      final models = await localDataSource.getTransactionsByCategories(
        categoryIds,
        filterType: filterType,
      );
      return models.map((model) => model.toEntity()).toList();
    } catch (e) {
      throw Exception('Failed to get transactions by categories: $e');
    }
  }

  @override
  Future<List<Transaction>> getTransactionsByCurrency(String currencyCode) async {
    if (currencyCode.isEmpty) {
      throw ArgumentError('Currency code cannot be empty');
    }

    try {
      final models = await localDataSource.getTransactionsByCurrency(currencyCode);
      return models.map((model) => model.toEntity()).toList();
    } catch (e) {
      throw Exception('Failed to get transactions by currency: $e');
    }
  }

  @override
  Future<List<Transaction>> getTransactionsByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    if (startDate.isAfter(endDate)) {
      throw ArgumentError('Start date must be before or equal to end date');
    }

    try {
      final models = await localDataSource.getTransactionsByDateRange(startDate, endDate);
      return models.map((model) => model.toEntity()).toList();
    } catch (e) {
      throw Exception('Failed to get transactions by date range: $e');
    }
  }

  @override
  Future<List<Transaction>> getTransactionsByType(TransactionType type) async {
    try {
      final models = await localDataSource.getTransactionsByType(type);
      return models.map((model) => model.toEntity()).toList();
    } catch (e) {
      throw Exception('Failed to get transactions by type: $e');
    }
  }

  @override
  Future<List<Transaction>> getTransactionsWithAnyCategory(List<String> categoryIds) async {
    return getTransactionsByCategories(categoryIds, filterType: CategoryFilterType.any);
  }

  @override
  Future<List<Transaction>> getTransactionsWithAllCategories(List<String> categoryIds) async {
    return getTransactionsByCategories(categoryIds, filterType: CategoryFilterType.all);
  }

  // ============================================================================
  // WRITE OPERATIONS
  // ============================================================================

  @override
  Future<void> addTransaction(Transaction transaction) async {
    try {
      final model = TransactionModel.fromEntity(transaction);
      await localDataSource.saveTransaction(model);
    } catch (e) {
      throw Exception('Failed to add transaction: $e');
    }
  }

  @override
  Future<void> updateTransaction(Transaction transaction) async {
    try {
      final model = TransactionModel.fromEntity(transaction);
      await localDataSource.updateTransaction(model);
    } catch (e) {
      throw Exception('Failed to update transaction: $e');
    }
  }

  @override
  Future<bool> deleteTransaction(String id) async {
    if (id.isEmpty) {
      throw ArgumentError('Transaction ID cannot be empty');
    }

    try {
      return await localDataSource.deleteTransaction(id);
    } catch (e) {
      throw Exception('Failed to delete transaction: $e');
    }
  }

  @override
  Future<int> deleteAllTransactions() async {
    try {
      return await localDataSource.deleteAllTransactions();
    } catch (e) {
      throw Exception('Failed to delete all transactions: $e');
    }
  }

  // ============================================================================
  // BULK DELETION OPERATIONS
  // ============================================================================

  @override
  Future<BulkDeletionResult> deleteTransactionsByFilter(FilterCriteria criteria) async {
    try {
      // Get transactions that will be deleted for the result
      final transactionsToDelete = await localDataSource.getTransactionsByFilter(criteria);
      final deletedIds = transactionsToDelete.map((t) => t.id).toList();
      final totalAmount = transactionsToDelete.fold<double>(
        0.0,
        (sum, t) => sum + t.signedAmount,
      );

      // Perform the deletion
      final deletedCount = await localDataSource.deleteTransactionsByFilter(criteria);

      return BulkDeletionResult(
        deletedCount: deletedCount,
        deletedTransactionIds: deletedIds,
        deletionTimestamp: DateTime.now(),
        appliedFilter: criteria,
        totalDeletedAmount: totalAmount,
      );
    } catch (e) {
      throw Exception('Failed to delete transactions by filter: $e');
    }
  }

  @override
  Future<int> deleteTransactionsByCategories(
    List<String> categoryIds, {
    CategoryFilterType filterType = CategoryFilterType.any,
  }) async {
    if (categoryIds.isEmpty) {
      throw ArgumentError('Category IDs list cannot be empty');
    }

    try {
      return await localDataSource.deleteTransactionsByCategories(
        categoryIds,
        filterType: filterType,
      );
    } catch (e) {
      throw Exception('Failed to delete transactions by categories: $e');
    }
  }

  @override
  Future<int> deleteTransactionsByCurrency(String currencyCode) async {
    if (currencyCode.isEmpty) {
      throw ArgumentError('Currency code cannot be empty');
    }

    try {
      return await localDataSource.deleteTransactionsByCurrency(currencyCode);
    } catch (e) {
      throw Exception('Failed to delete transactions by currency: $e');
    }
  }

  @override
  Future<int> deleteTransactionsByDateRange(DateTime startDate, DateTime endDate) async {
    if (startDate.isAfter(endDate)) {
      throw ArgumentError('Start date must be before or equal to end date');
    }

    try {
      return await localDataSource.deleteTransactionsByDateRange(startDate, endDate);
    } catch (e) {
      throw Exception('Failed to delete transactions by date range: $e');
    }
  }

  @override
  Future<int> deleteTransactionsByType(TransactionType type) async {
    try {
      return await localDataSource.deleteTransactionsByType(type);
    } catch (e) {
      throw Exception('Failed to delete transactions by type: $e');
    }
  }

  @override
  Future<int> deleteTransactionsByNote(String noteSearch) async {
    if (noteSearch.isEmpty) {
      throw ArgumentError('Note search text cannot be empty');
    }

    try {
      return await localDataSource.deleteTransactionsByNote(noteSearch);
    } catch (e) {
      throw Exception('Failed to delete transactions by note: $e');
    }
  }

  @override
  Future<int> deleteTransactionsByAmountRange({
    double? minAmount,
    double? maxAmount,
  }) async {
    if (minAmount != null && maxAmount != null && minAmount > maxAmount) {
      throw ArgumentError('Minimum amount must be less than or equal to maximum amount');
    }

    try {
      return await localDataSource.deleteTransactionsByAmountRange(
        minAmount: minAmount,
        maxAmount: maxAmount,
      );
    } catch (e) {
      throw Exception('Failed to delete transactions by amount range: $e');
    }
  }

  // ============================================================================
  // PREVIEW OPERATIONS
  // ============================================================================

  @override
  Future<BulkDeletionPreview> previewBulkDeletion(
    FilterCriteria criteria, {
    int maxSampleSize = 10,
  }) async {
    try {
      final allMatching = await localDataSource.getTransactionsByFilter(criteria);
      final sampleTransactions = allMatching.take(maxSampleSize).toList();
      
      // Calculate statistics
      final totalAmount = allMatching.fold<double>(0.0, (sum, t) => sum + t.signedAmount);
      
      final categoriesAffected = <String, int>{};
      final currenciesAffected = <String>{};
      
      for (final transaction in allMatching) {
        // Count categories
        for (final categoryId in transaction.categoryIds) {
          categoriesAffected[categoryId] = (categoriesAffected[categoryId] ?? 0) + 1;
        }
        
        // Collect currencies
        currenciesAffected.add(transaction.currencyId);
      }

      return BulkDeletionPreview(
        affectedCount: allMatching.length,
        sampleTransactions: sampleTransactions.map((m) => m.toEntity()).toList(),
        totalAmountAffected: totalAmount,
        categoriesAffected: categoriesAffected,
        currenciesAffected: currenciesAffected,
        appliedFilter: criteria,
        maxSampleSize: maxSampleSize,
      );
    } catch (e) {
      throw Exception('Failed to preview bulk deletion: $e');
    }
  }

  @override
  Future<int> countTransactionsByFilter(FilterCriteria criteria) async {
    try {
      return await localDataSource.countTransactionsByFilter(criteria);
    } catch (e) {
      throw Exception('Failed to count transactions by filter: $e');
    }
  }

  // ============================================================================
  // STATISTICS AND AGGREGATION
  // ============================================================================

  @override
  Future<double> getTotalAmountByCategories(
    List<String> categoryIds, {
    CategoryFilterType filterType = CategoryFilterType.any,
  }) async {
    if (categoryIds.isEmpty) {
      throw ArgumentError('Category IDs list cannot be empty');
    }

    try {
      final transactions = await localDataSource.getTransactionsByCategories(
        categoryIds,
        filterType: filterType,
      );
      return transactions.fold<double>(0.0, (sum, t) => sum + t.signedAmount);
    } catch (e) {
      throw Exception('Failed to get total amount by categories: $e');
    }
  }

  @override
  Future<double> getTotalAmountByCurrency(String currencyCode) async {
    if (currencyCode.isEmpty) {
      throw ArgumentError('Currency code cannot be empty');
    }

    try {
      final transactions = await localDataSource.getTransactionsByCurrency(currencyCode);
      return transactions.fold<double>(0.0, (sum, t) => sum + t.signedAmount);
    } catch (e) {
      throw Exception('Failed to get total amount by currency: $e');
    }
  }

  @override
  Future<TransactionStatistics> getTransactionStatistics() async {
    try {
      final allTransactions = await localDataSource.getAllTransactions();
      return _calculateStatistics(allTransactions);
    } catch (e) {
      throw Exception('Failed to get transaction statistics: $e');
    }
  }

  @override
  Future<TransactionStatistics> getFilteredTransactionStatistics(FilterCriteria criteria) async {
    try {
      final filteredTransactions = await localDataSource.getTransactionsByFilter(criteria);
      return _calculateStatistics(filteredTransactions);
    } catch (e) {
      throw Exception('Failed to get filtered transaction statistics: $e');
    }
  }

  // ============================================================================
  // PRIVATE HELPER METHODS
  // ============================================================================

  /// Calculates comprehensive statistics from a list of transaction models
  TransactionStatistics _calculateStatistics(List<TransactionModel> transactions) {
    if (transactions.isEmpty) {
      return const TransactionStatistics.empty();
    }

    final totalsByCategory = <String, double>{};
    final countsByCategory = <String, int>{};
    final totalsByCurrency = <String, double>{};
    final countsByCurrency = <String, int>{};
    
    double overallTotal = 0.0;
    double totalExpenses = 0.0;
    double totalIncome = 0.0;
    int expenseCount = 0;
    int incomeCount = 0;

    for (final transaction in transactions) {
      final signedAmount = transaction.signedAmount;
      overallTotal += signedAmount;

      // Type-based totals
      if (transaction.isExpense) {
        totalExpenses += transaction.amount;
        expenseCount++;
      } else {
        totalIncome += transaction.amount;
        incomeCount++;
      }

      // Category-based totals
      for (final categoryId in transaction.categoryIds) {
        totalsByCategory[categoryId] = (totalsByCategory[categoryId] ?? 0.0) + signedAmount;
        countsByCategory[categoryId] = (countsByCategory[categoryId] ?? 0) + 1;
      }

      // Currency-based totals
      totalsByCurrency[transaction.currencyId] = 
          (totalsByCurrency[transaction.currencyId] ?? 0.0) + signedAmount;
      countsByCurrency[transaction.currencyId] = 
          (countsByCurrency[transaction.currencyId] ?? 0) + 1;
    }

    return TransactionStatistics(
      totalsByCategory: totalsByCategory,
      countsByCategory: countsByCategory,
      totalsByCurrency: totalsByCurrency,
      countsByCurrency: countsByCurrency,
      overallTotal: overallTotal,
      overallCount: transactions.length,
      totalExpenses: totalExpenses,
      totalIncome: totalIncome,
      expenseCount: expenseCount,
      incomeCount: incomeCount,
    );
  }
}
