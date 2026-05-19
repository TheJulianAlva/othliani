import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:frontend/features/turista/home/data/models/itinerary_item_model.dart';

abstract class ItineraryRemoteDataSource {
  Future<List<ItineraryItemModel>> getItinerary(String tripId);
}

class ItineraryMockDataSource implements ItineraryRemoteDataSource {
  @override
  Future<List<ItineraryItemModel>> getItinerary(String tripId) async {
    await Future.delayed(const Duration(milliseconds: 600));

    final today = DateTime.now();
    final base = DateTime(today.year, today.month, today.day);

    return [
      ItineraryItemModel(
        id: 'event_1',
        title: 'Desayuno de bienvenida',
        description: 'Buffet de especialidades yucatecas incluido.',
        startTime: base.add(const Duration(hours: 8, minutes: 0)),
        endTime: base.add(const Duration(hours: 9, minutes: 30)),
        location: 'Hotel Akumal Bay, Tulum',
      ),
      ItineraryItemModel(
        id: 'event_2',
        title: 'Zona Arqueológica de Tulum',
        description:
            'Recorrido guiado por la ciudad amurallada maya frente al mar Caribe.',
        startTime: base.add(const Duration(hours: 10, minutes: 0)),
        endTime: base.add(const Duration(hours: 12, minutes: 30)),
        location: 'Zona Arqueológica de Tulum, Q.R.',
      ),
      ItineraryItemModel(
        id: 'event_3',
        title: 'Almuerzo en cenote',
        description: 'Comida tradicional en restaurante junto a cenote natural.',
        startTime: base.add(const Duration(hours: 13, minutes: 0)),
        endTime: base.add(const Duration(hours: 14, minutes: 30)),
        location: 'Restaurante La Selva, Tulum',
      ),
      ItineraryItemModel(
        id: 'event_4',
        title: 'Tiempo libre en Playa Paraíso',
        description:
            'Disfruta la playa considerada una de las más bellas del Caribe. Punto de reunión: palapa central.',
        startTime: base.add(const Duration(hours: 15, minutes: 0)),
        endTime: base.add(const Duration(hours: 18, minutes: 0)),
        location: 'Playa Paraíso, Tulum',
      ),
      ItineraryItemModel(
        id: 'event_5',
        title: 'Cena de cierre y brindis',
        description: 'Mariscos y cocina mexicana en el restaurante del grupo.',
        startTime: base.add(const Duration(hours: 20, minutes: 0)),
        endTime: base.add(const Duration(hours: 22, minutes: 0)),
        location: 'El Camello Jr., Tulum',
      ),
    ];
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
