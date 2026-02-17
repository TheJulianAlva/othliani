import 'package:flutter/material.dart';

/// Tipos de resultados de búsqueda
enum SearchResultType { guide, tourist, trip }

/// Modelo para resultados de búsqueda global
class SearchResult {
  final String id;
  final String name;
  final SearchResultType type;
  final String subtitle;
  final IconData icon;
  final Color color;

  SearchResult._({
    required this.id,
    required this.name,
    required this.type,
    required this.subtitle,
    required this.icon,
    required this.color,
  });

  /// Constructor para guías
  factory SearchResult.guide({
    required String id,
    required String name,
    String? status,
    int? viajesAsignados,
    String? viajeEstado,
  }) {
    String subtitle = '';
    if (viajesAsignados != null && viajesAsignados > 0) {
      subtitle =
          '$viajesAsignados viaje${viajesAsignados > 1 ? 's' : ''} asignado${viajesAsignados > 1 ? 's' : ''}';
      if (viajeEstado != null) {
        subtitle += ' • $viajeEstado';
      }
    } else {
      subtitle = status ?? 'Disponible';
    }

    return SearchResult._(
      id: id,
      name: name,
      type: SearchResultType.guide,
      subtitle: subtitle,
      icon: Icons.person_pin,
      color: Colors.blue,
    );
  }

  /// Constructor para turistas
  factory SearchResult.tourist({
    required String id,
    required String name,
    String? viajeId,
    String? status,
  }) {
    return SearchResult._(
      id: id,
      name: name,
      type: SearchResultType.tourist,
      subtitle: status ?? 'Sin viaje asignado',
      icon: Icons.person,
      color: Colors.green,
    );
  }

  /// Constructor para viajes
  factory SearchResult.trip({
    required String id,
    required String destino,
    String? estado,
    int? turistas,
  }) {
    String subtitle = '';
    if (turistas != null) {
      subtitle = '$turistas turista${turistas > 1 ? 's' : ''}';
    }
    if (estado != null) {
      subtitle += subtitle.isEmpty ? estado : ' • $estado';
    }

    return SearchResult._(
      id: id,
      name: destino,
      type: SearchResultType.trip,
      subtitle: subtitle,
      icon: Icons.directions_bus,
      color: Colors.orange,
    );
  }

  String get typeLabel {
    switch (type) {
      case SearchResultType.guide:
        return 'GUÍA';
      case SearchResultType.tourist:
        return 'TURISTA';
      case SearchResultType.trip:
        return 'VIAJE';
    }
  }
}
