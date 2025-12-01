import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import '../widgets/walkie_talkie_button.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  Position? _currentPosition;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeLocation();
  }

  Future<void> _initializeLocation() async {
    await _requestLocationPermission();
    await _getCurrentLocation();
  }

  Future<void> _requestLocationPermission() async {
    final status = await Permission.location.request();
    if (status.isDenied || status.isPermanentlyDenied) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Se requieren permisos de ubicación para usar el mapa',
            ),
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() => _isLoading = false);
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() => _isLoading = false);
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() => _isLoading = false);
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _currentPosition = position;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al obtener ubicación: $e')),
        );
      }
    }
  }

  void _centerOnCurrentLocation() {
    if (_currentPosition != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Ubicación actual: ${_currentPosition!.latitude.toStringAsFixed(4)}, ${_currentPosition!.longitude.toStringAsFixed(4)}',
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Ubicación no disponible')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mapa Interactivo'),
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location),
            onPressed: _centerOnCurrentLocation,
            tooltip: 'Centrar en mi ubicación',
          ),
        ],
      ),
      body: Stack(
        children: [
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _buildMapPlaceholder(),
          const WalkieTalkieButton(),
        ],
      ),
    );
  }

  Widget _buildMapPlaceholder() {
    return Container(
      color: Colors.grey[200],
      child: Stack(
        children: [
          // Grid pattern to simulate map
          CustomPaint(size: Size.infinite, painter: _GridPainter()),
          // Location info overlay
          Center(
            child: Card(
              margin: const EdgeInsets.all(16),
              elevation: 8,
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.map_outlined,
                      size: 64,
                      color: Colors.blue,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Vista Previa del Mapa',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Configura tu Google Maps API Key\npara ver el mapa real',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 16),
                    if (_currentPosition != null) ...[
                      const Divider(),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.location_on, color: Colors.green),
                          const SizedBox(width: 8),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Lat: ${_currentPosition!.latitude.toStringAsFixed(6)}',
                                style: const TextStyle(
                                  fontFamily: 'monospace',
                                  fontSize: 12,
                                ),
                              ),
                              Text(
                                'Lng: ${_currentPosition!.longitude.toStringAsFixed(6)}',
                                style: const TextStyle(
                                  fontFamily: 'monospace',
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ] else
                      const Text(
                        'Ubicación no disponible',
                        style: TextStyle(color: Colors.orange),
                      ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () {
                        // Open setup guide
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Configurar Google Maps'),
                            content: const SingleChildScrollView(
                              child: Text(
                                '1. Ve a console.cloud.google.com\n'
                                '2. Crea un proyecto\n'
                                '3. Habilita Maps SDK for Android/iOS\n'
                                '4. Crea una API Key\n'
                                '5. Configúrala en AndroidManifest.xml\n\n'
                                'Ver GOOGLE_MAPS_SETUP.md para más detalles',
                              ),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Entendido'),
                              ),
                            ],
                          ),
                        );
                      },
                      icon: const Icon(Icons.help_outline),
                      label: const Text('Cómo configurar'),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Simulated marker for current location
          if (_currentPosition != null)
            Positioned(
              top: MediaQuery.of(context).size.height * 0.3,
              left: MediaQuery.of(context).size.width * 0.5 - 20,
              child: const Icon(Icons.location_on, size: 40, color: Colors.red),
            ),
        ],
      ),
    );
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey[300]!
      ..strokeWidth = 1;

    const gridSize = 50.0;

    // Draw vertical lines
    for (double x = 0; x < size.width; x += gridSize) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    // Draw horizontal lines
    for (double y = 0; y < size.height; y += gridSize) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
