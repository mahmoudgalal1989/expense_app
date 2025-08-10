import '../entities/transaction.dart';
import '../entities/transaction_type.dart';
import '../enums/category_filter_type.dart';
import '../value_objects/filter_criteria.dart';
import '../value_objects/result_objects.dart';

/// Abstract repository interface for transaction data operations
/// 
/// This interface defines the contract for all transaction-related data operations
/// following the Repository pattern in Clean Architecture.
abstract class TransactionRepository {
  // ============================================================================
  // READ OPERATIONS
  // ============================================================================

  /// Retrieves all transactions
  /// 
  /// Returns a list of all transactions ordered by creation date (newest first)
  Future<List<Transaction>> getAllTransactions();

  /// Retrieves a specific transaction by its ID
  /// 
  /// Returns the transaction if found, null otherwise
  Future<Transaction?> getTransactionById(String id);

  /// Retrieves transactions filtered by the given criteria
  /// 
  /// [criteria] The filter criteria to apply
  /// Returns a list of transactions matching the criteria
  Future<List<Transaction>> getTransactionsByFilter(FilterCriteria criteria);

  /// Retrieves transactions that have any of the specified categories
  /// 
  /// [categoryIds] List of category IDs to match against
  /// Returns transactions that contain at least one of the specified categories
  Future<List<Transaction>> getTransactionsByCategories(
    List<String> categoryIds, {
    CategoryFilterType filterType = CategoryFilterType.any,
  });

  /// Retrieves transactions for a specific currency
  /// 
  /// [currencyCode] The currency code to filter by
  /// Returns all transactions using the specified currency
  Future<List<Transaction>> getTransactionsByCurrency(String currencyCode);

  /// Retrieves transactions within a date range
  /// 
  /// [startDate] Start of the date range (inclusive)
  /// [endDate] End of the date range (inclusive)
  /// Returns transactions created within the specified date range
  Future<List<Transaction>> getTransactionsByDateRange(
    DateTime startDate,
    DateTime endDate,
  );

  /// Retrieves transactions of a specific type
  /// 
  /// [type] The transaction type to filter by
  /// Returns all transactions of the specified type
  Future<List<Transaction>> getTransactionsByType(TransactionType type);

  /// Retrieves transactions that have ANY of the specified categories (OR logic)
  /// 
  /// [categoryIds] List of category IDs to match against
  /// Returns transactions that contain at least one of the specified categories
  Future<List<Transaction>> getTransactionsWithAnyCategory(List<String> categoryIds);

  /// Retrieves transactions that have ALL of the specified categories (AND logic)
  /// 
  /// [categoryIds] List of category IDs that must all be present
  /// Returns transactions that contain all of the specified categories
  Future<List<Transaction>> getTransactionsWithAllCategories(List<String> categoryIds);

  // ============================================================================
  // WRITE OPERATIONS
  // ============================================================================

  /// Adds a new transaction
  /// 
  /// [transaction] The transaction to add
  /// Throws an exception if a transaction with the same ID already exists
  Future<void> addTransaction(Transaction transaction);

  /// Updates an existing transaction
  /// 
  /// [transaction] The updated transaction data
  /// Throws an exception if the transaction doesn't exist
  Future<void> updateTransaction(Transaction transaction);

  /// Deletes a specific transaction by ID
  /// 
  /// [id] The ID of the transaction to delete
  /// Returns true if the transaction was deleted, false if it didn't exist
  Future<bool> deleteTransaction(String id);

  /// Deletes all transactions (use with caution)
  /// 
  /// Returns the number of transactions that were deleted
  Future<int> deleteAllTransactions();

  // ============================================================================
  // BULK DELETION OPERATIONS
  // ============================================================================

  /// Deletes transactions matching the specified filter criteria
  /// 
  /// [criteria] The filter criteria to determine which transactions to delete
  /// Returns a [BulkDeletionResult] with details about the deletion operation
  Future<BulkDeletionResult> deleteTransactionsByFilter(FilterCriteria criteria);

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
  // PREVIEW OPERATIONS (for safety before bulk deletion)
  // ============================================================================

  /// Previews what would be deleted by the specified filter criteria
  /// 
  /// [criteria] The filter criteria to preview
  /// [maxSampleSize] Maximum number of sample transactions to include
  /// Returns a [BulkDeletionPreview] with details about what would be affected
  Future<BulkDeletionPreview> previewBulkDeletion(
    FilterCriteria criteria, {
    int maxSampleSize = 10,
  });

  /// Counts transactions matching the specified filter criteria
  /// 
  /// [criteria] The filter criteria to count against
  /// Returns the number of transactions that match the criteria
  Future<int> countTransactionsByFilter(FilterCriteria criteria);

  // ============================================================================
  // STATISTICS AND AGGREGATION
  // ============================================================================

  /// Calculates total amount for transactions with the specified categories
  /// 
  /// [categoryIds] List of category IDs to calculate totals for
  /// [filterType] Whether to match ANY or ALL categories
  /// Returns the sum of all matching transaction amounts (signed)
  Future<double> getTotalAmountByCategories(
    List<String> categoryIds, {
    CategoryFilterType filterType = CategoryFilterType.any,
  });

  /// Calculates total amount for transactions in the specified currency
  /// 
  /// [currencyCode] The currency code to calculate totals for
  /// Returns the sum of all matching transaction amounts (signed)
  Future<double> getTotalAmountByCurrency(String currencyCode);

  /// Generates comprehensive statistics for all transactions
  /// 
  /// Returns detailed [TransactionStatistics] with breakdowns by category,
  /// currency, type, and overall totals
  Future<TransactionStatistics> getTransactionStatistics();

  /// Generates statistics for transactions matching the filter criteria
  /// 
  /// [criteria] The filter criteria to generate statistics for
  /// Returns [TransactionStatistics] for the filtered transactions
  Future<TransactionStatistics> getFilteredTransactionStatistics(FilterCriteria criteria);
}
