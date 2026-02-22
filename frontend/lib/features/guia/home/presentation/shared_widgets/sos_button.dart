import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/features/guia/home/presentation/blocs/sos/sos_cubit.dart';

/// Botón de emergencia SOS — compartido entre el layout B2B y B2C.
///
/// Si hay un [SosCubit] en el árbol, activa el pre-aviso de 30 segundos.
/// De lo contrario muestra el diálogo de confirmación clásico.
class SosButton extends StatefulWidget {
  final VoidCallback? onPressed;

  const SosButton({super.key, this.onPressed});

  @override
  State<SosButton> createState() => _SosButtonState();
}

class _SosButtonState extends State<SosButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.12,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handlePress(BuildContext context) {
    if (widget.onPressed != null) {
      widget.onPressed!();
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
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(scale: _scaleAnimation.value, child: child);
      },
      child: ElevatedButton.icon(
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
