import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:expense_app/core/bloc/app_settings_bloc.dart';
import 'package:expense_app/core/bloc/app_settings_event.dart';
import 'package:expense_app/core/bloc/app_settings_state.dart';
import 'package:expense_app/features/currency/domain/repositories/currency_repository.dart';
import 'package:expense_app/features/category/domain/repositories/category_repository.dart';
import 'package:expense_app/features/currency/domain/entities/currency.dart';
import 'package:expense_app/features/category/domain/entities/category.dart';

// Generate mocks
@GenerateMocks([CurrencyRepository, CategoryRepository])
import 'app_settings_bloc_test.mocks.dart';

void main() {
  group('AppSettingsBloc', () {
    late AppSettingsBloc bloc;
    late MockCurrencyRepository mockCurrencyRepository;
    late MockCategoryRepository mockCategoryRepository;

    setUp(() {
      mockCurrencyRepository = MockCurrencyRepository();
      mockCategoryRepository = MockCategoryRepository();
      bloc = AppSettingsBloc(
        currencyRepository: mockCurrencyRepository,
        categoryRepository: mockCategoryRepository,
      );
    });

    tearDown(() {
      bloc.close();
    });

    test('initial state is AppSettingsInitial', () {
      expect(bloc.state, equals(const AppSettingsInitial()));
    });

    group('InitializeAppSettings', () {
      test('emits [AppSettingsLoading, AppSettingsLoaded] when successful', () async {
        // Arrange
        final currencies = [
          const Currency(code: 'USD', name: 'US Dollar', symbol: '\$'),
          const Currency(code: 'EUR', name: 'Euro', symbol: '€'),
        ];
        final expenseCategories = <Category>[];
        final incomeCategories = <Category>[];
        final suggestedExpenseCategories = <Category>[];
        final suggestedIncomeCategories = <Category>[];

        when(mockCurrencyRepository.getAllCurrencies())
            .thenAnswer((_) async => currencies);
        when(mockCurrencyRepository.getSelectedCurrency())
            .thenAnswer((_) async => currencies.first);
        when(mockCategoryRepository.getUserCategories(CategoryType.expense))
            .thenAnswer((_) async => expenseCategories);
        when(mockCategoryRepository.getUserCategories(CategoryType.income))
            .thenAnswer((_) async => incomeCategories);
        when(mockCategoryRepository.getSuggestedCategories(CategoryType.expense))
            .thenAnswer((_) async => suggestedExpenseCategories);
        when(mockCategoryRepository.getSuggestedCategories(CategoryType.income))
            .thenAnswer((_) async => suggestedIncomeCategories);

        // Act & Assert
        expectLater(
          bloc.stream,
          emitsInOrder([
            const AppSettingsLoading(),
            AppSettingsLoaded(
              selectedCurrency: currencies.first,
              availableCurrencies: currencies,
              expenseCategories: expenseCategories,
              incomeCategories: incomeCategories,
              suggestedExpenseCategories: suggestedExpenseCategories,
              suggestedIncomeCategories: suggestedIncomeCategories,
            ),
          ]),
        );

        bloc.add(const InitializeAppSettings());
      });

      test('emits [AppSettingsLoading, AppSettingsError] when initialization fails', () async {
        // Arrange
        when(mockCurrencyRepository.getAllCurrencies())
            .thenThrow(Exception('Failed to load currencies'));

        // Act & Assert
        expectLater(
          bloc.stream,
          emitsInOrder([
            const AppSettingsLoading(),
            isA<AppSettingsError>(),
          ]),
        );

        bloc.add(const InitializeAppSettings());
      });
    });

    group('CurrencyChanged', () {
      test('emits [CurrencyUpdating, AppSettingsLoaded] when successful', () async {
        // Arrange
        final initialState = AppSettingsLoaded(
          selectedCurrency: const Currency(code: 'USD', name: 'US Dollar', symbol: '\$'),
          availableCurrencies: const [
            Currency(code: 'USD', name: 'US Dollar', symbol: '\$'),
            Currency(code: 'EUR', name: 'Euro', symbol: '€'),
          ],
          expenseCategories: const [],
          incomeCategories: const [],
          suggestedExpenseCategories: const [],
          suggestedIncomeCategories: const [],
        );
        
        bloc.emit(initialState);
        
        final newCurrency = const Currency(code: 'EUR', name: 'Euro', symbol: '€');
        when(mockCurrencyRepository.setSelectedCurrency(newCurrency))
            .thenAnswer((_) async {});

        // Act & Assert
        expectLater(
          bloc.stream,
          emitsInOrder([
            isA<CurrencyUpdating>(),
            initialState.copyWith(selectedCurrency: newCurrency),
          ]),
        );

        bloc.add(CurrencyChanged(newCurrency));
      });
    });
  });
}
