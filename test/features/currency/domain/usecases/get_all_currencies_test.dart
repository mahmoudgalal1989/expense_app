import 'package:dartz/dartz.dart';
import 'package:expense_app/core/error/failures.dart';
import 'package:expense_app/core/usecases/command.dart';
import 'package:expense_app/features/currency/domain/entities/currency.dart';
import 'package:expense_app/features/currency/domain/repositories/currency_repository.dart';
import 'package:expense_app/features/currency/domain/usecases/get_all_currencies.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

@GenerateMocks([CurrencyRepository])
import 'get_all_currencies_test.mocks.dart';

void main() {
  late GetAllCurrencies useCase;
  late MockCurrencyRepository mockCurrencyRepository;
  final tCurrencies = [
    const Currency(
      code: 'USD',
      countryName: 'United States',
      flagIconPath: 'assets/flags/us.png',
      isSelected: true,
      isMostUsed: true,
    ),
    const Currency(
      code: 'EUR',
      countryName: 'European Union',
      flagIconPath: 'assets/flags/eu.png',
      isSelected: false,
      isMostUsed: true,
    ),
  ];

  setUp(() {
    mockCurrencyRepository = MockCurrencyRepository();
    useCase = GetAllCurrencies(mockCurrencyRepository);
  });

  test('should get all currencies from the repository', () async {
    // arrange
    when(mockCurrencyRepository.getAllCurrencies())
        .thenAnswer((_) async => tCurrencies);

    // act
    final result = await useCase(const NoParams());

    // assert
    expect(result, Right(tCurrencies));
    verify(mockCurrencyRepository.getAllCurrencies());
    verifyNoMoreInteractions(mockCurrencyRepository);
  });

  test('should return a failure when getting all currencies fails', () async {
    // arrange
    final tFailure = CacheFailure('Failed to load currencies');
    when(mockCurrencyRepository.getAllCurrencies())
        .thenThrow(tFailure);

    // act
    final result = await useCase(const NoParams());

    // assert
    expect(result, Left(tFailure));
    verify(mockCurrencyRepository.getAllCurrencies());
    verifyNoMoreInteractions(mockCurrencyRepository);
  });

  test('should implement the Command interface', () {
    // assert
    expect(useCase, isA<Command<List<Currency>, NoParams>>());
  });
}
