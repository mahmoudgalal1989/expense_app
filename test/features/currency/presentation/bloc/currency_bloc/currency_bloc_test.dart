import 'dart:async';

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

void main() {
  // Test data
  final tCurrencies = [
    const Currency(
      code: 'USD',
      countryName: 'United States',
      flagIconPath: 'assets/flags/us.png',
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
    
    // Register fallback values
    registerFallbackValue(MockNoParams());
    
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
            isA<CurrenciesLoaded>(),
          ]),
        );

        // Verify the final state
        final loadedState = testBloc.state as CurrenciesLoaded;
        expect(loadedState.currencies, tCurrencies);
        expect(loadedState.mostUsedCurrencies, tCurrencies.where((c) => c.isMostUsed).toList());
        expect(loadedState.selectedCurrency, tCurrencies.firstWhere((c) => c.isSelected));
        
        // Verify the mock was called
        verify(() => mockGetAllCurrencies(any())).called(1);
      },
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
    });
    
    tearDown(() async {
      await testBloc.close();
    });
    
    test(
      'should call the search use case with the query and emit SearchResultsLoaded when successful',
      () async {
        // arrange
        when(() => mockSearchCurrencies(any()))
            .thenAnswer((_) async => Right(tSearchResults));

        // act - search with query
        testBloc.add(const SearchCurrencies(tQuery));

        // assert
        await expectLater(
          testBloc.stream,
          emitsInOrder([
            isA<CurrencyLoading>(),
            isA<SearchResultsLoaded>(),
          ]),
        );
        
        final resultsState = testBloc.state as SearchResultsLoaded;
        expect(resultsState.searchResults, tSearchResults);
        expect(resultsState.query, tQuery);
      },
    );

    test(
      'should emit CurrencyError when search fails',
      () async {
        // arrange
        const tErrorMessage = 'Search failed';
        
        // Set up the mock to throw an error during search
        when(() => mockSearchCurrencies(any()))
            .thenAnswer((_) async => Left<Failure, List<Currency>>(ServerFailure(tErrorMessage)));

        // act - search with an error
        testBloc.add(const SearchCurrencies('error'));

        // assert
        await expectLater(
          testBloc.stream,
          emitsInOrder([
            isA<CurrencyLoading>(),
            isA<CurrencyError>(),
          ]),
        );
        verify(() => mockSetSelectedCurrency(any())).called(1);
        verify(() => mockGetAllCurrencies(any())).called(1);
      },
      timeout: const Timeout(Duration(seconds: 5)),
    );
  });

  group('SelectCurrency', () {
    test(
      'should update selected currency and emit updated state',
      () async {
        // arrange
        final updatedCurrencies = tCurrencies.map((c) => c.code == 'EUR' 
          ? c.copyWith(isSelected: true) 
          : c.copyWith(isSelected: false)).toList();
        
        when(() => mockGetAllCurrencies(any()))
            .thenAnswer((_) async => Right<Failure, List<Currency>>(tCurrencies));
            
        when(() => mockSetSelectedCurrency(any()))
            .thenAnswer((invocation) async {
              final currency = invocation.positionalArguments[0] as Currency;
              return Right(currency);
            });
            
        when(() => mockGetAllCurrencies(any()))
            .thenAnswer((_) async => Right(updatedCurrencies));
        
        // Load initial currencies
        bloc.add(const LoadCurrencies());
        await untilCalled(() => mockGetAllCurrencies(any()));
        
        // Reset mocks
        reset(mockSetSelectedCurrency);
        reset(mockGetAllCurrencies);
        
        when(() => mockSetSelectedCurrency(any()))
            .thenAnswer((invocation) async {
              final currency = invocation.positionalArguments[0] as Currency;
              return Right(currency);
            });
            
        when(() => mockGetAllCurrencies(any()))
            .thenAnswer((_) async => Right(updatedCurrencies));
        
        // act
        bloc.add(const SelectCurrency('EUR'));
        
        // assert
        await expectLater(
          bloc.stream,
          emitsInOrder([
            // Initial state from previous load
            isA<CurrenciesLoaded>(),
            // Loading state
            isA<CurrencyLoading>(),
            // Updated state with new selection
            isA<CurrenciesLoaded>()
              .having(
                (s) => s.selectedCurrency.code,
                'selected currency code',
                'EUR',
              ),
          ]),
        );
        
        // Verify mocks
        verify(() => mockSetSelectedCurrency(any())).called(1);
        verify(() => mockGetAllCurrencies(any())).called(1);
      },
    );
  });
}
