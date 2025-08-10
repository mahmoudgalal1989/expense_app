import 'package:get_it/get_it.dart';
import 'package:expense_app/features/category/data/datasources/category_local_data_source.dart';
import 'package:expense_app/features/category/data/repositories/category_repository_impl.dart';
import 'package:expense_app/features/category/domain/repositories/category_repository.dart';

final sl = GetIt.instance;

void initCategoryFeature() {
  // Repository
  sl.registerLazySingleton<CategoryRepository>(
    () => CategoryRepositoryImpl(
      localDataSource: sl(),
    ),
  );

  // Data sources
  sl.registerLazySingleton<CategoryLocalDataSource>(
    () => CategoryLocalDataSourceImpl(),
  );
}
