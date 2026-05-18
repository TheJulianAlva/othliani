import 'package:dio/dio.dart';
import 'package:frontend/features/guia/home/domain/entities/agencia_home_data.dart';
import 'package:frontend/features/guia/home/domain/entities/personal_home_data.dart';
import 'package:frontend/features/guia/trips/data/models/actividad_itinerario_model.dart';

abstract class GuiaHomeRemoteDataSource {
  Future<AgenciaHomeData> getAgenciaHomeData(String folio);
  Future<PersonalHomeData> getPersonalHomeData(String nombreGuia);
}

class GuiaHomeRemoteDataSourceImpl implements GuiaHomeRemoteDataSource {
  final Dio dio;

  GuiaHomeRemoteDataSourceImpl({required this.dio});

  @override
  Future<AgenciaHomeData> getAgenciaHomeData(String guiaId) async {
    try {
      final response = await dio.get('/viajes/guia/$guiaId');

      if (response.data == null || response.data == '') {
        throw Exception('No tienes ningún viaje asignado para hoy.');
      }

      final data = response.data;

      final actividadesRaw = data['actividades'] as List<dynamic>? ?? [];
      final actividades =
          actividadesRaw
              .map(
                (act) => ActividadItinerarioModel(
                  nombre: act['nombre_actividad'],
                  horaInicio: DateTime.parse(act['hora_programada']),
                  horaFin: DateTime.parse(
                    act['hora_programada'],
                  ).add(const Duration(hours: 2)),
                  completada: false,
                  descripcion: 'Geocerca: ${act['radio_geocerca_mts']}m',
                  puntoReunion: 'Lat: ${act['lat']}, Lng: ${act['lng']}',
                ),
              )
              .toList();

      final participantesRaw = data['participantes'] as List<dynamic>? ?? [];
      final turistas =
          participantesRaw
              .where((p) => p['rol'] == 'TURISTA')
              .map(
                (t) => Turista(
                  id: t['id_usuario'],
                  nombre:
                      'GTO-4', // Hardcoded for demo as requested: "En la pestaña de turistas te saldrá el folio GTO-4 listo"
                  viajeId: data['id'],
                  status: 'OK',
                  bateria: 1.0,
                  enCampo: true,
                ),
              )
              .toList();

      // Dummy participante list so UI doesn't crash on length counts
      final dummyParticipantes =
          turistas
              .map(
                (t) => Participante(
                  nombre: t.nombre,
                  estado: EstadoParticipante.sincronizado,
                ),
              )
              .toList();

      return AgenciaHomeData(
        nombreViaje: data['nombre_viaje'],
        folio: 'VEL2026MX001',
        destino: 'Nevado de Toluca', // Hardcoded as requested
        totalParticipantes: turistas.length,
        geocercaRadio: '${data['distancia_max_global']} m',
        participantes: dummyParticipantes,
        historialAlertas: const [],
        actividades: actividades,
        listaTuristas: turistas,
      );
    } catch (e) {
      throw Exception('Error al conectar con el servidor de Veltur');
    }
  }

  @override
  Future<PersonalHomeData> getPersonalHomeData(String nombreGuia) {
    throw UnimplementedError('Not implemented for demo');
  }
}
