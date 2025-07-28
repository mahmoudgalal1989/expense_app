import 'dart:async';

import 'package:dartz/dartz.dart';
import 'package:expense_app/core/error/failures.dart';
import 'package:expense_app/core/usecases/command.dart';
import 'package:expense_app/features/currency/domain/entities/currency.dart';
import 'package:expense_app/features/currency/domain/usecases/get_all_currencies.dart';
import 'package:expense_app/features/currency/domain/usecases/set_selected_currency.dart';
import 'package:expense_app/features/currency/domain/usecases/search_currencies.dart' as search_usecase;
import 'package:expense_app/features/currency/presentation/bloc/currency_bloc/currency_bloc.dart';
import 'package:expense_app/features/currency/presentation/bloc/currency_bloc/currency_event.dart';
import 'package:expense_app/features/currency/presentation/bloc/currency_bloc/currency_state.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockCurrency extends Mock implements Currency {
  MockCurrency({
    required String code,
    required String countryName,
    required String flagIconPath,
    required bool isMostUsed,
    required bool isSelected,
  });
}

// Mock classes for Command pattern use cases
class MockGetAllCurrencies extends Mock implements Command<List<Currency>, NoParams> {
  @override
  Future<Either<Failure, List<Currency>>> call(NoParams params) async {
    return Right<Failure, List<Currency>>(<Currency>[]);
  }
}

class MockSetSelectedCurrency extends Mock implements Command<void, SetSelectedCurrencyParams> {
  @override
  Future<Either<Failure, void>> call(SetSelectedCurrencyParams params) async {
    return const Right<Failure, void>(null);
  }
}

class MockSearchCurrencies extends Mock implements Command<List<Currency>, search_usecase.SearchCurrenciesParams> {
  @override
  Future<Either<Failure, List<Currency>>> call(search_usecase.SearchCurrenciesParams params) async {
    return Right<Failure, List<Currency>>(<Currency>[]);
  }
}

void main() {
  late CurrencyBloc bloc;
  late MockGetAllCurrencies mockGetAllCurrencies;
  late MockSetSelectedCurrency mockSetSelectedCurrency;
  late MockSearchCurrencies mockSearchCurrencies;

  final tCurrencies = [
    const Currency(
      code: 'USD',
      countryName: 'United States',
      flagIconPath: 'assets/flags/us.png',
      isMostUsed: true,
      isSelected: true,
    ),
    const Currency(
      code: 'EUR',
      countryName: 'European Union',
      flagIconPath: 'assets/flags/eu.png',
      isMostUsed: true,
      isSelected: false,
    ),
  ];

  setUpAll(() {
    // Register fallback values for mocktail
    registerFallbackValue(
      MockCurrency(
        code: 'USD',
        countryName: 'United States',
        flagIconPath: 'assets/flags/us.png',
        isMostUsed: true,
        isSelected: true,
      ),
    );
  });

  // Helper method to wait for the initial state
  Future<void> waitForInitialState() async {
    // The bloc starts with CurrencyInitial state
    expect(bloc.state, isA<CurrencyInitial>());
  }

  // Helper method to load initial currencies
  Future<void> loadInitialCurrencies({bool shouldFail = false}) async {
    // Reset the mock to ensure clean state
    reset(mockGetAllCurrencies);
    
    // Set up the mock to return test currencies or failure based on the flag
    if (shouldFail) {
      when(() => mockGetAllCurrencies(any()))
          .thenAnswer((_) async => Left<Failure, List<Currency>>(CacheFailure('Failed to load currencies')));
    } else {
      when(() => mockGetAllCurrencies(any()))
          .thenAnswer((_) async => Right<Failure, List<Currency>>(tCurrencies));
    }
    
    // Add the event to load currencies
    bloc.add(const LoadCurrencies());
    
    // Wait for either CurrenciesLoaded or CurrencyError state
    await bloc.stream.firstWhere(
      (state) => state is CurrenciesLoaded || state is CurrencyError,
      orElse: () => throw Exception('Expected CurrenciesLoaded or CurrencyError state'),
    );
  }

  setUp(() {
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
    
    bloc = CurrencyBloc(
      getAllCurrencies: mockGetAllCurrencies,
      setSelectedCurrency: mockSetSelectedCurrency,
      searchCurrencies: mockSearchCurrencies,
    );
  });

  tearDown(() {
    bloc.close();
  });

  group('LoadCurrencies', () {
    test(
      'should update state with currencies and most used currencies when LoadCurrencies is added',
      () async {
        // arrange
        when(() => mockGetAllCurrencies(any()))
            .thenAnswer((_) async => Right<Failure, List<Currency>>(tCurrencies));

        // Wait for the initial state
        await waitForInitialState();

        // Collect states for verification
        final states = <CurrencyState>[];
        final subscription = bloc.stream.listen(states.add);

        // act - use the helper method to load currencies
        await loadInitialCurrencies();

        // Cancel the subscription
        await subscription.cancel();

        // Verify the states
        expect(states, [
          isA<CurrencyLoading>(),
          isA<CurrenciesLoaded>(),
        ]);

        // Verify the final state
        final loadedState = states.last as CurrenciesLoaded;
        expect(loadedState.currencies, tCurrencies);
        expect(
          loadedState.mostUsedCurrencies,
          tCurrencies.where((c) => c.isMostUsed).toList(),
        );
        expect(
          loadedState.selectedCurrency,
          tCurrencies.firstWhere((c) => c.isSelected, orElse: () => tCurrencies.first),
        );
      },
    );

    test(
      'should emit [CurrencyError] when getting currencies fails',
      () async {
        // arrange
        // Set up the mock to fail
        when(() => mockGetAllCurrencies(any()))
            .thenAnswer((_) async => Left<Failure, List<Currency>>(CacheFailure('Failed to load currencies')));

        // Collect states for verification
        final states = <CurrencyState>[];
        final subscription = bloc.stream.listen(states.add);

        // act - load currencies (should fail)
        bloc.add(const LoadCurrencies());

        // Wait for the error state
        await expectLater(
          bloc.stream,
          emitsInOrder([
            isA<CurrencyLoading>(),
            isA<CurrencyError>().having(
              (e) => e.message,
              'error message',
              contains('Failed to load currencies'),
            ),
          ]),
        );

        // Cancel the subscription
        await subscription.cancel();

        // Verify the mock was called
        verify(() => mockGetAllCurrencies(any())).called(1);
        verifyNoMoreInteractions(mockGetAllCurrencies);
      },
      timeout: const Timeout(Duration(seconds: 5)),
    );
  });

  group('SearchCurrencies', () {
    const tQuery = 'USD';
    final tSearchResults = [
      tCurrencies.first,
    ];

    test(
      'should call the search use case with the query and emit SearchResultsLoaded when successful',
      () async {
        // arrange
        // First, set up the initial state with currencies loaded
        await loadInitialCurrencies();
        
        // Now set up the search mock
        reset(mockSearchCurrencies);
        when(() => mockSearchCurrencies(any()))
            .thenAnswer((_) async => Right(tSearchResults));

        // Collect states for verification
        final states = <CurrencyState>[];
        final subscription = bloc.stream.listen(states.add);

        // act
        bloc.add(SearchCurrencies(tQuery));

        // Wait for the search results state
        await bloc.stream.firstWhere(
          (state) => state is SearchResultsLoaded,
          orElse: () => throw Exception('Expected SearchResultsLoaded state'),
        );

        // Cancel the subscription
        await subscription.cancel();

        // Verify the states
        expect(states, [
          isA<CurrencyLoading>(),
          isA<SearchResultsLoaded>(),
        ]);

        // Verify the search results
        final resultsState = states.last as SearchResultsLoaded;
        expect(resultsState.searchResults, tSearchResults);
        expect(resultsState.query, 'US');
        expect(resultsState.selectedCurrency.code, tSearchResults.first.code);

        // Verify the search was called with the correct query
        verify(() => mockSearchCurrencies(const search_usecase.SearchCurrenciesParams('US'))).called(1);
      },
    );

    test(
      'should emit CurrencyError when search fails',
      () async {
        // arrange
        const tErrorMessage = 'Search failed';
        
        // First, set up the initial state with currencies loaded
        await loadInitialCurrencies();
        
        // Now set up the search mock to fail
        // Set up the mock to throw an error during search
        when(() => mockSearchCurrencies(any()))
            .thenAnswer((_) async => Left<Failure, List<Currency>>(ServerFailure('Search failed')));

        // act - search with an error
        bloc.add(const SearchCurrencies('error'));
        final subscription = bloc.stream.listen(states.add);

        // act
        bloc.add(SearchCurrencies(tQuery));

        // Wait for the error state
        await bloc.stream.firstWhere(
          (state) => state is CurrencyError,
          orElse: () => throw Exception('Expected CurrencyError state'),
        );

        // Cancel the subscription
        await subscription.cancel();

        // Verify the states
        expect(states, [
          isA<CurrencyLoading>(),
          isA<CurrencyError>(),
        ]);

        // Verify the error message
        final errorState = states.last as CurrencyError;
        expect(errorState.message, contains(tErrorMessage));
      },
    );

    test(
      'should return to currencies list when search query is not empty',
      () async {
        // arrange
        // Set up the mock to return an empty list for the search
        when(() => mockSearchCurrencies(any()))
            .thenAnswer((_) async => Right<Failure, List<Currency>>([]));

        // act - search for a non-existent currency
        bloc.add(const SearchCurrencies('XYZ'));
            
        // Load initial currencies
        bloc.add(const LoadCurrencies());
        
        // Wait for the initial load to complete
        await expectLater(
          bloc.stream,
          emitsInOrder([
            isA<CurrencyLoading>(),
            isA<CurrenciesLoaded>().having(
              (s) => s.currencies,
              'currencies',
              tCurrencies,
            ),
          ]),
        );
        
        // Load initial currencies first
        await loadInitialCurrencies();

        // Set up the mock to search for 'US'
        when(() => mockSearchCurrencies(any()))
            .thenAnswer((_) async => Right<Failure, List<Currency>>([tCurrencies[0]]));

        // act - search for 'US'
        bloc.add(const SearchCurrencies('US'));
        
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
        await untilCalled(() => mockGetAllCurrencies());
        
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
