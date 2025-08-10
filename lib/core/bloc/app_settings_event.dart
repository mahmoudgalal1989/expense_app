import 'package:equatable/equatable.dart';
import 'package:expense_app/features/currency/domain/entities/currency.dart';
import 'package:expense_app/features/category/domain/entities/category.dart';

/// Global app settings events that affect the entire application
abstract class AppSettingsEvent extends Equatable {
  const AppSettingsEvent();

  @override
  List<Object?> get props => [];
}

/// Initialize app settings (currency and categories)
class InitializeAppSettings extends AppSettingsEvent {
  const InitializeAppSettings();
}

/// Currency-related events
class CurrencyChanged extends AppSettingsEvent {
  final Currency currency;

  const CurrencyChanged(this.currency);

  @override
  List<Object> get props => [currency];
}

class LoadCurrencies extends AppSettingsEvent {
  const LoadCurrencies();
}

/// Category-related events
class CategoriesChanged extends AppSettingsEvent {
  final List<Category> categories;
  final CategoryType type;

  const CategoriesChanged({
    required this.categories,
    required this.type,
  });

  @override
  List<Object> get props => [categories, type];
}

class CategoryAdded extends AppSettingsEvent {
  final Category category;

  const CategoryAdded(this.category);

  @override
  List<Object> get props => [category];
}

class CategoryUpdated extends AppSettingsEvent {
  final Category category;

  const CategoryUpdated(this.category);

  @override
  List<Object> get props => [category];
}

class CategoryRemoved extends AppSettingsEvent {
  final String categoryId;
  final CategoryType type;

  const CategoryRemoved({
    required this.categoryId,
    required this.type,
  });

  @override
  List<Object> get props => [categoryId, type];
}

class CategoriesReordered extends AppSettingsEvent {
  final List<Category> reorderedCategories;
  final CategoryType type;

  const CategoriesReordered({
    required this.reorderedCategories,
    required this.type,
  });

  @override
  List<Object> get props => [reorderedCategories, type];
}

/// Reset all app settings to defaults
class ResetAppSettings extends AppSettingsEvent {
  const ResetAppSettings();
}
