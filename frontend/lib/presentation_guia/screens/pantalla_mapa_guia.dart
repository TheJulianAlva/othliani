import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class MapScreenGuia extends StatefulWidget {
  const MapScreenGuia({super.key});

  @override
  State<MapScreenGuia> createState() => _MapScreenGuiaState();
}

class _MapScreenGuiaState extends State<MapScreenGuia> {
  Position? _currentPosition;
  bool _isLoading = true;
  Position? _meetingPoint;

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

  void _setMeetingPoint() {
    if (_currentPosition != null) {
      setState(() {
        _meetingPoint = _currentPosition;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Punto de reunión establecido en tu ubicación actual'),
        ),
      );
      // In a real app, this would send a notification to all tourists
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Stack(
        children: [
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _buildMapPlaceholder(theme),

          // Meeting Point Button
          Positioned(
            bottom: 16,
            left: 16,
            child: FloatingActionButton.extended(
              onPressed: _setMeetingPoint,
              icon: const Icon(Icons.flag),
              label: const Text('Establecer Punto de Reunión'),
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
            ),
          ),

          // Center Location Button
          Positioned(
            bottom: 16,
            right: 16,
            child: FloatingActionButton(
              onPressed: _getCurrentLocation,
              mini: true,
              child: const Icon(Icons.my_location),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapPlaceholder(ThemeData theme) {
    return Container(
      color: theme.colorScheme.surfaceContainerHighest,
      child: Stack(
        children: [
          CustomPaint(size: Size.infinite, painter: _GridPainter()),

          // Guide Marker (Current Location)
          if (_currentPosition != null)
            Positioned(
              top: MediaQuery.of(context).size.height * 0.5 - 20,
              left: MediaQuery.of(context).size.width * 0.5 - 20,
              child: Column(
                children: [
                  const Icon(
                    Icons.person_pin_circle,
                    size: 40,
                    color: Colors.blue,
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'Tú (Guía)',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // Meeting Point Marker
          if (_meetingPoint != null)
            Positioned(
              top:
                  MediaQuery.of(context).size.height * 0.5 -
                  20, // Same as guide for demo
              left: MediaQuery.of(context).size.width * 0.5 - 20,
              child: const Icon(Icons.flag, size: 40, color: Colors.red),
            ),

          // Mock Tourists
          Positioned(
            top: MediaQuery.of(context).size.height * 0.4,
            left: MediaQuery.of(context).size.width * 0.3,
            child: Column(
              children: [
                const Icon(
                  Icons.directions_walk,
                  size: 30,
                  color: Colors.green,
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text('Juan', style: TextStyle(fontSize: 10)),
                ),
              ],
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).size.height * 0.6,
            left: MediaQuery.of(context).size.width * 0.7,
            child: Column(
              children: [
                const Icon(
                  Icons.directions_walk,
                  size: 30,
                  color: Colors.orange,
                ), // Warning color
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'Maria (Lejos)',
                    style: TextStyle(fontSize: 10),
                  ),
                ),
              ],
            ),
          ),

          // Info Card
          Positioned(
            top: 40,
            left: 16,
            right: 16,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  children: [
                    Text(
                      'Monitoreo de Grupo',
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    const Text('2 Turistas conectados'),
                    const Text(
                      '1 Turista fuera de rango (Simulado)',
                      style: TextStyle(color: Colors.orange),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = Colors.grey[300]!
          ..strokeWidth = 1;

    const gridSize = 50.0;

    for (double x = 0; x < size.width; x += gridSize) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    for (double y = 0; y < size.height; y += gridSize) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
