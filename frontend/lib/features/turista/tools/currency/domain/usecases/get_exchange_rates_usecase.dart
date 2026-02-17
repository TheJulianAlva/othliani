import 'package:dartz/dartz.dart';
import 'package:frontend/core/error/failures.dart';
import 'package:frontend/core/usecase/usecase.dart';
import 'package:frontend/features/turista/tools/currency/domain/repositories/currency_repository.dart';

class GetExchangeRatesUseCase implements UseCase<Map<String, double>, String> {
  final CurrencyRepository repository;

  GetExchangeRatesUseCase(this.repository);

  @override
  Future<Either<Failure, Map<String, double>>> call(String baseCurrency) async {
    return await repository.getExchangeRates(baseCurrency);
  }
}
