import 'package:flutter/material.dart';

class GuiaItineraryScreen extends StatelessWidget {
  const GuiaItineraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Itinerario - Guía')),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.route, size: 64),
            SizedBox(height: 16),
            Text(
              'Pantalla de itinerario del guía',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
