import 'package:flutter/material.dart';

class WalkieTalkieButton extends StatefulWidget {
  const WalkieTalkieButton({super.key});

  @override
  State<WalkieTalkieButton> createState() => _WalkieTalkieButtonState();
}

class _WalkieTalkieButtonState extends State<WalkieTalkieButton> {
  Offset _position = const Offset(20, 100);

  void _activateWalkieTalkie(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Walkie-Talkie activado'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Stack(
      children: [
        Positioned(
          left: _position.dx,
          top: _position.dy,
          child: Draggable(
            feedback: _buildButton(context, isDragging: true),
            childWhenDragging: Container(),
            onDragEnd: (details) {
              setState(() {
                // Keep button within screen bounds
                double newX = details.offset.dx;
                double newY = details.offset.dy;

                // Constrain to screen bounds (with padding)
                newX = newX.clamp(0.0, size.width - 70);
                newY = newY.clamp(0.0, size.height - 150);

                _position = Offset(newX, newY);
              });
            },
            child: _buildButton(context),
          ),
        ),
      ],
    );
  }

  Widget _buildButton(BuildContext context, {bool isDragging = false}) {
    return Material(
      elevation: isDragging ? 8 : 6,
      shape: const CircleBorder(),
      color: Colors.transparent,
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: Colors.orange,
          shape: BoxShape.circle,
          boxShadow: isDragging
              ? [
                  BoxShadow(
                    color: Colors.orange.withValues(alpha: 0.5),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
        ),
        child: InkWell(
          onTap: () => _activateWalkieTalkie(context),
          customBorder: const CircleBorder(),
          child: const Icon(Icons.radio, color: Colors.white, size: 28),
        ),
      ),
    );
  }
}
