import 'package:equatable/equatable.dart';

enum TipoIncidente {
  alertaTuristaAlejado,
  alertaMedica,
  sosGuiaActivado,
  sosGuiaCancelado,
  incidenteResuelto,
  sistemaIniciado,
  sistemaFinalizado,
  accionGuia,
  sincronizacion,
  sosManual,
}

extension TipoIncidenteExtension on TipoIncidente {
  String get etiqueta {
    switch (this) {
      case TipoIncidente.alertaTuristaAlejado:
        return 'Alerta Turista';
      case TipoIncidente.alertaMedica:
        return 'Alerta Médica';
      case TipoIncidente.sosGuiaActivado:
        return 'SOS Activado';
      case TipoIncidente.sosGuiaCancelado:
        return 'SOS Cancelado';
      case TipoIncidente.incidenteResuelto:
        return 'Resuelto';
      case TipoIncidente.sistemaIniciado:
        return 'Inicio Prot.';
      case TipoIncidente.sistemaFinalizado:
        return 'Fin Prot.';
      case TipoIncidente.accionGuia:
        return 'Acción Guía';
      case TipoIncidente.sincronizacion:
        return 'Sincronización';
      case TipoIncidente.sosManual:
        return 'SOS Manual';
    }
  }
}

class IncidentLog extends Equatable {
  final String id; // UUID
  final DateTime timestamp; // Hora exacta del evento
  final TipoIncidente tipo;
  final String descripcion;
  final double latitud;
  final double longitud;
  final bool isSynced; // ¿Ya se mandó al servidor de la agencia?

  const IncidentLog({
    required this.id,
    required this.timestamp,
    required this.tipo,
    required this.descripcion,
    required this.latitud,
    required this.longitud,
    this.isSynced = false,
  });

  // Adaptadores de compatibilidad para la antigua Bitácora UI
  String get prioridad {
    if (descripcion.contains('[CRITICA]')) return 'CRITICA';
    if (descripcion.contains('[ALTA]')) return 'ALTA';
    if (descripcion.contains('[INFO]')) return 'INFO';
    return 'ESTANDAR';
  }

  String get coordenadas => latitud != 0 ? '$latitud, $longitud' : '';

  // Para guardar en la memoria del teléfono
  Map<String, dynamic> toJson() => {
    'id': id,
    'timestamp': timestamp.toIso8601String(),
    'tipo': tipo.index,
    'descripcion': descripcion,
    'latitud': latitud,
    'longitud': longitud,
    'isSynced': isSynced,
  };

  factory IncidentLog.fromJson(Map<String, dynamic> json) => IncidentLog(
    id: json['id'],
    timestamp: DateTime.parse(json['timestamp']),
    tipo: TipoIncidente.values[json['tipo']],
    descripcion: json['descripcion'],
    latitud: json['latitud'],
    longitud: json['longitud'],
    isSynced: json['isSynced'] ?? false,
  );

  @override
  List<Object?> get props => [id, timestamp, tipo, descripcion, isSynced];
}
