# Global BLoC Refactoring Guidelines

## Overview
This document provides architectural guardrails for consolidating multiple feature-specific BLoCs into a single global BLoC in Flutter projects, ensuring performance, maintainability, and testability.

## 🎯 Core Principles

### 1. Scope Control - What Belongs in Global BLoC

#### ✅ INCLUDE (Cross-cutting, Stable State)
- **Application Settings**: Currency, language, theme preferences
- **User Preferences**: Display options, notification settings
- **Core Configuration**: Categories, tags, default values
- **Authentication State**: User session, permissions
- **App-wide Cache**: Reference data, lookup tables

#### ❌ EXCLUDE (Feature-specific, Volatile State)
- **Transactional Data**: Individual transactions, search results
- **Form State**: Input validation, temporary form data
- **Navigation State**: Current page, modal states
- **Feature-specific Filters**: Search criteria, sorting options
- **Real-time Data**: Live updates, streaming data

```dart
// ✅ GOOD: Global settings state
class AppSettingsState {
  final Currency selectedCurrency;
  final List<Category> categories;
  final ThemeMode themeMode;
  final Locale locale;
}

// ❌ BAD: Feature-specific state in global BLoC
class AppSettingsState {
  final List<Transaction> recentTransactions; // Belongs in TransactionBloc
  final String searchQuery; // Belongs in SearchBloc
  final bool isLoading; // Too generic, belongs in specific features
}
```

### 2. Performance Protection

#### Granular State Updates
```dart
// ✅ GOOD: Split state to prevent unnecessary rebuilds
class AppSettingsLoaded extends AppSettingsState {
  final CurrencySettings currencySettings;
  final CategorySettings categorySettings;
  final ThemeSettings themeSettings;
  
  // Only currency-dependent widgets rebuild when currency changes
  AppSettingsLoaded copyWithCurrency(CurrencySettings currency) {
    return AppSettingsLoaded(
      currencySettings: currency,
      categorySettings: categorySettings,
      themeSettings: themeSettings,
    );
  }
}

// Use BlocSelector for granular rebuilds
BlocSelector<AppSettingsBloc, AppSettingsState, Currency>(
  selector: (state) => state is AppSettingsLoaded 
    ? state.currencySettings.selectedCurrency 
    : null,
  builder: (context, currency) {
    // Only rebuilds when currency changes
    return CurrencyDisplay(currency: currency);
  },
)
```

#### Avoid Full Widget Tree Rebuilds
```dart
// ❌ BAD: Causes full tree rebuild
BlocBuilder<AppSettingsBloc, AppSettingsState>(
  builder: (context, state) {
    return MaterialApp(
      theme: state.theme,
      home: HomePage(), // Entire app rebuilds on any settings change
    );
  },
)

// ✅ GOOD: Scoped rebuilds
class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocSelector<AppSettingsBloc, AppSettingsState, ThemeData>(
      selector: (state) => state.theme,
      builder: (context, theme) {
        return MaterialApp(
          theme: theme, // Only theme changes trigger rebuild
          home: const HomePage(),
        );
      },
    );
  }
}
```

### 3. Testability Through Modularity

#### Handler Pattern Implementation
```dart
// ✅ GOOD: Testable, modular handlers
abstract class SettingsHandler<T extends AppSettingsEvent> {
  Future<void> handle(T event, Emitter<AppSettingsState> emit);
}

class CurrencySettingsHandler implements SettingsHandler<CurrencyChanged> {
  final CurrencyRepository _repository;
  
  CurrencySettingsHandler(this._repository);
  
  @override
  Future<void> handle(CurrencyChanged event, Emitter<AppSettingsState> emit) async {
    // Isolated, testable logic
    final updatedCurrency = await _repository.saveCurrency(event.currency);
    emit(state.copyWithCurrency(updatedCurrency));
  }
}

// Test handlers in isolation
void main() {
  group('CurrencySettingsHandler', () {
    late CurrencySettingsHandler handler;
    late MockCurrencyRepository mockRepository;
    
    setUp(() {
      mockRepository = MockCurrencyRepository();
      handler = CurrencySettingsHandler(mockRepository);
    });
    
    test('should update currency when CurrencyChanged event is handled', () async {
      // Test specific handler logic without BLoC complexity
    });
  });
}
```

### 4. Dependency Boundaries

#### SettingsService Aggregation Layer
```dart
// ✅ GOOD: Service layer aggregates repository calls
class SettingsService {
  final CurrencyRepository _currencyRepository;
  final CategoryRepository _categoryRepository;
  final ThemeRepository _themeRepository;
  
  SettingsService({
    required CurrencyRepository currencyRepository,
    required CategoryRepository categoryRepository,
    required ThemeRepository themeRepository,
  }) : _currencyRepository = currencyRepository,
       _categoryRepository = categoryRepository,
       _themeRepository = themeRepository;
  
  /// Aggregate initialization - loads all settings in parallel
  Future<AppSettingsData> initializeSettings() async {
    final results = await Future.wait([
      _currencyRepository.getSelectedCurrency(),
      _categoryRepository.getUserCategories(),
      _themeRepository.getThemePreference(),
    ]);
    
    return AppSettingsData(
      currency: results[0] as Currency,
      categories: results[1] as List<Category>,
      theme: results[2] as ThemeMode,
    );
  }
}

// BLoC depends only on service, not multiple repositories
class AppSettingsBloc extends Bloc<AppSettingsEvent, AppSettingsState> {
  final SettingsService _settingsService;
  
  AppSettingsBloc({required SettingsService settingsService})
      : _settingsService = settingsService,
        super(const AppSettingsInitial());
}
```

### 5. Initialization Strategy

#### Non-blocking Lazy Loading
```dart
// ✅ GOOD: Lazy initialization with partial rendering
class AppSettingsBloc extends Bloc<AppSettingsEvent, AppSettingsState> {
  AppSettingsBloc({required SettingsService settingsService})
      : _settingsService = settingsService,
        super(const AppSettingsInitial()) {
    
    // Allow partial initialization
    on<InitializeCurrencySettings>(_onInitializeCurrency);
    on<InitializeCategorySettings>(_onInitializeCategories);
    on<InitializeThemeSettings>(_onInitializeTheme);
  }
  
  Future<void> _onInitializeCurrency(
    InitializeCurrencySettings event,
    Emitter<AppSettingsState> emit,
  ) async {
    try {
      final currency = await _settingsService.loadCurrency();
      emit(state.copyWithCurrency(currency));
    } catch (e) {
      // Currency loading failed, but app can still function
      emit(state.copyWithCurrencyError(e.toString()));
    }
  }
}

// App can render with partial settings
class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppSettingsBloc, AppSettingsState>(
      builder: (context, state) {
        return Scaffold(
          body: Column(
            children: [
              // Always available
              const AppHeader(),
              
              // Conditional rendering based on loaded settings
              if (state.hasCurrency) 
                CurrencyDisplay(currency: state.currency),
              
              if (state.hasCategories)
                CategoryList(categories: state.categories),
              
              // Core functionality works even with partial settings
              const TransactionForm(),
            ],
          ),
        );
      },
    );
  }
}
```

### 6. Preventing "God BLoC" Syndrome

#### Clear Qualification Criteria
```dart
/// Decision Matrix for Global BLoC Inclusion
/// 
/// Ask these questions before adding state to global BLoC:
/// 
/// 1. Is this state needed by 3+ different features? 
/// 2. Does this state rarely change (< 10 times per user session)?
/// 3. Is this state fundamental to app operation?
/// 4. Would duplicating this state cause synchronization issues?
/// 
/// If all answers are YES, it qualifies for global BLoC.
/// If any answer is NO, create a feature-specific BLoC.

class GlobalBlocQualificationChecker {
  static bool qualifiesForGlobalBloc({
    required int dependentFeatures,
    required int changesPerSession,
    required bool isFundamental,
    required bool causesSyncIssues,
  }) {
    return dependentFeatures >= 3 &&
           changesPerSession < 10 &&
           isFundamental &&
           causesSyncIssues;
  }
}

// Example usage in code review
// Currency Settings:
// - dependentFeatures: 5 (transactions, reports, settings, budget, export)
// - changesPerSession: 2 (user rarely changes currency)
// - isFundamental: true (affects all monetary displays)
// - causesSyncIssues: true (inconsistent currency display)
// Result: ✅ Qualifies for global BLoC

// Search Query:
// - dependentFeatures: 1 (search feature only)
// - changesPerSession: 50+ (user types frequently)
// - isFundamental: false (app works without search)
// - causesSyncIssues: false (search is isolated)
// Result: ❌ Does not qualify for global BLoC
```

### 7. Migration Safety

#### Incremental Rollout Strategy
```dart
// Phase 1: Create global BLoC alongside existing BLoCs
class MainApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        // New global BLoC
        BlocProvider<AppSettingsBloc>(
          create: (context) => sl<AppSettingsBloc>(),
        ),
        // Keep existing BLoCs during migration
        BlocProvider<CurrencyBloc>(
          create: (context) => sl<CurrencyBloc>(),
        ),
        BlocProvider<CategoryBloc>(
          create: (context) => sl<CategoryBloc>(),
        ),
      ],
      child: MaterialApp(home: HomePage()),
    );
  }
}

// Phase 2: Feature flag for gradual migration
class SettingsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final useGlobalBloc = FeatureFlags.useGlobalSettingsBloc;
    
    if (useGlobalBloc) {
      return BlocBuilder<AppSettingsBloc, AppSettingsState>(
        builder: (context, state) => _buildSettingsUI(state),
      );
    } else {
      return MultiBlocBuilder(
        builders: [
          BlocBuilder<CurrencyBloc, CurrencyState>(),
          BlocBuilder<CategoryBloc, CategoryState>(),
        ],
        builder: (context, states) => _buildLegacySettingsUI(states),
      );
    }
  }
}

// Phase 3: Remove old BLoCs only after full parity
class MigrationValidator {
  static bool canRemoveLegacyBlocs() {
    return FeatureFlags.useGlobalSettingsBloc &&
           _allFeaturesUsingGlobalBloc() &&
           _integrationTestsPassing();
  }
}
```

## 🛠️ Implementation Checklist

### Pre-Refactoring Assessment
- [ ] Identify cross-cutting state vs feature-specific state
- [ ] Map dependencies between current BLoCs
- [ ] Analyze performance impact of current architecture
- [ ] Document existing behavior for regression testing

### During Refactoring
- [ ] Create SettingsService aggregation layer
- [ ] Implement handler pattern for modularity
- [ ] Add granular state selectors
- [ ] Implement lazy loading for non-critical settings
- [ ] Add feature flags for gradual rollout

### Post-Refactoring Validation
- [ ] Performance benchmarks show no regression
- [ ] All existing functionality preserved
- [ ] Test coverage maintained or improved
- [ ] Documentation updated
- [ ] Team training completed

## 📊 Success Metrics

### Performance Metrics
- Widget rebuild count reduction: Target 60%+ reduction
- Memory usage: No increase in peak memory
- App startup time: No increase in time-to-interactive

### Code Quality Metrics
- Cyclomatic complexity: Each handler < 10
- Test coverage: Maintain 80%+ coverage
- Code duplication: Eliminate duplicate state management

### Developer Experience Metrics
- Build time: No significant increase
- Hot reload performance: Maintained or improved
- Debugging complexity: Reduced due to centralized state

## 🚨 Red Flags - When to Stop

Stop the refactoring if you encounter:

1. **Performance Degradation**: Widget rebuilds increase significantly
2. **Complexity Explosion**: BLoC becomes difficult to understand
3. **Testing Difficulties**: Cannot test components in isolation
4. **Team Resistance**: Developers struggle with new patterns
5. **Feature Coupling**: Unrelated features become interdependent

## 📝 Code Review Checklist

### Architecture Review
- [ ] Only cross-cutting state included in global BLoC
- [ ] Handler pattern properly implemented
- [ ] Service layer aggregates repository calls
- [ ] SOLID principles maintained

### Performance Review
- [ ] BlocSelector used for granular updates
- [ ] State split to prevent unnecessary rebuilds
- [ ] No blocking initialization
- [ ] Memory leaks prevented

### Testability Review
- [ ] Handlers testable in isolation
- [ ] Mock services available
- [ ] Integration tests updated
- [ ] Regression tests passing

## 🎓 Training Materials

### For Developers
1. **Global BLoC Principles Workshop** (2 hours)
2. **Handler Pattern Implementation** (1 hour)
3. **Performance Optimization Techniques** (1.5 hours)
4. **Testing Strategies** (1 hour)

### For Code Reviewers
1. **Architectural Decision Review** (30 minutes)
2. **Performance Impact Assessment** (30 minutes)
3. **Red Flag Identification** (30 minutes)

---

## 📚 References

- [BLoC Pattern Documentation](https://bloclibrary.dev/)
- [Flutter Performance Best Practices](https://flutter.dev/docs/perf)
- [SOLID Principles in Flutter](https://medium.com/flutter-community/solid-principles-in-flutter)
- [Clean Architecture in Flutter](https://resocoder.com/flutter-clean-architecture-tdd/)

---

*This guide is based on real-world refactoring experience and should be adapted to your specific project needs.*
