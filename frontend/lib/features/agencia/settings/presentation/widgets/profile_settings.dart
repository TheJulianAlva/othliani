import 'package:flutter/material.dart';

class ProfileSettings extends StatelessWidget {
  const ProfileSettings({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Perfil de la Organización',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),

          // Logo Section
          Center(
            child: Column(
              children: [
                Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Icon(
                    Icons.business,
                    size: 50,
                    color: Colors.grey.shade400,
                  ),
                ),
                const SizedBox(height: 16),
                OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.upload_file),
                  label: const Text('Subir Logotipo'),
                ),
                const SizedBox(height: 8),
                Text(
                  'Max 2MB, PNG/JPG',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),

          // Form Fields
          _buildTextField(
            'Nombre Comercial de la Agencia',
            'Viajes y Aventuras S.A. de C.V.',
            Icons.store,
          ),
          const SizedBox(height: 24),
          _buildTextField(
            'Correo de Contacto',
            'contabilidad@viajesaventuras.com',
            Icons.email,
            helperText: 'Para notificaciones de facturación',
          ),
          const SizedBox(height: 24),

          // Timezone Mock
          const Text(
            'Zona Horaria Predeterminada',
            style: TextStyle(fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(4),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: 'GMT-06:00',
                isExpanded: true,
                items: const [
                  DropdownMenuItem(
                    value: 'GMT-06:00',
                    child: Text('(GMT-06:00) Ciudad de México'),
                  ),
                  DropdownMenuItem(
                    value: 'GMT-05:00',
                    child: Text('(GMT-05:00) Cancún'),
                  ),
                ],
                onChanged: (val) {},
              ),
            ),
          ),

          const SizedBox(height: 40),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.save),
              label: const Text('Guardar Cambios'),
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
            prefixIcon: Icon(icon, size: 20),
            border: const OutlineInputBorder(),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            helperText: helperText,
          ),
        ),
      ],
    );
  }
}
