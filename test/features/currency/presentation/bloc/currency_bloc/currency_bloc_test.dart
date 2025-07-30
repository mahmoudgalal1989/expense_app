import 'package:dartz/dartz.dart';
import 'package:expense_app/core/error/failures.dart';
import 'package:expense_app/core/usecases/command.dart';
import 'package:expense_app/features/currency/domain/entities/currency.dart';
import 'package:expense_app/features/currency/domain/usecases/set_selected_currency.dart';
import 'package:expense_app/features/currency/domain/usecases/search_currencies.dart' as search_usecase;
import 'package:expense_app/features/currency/presentation/bloc/currency_bloc/currency_bloc.dart';
import 'package:expense_app/features/currency/presentation/bloc/currency_bloc/currency_event.dart';
import 'package:expense_app/features/currency/presentation/bloc/currency_bloc/currency_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

// Fallback for NoParams
class MockNoParams extends Mock implements NoParams {}

// Mock classes for Command pattern use cases
class MockGetAllCurrencies extends Mock implements Command<List<Currency>, NoParams> {}
class MockSetSelectedCurrency extends Mock implements Command<void, SetSelectedCurrencyParams> {}
class MockSearchCurrencies extends Mock implements Command<List<Currency>, search_usecase.SearchCurrenciesParams> {}

// Fake classes for fallback values
class FakeSetSelectedCurrencyParams extends Fake implements SetSelectedCurrencyParams {}
class FakeSearchCurrenciesParams extends Fake implements search_usecase.SearchCurrenciesParams {}

void main() {
  // Register fallback values
  setUpAll(() {
    registerFallbackValue(MockNoParams());
    registerFallbackValue(FakeSetSelectedCurrencyParams());
    registerFallbackValue(FakeSearchCurrenciesParams());
  });
  // Test data
  final tCurrencies = [
    const Currency(
      code: 'USD',
      countryName: 'United States',
      flagIconPath: 'assets/flags/us.png',
      isMostUsed: true,
      isSelected: true,  // USD is initially selected
    ),
    const Currency(
      code: 'EUR',
      countryName: 'Euro',
      flagIconPath: 'assets/flags/eu.png',
      isMostUsed: true,
      isSelected: false,
    ),
    const Currency(
      code: 'GBP',
      countryName: 'British Pound',
      flagIconPath: 'assets/flags/gb.png',
      isMostUsed: true,
      isSelected: false,
    ),
  ];

  // Mocks
  late MockGetAllCurrencies mockGetAllCurrencies;
  late MockSetSelectedCurrency mockSetSelectedCurrency;
  late MockSearchCurrencies mockSearchCurrencies;

  // Helper to create a test bloc with the current mocks
  CurrencyBloc createTestBloc() {
    return CurrencyBloc(
      getAllCurrencies: mockGetAllCurrencies,
      setSelectedCurrency: mockSetSelectedCurrency,
      searchCurrencies: mockSearchCurrencies,
    );
  }

  // Setup that runs before each test
  void commonSetUp() {
    // Reset all mocks
    mockGetAllCurrencies = MockGetAllCurrencies();
    mockSetSelectedCurrency = MockSetSelectedCurrency();
    mockSearchCurrencies = MockSearchCurrencies();
    
    // Setup default mock responses
    when(() => mockGetAllCurrencies(any()))
        .thenAnswer((_) async => Right<Failure, List<Currency>>(tCurrencies));
    when(() => mockSetSelectedCurrency(any()))
        .thenAnswer((_) async => Right<Failure, void>(null));
    when(() => mockSearchCurrencies(any()))
        .thenAnswer((_) async => Right<Failure, List<Currency>>(tCurrencies));
  }
  
  setUp(commonSetUp);

  group('LoadCurrencies', () {
    test(
      'should update state with currencies and most used currencies when LoadCurrencies is added',
      () async {
        // arrange
        final testBloc = createTestBloc();
        
        // Verify initial state
        expect(testBloc.state, isA<CurrencyInitial>());

        // act - load currencies
        testBloc.add(const LoadCurrencies());

        // assert
        await expectLater(
          testBloc.stream,
          emitsInOrder([
            isA<CurrencyLoading>(),
            isA<CurrenciesLoaded>().having(
              (s) => s.currencies,
              'currencies',
              tCurrencies,
            ),
          ]),
        );

        // Verify the final state
        final loadedState = testBloc.state as CurrenciesLoaded;
        expect(loadedState.currencies, tCurrencies);
        expect(loadedState.mostUsedCurrencies, tCurrencies.where((c) => c.isMostUsed).toList());
        
        // Verify the mock was called
        verify(() => mockGetAllCurrencies(any())).called(1);
        
        // Clean up
        await testBloc.close();
      },
      timeout: const Timeout(Duration(seconds: 10)),
    );

    test(
      'should emit [CurrencyError] when getting currencies fails',
      () async {
        // arrange
        final testBloc = createTestBloc();
        
        // Set up the mock to fail
        when(() => mockGetAllCurrencies(any()))
            .thenAnswer((_) async => Left<Failure, List<Currency>>(CacheFailure('Failed to load')));

        // act - load currencies (should fail)
        testBloc.add(const LoadCurrencies());

        // assert
        await expectLater(
          testBloc.stream,
          emitsInOrder([
            isA<CurrencyLoading>(),
            isA<CurrencyError>(),
          ]),
        );

        // Verify the mock was called
        verify(() => mockGetAllCurrencies(any())).called(1);
      },
    );
  });

  group('SearchCurrencies', () {
    const tQuery = 'US';
    final tSearchResults = [tCurrencies.first];
    
    late CurrencyBloc testBloc;

    setUp(() {
      testBloc = createTestBloc();
      // Ensure initial state is set up with loaded currencies
      when(() => mockGetAllCurrencies(any()))
          .thenAnswer((_) async => Right<Failure, List<Currency>>(tCurrencies));
      
      // Load initial currencies to get to a valid state
      testBloc.add(const LoadCurrencies());
    });
    
    tearDown(() async {
      await testBloc.close();
    });
    
    test('should call the search use case with the query and update state', () async {
      // arrange
      when(() => mockSearchCurrencies(any()))
          .thenAnswer((_) async => Right(tSearchResults));

      // Wait for initial state to be loaded
      await testBloc.stream.firstWhere((state) => state is CurrenciesLoaded);

      // act - search with query
      testBloc.add(const SearchCurrencies(tQuery));
      
      // Wait for the state to update
      final state = await testBloc.stream.firstWhere(
        (state) => state is SearchResultsLoaded,
        orElse: () => testBloc.state,
      );

      // assert
      expect(state, isA<SearchResultsLoaded>());
      
      if (state is SearchResultsLoaded) {
        expect(state.searchResults, tSearchResults);
        expect(state.query, tQuery);
      } else {
        fail('Expected SearchResultsLoaded but got ${state.runtimeType}');
      }
    });

    test('should update state with error when search fails', () async {
      // arrange
      const tErrorMessage = 'Search failed';
      
      when(() => mockSearchCurrencies(any()))
          .thenAnswer((_) async => Left<Failure, List<Currency>>(ServerFailure(tErrorMessage)));

      // Wait for initial state to be loaded
      await testBloc.stream.firstWhere((state) => state is CurrenciesLoaded);

      // act - search with an error
      testBloc.add(const SearchCurrencies('error'));
      
      // Wait for the state to update
      final state = await testBloc.stream.firstWhere(
        (state) => state is CurrencyError,
        orElse: () => testBloc.state,
      );

      // assert
      expect(state, isA<CurrencyError>());
    });
  });

  group('SelectCurrency', () {
    late CurrencyBloc testBloc;
    late List<Currency> updatedCurrencies;

    setUp(() {
      testBloc = createTestBloc();
      
      // Create a copy of currencies with USD selected
      updatedCurrencies = tCurrencies.map((c) => c.code == 'USD' 
        ? c.copyWith(isSelected: true) 
        : c.copyWith(isSelected: false)).toList();
      
      // Setup mock responses
      when(() => mockGetAllCurrencies(any()))
          .thenAnswer((_) async => Right<Failure, List<Currency>>(tCurrencies));
          
      when(() => mockSetSelectedCurrency(any()))
          .thenAnswer((invocation) async {
            final currency = invocation.positionalArguments[0] as Currency;
            return Right(currency);
          });
    });
    
    tearDown(() async {
      await testBloc.close();
    });

    test('should update selected currency when a valid currency is selected', () async {
      print('Test started');
      
      // Print initial state
      print('Initial state: ${testBloc.state}');
      
      // First, ensure we have a valid CurrenciesLoaded state
      testBloc.add(const LoadCurrencies());
      print('Added LoadCurrencies event');
      
      // Print all state changes for debugging
      final subscription = testBloc.stream.listen((state) {
        print('State changed to: $state');
      });
      
      // Wait for the initial state to be loaded
      print('Waiting for CurrenciesLoaded state...');
      final initialState = await testBloc.stream.firstWhere(
        (state) {
          final match = state is CurrenciesLoaded;
          if (match) print('Found CurrenciesLoaded state: $state');
          return match;
        },
        orElse: () {
          print('No CurrenciesLoaded state found, current state: ${testBloc.state}');
          return testBloc.state;
        },
      );
      
      // Verify we have a valid initial state
      print('Verifying initial state...');
      expect(initialState, isA<CurrenciesLoaded>());
      if (initialState is! CurrenciesLoaded) {
        print('Test failed: Initial state is not CurrenciesLoaded');
        return;
      }
      
      print('Initial state verified: ${initialState.runtimeType}');
      
      // Find a currency to select (different from the currently selected one)
      final newCurrency = initialState.currencies.firstWhere(
        (c) => c.code != initialState.selectedCurrency.code,
        orElse: () {
          print('No different currency found, using first one');
          return initialState.currencies.first;
        },
      );
      
      print('Selected new currency: ${newCurrency.code} (current: ${initialState.selectedCurrency.code})');
      
      // Set up the mock to return the updated currencies list
      when(() => mockGetAllCurrencies(any()))
          .thenAnswer((_) async {
            print('getAllCurrencies called, returning updated currencies');
            return Right(updatedCurrencies);
          });
      
      // Set up the mock for setSelectedCurrency to handle SetSelectedCurrencyParams
      when(() => mockSetSelectedCurrency(any()))
          .thenAnswer((invocation) async {
            final params = invocation.positionalArguments[0] as SetSelectedCurrencyParams;
            final currency = params.currency;
            print('setSelectedCurrency called with: ${currency.code}');
            return Right(null); // Return Right with void
          });
      
      // Act - select a different currency
      print('Dispatching SelectCurrency event for ${newCurrency.code}');
      testBloc.add(SelectCurrency(newCurrency.code));
      
      // Wait for the state to update
      print('Waiting for state update with selected currency: ${newCurrency.code}');
      final state = await testBloc.stream.firstWhere(
        (state) {
          final match = state is CurrenciesLoaded && state.selectedCurrency.code == newCurrency.code;
          if (match) print('Found matching state with selected currency: ${newCurrency.code}');
          return match;
        },
        orElse: () {
          print('No matching state found, current state: ${testBloc.state}');
          return testBloc.state;
        },
      );

      // Print final state for debugging
      print('Final state: $state');
      
      // Assert - check final state
      print('Verifying final state...');
      expect(state, isA<CurrenciesLoaded>());
      
      if (state is CurrenciesLoaded) {
        print('Verifying selected currency is ${newCurrency.code}...');
        expect(state.selectedCurrency.code, newCurrency.code);
      } else {
        print('Test failed: Expected CurrenciesLoaded but got ${state.runtimeType}');
        fail('Expected CurrenciesLoaded but got ${state.runtimeType}');
      }
      
      // Verify the setSelectedCurrency use case was called
      print('Verifying setSelectedCurrency was called...');
      verify(() => mockSetSelectedCurrency(any())).called(1);
      print('Test completed successfully');
      
      // Clean up
      await subscription.cancel();
    }, timeout: const Timeout(Duration(seconds: 10)));
  });
}
