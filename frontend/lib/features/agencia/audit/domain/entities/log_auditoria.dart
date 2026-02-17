import 'package:equatable/equatable.dart';

class LogAuditoria extends Equatable {
  final String id;
  final DateTime fecha;
  final String nivel; // 'CRITICO', 'ADVERTENCIA', 'INFO'
  final String actor; // Quién lo hizo (Ej: 'Sys_Algorithm', 'Guía: Marcos')
  final String accion; // Qué pasó
  final String ip; // Dato técnico para auditoría (Simulado)
  final Map<String, dynamic>? metadata; // NUEVO: Para datos técnicos extra
  final String? relatedRoute; // NUEVO: Para redirigir (ej. '/viajes/204')

  const LogAuditoria({
    required this.id,
    required this.fecha,
    required this.nivel,
    required this.actor,
    required this.accion,
    required this.ip,
    this.metadata,
    this.relatedRoute,
  });

  @override
  List<Object?> get props => [
    id,
    fecha,
    nivel,
    actor,
    accion,
    ip,
    metadata,
    relatedRoute,
  ];
}
