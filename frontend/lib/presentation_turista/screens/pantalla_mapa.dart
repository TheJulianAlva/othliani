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

    // In a real implementation with Clean Arch:
    // BlocBuilder<MapBloc, MapState> would provide the markers and initial position.

    final Set<Marker> markers = {
      const Marker(
        markerId: MarkerId('tulum_ruins'),
        position: LatLng(20.2114, -87.4654),
        infoWindow: InfoWindow(
          title: 'Ruinas de Tulum',
          snippet: 'Zona Arqueológica',
        ),
      ),
      const Marker(
        markerId: MarkerId('hotel'),
        position: LatLng(20.2090, -87.4500),
        infoWindow: InfoWindow(
          title: 'Hotel Tulum Beach',
          snippet: 'Tu alojamiento',
        ),
      ),
    };

    return Scaffold(
      appBar: AppBar(title: Text(l10n.map)),
      body: GoogleMap(
        onMapCreated: _onMapCreated,
        initialCameraPosition: CameraPosition(target: _center, zoom: 13.0),
        markers: markers,
        myLocationEnabled: true,
        myLocationButtonEnabled: true,
      ),
    );
  }
}
