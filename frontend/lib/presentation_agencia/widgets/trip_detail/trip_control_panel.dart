import 'package:flutter/material.dart';
import '../../../domain/entities/viaje.dart';

class TripControlPanel extends StatelessWidget {
  final Viaje viaje;

  const TripControlPanel({super.key, required this.viaje});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Status Banner
            Container(
              padding: const EdgeInsets.all(8),
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(color: Colors.blue.shade100),
              ),
              child: Center(
                child: Text(
                  'DESTINO: ${viaje.destino}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    color: Colors.blue,
                  ),
                ),
              ),
            ),

            // 1. Guide Card
            const Text(
              'GUÍA RESPONSABLE',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      const CircleAvatar(
                        backgroundImage: NetworkImage(
                          'https://i.pravatar.cc/150?u=guide',
                        ),
                        radius: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Guía Asignado',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            const Text(
                              'Líder',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Stats
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildStat(Icons.battery_full, '85%', Colors.green),
                      Container(
                        height: 16,
                        width: 1,
                        color: Colors.grey.shade300,
                      ),
                      _buildStat(Icons.signal_cellular_alt, '4G', Colors.blue),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Actions - Stacked Vertical for narrow space
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      OutlinedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.call, size: 14),
                        label: const Text(
                          'Llamar',
                          style: TextStyle(fontSize: 12),
                        ),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                      ),
                      const SizedBox(height: 8),
                      OutlinedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.chat, size: 14),
                        label: const Text(
                          'Chat',
                          style: TextStyle(fontSize: 12),
                        ),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const Divider(height: 32),

            // 2. Safety Parameters
            const Text(
              'PARÁMETROS SEGURIDAD',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 16),
            _buildSliderControl('Radio', '50m', 0.2),
            const SizedBox(height: 16),
            _buildSliderControl('Timeout', '5m', 0.5),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.sync, size: 16),
                label: const Text('ACTUALIZAR', style: TextStyle(fontSize: 11)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0F4C75),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),

            const Divider(height: 32),

            // 3. Quick Logs
            const Text(
              'BITÁCORA RÁPIDA',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 12),
            // Use Column here, not Expanded ListView, because we are in a SingleChildScrollView
            Column(
              children: [
                _buildLogItem('10:42', 'Alerta Pánico: Ana G.', Colors.red),
                _buildLogItem('10:15', 'Checkpoint #1 Alcanzado', Colors.blue),
                _buildLogItem('10:00', 'Inicio de Ruta', Colors.grey),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStat(IconData icon, String value, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildSliderControl(String label, String value, double sliderVal) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontSize: 12)),
            Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            ),
          ],
        ),
        SliderTheme(
          data: SliderThemeData(
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
            trackHeight: 2,
            activeTrackColor: Colors.blue.shade800,
            inactiveTrackColor: Colors.grey.shade200,
          ),
          child: Slider(value: sliderVal, onChanged: (v) {}),
        ),
      ],
    );
  }

  Widget _buildLogItem(String time, String message, Color dotColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(time, style: const TextStyle(color: Colors.grey, fontSize: 11)),
          const SizedBox(width: 8),
          Container(
            margin: const EdgeInsets.only(top: 5),
            width: 6,
            height: 6,
            decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(fontSize: 12),
              overflow: TextOverflow.visible, // Wrapping allowed
            ),
          ),
        ],
      ),
    );
  }
}
