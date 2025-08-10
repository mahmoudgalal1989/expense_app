import '../../domain/entities/transaction.dart';
import '../../domain/entities/transaction_type.dart';

/// Data model for Transaction entity with JSON serialization support
/// 
/// Extends the domain Transaction entity and adds serialization capabilities
/// for data persistence and API communication.
class TransactionModel extends Transaction {
  const TransactionModel({
    required super.id,
    required super.amount,
    super.note,
    required super.categoryIds,
    required super.currencyId,
    required super.createdAt,
    super.updatedAt,
    required super.type,
  });

  /// Creates a TransactionModel from a Transaction entity
  factory TransactionModel.fromEntity(Transaction transaction) {
    return TransactionModel(
      id: transaction.id,
      amount: transaction.amount,
      note: transaction.note,
      categoryIds: transaction.categoryIds,
      currencyId: transaction.currencyId,
      createdAt: transaction.createdAt,
      updatedAt: transaction.updatedAt,
      type: transaction.type,
    );
  }

  /// Creates a TransactionModel from JSON data
  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    try {
      return TransactionModel(
        id: json['id'] as String,
        amount: _parseDouble(json['amount']),
        note: json['note'] as String?,
        categoryIds: _parseCategoryIds(json['categoryIds']),
        currencyId: json['currencyId'] as String,
        createdAt: DateTime.parse(json['createdAt'] as String),
        updatedAt: json['updatedAt'] != null 
            ? DateTime.parse(json['updatedAt'] as String)
            : null,
        type: _parseTransactionType(json['type']),
      );
    } catch (e) {
      throw FormatException('Failed to parse TransactionModel from JSON: $e');
    }
  }

  /// Converts this model to JSON data
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'amount': amount,
      'note': note,
      'categoryIds': categoryIds,
      'currencyId': currencyId,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'type': type.id, // Use the ID instead of name
    };
  }

  /// Converts this model to a domain Transaction entity
  Transaction toEntity() {
    return Transaction(
      id: id,
      amount: amount,
      note: note,
      categoryIds: categoryIds,
      currencyId: currencyId,
      createdAt: createdAt,
      updatedAt: updatedAt,
      type: type,
    );
  }

  /// Creates a copy of this model with updated values
  @override
  TransactionModel copyWith({
    String? id,
    double? amount,
    String? note,
    List<String>? categoryIds,
    String? currencyId,
    DateTime? createdAt,
    DateTime? updatedAt,
    TransactionType? type,
  }) {
    return TransactionModel(
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

  // ============================================================================
  // PRIVATE HELPER METHODS
  // ============================================================================

  /// Safely parses a double value from JSON
  static double _parseDouble(dynamic value) {
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      final parsed = double.tryParse(value);
      if (parsed != null) return parsed;
    }
    throw FormatException('Invalid amount value: $value');
  }

  /// Safely parses category IDs list from JSON
  static List<String> _parseCategoryIds(dynamic value) {
    if (value == null) return [];
    
    if (value is List) {
      return value.map((item) {
        if (item is String) return item;
        throw FormatException('Invalid category ID: $item');
      }).toList();
    }
    
    throw FormatException('Invalid categoryIds format: $value');
  }

  /// Safely parses transaction type from JSON
  static TransactionType _parseTransactionType(dynamic value) {
    if (value is String) {
      try {
        return TransactionTypeExtension.fromId(value);
      } catch (e) {
        throw FormatException('Invalid transaction type: $value');
      }
    }
    
    throw FormatException('Invalid transaction type format: $value');
  }

  // ============================================================================
  // VALIDATION METHODS
  // ============================================================================

  /// Validates this model's data integrity
  bool isValid() {
    try {
      // Validate required fields
      if (id.isEmpty) return false;
      if (amount <= 0) return false;
      if (currencyId.isEmpty) return false;
      
      // Validate category IDs
      for (final categoryId in categoryIds) {
        if (categoryId.isEmpty) return false;
      }
      
      // Validate note length
      if (note != null && note!.length > 500) return false;
      
      // Validate timestamps
      if (updatedAt != null && updatedAt!.isBefore(createdAt)) return false;
      
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Returns a list of validation errors (empty if valid)
  List<String> getValidationErrors() {
    final errors = <String>[];
    
    if (id.isEmpty) errors.add('ID cannot be empty');
    if (amount <= 0) errors.add('Amount must be positive');
    if (currencyId.isEmpty) errors.add('Currency ID cannot be empty');
    
    for (int i = 0; i < categoryIds.length; i++) {
      if (categoryIds[i].isEmpty) {
        errors.add('Category ID at index $i cannot be empty');
      }
    }
    
    // Check for duplicate category IDs
    final uniqueCategories = categoryIds.toSet();
    if (uniqueCategories.length != categoryIds.length) {
      errors.add('Duplicate category IDs are not allowed');
    }
    
    if (note != null && note!.length > 500) {
      errors.add('Note cannot exceed 500 characters');
    }
    
    if (updatedAt != null && updatedAt!.isBefore(createdAt)) {
      errors.add('Updated date cannot be before created date');
    }
    
    return errors;
  }

  @override
  String toString() {
    return 'TransactionModel('
        'id: $id, '
        'amount: $amount, '
        'type: $type, '
        'currency: $currencyId, '
        'categories: ${categoryIds.length}, '
        'createdAt: $createdAt'
        ')';
  }
}
