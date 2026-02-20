import 'package:equatable/equatable.dart';
import 'actividad_itinerario.dart';

class Viaje extends Equatable {
  final String id;
  final String destino;
  final String estado; // 'EN_CURSO', 'PROGRAMADO', etc.
  final DateTime fechaInicio; // Fecha de inicio del viaje
  final DateTime fechaFin; // Fecha de fin del viaje
  final int turistas;
  final double latitud; // Vital para el mapa
  final double longitud;

  // Campos operativos para tarjetas enriquecidas
  final String guiaNombre;
  final String horaInicio; // Ej: "08:30 AM"
  final int alertasActivas;

  // ✨ NUEVO CAMPO: Lista completa de actividades
  final List<ActividadItinerario> itinerario;

  const Viaje({
    required this.id,
    required this.destino,
    required this.estado,
    required this.fechaInicio,
    required this.fechaFin,
    required this.turistas,
    required this.latitud,
    required this.longitud,
    this.guiaNombre = 'Sin asignar',
    this.horaInicio = '--:--',
    this.alertasActivas = 0,
    this.itinerario = const [],
  });

  // Helper para saber la duración (Ej: "4 horas" o "3 días")
  String get duracionLabel {
    final diff = fechaFin.difference(fechaInicio);
    if (diff.inHours < 24) {
      return "${diff.inHours} horas";
    } else {
      return "${diff.inDays} días";
    }
  }

  Viaje copyWith({
    String? id,
    String? destino,
    String? estado,
    DateTime? fechaInicio,
    DateTime? fechaFin,
    int? turistas,
    double? latitud,
    double? longitud,
    String? guiaNombre,
    String? horaInicio,
    int? alertasActivas,
    List<ActividadItinerario>? itinerario,
  }) {
    return Viaje(
      id: id ?? this.id,
      destino: destino ?? this.destino,
      estado: estado ?? this.estado,
      fechaInicio: fechaInicio ?? this.fechaInicio,
      fechaFin: fechaFin ?? this.fechaFin,
      turistas: turistas ?? this.turistas,
      latitud: latitud ?? this.latitud,
      longitud: longitud ?? this.longitud,
      guiaNombre: guiaNombre ?? this.guiaNombre,
      horaInicio: horaInicio ?? this.horaInicio,
      alertasActivas: alertasActivas ?? this.alertasActivas,
      itinerario: itinerario ?? this.itinerario,
    );
  }

  // Equatable nos permite comparar si dos viajes son iguales por sus datos
  @override
  List<Object?> get props => [
    id,
    destino,
    estado,
    fechaInicio,
    fechaFin,
    turistas,
    latitud,
    longitud,
    guiaNombre,
    horaInicio,
    alertasActivas,
    itinerario,
  ];
}
