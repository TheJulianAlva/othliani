import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:frontend/features/guia/trips/domain/entities/actividad_itinerario.dart';
import 'activity_detail_sheet.dart';

// ─── Constantes de diseño ───
const _kCardRadius = 16.0;
const _kCardMargin = EdgeInsets.only(bottom: 12);
const _kGreen = Color(0xFF00AE00);

/// Tarjeta compacta de actividad con detalle flotante al tocar.
///
/// Si [esGestion] es `true`, se envuelve en un [Dismissible] para
/// permitir eliminar o editar la actividad con swipe.
class ActivityCard extends StatelessWidget {
  final ActividadItinerario actividad;
  final bool esGestion;

  const ActivityCard({
    super.key,
    required this.actividad,
    this.esGestion = false,
  });

  // ─── Helpers de formato ───

  /// Formatea un [DateTime] a "HH:mm".
  static String _hhmm(DateTime dt) =>
      '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';

  /// Rango horario listo para mostrar.
  String get _horarioTexto => '${_hhmm(actividad.horaInicio)} - ${_hhmm(actividad.horaFin)}';

  // ─── Build ───

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(_kCardRadius);

    final tarjetaBase = Container(
      margin: _kCardMargin,
      child: Material(
        color: Colors.white,
        borderRadius: borderRadius,
        child: InkWell(
          borderRadius: borderRadius,
          onTap: () => mostrarDetalleActividad(
            context,
            actividad: actividad,
            horarioTexto: _horarioTexto,
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              borderRadius: borderRadius,
              border: Border.all(color: Colors.grey.shade100),
            ),
            child: Row(
              children: [
                Icon(
                  actividad.completada ? Icons.check_circle : Icons.circle_outlined,
                  color: actividad.completada ? _kGreen : Colors.grey,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        actividad.nombre,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        _horarioTexto,
                        style: const TextStyle(color: Colors.grey, fontSize: 11),
                      ),
                    ],
                  ),
                ),
                if (actividad.descripcion != null || actividad.puntoReunion != null)
                  const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.grey, size: 20),
              ],
            ),
          ),
        ),
      ),
    );

    if (!esGestion) return tarjetaBase;

    return Dismissible(
      key: Key(actividad.nombre),
      dismissThresholds: const {
        DismissDirection.startToEnd: 0.7,
        DismissDirection.endToStart: 0.5,
      },
      movementDuration: const Duration(milliseconds: 600),
      background: _SwipeBackground(
        alignment: Alignment.centerLeft,
        color: Colors.redAccent.shade100,
        icon: Icons.delete_sweep_rounded,
      ),
      secondaryBackground: _SwipeBackground(
        alignment: Alignment.centerRight,
        color: Colors.blueGrey.shade400,
        icon: Icons.edit_note_rounded,
      ),
      confirmDismiss: (direction) async {
        if (direction == DismissDirection.startToEnd) {
          return _mostrarDialogoConfirmacion(context, actividad.nombre);
        }
        context.push('/ruta-edicion-itinerario');
        return false;
      },
      child: tarjetaBase,
    );
  }

  // ─── Diálogos ───

  Future<bool?> _mostrarDialogoConfirmacion(BuildContext context, String nombre) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('¿Eliminar actividad?'),
        content: Text('Esto quitará "$nombre" del itinerario.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('CANCELAR'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent.shade200),
            child: const Text('ELIMINAR', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

// ─── Widget privado de soporte ───

/// Fondo coloreado para el [Dismissible] (swipe izq / der).
class _SwipeBackground extends StatelessWidget {
  final Alignment alignment;
  final Color color;
  final IconData icon;

  const _SwipeBackground({
    required this.alignment,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: _kCardMargin,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(_kCardRadius),
      ),
      alignment: alignment,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Icon(icon, color: Colors.white),
    );
  }
}
