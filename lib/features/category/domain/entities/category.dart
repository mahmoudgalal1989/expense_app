import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

enum CategoryType { expense, income }

/// Extension to provide utility methods for CategoryType
extension CategoryTypeExtension on CategoryType {
  /// Returns the unique ID for this category type
  String get id {
    switch (this) {
      case CategoryType.expense:
        return 'expense';
      case CategoryType.income:
        return 'income';
    }
  }
  
  /// Returns true if this is an expense category
  bool get isExpense => this == CategoryType.expense;
  
  /// Returns true if this is an income category
  bool get isIncome => this == CategoryType.income;
  
  /// Returns a human-readable string representation
  String get displayName {
    switch (this) {
      case CategoryType.expense:
        return 'Expense';
      case CategoryType.income:
        return 'Income';
    }
  }
  
  /// Creates a CategoryType from its ID
  static CategoryType fromId(String id) {
    switch (id.toLowerCase()) {
      case 'expense':
        return CategoryType.expense;
      case 'income':
        return CategoryType.income;
      default:
        throw ArgumentError('Invalid category type ID: $id');
    }
  }
  
  /// Returns all available category type IDs
  static List<String> get allIds => CategoryType.values.map((type) => type.id).toList();
}

class Category extends Equatable {
  final String id;
  final String name;
  final String icon;
  final CategoryType type;
  final Color? borderColor;
  final int? order;

  const Category({
    required this.id,
    required this.name,
    required this.icon,
    required this.type,
    this.borderColor,
    this.order,
  });

  Category copyWith({
    String? id,
    String? name,
    String? icon,
    CategoryType? type,
    Color? borderColor,
    int? order,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      type: type ?? this.type,
      borderColor: borderColor ?? this.borderColor,
      order: order ?? this.order,
    );
  }

  @override
  List<Object?> get props => [id, name, icon, type, borderColor, order];
}
