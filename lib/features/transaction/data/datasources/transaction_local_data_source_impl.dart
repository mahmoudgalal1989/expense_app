import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/entities/transaction_type.dart';
import '../../domain/enums/category_filter_type.dart';
import '../../domain/value_objects/filter_criteria.dart';
import '../models/transaction_model.dart';
import 'transaction_local_data_source.dart';

/// Implementation of TransactionLocalDataSource using SharedPreferences
/// 
/// This implementation stores transactions as JSON in SharedPreferences
/// and provides efficient filtering and querying capabilities.
class TransactionLocalDataSourceImpl implements TransactionLocalDataSource {
  static const String _transactionsKey = 'transactions';
  
  final SharedPreferences _prefs;
  List<TransactionModel>? _cachedTransactions;

  TransactionLocalDataSourceImpl(this._prefs);

  // ============================================================================
  // READ OPERATIONS
  // ============================================================================

  @override
  Future<List<TransactionModel>> getAllTransactions() async {
    if (_cachedTransactions != null) {
      return List.from(_cachedTransactions!);
    }

    final transactionsJson = _prefs.getString(_transactionsKey);
    if (transactionsJson == null || transactionsJson.isEmpty) {
      _cachedTransactions = [];
      return [];
    }

    try {
      final List<dynamic> jsonList = json.decode(transactionsJson);
      _cachedTransactions = jsonList
          .map((json) => TransactionModel.fromJson(json as Map<String, dynamic>))
          .toList();
      
      // Sort by creation date (newest first)
      _cachedTransactions!.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      
      return List.from(_cachedTransactions!);
    } catch (e) {
      throw Exception('Failed to load transactions: $e');
    }
  }

  @override
  Future<TransactionModel?> getTransactionById(String id) async {
    final transactions = await getAllTransactions();
    try {
      return transactions.firstWhere((t) => t.id == id);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<List<TransactionModel>> getTransactionsByFilter(FilterCriteria criteria) async {
    final allTransactions = await getAllTransactions();
    return _applyFilter(allTransactions, criteria);
  }

  @override
  Future<List<TransactionModel>> getTransactionsByCategories(
    List<String> categoryIds, {
    CategoryFilterType filterType = CategoryFilterType.any,
  }) async {
    final criteria = FilterCriteria(
      categoryIds: categoryIds,
      categoryFilterType: filterType,
    );
    return getTransactionsByFilter(criteria);
  }

  @override
  Future<List<TransactionModel>> getTransactionsByCurrency(String currencyCode) async {
    final criteria = FilterCriteria.forCurrency(currencyCode);
    return getTransactionsByFilter(criteria);
  }

  @override
  Future<List<TransactionModel>> getTransactionsByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final allTransactions = await getAllTransactions();
    return allTransactions.where((transaction) {
      return transaction.createdAt.isAfter(startDate.subtract(const Duration(seconds: 1))) &&
             transaction.createdAt.isBefore(endDate.add(const Duration(seconds: 1)));
    }).toList();
  }

  @override
  Future<List<TransactionModel>> getTransactionsByType(TransactionType type) async {
    final criteria = FilterCriteria.forType(type);
    return getTransactionsByFilter(criteria);
  }

  @override
  Future<int> countTransactionsByFilter(FilterCriteria criteria) async {
    final filteredTransactions = await getTransactionsByFilter(criteria);
    return filteredTransactions.length;
  }

  // ============================================================================
  // WRITE OPERATIONS
  // ============================================================================

  @override
  Future<void> saveTransaction(TransactionModel transaction) async {
    final transactions = await getAllTransactions();
    
    // Check if transaction already exists
    if (transactions.any((t) => t.id == transaction.id)) {
      throw Exception('Transaction with ID ${transaction.id} already exists');
    }
    
    transactions.add(transaction);
    await _saveTransactions(transactions);
  }

  @override
  Future<void> updateTransaction(TransactionModel transaction) async {
    final transactions = await getAllTransactions();
    
    final index = transactions.indexWhere((t) => t.id == transaction.id);
    if (index == -1) {
      throw Exception('Transaction with ID ${transaction.id} not found');
    }
    
    transactions[index] = transaction;
    await _saveTransactions(transactions);
  }

  @override
  Future<void> saveTransactions(List<TransactionModel> transactions) async {
    await _saveTransactions(transactions);
  }

  // ============================================================================
  // DELETE OPERATIONS
  // ============================================================================

  @override
  Future<bool> deleteTransaction(String id) async {
    final transactions = await getAllTransactions();
    
    final initialLength = transactions.length;
    transactions.removeWhere((t) => t.id == id);
    
    if (transactions.length < initialLength) {
      await _saveTransactions(transactions);
      return true;
    }
    
    return false;
  }

  @override
  Future<int> deleteAllTransactions() async {
    final transactions = await getAllTransactions();
    final deletedCount = transactions.length;
    
    await _saveTransactions([]);
    return deletedCount;
  }

  @override
  Future<int> deleteTransactionsByFilter(FilterCriteria criteria) async {
    final allTransactions = await getAllTransactions();
    final transactionsToDelete = _applyFilter(allTransactions, criteria);
    
    final idsToDelete = transactionsToDelete.map((t) => t.id).toSet();
    final remainingTransactions = allTransactions
        .where((t) => !idsToDelete.contains(t.id))
        .toList();
    
    await _saveTransactions(remainingTransactions);
    return transactionsToDelete.length;
  }

  @override
  Future<int> deleteTransactionsByCategories(
    List<String> categoryIds, {
    CategoryFilterType filterType = CategoryFilterType.any,
  }) async {
    final criteria = FilterCriteria(
      categoryIds: categoryIds,
      categoryFilterType: filterType,
    );
    return deleteTransactionsByFilter(criteria);
  }

  @override
  Future<int> deleteTransactionsByCurrency(String currencyCode) async {
    final criteria = FilterCriteria.forCurrency(currencyCode);
    return deleteTransactionsByFilter(criteria);
  }

  @override
  Future<int> deleteTransactionsByDateRange(DateTime startDate, DateTime endDate) async {
    final allTransactions = await getAllTransactions();
    final transactionsToDelete = allTransactions.where((transaction) {
      return transaction.createdAt.isAfter(startDate.subtract(const Duration(seconds: 1))) &&
             transaction.createdAt.isBefore(endDate.add(const Duration(seconds: 1)));
    }).toList();
    
    final idsToDelete = transactionsToDelete.map((t) => t.id).toSet();
    final remainingTransactions = allTransactions
        .where((t) => !idsToDelete.contains(t.id))
        .toList();
    
    await _saveTransactions(remainingTransactions);
    return transactionsToDelete.length;
  }

  @override
  Future<int> deleteTransactionsByType(TransactionType type) async {
    final criteria = FilterCriteria.forType(type);
    return deleteTransactionsByFilter(criteria);
  }

  @override
  Future<int> deleteTransactionsByNote(String noteSearch) async {
    final criteria = FilterCriteria(noteSearch: noteSearch);
    return deleteTransactionsByFilter(criteria);
  }

  @override
  Future<int> deleteTransactionsByAmountRange({
    double? minAmount,
    double? maxAmount,
  }) async {
    final allTransactions = await getAllTransactions();
    final transactionsToDelete = allTransactions.where((transaction) {
      if (minAmount != null && transaction.amount < minAmount) return false;
      if (maxAmount != null && transaction.amount > maxAmount) return false;
      return true;
    }).toList();
    
    final idsToDelete = transactionsToDelete.map((t) => t.id).toSet();
    final remainingTransactions = allTransactions
        .where((t) => !idsToDelete.contains(t.id))
        .toList();
    
    await _saveTransactions(remainingTransactions);
    return transactionsToDelete.length;
  }

  // ============================================================================
  // UTILITY OPERATIONS
  // ============================================================================

  @override
  Future<bool> transactionExists(String id) async {
    final transaction = await getTransactionById(id);
    return transaction != null;
  }

  @override
  Future<int> getTransactionCount() async {
    final transactions = await getAllTransactions();
    return transactions.length;
  }

  @override
  Future<void> clearCache() async {
    _cachedTransactions = null;
  }

  @override
  Future<List<String>> validateStoredData() async {
    final errors = <String>[];
    
    try {
      final transactions = await getAllTransactions();
      
      for (int i = 0; i < transactions.length; i++) {
        final transaction = transactions[i];
        final validationErrors = transaction.getValidationErrors();
        
        if (validationErrors.isNotEmpty) {
          errors.add('Transaction at index $i (${transaction.id}): ${validationErrors.join(', ')}');
        }
      }
      
      // Check for duplicate IDs
      final ids = transactions.map((t) => t.id).toList();
      final uniqueIds = ids.toSet();
      if (ids.length != uniqueIds.length) {
        errors.add('Duplicate transaction IDs found');
      }
      
    } catch (e) {
      errors.add('Failed to validate stored data: $e');
    }
    
    return errors;
  }

  // ============================================================================
  // PRIVATE HELPER METHODS
  // ============================================================================

  /// Saves transactions to SharedPreferences and updates cache
  Future<void> _saveTransactions(List<TransactionModel> transactions) async {
    try {
      final jsonList = transactions.map((t) => t.toJson()).toList();
      final jsonString = json.encode(jsonList);
      
      await _prefs.setString(_transactionsKey, jsonString);
      
      // Update cache
      _cachedTransactions = List.from(transactions);
      _cachedTransactions!.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    } catch (e) {
      throw Exception('Failed to save transactions: $e');
    }
  }

  /// Applies filter criteria to a list of transactions
  List<TransactionModel> _applyFilter(List<TransactionModel> transactions, FilterCriteria criteria) {
    return transactions.where((transaction) {
      // Category filter
      if (criteria.hasCategoryFilter) {
        if (criteria.categoryFilterType == CategoryFilterType.any) {
          // ANY: transaction must have at least one of the specified categories
          final hasAnyCategory = transaction.hasAnyCategory(criteria.categoryIds!);
          if (!hasAnyCategory && !criteria.includeTransactionsWithoutCategories) {
            return false;
          }
          if (!hasAnyCategory && criteria.includeTransactionsWithoutCategories && transaction.hasCategories) {
            return false;
          }
        } else {
          // ALL: transaction must have all of the specified categories
          if (!transaction.hasAllCategories(criteria.categoryIds!)) {
            return false;
          }
        }
      }

      // Currency filter
      if (criteria.hasCurrencyFilter) {
        if (transaction.currencyId != criteria.currencyCode) {
          return false;
        }
      }

      // Date filter
      if (criteria.hasDateFilter) {
        if (!criteria.dateRange!.contains(transaction.createdAt)) {
          return false;
        }
      }

      // Type filter
      if (criteria.hasTypeFilter) {
        if (transaction.type != criteria.type) {
          return false;
        }
      }

      // Note filter
      if (criteria.hasNoteFilter) {
        final note = transaction.note ?? '';
        if (!note.toLowerCase().contains(criteria.noteSearch!.toLowerCase())) {
          return false;
        }
      }

      // Amount filter
      if (criteria.hasAmountFilter) {
        if (!criteria.amountRange!.contains(transaction.amount)) {
          return false;
        }
      }

      return true;
    }).toList();
  }
}
