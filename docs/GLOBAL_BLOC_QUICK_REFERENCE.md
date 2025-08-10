# Global BLoC Refactoring - Quick Reference Card

## 🚨 RED FLAGS - Stop Immediately If You See:

```dart
// ❌ CRITICAL: Feature-specific state in global BLoC
class AppSettingsState {
  final List<Transaction> transactions; // NO!
  final String searchQuery; // NO!
  final bool isFormValid; // NO!
}

// ❌ CRITICAL: MaterialApp inside BlocBuilder
BlocBuilder<AppSettingsBloc, AppSettingsState>(
  builder: (context, state) {
    return MaterialApp(/* ... */); // FULL TREE REBUILD!
  },
)

// ❌ CRITICAL: Multiple repositories in BLoC
class AppSettingsBloc {
  final CurrencyRepository _currencyRepo;
  final CategoryRepository _categoryRepo;
  final ThemeRepository _themeRepo; // TOO MANY!
}
```

## ✅ GREEN PATTERNS - Good to Go:

```dart
// ✅ GOOD: Cross-cutting state only
class AppSettingsState {
  final Currency selectedCurrency;
  final List<Category> categories;
  final ThemeMode theme;
}

// ✅ GOOD: Granular selectors
BlocSelector<AppSettingsBloc, AppSettingsState, Currency>(
  selector: (state) => state.currency,
  builder: (context, currency) => CurrencyDisplay(currency),
)

// ✅ GOOD: Service layer aggregation
class AppSettingsBloc {
  final SettingsService _service; // Single dependency
}
```

## 📋 Code Review Checklist

### Scope Control
- [ ] Only cross-cutting state in global BLoC
- [ ] No feature-specific state (transactions, forms, etc.)
- [ ] State qualifies: 3+ features depend on it
- [ ] State is stable: <10 changes per session

### Performance
- [ ] BlocSelector used instead of BlocBuilder
- [ ] No MaterialApp/Scaffold inside BlocBuilder
- [ ] State split for granular updates
- [ ] copyWith methods are specific (copyWithCurrency)

### Architecture
- [ ] Handler pattern implemented
- [ ] Service layer aggregates repositories
- [ ] Handlers are testable in isolation
- [ ] SOLID principles followed

### Initialization
- [ ] Non-blocking startup
- [ ] Lazy loading implemented
- [ ] Partial rendering supported
- [ ] Error handling graceful

## 🔍 Quick Validation Commands

```bash
# Run validation tool
dart tools/refactoring_validator.dart

# Generate JSON report
dart tools/refactoring_validator.dart --json

# Check for anti-patterns
grep -r "BlocBuilder<AppSettingsBloc" lib/ | grep -v "BlocSelector"
grep -r "MaterialApp" lib/ | grep -B5 -A5 "BlocBuilder"
```

## 📊 Performance Benchmarks

| Metric | Before | After | Target |
|--------|--------|-------|--------|
| Widget Rebuilds | 100% | 40% | <50% |
| Memory Usage | 50MB | 45MB | <55MB |
| Startup Time | 800ms | 750ms | <900ms |

## 🎯 Decision Matrix

**Should this state be in global BLoC?**

| Criteria | Weight | Score (1-5) | Total |
|----------|--------|-------------|-------|
| Used by 3+ features | 3x | ___ | ___ |
| Changes <10x per session | 2x | ___ | ___ |
| Fundamental to app | 2x | ___ | ___ |
| Causes sync issues if separate | 1x | ___ | ___ |

**Total Score: ___/40**
- 30+: ✅ Global BLoC
- 20-29: ⚠️ Consider carefully  
- <20: ❌ Feature-specific BLoC

## 🚀 Migration Phases

### Phase 1: Setup
- [ ] Create global BLoC alongside existing
- [ ] Implement handler pattern
- [ ] Add feature flags
- [ ] Create validation tools

### Phase 2: Migrate
- [ ] Move currency to global (low risk)
- [ ] Move categories to global
- [ ] Update UI components
- [ ] Run validation tests

### Phase 3: Cleanup
- [ ] Remove old BLoCs
- [ ] Update documentation
- [ ] Train team
- [ ] Monitor metrics

## 🆘 Emergency Rollback

If things go wrong:

```dart
// Immediate rollback via feature flag
class FeatureFlags {
  static bool useGlobalSettingsBloc = false; // DISABLE
}

// Or revert to MultiBlocProvider
MultiBlocProvider(
  providers: [
    BlocProvider<CurrencyBloc>(create: (context) => sl<CurrencyBloc>()),
    BlocProvider<CategoryBloc>(create: (context) => sl<CategoryBloc>()),
  ],
  child: App(),
)
```

## 📞 Need Help?

- **Architecture Questions**: Check `GLOBAL_BLOC_REFACTORING_GUIDELINES.md`
- **Validation Issues**: Run `dart tools/refactoring_validator.dart`
- **Performance Problems**: Profile with Flutter Inspector
- **Test Failures**: Check handler isolation

---

**Remember**: Global BLoC is for **stable, cross-cutting state only**. When in doubt, keep it feature-specific!
