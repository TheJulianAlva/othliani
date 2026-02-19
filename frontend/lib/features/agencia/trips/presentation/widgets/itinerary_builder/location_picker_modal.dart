import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

/// Modal de selección de ubicación para actividades del itinerario.
/// Devuelve un [LatLng] cuando el usuario confirma, o `null` si cancela.
class LocationPickerModal extends StatefulWidget {
  final LatLng? initialLocation;

  const LocationPickerModal({super.key, this.initialLocation});

  @override
  State<LocationPickerModal> createState() => _LocationPickerModalState();
}

class _LocationPickerModalState extends State<LocationPickerModal> {
  LatLng? _pickedLocation;
  final MapController _mapController = MapController();

  // Centro por defecto: CDMX
  static const LatLng _defaultCenter = LatLng(19.4326, -99.1332);

  @override
  void initState() {
    super.initState();
    _pickedLocation = widget.initialLocation;
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Seleccionar Ubicación',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: TextButton.icon(
              style: TextButton.styleFrom(
                backgroundColor:
                    _pickedLocation != null
                        ? colorScheme.primary
                        : Colors.grey[300],
                foregroundColor:
                    _pickedLocation != null ? Colors.white : Colors.grey[500],
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              icon: const Icon(Icons.check, size: 18),
              label: const Text(
                'Confirmar',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              onPressed:
                  _pickedLocation == null
                      ? null
                      : () => Navigator.pop(context, _pickedLocation),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          // ── Mapa interactivo ────────────────────────────────────────────
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: widget.initialLocation ?? _defaultCenter,
              initialZoom: 14.0,
              onTap: (tapPosition, latlng) {
                setState(() => _pickedLocation = latlng);
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.othliani.app',
              ),
              // Marker del punto seleccionado
              if (_pickedLocation != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _pickedLocation!,
                      width: 48,
                      height: 48,
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: colorScheme.primary,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: colorScheme.primary.withValues(
                                    alpha: 0.4,
                                  ),
                                  blurRadius: 10,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.location_on,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                          // "Punta" del pin
                          Container(
                            width: 3,
                            height: 8,
                            color: colorScheme.primary,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
            ],
          ),

          // ── Botón de re-centrar al punto marcado ────────────────────────
          if (_pickedLocation != null)
            Positioned(
              top: 16,
              right: 16,
              child: FloatingActionButton.small(
                heroTag: 'recenter_picker',
                backgroundColor: Colors.white,
                foregroundColor: colorScheme.primary,
                elevation: 4,
                onPressed: () => _mapController.move(_pickedLocation!, 14.0),
                child: const Icon(Icons.center_focus_strong, size: 18),
              ),
            ),

          // ── Instrucción flotante inferior ───────────────────────────────
          Positioned(
            bottom: 28,
            left: 24,
            right: 24,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child:
                  _pickedLocation == null
                      ? _buildInstructionBanner(
                        key: const ValueKey('hint'),
                        icon: Icons.touch_app,
                        text: 'Toca el mapa para colocar el pin exacto',
                        color: Colors.blue[800]!,
                        bgColor: Colors.blue[50]!,
                      )
                      : _buildInstructionBanner(
                        key: const ValueKey('coords'),
                        icon: Icons.gps_fixed,
                        text:
                            '${_pickedLocation!.latitude.toStringAsFixed(5)}, '
                            '${_pickedLocation!.longitude.toStringAsFixed(5)}',
                        color: Colors.green[800]!,
                        bgColor: Colors.green[50]!,
                      ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInstructionBanner({
    required Key key,
    required IconData icon,
    required String text,
    required Color color,
    required Color bgColor,
  }) {
    return Container(
      key: key,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: color.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              text,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: color,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
