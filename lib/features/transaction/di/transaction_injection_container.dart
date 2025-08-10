import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Data Layer
import '../data/datasources/transaction_local_data_source.dart';
import '../data/datasources/transaction_local_data_source_impl.dart';
import '../data/repositories/transaction_repository_impl.dart';

// Domain Layer
import '../domain/repositories/transaction_repository.dart';
import '../domain/usecases/add_transaction.dart';
import '../domain/usecases/delete_transaction.dart';
import '../domain/usecases/delete_transactions_by_filter.dart';
import '../domain/usecases/delete_transactions_specialized.dart';
import '../domain/usecases/get_transaction_statistics.dart';
import '../domain/usecases/get_transactions.dart';
import '../domain/usecases/get_transactions_by_filter.dart';
import '../domain/usecases/manage_transaction_categories.dart';
import '../domain/usecases/preview_bulk_deletion.dart';
import '../domain/usecases/update_transaction.dart';

// Presentation Layer
import '../presentation/bloc/transaction_bloc.dart';

/// Dependency injection container for transaction feature
/// 
/// Registers all transaction-related dependencies following the established
/// pattern from category and currency features.
class TransactionInjectionContainer {
  static final GetIt _getIt = GetIt.instance;

  /// Initializes all transaction dependencies
  static Future<void> init() async {
    // ========================================================================
    // DATA SOURCES
    // ========================================================================
    
    _getIt.registerLazySingleton<TransactionLocalDataSource>(
      () => TransactionLocalDataSourceImpl(_getIt<SharedPreferences>()),
    );

    // ========================================================================
    // REPOSITORIES
    // ========================================================================
    
    _getIt.registerLazySingleton<TransactionRepository>(
      () => TransactionRepositoryImpl(_getIt<TransactionLocalDataSource>()),
    );

    // ========================================================================
    // USE CASES - BASIC OPERATIONS
    // ========================================================================
    
    _getIt.registerFactory(() => AddTransaction(_getIt<TransactionRepository>()));
    _getIt.registerFactory(() => GetTransactions(_getIt<TransactionRepository>()));
    _getIt.registerFactory(() => GetTransactionById(_getIt<TransactionRepository>()));
    _getIt.registerFactory(() => GetTransactionsByFilter(_getIt<TransactionRepository>()));
    _getIt.registerFactory(() => UpdateTransaction(_getIt<TransactionRepository>()));
    _getIt.registerFactory(() => DeleteTransaction(_getIt<TransactionRepository>()));
    _getIt.registerFactory(() => DeleteAllTransactions(_getIt<TransactionRepository>()));

    // ========================================================================
    // USE CASES - BULK DELETION
    // ========================================================================
    
    _getIt.registerFactory(() => DeleteTransactionsByFilter(_getIt<TransactionRepository>()));
    _getIt.registerFactory(() => DeleteTransactionsByCategories(_getIt<TransactionRepository>()));
    _getIt.registerFactory(() => DeleteTransactionsByCurrency(_getIt<TransactionRepository>()));
    _getIt.registerFactory(() => DeleteTransactionsByDateRange(_getIt<TransactionRepository>()));
    _getIt.registerFactory(() => DeleteTransactionsByType(_getIt<TransactionRepository>()));
    _getIt.registerFactory(() => DeleteTransactionsByNote(_getIt<TransactionRepository>()));
    _getIt.registerFactory(() => DeleteTransactionsByAmountRange(_getIt<TransactionRepository>()));

    // ========================================================================
    // USE CASES - PREVIEW AND SAFETY
    // ========================================================================
    
    _getIt.registerFactory(() => PreviewBulkDeletion(_getIt<TransactionRepository>()));
    _getIt.registerFactory(() => CountTransactionsByFilter(_getIt<TransactionRepository>()));

    // ========================================================================
    // USE CASES - STATISTICS
    // ========================================================================
    
    _getIt.registerLazySingleton<GetTransactionStatistics>(
      () => GetTransactionStatistics(_getIt<TransactionRepository>()),
    );
    _getIt.registerLazySingleton<GetFilteredTransactionStatistics>(
      () => GetFilteredTransactionStatistics(_getIt<TransactionRepository>()),
    );
    _getIt.registerFactory(() => GetTotalAmountByCategories(_getIt<TransactionRepository>()));
    _getIt.registerFactory(() => GetTotalAmountByCurrency(_getIt<TransactionRepository>()));

    // ========================================================================
    // USE CASES - CATEGORY MANAGEMENT
    // ========================================================================
    
    _getIt.registerFactory(() => AddCategoryToTransaction(_getIt<TransactionRepository>()));
    _getIt.registerFactory(() => RemoveCategoryFromTransaction(_getIt<TransactionRepository>()));
    _getIt.registerFactory(() => ReplaceCategoriesInTransaction(_getIt<TransactionRepository>()));
    _getIt.registerFactory(() => ClearCategoriesFromTransaction(_getIt<TransactionRepository>()));

    // ========================================================================
    // PRESENTATION LAYER - BLOC
    // ========================================================================
    
    _getIt.registerFactory<TransactionBloc>(
      () => TransactionBloc(
        getTransactions: _getIt<GetTransactions>(),
        getTransactionsByFilter: _getIt<GetTransactionsByFilter>(),
        addTransaction: _getIt<AddTransaction>(),
        updateTransaction: _getIt<UpdateTransaction>(),
        deleteTransaction: _getIt<DeleteTransaction>(),
        deleteTransactionsByFilter: _getIt<DeleteTransactionsByFilter>(),
        previewBulkDeletion: _getIt<PreviewBulkDeletion>(),
        getTransactionStatistics: _getIt<GetTransactionStatistics>(),
        getFilteredTransactionStatistics: _getIt<GetFilteredTransactionStatistics>(),
        addCategoryToTransaction: _getIt<AddCategoryToTransaction>(),
        removeCategoryFromTransaction: _getIt<RemoveCategoryFromTransaction>(),
        replaceCategoriesInTransaction: _getIt<ReplaceCategoriesInTransaction>(),
      ),
    );
  }

  /// Clears all transaction dependencies (useful for testing)
  static void reset() {
    // Data Sources
    if (_getIt.isRegistered<TransactionLocalDataSource>()) {
      _getIt.unregister<TransactionLocalDataSource>();
    }

    // Repositories
    if (_getIt.isRegistered<TransactionRepository>()) {
      _getIt.unregister<TransactionRepository>();
    }

    // Use Cases - Basic Operations
    if (_getIt.isRegistered<AddTransaction>()) _getIt.unregister<AddTransaction>();
    if (_getIt.isRegistered<GetTransactions>()) _getIt.unregister<GetTransactions>();
    if (_getIt.isRegistered<GetTransactionById>()) _getIt.unregister<GetTransactionById>();
    if (_getIt.isRegistered<GetTransactionsByFilter>()) _getIt.unregister<GetTransactionsByFilter>();
    if (_getIt.isRegistered<UpdateTransaction>()) _getIt.unregister<UpdateTransaction>();
    if (_getIt.isRegistered<DeleteTransaction>()) _getIt.unregister<DeleteTransaction>();
    if (_getIt.isRegistered<DeleteAllTransactions>()) _getIt.unregister<DeleteAllTransactions>();

    // Use Cases - Bulk Deletion
    if (_getIt.isRegistered<DeleteTransactionsByFilter>()) _getIt.unregister<DeleteTransactionsByFilter>();
    if (_getIt.isRegistered<DeleteTransactionsByCategories>()) _getIt.unregister<DeleteTransactionsByCategories>();
    if (_getIt.isRegistered<DeleteTransactionsByCurrency>()) _getIt.unregister<DeleteTransactionsByCurrency>();
    if (_getIt.isRegistered<DeleteTransactionsByDateRange>()) _getIt.unregister<DeleteTransactionsByDateRange>();
    if (_getIt.isRegistered<DeleteTransactionsByType>()) _getIt.unregister<DeleteTransactionsByType>();
    if (_getIt.isRegistered<DeleteTransactionsByNote>()) _getIt.unregister<DeleteTransactionsByNote>();
    if (_getIt.isRegistered<DeleteTransactionsByAmountRange>()) _getIt.unregister<DeleteTransactionsByAmountRange>();

    // Use Cases - Preview and Safety
    if (_getIt.isRegistered<PreviewBulkDeletion>()) _getIt.unregister<PreviewBulkDeletion>();
    if (_getIt.isRegistered<CountTransactionsByFilter>()) _getIt.unregister<CountTransactionsByFilter>();

    // Use Cases - Statistics
    if (_getIt.isRegistered<GetTransactionStatistics>()) _getIt.unregister<GetTransactionStatistics>();
    if (_getIt.isRegistered<GetFilteredTransactionStatistics>()) _getIt.unregister<GetFilteredTransactionStatistics>();
    if (_getIt.isRegistered<GetTotalAmountByCategories>()) _getIt.unregister<GetTotalAmountByCategories>();
    if (_getIt.isRegistered<GetTotalAmountByCurrency>()) _getIt.unregister<GetTotalAmountByCurrency>();

    // Use Cases - Category Management
    if (_getIt.isRegistered<AddCategoryToTransaction>()) _getIt.unregister<AddCategoryToTransaction>();
    if (_getIt.isRegistered<RemoveCategoryFromTransaction>()) _getIt.unregister<RemoveCategoryFromTransaction>();
    if (_getIt.isRegistered<ReplaceCategoriesInTransaction>()) _getIt.unregister<ReplaceCategoriesInTransaction>();
    if (_getIt.isRegistered<ClearCategoriesFromTransaction>()) _getIt.unregister<ClearCategoriesFromTransaction>();

    // Presentation Layer - BLoC
    if (_getIt.isRegistered<TransactionBloc>()) _getIt.unregister<TransactionBloc>();
  }
}
