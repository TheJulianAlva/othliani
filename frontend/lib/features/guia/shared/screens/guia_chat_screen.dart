import 'package:flutter/material.dart';

class GuiaChatScreen extends StatelessWidget {
  const GuiaChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Chat - Guía')),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.chat, size: 64),
            SizedBox(height: 16),
            Text('Pantalla de chat del guía', style: TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }
}
