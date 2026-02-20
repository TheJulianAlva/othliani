import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:frontend/core/navigation/routes_guia.dart';

class GuiaHomeScreen extends StatelessWidget {
  const GuiaHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inicio - Guía'),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.home, size: 64),
            const SizedBox(height: 16),
            const Text(
              'Pantalla de inicio del guía',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go(RoutesGuia.map),
              child: const Text('Ver mapa'),
            ),
          ],
        ),
      ),
    );
  }
}
