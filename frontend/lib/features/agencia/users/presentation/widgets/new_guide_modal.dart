import 'package:flutter/material.dart';

class NewGuideModal extends StatefulWidget {
  const NewGuideModal({super.key});

  @override
  State<NewGuideModal> createState() => _NewGuideModalState();
}

class _NewGuideModalState extends State<NewGuideModal> {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 500),
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Alta de Nuevo Guía',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F4C75),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const Divider(),
                const SizedBox(height: 16),

                Text(
                  'Esta acción enviará una invitación por correo para que el guía descargue la App y configure su acceso.',
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                ),
                const SizedBox(height: 24),

                // Fields
                _buildTextField('Nombre Completo', 'Ej. Marcos Ruiz'),
                const SizedBox(height: 16),
                _buildTextField(
                  'Correo Electrónico',
                  'guia@agencia.com',
                  icon: Icons.email_outlined,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  'ID de Empleado (Opcional)',
                  'Ej. EMP-023',
                  icon: Icons.badge_outlined,
                ),

                const SizedBox(height: 32),

                // Actions
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text(
                        'Cancelar',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                    const SizedBox(width: 12),
                    ElevatedButton.icon(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          Navigator.of(context).pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Invitación enviada correctamente (Simulado)',
                              ),
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0F4C75),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                      ),
                      icon: const Icon(Icons.send, size: 16),
                      label: const Text('ENVIAR INVITACIÓN'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, String hint, {IconData? icon}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
        ),
        const SizedBox(height: 8),
        TextFormField(
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon:
                icon != null ? Icon(icon, size: 20, color: Colors.grey) : null,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 14,
            ),
            isDense: true,
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return label.contains('Opcional') ? null : 'Campo requerido';
            }
            return null;
          },
        ),
      ],
    );
  }
}
