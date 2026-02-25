import 'package:flutter/material.dart';

/// Tarjeta de estado del viaje actual — compartida entre el layout B2B y B2C.
class StatusCard extends StatelessWidget {
  final String titulo;
  final String subtitulo;
  final IconData icono;
  final Color color;

  const StatusCard({
    super.key,
    required this.titulo,
    required this.subtitulo,
    this.icono = Icons.directions_walk,
    this.color = const Color(0xFF3D5AF1),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withAlpha(60)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withAlpha(40),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icono, color: color, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  titulo,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: Color(0xFF1A1A2E),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitulo,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: color.withAlpha(180)),
        ],
      ),
    );
  }
}
