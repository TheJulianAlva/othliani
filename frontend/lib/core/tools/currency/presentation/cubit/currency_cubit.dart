import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/core/tools/currency/domain/usecases/convert_currency_usecase.dart';
import 'package:frontend/core/tools/currency/domain/usecases/get_exchange_rates_usecase.dart';
import 'package:frontend/core/tools/currency/presentation/cubit/currency_state.dart';

class CurrencyCubit extends Cubit<CurrencyState> {
  final GetExchangeRatesUseCase getExchangeRatesUseCase;
  final ConvertCurrencyUseCase convertCurrencyUseCase;

  CurrencyCubit({
    required this.getExchangeRatesUseCase,
    required this.convertCurrencyUseCase,
  }) : super(CurrencyInitial());

  Future<void> init() async {
    emit(
      const CurrencyLoaded(result: 0.0, fromCurrency: 'USD', toCurrency: 'MXN'),
    );
  }

  Future<void> convert(double amount, String from, String to) async {
    final currentState = state;
    if (currentState is CurrencyLoaded) {
      emit(CurrencyLoading());
      final result = await convertCurrencyUseCase(
        ConvertCurrencyParams(amount: amount, from: from, to: to),
      );

      // Get rates just to keep them in state if needed, or we could skip it.
      // For now let's just update the result.
      final ratesResult = await getExchangeRatesUseCase(from);
      Map<String, double> rates = {};
      ratesResult.fold((l) => null, (r) => rates = r);

      result.fold(
        (failure) => emit(CurrencyError(failure.message)),
        (value) => emit(
          currentState.copyWith(
            result: value,
            fromCurrency: from,
            toCurrency: to,
            rates: rates,
          ),
        ),
      );
    } else {
      // Initial load
      emit(CurrencyLoading());
      final result = await convertCurrencyUseCase(
        ConvertCurrencyParams(amount: amount, from: from, to: to),
      );
      final ratesResult = await getExchangeRatesUseCase(from);
      Map<String, double> rates = {};
      ratesResult.fold((l) => null, (r) => rates = r);

      result.fold(
        (failure) => emit(CurrencyError(failure.message)),
        (value) => emit(
          CurrencyLoaded(
            result: value,
            fromCurrency: from,
            toCurrency: to,
            rates: rates,
          ),
        ),
      );
    }
  }

  void updateCurrencies(String from, String to) {
    final currentState = state;
    if (currentState is CurrencyLoaded) {
      emit(
        currentState.copyWith(fromCurrency: from, toCurrency: to, result: 0.0),
      );
    } else {
      emit(CurrencyLoaded(result: 0.0, fromCurrency: from, toCurrency: to));
    }
  }

  Future<void> swapCurrencies() async {
    final currentState = state;
    if (currentState is CurrencyLoaded) {
      emit(
        currentState.copyWith(
          fromCurrency: currentState.toCurrency,
          toCurrency: currentState.fromCurrency,
          result: 0.0,
        ),
      );
    }
  }
}
