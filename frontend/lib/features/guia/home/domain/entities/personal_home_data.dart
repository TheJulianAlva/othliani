import 'package:equatable/equatable.dart';

class ContactoEmergencia extends Equatable {
  final String nombre;
  final String relacion;
  final String telefono;

  const ContactoEmergencia({
    required this.nombre,
    required this.relacion,
    required this.telefono,
  });

  @override
  List<Object?> get props => [nombre, telefono];
}

class ActividadItinerario extends Equatable {
  final String nombre;
  final String horaInicio;
  final String horaFin;
  final bool completada;

  const ActividadItinerario({
    required this.nombre,
    required this.horaInicio,
    required this.horaFin,
    required this.completada,
  });

  @override
  List<Object?> get props => [nombre, horaInicio, completada];
}

class PersonalHomeData extends Equatable {
  final String nombreGuia;
  final String nombreViaje;
  final String destino;
  final String horaInicio;
  final int participantes;
  final bool viajeActivo;
  final int geocercaMetros;
  final double kmRecorridos;
  final int minActivos;
  final double altitudActualM;
  final double huellaCarbono;
  final List<ContactoEmergencia> contactos;
  final List<ActividadItinerario> actividades;

  const PersonalHomeData({
    required this.nombreGuia,
    required this.nombreViaje,
    required this.destino,
    required this.horaInicio,
    required this.participantes,
    this.viajeActivo = true,
    this.geocercaMetros = 200,
    this.kmRecorridos = 0,
    this.minActivos = 0,
    this.altitudActualM = 0,
    this.huellaCarbono = 0,
    required this.contactos,
    required this.actividades,
  });

  @override
  List<Object?> get props => [
    nombreGuia,
    nombreViaje,
    destino,
    geocercaMetros,
    viajeActivo,
  ];
}
