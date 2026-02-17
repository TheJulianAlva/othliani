import 'package:equatable/equatable.dart';

abstract class CurrencyState extends Equatable {
  const CurrencyState();

  @override
  List<Object?> get props => [];
}

class CurrencyInitial extends CurrencyState {}

class CurrencyLoading extends CurrencyState {}

class CurrencyLoaded extends CurrencyState {
  final double result;
  final String fromCurrency;
  final String toCurrency;
  final Map<String, double> rates;

  const CurrencyLoaded({
    required this.result,
    required this.fromCurrency,
    required this.toCurrency,
    this.rates = const {},
  });

  @override
  List<Object?> get props => [result, fromCurrency, toCurrency, rates];

  CurrencyLoaded copyWith({
    double? result,
    String? fromCurrency,
    String? toCurrency,
    Map<String, double>? rates,
  }) {
    return CurrencyLoaded(
      result: result ?? this.result,
      fromCurrency: fromCurrency ?? this.fromCurrency,
      toCurrency: toCurrency ?? this.toCurrency,
      rates: rates ?? this.rates,
    );
  }
}

class CurrencyError extends CurrencyState {
  final String message;

  const CurrencyError(this.message);

  @override
  List<Object> get props => [message];
}
