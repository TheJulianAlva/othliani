import 'package:flutter/material.dart';
import 'dart:ui';

import '../../core/theme/veltur_tokens.dart';

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
    // El tinte cálido de la barrera se toma del token de sombra (D-02): se
    // fuerza la opacidad a 35% para preservar el comportamiento actual,
    // reemplazando solo el color neutro por el warm brown de la marca.
    final barrierColor = VelturTokens.of(
      context,
    ).shadowMd.first.color.withValues(alpha: 0.35);
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: barrierColor,
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
    final theme = Theme.of(context);
    final tokens = VelturTokens.of(context);

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
                key: const Key('savingOverlaySpinnerCircle'),
                padding: const EdgeInsets.all(28),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  shape: BoxShape.circle,
                  boxShadow: tokens.shadowMd,
                ),
                child: SizedBox(
                  width: 40,
                  height: 40,
                  child: CircularProgressIndicator(
                    color: theme.colorScheme.primary,
                    strokeWidth: 3.5,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Texto descriptivo
              Text(
                mensaje,
                textAlign: TextAlign.center,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.surface,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                  shadows: [
                    Shadow(
                      color: tokens.shadowMd.first.color,
                      blurRadius: 8,
                      offset: const Offset(0, 2),
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
