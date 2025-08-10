/// Proper Global BLoC Implementation Example
/// 
/// This file demonstrates the correct implementation of global BLoC
/// following all architectural guardrails and best practices.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

// ============================================================================
// 1. SCOPE CONTROL - Only Cross-cutting, Stable State
// ============================================================================

/// ✅ GOOD: Cross-cutting application settings
class AppSettingsState extends Equatable {
  final CurrencySettings currencySettings;
  final CategorySettings categorySettings;
  final ThemeSettings themeSettings;
  final LocaleSettings localeSettings;
  
  const AppSettingsState({
    required this.currencySettings,
    required this.categorySettings,
    required this.themeSettings,
    required this.localeSettings,
  });
  
  /// Granular update methods to prevent unnecessary rebuilds
  AppSettingsState copyWithCurrency(CurrencySettings currency) {
    return AppSettingsState(
      currencySettings: currency,
      categorySettings: categorySettings,
      themeSettings: themeSettings,
      localeSettings: localeSettings,
    );
  }
  
  AppSettingsState copyWithCategories(CategorySettings categories) {
    return AppSettingsState(
      currencySettings: currencySettings,
      categorySettings: categories,
      themeSettings: themeSettings,
      localeSettings: localeSettings,
    );
  }
  
  @override
  List<Object> get props => [
    currencySettings,
    categorySettings, 
    themeSettings,
    localeSettings,
  ];
}

/// Sub-state classes for granular updates
class CurrencySettings extends Equatable {
  final Currency selectedCurrency;
  final List<Currency> availableCurrencies;
  
  const CurrencySettings({
    required this.selectedCurrency,
    required this.availableCurrencies,
  });
  
  @override
  List<Object> get props => [selectedCurrency, availableCurrencies];
}

class CategorySettings extends Equatable {
  final List<Category> expenseCategories;
  final List<Category> incomeCategories;
  
  const CategorySettings({
    required this.expenseCategories,
    required this.incomeCategories,
  });
  
  List<Category> getCategoriesByType(CategoryType type) {
    return type == CategoryType.expense ? expenseCategories : incomeCategories;
  }
  
  @override
  List<Object> get props => [expenseCategories, incomeCategories];
}

// ============================================================================
// 2. DEPENDENCY BOUNDARIES - Service Layer Aggregation
// ============================================================================

/// ✅ GOOD: Service layer aggregates repository calls
class SettingsService {
  final CurrencyRepository _currencyRepository;
  final CategoryRepository _categoryRepository;
  final ThemeRepository _themeRepository;
  final LocaleRepository _localeRepository;
  
  SettingsService({
    required CurrencyRepository currencyRepository,
    required CategoryRepository categoryRepository,
    required ThemeRepository themeRepository,
    required LocaleRepository localeRepository,
  }) : _currencyRepository = currencyRepository,
       _categoryRepository = categoryRepository,
       _themeRepository = themeRepository,
       _localeRepository = localeRepository;
  
  /// Non-blocking initialization with parallel loading
  Future<AppSettingsState> initializeSettings() async {
    try {
      // Load settings in parallel for better performance
      final results = await Future.wait([
        _loadCurrencySettings(),
        _loadCategorySettings(),
        _loadThemeSettings(),
        _loadLocaleSettings(),
      ]);
      
      return AppSettingsState(
        currencySettings: results[0] as CurrencySettings,
        categorySettings: results[1] as CategorySettings,
        themeSettings: results[2] as ThemeSettings,
        localeSettings: results[3] as LocaleSettings,
      );
    } catch (e) {
      // Return default settings if loading fails
      return _getDefaultSettings();
    }
  }
  
  /// Lazy loading for individual settings
  Future<CurrencySettings> _loadCurrencySettings() async {
    final selected = await _currencyRepository.getSelectedCurrency();
    final available = await _currencyRepository.getAvailableCurrencies();
    
    return CurrencySettings(
      selectedCurrency: selected,
      availableCurrencies: available,
    );
  }
  
  Future<CategorySettings> _loadCategorySettings() async {
    final expense = await _categoryRepository.getUserCategories(CategoryType.expense);
    final income = await _categoryRepository.getUserCategories(CategoryType.income);
    
    return CategorySettings(
      expenseCategories: expense,
      incomeCategories: income,
    );
  }
  
  // Additional service methods...
  Future<void> updateCurrency(Currency currency) async {
    await _currencyRepository.saveCurrency(currency);
  }
  
  Future<void> addCategory(Category category) async {
    await _categoryRepository.addUserCategory(category, category.type);
  }
}

// ============================================================================
// 3. TESTABILITY - Handler Pattern Implementation
// ============================================================================

/// ✅ GOOD: Testable handler interface
abstract class SettingsHandler<T extends AppSettingsEvent> {
  Future<void> handle(T event, Emitter<AppSettingsState> emit, AppSettingsState currentState);
}

/// ✅ GOOD: Isolated, testable currency handler
class CurrencySettingsHandler implements SettingsHandler<CurrencyChanged> {
  final SettingsService _settingsService;
  
  CurrencySettingsHandler(this._settingsService);
  
  @override
  Future<void> handle(
    CurrencyChanged event,
    Emitter<AppSettingsState> emit,
    AppSettingsState currentState,
  ) async {
    try {
      // Emit loading state for currency only
      emit(currentState.copyWithCurrency(
        currentState.currencySettings.copyWith(isLoading: true),
      ));
      
      // Update currency through service
      await _settingsService.updateCurrency(event.currency);
      
      // Load updated currency settings
      final updatedCurrencySettings = await _settingsService._loadCurrencySettings();
      
      // Emit updated state
      emit(currentState.copyWithCurrency(updatedCurrencySettings));
    } catch (e) {
      // Emit error state for currency only
      emit(currentState.copyWithCurrency(
        currentState.currencySettings.copyWith(error: e.toString()),
      ));
    }
  }
}

/// ✅ GOOD: Handler factory for dependency injection
class SettingsHandlerFactory {
  final SettingsService _settingsService;
  
  SettingsHandlerFactory(this._settingsService);
  
  T createHandler<T extends SettingsHandler>() {
    switch (T) {
      case CurrencySettingsHandler:
        return CurrencySettingsHandler(_settingsService) as T;
      case CategorySettingsHandler:
        return CategorySettingsHandler(_settingsService) as T;
      default:
        throw ArgumentError('Unknown handler type: $T');
    }
  }
}

// ============================================================================
// 4. GLOBAL BLOC - Lightweight Orchestrator
// ============================================================================

/// ✅ GOOD: Lightweight global BLoC that delegates to handlers
class AppSettingsBloc extends Bloc<AppSettingsEvent, AppSettingsState> {
  final SettingsService _settingsService;
  final SettingsHandlerFactory _handlerFactory;
  
  AppSettingsBloc({
    required SettingsService settingsService,
    required SettingsHandlerFactory handlerFactory,
  }) : _settingsService = settingsService,
       _handlerFactory = handlerFactory,
       super(AppSettingsInitial()) {
    
    // Register event handlers
    on<InitializeAppSettings>(_onInitializeSettings);
    on<CurrencyChanged>(_onCurrencyChanged);
    on<CategoryAdded>(_onCategoryAdded);
    on<CategoryUpdated>(_onCategoryUpdated);
    on<ThemeChanged>(_onThemeChanged);
  }
  
  /// Non-blocking initialization
  Future<void> _onInitializeSettings(
    InitializeAppSettings event,
    Emitter<AppSettingsState> emit,
  ) async {
    try {
      // Don't block - emit loading state immediately
      emit(AppSettingsLoading());
      
      // Load settings asynchronously
      final settings = await _settingsService.initializeSettings();
      emit(settings);
    } catch (e) {
      // Emit error but allow partial functionality
      emit(AppSettingsError(e.toString()));
    }
  }
  
  /// Delegate to specialized handler
  Future<void> _onCurrencyChanged(
    CurrencyChanged event,
    Emitter<AppSettingsState> emit,
  ) async {
    final handler = _handlerFactory.createHandler<CurrencySettingsHandler>();
    await handler.handle(event, emit, state);
  }
  
  // Additional event handlers delegate to specialized handlers...
}

// ============================================================================
// 5. PERFORMANCE PROTECTION - Granular Widget Updates
// ============================================================================

/// ✅ GOOD: Granular selector for currency display
class CurrencyDisplay extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocSelector<AppSettingsBloc, AppSettingsState, Currency?>(
      selector: (state) {
        if (state is AppSettingsLoaded) {
          return state.currencySettings.selectedCurrency;
        }
        return null;
      },
      builder: (context, currency) {
        // Only rebuilds when currency changes
        if (currency == null) {
          return const CircularProgressIndicator();
        }
        
        return Text(
          currency.symbol,
          style: Theme.of(context).textTheme.headlineMedium,
        );
      },
    );
  }
}

/// ✅ GOOD: Scoped BLoC builder for categories
class CategoryList extends StatelessWidget {
  final CategoryType type;
  
  const CategoryList({required this.type, Key? key}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return BlocSelector<AppSettingsBloc, AppSettingsState, List<Category>>(
      selector: (state) {
        if (state is AppSettingsLoaded) {
          return state.categorySettings.getCategoriesByType(type);
        }
        return <Category>[];
      },
      builder: (context, categories) {
        // Only rebuilds when categories of this type change
        return ListView.builder(
          itemCount: categories.length,
          itemBuilder: (context, index) {
            return CategoryTile(category: categories[index]);
          },
        );
      },
    );
  }
}

/// ✅ GOOD: App-level theme selector (prevents full tree rebuilds)
class ThemedApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocSelector<AppSettingsBloc, AppSettingsState, ThemeData>(
      selector: (state) {
        if (state is AppSettingsLoaded) {
          return state.themeSettings.themeData;
        }
        return ThemeData.light(); // Default theme
      },
      builder: (context, theme) {
        // Only rebuilds when theme changes
        return MaterialApp(
          theme: theme,
          home: const HomePage(),
          // App structure stays stable
        );
      },
    );
  }
}

// ============================================================================
// 6. INITIALIZATION STRATEGY - Progressive Loading
// ============================================================================

/// ✅ GOOD: Progressive loading with partial rendering
class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Expense Tracker'),
        // Always available regardless of settings state
      ),
      body: BlocBuilder<AppSettingsBloc, AppSettingsState>(
        builder: (context, state) {
          return Column(
            children: [
              // Core functionality always available
              const TransactionForm(),
              
              // Progressive enhancement based on loaded settings
              if (state is AppSettingsLoaded) ...[
                // Currency display when currency settings loaded
                if (state.currencySettings.isLoaded)
                  CurrencyDisplay(),
                
                // Categories when category settings loaded  
                if (state.categorySettings.isLoaded)
                  CategoryList(type: CategoryType.expense),
              ] else if (state is AppSettingsLoading) ...[
                // Show loading indicators for individual sections
                const CurrencyLoadingPlaceholder(),
                const CategoryLoadingPlaceholder(),
              ] else if (state is AppSettingsError) ...[
                // Graceful error handling with retry options
                ErrorBanner(
                  message: state.message,
                  onRetry: () {
                    context.read<AppSettingsBloc>().add(
                      const InitializeAppSettings(),
                    );
                  },
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}

// ============================================================================
// 7. MIGRATION SAFETY - Feature Flag Support
// ============================================================================

/// ✅ GOOD: Feature flag for gradual migration
class SettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // Feature flag for gradual rollout
    final useGlobalSettings = FeatureFlags.instance.isEnabled('global_settings_bloc');
    
    if (useGlobalSettings) {
      return _buildGlobalSettingsUI();
    } else {
      return _buildLegacySettingsUI();
    }
  }
  
  Widget _buildGlobalSettingsUI() {
    return BlocBuilder<AppSettingsBloc, AppSettingsState>(
      builder: (context, state) {
        if (state is AppSettingsLoaded) {
          return Column(
            children: [
              CurrencySettingsSection(
                settings: state.currencySettings,
                onCurrencyChanged: (currency) {
                  context.read<AppSettingsBloc>().add(
                    CurrencyChanged(currency),
                  );
                },
              ),
              CategorySettingsSection(
                settings: state.categorySettings,
                onCategoryAdded: (category) {
                  context.read<AppSettingsBloc>().add(
                    CategoryAdded(category),
                  );
                },
              ),
            ],
          );
        }
        
        return const SettingsLoadingView();
      },
    );
  }
  
  Widget _buildLegacySettingsUI() {
    // Keep legacy implementation during migration
    return MultiBlocBuilder(
      builders: [
        BlocBuilder<CurrencyBloc, CurrencyState>(),
        BlocBuilder<CategoryBloc, CategoryState>(),
      ],
      builder: (context, states) {
        // Legacy UI implementation
        return const LegacySettingsView();
      },
    );
  }
}

// ============================================================================
// 8. TESTING SUPPORT - Mockable Dependencies
// ============================================================================

/// ✅ GOOD: Testable handler with mocked dependencies
class MockSettingsService implements SettingsService {
  @override
  Future<AppSettingsState> initializeSettings() async {
    return const AppSettingsLoaded(
      currencySettings: CurrencySettings(
        selectedCurrency: Currency.usd(),
        availableCurrencies: [Currency.usd(), Currency.eur()],
      ),
      categorySettings: CategorySettings(
        expenseCategories: [Category.food(), Category.transport()],
        incomeCategories: [Category.salary()],
      ),
      themeSettings: ThemeSettings.light(),
      localeSettings: LocaleSettings.english(),
    );
  }
  
  // Mock implementations for testing...
}

// Example unit test
void main() {
  group('CurrencySettingsHandler', () {
    late CurrencySettingsHandler handler;
    late MockSettingsService mockService;
    
    setUp(() {
      mockService = MockSettingsService();
      handler = CurrencySettingsHandler(mockService);
    });
    
    test('should update currency when CurrencyChanged event is handled', () async {
      // Arrange
      final event = CurrencyChanged(Currency.eur());
      final currentState = AppSettingsLoaded.initial();
      final emitter = MockEmitter<AppSettingsState>();
      
      // Act
      await handler.handle(event, emitter, currentState);
      
      // Assert
      verify(mockService.updateCurrency(Currency.eur())).called(1);
      expect(emitter.states.last.currencySettings.selectedCurrency, Currency.eur());
    });
  });
}

// ============================================================================
// SUMMARY: This implementation demonstrates:
// 
// ✅ Proper scope control (only cross-cutting state)
// ✅ Performance protection (granular selectors)  
// ✅ Testability (handler pattern with DI)
// ✅ Dependency boundaries (service layer)
// ✅ Non-blocking initialization (progressive loading)
// ✅ God BLoC prevention (focused responsibility)
// ✅ Migration safety (feature flags)
// ✅ SOLID principles compliance
// ============================================================================
