import 'package:frontend/features/guia/trips/domain/entities/actividad_itinerario.dart';

class ActividadItinerarioModel extends ActividadItinerario {
  ActividadItinerarioModel({
    required super.nombre,
    required super.horaInicio,
    required super.horaFin,
    required super.completada,
    super.descripcion,
    super.puntoReunion,
  });

  // Esto te servirá cuando conectes la API de OhtliAni
  factory ActividadItinerarioModel.fromJson(Map<String, dynamic> json) {
    return ActividadItinerarioModel(
      nombre: json['nombre'],
      horaInicio: DateTime.parse(json['hora_inicio']),
      horaFin: DateTime.parse(json['hora_fin']),
      completada: json['completada'] ?? false,
      descripcion: json['descripcion'],
      puntoReunion: json['punto_reunion'],
    );
  }
}
