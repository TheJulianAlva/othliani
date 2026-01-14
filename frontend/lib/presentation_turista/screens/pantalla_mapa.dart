import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../core/theme/app_constants.dart';
import 'package:frontend/core/l10n/app_localizations.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  Position? _currentPosition;
  bool _isLoading = true;
  bool _activitiesExpanded = false;

  final List<Map<String, String>> _currentActivities = [
    {
      'time': '10:00 AM',
      'title': 'Visita a zona arqueológica',
      'status': 'En curso',
      'description': 'Recorrido guiado por las pirámides del Sol y la Luna.',
    },
    {
      'time': '01:00 PM',
      'title': 'Comida en restaurante local',
      'status': 'Pendiente',
      'description': 'Degustación de platillos típicos de la región.',
    },
    {
      'time': '03:30 PM',
      'title': 'Tiempo libre en la playa',
      'status': 'Pendiente',
      'description': 'Relájate en las hermosas playas de arena blanca.',
    },
  ];

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
    final l10n = AppLocalizations.of(context)!;
    if (_currentPosition != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${l10n.currentLocation}: ${_currentPosition!.latitude.toStringAsFixed(4)}, ${_currentPosition!.longitude.toStringAsFixed(4)}',
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.locationNotAvailable)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Stack(
      children: [
        _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _buildMapPlaceholder(),

        if (_currentActivities.isNotEmpty)
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: Card(
              elevation: 8,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.5,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      InkWell(
                        onTap: () {
                          setState(() {
                            _activitiesExpanded = !_activitiesExpanded;
                          });
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(AppSpacing.md),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.directions_walk,
                                    color: theme.colorScheme.primary,
                                    size: 20,
                                  ),
                                  const SizedBox(width: AppSpacing.sm),
                                  Text(
                                    l10n.currentActivities,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                              Icon(
                                _activitiesExpanded
                                    ? Icons.expand_less
                                    : Icons.expand_more,
                                size: 24,
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (_activitiesExpanded)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(
                            AppSpacing.md,
                            0,
                            AppSpacing.md,
                            AppSpacing.md,
                          ),
                          child: Column(
                            children:
                                _currentActivities.map((activity) {
                                  return Padding(
                                    padding: const EdgeInsets.only(bottom: 12),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 8,
                                                    vertical: 4,
                                                  ),
                                              decoration: BoxDecoration(
                                                color:
                                                    activity['status'] ==
                                                            'En curso'
                                                        ? Colors.green
                                                            .withValues(
                                                              alpha: 0.2,
                                                            )
                                                        : Colors.grey
                                                            .withValues(
                                                              alpha: 0.2,
                                                            ),
                                                borderRadius:
                                                    BorderRadius.circular(4),
                                              ),
                                              child: Text(
                                                activity['time']!,
                                                style: TextStyle(
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.bold,
                                                  color:
                                                      activity['status'] ==
                                                              'En curso'
                                                          ? Colors.green
                                                          : Colors.grey[700],
                                                ),
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            Expanded(
                                              child: Text(
                                                activity['title']!,
                                                style: const TextStyle(
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          activity['description']!,
                                          style: TextStyle(
                                            fontSize: 12,
                                            color:
                                                theme
                                                    .textTheme
                                                    .bodySmall
                                                    ?.color,
                                          ),
                                        ),
                                        if (activity != _currentActivities.last)
                                          const Divider(height: 16),
                                      ],
                                    ),
                                  );
                                }).toList(),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),

        Positioned(
          bottom: 16,
          right: 16,
          child: FloatingActionButton(
            onPressed: _centerOnCurrentLocation,
            tooltip: l10n.centerOnLocation,
            mini: true,
            child: const Icon(Icons.my_location),
          ),
        ),
      ],
    );
  }

  Widget _buildMapPlaceholder() {
    final l10n = AppLocalizations.of(context)!;

    return Container(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Stack(
        children: [
          CustomPaint(size: Size.infinite, painter: _GridPainter()),
          Center(
            child: Card(
              margin: const EdgeInsets.all(16),
              elevation: 8,
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.map_outlined,
                      size: 64,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Vista Previa del Mapa',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Configura tu Google Maps API Key\npara ver el mapa real',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium,
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
                      Text(
                        l10n.locationNotAvailable,
                        style: const TextStyle(color: Colors.orange),
                      ),
                  ],
                ),
              ),
            ),
          ),
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
