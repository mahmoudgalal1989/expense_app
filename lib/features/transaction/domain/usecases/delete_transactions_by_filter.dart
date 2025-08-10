import '../../../../core/usecases/usecase.dart';
import '../repositories/transaction_repository.dart';
import '../value_objects/filter_criteria.dart';
import '../value_objects/result_objects.dart';
import '../enums/deletion_confirmation_type.dart';

/// Use case for deleting multiple transactions based on filter criteria
/// 
/// This is the primary bulk deletion use case that supports all filter options
/// and provides comprehensive safety checks and result reporting.
class DeleteTransactionsByFilter implements UseCase<BulkDeletionResult, DeleteTransactionsByFilterParams> {
  final TransactionRepository repository;

  const DeleteTransactionsByFilter(this.repository);

  @override
  Future<BulkDeletionResult> call(DeleteTransactionsByFilterParams params) async {
    // Validate parameters
    _validateParams(params);

    // Safety check for high-impact operations
    if (params.criteria.isHighImpact && !params.safetyOverride) {
      final preview = await repository.previewBulkDeletion(params.criteria);
      if (preview.isHighImpact && params.confirmationType != DeletionConfirmationType.confirmed) {
        throw ArgumentError(
          'High-impact deletion detected (${preview.affectedCount} transactions). '
          'Use confirmationType: confirmed or enable safetyOverride to proceed.'
        );
      }
    }

    try {
      // Perform the bulk deletion
      final result = await repository.deleteTransactionsByFilter(params.criteria);
      
      // Validate result
      if (result.deletedCount < 0) {
        throw Exception('Invalid deletion result: negative count');
      }
      
      return result;
    } catch (e) {
      throw Exception('Failed to delete transactions by filter: $e');
    }
  }

  /// Validates the deletion parameters
  void _validateParams(DeleteTransactionsByFilterParams params) {
    // Validate filter criteria
    if (params.criteria.isEmpty && !params.allowEmptyFilter) {
      throw ArgumentError(
        'Empty filter criteria would delete all transactions. '
        'Set allowEmptyFilter: true to proceed.'
      );
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

/// Parameters for bulk deletion by filter criteria
class DeleteTransactionsByFilterParams extends UseCaseParams {
  /// The filter criteria to determine which transactions to delete
  final FilterCriteria criteria;
  
  /// Type of confirmation required for this deletion
  final DeletionConfirmationType confirmationType;
  
  /// Whether to allow deletion with empty filter (deletes all transactions)
  final bool allowEmptyFilter;
  
  /// Override safety checks for high-impact deletions
  final bool safetyOverride;
  
  /// Optional reason for the deletion (for audit purposes)
  final String? reason;

  const DeleteTransactionsByFilterParams({
    required this.criteria,
    this.confirmationType = DeletionConfirmationType.preview,
    this.allowEmptyFilter = false,
    this.safetyOverride = false,
    this.reason,
  });

  /// Creates parameters for confirmed deletion (after preview)
  const DeleteTransactionsByFilterParams.confirmed({
    required FilterCriteria criteria,
    bool allowEmptyFilter = false,
    bool safetyOverride = false,
    String? reason,
  }) : this(
          criteria: criteria,
          confirmationType: DeletionConfirmationType.confirmed,
          allowEmptyFilter: allowEmptyFilter,
          safetyOverride: safetyOverride,
          reason: reason,
        );

  /// Creates parameters for immediate deletion (dangerous)
  const DeleteTransactionsByFilterParams.immediate({
    required FilterCriteria criteria,
    bool allowEmptyFilter = false,
    String? reason,
  }) : this(
          criteria: criteria,
          confirmationType: DeletionConfirmationType.immediate,
          allowEmptyFilter: allowEmptyFilter,
          safetyOverride: true,
          reason: reason,
        );

  @override
  List<Object?> get props => [
        criteria,
        confirmationType,
        allowEmptyFilter,
        safetyOverride,
        reason,
      ];

  @override
  String toString() {
    return 'DeleteTransactionsByFilterParams('
        'criteria: $criteria, '
        'confirmationType: $confirmationType, '
        'allowEmptyFilter: $allowEmptyFilter, '
        'safetyOverride: $safetyOverride'
        ')';
  }
}
