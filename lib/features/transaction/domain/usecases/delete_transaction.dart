import '../../../../core/usecases/usecase.dart';
import '../repositories/transaction_repository.dart';

/// Use case for deleting a single transaction
/// 
/// Validates that the transaction exists before attempting deletion.
class DeleteTransaction implements UseCase<bool, DeleteTransactionParams> {
  final TransactionRepository repository;

  const DeleteTransaction(this.repository);

  @override
  Future<bool> call(DeleteTransactionParams params) async {
    // Validate parameters
    if (params.id.isEmpty) {
      throw ArgumentError('Transaction ID cannot be empty');
    }

    try {
      // Check if transaction exists (optional verification)
      if (params.verifyExists) {
        final transaction = await repository.getTransactionById(params.id);
        if (transaction == null) {
          if (params.throwIfNotFound) {
            throw ArgumentError('Transaction with ID ${params.id} not found');
          }
          return false;
        }
      }

      // Delete the transaction
      final deleted = await repository.deleteTransaction(params.id);
      
      if (!deleted && params.throwIfNotFound) {
        throw ArgumentError('Transaction with ID ${params.id} not found');
      }
      
      return deleted;
    } catch (e) {
      throw Exception('Failed to delete transaction ${params.id}: $e');
    }
  }
}

/// Use case for deleting all transactions
/// 
/// This is a dangerous operation that should be used with extreme caution.
/// Consider implementing additional safety checks in the presentation layer.
class DeleteAllTransactions implements UseCase<int, DeleteAllTransactionsParams> {
  final TransactionRepository repository;

  const DeleteAllTransactions(this.repository);

  @override
  Future<int> call(DeleteAllTransactionsParams params) async {
    // Safety check - require explicit confirmation
    if (!params.confirmed) {
      throw ArgumentError('Deletion of all transactions must be explicitly confirmed');
    }

    try {
      final deletedCount = await repository.deleteAllTransactions();
      return deletedCount;
    } catch (e) {
      throw Exception('Failed to delete all transactions: $e');
    }
  }
}

/// Parameters for deleting a single transaction
class DeleteTransactionParams extends UseCaseParams {
  /// ID of the transaction to delete
  final String id;
  
  /// Whether to verify the transaction exists before attempting deletion
  final bool verifyExists;
  
  /// Whether to throw an exception if the transaction is not found
  final bool throwIfNotFound;

  const DeleteTransactionParams({
    required this.id,
    this.verifyExists = false,
    this.throwIfNotFound = false,
  });

  /// Creates parameters for safe deletion (with verification)
  const DeleteTransactionParams.safe({
    required String id,
  }) : this(
          id: id,
          verifyExists: true,
          throwIfNotFound: true,
        );

  /// Creates parameters for quick deletion (without verification)
  const DeleteTransactionParams.quick({
    required String id,
  }) : this(
          id: id,
          verifyExists: false,
          throwIfNotFound: false,
        );

  @override
  List<Object?> get props => [id, verifyExists, throwIfNotFound];

  @override
  String toString() {
    return 'DeleteTransactionParams('
        'id: $id, '
        'verifyExists: $verifyExists, '
        'throwIfNotFound: $throwIfNotFound'
        ')';
  }
}

/// Parameters for deleting all transactions
class DeleteAllTransactionsParams extends UseCaseParams {
  /// Explicit confirmation that all transactions should be deleted
  final bool confirmed;
  
  /// Optional reason for the deletion (for audit purposes)
  final String? reason;

  const DeleteAllTransactionsParams({
    required this.confirmed,
    this.reason,
  });

  /// Creates confirmed parameters for deleting all transactions
  const DeleteAllTransactionsParams.confirmed({
    String? reason,
  }) : this(
          confirmed: true,
          reason: reason,
        );

  @override
  List<Object?> get props => [confirmed, reason];

  @override
  String toString() {
    return 'DeleteAllTransactionsParams('
        'confirmed: $confirmed, '
        'reason: $reason'
        ')';
  }
}
