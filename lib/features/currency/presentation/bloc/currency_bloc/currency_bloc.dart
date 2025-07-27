import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:expense_app/features/currency/domain/entities/currency.dart';
import 'package:expense_app/features/currency/domain/usecases/get_all_currencies.dart';
import 'package:expense_app/features/currency/domain/usecases/get_most_used_currencies.dart';
import 'package:expense_app/features/currency/domain/usecases/set_selected_currency.dart';

part 'currency_event.dart';
part 'currency_state.dart';

class CurrencyBloc extends Bloc<CurrencyEvent, CurrencyState> {
  final GetAllCurrencies getAllCurrencies;
  final GetMostUsedCurrencies getMostUsedCurrencies;
  final SetSelectedCurrency setSelectedCurrency;

  CurrencyBloc({
    required this.getAllCurrencies,
    required this.getMostUsedCurrencies,
    required this.setSelectedCurrency,
  }) : super(CurrencyInitial()) {
    on<LoadCurrencies>(_onLoadCurrencies);
    on<LoadMostUsedCurrencies>(_onLoadMostUsedCurrencies);
    on<SelectCurrency>(_onSelectCurrency);
  }

  Future<void> _onLoadCurrencies(
    LoadCurrencies event,
    Emitter<CurrencyState> emit,
  ) async {
    emit(CurrencyLoading());
    
    final result = await getAllCurrencies();
    
    result.fold(
      (failure) => emit(CurrencyError(failure.toString())),
      (currencies) {
        if (currencies.isEmpty) {
          emit(const CurrencyError('No currencies available'));
        } else {
          // Create a new state with the loaded currencies
          final newState = CurrenciesLoaded(currencies: currencies);
          emit(newState);
          // After loading all currencies, load most used currencies
          add(const LoadMostUsedCurrencies());
        }
      },
    );
  }

  Future<void> _onLoadMostUsedCurrencies(
    LoadMostUsedCurrencies event,
    Emitter<CurrencyState> emit,
  ) async {
    if (state is! CurrenciesLoaded) return;
    
    final currentState = state as CurrenciesLoaded;
    
    // Get most used currencies
    final result = await getMostUsedCurrencies();
    
    // Handle the result
    result.fold(
      // On error, emit error state
      (failure) => emit(CurrencyError(failure.toString())),
      // On success, update the state with most used currencies
      (mostUsedCurrencies) {
        // Only update if the current state is still CurrenciesLoaded
        if (state is CurrenciesLoaded) {
          emit((state as CurrenciesLoaded).copyWith(
            mostUsedCurrencies: mostUsedCurrencies,
          ));
        }
      },
    );
  }

  Future<void> _onSelectCurrency(
    SelectCurrency event,
    Emitter<CurrencyState> emit,
  ) async {
    if (state is! CurrenciesLoaded) return;
    
    final currentState = state as CurrenciesLoaded;
    final selectedCurrency = currentState.currencies.firstWhere(
      (c) => c.code == event.currencyCode,
      orElse: () => currentState.currencies.first,
    );
    
    emit(CurrencyLoading());
    
    try {
      await setSelectedCurrency(selectedCurrency);
      
      final updatedCurrencies = currentState.currencies.map((currency) {
        return currency.code == event.currencyCode
            ? currency.copyWith(isSelected: true)
            : currency.copyWith(isSelected: false);
      }).toList();
      
      emit(CurrenciesLoaded(currencies: updatedCurrencies));
    } catch (e) {
      emit(CurrencyError('Failed to select currency: ${e.toString()}'));
      // Re-emit the previous state to maintain UI consistency
      emit(currentState);
    }
  }
}
