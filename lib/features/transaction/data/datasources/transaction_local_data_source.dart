import '../../domain/entities/transaction_type.dart';
import '../../domain/enums/category_filter_type.dart';
import '../../domain/value_objects/filter_criteria.dart';
import '../models/transaction_model.dart';

/// Abstract interface for local transaction data operations
/// 
/// This interface defines the contract for local data storage operations
/// such as SharedPreferences, SQLite, or other local storage mechanisms.
abstract class TransactionLocalDataSource {
  // ============================================================================
  // READ OPERATIONS
  // ============================================================================

  /// Retrieves all transactions from local storage
  /// 
  /// Returns a list of all stored transactions
  Future<List<TransactionModel>> getAllTransactions();

  /// Retrieves a specific transaction by its ID
  /// 
  /// Returns the transaction if found, null otherwise
  Future<TransactionModel?> getTransactionById(String id);

  /// Retrieves transactions filtered by the given criteria
  /// 
  /// [criteria] The filter criteria to apply
  /// Returns a list of transactions matching the criteria
  Future<List<TransactionModel>> getTransactionsByFilter(FilterCriteria criteria);

  /// Retrieves transactions that have any of the specified categories
  /// 
  /// [categoryIds] List of category IDs to match against
  /// [filterType] Whether to match ANY or ALL categories
  /// Returns transactions that match the category criteria
  Future<List<TransactionModel>> getTransactionsByCategories(
    List<String> categoryIds, {
    CategoryFilterType filterType = CategoryFilterType.any,
  });

  /// Retrieves transactions for a specific currency
  /// 
  /// [currencyCode] The currency code to filter by
  /// Returns all transactions using the specified currency
  Future<List<TransactionModel>> getTransactionsByCurrency(String currencyCode);

  /// Retrieves transactions within a date range
  /// 
  /// [startDate] Start of the date range (inclusive)
  /// [endDate] End of the date range (inclusive)
  /// Returns transactions created within the specified date range
  Future<List<TransactionModel>> getTransactionsByDateRange(
    DateTime startDate,
    DateTime endDate,
  );

  /// Retrieves transactions of a specific type
  /// 
  /// [type] The transaction type to filter by
  /// Returns all transactions of the specified type
  Future<List<TransactionModel>> getTransactionsByType(TransactionType type);

  /// Counts transactions matching the specified filter criteria
  /// 
  /// [criteria] The filter criteria to count against
  /// Returns the number of transactions that match the criteria
  Future<int> countTransactionsByFilter(FilterCriteria criteria);

  // ============================================================================
  // WRITE OPERATIONS
  // ============================================================================

  /// Saves a new transaction to local storage
  /// 
  /// [transaction] The transaction to save
  /// Throws an exception if a transaction with the same ID already exists
  Future<void> saveTransaction(TransactionModel transaction);

  /// Updates an existing transaction in local storage
  /// 
  /// [transaction] The updated transaction data
  /// Throws an exception if the transaction doesn't exist
  Future<void> updateTransaction(TransactionModel transaction);

  /// Saves multiple transactions to local storage
  /// 
  /// [transactions] List of transactions to save
  /// This is useful for bulk operations and initial data loading
  Future<void> saveTransactions(List<TransactionModel> transactions);

  // ============================================================================
  // DELETE OPERATIONS
  // ============================================================================

  /// Deletes a specific transaction by ID
  /// 
  /// [id] The ID of the transaction to delete
  /// Returns true if the transaction was deleted, false if it didn't exist
  Future<bool> deleteTransaction(String id);

  /// Deletes all transactions from local storage
  /// 
  /// Returns the number of transactions that were deleted
  Future<int> deleteAllTransactions();

  /// Deletes transactions matching the specified filter criteria
  /// 
  /// [criteria] The filter criteria to determine which transactions to delete
  /// Returns the number of transactions that were deleted
  Future<int> deleteTransactionsByFilter(FilterCriteria criteria);

  /// Deletes transactions that have the specified categories
  /// 
  /// [categoryIds] List of category IDs to match against
  /// [filterType] Whether to match ANY or ALL categories
  /// Returns the number of transactions that were deleted
  Future<int> deleteTransactionsByCategories(
    List<String> categoryIds, {
    CategoryFilterType filterType = CategoryFilterType.any,
  });

  /// Deletes all transactions for a specific currency
  /// 
  /// [currencyCode] The currency code to filter by
  /// Returns the number of transactions that were deleted
  Future<int> deleteTransactionsByCurrency(String currencyCode);

  /// Deletes transactions within a date range
  /// 
  /// [startDate] Start of the date range (inclusive)
  /// [endDate] End of the date range (inclusive)
  /// Returns the number of transactions that were deleted
  Future<int> deleteTransactionsByDateRange(DateTime startDate, DateTime endDate);

  /// Deletes transactions of a specific type
  /// 
  /// [type] The transaction type to filter by
  /// Returns the number of transactions that were deleted
  Future<int> deleteTransactionsByType(TransactionType type);

  /// Deletes transactions containing the specified text in their notes
  /// 
  /// [noteSearch] Text to search for in transaction notes (case-insensitive)
  /// Returns the number of transactions that were deleted
  Future<int> deleteTransactionsByNote(String noteSearch);

  /// Deletes transactions within a specific amount range
  /// 
  /// [minAmount] Minimum amount (inclusive, null for no minimum)
  /// [maxAmount] Maximum amount (inclusive, null for no maximum)
  /// Returns the number of transactions that were deleted
  Future<int> deleteTransactionsByAmountRange({
    double? minAmount,
    double? maxAmount,
  });

  // ============================================================================
  // UTILITY OPERATIONS
  // ============================================================================

  /// Checks if a transaction with the given ID exists
  /// 
  /// [id] The transaction ID to check
  /// Returns true if the transaction exists, false otherwise
  Future<bool> transactionExists(String id);

  /// Gets the total number of transactions in storage
  /// 
  /// Returns the total count of all transactions
  Future<int> getTransactionCount();

  /// Clears all cached data and forces a reload from storage
  /// 
  /// This is useful for testing or when storage might have been modified externally
  Future<void> clearCache();

  /// Validates the integrity of stored transaction data
  /// 
  /// Returns a list of validation errors found in the stored data
  Future<List<String>> validateStoredData();
}
