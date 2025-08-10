import '../../../../core/usecases/usecase.dart';
import '../repositories/transaction_repository.dart';

/// Use case for adding a category to an existing transaction
/// 
/// Handles validation and ensures the category is not already present.
class AddCategoryToTransaction implements UseCase<void, AddCategoryToTransactionParams> {
  final TransactionRepository repository;

  const AddCategoryToTransaction(this.repository);

  @override
  Future<void> call(AddCategoryToTransactionParams params) async {
    // Validate parameters
    _validateParams(params.transactionId, params.categoryId);

    // Get existing transaction
    final transaction = await repository.getTransactionById(params.transactionId);
    if (transaction == null) {
      throw ArgumentError('Transaction with ID ${params.transactionId} not found');
    }

    // Check if category is already present
    if (transaction.hasCategory(params.categoryId)) {
      if (params.skipIfExists) {
        return; // Category already exists, skip silently
      }
      throw ArgumentError('Category ${params.categoryId} is already in transaction ${params.transactionId}');
    }

    // Add category to transaction
    final updatedTransaction = transaction.addCategory(params.categoryId);
    
    try {
      await repository.updateTransaction(updatedTransaction);
    } catch (e) {
      throw Exception('Failed to add category to transaction: $e');
    }
  }

  void _validateParams(String transactionId, String categoryId) {
    if (transactionId.isEmpty) {
      throw ArgumentError('Transaction ID cannot be empty');
    }
    if (categoryId.isEmpty) {
      throw ArgumentError('Category ID cannot be empty');
    }
  }
}

/// Use case for removing a category from an existing transaction
/// 
/// Handles validation and ensures the category exists before removal.
class RemoveCategoryFromTransaction implements UseCase<void, RemoveCategoryFromTransactionParams> {
  final TransactionRepository repository;

  const RemoveCategoryFromTransaction(this.repository);

  @override
  Future<void> call(RemoveCategoryFromTransactionParams params) async {
    // Validate parameters
    _validateParams(params.transactionId, params.categoryId);

    // Get existing transaction
    final transaction = await repository.getTransactionById(params.transactionId);
    if (transaction == null) {
      throw ArgumentError('Transaction with ID ${params.transactionId} not found');
    }

    // Check if category exists in transaction
    if (!transaction.hasCategory(params.categoryId)) {
      if (params.skipIfNotExists) {
        return; // Category doesn't exist, skip silently
      }
      throw ArgumentError('Category ${params.categoryId} is not in transaction ${params.transactionId}');
    }

    // Remove category from transaction
    final updatedTransaction = transaction.removeCategory(params.categoryId);
    
    try {
      await repository.updateTransaction(updatedTransaction);
    } catch (e) {
      throw Exception('Failed to remove category from transaction: $e');
    }
  }

  void _validateParams(String transactionId, String categoryId) {
    if (transactionId.isEmpty) {
      throw ArgumentError('Transaction ID cannot be empty');
    }
    if (categoryId.isEmpty) {
      throw ArgumentError('Category ID cannot be empty');
    }
  }
}

/// Use case for replacing all categories in an existing transaction
/// 
/// Completely replaces the category list with a new set of categories.
class ReplaceCategoriesInTransaction implements UseCase<void, ReplaceCategoriesInTransactionParams> {
  final TransactionRepository repository;

  const ReplaceCategoriesInTransaction(this.repository);

  @override
  Future<void> call(ReplaceCategoriesInTransactionParams params) async {
    // Validate parameters
    if (params.transactionId.isEmpty) {
      throw ArgumentError('Transaction ID cannot be empty');
    }

    // Validate category IDs
    for (final categoryId in params.categoryIds) {
      if (categoryId.isEmpty) {
        throw ArgumentError('Category ID cannot be empty');
      }
    }

    // Check for duplicates
    final uniqueCategories = params.categoryIds.toSet();
    if (uniqueCategories.length != params.categoryIds.length) {
      throw ArgumentError('Duplicate category IDs are not allowed');
    }

    // Get existing transaction
    final transaction = await repository.getTransactionById(params.transactionId);
    if (transaction == null) {
      throw ArgumentError('Transaction with ID ${params.transactionId} not found');
    }

    // Replace categories in transaction
    final updatedTransaction = transaction.replaceCategories(params.categoryIds);
    
    try {
      await repository.updateTransaction(updatedTransaction);
    } catch (e) {
      throw Exception('Failed to replace categories in transaction: $e');
    }
  }
}

/// Use case for clearing all categories from an existing transaction
/// 
/// Removes all categories, making the transaction uncategorized.
class ClearCategoriesFromTransaction implements UseCase<void, ClearCategoriesFromTransactionParams> {
  final TransactionRepository repository;

  const ClearCategoriesFromTransaction(this.repository);

  @override
  Future<void> call(ClearCategoriesFromTransactionParams params) async {
    // Validate parameters
    if (params.transactionId.isEmpty) {
      throw ArgumentError('Transaction ID cannot be empty');
    }

    // Get existing transaction
    final transaction = await repository.getTransactionById(params.transactionId);
    if (transaction == null) {
      throw ArgumentError('Transaction with ID ${params.transactionId} not found');
    }

    // Skip if already has no categories
    if (!transaction.hasCategories && params.skipIfEmpty) {
      return;
    }

    // Clear all categories
    final updatedTransaction = transaction.replaceCategories([]);
    
    try {
      await repository.updateTransaction(updatedTransaction);
    } catch (e) {
      throw Exception('Failed to clear categories from transaction: $e');
    }
  }
}

// ============================================================================
// PARAMETER CLASSES
// ============================================================================

/// Parameters for adding a category to a transaction
class AddCategoryToTransactionParams extends UseCaseParams {
  /// ID of the transaction to modify
  final String transactionId;
  
  /// ID of the category to add
  final String categoryId;
  
  /// Whether to skip silently if category already exists
  final bool skipIfExists;

  const AddCategoryToTransactionParams({
    required this.transactionId,
    required this.categoryId,
    this.skipIfExists = false,
  });

  @override
  List<Object?> get props => [transactionId, categoryId, skipIfExists];

  @override
  String toString() {
    return 'AddCategoryToTransactionParams('
        'transactionId: $transactionId, '
        'categoryId: $categoryId, '
        'skipIfExists: $skipIfExists'
        ')';
  }
}

/// Parameters for removing a category from a transaction
class RemoveCategoryFromTransactionParams extends UseCaseParams {
  /// ID of the transaction to modify
  final String transactionId;
  
  /// ID of the category to remove
  final String categoryId;
  
  /// Whether to skip silently if category doesn't exist
  final bool skipIfNotExists;

  const RemoveCategoryFromTransactionParams({
    required this.transactionId,
    required this.categoryId,
    this.skipIfNotExists = false,
  });

  @override
  List<Object?> get props => [transactionId, categoryId, skipIfNotExists];

  @override
  String toString() {
    return 'RemoveCategoryFromTransactionParams('
        'transactionId: $transactionId, '
        'categoryId: $categoryId, '
        'skipIfNotExists: $skipIfNotExists'
        ')';
  }
}

/// Parameters for replacing categories in a transaction
class ReplaceCategoriesInTransactionParams extends UseCaseParams {
  /// ID of the transaction to modify
  final String transactionId;
  
  /// New list of category IDs (can be empty to clear all categories)
  final List<String> categoryIds;

  const ReplaceCategoriesInTransactionParams({
    required this.transactionId,
    required this.categoryIds,
  });

  /// Creates parameters to clear all categories
  const ReplaceCategoriesInTransactionParams.clear({
    required String transactionId,
  }) : this(
          transactionId: transactionId,
          categoryIds: const [],
        );

  @override
  List<Object?> get props => [transactionId, categoryIds];

  @override
  String toString() {
    return 'ReplaceCategoriesInTransactionParams('
        'transactionId: $transactionId, '
        'categoryIds: $categoryIds'
        ')';
  }
}

/// Parameters for clearing categories from a transaction
class ClearCategoriesFromTransactionParams extends UseCaseParams {
  /// ID of the transaction to modify
  final String transactionId;
  
  /// Whether to skip silently if transaction already has no categories
  final bool skipIfEmpty;

  const ClearCategoriesFromTransactionParams({
    required this.transactionId,
    this.skipIfEmpty = true,
  });

  @override
  List<Object?> get props => [transactionId, skipIfEmpty];

  @override
  String toString() {
    return 'ClearCategoriesFromTransactionParams('
        'transactionId: $transactionId, '
        'skipIfEmpty: $skipIfEmpty'
        ')';
  }
}
