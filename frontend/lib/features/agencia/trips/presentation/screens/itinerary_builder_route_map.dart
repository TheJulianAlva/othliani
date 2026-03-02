import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../blocs/itinerary_builder/itinerary_builder_cubit.dart';
import '../../domain/entities/actividad_itinerario.dart';

// ==========================================================
// ✨ MAPA DE RUTA DEL DÍA
// ==========================================================
class DayRouteMap extends StatefulWidget {
  const DayRouteMap({super.key});

  @override
  State<DayRouteMap> createState() => _DayRouteMapState();
}

class _DayRouteMapState extends State<DayRouteMap> {
  final MapController _mapCtrl = MapController();

  @override
  void dispose() {
    _mapCtrl.dispose();
    super.dispose();
  }

  Color _colorForType(TipoActividad tipo) {
    switch (tipo) {
      case TipoActividad.hospedaje:
        return Colors.purple;
      case TipoActividad.comida:
        return Colors.orange;
      case TipoActividad.traslado:
        return Colors.blue;
      case TipoActividad.cultura:
        return const Color(0xFF795548);
      case TipoActividad.aventura:
        return Colors.green;
      case TipoActividad.tiempoLibre:
        return Colors.teal;
      case TipoActividad.visitaGuiada:
        return Colors.indigo;
      case TipoActividad.checkIn:
        return Colors.cyan;
      default:
        return Colors.blueGrey;
    }
  }

  IconData _iconForType(TipoActividad tipo) {
    switch (tipo) {
      case TipoActividad.hospedaje:
        return Icons.hotel_rounded;
      case TipoActividad.comida:
        return Icons.restaurant_rounded;
      case TipoActividad.traslado:
        return Icons.directions_bus_rounded;
      case TipoActividad.cultura:
        return Icons.museum_rounded;
      case TipoActividad.aventura:
        return Icons.hiking_rounded;
      case TipoActividad.tiempoLibre:
        return Icons.beach_access_rounded;
      case TipoActividad.visitaGuiada:
        return Icons.tour_rounded;
      case TipoActividad.checkIn:
        return Icons.where_to_vote_rounded;
      default:
        return Icons.local_activity_rounded;
    }
  }

  void _fitToPoints(List<LatLng> points) {
    if (points.isEmpty) return;
    if (points.length == 1) {
      _mapCtrl.move(points.first, 14.0);
      return;
    }
    final bounds = LatLngBounds.fromPoints(points);
    _mapCtrl.fitCamera(
      CameraFit.bounds(
        bounds: bounds,
        padding: const EdgeInsets.all(48),
        maxZoom: 15.0,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ItineraryBuilderCubit, ItineraryBuilderState>(
      listenWhen:
          (prev, curr) =>
              prev.diaSeleccionadoIndex != curr.diaSeleccionadoIndex ||
              prev.actividadesPorDia != curr.actividadesPorDia,
      listener: (ctx, state) {
        final pts =
            state.actividadesDelDiaActual
                .where(
                  (a) =>
                      a.ubicacionCentral != null &&
                      !a.horaInicio.isAtSameMomentAs(
                        a.horaFin,
                      ), // excluir sin-horario
                )
                .map((a) => a.ubicacionCentral!)
                .toList();
        Future.delayed(const Duration(milliseconds: 350), () {
          if (mounted) _fitToPoints(pts);
        });
      },
      builder: (ctx, state) {
        final actividades = [
          ...state.actividadesDelDiaActual.where(
            (a) =>
                a.ubicacionCentral != null &&
                !a.horaInicio.isAtSameMomentAs(a.horaFin), // solo con horario
          ),
        ]..sort((a, b) => a.horaInicio.compareTo(b.horaInicio));

        final points = actividades.map((a) => a.ubicacionCentral!).toList();

        return Stack(
          children: [
            // ── Mapa base ─────────────────────────────────────────────────
            FlutterMap(
              mapController: _mapCtrl,
              options: MapOptions(
                initialCenter:
                    points.isNotEmpty
                        ? points.first
                        : const LatLng(19.4326, -99.1332),
                initialZoom: 13.0,
                interactionOptions: const InteractionOptions(
                  flags:
                      InteractiveFlag.pinchZoom |
                      InteractiveFlag.drag |
                      InteractiveFlag.doubleTapZoom,
                ),
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.othliani.app',
                ),
                // Polilínea de ruta en orden cronológico
                if (points.length >= 2)
                  PolylineLayer(
                    polylines: [
                      Polyline(
                        points: points,
                        strokeWidth: 3.5,
                        color: Colors.blue,
                      ),
                    ],
                  ),
                // Marcadores mixtos: ícono del tipo de actividad + número de orden
                MarkerLayer(
                  markers:
                      actividades.asMap().entries.map((entry) {
                        final i = entry.key;
                        final act = entry.value;
                        final color = _colorForType(act.tipo);
                        final icon = _iconForType(act.tipo);

                        return Marker(
                          point: act.ubicacionCentral!,
                          width: 48,
                          height: 56,
                          child: Column(
                            children: [
                              // Círculo principal con el ícono del tipo
                              Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: color,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 2.5,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: color.withValues(alpha: 0.45),
                                      blurRadius: 8,
                                      spreadRadius: 1,
                                    ),
                                  ],
                                ),
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    Icon(icon, color: Colors.white, size: 18),
                                    // Burbuja del número de orden
                                    Positioned(
                                      top: 0,
                                      right: 0,
                                      child: Container(
                                        width: 15,
                                        height: 15,
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: color,
                                            width: 1,
                                          ),
                                        ),
                                        child: Center(
                                          child: Text(
                                            '${i + 1}',
                                            style: TextStyle(
                                              fontSize: 8,
                                              fontWeight: FontWeight.bold,
                                              color: color,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Punta del pin
                              Container(
                                width: 3,
                                height: 8,
                                decoration: BoxDecoration(
                                  color: color,
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                ),
              ],
            ),

            // ── Estado vacío ──────────────────────────────────────────────
            if (actividades.isEmpty)
              Positioned.fill(
                child: Container(
                  color: Colors.black.withValues(alpha: 0.03),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.map_outlined,
                          size: 40,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Agrega ubicaciones a las\nactividades para ver la ruta',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade500,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            // ── Chip de puntos mapeados ───────────────────────────────────
            if (actividades.isNotEmpty)
              Positioned(
                top: 10,
                right: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.92),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.route, size: 14, color: Colors.blue.shade700),
                      const SizedBox(width: 5),
                      Text(
                        '${actividades.length} punto'
                        '${actividades.length == 1 ? '' : 's'}',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade800,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // ── FAB re-centrar ────────────────────────────────────────────
            if (actividades.isNotEmpty)
              Positioned(
                bottom: 10,
                right: 10,
                child: FloatingActionButton.small(
                  heroTag: 'recenter_route_map',
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.blue.shade700,
                  elevation: 3,
                  onPressed: () => _fitToPoints(points),
                  child: const Icon(Icons.center_focus_strong, size: 18),
                ),
              ),
          ],
        );
      },
    );
  }
}
