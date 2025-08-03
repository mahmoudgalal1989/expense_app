import 'package:get_it/get_it.dart';
import 'package:expense_app/features/category/data/datasources/category_local_data_source.dart';
import 'package:expense_app/features/category/data/datasources/category_persistence_data_source.dart';
import 'package:expense_app/features/category/data/repositories/category_repository_impl.dart';
import 'package:expense_app/features/category/domain/repositories/category_repository.dart';
import 'package:expense_app/features/category/domain/usecases/add_user_category.dart';
import 'package:expense_app/features/category/domain/usecases/get_suggested_categories.dart';
import 'package:expense_app/features/category/domain/usecases/manage_user_categories.dart';
import 'package:expense_app/features/category/presentation/bloc/category_bloc.dart';

final sl = GetIt.instance;

void initCategoryFeature() {
  // BLoC
  sl.registerFactory(
    () => CategoryBloc(
      getSuggestedCategories: sl(),
      addUserCategory: sl(),
      manageUserCategories: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => GetSuggestedCategories(sl()));
  sl.registerLazySingleton(() => AddUserCategory(sl()));
  sl.registerLazySingleton(() => ManageUserCategories(sl()));

  // Repository
  sl.registerLazySingleton<CategoryRepository>(
    () => CategoryRepositoryImpl(localDataSource: sl()),
  );

  // Data sources
  sl.registerLazySingleton<CategoryLocalDataSource>(
    () => CategoryLocalDataSourceImpl(),
  );
  sl.registerLazySingleton<CategoryPersistenceDataSource>(
    () => CategoryPersistenceDataSourceImpl(),
  );
}
