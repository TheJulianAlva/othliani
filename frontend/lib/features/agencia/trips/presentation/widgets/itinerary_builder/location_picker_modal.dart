import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;

/// Modal de selección de ubicación para actividades del itinerario.
/// Devuelve un [LatLng] cuando el usuario confirma, o `null` si cancela.
///
/// [initialLocation]: ubicación previa de la actividad (si ya tenía).
/// [tripCenter]: coordenadas del destino del viaje — se usa como centro
///               inicial si aún no hay [initialLocation].
class LocationPickerModal extends StatefulWidget {
  final LatLng? initialLocation;
  final LatLng? tripCenter;

  const LocationPickerModal({super.key, this.initialLocation, this.tripCenter});

  @override
  State<LocationPickerModal> createState() => _LocationPickerModalState();
}

class _LocationPickerModalState extends State<LocationPickerModal> {
  LatLng? _pickedLocation;
  final MapController _mapController = MapController();

  // Barra de búsqueda
  final TextEditingController _searchCtrl = TextEditingController();
  Timer? _debounce;
  List<_NominatimResult> _suggestions = [];
  bool _isSearching = false;
  bool _showSuggestions = false;

  // Centro inicial: primero la ubicación ya guardada, luego la del viaje, luego CDMX
  static const LatLng _defaultCenter = LatLng(19.4326, -99.1332);

  LatLng get _initialCenter =>
      widget.initialLocation ?? widget.tripCenter ?? _defaultCenter;

  @override
  void initState() {
    super.initState();
    _pickedLocation = widget.initialLocation;
  }

  @override
  void dispose() {
    _mapController.dispose();
    _searchCtrl.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  // ── Búsqueda Nominatim ─────────────────────────────────────────────────────
  void _onSearchChanged(String query) {
    _debounce?.cancel();
    if (query.trim().length < 3) {
      setState(() {
        _suggestions = [];
        _showSuggestions = false;
      });
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 600), () => _search(query));
  }

  Future<void> _search(String query) async {
    setState(() => _isSearching = true);
    try {
      final uri = Uri.parse(
        'https://nominatim.openstreetmap.org/search'
        '?q=${Uri.encodeComponent(query)}'
        '&format=json&limit=5&addressdetails=1',
      );
      final response = await http.get(
        uri,
        headers: {'User-Agent': 'OthlianniApp/1.0'},
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          _suggestions = data.map((e) => _NominatimResult.fromJson(e)).toList();
          _showSuggestions = _suggestions.isNotEmpty;
        });
      }
    } catch (_) {
    } finally {
      if (mounted) setState(() => _isSearching = false);
    }
  }

  void _selectSuggestion(_NominatimResult result) {
    final latlng = LatLng(result.lat, result.lng);
    setState(() {
      _pickedLocation = latlng;
      _suggestions = [];
      _showSuggestions = false;
      _searchCtrl.text = result.displayName;
    });
    _mapController.move(latlng, 15.0);
  }

  // ──────────────────────────────────────────────────────────────────────────
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
        // ── Barra de búsqueda en la parte inferior del AppBar ───────────
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
            child: TextField(
              controller: _searchCtrl,
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Buscar lugar o dirección...',
                prefixIcon:
                    _isSearching
                        ? const Padding(
                          padding: EdgeInsets.all(12),
                          child: SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        )
                        : const Icon(Icons.search, size: 20),
                suffixIcon:
                    _searchCtrl.text.isNotEmpty
                        ? IconButton(
                          icon: const Icon(Icons.clear, size: 18),
                          onPressed: () {
                            _searchCtrl.clear();
                            setState(() {
                              _suggestions = [];
                              _showSuggestions = false;
                            });
                          },
                        )
                        : null,
                filled: true,
                fillColor: Colors.grey[100],
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 8,
                  horizontal: 12,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide(
                    color: colorScheme.primary,
                    width: 1.5,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          // ── Mapa interactivo ────────────────────────────────────────────
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _initialCenter,
              initialZoom: 14.0,
              onTap: (tapPosition, latlng) {
                setState(() {
                  _pickedLocation = latlng;
                  _showSuggestions = false;
                });
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

          // ── Lista de sugerencias de búsqueda ──────────────────────────
          if (_showSuggestions && _suggestions.isNotEmpty)
            Positioned(
              top: 0,
              left: 12,
              right: 12,
              child: Material(
                elevation: 6,
                borderRadius: BorderRadius.circular(12),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _suggestions.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, i) {
                      final s = _suggestions[i];
                      return ListTile(
                        dense: true,
                        leading: const Icon(
                          Icons.location_on_outlined,
                          size: 18,
                          color: Colors.grey,
                        ),
                        title: Text(
                          s.displayName,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 13),
                        ),
                        onTap: () => _selectSuggestion(s),
                      );
                    },
                  ),
                ),
              ),
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
                        text: 'Busca un lugar o toca el mapa para fijar el pin',
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

// ── Modelo para resultado de Nominatim ──────────────────────────────────────
class _NominatimResult {
  final String displayName;
  final double lat;
  final double lng;

  _NominatimResult({
    required this.displayName,
    required this.lat,
    required this.lng,
  });

  factory _NominatimResult.fromJson(Map<String, dynamic> j) => _NominatimResult(
    displayName: j['display_name'] as String? ?? '',
    lat: double.tryParse(j['lat'] as String? ?? '0') ?? 0,
    lng: double.tryParse(j['lon'] as String? ?? '0') ?? 0,
  );
}
