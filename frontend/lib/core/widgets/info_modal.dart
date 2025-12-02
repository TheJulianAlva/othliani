import 'package:flutter/material.dart';

/// Utilidad para mostrar un modal reutilizable con animación.
/// - [title]: Título del modal (p. ej. "Aviso de Privacidad").
/// - [content]: Texto largo a mostrar.
/// - [onAccept]: (Opcional) Callback para un botón de "Aceptar".
class InfoModal {
  static Future<void> show({
    required BuildContext context,
    required String title,
    required String content,
    IconData? icon,
    Color? titleColor,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent, // para esquinas redondeadas bonitas
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return _AnimatedInfoSheet(
          title: title,
          content: content,
          icon: icon,
          titleColor: titleColor,
        );
      },
    );
  }
}

/// Widget interno con animación (fade + slide).
class _AnimatedInfoSheet extends StatefulWidget {
  final String title;
  final String content;
  final IconData? icon;
  final Color? titleColor;

  const _AnimatedInfoSheet({
    required this.title,
    required this.content,
    this.icon,
    this.titleColor,
  });

  @override
  State<_AnimatedInfoSheet> createState() => _AnimatedInfoSheetState();
}

class _AnimatedInfoSheetState extends State<_AnimatedInfoSheet>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280), // velocidad de entrada
      reverseDuration: const Duration(milliseconds: 180),
    );

    _fade = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutQuad,
      reverseCurve: Curves.easeInQuad,
    );

    _slide =
        Tween<Offset>(
          begin: const Offset(0, 0.06), // un poquito desde abajo
          end: Offset.zero,
        ).animate(
          CurvedAnimation(
            parent: _controller,
            curve: Curves.easeOutCubic,
            reverseCurve: Curves.easeInCubic,
          ),
        );

    // Dispara la animación de entrada
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _close() async {
    // Animación de salida antes de cerrar
    await _controller.reverse();
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Usamos SafeArea + Draggable (opcional) + contenido con scroll
    return SafeArea(
      top: false,
      child: FadeTransition(
        opacity: _fade,
        child: SlideTransition(
          position: _slide,
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            padding: const EdgeInsets.only(
              left: 16,
              right: 16,
              top: 12,
              bottom: 8,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Indicador de arrastre (estético)
                Container(
                  width: 36,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.black12,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),

                // Título
                Align(
                  alignment: Alignment.centerLeft,
                  child: Row(
                    children: [
                      if (widget.icon != null) ...[
                        Icon(
                          widget.icon,
                          color: widget.titleColor ?? Colors.black,
                        ),
                        const SizedBox(width: 8),
                      ],
                      Expanded(
                        child: Text(
                          widget.title,
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: widget.titleColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),

                // Contenido scrollable
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      widget.content,
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // Botones de acción
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(onPressed: _close, child: const Text('Cerrar')),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
