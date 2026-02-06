import 'package:equatable/equatable.dart';

class Viaje extends Equatable {
  final String id;
  final String destino;
  final String estado; // 'EN_CURSO', 'PROGRAMADO', etc.
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
    required this.turistas,
    required this.latitud,
    required this.longitud,
    this.guiaNombre = 'Sin asignar',
    this.horaInicio = '--:--',
    this.alertasActivas = 0,
  });

  // Equatable nos permite comparar si dos viajes son iguales por sus datos
  @override
  List<Object?> get props => [
    id,
    destino,
    estado,
    turistas,
    latitud,
    longitud,
    guiaNombre,
    horaInicio,
    alertasActivas,
  ];
}
