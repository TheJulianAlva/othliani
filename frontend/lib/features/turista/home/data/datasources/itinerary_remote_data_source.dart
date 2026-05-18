import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
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

class ItineraryRemoteDataSourceImpl implements ItineraryRemoteDataSource {
  final Dio dio;

  ItineraryRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<ItineraryItemModel>> getItinerary(String tripId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final folio = prefs.getString('CACHED_FOLIO') ?? 'GTO-4';
      
      final response = await dio.post('/participantes/login', data: {'folio': folio});
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        if (data['exito'] == true) {
          final viaje = data['viaje'];
          final actividades = viaje['actividades'] as List<dynamic>? ?? [];
          
          return actividades.map((act) {
            final horaProgStr = act['hora_programada'] as String;
            final startTime = DateTime.parse(horaProgStr);
            return ItineraryItemModel(
              id: act['id'],
              title: act['nombre_actividad'],
              description: act['direccion'] ?? 'Actividad del viaje',
              startTime: startTime,
              endTime: startTime.add(const Duration(hours: 2)),
              location: 'Nevado de Toluca',
            );
          }).toList();
        }
      }
      throw Exception('Error al obtener el itinerario del servidor');
    } catch (e) {
      throw Exception('Error de red: $e');
    }
  }
}
