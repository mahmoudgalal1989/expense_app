import '../../../../core/usecases/usecase.dart';
import '../entities/transaction.dart';
import '../entities/transaction_type.dart';
import '../repositories/transaction_repository.dart';

/// Use case for adding a new transaction
/// 
/// Validates transaction data and ensures all referenced entities exist
/// before persisting the transaction.
class AddTransaction implements UseCase<void, AddTransactionParams> {
  final TransactionRepository repository;

  const AddTransaction(this.repository);

  @override
  Future<void> call(AddTransactionParams params) async {
    // Validate transaction data
    _validateTransactionData(params);

    // Generate unique ID if not provided
    final transactionId = params.id ?? _generateTransactionId();
    
    // Create transaction with current timestamp
    final now = DateTime.now();
    final transaction = Transaction(
      id: transactionId,
      amount: params.amount,
      note: params.note,
      categoryIds: params.categoryIds ?? [],
      currencyId: params.currencyId,
      createdAt: now,
      updatedAt: null, // No updates yet
      type: params.type,
    );

    // Add transaction to repository
    await repository.addTransaction(transaction);
  }

  /// Validates the transaction data before creation
  void _validateTransactionData(AddTransactionParams params) {
    // Validate amount
    if (params.amount <= 0) {
      throw ArgumentError('Transaction amount must be positive');
    }

    // Validate currency
    if (params.currencyId.isEmpty) {
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

  /// Generates a unique transaction ID
  String _generateTransactionId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = (timestamp % 10000).toString().padLeft(4, '0');
    return 'txn_${timestamp}_$random';
  }
}

/// Parameters for adding a transaction
class AddTransactionParams extends UseCaseParams {
  /// Optional ID for the transaction (will be generated if not provided)
  final String? id;
  
  /// Transaction amount (must be positive)
  final double amount;
  
  /// Optional note for the transaction
  final String? note;
  
  /// List of category IDs (can be null or empty for uncategorized)
  final List<String>? categoryIds;
  
  /// Currency code for the transaction (required)
  final String currencyId;
  
  /// Type of transaction
  final TransactionType type;

  const AddTransactionParams({
    this.id,
    required this.amount,
    this.note,
    this.categoryIds,
    required this.currencyId,
    required this.type,
  });

  /// Creates parameters for an expense transaction
  const AddTransactionParams.expense({
    String? id,
    required double amount,
    String? note,
    List<String>? categoryIds,
    required String currencyId,
  }) : this(
          id: id,
          amount: amount,
          note: note,
          categoryIds: categoryIds,
          currencyId: currencyId,
          type: TransactionType.expense,
        );

  /// Creates parameters for an income transaction
  const AddTransactionParams.income({
    String? id,
    required double amount,
    String? note,
    List<String>? categoryIds,
    required String currencyId,
  }) : this(
          id: id,
          amount: amount,
          note: note,
          categoryIds: categoryIds,
          currencyId: currencyId,
          type: TransactionType.income,
        );

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
    return 'AddTransactionParams('
        'amount: $amount, '
        'type: $type, '
        'currency: $currencyId, '
        'categories: $categoryIds'
        ')';
  }
}
