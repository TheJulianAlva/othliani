import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:frontend/core/demo/demo_config.dart';
import 'package:frontend/core/di/service_locator.dart';
import 'package:frontend/core/theme/veltur_tokens.dart';
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
    final tokens = VelturTokens.of(context);
    final textTheme = Theme.of(context).textTheme;
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(tokens.radiusLg),
        ),
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
                  color: tokens.border,
                  borderRadius: BorderRadius.circular(tokens.radiusFull),
                ),
              ),
            ),
            Text(item.title, style: textTheme.titleLarge),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.access_time, size: 16, color: tokens.textMuted),
                const SizedBox(width: 6),
                Text(
                  timeStr,
                  style: textTheme.labelLarge?.copyWith(
                    color: tokens.textMuted,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Icon(
                  Icons.place_outlined,
                  size: 16,
                  color: tokens.textMuted,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    item.location,
                    style: textTheme.labelLarge?.copyWith(
                      color: tokens.textMuted,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(item.description, style: textTheme.bodyLarge),
          ],
        ),
      ),
    );
  }

  String _fmt(DateTime dt) =>
      '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final tokens = VelturTokens.of(context);
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
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(tokens.radiusMd),
                    boxShadow: tokens.shadowSm,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _LegendItem(color: tokens.safe, label: 'Completada'),
                      const SizedBox(height: 4),
                      _LegendItem(color: tokens.warn, label: 'En curso'),
                      const SizedBox(height: 4),
                      _LegendItem(
                        color: tokens.textMuted,
                        label: 'Pendiente',
                      ),
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
        Text(label, style: Theme.of(context).textTheme.labelLarge),
      ],
    );
  }
}
