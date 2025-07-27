import 'package:dartz/dartz.dart';
import 'package:expense_app/core/error/failures.dart';
import 'package:expense_app/features/currency/domain/entities/currency.dart';
import 'package:expense_app/features/currency/domain/repositories/currency_repository.dart';

class SetSelectedCurrency {
  final CurrencyRepository repository;

  SetSelectedCurrency(this.repository);

  Future<Either<Failure, void>> call(Currency currency) async {
    try {
      await repository.setSelectedCurrency(currency);
      return const Right(null);
    } catch (e) {
      return Left(CacheFailure('Failed to set selected currency'));
    }
  }
}
