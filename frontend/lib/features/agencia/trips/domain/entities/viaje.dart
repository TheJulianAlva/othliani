import 'package:equatable/equatable.dart';
import 'actividad_itinerario.dart';

// ─────────────────────────────────────────────────────────────────────────────
// ContactoConfianza — sucesores para el modelo B2C (Personal)
// ─────────────────────────────────────────────────────────────────────────────
class ContactoConfianza {
  final String nombre;
  final String telefono;

  const ContactoConfianza({required this.nombre, required this.telefono});

  Map<String, dynamic> toJson() => {'nombre': nombre, 'telefono': telefono};

  static ContactoConfianza fromJson(Map<String, dynamic> json) =>
      ContactoConfianza(
        nombre: json['nombre'] as String? ?? '',
        telefono: json['telefono'] as String? ?? '',
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// TipoViaje — distingue el modelo de negocio del viaje (B2B vs. B2C)
//
// Determina QUIÉN recibe la Sucesión de Mando cuando el guía activa SOS:
//   agencia  → notificación Push al Co-Guía + dashboard de la agencia
//   personal → SMS/link de emergencia al Contacto de Confianza
// ─────────────────────────────────────────────────────────────────────────────
enum TipoViaje {
  agencia, // B2B: guia asignado por una agencia, hay co-guías disponibles
  personal; // B2C: guía independiente, solo con contactos de confianza remotos

  String get etiqueta => switch (this) {
    TipoViaje.agencia => 'Agencia (B2B)',
    TipoViaje.personal => 'Personal  (B2C)',
  };

  String toJson() => name;
  static TipoViaje fromJson(String? v) => TipoViaje.values.firstWhere(
    (e) => e.name == v,
    orElse: () => TipoViaje.agencia,
  );
}

//
// El radio se usa en CalculateRiskUseCase y MapaMonitoreoWidget para:
//   - Calcular si un turista salió de la zona segura
//   - Dibujar el círculo de geocerca en el mapa
// ─────────────────────────────────────────────────────────────────────────────
enum TipoGrupo {
  escolar, // Riesgo Alto : 25 m  — niños que se pierden fácil
  familiar, // Riesgo Medio: 50 m  — familias con ritmos mixtos
  aventuraAdultos; // Riesgo Bajo : 150 m — adultos independientes

  /// Radio de geocerca en metros.
  double get radioMetros => switch (this) {
    TipoGrupo.escolar => 25.0,
    TipoGrupo.familiar => 50.0,
    TipoGrupo.aventuraAdultos => 150.0,
  };

  /// Etiqueta legible para la UI.
  String get etiqueta => switch (this) {
    TipoGrupo.escolar => 'Escolar (25 m)',
    TipoGrupo.familiar => 'Familiar (50 m)',
    TipoGrupo.aventuraAdultos => 'Mochileros (150 m)',
  };

  String toJson() => name;
  static TipoGrupo fromJson(String? v) => TipoGrupo.values.firstWhere(
    (e) => e.name == v,
    orElse: () => TipoGrupo.familiar,
  );
}

class Viaje extends Equatable {
  final String id;
  final String destino;
  final String estado; // 'EN_CURSO', 'PROGRAMADO', etc.
  final DateTime fechaInicio; // Fecha de inicio del viaje
  final DateTime fechaFin; // Fecha de fin del viaje
  final int turistas;
  final double latitud; // Vital para el mapa
  final double longitud;

  // Campos operativos para tarjetas enriquecidas
  final String guiaNombre;
  final String horaInicio; // Ej: "08:30 AM"
  final int alertasActivas;

  /// Tipo de grupo del viaje — determina el radio de geocerca dinámica.
  final TipoGrupo tipoGrupo;

  // ── Sucesión de Mando ─────────────────────────────────────────────────────────

  /// Modelo del viaje (B2B vs B2C) — decide el protocolo de sucesión.
  final TipoViaje tipoViaje;

  /// IDs de co-guías (B2B). El primero es el sucesor inmediato.
  final List<String> coGuiasIds;

  /// Contactos de confianza remotos (B2C — familia/amigos).
  final List<ContactoConfianza> contactosConfianza;

  // ── Itinerario ──────────────────────────────────────────────────────────────
  final List<ActividadItinerario> itinerario;

  const Viaje({
    required this.id,
    required this.destino,
    required this.estado,
    required this.fechaInicio,
    required this.fechaFin,
    required this.turistas,
    required this.latitud,
    required this.longitud,
    this.tipoGrupo = TipoGrupo.familiar,
    this.tipoViaje = TipoViaje.agencia, // default no-breaking
    this.coGuiasIds = const [],
    this.contactosConfianza = const [],
    this.guiaNombre = 'Sin asignar',
    this.horaInicio = '--:--',
    this.alertasActivas = 0,
    this.itinerario = const [],
  });

  // Helper para saber la duración (Ej: "4 horas" o "3 días")
  String get duracionLabel {
    final diff = fechaFin.difference(fechaInicio);
    if (diff.inHours < 24) {
      return "${diff.inHours} horas";
    } else {
      return "${diff.inDays} días";
    }
  }

  Viaje copyWith({
    String? id,
    String? destino,
    String? estado,
    DateTime? fechaInicio,
    DateTime? fechaFin,
    int? turistas,
    double? latitud,
    double? longitud,
    TipoGrupo? tipoGrupo,
    TipoViaje? tipoViaje,
    List<String>? coGuiasIds,
    List<ContactoConfianza>? contactosConfianza,
    String? guiaNombre,
    String? horaInicio,
    int? alertasActivas,
    List<ActividadItinerario>? itinerario,
  }) {
    return Viaje(
      id: id ?? this.id,
      destino: destino ?? this.destino,
      estado: estado ?? this.estado,
      fechaInicio: fechaInicio ?? this.fechaInicio,
      fechaFin: fechaFin ?? this.fechaFin,
      turistas: turistas ?? this.turistas,
      latitud: latitud ?? this.latitud,
      longitud: longitud ?? this.longitud,
      tipoGrupo: tipoGrupo ?? this.tipoGrupo,
      tipoViaje: tipoViaje ?? this.tipoViaje,
      coGuiasIds: coGuiasIds ?? this.coGuiasIds,
      contactosConfianza: contactosConfianza ?? this.contactosConfianza,
      guiaNombre: guiaNombre ?? this.guiaNombre,
      horaInicio: horaInicio ?? this.horaInicio,
      alertasActivas: alertasActivas ?? this.alertasActivas,
      itinerario: itinerario ?? this.itinerario,
    );
  }

  // Equatable nos permite comparar si dos viajes son iguales por sus datos
  @override
  List<Object?> get props => [
    id,
    destino,
    estado,
    fechaInicio,
    fechaFin,
    turistas,
    latitud,
    longitud,
    tipoGrupo,
    tipoViaje,
    coGuiasIds,
    contactosConfianza,
    guiaNombre,
    horaInicio,
    alertasActivas,
    itinerario,
  ];
}
