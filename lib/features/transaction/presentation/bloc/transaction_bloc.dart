import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/add_transaction.dart' as add_uc;
import '../../domain/usecases/delete_transaction.dart' as delete_uc;
import '../../domain/usecases/delete_transactions_by_filter.dart' as delete_filter_uc;
import '../../domain/usecases/get_transaction_statistics.dart' as stats_uc;
import '../../domain/usecases/get_transactions.dart' as get_uc;
import '../../domain/usecases/get_transactions_by_filter.dart' as get_filter_uc;
import '../../domain/usecases/manage_transaction_categories.dart' as category_uc;
import '../../domain/usecases/preview_bulk_deletion.dart' as preview_uc;
import '../../domain/usecases/update_transaction.dart' as update_uc;
import '../../domain/value_objects/filter_criteria.dart';
import 'transaction_event.dart';
import 'transaction_state.dart';

/// BLoC for managing transaction state and operations
/// 
/// Handles all transaction-related business logic including CRUD operations,
/// filtering, bulk operations, and statistics.
class TransactionBloc extends Bloc<TransactionEvent, TransactionState> {
  // Use Cases
  final get_uc.GetTransactions _getTransactions;
  final get_filter_uc.GetTransactionsByFilter _getTransactionsByFilter;
  final add_uc.AddTransaction _addTransaction;
  final update_uc.UpdateTransaction _updateTransaction;
  final delete_uc.DeleteTransaction _deleteTransaction;
  final delete_filter_uc.DeleteTransactionsByFilter _deleteTransactionsByFilter;
  final preview_uc.PreviewBulkDeletion _previewBulkDeletion;
  final stats_uc.GetTransactionStatistics _getTransactionStatistics;
  final stats_uc.GetFilteredTransactionStatistics _getFilteredTransactionStatistics;
  final category_uc.AddCategoryToTransaction _addCategoryToTransaction;
  final category_uc.RemoveCategoryFromTransaction _removeCategoryFromTransaction;
  final category_uc.ReplaceCategoriesInTransaction _replaceCategoriesInTransaction;

  // Current filter state
  FilterCriteria? _currentFilter;

  TransactionBloc({
    required get_uc.GetTransactions getTransactions,
    required get_filter_uc.GetTransactionsByFilter getTransactionsByFilter,
    required add_uc.AddTransaction addTransaction,
    required update_uc.UpdateTransaction updateTransaction,
    required delete_uc.DeleteTransaction deleteTransaction,
    required delete_filter_uc.DeleteTransactionsByFilter deleteTransactionsByFilter,
    required preview_uc.PreviewBulkDeletion previewBulkDeletion,
    required stats_uc.GetTransactionStatistics getTransactionStatistics,
    required stats_uc.GetFilteredTransactionStatistics getFilteredTransactionStatistics,
    required category_uc.AddCategoryToTransaction addCategoryToTransaction,
    required category_uc.RemoveCategoryFromTransaction removeCategoryFromTransaction,
    required category_uc.ReplaceCategoriesInTransaction replaceCategoriesInTransaction,
  })  : _getTransactions = getTransactions,
        _getTransactionsByFilter = getTransactionsByFilter,
        _addTransaction = addTransaction,
        _updateTransaction = updateTransaction,
        _deleteTransaction = deleteTransaction,
        _deleteTransactionsByFilter = deleteTransactionsByFilter,
        _previewBulkDeletion = previewBulkDeletion,
        _getTransactionStatistics = getTransactionStatistics,
        _getFilteredTransactionStatistics = getFilteredTransactionStatistics,
        _addCategoryToTransaction = addCategoryToTransaction,
        _removeCategoryFromTransaction = removeCategoryFromTransaction,
        _replaceCategoriesInTransaction = replaceCategoriesInTransaction,
        super(const TransactionInitial()) {
    // Register event handlers
    on<LoadTransactions>(_onLoadTransactions);
    on<RefreshTransactions>(_onRefreshTransactions);
    on<AddTransaction>(_onAddTransaction);
    on<UpdateTransaction>(_onUpdateTransaction);
    on<DeleteTransaction>(_onDeleteTransaction);
    on<ApplyFilter>(_onApplyFilter);
    on<ClearFilters>(_onClearFilters);
    on<AddCategoryToTransaction>(_onAddCategoryToTransaction);
    on<RemoveCategoryFromTransaction>(_onRemoveCategoryFromTransaction);
    on<ReplaceCategoriesInTransaction>(_onReplaceCategoriesInTransaction);
    on<PreviewBulkDeletion>(_onPreviewBulkDeletion);
    on<PerformBulkDeletion>(_onPerformBulkDeletion);
    on<LoadTransactionStatistics>(_onLoadTransactionStatistics);
  }

  // ============================================================================
  // EVENT HANDLERS
  // ============================================================================

  /// Handles loading transactions
  Future<void> _onLoadTransactions(
    LoadTransactions event,
    Emitter<TransactionState> emit,
  ) async {
    emit(const TransactionLoading());

    try {
      final transactions = _currentFilter != null
          ? await _getTransactionsByFilter(get_filter_uc.GetTransactionsByFilterParams(
              criteria: _currentFilter!,
            ))
          : await _getTransactions();

      emit(TransactionsLoaded(
        transactions: transactions,
        appliedFilter: _currentFilter,
        isFiltered: _currentFilter != null,
      ));
    } catch (e) {
      emit(TransactionError(
        message: 'Failed to load transactions: ${e.toString()}',
        operation: 'load',
        error: e,
      ));
    }
  }

  /// Handles refreshing transactions
  Future<void> _onRefreshTransactions(
    RefreshTransactions event,
    Emitter<TransactionState> emit,
  ) async {
    // Use the same logic as loading but don't show loading state
    try {
      final transactions = _currentFilter != null
          ? await _getTransactionsByFilter(get_filter_uc.GetTransactionsByFilterParams(
              criteria: _currentFilter!,
            ))
          : await _getTransactions();

      emit(TransactionsLoaded(
        transactions: transactions,
        appliedFilter: _currentFilter,
        isFiltered: _currentFilter != null,
      ));
    } catch (e) {
      emit(TransactionError(
        message: 'Failed to refresh transactions: ${e.toString()}',
        operation: 'refresh',
        error: e,
      ));
    }
  }

  /// Handles adding a new transaction
  Future<void> _onAddTransaction(
    AddTransaction event,
    Emitter<TransactionState> emit,
  ) async {
    emit(const TransactionOperationInProgress(operation: 'Adding transaction'));

    try {
      await _addTransaction(add_uc.AddTransactionParams(
        amount: event.amount,
        note: event.note,
        categoryIds: event.categoryIds,
        currencyId: event.currencyId,
        type: event.type,
      ));

      emit(const TransactionOperationSuccess(
        message: 'Transaction added successfully',
        operation: 'add',
      ));

      // Reload transactions
      add(const LoadTransactions());
    } catch (e) {
      emit(TransactionError(
        message: 'Failed to add transaction: ${e.toString()}',
        operation: 'add',
        error: e,
      ));
    }
  }

  /// Handles updating a transaction
  Future<void> _onUpdateTransaction(
    UpdateTransaction event,
    Emitter<TransactionState> emit,
  ) async {
    emit(const TransactionOperationInProgress(operation: 'Updating transaction'));

    try {
      await _updateTransaction(update_uc.UpdateTransactionParams(
        id: event.transactionId,
        amount: event.amount,
        note: event.note,
        categoryIds: event.categoryIds,
        currencyId: event.currencyId,
        type: event.type,
      ));

      emit(const TransactionOperationSuccess(
        message: 'Transaction updated successfully',
        operation: 'update',
      ));

      // Reload transactions
      add(const LoadTransactions());
    } catch (e) {
      emit(TransactionError(
        message: 'Failed to update transaction: ${e.toString()}',
        operation: 'update',
        error: e,
      ));
    }
  }

  /// Handles deleting a transaction
  Future<void> _onDeleteTransaction(
    DeleteTransaction event,
    Emitter<TransactionState> emit,
  ) async {
    emit(const TransactionOperationInProgress(operation: 'Deleting transaction'));

    try {
      await _deleteTransaction(delete_uc.DeleteTransactionParams.safe(
        id: event.transactionId,
      ));

      emit(const TransactionOperationSuccess(
        message: 'Transaction deleted successfully',
        operation: 'delete',
      ));

      // Reload transactions
      add(const LoadTransactions());
    } catch (e) {
      emit(TransactionError(
        message: 'Failed to delete transaction: ${e.toString()}',
        operation: 'delete',
        error: e,
      ));
    }
  }

  /// Handles applying filters
  Future<void> _onApplyFilter(
    ApplyFilter event,
    Emitter<TransactionState> emit,
  ) async {
    _currentFilter = event.criteria;
    emit(const TransactionLoading());

    try {
      final transactions = await _getTransactionsByFilter(
        get_filter_uc.GetTransactionsByFilterParams(criteria: event.criteria),
      );

      emit(TransactionsLoaded(
        transactions: transactions,
        appliedFilter: event.criteria,
        isFiltered: true,
      ));
    } catch (e) {
      emit(TransactionError(
        message: 'Failed to apply filter: ${e.toString()}',
        operation: 'filter',
        error: e,
      ));
    }
  }

  /// Handles clearing filters
  Future<void> _onClearFilters(
    ClearFilters event,
    Emitter<TransactionState> emit,
  ) async {
    _currentFilter = null;
    add(const LoadTransactions());
  }

  /// Handles adding category to transaction
  Future<void> _onAddCategoryToTransaction(
    AddCategoryToTransaction event,
    Emitter<TransactionState> emit,
  ) async {
    try {
      await _addCategoryToTransaction(category_uc.AddCategoryToTransactionParams(
        transactionId: event.transactionId,
        categoryId: event.categoryId,
        skipIfExists: true,
      ));

      emit(const TransactionOperationSuccess(
        message: 'Category added to transaction',
        operation: 'add_category',
      ));

      // Reload transactions
      add(const LoadTransactions());
    } catch (e) {
      emit(TransactionError(
        message: 'Failed to add category: ${e.toString()}',
        operation: 'add_category',
        error: e,
      ));
    }
  }

  /// Handles removing category from transaction
  Future<void> _onRemoveCategoryFromTransaction(
    RemoveCategoryFromTransaction event,
    Emitter<TransactionState> emit,
  ) async {
    try {
      await _removeCategoryFromTransaction(category_uc.RemoveCategoryFromTransactionParams(
        transactionId: event.transactionId,
        categoryId: event.categoryId,
        skipIfNotExists: true,
      ));

      emit(const TransactionOperationSuccess(
        message: 'Category removed from transaction',
        operation: 'remove_category',
      ));

      // Reload transactions
      add(const LoadTransactions());
    } catch (e) {
      emit(TransactionError(
        message: 'Failed to remove category: ${e.toString()}',
        operation: 'remove_category',
        error: e,
      ));
    }
  }

  /// Handles replacing categories in transaction
  Future<void> _onReplaceCategoriesInTransaction(
    ReplaceCategoriesInTransaction event,
    Emitter<TransactionState> emit,
  ) async {
    try {
      await _replaceCategoriesInTransaction(category_uc.ReplaceCategoriesInTransactionParams(
        transactionId: event.transactionId,
        categoryIds: event.categoryIds,
      ));

      emit(const TransactionOperationSuccess(
        message: 'Transaction categories updated',
        operation: 'replace_categories',
      ));

      // Reload transactions
      add(const LoadTransactions());
    } catch (e) {
      emit(TransactionError(
        message: 'Failed to update categories: ${e.toString()}',
        operation: 'replace_categories',
        error: e,
      ));
    }
  }

  /// Handles bulk deletion preview
  Future<void> _onPreviewBulkDeletion(
    PreviewBulkDeletion event,
    Emitter<TransactionState> emit,
  ) async {
    emit(const TransactionLoading());

    try {
      final preview = await _previewBulkDeletion(
        preview_uc.PreviewBulkDeletionParams(criteria: event.criteria),
      );

      emit(BulkDeletionPreviewLoaded(preview: preview));
    } catch (e) {
      emit(TransactionError(
        message: 'Failed to preview bulk deletion: ${e.toString()}',
        operation: 'preview_bulk_deletion',
        error: e,
      ));
    }
  }

  /// Handles performing bulk deletion
  Future<void> _onPerformBulkDeletion(
    PerformBulkDeletion event,
    Emitter<TransactionState> emit,
  ) async {
    if (!event.confirmed) {
      emit(const TransactionConfirmationRequired(
        message: 'Are you sure you want to delete these transactions?',
        operation: 'bulk_delete',
      ));
      return;
    }

    emit(const TransactionOperationInProgress(operation: 'Deleting transactions'));

    try {
      final result = await _deleteTransactionsByFilter(
        delete_filter_uc.DeleteTransactionsByFilterParams.confirmed(
          criteria: event.criteria,
        ),
      );

      emit(BulkDeletionCompleted(result: result));

      // Reload transactions
      add(const LoadTransactions());
    } catch (e) {
      emit(TransactionError(
        message: 'Failed to perform bulk deletion: ${e.toString()}',
        operation: 'bulk_delete',
        error: e,
      ));
    }
  }

  /// Handles loading transaction statistics
  Future<void> _onLoadTransactionStatistics(
    LoadTransactionStatistics event,
    Emitter<TransactionState> emit,
  ) async {
    emit(const TransactionLoading());

    try {
      final statistics = event.criteria != null
          ? await _getFilteredTransactionStatistics(stats_uc.GetFilteredTransactionStatisticsParams(
              criteria: event.criteria!,
            ))
          : await _getTransactionStatistics.call();

      emit(TransactionStatisticsLoaded(
        statistics: statistics,
        appliedFilter: event.criteria,
      ));
    } catch (e) {
      emit(TransactionError(
        message: 'Failed to load statistics: ${e.toString()}',
        operation: 'load_statistics',
        error: e,
      ));
    }
  }

  // ============================================================================
  // HELPER METHODS
  // ============================================================================

  /// Returns the current filter criteria
  FilterCriteria? get currentFilter => _currentFilter;

  /// Returns true if any filter is currently applied
  bool get isFiltered => _currentFilter != null;
}
