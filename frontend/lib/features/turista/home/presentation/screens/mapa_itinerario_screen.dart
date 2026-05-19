import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:frontend/core/demo/demo_config.dart';
import 'package:frontend/core/di/service_locator.dart';
import 'package:frontend/features/turista/home/domain/entities/itinerary_item.dart';
import 'package:frontend/features/turista/home/presentation/bloc/itinerary_bloc.dart';
import 'package:frontend/features/turista/home/presentation/bloc/itinerary_event.dart';
import 'package:frontend/features/turista/home/presentation/bloc/itinerary_state.dart';

class MapaItinerarioScreen extends StatelessWidget {
  const MapaItinerarioScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          sl<ItineraryBloc>()..add(const LoadItinerary(kDemoTripId)),
      child: const _MapaItinerarioView(),
    );
  }
}

class _MapaItinerarioView extends StatefulWidget {
  const _MapaItinerarioView();

  @override
  State<_MapaItinerarioView> createState() => _MapaItinerarioViewState();
}

class _MapaItinerarioViewState extends State<_MapaItinerarioView> {
  GoogleMapController? _mapController;

  void _fitBounds(List<ItineraryItem> items) {
    final coords = items
        .where((e) => e.hasCoordinates)
        .map((e) => LatLng(e.latitude!, e.longitude!))
        .toList();
    if (coords.isEmpty || _mapController == null) return;

    double minLat = coords.first.latitude;
    double maxLat = coords.first.latitude;
    double minLng = coords.first.longitude;
    double maxLng = coords.first.longitude;

    for (final c in coords) {
      if (c.latitude < minLat) minLat = c.latitude;
      if (c.latitude > maxLat) maxLat = c.latitude;
      if (c.longitude < minLng) minLng = c.longitude;
      if (c.longitude > maxLng) maxLng = c.longitude;
    }

    _mapController!.animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(
          southwest: LatLng(minLat, minLng),
          northeast: LatLng(maxLat, maxLng),
        ),
        60,
      ),
    );
  }

  Set<Marker> _buildMarkers(List<ItineraryItem> items) {
    final now = DateTime.now();
    return {
      for (var i = 0; i < items.length; i++)
        if (items[i].hasCoordinates)
          Marker(
            markerId: MarkerId(items[i].id),
            position: LatLng(items[i].latitude!, items[i].longitude!),
            icon: BitmapDescriptor.defaultMarkerWithHue(
              items[i].endTime.isBefore(now)
                  ? BitmapDescriptor.hueGreen
                  : items[i].startTime.isBefore(now)
                  ? BitmapDescriptor.hueOrange
                  : BitmapDescriptor.hueAzure,
            ),
            onTap: () => _showEventSheet(context, items[i]),
          ),
    };
  }

  void _showEventSheet(BuildContext context, ItineraryItem item) {
    final timeStr =
        '${_fmt(item.startTime)} – ${_fmt(item.endTime)}';
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            Text(
              item.title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.access_time, size: 16, color: Colors.grey),
                const SizedBox(width: 6),
                Text(
                  timeStr,
                  style: const TextStyle(color: Colors.grey, fontSize: 13),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(
                  Icons.place_outlined,
                  size: 16,
                  color: Colors.grey,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    item.location,
                    style: const TextStyle(color: Colors.grey, fontSize: 13),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              item.description,
              style: const TextStyle(fontSize: 14, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }

  String _fmt(DateTime dt) =>
      '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Itinerario en mapa'),
        centerTitle: true,
      ),
      body: BlocConsumer<ItineraryBloc, ItineraryState>(
        listener: (context, state) {
          if (state is ItineraryLoaded) {
            WidgetsBinding.instance.addPostFrameCallback(
              (_) => _fitBounds(state.items),
            );
          }
        },
        builder: (context, state) {
          if (state is ItineraryLoading || state is ItineraryInitial) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is ItineraryError) {
            return Center(child: Text(state.message));
          }
          final items = (state as ItineraryLoaded).items;
          return Stack(
            children: [
              Positioned.fill(
                child: GoogleMap(
                  onMapCreated: (controller) {
                    _mapController = controller;
                    _fitBounds(items);
                  },
                  initialCameraPosition: const CameraPosition(
                    target: LatLng(20.2116, -87.4291),
                    zoom: 10,
                  ),
                  markers: _buildMarkers(items),
                  myLocationEnabled: true,
                  myLocationButtonEnabled: false,
                  zoomControlsEnabled: false,
                ),
              ),
              // Leyenda de colores
              Positioned(
                bottom: 24,
                left: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.15),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _LegendItem(color: Colors.green, label: 'Completada'),
                      SizedBox(height: 4),
                      _LegendItem(color: Colors.orange, label: 'En curso'),
                      SizedBox(height: 4),
                      _LegendItem(color: Colors.blue, label: 'Pendiente'),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}
