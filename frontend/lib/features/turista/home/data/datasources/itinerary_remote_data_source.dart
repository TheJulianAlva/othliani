import 'package:frontend/features/turista/home/data/models/itinerary_item_model.dart';

abstract class ItineraryRemoteDataSource {
  Future<List<ItineraryItemModel>> getItinerary(String tripId);
}

class ItineraryMockDataSource implements ItineraryRemoteDataSource {
  @override
  Future<List<ItineraryItemModel>> getItinerary(String tripId) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    // Mock data
    final now = DateTime.now();
    return List.generate(5, (index) {
      final startTime = now.add(Duration(hours: 9 + index));
      return ItineraryItemModel(
        id: 'event_$index',
        title: 'Evento del itinerario ${index + 1}',
        description: 'Descripción breve del lugar o actividad a realizar.',
        startTime: startTime,
        endTime: startTime.add(const Duration(hours: 1)),
        location: 'Lugar Turístico $index',
      );
    });
  }
}
