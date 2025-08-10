import 'package:equatable/equatable.dart';
import 'transaction_type.dart';

/// Core transaction entity representing a financial transaction
/// 
/// A transaction can have multiple categories but only one currency.
/// Categories are optional, allowing transactions without categorization.
class Transaction extends Equatable {
  /// Unique identifier for the transaction
  final String id;
  
  /// Transaction amount (always positive, sign determined by type)
  final double amount;
  
  /// Optional note/description for the transaction
  final String? note;
  
  /// List of category IDs associated with this transaction
  /// Can be empty for uncategorized transactions
  final List<String> categoryIds;
  
  /// Currency code for this transaction (required)
  final String currencyId;
  
  /// When the transaction was created
  final DateTime createdAt;
  
  /// When the transaction was last updated (null if never updated)
  final DateTime? updatedAt;
  
  /// Type of transaction (expense or income)
  final TransactionType type;

  const Transaction({
    required this.id,
    required this.amount,
    this.note,
    required this.categoryIds,
    required this.currencyId,
    required this.createdAt,
    this.updatedAt,
    required this.type,
  });

  /// Creates a copy of this transaction with updated fields
  Transaction copyWith({
    String? id,
    double? amount,
    String? note,
    List<String>? categoryIds,
    String? currencyId,
    DateTime? createdAt,
    DateTime? updatedAt,
    TransactionType? type,
  }) {
    return Transaction(
      id: id ?? this.id,
      amount: amount ?? this.amount,
      note: note ?? this.note,
      categoryIds: categoryIds ?? this.categoryIds,
      currencyId: currencyId ?? this.currencyId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      type: type ?? this.type,
    );
  }

  /// Returns true if this is an expense transaction
  bool get isExpense => type.isExpense;
  
  /// Returns true if this is an income transaction
  bool get isIncome => type.isIncome;
  
  /// Returns true if this transaction has any categories
  bool get hasCategories => categoryIds.isNotEmpty;
  
  /// Returns true if this transaction has exactly one category
  bool get hasSingleCategory => categoryIds.length == 1;
  
  /// Returns true if this transaction has multiple categories
  bool get hasMultipleCategories => categoryIds.length > 1;
  
  /// Returns the signed amount (negative for expenses, positive for income)
  double get signedAmount => amount * type.amountMultiplier;
  
  /// Adds a category to this transaction if not already present
  Transaction addCategory(String categoryId) {
    if (categoryIds.contains(categoryId)) {
      return this;
    }
    
    final updatedCategories = List<String>.from(categoryIds)..add(categoryId);
    return copyWith(
      categoryIds: updatedCategories,
      updatedAt: DateTime.now(),
    );
  }
  
  /// Removes a category from this transaction
  Transaction removeCategory(String categoryId) {
    if (!categoryIds.contains(categoryId)) {
      return this;
    }
    
    final updatedCategories = List<String>.from(categoryIds)..remove(categoryId);
    return copyWith(
      categoryIds: updatedCategories,
      updatedAt: DateTime.now(),
    );
  }
  
  /// Replaces all categories with the provided list
  Transaction replaceCategories(List<String> newCategoryIds) {
    // Remove duplicates while preserving order
    final uniqueCategories = newCategoryIds.toSet().toList();
    
    return copyWith(
      categoryIds: uniqueCategories,
      updatedAt: DateTime.now(),
    );
  }
  
  /// Returns true if this transaction contains the specified category
  bool hasCategory(String categoryId) => categoryIds.contains(categoryId);
  
  /// Returns true if this transaction contains any of the specified categories
  bool hasAnyCategory(List<String> categoryIds) {
    return categoryIds.any((id) => this.categoryIds.contains(id));
  }
  
  /// Returns true if this transaction contains all of the specified categories
  bool hasAllCategories(List<String> categoryIds) {
    return categoryIds.every((id) => this.categoryIds.contains(id));
  }

  @override
  List<Object?> get props => [
        id,
        amount,
        note,
        categoryIds,
        currencyId,
        createdAt,
        updatedAt,
        type,
      ];

  @override
  String toString() {
    return 'Transaction('
        'id: $id, '
        'amount: $amount, '
        'note: $note, '
        'categoryIds: $categoryIds, '
        'currencyId: $currencyId, '
        'type: $type, '
        'createdAt: $createdAt'
        ')';
  }
}
