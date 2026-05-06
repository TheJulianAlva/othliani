import 'package:flutter/material.dart';

class NewTripModal extends StatefulWidget {
  const NewTripModal({super.key});

  @override
  State<NewTripModal> createState() => _NewTripModalState();
}

class _NewTripModalState extends State<NewTripModal> {
  int _currentStep = 0;
  final _pageController = PageController();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        constraints: BoxConstraints(
          maxWidth: 600,
          maxHeight: MediaQuery.of(context).size.height * 0.9,
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Crear Nuevo Viaje',
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

            // Steps Indicator
            Row(
              children: [
                _buildStepIndicator(0, "Datos Básicos"),
                Expanded(
                  child: Container(height: 1, color: Colors.grey.shade300),
                ),
                _buildStepIndicator(1, "Configuración Seguridad"),
              ],
            ),
            const SizedBox(height: 24),

            // Content Wizard
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [_buildStep1(), _buildStep2()],
              ),
            ),

            // Actions
            const Divider(),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (_currentStep > 0)
                  TextButton(
                    onPressed: () {
                      setState(() => _currentStep--);
                      _pageController.previousPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    },
                    child: const Text(
                      'Atrás',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: () {
                    if (_currentStep < 1) {
                      setState(() => _currentStep++);
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    } else {
                      // Save
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Viaje Creado Exitosamente'),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0F4C75),
                    foregroundColor: Colors.white,
                  ),
                  child: Text(
                    _currentStep < 1 ? 'Siguiente' : 'Guardar y Gestionar',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepIndicator(int index, String title) {
    bool isActive = _currentStep >= index;
    return Row(
      children: [
        CircleAvatar(
          radius: 12,
          backgroundColor:
              isActive ? const Color(0xFF0F4C75) : Colors.grey.shade300,
          child: Text(
            (index + 1).toString(),
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
        ),
        const SizedBox(width: 8),
        ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 120),
          child: Text(
            title,
            style: TextStyle(
              color: isActive ? Colors.black87 : Colors.grey,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildStep1() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTextField(
            "Nombre del Destino / Viaje",
            "Ej. Ruta del Vino QRO",
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: _buildTextField("Fecha Inicio", "DD/MM/AAAA")),
              const SizedBox(width: 16),
              Expanded(child: _buildTextField("Fecha Fin", "DD/MM/AAAA")),
            ],
          ),
          const SizedBox(height: 16),
          _buildTextField(
            "Número de Folio (Automático)",
            "#MEX-025",
            enabled: false,
          ),
        ],
      ),
    );
  }

  Widget _buildStep2() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Parámetros de Alerta",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 8),
          const Text(
            "Define cuándo se disparan las alertas automáticas para este viaje.",
            style: TextStyle(color: Colors.grey, fontSize: 12),
          ),
          const SizedBox(height: 24),
          _buildTextField("Radio de Alejamiento Máximo (Metros)", "50"),
          const SizedBox(height: 16),
          _buildTextField("Tiempo de Desconexión (Minutos)", "5"),
          const SizedBox(height: 16),
          _buildTextField("Guía Asignado", "Buscar guía..."),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, String hint, {bool enabled = true}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
        ),
        const SizedBox(height: 6),
        TextField(
          enabled: enabled,
          decoration: InputDecoration(
            hintText: hint,
            border: const OutlineInputBorder(),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
            filled: !enabled,
            fillColor: enabled ? null : Colors.grey.shade100,
          ),
        ),
      ],
    );
  }
}
