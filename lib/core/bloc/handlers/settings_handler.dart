import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:expense_app/core/bloc/app_settings_event.dart';
import 'package:expense_app/core/bloc/app_settings_state.dart';

/// Abstract base class for settings handlers
/// Follows Single Responsibility Principle - each handler manages one aspect of settings
abstract class SettingsHandler<T extends AppSettingsEvent> {
  /// Handle a specific type of settings event
  Future<void> handle(
    T event,
    Emitter<AppSettingsState> emit,
    AppSettingsState currentState,
  );

  /// Check if this handler can process the given event
  bool canHandle(AppSettingsEvent event) => event is T;

  /// Get the priority of this handler (lower numbers = higher priority)
  int get priority => 0;
}

/// Interface for settings data loading
abstract class SettingsDataLoader {
  Future<Map<String, dynamic>> loadInitialData();
}

/// Interface for settings persistence
abstract class SettingsPersistence {
  Future<void> persistSettings(Map<String, dynamic> settings);
  Future<Map<String, dynamic>> loadPersistedSettings();
}

/// Interface for settings validation
abstract class SettingsValidator {
  bool validate(Map<String, dynamic> settings);
  List<String> getValidationErrors(Map<String, dynamic> settings);
}
