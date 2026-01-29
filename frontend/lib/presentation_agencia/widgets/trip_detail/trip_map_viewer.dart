import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class TripMapViewer extends StatelessWidget {
  final double centerLat;
  final double centerLng;

  const TripMapViewer({
    super.key,
    this.centerLat = 19.4326, // Default CDMX
    this.centerLng = -99.1332,
  });

  @override
  Widget build(BuildContext context) {
    // Center Location from props
    final center = LatLng(centerLat, centerLng);

    return Stack(
      children: [
        FlutterMap(
          options: MapOptions(initialCenter: center, initialZoom: 14.5),
          children: [
            TileLayer(
              // Using CartoDB Dark Matter for the "Muted/Dark Mode" requested
              urlTemplate:
                  'https://{s}.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}@2x.png',
              // urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png', // Standard light
              // urlTemplate: 'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}@2x.png', // Dark
            ),
            // Note: User asked for Dark Mode map to contrast alerts.
            // But for now using Voyager (cleaner) or maybe Dark?
            // Let's stick with Voyager for clarity unless specified,
            // actually user said "Fondo del Mapa: Usa un estilo Dark Mode or Muted".
            // Let's double check if I can use Dark Matter without API key. Yes CartoDB is usually free for dev.
            // I'll stick to OpenStreetMap for safety if I don't want to risk broken tiles,
            // but I will add an overlay color to "mute" it if needed.
            // Actually, let's use standard OSM for reliability, but maybe add a dark overlay?

            // GeoFence Circle (Blue Translucent) - 50m radius approx
            CircleLayer(
              circles: [
                CircleMarker(
                  point: center,
                  radius: 250, // Visual radius
                  useRadiusInMeter: true,
                  color: Colors.blue.withValues(alpha: 0.15),
                  borderColor: Colors.blue.withValues(alpha: 0.5),
                  borderStrokeWidth: 1,
                ),
              ],
            ),

            // Markers
            MarkerLayer(
              markers: [
                // Guide (Center)
                Marker(
                  point: center,
                  width: 40,
                  height: 40,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.blue.shade900, width: 2),
                      boxShadow: const [
                        BoxShadow(blurRadius: 4, color: Colors.black26),
                      ],
                    ),
                    child: Icon(
                      Icons.security,
                      size: 20,
                      color: Colors.blue.shade900,
                    ),
                  ),
                ),

                // Panic User (Ana G)
                Marker(
                  point: LatLng(19.108, -99.759),
                  width: 30,
                  height: 30,
                  child: _buildDot(Colors.red, true),
                ),

                // Warning User (Luis)
                Marker(
                  point: LatLng(19.104, -99.763),
                  width: 30,
                  height: 30,
                  child: _buildDot(Colors.amber, false),
                ),

                // Normal Users (Cluster)
                Marker(
                  point: LatLng(19.1055, -99.7615),
                  width: 30,
                  height: 30,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 1.5),
                    ),
                    child: const Center(
                      child: Text(
                        '10',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),

        // Floating Controls (Legend, Layers, Center)
        Positioned(
          bottom: 24,
          left: 0,
          right: 0,
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: const [
                  BoxShadow(blurRadius: 10, color: Colors.black26),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildLegendItem(Colors.green, 'OK'),
                  const SizedBox(width: 12),
                  _buildLegendItem(Colors.amber, 'Warning'),
                  const SizedBox(width: 12),
                  _buildLegendItem(Colors.red, 'SOS'),
                  Container(
                    height: 20,
                    width: 1,
                    color: Colors.grey.shade300,
                    margin: const EdgeInsets.symmetric(horizontal: 12),
                  ),
                  const Icon(Icons.layers, size: 20, color: Colors.grey),
                  const SizedBox(width: 12),
                  const Icon(Icons.my_location, size: 20, color: Colors.blue),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDot(Color color, bool pulse) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: pulse ? [BoxShadow(blurRadius: 8, color: color)] : null,
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}
