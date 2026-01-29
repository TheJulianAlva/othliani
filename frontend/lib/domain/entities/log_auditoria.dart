import 'package:equatable/equatable.dart';

class LogAuditoria extends Equatable {
  final String id;
  final DateTime fecha;
  final String nivel; // 'CRT' (Crítico), 'INF' (Info), 'WRN' (Warning)
  final String actor; // Quién lo hizo (Ej: 'Sys_Algorithm')
  final String accion; // Qué hizo (Ej: 'Detectado Alejamiento')

  const LogAuditoria({
    required this.id,
    required this.fecha,
    required this.nivel,
    required this.actor,
    required this.accion,
  });

  @override
  List<Object?> get props => [id, fecha, nivel, actor, accion];
}
