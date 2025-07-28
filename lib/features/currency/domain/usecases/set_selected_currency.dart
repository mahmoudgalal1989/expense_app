import 'package:dartz/dartz.dart';
import 'package:expense_app/core/error/failures.dart';
import 'package:expense_app/core/usecases/command.dart';
import 'package:expense_app/features/currency/domain/entities/currency.dart';
import 'package:expense_app/features/currency/domain/repositories/currency_repository.dart';

/// Parameters for the [SetSelectedCurrency] command.
class SetSelectedCurrencyParams {
  final Currency currency;

  const SetSelectedCurrencyParams(this.currency);
}

/// Command to set the currently selected currency.
class SetSelectedCurrency implements Command<void, SetSelectedCurrencyParams> {
  final CurrencyRepository repository;

  const SetSelectedCurrency(this.repository);

  @override
  Future<Either<Failure, void>> call(SetSelectedCurrencyParams params) async {
    try {
      await repository.setSelectedCurrency(params.currency);
      return const Right(null);
    } catch (e) {
      return const Left(CacheFailure('Failed to set selected currency'));
    }
  }
}
