import 'package:flutter/material.dart';
import 'dart:async';

class VoiceCallDialog extends StatefulWidget {
  final String contactName;
  final String role; // "Guía" or "Turista"

  const VoiceCallDialog({
    super.key,
    required this.contactName,
    required this.role,
  });

  @override
  State<VoiceCallDialog> createState() => _VoiceCallDialogState();
}

class _VoiceCallDialogState extends State<VoiceCallDialog> {
  int _seconds = 0;
  Timer? _timer;
  String _status = 'Conectando...';

  @override
  void initState() {
    super.initState();
    // Simulate connection after 2 seconds
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _status = 'En llamada';
          _startTimer();
        });
      }
    });
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _seconds++;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String get _timerText {
    final minutes = (_seconds / 60).floor().toString().padLeft(2, '0');
    final seconds = (_seconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFF1A237E), // Dark blue background
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: const EdgeInsets.all(24),
        width: 300,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircleAvatar(
              radius: 40,
              backgroundColor: Colors.white24,
              child: Icon(Icons.person, size: 40, color: Colors.white),
            ),
            const SizedBox(height: 16),
            Text(
              widget.contactName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              widget.role,
              style: const TextStyle(color: Colors.white70, fontSize: 14),
            ),
            const SizedBox(height: 24),
            Text(
              _status,
              style: const TextStyle(color: Colors.white54, fontSize: 14),
            ),
            if (_status == 'En llamada')
              Text(
                _timerText,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w300,
                ),
              ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildActionButton(
                  icon: Icons.mic_off,
                  color: Colors.white24,
                  onTap: () {},
                ),
                _buildActionButton(
                  icon: Icons.call_end,
                  color: Colors.red,
                  onTap: () => Navigator.of(context).pop(),
                ),
                _buildActionButton(
                  icon: Icons.volume_up,
                  color: Colors.white24,
                  onTap: () {},
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: CircleAvatar(
        radius: 28,
        backgroundColor: color,
        child: Icon(icon, color: Colors.white, size: 24),
      ),
    );
  }
}
