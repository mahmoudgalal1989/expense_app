import '../../../../core/usecases/usecase.dart';
import '../entities/transaction_type.dart';
import '../enums/category_filter_type.dart';
import '../repositories/transaction_repository.dart';

/// Use case for deleting transactions by categories
/// 
/// Specialized use case for category-based deletion with AND/OR logic support.
class DeleteTransactionsByCategories implements UseCase<int, DeleteTransactionsByCategoriesParams> {
  final TransactionRepository repository;

  const DeleteTransactionsByCategories(this.repository);

  @override
  Future<int> call(DeleteTransactionsByCategoriesParams params) async {
    // Validate parameters
    _validateParams(params);

    try {
      return await repository.deleteTransactionsByCategories(
        params.categoryIds,
        filterType: params.filterType,
      );
    } catch (e) {
      throw Exception('Failed to delete transactions by categories: $e');
    }
  }

  void _validateParams(DeleteTransactionsByCategoriesParams params) {
    if (params.categoryIds.isEmpty) {
      throw ArgumentError('Category IDs list cannot be empty');
    }

    for (final categoryId in params.categoryIds) {
      if (categoryId.isEmpty) {
        throw ArgumentError('Category ID cannot be empty');
      }
    }
  }
}

/// Use case for deleting transactions by currency
/// 
/// Specialized use case for currency-based deletion.
class DeleteTransactionsByCurrency implements UseCase<int, DeleteTransactionsByCurrencyParams> {
  final TransactionRepository repository;

  const DeleteTransactionsByCurrency(this.repository);

  @override
  Future<int> call(DeleteTransactionsByCurrencyParams params) async {
    // Validate parameters
    if (params.currencyCode.isEmpty) {
      throw ArgumentError('Currency code cannot be empty');
    }

    try {
      return await repository.deleteTransactionsByCurrency(params.currencyCode);
    } catch (e) {
      throw Exception('Failed to delete transactions by currency: $e');
    }
  }
}

/// Use case for deleting transactions by date range
/// 
/// Specialized use case for date-based deletion.
class DeleteTransactionsByDateRange implements UseCase<int, DeleteTransactionsByDateRangeParams> {
  final TransactionRepository repository;

  const DeleteTransactionsByDateRange(this.repository);

  @override
  Future<int> call(DeleteTransactionsByDateRangeParams params) async {
    // Validate parameters
    if (params.startDate.isAfter(params.endDate)) {
      throw ArgumentError('Start date must be before or equal to end date');
    }

    try {
      return await repository.deleteTransactionsByDateRange(
        params.startDate,
        params.endDate,
      );
    } catch (e) {
      throw Exception('Failed to delete transactions by date range: $e');
    }
  }
}

/// Use case for deleting transactions by type
/// 
/// Specialized use case for transaction type-based deletion.
class DeleteTransactionsByType implements UseCase<int, DeleteTransactionsByTypeParams> {
  final TransactionRepository repository;

  const DeleteTransactionsByType(this.repository);

  @override
  Future<int> call(DeleteTransactionsByTypeParams params) async {
    try {
      return await repository.deleteTransactionsByType(params.type);
    } catch (e) {
      throw Exception('Failed to delete transactions by type: $e');
    }
  }
}

/// Use case for deleting transactions by note content
/// 
/// Specialized use case for note-based deletion (text search).
class DeleteTransactionsByNote implements UseCase<int, DeleteTransactionsByNoteParams> {
  final TransactionRepository repository;

  const DeleteTransactionsByNote(this.repository);

  @override
  Future<int> call(DeleteTransactionsByNoteParams params) async {
    // Validate parameters
    if (params.noteSearch.isEmpty) {
      throw ArgumentError('Note search text cannot be empty');
    }

    try {
      return await repository.deleteTransactionsByNote(params.noteSearch);
    } catch (e) {
      throw Exception('Failed to delete transactions by note: $e');
    }
  }
}

/// Use case for deleting transactions by amount range
/// 
/// Specialized use case for amount-based deletion.
class DeleteTransactionsByAmountRange implements UseCase<int, DeleteTransactionsByAmountRangeParams> {
  final TransactionRepository repository;

  const DeleteTransactionsByAmountRange(this.repository);

  @override
  Future<int> call(DeleteTransactionsByAmountRangeParams params) async {
    // Validate parameters
    if (params.minAmount != null && params.maxAmount != null) {
      if (params.minAmount! > params.maxAmount!) {
        throw ArgumentError('Minimum amount must be less than or equal to maximum amount');
      }
    }

    if (params.minAmount != null && params.minAmount! < 0) {
      throw ArgumentError('Minimum amount cannot be negative');
    }

    if (params.maxAmount != null && params.maxAmount! < 0) {
      throw ArgumentError('Maximum amount cannot be negative');
    }

    try {
      return await repository.deleteTransactionsByAmountRange(
        minAmount: params.minAmount,
        maxAmount: params.maxAmount,
      );
    } catch (e) {
      throw Exception('Failed to delete transactions by amount range: $e');
    }
  }
}

// ============================================================================
// PARAMETER CLASSES
// ============================================================================

/// Parameters for deleting transactions by categories
class DeleteTransactionsByCategoriesParams extends UseCaseParams {
  final List<String> categoryIds;
  final CategoryFilterType filterType;

  const DeleteTransactionsByCategoriesParams({
    required this.categoryIds,
    this.filterType = CategoryFilterType.any,
  });

  @override
  List<Object?> get props => [categoryIds, filterType];
}

/// Parameters for deleting transactions by currency
class DeleteTransactionsByCurrencyParams extends UseCaseParams {
  final String currencyCode;

  const DeleteTransactionsByCurrencyParams({
    required this.currencyCode,
  });

  @override
  List<Object?> get props => [currencyCode];
}

/// Parameters for deleting transactions by date range
class DeleteTransactionsByDateRangeParams extends UseCaseParams {
  final DateTime startDate;
  final DateTime endDate;

  const DeleteTransactionsByDateRangeParams({
    required this.startDate,
    required this.endDate,
  });

  @override
  List<Object?> get props => [startDate, endDate];
}

/// Parameters for deleting transactions by type
class DeleteTransactionsByTypeParams extends UseCaseParams {
  final TransactionType type;

  const DeleteTransactionsByTypeParams({
    required this.type,
  });

  @override
  List<Object?> get props => [type];
}

/// Parameters for deleting transactions by note
class DeleteTransactionsByNoteParams extends UseCaseParams {
  final String noteSearch;

  const DeleteTransactionsByNoteParams({
    required this.noteSearch,
  });

  @override
  List<Object?> get props => [noteSearch];
}

/// Parameters for deleting transactions by amount range
class DeleteTransactionsByAmountRangeParams extends UseCaseParams {
  final double? minAmount;
  final double? maxAmount;

  const DeleteTransactionsByAmountRangeParams({
    this.minAmount,
    this.maxAmount,
  });

  @override
  List<Object?> get props => [minAmount, maxAmount];
}
