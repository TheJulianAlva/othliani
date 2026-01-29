import 'package:equatable/equatable.dart';

class Viaje extends Equatable {
  final String id;
  final String destino;
  final String estado; // 'EN_CURSO', 'PROGRAMADO', etc.
  final int turistas;
  final double latitud; // Vital para el mapa
  final double longitud;

  const Viaje({
    required this.id,
    required this.destino,
    required this.estado,
    required this.turistas,
    required this.latitud,
    required this.longitud,
  });

  // Equatable nos permite comparar si dos viajes son iguales por sus datos
  @override
  List<Object?> get props => [id, destino, estado, turistas, latitud, longitud];
}
