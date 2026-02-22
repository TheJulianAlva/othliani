import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────────────────────
// SwipeToActionWidget — botón deslizable anti-pánico
//
// El guía debe arrastrar el thumb >80% del track para confirmar la acción.
// Si suelta antes, el thumb regresa al inicio con animación de resorte.
// ─────────────────────────────────────────────────────────────────────────────

class SwipeToActionWidget extends StatefulWidget {
  final String text;
  final VoidCallback onActionCompleted;
  final Color baseColor;
  final Color textColor;
  final IconData icon;

  const SwipeToActionWidget({
    super.key,
    required this.text,
    required this.onActionCompleted,
    this.baseColor = Colors.red,
    this.textColor = Colors.white,
    this.icon = Icons.warning_amber_rounded,
  });

  @override
  State<SwipeToActionWidget> createState() => _SwipeToActionWidgetState();
}

class _SwipeToActionWidgetState extends State<SwipeToActionWidget>
    with SingleTickerProviderStateMixin {
  double _dragX = 0;
  bool _completado = false;

  static const double _thumbSize = 58.0;
  static const double _padding = 4.0;

  late AnimationController _springCtrl;
  late Animation<double> _springAnim;

  @override
  void initState() {
    super.initState();
    _springCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
  }

  @override
  void dispose() {
    _springCtrl.dispose();
    super.dispose();
  }

  void _onDragUpdate(DragUpdateDetails d, double maxDrag) {
    if (_completado) return;
    setState(() {
      _dragX = (_dragX + d.delta.dx).clamp(0.0, maxDrag);
    });
  }

  void _onDragEnd(DragEndDetails _, double maxDrag) {
    if (_completado) return;
    if (_dragX >= maxDrag * 0.8) {
      // Completado: lleva el thumb al final y ejecuta la acción
      setState(() {
        _dragX = maxDrag;
        _completado = true;
      });
      widget.onActionCompleted();
    } else {
      // Resorte: anima de vuelta al inicio
      _springAnim = Tween<double>(begin: _dragX, end: 0.0).animate(
        CurvedAnimation(parent: _springCtrl, curve: Curves.elasticOut),
      )..addListener(() => setState(() => _dragX = _springAnim.value));
      _springCtrl
        ..reset()
        ..forward();
    }
  }

  /// Permite reutilizar el widget tras completar (ej. botón "a salvo")
  void reset() => setState(() {
    _dragX = 0;
    _completado = false;
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, constraints) {
        final double maxDrag = constraints.maxWidth - _thumbSize - _padding * 2;
        final double progreso = _dragX / maxDrag;

        return Container(
          height: _thumbSize + _padding * 2,
          decoration: BoxDecoration(
            color: widget.baseColor.withAlpha(30),
            borderRadius: BorderRadius.circular(
              (_thumbSize + _padding * 2) / 2,
            ),
            border: Border.all(
              color: widget.baseColor.withAlpha(120),
              width: 2,
            ),
          ),
          child: Stack(
            alignment: Alignment.centerLeft,
            children: [
              // Relleno de progreso
              AnimatedContainer(
                duration: Duration.zero,
                width: _dragX + _thumbSize + _padding,
                height: _thumbSize,
                decoration: BoxDecoration(
                  color: widget.baseColor.withAlpha((progreso * 60).round()),
                  borderRadius: BorderRadius.circular(_thumbSize / 2),
                ),
              ),

              // Texto centrado
              Center(
                child: Padding(
                  padding: EdgeInsets.only(left: _thumbSize + _padding),
                  child: Text(
                    _completado ? '✓ Confirmado' : widget.text,
                    style: TextStyle(
                      color: widget.baseColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),

              // Thumb deslizable
              GestureDetector(
                onHorizontalDragUpdate: (d) => _onDragUpdate(d, maxDrag),
                onHorizontalDragEnd: (d) => _onDragEnd(d, maxDrag),
                child: Positioned(
                  left: _dragX + _padding,
                  child: _Thumb(
                    size: _thumbSize,
                    color: widget.baseColor,
                    icon: _completado ? Icons.check_rounded : widget.icon,
                    progreso: progreso,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _Thumb extends StatelessWidget {
  final double size;
  final Color color;
  final IconData icon;
  final double progreso;

  const _Thumb({
    required this.size,
    required this.color,
    required this.icon,
    required this.progreso,
  });

  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      color: progreso >= 0.8 ? Colors.green : color,
      shape: BoxShape.circle,
      boxShadow: [
        BoxShadow(
          color: color.withAlpha(80),
          blurRadius: 8,
          offset: const Offset(0, 3),
        ),
      ],
    ),
    child: Icon(icon, color: Colors.white, size: 26),
  );
}
