import 'package:dartz/dartz.dart';
import 'package:frontend/core/error/failures.dart';
import 'package:frontend/core/usecase/usecase.dart';
import 'package:frontend/features/turista/home/domain/entities/itinerary_item.dart';
import 'package:frontend/features/turista/home/domain/repositories/itinerary_repository.dart';

class GetItineraryUseCase implements UseCase<List<ItineraryItem>, String> {
  final ItineraryRepository repository;

  GetItineraryUseCase(this.repository);

  @override
  Future<Either<Failure, List<ItineraryItem>>> call(String tripId) async {
    return await repository.getItinerary(tripId);
  }
}
