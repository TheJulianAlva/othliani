import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/features/guia/sos/presentation/blocs/sos_cubit.dart';

/// Botón de emergencia SOS — compartido entre el layout B2B y B2C.
///
/// Si hay un [SosCubit] en el árbol, activa el pre-aviso de 30 segundos.
/// De lo contrario muestra el diálogo de confirmación clásico.
class SosButton extends StatelessWidget {
  final VoidCallback? onPressed;

  const SosButton({super.key, this.onPressed});

  void _handlePress(BuildContext context) {
    if (onPressed != null) {
      onPressed!();
      return;
    }

    // Delegamos al SosCubit si está disponible en el árbol.
    try {
      context.read<SosCubit>().triggerWarning();
    } catch (_) {
      // Fallback: el cubit no está disponible → diálogo clásico.
      _mostrarConfirmacion(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () => _handlePress(context),
      icon: const Icon(Icons.emergency, size: 20),
      label: const Text(
        'SOS',
        style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFD32F2F),
        foregroundColor: Colors.white,
        minimumSize: const Size.fromHeight(52),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 6,
        shadowColor: const Color(0xFFD32F2F).withAlpha(120),
      ),
    );
  }

  void _mostrarConfirmacion(BuildContext context) {
    showDialog<void>(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('¿Activar SOS?'),
            content: const Text(
              'Se enviará una alerta de emergencia a la agencia y a los contactos de seguridad registrados.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD32F2F),
                  foregroundColor: Colors.white,
                ),
                child: const Text('Activar'),
              ),
            ],
          ),
    );
  }
}
