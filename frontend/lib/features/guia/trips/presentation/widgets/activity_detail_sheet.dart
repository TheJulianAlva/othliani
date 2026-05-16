import 'package:flutter/material.dart';

import 'package:frontend/features/guia/trips/domain/entities/actividad_itinerario.dart';

/// Muestra un bottom sheet flotante con el detalle de una [ActividadItinerario].
///
/// Recibe el [horarioTexto] ya formateado para no duplicar lógica de formato.
void mostrarDetalleActividad(
  BuildContext context, {
  required ActividadItinerario actividad,
  required String horarioTexto,
}) {
  showDialog(
    context: context,
    builder:
        (ctx) => AlertDialog(
          title: Text(actividad.nombre, style: const TextStyle(fontSize: 18)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Estado: ${actividad.completada ? "Completada" : "Pendiente"}',
              ),
              const SizedBox(height: 4),
              Text('Horario: $horarioTexto'),
              if (actividad.puntoReunion != null) ...[
                const SizedBox(height: 4),
                Text('Punto de reunión: ${actividad.puntoReunion}'),
              ],
              const SizedBox(height: 12),
              Text(actividad.descripcion ?? 'Sin detalles adicionales.'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('OK'),
            ),
          ],
        ),
  );
}
