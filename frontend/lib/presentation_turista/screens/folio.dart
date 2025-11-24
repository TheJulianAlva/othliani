import 'package:flutter/material.dart';

class FolioScreen extends StatefulWidget {
  const FolioScreen({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _FolioScreenState createState() => _FolioScreenState();
}

class _FolioScreenState extends State<FolioScreen> {
  final TextEditingController _folioController = TextEditingController();

  void _onContinue() {
    final folio = _folioController.text.trim();
    // Aquí puedes manejar el folio ingresado
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Folio ingresado: $folio')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Bienvenido a OthliAni')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _folioController,
              decoration: InputDecoration(
                label: Text('Ingresa tu folio'),
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _onContinue,
                child: Text('Continuar'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
