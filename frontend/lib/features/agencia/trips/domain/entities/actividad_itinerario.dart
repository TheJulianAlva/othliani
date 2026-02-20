import 'package:equatable/equatable.dart';
import 'package:latlong2/latlong.dart';

enum TipoActividad {
  traslado, // Monitoreo de ruta (Velocidad, desvío)
  visitaGuiada, // Geocerca activa
  checkIn, // Punto específico
  tiempoLibre, // PRIVACIDAD TOTAL (GPS OFF)
  comida, // Holgura amplia
  hospedaje, // Hotel/alojamiento
  aventura, // Actividades de aventura
  cultura, // Museos, sitios históricos
  otro, // Otros tipos
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

  // ✨ FASE 5: Imagen visual de la actividad (seleccionada desde Pexels)
  final String? imagenUrl;

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
    this.imagenUrl,
  });

  /*
   * ✨ FASE 13: SERIALIZACIÓN PARA PERSISTENCIA LOCAL
   * Necesaria para guardar borradores en SharedPreferences
   */
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'titulo': titulo,
      'descripcion': descripcion,
      'horaInicio': horaInicio.toIso8601String(),
      'horaFin': horaFin.toIso8601String(),
      'holguraMinutos': holguraMinutos,
      'tipo': tipo.index, // Guardamos índice del Enum
      'imagenUrl': imagenUrl,
      'lat': ubicacionCentral?.latitude,
      'lng': ubicacionCentral?.longitude,
      'recomendaciones': recomendaciones,
      // Nota: Si necesitamos guardar polígonos o geocercas complejas,
      // habría que serializarlas también. Por ahora MVP.
    };
  }

  factory ActividadItinerario.fromJson(Map<String, dynamic> json) {
    return ActividadItinerario(
      id: json['id'],
      titulo: json['titulo'],
      descripcion: json['descripcion'] ?? '',
      horaInicio: DateTime.parse(json['horaInicio']),
      horaFin: DateTime.parse(json['horaFin']),
      holguraMinutos: json['holguraMinutos'] ?? 15,
      tipo: TipoActividad.values[json['tipo']],
      imagenUrl: json['imagenUrl'],
      ubicacionCentral:
          (json['lat'] != null && json['lng'] != null)
              ? LatLng(json['lat'], json['lng'])
              : null,
      recomendaciones: json['recomendaciones'] ?? '',
      // Valores por defecto para campos complejos no persistidos en MVP
      radioGeocerca: 50.0,
      poligonoGeocerca: const [],
      urlFotoPuntoReunion: null,
      huellaCarbono: 0.0,
      guiaResponsableId: null,
    );
  }

  // Lógica de Negocio: ¿El sistema debe rastrear?
  bool get esMonitoreable => tipo != TipoActividad.tiempoLibre;

  // Getter para duración en minutos
  int get duracionMinutos => horaFin.difference(horaInicio).inMinutes;

  @override
  List<Object?> get props => [
    id,
    titulo,
    tipo,
    horaInicio,
    horaFin,
    guiaResponsableId,
    imagenUrl,
  ];
}
