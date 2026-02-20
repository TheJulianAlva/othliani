import 'package:flutter/material.dart';

class GuiaProfileScreen extends StatelessWidget {
  const GuiaProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Perfil - Guía')),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person, size: 64),
            SizedBox(height: 16),
            Text('Pantalla de perfil del guía', style: TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
