import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:expense_app/core/bloc/app_settings_event.dart';
import 'package:expense_app/core/bloc/app_settings_state.dart';
import 'package:expense_app/core/bloc/handlers/settings_handler.dart';

/// Settings manager that coordinates multiple handlers
/// Follows Open/Closed Principle - open for extension, closed for modification
/// Follows Dependency Inversion Principle - depends on abstractions, not concretions
class SettingsManager {
  final List<SettingsHandler> _handlers;

  SettingsManager({
    required List<SettingsHandler> handlers,
  }) : _handlers = List.from(handlers)..sort((a, b) => a.priority.compareTo(b.priority));

  /// Process an event using the appropriate handler
  Future<void> processEvent(
    AppSettingsEvent event,
    Emitter<AppSettingsState> emit,
    AppSettingsState currentState,
  ) async {
    final handler = _findHandler(event);
    if (handler != null) {
      await handler.handle(event as dynamic, emit, currentState);
    } else {
      emit(AppSettingsError(
        'No handler found for event: ${event.runtimeType}',
      ));
    }
  }

  /// Find the appropriate handler for an event
  SettingsHandler? _findHandler(AppSettingsEvent event) {
    return _handlers.firstWhere(
      (handler) => handler.canHandle(event),
      orElse: () => throw StateError('No handler found for event: ${event.runtimeType}'),
    );
  }

  /// Add a new handler (for extensibility)
  void addHandler(SettingsHandler handler) {
    _handlers.add(handler);
    _handlers.sort((a, b) => a.priority.compareTo(b.priority));
  }

  /// Remove a handler
  void removeHandler(SettingsHandler handler) {
    _handlers.remove(handler);
  }

  /// Get all registered handlers
  List<SettingsHandler> get handlers => List.unmodifiable(_handlers);

  /// Check if a handler exists for an event type
  bool hasHandlerFor(AppSettingsEvent event) {
    return _handlers.any((handler) => handler.canHandle(event));
  }
}
