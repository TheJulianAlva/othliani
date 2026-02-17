import 'package:equatable/equatable.dart';
import 'package:latlong2/latlong.dart';

enum TipoActividad {
  traslado, // Monitoreo de ruta (Velocidad, desvío)
  visitaGuiada, // Geocerca activa
  checkIn, // Punto específico
  tiempoLibre, // PRIVACIDAD TOTAL (GPS OFF)
  comida, // Holgura amplia
}

class ActividadItinerario extends Equatable {
  final String id;
  final String titulo;
  final String descripcion;

  //  Bloques horarios específicos, no "día completo"
  final DateTime horaInicio;
  final DateTime horaFin;

  // [cite: 12] Margen de tolerancia antes de alerta
  final int holguraMinutos;

  final TipoActividad tipo;

  // [cite: 16, 17] Soporte para Punto (Radio) o Polígono (Parques)
  final LatLng? ubicacionCentral;
  final double radioGeocerca;
  final List<LatLng>? poligonoGeocerca;

  // [cite: 30] Referencia visual del punto de reunión
  final String? urlFotoPuntoReunion;
  final String recomendaciones; // Ej: "Llevar botas"

  // [cite: 45] Innovación: Turismo Regenerativo
  final double huellaCarbono; // kg CO2 estimado

  final String? guiaResponsableId;

  const ActividadItinerario({
    required this.id,
    required this.titulo,
    required this.tipo,
    required this.horaInicio,
    required this.horaFin,
    this.descripcion = '',
    this.holguraMinutos = 30,
    this.ubicacionCentral,
    this.radioGeocerca = 100.0,
    this.poligonoGeocerca,
    this.urlFotoPuntoReunion,
    this.recomendaciones = '',
    this.huellaCarbono = 0.0,
    this.guiaResponsableId,
  });

  // Lógica de Negocio: ¿El sistema debe rastrear?
  bool get esMonitoreable => tipo != TipoActividad.tiempoLibre;

  @override
  List<Object?> get props => [
    id,
    titulo,
    tipo,
    horaInicio,
    horaFin,
    guiaResponsableId,
  ];
}
