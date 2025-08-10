import 'package:equatable/equatable.dart';
import '../../domain/entities/transaction.dart';
import '../../domain/entities/transaction_type.dart';
import '../../domain/value_objects/filter_criteria.dart';
import '../../domain/value_objects/result_objects.dart';

/// Base class for all transaction states
abstract class TransactionState extends Equatable {
  const TransactionState();

  @override
  List<Object?> get props => [];
}

// ============================================================================
// LOADING STATES
// ============================================================================

/// Initial state when the BLoC is first created
class TransactionInitial extends TransactionState {
  const TransactionInitial();
}

/// State when transactions are being loaded
class TransactionLoading extends TransactionState {
  const TransactionLoading();
}

/// State when a transaction operation is in progress
class TransactionOperationInProgress extends TransactionState {
  final String operation;

  const TransactionOperationInProgress({required this.operation});

  @override
  List<Object?> get props => [operation];
}

// ============================================================================
// SUCCESS STATES
// ============================================================================

/// State when transactions are successfully loaded
class TransactionsLoaded extends TransactionState {
  final List<Transaction> transactions;
  final FilterCriteria? appliedFilter;
  final bool isFiltered;

  const TransactionsLoaded({
    required this.transactions,
    this.appliedFilter,
    this.isFiltered = false,
  });

  /// Returns true if there are no transactions
  bool get isEmpty => transactions.isEmpty;

  /// Returns true if there are transactions
  bool get hasTransactions => transactions.isNotEmpty;

  /// Returns the number of transactions
  int get transactionCount => transactions.length;

  /// Returns transactions of a specific type
  List<Transaction> getTransactionsByType(TransactionType type) {
    return transactions.where((t) => t.type == type).toList();
  }

  /// Returns expense transactions
  List<Transaction> get expenses => getTransactionsByType(TransactionType.expense);

  /// Returns income transactions
  List<Transaction> get income => getTransactionsByType(TransactionType.income);

  /// Returns total amount (signed)
  double get totalAmount => transactions.fold(0.0, (sum, t) => sum + t.signedAmount);

  /// Returns total expense amount (positive)
  double get totalExpenses => expenses.fold(0.0, (sum, t) => sum + t.amount);

  /// Returns total income amount (positive)
  double get totalIncome => income.fold(0.0, (sum, t) => sum + t.amount);

  /// Creates a copy with updated transactions
  TransactionsLoaded copyWith({
    List<Transaction>? transactions,
    FilterCriteria? appliedFilter,
    bool? isFiltered,
  }) {
    return TransactionsLoaded(
      transactions: transactions ?? this.transactions,
      appliedFilter: appliedFilter ?? this.appliedFilter,
      isFiltered: isFiltered ?? this.isFiltered,
    );
  }

  @override
  List<Object?> get props => [transactions, appliedFilter, isFiltered];
}

/// State when a transaction operation is successful
class TransactionOperationSuccess extends TransactionState {
  final String message;
  final String operation;

  const TransactionOperationSuccess({
    required this.message,
    required this.operation,
  });

  @override
  List<Object?> get props => [message, operation];
}

/// State when transaction statistics are loaded
class TransactionStatisticsLoaded extends TransactionState {
  final TransactionStatistics statistics;
  final FilterCriteria? appliedFilter;

  const TransactionStatisticsLoaded({
    required this.statistics,
    this.appliedFilter,
  });

  @override
  List<Object?> get props => [statistics, appliedFilter];
}

/// State when bulk deletion preview is loaded
class BulkDeletionPreviewLoaded extends TransactionState {
  final BulkDeletionPreview preview;

  const BulkDeletionPreviewLoaded({required this.preview});

  @override
  List<Object?> get props => [preview];
}

/// State when bulk deletion is completed
class BulkDeletionCompleted extends TransactionState {
  final BulkDeletionResult result;

  const BulkDeletionCompleted({required this.result});

  @override
  List<Object?> get props => [result];
}

// ============================================================================
// ERROR STATES
// ============================================================================

/// State when an error occurs
class TransactionError extends TransactionState {
  final String message;
  final String? operation;
  final dynamic error;

  const TransactionError({
    required this.message,
    this.operation,
    this.error,
  });

  @override
  List<Object?> get props => [message, operation, error];
}

/// State when a validation error occurs
class TransactionValidationError extends TransactionState {
  final String message;
  final Map<String, String> fieldErrors;

  const TransactionValidationError({
    required this.message,
    this.fieldErrors = const {},
  });

  @override
  List<Object?> get props => [message, fieldErrors];
}

// ============================================================================
// CONFIRMATION STATES
// ============================================================================

/// State when user confirmation is required for a dangerous operation
class TransactionConfirmationRequired extends TransactionState {
  final String message;
  final String operation;
  final dynamic data;

  const TransactionConfirmationRequired({
    required this.message,
    required this.operation,
    this.data,
  });

  @override
  List<Object?> get props => [message, operation, data];
}
