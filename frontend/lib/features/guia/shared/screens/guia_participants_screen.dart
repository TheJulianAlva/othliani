import 'package:flutter/material.dart';

class GuiaParticipantsScreen extends StatelessWidget {
  const GuiaParticipantsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Participantes - Guía')),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.group, size: 64),
            SizedBox(height: 16),
            Text(
              'Lista de participantes del guía',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
