import 'package:flutter/material.dart';
import 'package:frontend/features/agencia/trips/presentation/utils/trip_status_utils.dart';

/// Widget reutilizable para mostrar el estado de un viaje
/// con texto contextual, color e icono
class TripStatusChip extends StatelessWidget {
  final String estado;
  final bool compact;

  const TripStatusChip({required this.estado, this.compact = false, super.key});

  @override
  Widget build(BuildContext context) {
    final info = getTripStatusInfo(estado);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 6 : 8,
        vertical: compact ? 2 : 4,
      ),
      decoration: BoxDecoration(
        color: info.color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: info.color.withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(info.icon, size: compact ? 10 : 12, color: info.color),
          SizedBox(width: compact ? 2 : 4),
          Text(
            info.text,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: compact ? 10 : 11,
              color: info.color,
            ),
          ),
        ],
      ),
    );
  }
}
