import 'package:flutter/material.dart';

import 'package:frontend/features/guia/trips/domain/entities/actividad_itinerario.dart';

// ─── Constantes de diseño ───
const _kSheetRadius = 24.0;
const _kDarkText = Color(0xFF2C3E50);
const _kGreen = Color(0xFF00AE00);

/// Muestra un bottom sheet flotante con el detalle de una [ActividadItinerario].
///
/// Recibe el [horarioTexto] ya formateado para no duplicar lógica de formato.
void mostrarDetalleActividad(
  BuildContext context, {
  required ActividadItinerario actividad,
  required String horarioTexto,
}) {
  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (_) => _ActividadDetalleSheet(
      actividad: actividad,
      horarioTexto: horarioTexto,
    ),
  );
}

// ═══════════════════════════════════════════════════════════════════
//  Widgets privados del sheet
// ═══════════════════════════════════════════════════════════════════

class _ActividadDetalleSheet extends StatelessWidget {
  final ActividadItinerario actividad;
  final String horarioTexto;

  const _ActividadDetalleSheet({
    required this.actividad,
    required this.horarioTexto,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(_kSheetRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Título
            Text(
              actividad.nombre,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: _kDarkText,
              ),
            ),
            const SizedBox(height: 12),

            // Estado
            _InfoRow(
              icon: actividad.completada ? Icons.check_circle : Icons.circle,
              text: actividad.completada ? 'Completada' : 'En curso',
              iconColor: actividad.completada ? _kGreen : Colors.yellow[700]!,
              textColor: Colors.black87,
            ),

            // Horario
            _InfoRow(
              icon: Icons.access_time_filled,
              text: horarioTexto,
              iconColor: Colors.blue,
            ),

            // Punto de reunión
            if (actividad.puntoReunion != null)
              _InfoRow(
                icon: Icons.location_on,
                text: 'Punto de reunión: ${actividad.puntoReunion}',
                iconColor: Colors.red[400]!,
              ),

            const Divider(height: 24),

            // Descripción
            const Text(
              'Descripción',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black54),
            ),
            const SizedBox(height: 6),
            Text(
              actividad.descripcion ?? 'Sin detalles adicionales.',
              style: const TextStyle(fontSize: 15, height: 1.4, color: Colors.black87),
            ),
            const SizedBox(height: 20),

            // Botón de cierre
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[50],
                  foregroundColor: Colors.green[700],
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Entendido'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Fila reutilizable de ícono + texto.
class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color iconColor;
  final Color textColor;

  const _InfoRow({
    required this.icon,
    required this.text,
    required this.iconColor,
    this.textColor = Colors.black54,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 18, color: iconColor),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: textColor),
            ),
          ),
        ],
      ),
    );
  }
}
