import 'package:flutter/material.dart';

class DraftGuardWidget extends StatelessWidget {
  final Widget child;
  final bool
  shouldWarn; // ¿Debemos advertir? (Ej: Si el formulario está vacío, no molestamos)
  final VoidCallback?
  onConfirmExit; // Callback opcional por si queremos forzar guardado extra

  const DraftGuardWidget({
    super.key,
    required this.child,
    this.shouldWarn = true,
    this.onConfirmExit,
  });

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop:
          !shouldWarn, // Si shouldWarn es true, BLOQUEAMOS la salida automática
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) {
          return; // Si ya salió (porque shouldWarn era false), no hacemos nada
        }

        // Mostramos la advertencia
        final bool salir = await _showExitDialog(context) ?? false;

        if (salir) {
          onConfirmExit?.call(); // Ejecutar lógica de guardado extra si existe
          if (context.mounted) {
            Navigator.of(context).pop(); // Salir manualmente
          }
        }
      },
      child: child,
    );
  }

  Future<bool?> _showExitDialog(BuildContext context) {
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
              "Tienes un viaje en proceso. Si sales ahora, **se creará una copia automática (Borrador)** para que puedas recuperarlo más tarde.\n\n"
              "¿Estás seguro de que deseas salir?",
              style: TextStyle(fontSize: 14),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false), // No salir
                child: const Text("Cancelar, seguir editando"),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(ctx, true), // Sí, salir
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
