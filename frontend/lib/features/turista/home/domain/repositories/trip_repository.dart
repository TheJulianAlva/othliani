import 'package:dartz/dartz.dart';
import 'package:frontend/core/error/failures.dart';
import 'package:frontend/features/turista/home/domain/entities/trip.dart';

abstract class TripRepository {
  Future<Either<Failure, Trip>> getCurrentTrip();
}
