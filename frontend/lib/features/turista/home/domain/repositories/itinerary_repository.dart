import 'package:dartz/dartz.dart';
import 'package:frontend/core/error/failures.dart';
import 'package:frontend/features/turista/home/domain/entities/itinerary_item.dart';

abstract class ItineraryRepository {
  Future<Either<Failure, List<ItineraryItem>>> getItinerary(String tripId);
}
