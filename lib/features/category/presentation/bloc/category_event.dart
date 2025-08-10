import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:expense_app/features/category/domain/entities/category.dart';

abstract class CategoryEvent extends Equatable {
  const CategoryEvent();

  @override
  List<Object> get props => [];
}

class LoadCategories extends CategoryEvent {
  final CategoryType type;

  const LoadCategories(this.type);

  @override
  List<Object> get props => [type];
}

class AddCategory extends CategoryEvent {
  final Category category;

  const AddCategory(this.category);

  @override
  List<Object> get props => [category];
}

class ReorderUserCategories extends CategoryEvent {
  final int oldIndex;
  final int newIndex;

  const ReorderUserCategories(this.oldIndex, this.newIndex);

  @override
  List<Object> get props => [oldIndex, newIndex];
}

class CreateCategory extends CategoryEvent {
  final String name;
  final String icon;
  final CategoryType type;
  final Color borderColor;

  const CreateCategory({
    required this.name,
    required this.icon,
    required this.type,
    required this.borderColor,
  });

  @override
  List<Object> get props => [name, icon, type, borderColor];
}

class UpdateCategory extends CategoryEvent {
  final String categoryId;
  final String name;
  final String icon;
  final CategoryType type;
  final Color borderColor;

  const UpdateCategory({
    required this.categoryId,
    required this.name,
    required this.icon,
    required this.type,
    required this.borderColor,
  });

  @override
  List<Object> get props => [categoryId, name, icon, type, borderColor];
}
