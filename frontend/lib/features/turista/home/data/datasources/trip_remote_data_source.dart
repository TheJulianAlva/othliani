import 'package:frontend/features/turista/home/data/models/trip_model.dart';

abstract class TripRemoteDataSource {
  Future<TripModel> getCurrentTrip();
}

class TripMockDataSource implements TripRemoteDataSource {
  @override
  Future<TripModel> getCurrentTrip() async {
    await Future.delayed(const Duration(seconds: 1)); // Simulate latency

    // Mock data based on pantalla_inicio_viaje.dart
    final mockActivities = {
      'Día 1': [
        {
          'id': '1_1',
          'time': '08:00 AM',
          'title': 'Desayuno en el hotel',
          'description':
              'Buffet completo con opciones locales e internacionales.',
          'status': 'terminada',
        },
        {
          'id': '1_2',
          'time': '10:00 AM',
          'title': 'Visita a zona arqueológica',
          'description': 'Recorrido guiado por las ruinas mayas de Tulum.',
          'status': 'terminada',
        },
        {
          'id': '1_3',
          'time': '01:00 PM',
          'title': 'Comida en restaurante local',
          'description': 'Degustación de platillos típicos de la región.',
          'status': 'en_curso',
        },
        {
          'id': '1_4',
          'time': '03:30 PM',
          'title': 'Tiempo libre en la playa',
          'description': 'Relájate en las hermosas playas de arena blanca.',
          'status': 'pendiente',
        },
        {
          'id': '1_5',
          'time': '06:00 PM',
          'title': 'Cena de bienvenida',
          'description': 'Cena especial con vista al mar.',
          'status': 'pendiente',
        },
      ],
      'Día 2': [
        {
          'id': '2_1',
          'time': '07:00 AM',
          'title': 'Yoga en la playa',
          'description': 'Sesión de yoga matutina frente al mar.',
          'status': 'pendiente',
        },
        {
          'id': '2_2',
          'time': '09:00 AM',
          'title': 'Desayuno buffet',
          'description': 'Desayuno completo con opciones saludables.',
          'status': 'pendiente',
        },
        {
          'id': '2_3',
          'time': '11:00 AM',
          'title': 'Tour en cenote',
          'description': 'Explora los místicos cenotes mayas.',
          'status': 'pendiente',
        },
      ],
      'Día 3': [
        {
          'id': '3_1',
          'time': '08:30 AM',
          'title': 'Desayuno continental',
          'description': 'Desayuno ligero antes de la excursión del día.',
          'status': 'pendiente',
        },
        {
          'id': '3_2',
          'time': '10:00 AM',
          'title': 'Excursión a Chichén Itzá',
          'description': 'Visita una de las 7 maravillas del mundo moderno.',
          'status': 'pendiente',
        },
      ],
    };

    // Convert map manually to simulate proper JSON structure parsing if needed,
    // or just construct TripModel directly since we are mocking.
    // However, to test `fromJson`, let's construct it via JSON.
    final json = {
      'id': 'trip_001',
      'title': 'Cancún-Tulum',
      'description': 'All Included Trip',
      'activitiesByDay': mockActivities,
    };

    return TripModel.fromJson(json);
  }
}
