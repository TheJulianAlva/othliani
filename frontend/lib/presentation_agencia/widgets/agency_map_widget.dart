import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:go_router/go_router.dart';
import '../../domain/entities/viaje.dart';

class AgencyMapWidget extends StatelessWidget {
  final List<Viaje> viajes;

  const AgencyMapWidget({super.key, this.viajes = const []});

  @override
  Widget build(BuildContext context) {
    // Default Center: Mexico City if no trips, else center on first trip
    final center =
        viajes.isNotEmpty
            ? LatLng(viajes.first.latitud, viajes.first.longitud)
            : LatLng(19.4326, -99.1332);

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
            options: MapOptions(initialCenter: center, initialZoom: 10.0),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.othliani.app',
              ),
              MarkerLayer(
                markers:
                    viajes.map((viaje) {
                      return _buildMarker(
                        point: LatLng(viaje.latitud, viaje.longitud),
                        color: _getColorForStatus(viaje.estado),
                        icon: Icons.directions_bus,
                        onTap: () => context.go('/viajes/${viaje.id}'),
                        tooltip: 'Viaje #${viaje.id} - ${viaje.destino}',
                      );
                    }).toList(),
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
                  _buildLegendItem(Colors.green, 'En Curso'),
                  const SizedBox(height: 4),
                  _buildLegendItem(Colors.blue, 'Programado'),
                  const SizedBox(height: 4),
                  _buildLegendItem(Colors.grey, 'Finalizado'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getColorForStatus(String estado) {
    switch (estado) {
      case 'EN_CURSO':
        return Colors.green;
      case 'PROGRAMADO':
        return Colors.blue;
      case 'FINALIZADO':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  Marker _buildMarker({
    required LatLng point,
    required Color color,
    required IconData icon,
    required String tooltip,
    VoidCallback? onTap,
  }) {
    return Marker(
      point: point,
      width: 40,
      height: 40,
      child: GestureDetector(
        onTap: onTap,
        child: Tooltip(
          message: tooltip,
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
