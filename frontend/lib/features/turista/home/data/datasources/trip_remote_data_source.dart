import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:frontend/features/turista/home/data/models/trip_model.dart';
import 'package:frontend/features/turista/home/data/models/activity_model.dart';
import 'package:frontend/features/turista/home/domain/entities/activity.dart';

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

class TripRemoteDataSourceImpl implements TripRemoteDataSource {
  final Dio dio;

  TripRemoteDataSourceImpl({required this.dio});

  @override
  Future<TripModel> getCurrentTrip() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final folio = prefs.getString('CACHED_FOLIO') ?? 'GTO-4';
      
      final response = await dio.post('/participantes/login', data: {'folio': folio});
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        if (data['exito'] == true) {
          final viaje = data['viaje'];
          final actividades = viaje['actividades'] as List<dynamic>? ?? [];
          
          final mappedActivities = actividades.map((act) {
            return ActivityModel(
              id: act['id'],
              title: act['nombre_actividad'],
              description: act['direccion'] ?? 'Actividad del viaje',
              time: act['hora_programada'].toString().substring(11, 16),
              status: act['estado'] == 'COMPLETADO' 
                  ? ActivityStatus.finished 
                  : (act['estado'] == 'EN_CURSO' ? ActivityStatus.inProgress : ActivityStatus.pending),
            );
          }).toList();

          final json = {
            'id': viaje['id'],
            'title': viaje['nombre_viaje'],
            'description': 'Nevado de Toluca',
            'activitiesByDay': {
              'Día 1': mappedActivities.map((e) => e.toJson()).toList(),
            },
          };

          return TripModel.fromJson(json);
        }
      }
      throw Exception('Error al obtener el viaje del servidor');
    } catch (e) {
      throw Exception('Error de red: $e');
    }
  }
}
