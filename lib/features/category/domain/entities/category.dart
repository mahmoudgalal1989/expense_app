import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

enum CategoryType { expense, income }

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
