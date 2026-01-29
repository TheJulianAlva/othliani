import 'package:equatable/equatable.dart';

class Turista extends Equatable {
  final String id;
  final String nombre;
  final String viajeId; // Vinculado a un viaje específico
  final String status; // 'OK', 'ADVERTENCIA', 'SOS', 'OFFLINE'
  final double bateria; // 0.0 a 1.0
  final bool enCampo; // Si está actualmente en una expedición

  const Turista({
    required this.id,
    required this.nombre,
    required this.viajeId,
    required this.status,
    required this.bateria,
    required this.enCampo,
  });

  @override
  List<Object?> get props => [id, nombre, viajeId, status, bateria, enCampo];
}
