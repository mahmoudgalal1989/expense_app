import '../../../../core/usecases/usecase.dart';
import '../entities/transaction_type.dart';
import '../enums/category_filter_type.dart';
import '../repositories/transaction_repository.dart';
import '../value_objects/filter_criteria.dart';
import '../value_objects/result_objects.dart';

/// Use case for generating comprehensive transaction statistics
/// 
/// Provides detailed breakdowns by category, currency, type, and overall totals.
class GetTransactionStatistics implements NoParamsUseCase<TransactionStatistics> {
  final TransactionRepository repository;

  const GetTransactionStatistics(this.repository);

  @override
  Future<TransactionStatistics> call() async {
    try {
      return await repository.getTransactionStatistics();
    } catch (e) {
      throw Exception('Failed to generate transaction statistics: $e');
    }
  }
}

/// Use case for generating filtered transaction statistics
/// 
/// Provides statistics for transactions matching specific filter criteria.
class GetFilteredTransactionStatistics implements UseCase<TransactionStatistics, GetFilteredTransactionStatisticsParams> {
  final TransactionRepository repository;

  const GetFilteredTransactionStatistics(this.repository);

  @override
  Future<TransactionStatistics> call(GetFilteredTransactionStatisticsParams params) async {
    // Validate filter criteria
    _validateFilterCriteria(params.criteria);

    try {
      return await repository.getFilteredTransactionStatistics(params.criteria);
    } catch (e) {
      throw Exception('Failed to generate filtered transaction statistics: $e');
    }
  }

  /// Validates the filter criteria
  void _validateFilterCriteria(FilterCriteria criteria) {
    // Validate date range if present
    if (criteria.hasDateFilter && !criteria.dateRange!.isValid) {
      throw ArgumentError('Invalid date range in filter criteria');
    }

    // Validate amount range if present
    if (criteria.hasAmountFilter && !criteria.amountRange!.isValid) {
      throw ArgumentError('Invalid amount range in filter criteria');
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
}

/// Use case for getting total amounts by categories
/// 
/// Specialized use case for category-based totals calculation.
class GetTotalAmountByCategories implements UseCase<double, GetTotalAmountByCategoriesParams> {
  final TransactionRepository repository;

  const GetTotalAmountByCategories(this.repository);

  @override
  Future<double> call(GetTotalAmountByCategoriesParams params) async {
    // Validate parameters
    if (params.categoryIds.isEmpty) {
      throw ArgumentError('Category IDs list cannot be empty');
    }

    for (final categoryId in params.categoryIds) {
      if (categoryId.isEmpty) {
        throw ArgumentError('Category ID cannot be empty');
      }
    }

    try {
      return await repository.getTotalAmountByCategories(
        params.categoryIds,
        filterType: params.filterType,
      );
    } catch (e) {
      throw Exception('Failed to get total amount by categories: $e');
    }
  }
}

/// Use case for getting total amounts by currency
/// 
/// Specialized use case for currency-based totals calculation.
class GetTotalAmountByCurrency implements UseCase<double, GetTotalAmountByCurrencyParams> {
  final TransactionRepository repository;

  const GetTotalAmountByCurrency(this.repository);

  @override
  Future<double> call(GetTotalAmountByCurrencyParams params) async {
    // Validate parameters
    if (params.currencyCode.isEmpty) {
      throw ArgumentError('Currency code cannot be empty');
    }

    try {
      return await repository.getTotalAmountByCurrency(params.currencyCode);
    } catch (e) {
      throw Exception('Failed to get total amount by currency: $e');
    }
  }
}

// ============================================================================
// PARAMETER CLASSES
// ============================================================================

/// Parameters for getting filtered transaction statistics
class GetFilteredTransactionStatisticsParams extends UseCaseParams {
  /// The filter criteria to generate statistics for
  final FilterCriteria criteria;

  const GetFilteredTransactionStatisticsParams({
    required this.criteria,
  });

  /// Creates parameters for statistics of a specific category
  GetFilteredTransactionStatisticsParams.forCategory(String categoryId)
      : criteria = FilterCriteria.forCategory(categoryId);

  /// Creates parameters for statistics of a specific currency
  GetFilteredTransactionStatisticsParams.forCurrency(String currencyCode)
      : criteria = FilterCriteria.forCurrency(currencyCode);

  /// Creates parameters for statistics of a specific type
  GetFilteredTransactionStatisticsParams.forType(TransactionType type)
      : criteria = FilterCriteria.forType(type);

  @override
  List<Object?> get props => [criteria];

  @override
  String toString() {
    return 'GetFilteredTransactionStatisticsParams(criteria: $criteria)';
  }
}

/// Parameters for getting total amount by categories
class GetTotalAmountByCategoriesParams extends UseCaseParams {
  /// List of category IDs to calculate totals for
  final List<String> categoryIds;
  
  /// How to apply category filtering when multiple categories are specified
  final CategoryFilterType filterType;

  const GetTotalAmountByCategoriesParams({
    required this.categoryIds,
    this.filterType = CategoryFilterType.any,
  });

  @override
  List<Object?> get props => [categoryIds, filterType];

  @override
  String toString() {
    return 'GetTotalAmountByCategoriesParams('
        'categoryIds: $categoryIds, '
        'filterType: $filterType'
        ')';
  }
}

/// Parameters for getting total amount by currency
class GetTotalAmountByCurrencyParams extends UseCaseParams {
  /// Currency code to calculate totals for
  final String currencyCode;

  const GetTotalAmountByCurrencyParams({
    required this.currencyCode,
  });

  @override
  List<Object?> get props => [currencyCode];

  @override
  String toString() {
    return 'GetTotalAmountByCurrencyParams(currencyCode: $currencyCode)';
  }
}
