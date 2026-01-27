import 'package:flutter/material.dart';

class DirectoryTab extends StatelessWidget {
  const DirectoryTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.backpack_outlined, size: 48, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          const Text(
            'Directorio de Turistas',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Este directorio se alimenta automáticamente de los viajes.',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
