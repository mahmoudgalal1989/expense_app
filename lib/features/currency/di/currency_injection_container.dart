import 'package:expense_app/core/usecases/command.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/datasources/currency_local_data_source.dart';
import '../data/repositories/currency_repository_impl.dart';
import '../domain/entities/currency.dart';
import '../domain/repositories/currency_repository.dart';
import '../domain/usecases/get_all_currencies.dart';
import '../domain/usecases/set_selected_currency.dart';
import '../domain/usecases/search_currencies.dart';
import '../presentation/bloc/currency_bloc/currency_bloc.dart';

final getIt = GetIt.instance;

/// Initializes all dependencies for the currency feature
Future<void> initCurrencyFeature() async {
  // Register SharedPreferences
  if (!getIt.isRegistered<SharedPreferences>()) {
    final prefs = await SharedPreferences.getInstance();
    getIt.registerLazySingleton<SharedPreferences>(() => prefs);
  }

  // Data sources
  getIt.registerLazySingleton<CurrencyLocalDataSource>(
    () => CurrencyLocalDataSourceImpl(),
  );

  // Repository
  getIt.registerLazySingleton<CurrencyRepository>(
    () => CurrencyRepositoryImpl(
      localDataSource: getIt<CurrencyLocalDataSource>(),
      prefs: getIt<SharedPreferences>(),
    ),
  );

  // Use cases as Commands
  getIt.registerLazySingleton<Command<List<Currency>, NoParams>>(
    () => GetAllCurrencies(getIt<CurrencyRepository>()),
  );

  getIt.registerLazySingleton<Command<void, SetSelectedCurrencyParams>>(
    () => SetSelectedCurrency(getIt<CurrencyRepository>()),
  );

  getIt.registerLazySingleton<Command<List<Currency>, SearchCurrenciesParams>>(
    () => SearchCurrencies(getIt<CurrencyRepository>()),
  );

  // BLoC
  getIt.registerFactory(
    () => CurrencyBloc(
      getAllCurrencies: getIt<Command<List<Currency>, NoParams>>(),
      setSelectedCurrency: getIt<Command<void, SetSelectedCurrencyParams>>(),
      searchCurrencies:
          getIt<Command<List<Currency>, SearchCurrenciesParams>>(),
    ),
  );
}
