import 'package:dartz/dartz.dart';
import 'package:expense_app/core/error/failures.dart';
import 'package:expense_app/core/usecases/command.dart';
import 'package:expense_app/features/currency/domain/entities/currency.dart';
import 'package:expense_app/features/currency/domain/repositories/currency_repository.dart';
import 'package:expense_app/features/currency/domain/usecases/set_selected_currency.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

@GenerateMocks([CurrencyRepository])
import 'set_selected_currency_test.mocks.dart';

void main() {
  late SetSelectedCurrency useCase;
  late MockCurrencyRepository mockCurrencyRepository;
  const tCurrency = Currency(
    code: 'USD',
    countryName: 'United States',
    flagIconPath: 'assets/flags/us.png',
    isSelected: true,
    isMostUsed: true,
  );

  setUp(() {
    mockCurrencyRepository = MockCurrencyRepository();
    useCase = SetSelectedCurrency(mockCurrencyRepository);
  });

  test('should set the selected currency in the repository', () async {
    // arrange
    when(mockCurrencyRepository.setSelectedCurrency(tCurrency))
        .thenAnswer((_) async => Future.value());

    // act
    final result = await useCase(const SetSelectedCurrencyParams(tCurrency));

    // assert
    expect(result, const Right(null));
    verify(mockCurrencyRepository.setSelectedCurrency(tCurrency));
    verifyNoMoreInteractions(mockCurrencyRepository);
  });

  test('should return a failure when setting the selected currency fails', () async {
    // arrange
    const tFailure = CacheFailure('Failed to set selected currency');
    when(mockCurrencyRepository.setSelectedCurrency(tCurrency))
        .thenThrow(tFailure);

    // act
    final result = await useCase(const SetSelectedCurrencyParams(tCurrency));

    // assert
    expect(result, const Left(tFailure));
    verify(mockCurrencyRepository.setSelectedCurrency(tCurrency));
    verifyNoMoreInteractions(mockCurrencyRepository);
  });

  test('should implement the Command interface', () {
    // assert
    expect(useCase, isA<Command<void, SetSelectedCurrencyParams>>());
  });

  test('should create SetSelectedCurrencyParams with currency', () {
    // arrange
    const currency = Currency(
      code: 'EUR',
      countryName: 'European Union',
      flagIconPath: 'assets/flags/eu.png',
      isSelected: false,
      isMostUsed: true,
    );
    
    // act
    const params = SetSelectedCurrencyParams(currency);
    
    // assert
    expect(params.currency, currency);
  });
}
