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
      type: CategoryType.values
          .firstWhere((e) => e.toString() == 'CategoryType.${json['type']}'),
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
      'type': type.toString().split('.').last,
      'borderColor': borderColor?.value,
      'order': order,
    };
  }
}
