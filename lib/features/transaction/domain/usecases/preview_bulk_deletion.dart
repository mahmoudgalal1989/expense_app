import '../../../../core/usecases/usecase.dart';
import '../repositories/transaction_repository.dart';
import '../value_objects/filter_criteria.dart';
import '../value_objects/result_objects.dart';

/// Use case for previewing what would be deleted by bulk deletion operations
/// 
/// This is a safety feature that allows users to see what transactions would
/// be affected before actually performing the deletion.
class PreviewBulkDeletion implements UseCase<BulkDeletionPreview, PreviewBulkDeletionParams> {
  final TransactionRepository repository;

  const PreviewBulkDeletion(this.repository);

  @override
  Future<BulkDeletionPreview> call(PreviewBulkDeletionParams params) async {
    // Validate parameters
    _validateParams(params);

    try {
      // Get the preview from repository
      final preview = await repository.previewBulkDeletion(
        params.criteria,
        maxSampleSize: params.maxSampleSize,
      );
      
      return preview;
    } catch (e) {
      throw Exception('Failed to preview bulk deletion: $e');
    }
  }

  /// Validates the preview parameters
  void _validateParams(PreviewBulkDeletionParams params) {
    // Validate max sample size
    if (params.maxSampleSize <= 0) {
      throw ArgumentError('Max sample size must be positive');
    }

    if (params.maxSampleSize > 100) {
      throw ArgumentError('Max sample size cannot exceed 100 for performance reasons');
    }

    // Validate date range if present
    if (params.criteria.hasDateFilter && !params.criteria.dateRange!.isValid) {
      throw ArgumentError('Invalid date range in filter criteria');
    }

    // Validate amount range if present
    if (params.criteria.hasAmountFilter && !params.criteria.amountRange!.isValid) {
      throw ArgumentError('Invalid amount range in filter criteria');
    }

    // Validate category IDs if present
    if (params.criteria.hasCategoryFilter) {
      for (final categoryId in params.criteria.categoryIds!) {
        if (categoryId.isEmpty) {
          throw ArgumentError('Category ID cannot be empty');
        }
      }
    }

    // Validate currency code if present
    if (params.criteria.hasCurrencyFilter && params.criteria.currencyCode!.isEmpty) {
      throw ArgumentError('Currency code cannot be empty');
    }
  }
}

/// Use case for counting transactions that match filter criteria
/// 
/// Useful for getting just the count without the overhead of loading sample data.
class CountTransactionsByFilter implements UseCase<int, CountTransactionsByFilterParams> {
  final TransactionRepository repository;

  const CountTransactionsByFilter(this.repository);

  @override
  Future<int> call(CountTransactionsByFilterParams params) async {
    try {
      return await repository.countTransactionsByFilter(params.criteria);
    } catch (e) {
      throw Exception('Failed to count transactions by filter: $e');
    }
  }
}

/// Parameters for previewing bulk deletion
class PreviewBulkDeletionParams extends UseCaseParams {
  /// The filter criteria to preview
  final FilterCriteria criteria;
  
  /// Maximum number of sample transactions to include in the preview
  final int maxSampleSize;

  const PreviewBulkDeletionParams({
    required this.criteria,
    this.maxSampleSize = 10,
  });

  /// Creates parameters with a smaller sample size for quick preview
  const PreviewBulkDeletionParams.quick({
    required FilterCriteria criteria,
  }) : this(
          criteria: criteria,
          maxSampleSize: 5,
        );

  /// Creates parameters with a larger sample size for detailed preview
  const PreviewBulkDeletionParams.detailed({
    required FilterCriteria criteria,
  }) : this(
          criteria: criteria,
          maxSampleSize: 20,
        );

  @override
  List<Object?> get props => [criteria, maxSampleSize];

  @override
  String toString() {
    return 'PreviewBulkDeletionParams('
        'criteria: $criteria, '
        'maxSampleSize: $maxSampleSize'
        ')';
  }
}

/// Parameters for counting transactions by filter
class CountTransactionsByFilterParams extends UseCaseParams {
  /// The filter criteria to count against
  final FilterCriteria criteria;

  const CountTransactionsByFilterParams({
    required this.criteria,
  });

  @override
  List<Object?> get props => [criteria];

  @override
  String toString() {
    return 'CountTransactionsByFilterParams(criteria: $criteria)';
  }
}
