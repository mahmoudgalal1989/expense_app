import 'package:expense_app/features/category/domain/entities/category.dart';
import 'package:flutter/material.dart';

class CategoryModel extends Category {
  const CategoryModel({
    required super.id,
    required super.name,
    required super.icon,
    required super.type,
    super.borderColor,
    super.order,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'],
      name: json['name'],
      icon: json['icon'],
      type: CategoryTypeExtension.fromId(json['type']),
      borderColor: json['borderColor'] != null 
          ? Color(json['borderColor']) 
          : null,
      order: json['order'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
      'type': type.id, // Use the ID instead of toString
      'borderColor': borderColor?.value,
      'order': order,
    };
  }
}
