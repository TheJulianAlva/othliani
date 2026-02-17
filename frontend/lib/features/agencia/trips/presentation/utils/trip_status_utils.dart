import 'package:flutter/material.dart';

/// Información de estado de un viaje
class TripStatusInfo {
  final String text;
  final Color color;
  final IconData icon;

  const TripStatusInfo({
    required this.text,
    required this.color,
    required this.icon,
  });
}

/// Obtiene información visual del estado de un viaje
TripStatusInfo getTripStatusInfo(String estado) {
  switch (estado.toLowerCase()) {
    case 'planificado':
      return const TripStatusInfo(
        text: 'PLANIFICADO',
        color: Colors.blue,
        icon: Icons.event_note,
      );
    case 'en_curso':
    case 'en curso':
      return const TripStatusInfo(
        text: 'EN CURSO',
        color: Colors.green,
        icon: Icons.play_circle_filled,
      );
    case 'completado':
      return const TripStatusInfo(
        text: 'COMPLETADO',
        color: Colors.grey,
        icon: Icons.check_circle,
      );
    case 'cancelado':
      return const TripStatusInfo(
        text: 'CANCELADO',
        color: Colors.red,
        icon: Icons.cancel,
      );
    case 'pausado':
      return const TripStatusInfo(
        text: 'PAUSADO',
        color: Colors.orange,
        icon: Icons.pause_circle_filled,
      );
    default:
      return const TripStatusInfo(
        text: 'DESCONOCIDO',
        color: Colors.grey,
        icon: Icons.help_outline,
      );
  }
}
