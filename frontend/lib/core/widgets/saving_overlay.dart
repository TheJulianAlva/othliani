import 'package:flutter/material.dart';
import 'dart:ui';

/// Cortina de carga elegante con blur que bloquea la UI durante el guardado.
/// Uso:
///   await SavingOverlay.showAndWait(context, mensaje: "Guardando...");
///   SavingOverlay.show(context); // + SavingOverlay.hide(context);
class SavingOverlay extends StatelessWidget {
  final String mensaje;

  const SavingOverlay({super.key, this.mensaje = "Guardando progreso..."});

  // ─── API estática ──────────────────────────────────────────────────────────

  /// Muestra el overlay. Combinar con [hide] si se necesita control manual.
  static void show(
    BuildContext context, {
    String mensaje = "Guardando progreso...",
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.35),
      useRootNavigator: true,
      builder: (_) => SavingOverlay(mensaje: mensaje),
    );
  }

  /// Cierra el overlay abierto con [show].
  static void hide(BuildContext context) {
    Navigator.of(context, rootNavigator: true).pop();
  }

  /// Muestra el overlay, espera [duration] y lo cierra automáticamente.
  /// Ideal para usar con await:
  ///   await SavingOverlay.showAndWait(context);
  static Future<void> showAndWait(
    BuildContext context, {
    String mensaje = "Guardando progreso...",
    Duration duration = const Duration(milliseconds: 800),
  }) async {
    show(context, mensaje: mensaje);
    await Future.delayed(duration);
    if (context.mounted) hide(context);
  }

  // ─── Widget ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false, // El usuario no puede cerrar tocando atrás
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
        child: Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Círculo con la rueda giratoria
              Container(
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.18),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: const SizedBox(
                  width: 40,
                  height: 40,
                  child: CircularProgressIndicator(
                    color: Color(0xFF1565C0), // blue[800]
                    strokeWidth: 3.5,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Texto descriptivo
              Text(
                mensaje,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                  shadows: [
                    Shadow(
                      color: Colors.black45,
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
