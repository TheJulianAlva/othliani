import 'package:dartz/dartz.dart';
import 'package:frontend/core/error/failures.dart';
import 'package:frontend/core/usecase/usecase.dart';
import 'package:frontend/features/turista/home/domain/entities/trip.dart';
import 'package:frontend/features/turista/home/domain/repositories/trip_repository.dart';

class GetCurrentTripUseCase implements UseCase<Trip, NoParams> {
  final TripRepository repository;

  GetCurrentTripUseCase(this.repository);

  @override
  Future<Either<Failure, Trip>> call(NoParams params) async {
    return await repository.getCurrentTrip();
  }
}
