import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:dartz/dartz.dart';
import 'package:expense_app/core/error/failures.dart';
import 'package:expense_app/features/currency/domain/entities/currency.dart';
import 'package:expense_app/features/currency/domain/usecases/get_all_currencies.dart';
import 'package:expense_app/features/currency/domain/usecases/set_selected_currency.dart';
import 'package:expense_app/features/currency/domain/usecases/search_currencies.dart';
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

class MockGetAllCurrencies extends Mock implements GetAllCurrencies {}
class MockSetSelectedCurrency extends Mock implements SetSelectedCurrency {}
class MockSearchCurrenciesUseCase extends Mock implements SearchCurrenciesUseCase {}

void main() {
  late CurrencyBloc bloc;
  late MockGetAllCurrencies mockGetAllCurrencies;
  late MockSetSelectedCurrency mockSetSelectedCurrency;
  late MockSearchCurrenciesUseCase mockSearchCurrenciesUseCase;

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
  Future<void> loadInitialCurrencies() async {
    // Reset the mock to ensure clean state
    reset(mockGetAllCurrencies);
    
    // Set up the mock to return test currencies
    when(() => mockGetAllCurrencies())
        .thenAnswer((_) async => Right(tCurrencies));
    
    // Add the event to load currencies
    bloc.add(const LoadCurrencies());
    
    // Wait for the currencies to be loaded with a timeout
    final completer = Completer<void>();
    final subscription = bloc.stream.listen((state) {
      if (state is CurrenciesLoaded) {
        if (!completer.isCompleted) {
          completer.complete();
        }
      } else if (state is CurrencyError) {
        if (!completer.isCompleted) {
          completer.completeError(
            Exception('Failed to load currencies: ${state.message}'),
          );
        }
      }
    });

    try {
      await completer.future.timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          throw TimeoutException('Timed out waiting for CurrenciesLoaded');
        },
      );
    } finally {
      await subscription.cancel();
    }
  }

  setUp(() {
    mockGetAllCurrencies = MockGetAllCurrencies();
    mockSetSelectedCurrency = MockSetSelectedCurrency();
    mockSearchCurrenciesUseCase = MockSearchCurrenciesUseCase();
    
    // Setup default mock responses
    when(() => mockGetAllCurrencies())
        .thenAnswer((_) async => Right(tCurrencies));
    when(() => mockSetSelectedCurrency(any()))
        .thenAnswer((_) async => const Right(null));
    when(() => mockSearchCurrenciesUseCase(any()))
        .thenAnswer((_) async => Right(tCurrencies));
    
    bloc = CurrencyBloc(
      getAllCurrencies: mockGetAllCurrencies,
      setSelectedCurrency: mockSetSelectedCurrency,
      searchCurrenciesUseCase: mockSearchCurrenciesUseCase,
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
        when(() => mockGetAllCurrencies())
            .thenAnswer((_) async => Right(tCurrencies));

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
          isA<CurrencyInitial>(),
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
        reset(mockGetAllCurrencies);
        when(() => mockGetAllCurrencies())
            .thenAnswer((_) async => Left(CacheFailure('Failed to load currencies')));
        
        // Wait for the initial state
        await waitForInitialState();

        // Collect states for verification
        final states = <CurrencyState>[];
        final subscription = bloc.stream.listen(states.add);

        // act - try to load currencies (should fail)
        await loadInitialCurrencies();

        // Wait for the error state
        await bloc.stream.firstWhere(
          (state) => state is CurrencyError,
          orElse: () => throw Exception('Expected CurrencyError state'),
        );

        // Cancel the subscription
        await subscription.cancel();

        // Verify the states
        expect(states, [
          isA<CurrencyInitial>(),
          isA<CurrencyLoading>(),
          isA<CurrencyError>(),
        ]);

        // Verify the error message
        final errorState = states.last as CurrencyError;
        expect(errorState.message, contains('Failed to load currencies'));
        
        // Verify mocks
        verify(() => mockGetAllCurrencies()).called(1);
        verifyNoMoreInteractions(mockGetAllCurrencies);
      },
      timeout: const Timeout(Duration(seconds: 10)),
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
        reset(mockSearchCurrenciesUseCase);
        when(() => mockSearchCurrenciesUseCase(any()))
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
        expect(resultsState.query, tQuery);
        expect(resultsState.selectedCurrency.code, tSearchResults.first.code);

        // Verify the search was called with the correct query
        verify(() => mockSearchCurrenciesUseCase(tQuery)).called(1);
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
        reset(mockSearchCurrenciesUseCase);
        when(() => mockSearchCurrenciesUseCase(any()))
            .thenAnswer((_) async => Left(CacheFailure(tErrorMessage)));

        // Collect states for verification
        final states = <CurrencyState>[];
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
      'should return to currencies list when search query is empty',
      () async {
        // First, set up the initial state with currencies loaded
        await loadInitialCurrencies();
        
        // Now set up the search mock
        reset(mockSearchCurrenciesUseCase);
        when(() => mockSearchCurrenciesUseCase(any()))
            .thenAnswer((_) async => Right(tCurrencies));

        // Collect states for verification
        final states = <CurrencyState>[];
        final subscription = bloc.stream.listen(states.add);

        // act - search with empty query
        bloc.add(SearchCurrencies(''));

        // Wait for the currencies loaded state
        await bloc.stream.firstWhere(
          (state) => state is CurrenciesLoaded,
          orElse: () => throw Exception('Expected CurrenciesLoaded state'),
        );

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
          loadedState.selectedCurrency.code,
          tCurrencies.firstWhere((c) => c.isSelected).code,
        );
      },
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
        
        when(() => mockGetAllCurrencies())
            .thenAnswer((_) async => Right(tCurrencies));
            
        when(() => mockSetSelectedCurrency(any()))
            .thenAnswer((invocation) async {
              final currency = invocation.positionalArguments[0] as Currency;
              return Right(currency);
            });
            
        when(() => mockGetAllCurrencies())
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
            
        when(() => mockGetAllCurrencies())
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
        verify(() => mockGetAllCurrencies()).called(1);
      },
    );
  });
}
