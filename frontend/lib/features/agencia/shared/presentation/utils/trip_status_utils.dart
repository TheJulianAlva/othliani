import 'package:flutter/material.dart';

class TripStatusInfo {
  final String label;
  final Color color;
  final IconData icon;

  const TripStatusInfo({
    required this.label,
    required this.color,
    required this.icon,
  });
}

TripStatusInfo getTripStatusInfo(String status) {
  switch (status) {
    case 'EN_CURSO':
      return const TripStatusInfo(
        label: 'En Ruta',
        color: Colors.green,
        icon: Icons.directions_bus,
      );
    case 'PROGRAMADO':
      return const TripStatusInfo(
        label: 'Próximo',
        color: Colors.blue,
        icon: Icons.calendar_today,
      );
    case 'FINALIZADO':
      return const TripStatusInfo(
        label: 'Completado',
        color: Colors.grey,
        icon: Icons.flag,
      );
    default:
      return const TripStatusInfo(
        label: 'Desconocido',
        color: Colors.grey,
        icon: Icons.help_outline,
      );
  }
}
