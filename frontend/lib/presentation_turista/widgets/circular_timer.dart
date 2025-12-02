import 'dart:async';
import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_colors.dart';

class CircularTimer extends StatefulWidget {
  final Duration duration;
  final VoidCallback onComplete;

  const CircularTimer({
    super.key,
    required this.duration,
    required this.onComplete,
  });

  @override
  State<CircularTimer> createState() => _CircularTimerState();
}

class _CircularTimerState extends State<CircularTimer> {
  late Timer _timer;
  late int _remainingSeconds;
  late int _totalSeconds;

  @override
  void initState() {
    super.initState();
    _totalSeconds = widget.duration.inSeconds;
    _remainingSeconds = _totalSeconds;
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() {
          _remainingSeconds--;
        });
      } else {
        _timer.cancel();
        widget.onComplete();
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double progress = _remainingSeconds / _totalSeconds;

    return SizedBox(
      width: 120,
      height: 120,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 100,
            height: 100,
            child: CircularProgressIndicator(
              value: progress,
              strokeWidth: 8,
              backgroundColor: Colors.grey[300],
              color: AppColors.primary,
            ),
          ),
          Center(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$_remainingSeconds',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const Text(
                    'segundos',
                    style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
