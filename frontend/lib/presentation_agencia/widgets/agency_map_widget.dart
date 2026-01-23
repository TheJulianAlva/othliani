import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class AgencyMapWidget extends StatelessWidget {
  const AgencyMapWidget({super.key});

  @override
  Widget build(BuildContext context) {
    // Center: Mexico City (Example)
    final center = LatLng(19.4326, -99.1332);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          FlutterMap(
            options: MapOptions(initialCenter: center, initialZoom: 13.0),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.othliani.app',
              ),
              MarkerLayer(
                markers: [
                  // Normal Trip
                  _buildMarker(
                    LatLng(19.4326, -99.1332),
                    Colors.green,
                    Icons.directions_bus,
                  ),
                  // Warning Trip (Low Battery)
                  _buildMarker(
                    LatLng(19.4200, -99.1500),
                    Colors.amber,
                    Icons.battery_alert,
                  ),
                  // Critical SOS
                  _buildMarker(
                    LatLng(19.4400, -99.1200),
                    Colors.red,
                    Icons.warning,
                  ),
                  // Cluster (Simulated visually as a bigger marker for now)
                  _buildMarker(
                    LatLng(19.4100, -99.1600),
                    const Color(0xFF0F4C75),
                    Icons.filter_9_plus, // Represents a cluster/group
                    isCluster: true,
                  ),
                ],
              ),
            ],
          ),

          // Legend Overlay
          Positioned(
            bottom: 16,
            left: 16,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(4),
                boxShadow: const [
                  BoxShadow(blurRadius: 4, color: Colors.black26),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLegendItem(Colors.green, 'Normal'),
                  const SizedBox(height: 4),
                  _buildLegendItem(Colors.amber, 'Riesgo'),
                  const SizedBox(height: 4),
                  _buildLegendItem(Colors.red, 'SOS'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Marker _buildMarker(
    LatLng point,
    Color color,
    IconData icon, {
    bool isCluster = false,
  }) {
    return Marker(
      point: point,
      width: 40,
      height: 40,
      child: Tooltip(
        message: isCluster ? '5 Viajes en Zona' : 'Ver Detalles',
        child: Container(
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: const [BoxShadow(blurRadius: 4, color: Colors.black38)],
          ),
          child: Icon(icon, color: Colors.white, size: 20),
        ),
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      children: [
        CircleAvatar(radius: 4, backgroundColor: color),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
