import 'package:flutter/material.dart';

class GuiaAlertsScreen extends StatelessWidget {
  const GuiaAlertsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Alertas - Guía')),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.notifications, size: 64),
            SizedBox(height: 16),
            Text(
              'Pantalla de alertas del guía',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
