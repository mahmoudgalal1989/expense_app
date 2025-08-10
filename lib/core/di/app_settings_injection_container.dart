import 'package:get_it/get_it.dart';
import 'package:expense_app/core/bloc/bloc.dart';
import 'package:expense_app/features/currency/domain/repositories/currency_repository.dart';
import 'package:expense_app/features/category/domain/repositories/category_repository.dart';

final GetIt sl = GetIt.instance;

/// Initialize global app settings dependency injection
void initAppSettings() {
  // BLoC
  sl.registerFactory<AppSettingsBloc>(
    () => AppSettingsBloc(
      currencyRepository: sl<CurrencyRepository>(),
      categoryRepository: sl<CategoryRepository>(),
    ),
  );
}
