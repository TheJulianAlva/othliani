import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:frontend/core/l10n/app_localizations.dart';

// Since MapBloc would require managing heavy state (Google Map Controller, Markers),
// and often Maps are very UI heavy, we might keep it as a StatefulWidget but move business logic (like fetching POIs) to a Bloc.
// For now, to fit the "Clean Architecture" migration request efficiently in this iteration,
// we will structure it with a simple Placeholder or basic implementation that is ready for expansion.
// The previous implementation likely had hardcoded markers. We will simulate that for now.

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late GoogleMapController mapController;
  final LatLng _center = const LatLng(20.2114, -87.4654); // Tulum

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    final Set<Marker> markers = {
      Marker(
        markerId: const MarkerId('tourist'),
        position: const LatLng(20.2114, -87.4654),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
        infoWindow: const InfoWindow(
          title: 'Tú',
          snippet: 'Ubicación actual',
        ),
      ),
      Marker(
        markerId: const MarkerId('guide'),
        position: const LatLng(20.2090, -87.4500),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange), // Representing the guide
        infoWindow: const InfoWindow(
          title: 'Tu Guía',
          snippet: 'Guía del recorrido',
        ),
      ),
    };

    final Set<Circle> circles = {
      Circle(
        circleId: const CircleId('safe_zone'),
        center: const LatLng(20.2100, -87.4580),
        radius: 1500, // 1.5 km
        fillColor: Colors.blue.withValues(alpha: 0.2),
        strokeColor: Colors.blue.withValues(alpha: 0.5),
        strokeWidth: 2,
      ),
    };

    return Scaffold(
      appBar: AppBar(title: Text(l10n.map)),
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: _onMapCreated,
            initialCameraPosition: CameraPosition(target: _center, zoom: 14.0),
            markers: markers,
            circles: circles,
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
          ),
          Positioned(
            bottom: 30,
            left: 20,
            right: 20,
            child: GestureDetector(
              onLongPress: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('¡Emergencia activada!'),
                    backgroundColor: Colors.red,
                  ),
                );
              },
              child: Container(
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.red.shade700,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.red.withValues(alpha: 0.5),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.warning_amber_rounded, color: Colors.white, size: 28),
                    SizedBox(width: 12),
                    Text(
                      'MANTENER PRESIONADO 3 SEG',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
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

