import 'package:dartz/dartz.dart';
import 'package:expense_app/core/error/failures.dart';
import 'package:expense_app/features/currency/domain/entities/currency.dart';
import 'package:expense_app/features/currency/domain/repositories/currency_repository.dart';
import 'package:expense_app/features/currency/domain/usecases/get_most_used_currencies.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockCurrencyRepository extends Mock implements CurrencyRepository {}

void main() {
  late GetMostUsedCurrencies usecase;
  late MockCurrencyRepository mockCurrencyRepository;

  setUp(() {
    mockCurrencyRepository = MockCurrencyRepository();
    usecase = GetMostUsedCurrencies(mockCurrencyRepository);
  });

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

  test(
    'should get most used currencies from the repository',
    () async {
      // arrange
      when(() => mockCurrencyRepository.getMostUsedCurrencies())
          .thenAnswer((_) async => tCurrencies);
      
      // act
      final result = await usecase();
      
      // assert
      expect(result, Right(tCurrencies));
      verify(() => mockCurrencyRepository.getMostUsedCurrencies()).called(1);
      verifyNoMoreInteractions(mockCurrencyRepository);
    },
  );

  test(
    'should return a failure when getting most used currencies fails',
    () async {
      // arrange
      when(() => mockCurrencyRepository.getMostUsedCurrencies())
          .thenThrow(Exception('Failed to load most used currencies'));
      
      // act
      final result = await usecase();
      
      // assert
      expect(
        result,
        isA<Left<Failure, List<Currency>>>().having(
          (l) => l.value,
          'failure',
          isA<CacheFailure>(),
        ),
      );
      verify(() => mockCurrencyRepository.getMostUsedCurrencies()).called(1);
      verifyNoMoreInteractions(mockCurrencyRepository);
    },
  );
}
