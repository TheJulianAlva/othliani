import 'package:dartz/dartz.dart';
import 'package:frontend/core/error/failures.dart';
import 'package:frontend/features/turista/home/data/datasources/itinerary_remote_data_source.dart';
import 'package:frontend/features/turista/home/domain/entities/itinerary_item.dart';
import 'package:frontend/features/turista/home/domain/repositories/itinerary_repository.dart';

class ItineraryRepositoryImpl implements ItineraryRepository {
  final ItineraryRemoteDataSource remoteDataSource;

  ItineraryRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<ItineraryItem>>> getItinerary(
    String tripId,
  ) async {
    try {
      final items = await remoteDataSource.getItinerary(tripId);
      return Right(items);
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
