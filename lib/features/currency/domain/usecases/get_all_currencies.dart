import 'package:dartz/dartz.dart';
import 'package:expense_app/core/error/failures.dart';
import 'package:expense_app/core/usecases/command.dart';
import 'package:expense_app/features/currency/domain/entities/currency.dart';
import 'package:expense_app/features/currency/domain/repositories/currency_repository.dart';

/// Command to get all available currencies.
class GetAllCurrencies implements Command<List<Currency>, NoParams> {
  final CurrencyRepository repository;

  const GetAllCurrencies(this.repository);

  @override
  Future<Either<Failure, List<Currency>>> call(NoParams _) async {
    try {
      final currencies = await repository.getAllCurrencies();
      return Right(currencies);
    } catch (e) {
      return const Left(CacheFailure('Failed to load currencies'));
    }
  }
}
