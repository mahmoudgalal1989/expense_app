import 'package:equatable/equatable.dart';
import '../../domain/entities/transaction_type.dart';
import '../../domain/value_objects/filter_criteria.dart';

/// Base class for all transaction events
abstract class TransactionEvent extends Equatable {
  const TransactionEvent();

  @override
  List<Object?> get props => [];
}

// ============================================================================
// INITIALIZATION EVENTS
// ============================================================================

/// Event to initialize/load all transactions
class LoadTransactions extends TransactionEvent {
  const LoadTransactions();
}

/// Event to refresh transactions (force reload)
class RefreshTransactions extends TransactionEvent {
  const RefreshTransactions();
}

// ============================================================================
// CRUD EVENTS
// ============================================================================

/// Event to add a new transaction
class AddTransaction extends TransactionEvent {
  final double amount;
  final String? note;
  final List<String> categoryIds;
  final String currencyId;
  final TransactionType type;

  const AddTransaction({
    required this.amount,
    this.note,
    required this.categoryIds,
    required this.currencyId,
    required this.type,
  });

  @override
  List<Object?> get props => [amount, note, categoryIds, currencyId, type];
}

/// Event to update an existing transaction
class UpdateTransaction extends TransactionEvent {
  final String transactionId;
  final double? amount;
  final String? note;
  final List<String>? categoryIds;
  final String? currencyId;
  final TransactionType? type;

  const UpdateTransaction({
    required this.transactionId,
    this.amount,
    this.note,
    this.categoryIds,
    this.currencyId,
    this.type,
  });

  @override
  List<Object?> get props => [transactionId, amount, note, categoryIds, currencyId, type];
}

/// Event to delete a single transaction
class DeleteTransaction extends TransactionEvent {
  final String transactionId;

  const DeleteTransaction({required this.transactionId});

  @override
  List<Object?> get props => [transactionId];
}

// ============================================================================
// FILTERING EVENTS
// ============================================================================

/// Event to apply filters to transactions
class ApplyFilter extends TransactionEvent {
  final FilterCriteria criteria;

  const ApplyFilter({required this.criteria});

  @override
  List<Object?> get props => [criteria];
}

/// Event to clear all filters
class ClearFilters extends TransactionEvent {
  const ClearFilters();
}

// ============================================================================
// CATEGORY MANAGEMENT EVENTS
// ============================================================================

/// Event to add a category to a transaction
class AddCategoryToTransaction extends TransactionEvent {
  final String transactionId;
  final String categoryId;

  const AddCategoryToTransaction({
    required this.transactionId,
    required this.categoryId,
  });

  @override
  List<Object?> get props => [transactionId, categoryId];
}

/// Event to remove a category from a transaction
class RemoveCategoryFromTransaction extends TransactionEvent {
  final String transactionId;
  final String categoryId;

  const RemoveCategoryFromTransaction({
    required this.transactionId,
    required this.categoryId,
  });

  @override
  List<Object?> get props => [transactionId, categoryId];
}

/// Event to replace all categories in a transaction
class ReplaceCategoriesInTransaction extends TransactionEvent {
  final String transactionId;
  final List<String> categoryIds;

  const ReplaceCategoriesInTransaction({
    required this.transactionId,
    required this.categoryIds,
  });

  @override
  List<Object?> get props => [transactionId, categoryIds];
}

// ============================================================================
// BULK OPERATIONS EVENTS
// ============================================================================

/// Event to preview bulk deletion
class PreviewBulkDeletion extends TransactionEvent {
  final FilterCriteria criteria;

  const PreviewBulkDeletion({required this.criteria});

  @override
  List<Object?> get props => [criteria];
}

/// Event to perform bulk deletion
class PerformBulkDeletion extends TransactionEvent {
  final FilterCriteria criteria;
  final bool confirmed;

  const PerformBulkDeletion({
    required this.criteria,
    this.confirmed = false,
  });

  @override
  List<Object?> get props => [criteria, confirmed];
}

// ============================================================================
// STATISTICS EVENTS
// ============================================================================

/// Event to load transaction statistics
class LoadTransactionStatistics extends TransactionEvent {
  final FilterCriteria? criteria;

  const LoadTransactionStatistics({this.criteria});

  @override
  List<Object?> get props => [criteria];
}
