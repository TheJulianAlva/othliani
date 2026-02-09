import 'package:dartz/dartz.dart';
import 'package:frontend/core/error/failures.dart';
import 'package:frontend/features/turista/tools/currency/data/datasources/currency_remote_data_source.dart';
import 'package:frontend/features/turista/tools/currency/domain/repositories/currency_repository.dart';

class CurrencyRepositoryImpl implements CurrencyRepository {
  final CurrencyRemoteDataSource remoteDataSource;

  CurrencyRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, Map<String, double>>> getExchangeRates(
    String baseCurrency,
  ) async {
    try {
      final rates = await remoteDataSource.getExchangeRates(baseCurrency);
      return Right(rates);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, double>> convertCurrency(
    double amount,
    String from,
    String to,
  ) async {
    try {
      final rates = await remoteDataSource.getExchangeRates(from);
      final rate = rates[to];
      if (rate == null) {
        return Left(ServerFailure('Rate not found'));
      }
      return Right(amount * rate);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
