import 'package:frontend/features/agencia/users/domain/entities/turista.dart';

/// Model de [Turista] para la capa de datos del feature Guía.
///
/// Extiende la entidad base y agrega el factory [fromJson] para cuando
/// se conecte con el API real de OhtliAni.
class TuristaModel extends Turista {
  const TuristaModel({
    required super.id,
    required super.nombre,
    required super.viajeId,
    required super.status,
    required super.bateria,
    required super.enCampo,
    super.vulnerabilidad,
    super.tipoSangre,
    super.alergias,
    super.condicionesMedicas,
    super.contactoEmergenciaNombre,
    super.contactoEmergenciaParentesco,
    super.contactoEmergenciaTelefono,
    super.appInstalada,
    super.pagoCompletado,
    super.responsivaFirmada,
    super.incidentesCount,
    super.asistio,
    super.notasGuia,
    super.calificacion,
  });

  /// Factory para convertir el JSON del API → entidad Turista.
  factory TuristaModel.fromJson(Map<String, dynamic> json) {
    return TuristaModel(
      id: json['id'],
      nombre: json['nombre'],
      viajeId: json['viaje_id'],
      status: json['status'] ?? 'OK',
      bateria: (json['bateria'] as num?)?.toDouble() ?? 1.0,
      enCampo: json['en_campo'] ?? false,
      vulnerabilidad: NivelVulnerabilidad.fromJson(json['vulnerabilidad']),
      tipoSangre: json['tipo_sangre'],
      alergias: json['alergias'],
      condicionesMedicas: json['condiciones_medicas'],
      contactoEmergenciaNombre: json['contacto_emergencia_nombre'],
      contactoEmergenciaParentesco: json['contacto_emergencia_parentesco'],
      contactoEmergenciaTelefono: json['contacto_emergencia_telefono'],
      appInstalada: json['app_instalada'] ?? false,
      pagoCompletado: json['pago_completado'] ?? false,
      responsivaFirmada: json['responsiva_firmada'] ?? false,
      incidentesCount: json['incidentes_count'],
      asistio: json['asistio'],
      notasGuia: json['notas_guia'],
      calificacion: (json['calificacion'] as num?)?.toDouble(),
    );
  }
}
