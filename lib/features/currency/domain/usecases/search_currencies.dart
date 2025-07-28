import 'package:dartz/dartz.dart';
import 'package:expense_app/core/error/failures.dart';
import 'package:expense_app/features/currency/domain/entities/currency.dart';
import 'package:expense_app/features/currency/domain/repositories/currency_repository.dart';

class SearchCurrenciesUseCase {
  final CurrencyRepository repository;

  SearchCurrenciesUseCase(this.repository);

  Future<Either<Failure, List<Currency>>> call(String query) async {
    try {
      final results = await repository.searchCurrencies(query);
      return Right(results);
    } catch (e) {
      return const Left(CacheFailure('Failed to search currencies'));
    }
  }
}
