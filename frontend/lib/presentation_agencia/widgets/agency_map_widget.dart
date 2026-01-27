import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:go_router/go_router.dart';

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
                    point: LatLng(19.4326, -99.1332),
                    color: Colors.green,
                    icon: Icons.directions_bus,
                    onTap: () => context.go('/viajes/305/detalle'),
                  ),
                  // Warning Trip (Low Battery)
                  _buildMarker(
                    point: LatLng(19.4200, -99.1500),
                    color: Colors.amber,
                    icon: Icons.battery_alert,
                    onTap:
                        () => context.go(
                          '/viajes/110/detalle?focus_user=Luis+P.',
                        ),
                  ),
                  // Critical SOS
                  _buildMarker(
                    point: LatLng(19.4400, -99.1200),
                    color: Colors.red,
                    icon: Icons.warning,
                    onTap:
                        () => context.go(
                          '/viajes/204/detalle?focus_user=Ana+G.&open_modal=true',
                        ),
                  ),
                  // Cluster (Simulated visually as a bigger marker for now)
                  _buildMarker(
                    point: LatLng(19.4100, -99.1600),
                    color: const Color(0xFF0F4C75),
                    icon: Icons.filter_9_plus,
                    isCluster: true,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('🔍 Acercando vista de clúster...'),
                          duration: Duration(seconds: 1),
                        ),
                      );
                    },
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

  Marker _buildMarker({
    required LatLng point,
    required Color color,
    required IconData icon,
    bool isCluster = false,
    VoidCallback? onTap,
  }) {
    return Marker(
      point: point,
      width: 40,
      height: 40,
      child: GestureDetector(
        onTap: onTap,
        child: Tooltip(
          message: isCluster ? '5 Viajes en Zona' : 'Ver Detalles',
          child: Container(
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
              boxShadow: const [
                BoxShadow(blurRadius: 4, color: Colors.black38),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
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
