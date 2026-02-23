import 'package:dartz/dartz.dart';
import 'package:frontend/core/error/failures.dart';

abstract class CurrencyRepository {
  Future<Either<Failure, Map<String, double>>> getExchangeRates(
    String baseCurrency,
  );
  Future<Either<Failure, double>> convertCurrency(
    double amount,
    String from,
    String to,
  );
}
