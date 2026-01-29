import 'package:equatable/equatable.dart';

class Alerta extends Equatable {
  final String id;
  final String viajeId;
  final String nombreTurista;
  final String tipo; // 'PANICO', 'LEJANIA', 'BATERIA_BAJA', etc.
  final DateTime hora;
  final bool esCritica;
  final String mensaje;

  const Alerta({
    required this.id,
    required this.viajeId,
    required this.nombreTurista,
    required this.tipo,
    required this.hora,
    required this.esCritica,
    required this.mensaje,
  });

  @override
  List<Object?> get props => [
    id,
    viajeId,
    nombreTurista,
    tipo,
    hora,
    esCritica,
    mensaje,
  ];
}
