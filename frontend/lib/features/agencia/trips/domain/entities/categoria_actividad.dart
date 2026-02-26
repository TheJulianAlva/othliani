import 'actividad_itinerario.dart'; // Para TipoActividad

/// Modelo de categoría de actividad para el itinerary builder.
/// Reemplaza el enum [TipoActividad] con un modelo dinámico que las agencias
/// pueden personalizar (nombre, emoji, color, duración).
class CategoriaActividad {
  final String id;
  final String nombre;
  final String emoji;
  final String colorHex;
  final int duracionDefaultMinutos;
  final bool esPersonalizada;

  const CategoriaActividad({
    required this.id,
    required this.nombre,
    required this.emoji,
    this.colorHex = '#2196F3',
    this.duracionDefaultMinutos = 60,
    this.esPersonalizada = false,
  });

  // ─── Compatibilidad con el enum legacy ────────────────────────────────────

  /// Convierte un [TipoActividad] a su [CategoriaActividad] equivalente.
  factory CategoriaActividad.fromTipoActividad(TipoActividad tipo) {
    return defaults().firstWhere(
      (c) => c.id == 'sys_${tipo.name}',
      orElse: () => defaults().first,
    );
  }

  // ─── Categorías del sistema (los 6 bloques del toolbox original) ──────────

  static List<CategoriaActividad> defaults() => [
    const CategoriaActividad(
      id: 'sys_hospedaje',
      nombre: 'Hospedaje',
      emoji: '🏨',
      colorHex: '#9C27B0',
      duracionDefaultMinutos: 30,
    ),
    const CategoriaActividad(
      id: 'sys_comida',
      nombre: 'Alimentos',
      emoji: '🍽️',
      colorHex: '#FF9800',
      duracionDefaultMinutos: 90,
    ),
    const CategoriaActividad(
      id: 'sys_traslado',
      nombre: 'Traslado',
      emoji: '🚌',
      colorHex: '#2196F3',
      duracionDefaultMinutos: 60,
    ),
    const CategoriaActividad(
      id: 'sys_cultura',
      nombre: 'Cultura / Museo',
      emoji: '🏛️',
      colorHex: '#795548',
      duracionDefaultMinutos: 90,
    ),
    const CategoriaActividad(
      id: 'sys_aventura',
      nombre: 'Aventura',
      emoji: '🧗',
      colorHex: '#4CAF50',
      duracionDefaultMinutos: 90,
    ),
    const CategoriaActividad(
      id: 'sys_tiempoLibre',
      nombre: 'Tiempo Libre',
      emoji: '🏖️',
      colorHex: '#009688',
      duracionDefaultMinutos: 60,
    ),
  ];

  /// Retorna el [TipoActividad] equivalente para compatibilidad con código legacy.
  TipoActividad toTipoActividad() {
    switch (id) {
      case 'sys_hospedaje':
        return TipoActividad.hospedaje;
      case 'sys_comida':
        return TipoActividad.comida;
      case 'sys_traslado':
        return TipoActividad.traslado;
      case 'sys_cultura':
        return TipoActividad.cultura;
      case 'sys_aventura':
        return TipoActividad.aventura;
      case 'sys_tiempoLibre':
        return TipoActividad.tiempoLibre;
      default:
        return TipoActividad.otro; // Categorías personalizadas
    }
  }

  // ─── Serialización ────────────────────────────────────────────────────────

  Map<String, dynamic> toJson() => {
    'id': id,
    'nombre': nombre,
    'emoji': emoji,
    'colorHex': colorHex,
    'duracionDefaultMinutos': duracionDefaultMinutos,
    'esPersonalizada': esPersonalizada,
  };

  factory CategoriaActividad.fromJson(Map<String, dynamic> json) =>
      CategoriaActividad(
        id: json['id'] as String,
        nombre: json['nombre'] as String,
        emoji: json['emoji'] as String,
        colorHex: json['colorHex'] as String? ?? '#2196F3',
        duracionDefaultMinutos: json['duracionDefaultMinutos'] as int? ?? 60,
        esPersonalizada: json['esPersonalizada'] as bool? ?? false,
      );

  @override
  bool operator ==(Object other) =>
      other is CategoriaActividad && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
