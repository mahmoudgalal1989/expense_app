import 'package:dartz/dartz.dart';
import 'package:expense_app/core/error/failures.dart';
import 'package:expense_app/features/currency/domain/entities/currency.dart';
import 'package:expense_app/features/currency/domain/usecases/get_all_currencies.dart';
import 'package:expense_app/features/currency/domain/usecases/set_selected_currency.dart';
import 'package:expense_app/features/currency/domain/usecases/search_currencies.dart';
import 'package:expense_app/features/currency/presentation/bloc/currency_bloc/currency_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

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
      isSelected: false,
    ),
    const Currency(
      code: 'EUR',
      countryName: 'European Union',
      flagIconPath: 'assets/flags/eu.png',
      isMostUsed: true,
      isSelected: false,
    ),
  ];

  setUp(() {
    mockGetAllCurrencies = MockGetAllCurrencies();
    mockSetSelectedCurrency = MockSetSelectedCurrency();
    mockSearchCurrenciesUseCase = MockSearchCurrenciesUseCase();
    
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
        // arrange - mock the response from the use case
        when(() => mockGetAllCurrencies())
            .thenAnswer((_) async => Right(tCurrencies));
            
        // act & assert - expect the following states in order
        final expected = [
          // Loading state
          isA<CurrencyLoading>(),
          // First update with currencies (empty mostUsedCurrencies)
          isA<CurrenciesLoaded>().having(
            (s) => s.currencies,
            'currencies',
            tCurrencies,
          ).having(
            (s) => s.mostUsedCurrencies,
            'mostUsedCurrencies',
            [],
          ),
          // Second update with most used currencies
          isA<CurrenciesLoaded>().having(
            (s) => s.currencies,
            'currencies',
            tCurrencies,
          ).having(
            (s) => s.mostUsedCurrencies,
            'mostUsedCurrencies',
            tCurrencies.where((c) => c.isMostUsed).toList(),
          ),
        ];
        
        expectLater(
          bloc.stream,
          emitsInOrder(expected),
        );
        
        // act - load currencies which will also load most used
        bloc.add(const LoadCurrencies());
      },
    );

    test(
      'should emit [CurrencyError] when getting currencies fails',
      () async {
        // arrange
        when(() => mockGetAllCurrencies())
            .thenAnswer((_) async => Left(CacheFailure('Failed to load currencies')));
        
        // Act
        bloc.add(const LoadCurrencies());
        
        // Wait for the error state
        final state = await bloc.stream
            .where((state) => state is CurrencyError)
            .first;
        
        // Assert
        expect(state, isA<CurrencyError>());
        
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
      const Currency(
        code: 'USD',
        countryName: 'United States',
        flagIconPath: 'assets/flags/us.png',
        isMostUsed: true,
        isSelected: false,
      ),
    ];

    test(
      'should call the search use case with the query and emit SearchResultsLoaded when successful',
      () async {
        // arrange
        when(() => mockSearchCurrenciesUseCase(tQuery))
            .thenAnswer((_) async => Right(tSearchResults));
        
        // act
        bloc.add(const SearchCurrencies(tQuery));
        await untilCalled(() => mockSearchCurrenciesUseCase(tQuery));
        
        // assert
        verify(() => mockSearchCurrenciesUseCase(tQuery));
        expect(
          bloc.state,
          isA<SearchResultsLoaded>()
              .having((s) => s.searchResults, 'search results', tSearchResults)
              .having((s) => s.query, 'query', tQuery)
              .having((s) => s.selectedCurrency, 'selected currency', tSearchResults.first),
        );
      },
    );

    test(
      'should emit CurrencyError when search fails',
      () async {
        // arrange
        const tErrorMessage = 'Search failed';
        when(() => mockSearchCurrenciesUseCase(tQuery))
            .thenAnswer((_) async => const Left(CacheFailure(tErrorMessage)));
        
        // act
        bloc.add(const SearchCurrencies(tQuery));
        await untilCalled(() => mockSearchCurrenciesUseCase(tQuery));
        
        // assert
        verify(() => mockSearchCurrenciesUseCase(tQuery));
        expect(
          bloc.state,
          isA<CurrencyError>().having((e) => e.message, 'message', tErrorMessage),
        );
      },
    );

    test(
      'should return to currencies list when search query is empty',
      () async {
        // arrange
        when(() => mockSearchCurrenciesUseCase(''))
            .thenAnswer((_) async => Right(tCurrencies));
        
        // Load currencies first to set _allCurrencies
        when(() => mockGetAllCurrencies())
            .thenAnswer((_) async => Right(tCurrencies));
        bloc.add(const LoadCurrencies());
        await untilCalled(() => mockGetAllCurrencies());
        
        // act
        bloc.add(const SearchCurrencies(''));
        
        // assert
        expect(
          bloc.state,
          isA<CurrenciesLoaded>()
              .having((s) => s.currencies, 'currencies', tCurrencies)
              .having(
                (s) => s.mostUsedCurrencies, 
                'most used currencies',
                tCurrencies.where((c) => c.isMostUsed).toList(),
              ),
        );
      },
    );
  });
}
