import 'package:flutter/material.dart';

enum SearchResultType { guide, tourist, trip }

class SearchResult {
  final SearchResultType type;
  final String id;
  final String name;
  final String subtitle;
  final IconData icon;
  final Color color;

  const SearchResult({
    required this.type,
    required this.id,
    required this.name,
    required this.subtitle,
    required this.icon,
    required this.color,
  });

  // Factory constructors for each type
  factory SearchResult.guide({
    required String id,
    required String name,
    required String status,
    required int viajesAsignados,
  }) {
    String statusText =
        status == 'EN_RUTA'
            ? 'En ruta'
            : status == 'ONLINE'
            ? 'Online'
            : 'Offline';
    return SearchResult(
      type: SearchResultType.guide,
      id: id,
      name: name,
      subtitle:
          '$statusText • $viajesAsignados ${viajesAsignados == 1 ? 'viaje' : 'viajes'}',
      icon: Icons.person_pin,
      color: Colors.blue,
    );
  }

  factory SearchResult.tourist({
    required String id,
    required String name,
    required String viajeId,
    required String status,
  }) {
    String statusText =
        status == 'SOS'
            ? 'SOS activo'
            : status == 'OFFLINE'
            ? 'Sin conexión'
            : 'OK';
    return SearchResult(
      type: SearchResultType.tourist,
      id: id,
      name: name,
      subtitle: 'Viaje #$viajeId • $statusText',
      icon: Icons.person,
      color: Colors.green,
    );
  }

  factory SearchResult.trip({
    required String id,
    required String destino,
    required String estado,
    required int turistas,
  }) {
    String estadoText =
        estado == 'EN_CURSO'
            ? 'En curso'
            : estado == 'PROGRAMADO'
            ? 'Programado'
            : 'Finalizado';
    return SearchResult(
      type: SearchResultType.trip,
      id: id,
      name: 'Viaje #$id',
      subtitle: '$destino • $estadoText • $turistas pax',
      icon: Icons.directions_bus,
      color: Colors.orange,
    );
  }

  String get typeLabel {
    switch (type) {
      case SearchResultType.guide:
        return 'Guía';
      case SearchResultType.tourist:
        return 'Turista';
      case SearchResultType.trip:
        return 'Viaje';
    }
  }

  @override
  String toString() => name;
}
