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


    return Stack(
      children: [
        Positioned(
          left: _position.dx,
          top: _position.dy,
          child: Draggable(
            feedback: _buildButton(context, isDragging: true),
            childWhenDragging: Container(),
            onDragEnd: (details) {
              final RenderBox renderBox = context.findRenderObject() as RenderBox;
              final localOffset = renderBox.globalToLocal(details.offset);
              
              setState(() {
                // Keep button within screen bounds
                double newX = localOffset.dx;
                double newY = localOffset.dy;

                // Constrain to widget bounds (with padding)
                newX = newX.clamp(0.0, renderBox.size.width - 56); // 56 is button width
                newY = newY.clamp(0.0, renderBox.size.height - 56);

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
