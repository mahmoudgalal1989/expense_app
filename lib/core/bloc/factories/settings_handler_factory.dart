import 'package:expense_app/core/bloc/handlers/settings_handler.dart';
import 'package:expense_app/core/bloc/handlers/initialization_handler.dart';
import 'package:expense_app/core/bloc/handlers/currency_settings_handler.dart';
import 'package:expense_app/core/bloc/handlers/category_settings_handler.dart';
import 'package:expense_app/features/currency/domain/repositories/currency_repository.dart';
import 'package:expense_app/features/category/domain/repositories/category_repository.dart';

/// Factory for creating settings handlers
/// Follows Factory Pattern and Dependency Inversion Principle
class SettingsHandlerFactory {
  final CurrencyRepository _currencyRepository;
  final CategoryRepository _categoryRepository;

  SettingsHandlerFactory({
    required CurrencyRepository currencyRepository,
    required CategoryRepository categoryRepository,
  })  : _currencyRepository = currencyRepository,
        _categoryRepository = categoryRepository;

  /// Create all default handlers
  List<SettingsHandler> createDefaultHandlers() {
    return [
      // Initialization handler
      InitializationHandler(
        currencyRepository: _currencyRepository,
        categoryRepository: _categoryRepository,
      ),

      // Currency handlers
      CurrencySettingsHandler(
        currencyRepository: _currencyRepository,
      ),
      LoadCurrenciesHandler(
        currencyRepository: _currencyRepository,
      ),

      // Category handlers
      CategoryAddedHandler(
        categoryRepository: _categoryRepository,
      ),
      CategoryUpdatedHandler(
        categoryRepository: _categoryRepository,
      ),
      CategoryRemovedHandler(
        categoryRepository: _categoryRepository,
      ),
      CategoriesReorderedHandler(
        categoryRepository: _categoryRepository,
      ),
    ];
  }

  /// Create a specific handler by type
  T createHandler<T extends SettingsHandler>() {
    switch (T) {
      case InitializationHandler:
        return InitializationHandler(
          currencyRepository: _currencyRepository,
          categoryRepository: _categoryRepository,
        ) as T;

      case CurrencySettingsHandler:
        return CurrencySettingsHandler(
          currencyRepository: _currencyRepository,
        ) as T;

      case LoadCurrenciesHandler:
        return LoadCurrenciesHandler(
          currencyRepository: _currencyRepository,
        ) as T;

      case CategoryAddedHandler:
        return CategoryAddedHandler(
          categoryRepository: _categoryRepository,
        ) as T;

      case CategoryUpdatedHandler:
        return CategoryUpdatedHandler(
          categoryRepository: _categoryRepository,
        ) as T;

      case CategoryRemovedHandler:
        return CategoryRemovedHandler(
          categoryRepository: _categoryRepository,
        ) as T;

      case CategoriesReorderedHandler:
        return CategoriesReorderedHandler(
          categoryRepository: _categoryRepository,
        ) as T;

      default:
        throw ArgumentError('Unknown handler type: $T');
    }
  }

  /// Create custom handler with additional dependencies
  SettingsHandler createCustomHandler(
    String handlerType,
    Map<String, dynamic> dependencies,
  ) {
    // This method allows for future extensibility
    // Custom handlers can be created based on configuration
    throw UnimplementedError('Custom handler creation not yet implemented');
  }
}
