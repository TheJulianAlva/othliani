import 'package:equatable/equatable.dart';
import 'package:latlong2/latlong.dart';
import 'categoria_actividad.dart'; // 📸 Para incrustar snapshot en el JSON

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

  /// 📸 Snapshot de la categoría incrustado en el documento.
  /// Se guarda completo en el JSON para que el itinerario sea autónomo:
  /// aunque el catálogo en memoria se reinicie, la tarjeta se reconstruye
  /// desde estos datos sin necesidad de consultar ningún repositorio.
  final CategoriaActividad? categoriaSnapshot;

  const ActividadItinerario({
    required this.id,
    required this.titulo,
    required this.tipo,
    required this.horaInicio,
    required this.horaFin,
    this.categoriaSnapshot,
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

  ActividadItinerario copyWith({
    String? id,
    String? titulo,
    String? descripcion,
    DateTime? horaInicio,
    DateTime? horaFin,
    int? holguraMinutos,
    TipoActividad? tipo,
    LatLng? ubicacionCentral,
    double? radioGeocerca,
    List<LatLng>? poligonoGeocerca,
    String? urlFotoPuntoReunion,
    String? recomendaciones,
    String? imagenUrl,
    double? huellaCarbono,
    String? guiaResponsableId,
    CategoriaActividad? categoriaSnapshot,
  }) {
    return ActividadItinerario(
      id: id ?? this.id,
      titulo: titulo ?? this.titulo,
      descripcion: descripcion ?? this.descripcion,
      horaInicio: horaInicio ?? this.horaInicio,
      horaFin: horaFin ?? this.horaFin,
      holguraMinutos: holguraMinutos ?? this.holguraMinutos,
      tipo: tipo ?? this.tipo,
      ubicacionCentral: ubicacionCentral ?? this.ubicacionCentral,
      radioGeocerca: radioGeocerca ?? this.radioGeocerca,
      poligonoGeocerca: poligonoGeocerca ?? this.poligonoGeocerca,
      urlFotoPuntoReunion: urlFotoPuntoReunion ?? this.urlFotoPuntoReunion,
      recomendaciones: recomendaciones ?? this.recomendaciones,
      imagenUrl: imagenUrl ?? this.imagenUrl,
      huellaCarbono: huellaCarbono ?? this.huellaCarbono,
      guiaResponsableId: guiaResponsableId ?? this.guiaResponsableId,
      categoriaSnapshot: categoriaSnapshot ?? this.categoriaSnapshot,
    );
  }

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
      'tipo': tipo.index, // Legacy: índice del enum para backward compat
      'imagenUrl': imagenUrl,
      'lat': ubicacionCentral?.latitude,
      'lng': ubicacionCentral?.longitude,
      'recomendaciones': recomendaciones,
      // 📸 Snapshot completo de la categoría — el itinerario es un documento autónomo.
      // Si el catálogo en RAM se reinicia, la tarjeta se reconstruye desde aquí.
      if (categoriaSnapshot != null)
        'categoria': {
          'id': categoriaSnapshot!.id,
          'nombre': categoriaSnapshot!.nombre,
          'emoji': categoriaSnapshot!.emoji,
          'colorHex': categoriaSnapshot!.colorHex,
          'duracionDefaultMinutos': categoriaSnapshot!.duracionDefaultMinutos,
          'esPersonalizada': categoriaSnapshot!.esPersonalizada,
        },
    };
  }

  factory ActividadItinerario.fromJson(Map<String, dynamic> json) {
    // 📸 Intentar reconstruir la categoría desde el snapshot guardado en disco.
    // Si no existe (JSON antiguo), usar fallback desde el tipo legacy.
    CategoriaActividad? snapshot;
    if (json['categoria'] != null) {
      final c = json['categoria'] as Map<String, dynamic>;
      snapshot = CategoriaActividad(
        id: c['id'] as String,
        nombre: c['nombre'] as String,
        emoji: c['emoji'] as String,
        colorHex: (c['colorHex'] as String?) ?? '#2196F3',
        duracionDefaultMinutos: (c['duracionDefaultMinutos'] as int?) ?? 60,
        esPersonalizada: (c['esPersonalizada'] as bool?) ?? false,
      );
    }

    final tipo = TipoActividad.values[json['tipo'] as int];

    return ActividadItinerario(
      id: json['id'] as String,
      titulo: json['titulo'] as String,
      descripcion: json['descripcion'] as String? ?? '',
      horaInicio: DateTime.parse(json['horaInicio'] as String),
      horaFin: DateTime.parse(json['horaFin'] as String),
      holguraMinutos: json['holguraMinutos'] as int? ?? 15,
      tipo: tipo,
      // Si hay snapshot lo usamos; si no, derivamos desde el tipo legacy.
      categoriaSnapshot: snapshot ?? CategoriaActividad.fromTipoActividad(tipo),
      imagenUrl: json['imagenUrl'] as String?,
      ubicacionCentral:
          (json['lat'] != null && json['lng'] != null)
              ? LatLng(json['lat'] as double, json['lng'] as double)
              : null,
      recomendaciones: json['recomendaciones'] as String? ?? '',
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
    categoriaSnapshot,
  ];
}
