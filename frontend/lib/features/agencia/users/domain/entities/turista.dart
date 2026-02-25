import 'package:equatable/equatable.dart';

// ─────────────────────────────────────────────────────────────────────────────
// NivelVulnerabilidad — clasifica el perfil de riesgo del turista
//
// estandar : adulto sin condiciones especiales (respuesta push + pantalla naranja)
// critica  : menor de edad, persona con discapacidad (alarma inmediata, rojo
//            parpadeante, llamada automática si no se cancela en 5 s)
// ─────────────────────────────────────────────────────────────────────────────
enum NivelVulnerabilidad {
  estandar,
  critica;

  String toJson() => name;

  static NivelVulnerabilidad fromJson(String? value) =>
      NivelVulnerabilidad.values.firstWhere(
        (e) => e.name == value,
        orElse: () => NivelVulnerabilidad.estandar,
      );

  /// Etiqueta legible para la UI y los logs de auditoría.
  String get etiqueta => switch (this) {
    NivelVulnerabilidad.estandar => 'Estándar',
    NivelVulnerabilidad.critica => 'Prioridad Crítica',
  };

  /// Ícono representativo para el panel de monitoreo.
  String get iconSemantic => switch (this) {
    NivelVulnerabilidad.estandar => 'person',
    NivelVulnerabilidad.critica => 'child_care',
  };
}

class Turista extends Equatable {
  final String id;
  final String nombre;
  final String viajeId; // Vinculado a un viaje específico
  final String status; // 'OK', 'ADVERTENCIA', 'SOS', 'OFFLINE'
  final double bateria; // 0.0 a 1.0
  final bool enCampo; // Si está actualmente en una expedición

  // --- Campos de Seguridad y Vulnerabilidad ---
  /// Clasifica al turista según su nivel de riesgo para el sistema de alertas.
  /// Determina la intensidad de la alarma (visual, háptica y escalamiento automático).
  final NivelVulnerabilidad vulnerabilidad;

  // --- Campos para Vista de Logística (PROGRAMADO) ---
  final String? tipoSangre; // Ej: "O+", "A-"
  final String? alergias; // Ej: "Penicilina, Nueces"
  final String? condicionesMedicas; // Ej: "Asma"
  final String? contactoEmergenciaNombre; // Ej: "Pedro Gómez"
  final String? contactoEmergenciaParentesco; // Ej: "Padre"
  final String? contactoEmergenciaTelefono; // Ej: "+52 55 9876 5432"
  final bool appInstalada; // ¿Ya descargó la app?
  final bool pagoCompletado; // ¿Pagó el viaje?
  final bool responsivaFirmada; // ¿Firmó la responsiva?

  // --- Campos para Vista de Auditoría (FINALIZADO) ---
  final int? incidentesCount; // Número de incidentes durante el viaje
  final bool? asistio; // ¿Se presentó al viaje?
  final String? notasGuia; // Comentarios del guía
  final double? calificacion; // Calificación del turista (0-5)

  const Turista({
    required this.id,
    required this.nombre,
    required this.viajeId,
    required this.status,
    required this.bateria,
    required this.enCampo,
    this.vulnerabilidad = NivelVulnerabilidad.estandar, // no-breaking default
    // Campos opcionales para logística
    this.tipoSangre,
    this.alergias,
    this.condicionesMedicas,
    this.contactoEmergenciaNombre,
    this.contactoEmergenciaParentesco,
    this.contactoEmergenciaTelefono,
    this.appInstalada = false,
    this.pagoCompletado = false,
    this.responsivaFirmada = false,
    // Campos opcionales para auditoría
    this.incidentesCount,
    this.asistio,
    this.notasGuia,
    this.calificacion,
  });

  @override
  List<Object?> get props => [
    id,
    nombre,
    viajeId,
    status,
    bateria,
    enCampo,
    vulnerabilidad,
    tipoSangre,
    alergias,
    condicionesMedicas,
    contactoEmergenciaNombre,
    contactoEmergenciaParentesco,
    contactoEmergenciaTelefono,
    appInstalada,
    pagoCompletado,
    responsivaFirmada,
    incidentesCount,
    asistio,
    notasGuia,
    calificacion,
  ];
}
