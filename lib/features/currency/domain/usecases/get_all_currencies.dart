import 'package:dartz/dartz.dart';
import 'package:expense_app/core/error/failures.dart';
import 'package:expense_app/features/currency/domain/entities/currency.dart';
import 'package:expense_app/features/currency/domain/repositories/currency_repository.dart';

class GetAllCurrencies {
  final CurrencyRepository repository;

  GetAllCurrencies(this.repository);

  Future<Either<Failure, List<Currency>>> call() async {
    try {
      final currencies = await repository.getAllCurrencies();
      return Right(currencies);
    } catch (e) {
      return const Left(CacheFailure('Failed to load currencies'));
    }
  }
}
