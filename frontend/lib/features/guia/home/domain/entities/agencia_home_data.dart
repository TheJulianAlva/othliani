import 'package:equatable/equatable.dart';
import 'package:frontend/features/guia/trips/domain/entities/actividad_itinerario.dart';
import 'package:frontend/features/agencia/users/domain/entities/turista.dart';

enum EstadoParticipante { sincronizado, offline, alerta }

class Participante extends Equatable {
  final String nombre;
  final EstadoParticipante estado;

  const Participante({required this.nombre, required this.estado});

  @override
  List<Object?> get props => [nombre, estado];
}

class AlertaHistorial extends Equatable {
  final String descripcion;
  final String hora;

  const AlertaHistorial({required this.descripcion, required this.hora});

  @override
  List<Object?> get props => [descripcion, hora];
}

class AgenciaHomeData extends Equatable {
  final String nombreViaje;
  final String folio;
  final String destino;
  final int totalParticipantes;
  final List<Participante> participantes;
  final List<AlertaHistorial> historialAlertas;
  final String geocercaRadio;
  final List<ActividadItinerario> actividades;
  final List<Turista> listaTuristas;

  const AgenciaHomeData({
    required this.nombreViaje,
    required this.folio,
    required this.destino,
    required this.totalParticipantes,
    required this.participantes,
    required this.historialAlertas,
    required this.geocercaRadio,
    this.actividades = const [],
    this.listaTuristas = const [],
  });

  @override
  List<Object?> get props => [
    nombreViaje,
    folio,
    destino,
    totalParticipantes,
    participantes,
    historialAlertas,
    geocercaRadio,
    actividades,
    listaTuristas,
  ];
}
