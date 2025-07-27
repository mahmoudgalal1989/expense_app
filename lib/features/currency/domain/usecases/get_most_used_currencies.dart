import 'package:dartz/dartz.dart';
import 'package:expense_app/core/error/failures.dart';
import 'package:expense_app/features/currency/domain/entities/currency.dart';
import 'package:expense_app/features/currency/domain/repositories/currency_repository.dart';

class GetMostUsedCurrencies {
  final CurrencyRepository repository;

  const GetMostUsedCurrencies(this.repository);

  Future<Either<Failure, List<Currency>>> call() async {
    try {
      final result = await repository.getMostUsedCurrencies();
      return Right(result);
    } on Exception catch (e) {
      return Left(CacheFailure(e.toString()));
    }
  }
}
