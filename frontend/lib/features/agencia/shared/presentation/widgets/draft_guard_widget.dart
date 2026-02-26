import 'package:flutter/material.dart';
import 'package:frontend/core/widgets/saving_overlay.dart';

class DraftGuardWidget extends StatefulWidget {
  final Widget child;
  final bool shouldWarn;
  final VoidCallback? onConfirmExit;

  /// Si se provee, el gesto/botón de atrás del sistema llama a este callback
  /// en vez de mostrar el diálogo. Úsalo para navegación interna entre pasos.
  final VoidCallback? onBackOverride;

  const DraftGuardWidget({
    super.key,
    required this.child,
    this.shouldWarn = true,
    this.onConfirmExit,
    this.onBackOverride,
  });

  @override
  State<DraftGuardWidget> createState() => _DraftGuardWidgetState();

  // ─── Método estático reutilizable ─────────────────────────────────────────

  static Future<bool?> showExitDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Row(
              children: [
                Icon(Icons.save_as_rounded, color: Colors.amber[800]),
                const SizedBox(width: 10),
                const Text("¿Salir de la creación?"),
              ],
            ),
            content: const Text(
              "Tienes un viaje en proceso. Si sales ahora, se creará una copia "
              "automática (Borrador) para que puedas recuperarlo más tarde.\n\n"
              "¿Estás seguro de que deseas salir?",
              style: TextStyle(fontSize: 14),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text("Cancelar, seguir editando"),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(ctx, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[800],
                  foregroundColor: Colors.white,
                ),
                child: const Text("Salir y Guardar Borrador"),
              ),
            ],
          ),
    );
  }
}

class _DraftGuardWidgetState extends State<DraftGuardWidget> {
  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;

        // Caso A: Navegación interna (entre pasos) → sin diálogo ni overlay
        // Usamos widget.onBackOverride para obtener siempre el valor actualizado
        if (widget.onBackOverride != null) {
          widget.onBackOverride!();
          return;
        }

        // Caso B: Sin datos → salir directo
        if (!widget.shouldWarn) {
          Navigator.of(context).pop();
          return;
        }

        // Caso C: Hay datos → diálogo + overlay al confirmar
        final bool salir =
            await DraftGuardWidget.showExitDialog(context) ?? false;

        if (salir) {
          widget.onConfirmExit?.call();

          if (context.mounted) {
            await SavingOverlay.showAndWait(
              context,
              mensaje: "Guardando borrador...",
              duration: const Duration(milliseconds: 800),
            );

            if (context.mounted) {
              Navigator.of(context).pop();
            }
          }
        }
      },
      child: widget.child,
    );
  }
}
