import 'package:dartz/dartz.dart';
import 'package:frontend/core/error/failures.dart';
import 'package:frontend/core/usecase/usecase.dart';
import 'package:frontend/features/turista/tools/currency/domain/repositories/currency_repository.dart';

class ConvertCurrencyParams {
  final double amount;
  final String from;
  final String to;

  ConvertCurrencyParams({
    required this.amount,
    required this.from,
    required this.to,
  });
}

class ConvertCurrencyUseCase implements UseCase<double, ConvertCurrencyParams> {
  final CurrencyRepository repository;

  ConvertCurrencyUseCase(this.repository);

  @override
  Future<Either<Failure, double>> call(ConvertCurrencyParams params) async {
    return await repository.convertCurrency(
      params.amount,
      params.from,
      params.to,
    );
  }
}
