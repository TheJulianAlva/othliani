import 'package:equatable/equatable.dart';

class ActividadItinerario extends Equatable {
  final String nombre;
  final DateTime horaInicio;
  final DateTime horaFin;
  final bool completada;
  // --- MEJORA: Atributos para el Panel de Detalles ---
  final String? descripcion;
  final String? puntoReunion;

  const ActividadItinerario({
    required this.nombre,
    required this.horaInicio,
    required this.horaFin,
    required this.completada,
    this.descripcion, // Opcionales para no romper la creación de viajes vieja
    this.puntoReunion,
  });

  @override
  // Agregamos los nuevos campos a props para la comparación de BLoC
  List<Object?> get props => [
    nombre,
    horaInicio,
    completada,
    descripcion,
    puntoReunion,
  ];
}
