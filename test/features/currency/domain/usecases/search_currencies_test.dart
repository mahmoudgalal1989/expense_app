import 'package:dartz/dartz.dart';
import 'package:expense_app/core/error/failures.dart';
import 'package:expense_app/core/usecases/command.dart';
import 'package:expense_app/features/currency/domain/entities/currency.dart';
import 'package:expense_app/features/currency/domain/repositories/currency_repository.dart';
import 'package:expense_app/features/currency/domain/usecases/search_currencies.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

@GenerateMocks([CurrencyRepository])
import 'search_currencies_test.mocks.dart';

void main() {
  late SearchCurrencies useCase;
  late MockCurrencyRepository mockCurrencyRepository;
  final tQuery = 'USD';
  final tSearchResults = [
    const Currency(
      code: 'USD',
      countryName: 'United States',
      flagIconPath: 'assets/flags/us.png',
      isSelected: true,
      isMostUsed: true,
    ),
  ];

  setUp(() {
    mockCurrencyRepository = MockCurrencyRepository();
    useCase = SearchCurrencies(mockCurrencyRepository);
  });

  test('should search for currencies matching the query', () async {
    // arrange
    when(mockCurrencyRepository.searchCurrencies(tQuery))
        .thenAnswer((_) async => tSearchResults);

    // act
    final result = await useCase(SearchCurrenciesParams(tQuery));

    // assert
    expect(result, Right(tSearchResults));
    verify(mockCurrencyRepository.searchCurrencies(tQuery));
    verifyNoMoreInteractions(mockCurrencyRepository);
  });

  test('should return a failure when searching currencies fails', () async {
    // arrange
    const tFailure = CacheFailure('Failed to search currencies');
    when(mockCurrencyRepository.searchCurrencies(tQuery))
        .thenThrow(tFailure);

    // act
    final result = await useCase(SearchCurrenciesParams(tQuery));

    // assert
    expect(result, const Left(tFailure));
    verify(mockCurrencyRepository.searchCurrencies(tQuery));
    verifyNoMoreInteractions(mockCurrencyRepository);
  });

  test('should implement the Command interface', () {
    // assert
    expect(useCase, isA<Command<List<Currency>, SearchCurrenciesParams>>());
  });

  test('should create SearchCurrenciesParams with query', () {
    // arrange
    const query = 'test';
    
    // act
    final params = SearchCurrenciesParams(query);
    
    // assert
    expect(params.query, query);
  });
}
