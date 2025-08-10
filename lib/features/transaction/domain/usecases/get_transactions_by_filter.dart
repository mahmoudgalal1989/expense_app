import '../../../../core/usecases/usecase.dart';
import '../entities/transaction.dart';
import '../repositories/transaction_repository.dart';
import '../value_objects/filter_criteria.dart';

/// Use case for retrieving transactions with filtering capabilities
/// 
/// Supports complex filtering by categories, currency, date range, type,
/// note content, and amount range with various combination options.
class GetTransactionsByFilter implements UseCase<List<Transaction>, GetTransactionsByFilterParams> {
  final TransactionRepository repository;

  const GetTransactionsByFilter(this.repository);

  @override
  Future<List<Transaction>> call(GetTransactionsByFilterParams params) async {
    // Validate filter criteria
    _validateFilterCriteria(params.criteria);

    try {
      final transactions = await repository.getTransactionsByFilter(params.criteria);
      
      // Apply additional sorting based on sort criteria
      _sortTransactions(transactions, params.sortBy, params.sortOrder);
      
      // Apply pagination if specified
      if (params.limit != null || params.offset != null) {
        return _paginateTransactions(transactions, params.offset ?? 0, params.limit);
      }
      
      return transactions;
    } catch (e) {
      throw Exception('Failed to retrieve filtered transactions: $e');
    }
  }

  /// Validates the filter criteria
  void _validateFilterCriteria(FilterCriteria criteria) {
    // Validate date range if present
    if (criteria.hasDateFilter && !criteria.dateRange!.isValid) {
      throw ArgumentError('Invalid date range: start date must be before or equal to end date');
    }

    // Validate amount range if present
    if (criteria.hasAmountFilter && !criteria.amountRange!.isValid) {
      throw ArgumentError('Invalid amount range: minimum amount must be less than or equal to maximum amount');
    }

    // Validate category IDs if present
    if (criteria.hasCategoryFilter) {
      for (final categoryId in criteria.categoryIds!) {
        if (categoryId.isEmpty) {
          throw ArgumentError('Category ID cannot be empty');
        }
      }
    }

    // Validate currency code if present
    if (criteria.hasCurrencyFilter && criteria.currencyCode!.isEmpty) {
      throw ArgumentError('Currency code cannot be empty');
    }
  }

  /// Sorts transactions based on the specified criteria
  void _sortTransactions(
    List<Transaction> transactions,
    TransactionSortBy sortBy,
    SortOrder sortOrder,
  ) {
    transactions.sort((a, b) {
      int comparison;
      
      switch (sortBy) {
        case TransactionSortBy.createdAt:
          comparison = a.createdAt.compareTo(b.createdAt);
          break;
        case TransactionSortBy.amount:
          comparison = a.amount.compareTo(b.amount);
          break;
        case TransactionSortBy.type:
          comparison = a.type.index.compareTo(b.type.index);
          break;
        case TransactionSortBy.currency:
          comparison = a.currencyId.compareTo(b.currencyId);
          break;
        case TransactionSortBy.note:
          final noteA = a.note ?? '';
          final noteB = b.note ?? '';
          comparison = noteA.compareTo(noteB);
          break;
      }
      
      return sortOrder == SortOrder.ascending ? comparison : -comparison;
    });
  }

  /// Applies pagination to the transaction list
  List<Transaction> _paginateTransactions(
    List<Transaction> transactions,
    int offset,
    int? limit,
  ) {
    if (offset >= transactions.length) {
      return [];
    }
    
    final startIndex = offset;
    final endIndex = limit != null 
        ? (offset + limit).clamp(0, transactions.length)
        : transactions.length;
    
    return transactions.sublist(startIndex, endIndex);
  }
}

/// Parameters for filtering transactions
class GetTransactionsByFilterParams extends UseCaseParams {
  /// The filter criteria to apply
  final FilterCriteria criteria;
  
  /// How to sort the results
  final TransactionSortBy sortBy;
  
  /// Sort order (ascending or descending)
  final SortOrder sortOrder;
  
  /// Maximum number of results to return (null for no limit)
  final int? limit;
  
  /// Number of results to skip (for pagination)
  final int? offset;

  const GetTransactionsByFilterParams({
    required this.criteria,
    this.sortBy = TransactionSortBy.createdAt,
    this.sortOrder = SortOrder.descending,
    this.limit,
    this.offset,
  });

  /// Creates parameters with empty filter (returns all transactions)
  const GetTransactionsByFilterParams.all({
    TransactionSortBy sortBy = TransactionSortBy.createdAt,
    SortOrder sortOrder = SortOrder.descending,
    int? limit,
    int? offset,
  }) : this(
          criteria: const FilterCriteria.empty(),
          sortBy: sortBy,
          sortOrder: sortOrder,
          limit: limit,
          offset: offset,
        );

  @override
  List<Object?> get props => [criteria, sortBy, sortOrder, limit, offset];

  @override
  String toString() {
    return 'GetTransactionsByFilterParams('
        'criteria: $criteria, '
        'sortBy: $sortBy, '
        'sortOrder: $sortOrder, '
        'limit: $limit, '
        'offset: $offset'
        ')';
  }
}

/// Enum for transaction sorting options
enum TransactionSortBy {
  createdAt,
  amount,
  type,
  currency,
  note,
}

/// Enum for sort order
enum SortOrder {
  ascending,
  descending,
}

/// Extension for TransactionSortBy
extension TransactionSortByExtension on TransactionSortBy {
  String get displayName {
    switch (this) {
      case TransactionSortBy.createdAt:
        return 'Date Created';
      case TransactionSortBy.amount:
        return 'Amount';
      case TransactionSortBy.type:
        return 'Type';
      case TransactionSortBy.currency:
        return 'Currency';
      case TransactionSortBy.note:
        return 'Note';
    }
  }
}

/// Extension for SortOrder
extension SortOrderExtension on SortOrder {
  String get displayName {
    switch (this) {
      case SortOrder.ascending:
        return 'Ascending';
      case SortOrder.descending:
        return 'Descending';
    }
  }
  
  bool get isAscending => this == SortOrder.ascending;
  bool get isDescending => this == SortOrder.descending;
}
