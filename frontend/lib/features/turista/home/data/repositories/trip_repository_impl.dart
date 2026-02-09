import 'package:dartz/dartz.dart';
import 'package:frontend/core/error/failures.dart';
import 'package:frontend/features/turista/home/data/datasources/trip_remote_data_source.dart';
import 'package:frontend/features/turista/home/domain/entities/trip.dart';
import 'package:frontend/features/turista/home/domain/repositories/trip_repository.dart';

class TripRepositoryImpl implements TripRepository {
  final TripRemoteDataSource remoteDataSource;

  TripRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, Trip>> getCurrentTrip() async {
    try {
      final trip = await remoteDataSource.getCurrentTrip();
      return Right(trip);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
