import 'package:flutter/material.dart';

class GuiaMapScreen extends StatelessWidget {
  const GuiaMapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mapa - Guía')),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.map, size: 64),
            SizedBox(height: 16),
            Text('Pantalla de mapa del guía', style: TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
