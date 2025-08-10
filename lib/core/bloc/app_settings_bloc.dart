import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:expense_app/core/bloc/app_settings_event.dart';
import 'package:expense_app/core/bloc/app_settings_state.dart';
import 'package:expense_app/core/bloc/managers/settings_manager.dart';
import 'package:expense_app/core/bloc/factories/settings_handler_factory.dart';
import 'package:expense_app/core/bloc/handlers/settings_handler.dart';
import 'package:expense_app/features/currency/domain/repositories/currency_repository.dart';
import 'package:expense_app/features/category/domain/repositories/category_repository.dart';

/// Global BLoC that manages core app settings (currency and categories)
/// Refactored to follow SOLID principles:
/// - Single Responsibility: Each handler manages one aspect of settings
/// - Open/Closed: Easy to extend with new handlers without modifying existing code
/// - Liskov Substitution: All handlers implement the same interface
/// - Interface Segregation: Handlers only depend on what they need
/// - Dependency Inversion: Depends on abstractions, not concretions
class AppSettingsBloc extends Bloc<AppSettingsEvent, AppSettingsState> {
  final SettingsManager _settingsManager;
  final SettingsHandlerFactory _handlerFactory;

  /// Constructor with dependency injection
  AppSettingsBloc({
    required CurrencyRepository currencyRepository,
    required CategoryRepository categoryRepository,
    SettingsManager? settingsManager,
    SettingsHandlerFactory? handlerFactory,
  })  : _handlerFactory = handlerFactory ??
            SettingsHandlerFactory(
              currencyRepository: currencyRepository,
              categoryRepository: categoryRepository,
            ),
        _settingsManager = settingsManager ??
            SettingsManager(
              handlers: (handlerFactory ??
                      SettingsHandlerFactory(
                        currencyRepository: currencyRepository,
                        categoryRepository: categoryRepository,
                      ))
                  .createDefaultHandlers(),
            ),
        super(const AppSettingsInitial()) {
    // Register universal event handler
    on<AppSettingsEvent>(_onAppSettingsEvent);
  }

  /// Universal event handler that delegates to appropriate handlers
  /// Follows Open/Closed Principle - new handlers can be added without modifying this method
  Future<void> _onAppSettingsEvent(
    AppSettingsEvent event,
    Emitter<AppSettingsState> emit,
  ) async {
    try {
      await _settingsManager.processEvent(event, emit, state);
    } catch (error) {
      emit(AppSettingsError(
        'Failed to process event ${event.runtimeType}: $error',
      ));
    }
  }

  /// Add a new handler dynamically (for extensibility)
  /// Follows Open/Closed Principle - extend functionality without modifying existing code
  void addHandler(SettingsHandler handler) {
    _settingsManager.addHandler(handler);
  }

  /// Remove a handler dynamically
  void removeHandler(SettingsHandler handler) {
    _settingsManager.removeHandler(handler);
  }

  /// Check if a handler exists for an event type
  bool hasHandlerFor(AppSettingsEvent event) {
    return _settingsManager.hasHandlerFor(event);
  }

  /// Get all registered handlers (for debugging/testing)
  List<SettingsHandler> get handlers => _settingsManager.handlers;

  /// Create a new handler using the factory
  T createHandler<T extends SettingsHandler>() {
    return _handlerFactory.createHandler<T>();
  }
}
