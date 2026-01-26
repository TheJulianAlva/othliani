import 'package:flutter/material.dart';

class SecuritySettings extends StatefulWidget {
  const SecuritySettings({super.key});

  @override
  State<SecuritySettings> createState() => _SecuritySettingsState();
}

class _SecuritySettingsState extends State<SecuritySettings> {
  double _geofenceRadius = 50;
  double _timeoutMinutes = 5;
  bool _stopDetection = true;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Seguridad Operativa (Valores por Defecto)',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Estos valores se aplicarán automáticamente a los nuevos viajes, pero podrás modificarlos en cada expedición.',
            style: TextStyle(color: Colors.grey.shade600),
          ),
          const SizedBox(height: 32),

          // Geofence Radius
          const Text(
            'Radio de Alejamiento (Geocerca)',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.radar, color: Colors.blueGrey),
              const SizedBox(width: 16),
              Expanded(
                child: Slider(
                  value: _geofenceRadius,
                  min: 10,
                  max: 200,
                  divisions: 19,
                  label: '${_geofenceRadius.round()} metros',
                  onChanged: (value) => setState(() => _geofenceRadius = value),
                ),
              ),
              Container(
                width: 100,
                alignment: Alignment.center,
                child: Text(
                  '${_geofenceRadius.round()} metros',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.amber.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.amber.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.warning_amber_rounded, color: Colors.amber.shade800),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Nota: Un radio menor a 20m puede generar falsas alarmas en zonas montañosas debido a la imprecisión del GPS.',
                    style: TextStyle(
                      color: Colors.amber.shade900,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // Timeout
          const Text(
            'Tiempo de Desconexión (Timeout)',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.timer_off_outlined, color: Colors.blueGrey),
              const SizedBox(width: 16),
              Expanded(
                child: Slider(
                  value: _timeoutMinutes,
                  min: 1,
                  max: 60,
                  divisions: 59,
                  label: '${_timeoutMinutes.round()} minutos',
                  onChanged: (value) => setState(() => _timeoutMinutes = value),
                ),
              ),
              Container(
                width: 100,
                alignment: Alignment.center,
                child: Text(
                  '${_timeoutMinutes.round()} mins',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 32),
          const Divider(),
          const SizedBox(height: 24),

          // Stop Detection Switch
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Activar detección de paradas inesperadas'),
            subtitle: const Text(
              'Utiliza IA para identificar detenciones no programadas en ruta.',
            ),
            value: _stopDetection,
            onChanged: (val) => setState(() => _stopDetection = val),
            activeThumbColor: Theme.of(context).primaryColor,
          ),

          const SizedBox(height: 40),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.save),
              label: const Text('Guardar Configuración'),
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
