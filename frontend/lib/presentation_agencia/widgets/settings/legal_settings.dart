import 'package:flutter/material.dart';

class LegalSettings extends StatelessWidget {
  const LegalSettings({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Legal y Privacidad',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Cumplimiento con LFPDPPP e ISO 31000.',
            style: TextStyle(color: Colors.grey.shade600),
          ),
          const SizedBox(height: 32),

          // Privacy Notice
          const Text(
            'Aviso de Privacidad',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            'Este documento aparecerá en la App del Turista cuando se registren bajo tu agencia.',
            style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
          ),
          const SizedBox(height: 16),

          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              border: Border.all(
                color: Colors.grey.shade300,
                style: BorderStyle.solid,
              ),
              borderRadius: BorderRadius.circular(8),
              color: Colors.grey.shade50,
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.cloud_upload_outlined,
                  size: 40,
                  color: Colors.blueGrey,
                ),
                const SizedBox(height: 16),
                const Text('Arrastra tu PDF aquí o haz clic para subir'),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () {},
                  child: const Text('Seleccionar Archivo'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Center(
            child: Text(
              'O ingresa una URL pública:',
              style: TextStyle(color: Colors.grey),
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            initialValue: 'https://viajesaventuras.com/privacidad',
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.link),
              border: OutlineInputBorder(),
              labelText: 'URL del Aviso de Privacidad',
            ),
          ),

          const SizedBox(height: 40),

          // ARCO Rights
          const Text(
            'Contacto ARCO',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
          ),
          const SizedBox(height: 8),
          TextFormField(
            initialValue: 'legal@viajesaventuras.com',
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.gavel_outlined, color: Colors.blueGrey),
              border: OutlineInputBorder(),
              labelText: 'Correo para derechos ARCO',
              helperText:
                  'Recibirá las solicitudes de acceso, rectificación, cancelación y oposición.',
            ),
          ),

          const SizedBox(height: 40),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.save),
              label: const Text('Guardar'),
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
}
