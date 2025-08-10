import '../../../../core/usecases/usecase.dart';
import '../entities/transaction.dart';
import '../repositories/transaction_repository.dart';

/// Use case for retrieving all transactions
/// 
/// Returns all transactions ordered by creation date (newest first)
class GetTransactions implements NoParamsUseCase<List<Transaction>> {
  final TransactionRepository repository;

  const GetTransactions(this.repository);

  @override
  Future<List<Transaction>> call() async {
    try {
      final transactions = await repository.getAllTransactions();
      
      // Sort by creation date (newest first) as a safety measure
      // Repository should already return them sorted, but this ensures consistency
      transactions.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      
      return transactions;
    } catch (e) {
      // Log error and rethrow with more context
      throw Exception('Failed to retrieve transactions: $e');
    }
  }
}

/// Use case for retrieving a specific transaction by ID
class GetTransactionById implements UseCase<Transaction?, GetTransactionByIdParams> {
  final TransactionRepository repository;

  const GetTransactionById(this.repository);

  @override
  Future<Transaction?> call(GetTransactionByIdParams params) async {
    if (params.id.isEmpty) {
      throw ArgumentError('Transaction ID cannot be empty');
    }

    try {
      return await repository.getTransactionById(params.id);
    } catch (e) {
      throw Exception('Failed to retrieve transaction ${params.id}: $e');
    }
  }
}

/// Parameters for getting a transaction by ID
class GetTransactionByIdParams extends UseCaseParams {
  /// The ID of the transaction to retrieve
  final String id;

  const GetTransactionByIdParams({required this.id});

  @override
  List<Object?> get props => [id];

  @override
  String toString() => 'GetTransactionByIdParams(id: $id)';
}
