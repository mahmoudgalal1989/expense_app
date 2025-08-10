import 'package:equatable/equatable.dart';
import 'package:expense_app/features/currency/domain/entities/currency.dart';
import 'package:expense_app/features/category/domain/entities/category.dart';

/// Global app settings state
abstract class AppSettingsState extends Equatable {
  const AppSettingsState();

  @override
  List<Object?> get props => [];
}

/// Initial state when app starts
class AppSettingsInitial extends AppSettingsState {
  const AppSettingsInitial();
}

/// Loading state during initialization
class AppSettingsLoading extends AppSettingsState {
  const AppSettingsLoading();
}

/// Settings loaded successfully
class AppSettingsLoaded extends AppSettingsState {
  final Currency selectedCurrency;
  final List<Currency> availableCurrencies;
  final List<Category> expenseCategories;
  final List<Category> incomeCategories;
  final List<Category> suggestedExpenseCategories;
  final List<Category> suggestedIncomeCategories;

  const AppSettingsLoaded({
    required this.selectedCurrency,
    required this.availableCurrencies,
    required this.expenseCategories,
    required this.incomeCategories,
    required this.suggestedExpenseCategories,
    required this.suggestedIncomeCategories,
  });

  /// Copy with method for state updates
  AppSettingsLoaded copyWith({
    Currency? selectedCurrency,
    List<Currency>? availableCurrencies,
    List<Category>? expenseCategories,
    List<Category>? incomeCategories,
    List<Category>? suggestedExpenseCategories,
    List<Category>? suggestedIncomeCategories,
  }) {
    return AppSettingsLoaded(
      selectedCurrency: selectedCurrency ?? this.selectedCurrency,
      availableCurrencies: availableCurrencies ?? this.availableCurrencies,
      expenseCategories: expenseCategories ?? this.expenseCategories,
      incomeCategories: incomeCategories ?? this.incomeCategories,
      suggestedExpenseCategories: suggestedExpenseCategories ?? this.suggestedExpenseCategories,
      suggestedIncomeCategories: suggestedIncomeCategories ?? this.suggestedIncomeCategories,
    );
  }

  /// Get categories by type
  List<Category> getCategoriesByType(CategoryType type) {
    return type == CategoryType.expense ? expenseCategories : incomeCategories;
  }

  /// Get suggested categories by type
  List<Category> getSuggestedCategoriesByType(CategoryType type) {
    return type == CategoryType.expense ? suggestedExpenseCategories : suggestedIncomeCategories;
  }

  @override
  List<Object> get props => [
        selectedCurrency,
        availableCurrencies,
        expenseCategories,
        incomeCategories,
        suggestedExpenseCategories,
        suggestedIncomeCategories,
      ];
}

/// Error state
class AppSettingsError extends AppSettingsState {
  final String message;

  const AppSettingsError(this.message);

  @override
  List<Object> get props => [message];
}

/// Currency updating state
class CurrencyUpdating extends AppSettingsState {
  final AppSettingsLoaded currentState;

  const CurrencyUpdating(this.currentState);

  @override
  List<Object> get props => [currentState];
}

/// Categories updating state
class CategoriesUpdating extends AppSettingsState {
  final AppSettingsLoaded currentState;
  final CategoryType type;

  const CategoriesUpdating({
    required this.currentState,
    required this.type,
  });

  @override
  List<Object> get props => [currentState, type];
}
