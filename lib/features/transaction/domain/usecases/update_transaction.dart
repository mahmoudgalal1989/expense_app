import '../../../../core/usecases/usecase.dart';
import '../entities/transaction_type.dart';
import '../repositories/transaction_repository.dart';

/// Use case for updating an existing transaction
/// 
/// Validates the updated data and ensures the transaction exists before updating.
/// Automatically updates the updatedAt timestamp.
class UpdateTransaction implements UseCase<void, UpdateTransactionParams> {
  final TransactionRepository repository;

  const UpdateTransaction(this.repository);

  @override
  Future<void> call(UpdateTransactionParams params) async {
    // Validate parameters
    _validateUpdateParams(params);

    // Get existing transaction
    final existingTransaction = await repository.getTransactionById(params.id);
    if (existingTransaction == null) {
      throw ArgumentError('Transaction with ID ${params.id} not found');
    }

    // Create updated transaction
    final updatedTransaction = existingTransaction.copyWith(
      amount: params.amount,
      note: params.note,
      categoryIds: params.categoryIds,
      currencyId: params.currencyId,
      type: params.type,
      updatedAt: DateTime.now(),
    );

    // Update in repository
    await repository.updateTransaction(updatedTransaction);
  }

  /// Validates the update parameters
  void _validateUpdateParams(UpdateTransactionParams params) {
    // Validate ID
    if (params.id.isEmpty) {
      throw ArgumentError('Transaction ID cannot be empty');
    }

    // Validate amount
    if (params.amount != null && params.amount! <= 0) {
      throw ArgumentError('Transaction amount must be positive');
    }

    // Validate currency
    if (params.currencyId != null && params.currencyId!.isEmpty) {
      throw ArgumentError('Currency ID cannot be empty');
    }

    // Validate category IDs (if provided)
    if (params.categoryIds != null) {
      final uniqueCategories = params.categoryIds!.toSet();
      if (uniqueCategories.length != params.categoryIds!.length) {
        throw ArgumentError('Duplicate category IDs are not allowed');
      }
      
      for (final categoryId in params.categoryIds!) {
        if (categoryId.isEmpty) {
          throw ArgumentError('Category ID cannot be empty');
        }
      }
    }

    // Validate note length (optional but reasonable limit)
    if (params.note != null && params.note!.length > 500) {
      throw ArgumentError('Transaction note cannot exceed 500 characters');
    }
  }
}

/// Parameters for updating a transaction
/// 
/// Only non-null fields will be updated. The ID is required to identify
/// the transaction to update.
class UpdateTransactionParams extends UseCaseParams {
  /// ID of the transaction to update (required)
  final String id;
  
  /// New amount (null to keep existing)
  final double? amount;
  
  /// New note (null to keep existing, empty string to clear)
  final String? note;
  
  /// New category IDs (null to keep existing, empty list to clear categories)
  final List<String>? categoryIds;
  
  /// New currency ID (null to keep existing)
  final String? currencyId;
  
  /// New transaction type (null to keep existing)
  final TransactionType? type;

  const UpdateTransactionParams({
    required this.id,
    this.amount,
    this.note,
    this.categoryIds,
    this.currencyId,
    this.type,
  });

  /// Creates update parameters for changing only the amount
  const UpdateTransactionParams.amount({
    required String id,
    required double amount,
  }) : this(
          id: id,
          amount: amount,
        );

  /// Creates update parameters for changing only the note
  const UpdateTransactionParams.note({
    required String id,
    required String note,
  }) : this(
          id: id,
          note: note,
        );

  /// Creates update parameters for changing only the categories
  const UpdateTransactionParams.categories({
    required String id,
    required List<String> categoryIds,
  }) : this(
          id: id,
          categoryIds: categoryIds,
        );

  /// Creates update parameters for changing only the currency
  const UpdateTransactionParams.currency({
    required String id,
    required String currencyId,
  }) : this(
          id: id,
          currencyId: currencyId,
        );

  /// Creates update parameters for changing only the type
  const UpdateTransactionParams.type({
    required String id,
    required TransactionType type,
  }) : this(
          id: id,
          type: type,
        );

  /// Returns true if any field is being updated
  bool get hasUpdates =>
      amount != null ||
      note != null ||
      categoryIds != null ||
      currencyId != null ||
      type != null;

  @override
  List<Object?> get props => [
        id,
        amount,
        note,
        categoryIds,
        currencyId,
        type,
      ];

  @override
  String toString() {
    final updates = <String>[];
    if (amount != null) updates.add('amount: $amount');
    if (note != null) updates.add('note: "$note"');
    if (categoryIds != null) updates.add('categories: $categoryIds');
    if (currencyId != null) updates.add('currency: $currencyId');
    if (type != null) updates.add('type: $type');
    
    return 'UpdateTransactionParams(id: $id, updates: [${updates.join(', ')}])';
  }
}
