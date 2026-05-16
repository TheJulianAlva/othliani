import 'package:equatable/equatable.dart';

class Guia extends Equatable {
  final String id;
  final String nombre;
  final String status; // 'DISPONIBLE', 'EN_VIAJE', 'DESCANSO'
  final String rol;
  final int diasTrabajoMes;
  final double csat;
  final int totalReviews;
  final String? proxViaje;
  final List<String> idiomas;
  final List<String> especialidades;
  final double pagadoMes;
  final double saldoPendiente;
  final int viajesAsignados;

  const Guia({
    required this.id,
    required this.nombre,
    required this.status,
    this.rol = 'Guía',
    this.diasTrabajoMes = 0,
    this.csat = 0.0,
    this.totalReviews = 0,
    this.proxViaje,
    this.idiomas = const ['Español (Nativo)'],
    this.especialidades = const [],
    this.pagadoMes = 0.0,
    this.saldoPendiente = 0.0,
    this.viajesAsignados = 0,
  });

  @override
  List<Object?> get props => [
    id,
    nombre,
    status,
    rol,
    diasTrabajoMes,
    csat,
    totalReviews,
    proxViaje,
    idiomas,
    especialidades,
    pagadoMes,
    saldoPendiente,
    viajesAsignados,
  ];
}
