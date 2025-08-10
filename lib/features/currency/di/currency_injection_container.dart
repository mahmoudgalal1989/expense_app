import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../data/datasources/currency_local_data_source.dart';
import '../data/repositories/currency_repository_impl.dart';
import '../domain/repositories/currency_repository.dart';

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

  // Note: CurrencyRepository is used by AppSettingsBloc
  // No need for separate CurrencyBloc or use cases
}
