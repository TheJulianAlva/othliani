import 'package:equatable/equatable.dart';

class Guia extends Equatable {
  final String id;
  final String nombre;
  final String status; // 'ONLINE', 'OFFLINE', 'EN_RUTA'
  final int viajesAsignados;

  const Guia({
    required this.id,
    required this.nombre,
    required this.status,
    required this.viajesAsignados,
  });

  @override
  List<Object?> get props => [id, nombre, status, viajesAsignados];
}
