import 'package:flutter/material.dart';

/// Información de estilo para estados de viajes
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

/// Obtiene la información de estilo para un estado de viaje
///
/// Estados soportados:
/// - EN_CURSO: "En Ruta" (verde + sensor icon)
/// - PROGRAMADO: "Próximo" (azul + event icon)
/// - FINALIZADO: "Completado" (gris + flag icon)
TripStatusInfo getTripStatusInfo(String estado) {
  switch (estado) {
    case 'EN_CURSO':
      return TripStatusInfo(
        text: 'En Ruta',
        color: Colors.green[700]!,
        icon: Icons.sensors,
      );
    case 'PROGRAMADO':
      return TripStatusInfo(
        text: 'Próximo',
        color: Colors.blue[700]!,
        icon: Icons.event,
      );
    case 'FINALIZADO':
      return TripStatusInfo(
        text: 'Completado',
        color: Colors.grey[600]!,
        icon: Icons.flag,
      );
    default:
      return TripStatusInfo(
        text: 'Desconocido',
        color: Colors.grey[600]!,
        icon: Icons.help_outline,
      );
  }
}
