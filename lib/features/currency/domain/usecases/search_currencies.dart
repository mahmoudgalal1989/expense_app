import 'package:dartz/dartz.dart';
import 'package:expense_app/core/error/failures.dart';
import 'package:expense_app/core/usecases/command.dart';
import 'package:expense_app/features/currency/domain/entities/currency.dart';
import 'package:expense_app/features/currency/domain/repositories/currency_repository.dart';

/// Parameters for the [SearchCurrencies] command.
class SearchCurrenciesParams {
  final String query;

  const SearchCurrenciesParams(this.query);
}

/// Command to search for currencies based on a query.
class SearchCurrencies
    implements Command<List<Currency>, SearchCurrenciesParams> {
  final CurrencyRepository repository;

  const SearchCurrencies(this.repository);

  @override
  Future<Either<Failure, List<Currency>>> call(
      SearchCurrenciesParams params) async {
    try {
      final results = await repository.searchCurrencies(params.query);
      return Right(results);
    } catch (e) {
      return const Left(CacheFailure('Failed to search currencies'));
    }
  }
}
