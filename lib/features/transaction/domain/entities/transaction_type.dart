/// Enum representing the type of transaction
enum TransactionType {
  /// Transaction represents an expense (money going out)
  expense,
  
  /// Transaction represents an income (money coming in)
  income,
}

/// Extension to provide utility methods for TransactionType
extension TransactionTypeExtension on TransactionType {
  /// Returns the unique ID for this transaction type
  String get id {
    switch (this) {
      case TransactionType.expense:
        return 'expense';
      case TransactionType.income:
        return 'income';
    }
  }
  
  /// Returns true if this is an expense transaction
  bool get isExpense => this == TransactionType.expense;
  
  /// Returns true if this is an income transaction
  bool get isIncome => this == TransactionType.income;
  
  /// Returns a human-readable string representation
  String get displayName {
    switch (this) {
      case TransactionType.expense:
        return 'Expense';
      case TransactionType.income:
        return 'Income';
    }
  }
  
  /// Returns the multiplier for amount calculation (-1 for expense, +1 for income)
  int get amountMultiplier {
    switch (this) {
      case TransactionType.expense:
        return -1;
      case TransactionType.income:
        return 1;
    }
  }
  
  /// Creates a TransactionType from its ID
  static TransactionType fromId(String id) {
    switch (id.toLowerCase()) {
      case 'expense':
        return TransactionType.expense;
      case 'income':
        return TransactionType.income;
      default:
        throw ArgumentError('Invalid transaction type ID: $id');
    }
  }
  
  /// Returns all available transaction type IDs
  static List<String> get allIds => TransactionType.values.map((type) => type.id).toList();
}
