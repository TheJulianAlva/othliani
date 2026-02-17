import 'package:equatable/equatable.dart';

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
  ];
}
