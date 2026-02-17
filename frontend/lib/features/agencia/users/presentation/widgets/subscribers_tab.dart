import 'package:flutter/material.dart';

class SubscribersTab extends StatelessWidget {
  const SubscribersTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.mobile_friendly, size: 48, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          const Text(
            'Suscriptores App B2C',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Usuarios que han adquirido una suscripción personal.',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
