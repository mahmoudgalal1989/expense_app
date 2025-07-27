import 'package:dartz/dartz.dart';
import 'package:expense_app/core/error/failures.dart';
import 'package:expense_app/features/currency/domain/entities/currency.dart';
import 'package:expense_app/features/currency/domain/usecases/get_all_currencies.dart';
import 'package:expense_app/features/currency/domain/usecases/get_most_used_currencies.dart';
import 'package:expense_app/features/currency/domain/usecases/set_selected_currency.dart';
import 'package:expense_app/features/currency/presentation/bloc/currency_bloc/currency_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockGetAllCurrencies extends Mock implements GetAllCurrencies {}
class MockGetMostUsedCurrencies extends Mock implements GetMostUsedCurrencies {}
class MockSetSelectedCurrency extends Mock implements SetSelectedCurrency {}

void main() {
  late CurrencyBloc bloc;
  late MockGetAllCurrencies mockGetAllCurrencies;
  late MockGetMostUsedCurrencies mockGetMostUsedCurrencies;
  late MockSetSelectedCurrency mockSetSelectedCurrency;

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
    mockGetMostUsedCurrencies = MockGetMostUsedCurrencies();
    mockSetSelectedCurrency = MockSetSelectedCurrency();
    
    bloc = CurrencyBloc(
      getAllCurrencies: mockGetAllCurrencies,
      getMostUsedCurrencies: mockGetMostUsedCurrencies,
      setSelectedCurrency: mockSetSelectedCurrency,
    );
  });

  tearDown(() {
    bloc.close();
  });

  group('LoadMostUsedCurrencies', () {
    test(
      'should emit [CurrenciesLoaded] with most used currencies when successful',
      () async {
        // arrange
        when(() => mockGetAllCurrencies())
            .thenAnswer((_) async => Right(tCurrencies));
        when(() => mockGetMostUsedCurrencies())
            .thenAnswer((_) async => Right(tCurrencies));
        
        // Act
        bloc.add(const LoadCurrencies());
        
        // Wait for the final state with most used currencies
        final state = await bloc.stream
            .where((state) => state is CurrenciesLoaded && (state as CurrenciesLoaded).mostUsedCurrencies.isNotEmpty)
            .first;
        
        // Assert
        expect(state, isA<CurrenciesLoaded>());
        expect((state as CurrenciesLoaded).mostUsedCurrencies, tCurrencies);
        
        // Verify mocks
        verify(() => mockGetAllCurrencies()).called(1);
        verify(() => mockGetMostUsedCurrencies()).called(1);
        verifyNoMoreInteractions(mockGetAllCurrencies);
        verifyNoMoreInteractions(mockGetMostUsedCurrencies);
      },
      timeout: const Timeout(Duration(seconds: 10)),
    );

    test(
      'should emit [CurrencyError] when getting most used currencies fails',
      () async {
        // arrange
        when(() => mockGetAllCurrencies())
            .thenAnswer((_) async => Right(tCurrencies));
        when(() => mockGetMostUsedCurrencies())
            .thenAnswer((_) async => Left(CacheFailure('Failed to load most used currencies')));
        
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
        verify(() => mockGetMostUsedCurrencies()).called(1);
        verifyNoMoreInteractions(mockGetAllCurrencies);
        verifyNoMoreInteractions(mockGetMostUsedCurrencies);
      },
      timeout: const Timeout(Duration(seconds: 10)),
    );
  });
}
