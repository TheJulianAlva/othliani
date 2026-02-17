import 'package:flutter/material.dart';

class NotificationSettings extends StatelessWidget {
  const NotificationSettings({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Notificaciones y Alertas',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Gestiona el escalamiento de alertas críticas durante los viajes.',
            style: TextStyle(color: Colors.grey.shade600),
          ),
          const SizedBox(height: 32),

          // Emergency Contacts
          const Text(
            'Contactos de Emergencia',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
          ),
          const SizedBox(height: 8),
          Text(
            '¿A quién le llega el correo si se activa un botón de pánico y el admin no está viendo la pantalla?',
            style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
          ),
          const SizedBox(height: 24),

          _buildTextField(
            'Correo de Supervisión',
            'seguridad@viajesaventuras.com',
            Icons.email_outlined,
            helperText:
                'Recibirá alertas de pánico y desvíos graves en tiempo real.',
          ),
          const SizedBox(height: 24),
          _buildTextField(
            'Teléfono para SMS (Opcional)',
            '+52 55 1234 5678',
            Icons.sms_outlined,
            helperText:
                'Se enviará un SMS solo si no hay respuesta por email en 5 minutos.',
          ),

          const SizedBox(height: 40),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.save),
              label: const Text('Guardar Preferencias'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(
    String label,
    String initialValue,
    IconData icon, {
    String? helperText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        TextFormField(
          initialValue: initialValue,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, size: 20, color: Colors.grey.shade600),
            border: const OutlineInputBorder(),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            helperText: helperText,
            helperMaxLines: 2,
          ),
        ),
      ],
    );
  }
}
