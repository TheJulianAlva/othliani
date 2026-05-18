import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:go_router/go_router.dart';
import 'package:frontend/features/agencia/trips/domain/entities/viaje.dart';
import 'package:frontend/features/agencia/shared/domain/entities/alerta.dart';

class AgencyMapWidget extends StatefulWidget {
  final List<Viaje> viajes;
  final List<Alerta> alertas;

  const AgencyMapWidget({
    super.key,
    this.viajes = const [],
    this.alertas = const [],
  });

  @override
  State<AgencyMapWidget> createState() => _AgencyMapWidgetState();
}

class _AgencyMapWidgetState extends State<AgencyMapWidget> {
  // Controladores
  final MapController _mapController = MapController();

  // Estado de Filtros
  final bool _showEnCurso = true;
  final bool _showProgramados = false;
  final bool _showFinalizados = false;

  // Estado de Selección
  int _selectedIndex = -1; // -1 significa ninguno seleccionado

  @override
  void initState() {
    super.initState();
    // No longer using PageView, we'll just show the selected item.
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 1. Aplicar Filtros
    final filteredViajes =
        widget.viajes.where((viaje) {
          if (viaje.estado == 'EN_CURSO' && _showEnCurso) return true;
          if (viaje.estado == 'PROGRAMADO' && _showProgramados) return true;
          if (viaje.estado == 'FINALIZADO' && _showFinalizados) return true;
          return false;
        }).toList();

    // Centro inicial seguro
    final initialCenter =
        filteredViajes.isNotEmpty
            ? LatLng(
              filteredViajes.first.latitud,
              filteredViajes.first.longitud,
            )
            : const LatLng(19.4326, -99.1332);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // --- CAPA 1: EL MAPA ---
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: initialCenter,
              initialZoom: 11.0,
              onTap: (_, __) {
                // Al tocar el mapa vacío, deseleccionamos
                setState(() => _selectedIndex = -1);
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.veltur.app',
              ),
              MarkerLayer(
                markers:
                    filteredViajes.asMap().entries.map((entry) {
                      return _buildMarker(
                        entry.value,
                        entry.key,
                        filteredViajes,
                      );
                    }).toList(),
              ),
            ],
          ),

          // --- CAPA 2: TARJETA DE VIAJE SELECCIONADO (TOP LEFT) ---
          if (filteredViajes.isNotEmpty) ...[
            Builder(
              builder: (context) {
                // Si no hay ninguno seleccionado, por defecto mostrar el primero o ninguno.
                // En el mockup se ve una tarjeta flotante en el top-left.
                final int idx = _selectedIndex == -1 ? 0 : _selectedIndex;
                final Viaje viajeSeleccionado = filteredViajes[idx];

                return Positioned(
                  top: 16,
                  left: 16,
                  child: SizedBox(
                    width: 320,
                    child: _buildTripCard(viajeSeleccionado, idx),
                  ),
                );
              }
            ),
          ],

          // --- CAPA 3: BOTÓN RE-CENTRAR (Móvil) ---
          Positioned(
            bottom: 16,
            right: 16,
            child: FloatingActionButton.small(
              heroTag: 'recenter_map',
              backgroundColor: Colors.white,
              foregroundColor: Colors.blue[800],
              elevation: 4,
              onPressed: () => _recenterMap(filteredViajes),
              child: const Icon(Icons.center_focus_strong),
            ),
          ),
        ],
      ),
    );
  }

  // --- WIDGETS AUXILIARES ---

  Widget _buildTripCard(Viaje viaje, int pageIndex) {
    final bool hasAlerts = viaje.alertasActivas > 0;
    
    // In mockup, the top-left card is white with subtle shadow and rounded corners.
    // If it has alerts, there's a red pill at the top left "CON ALERTAS" and "V-102" at top right.
    return GestureDetector(
      onTap: () {
        context.go('/viajes/${viaje.id}?return_to=dashboard');
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Row 1: Status Pill and ID
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (hasAlerts)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFEBEE),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      "CON ALERTAS",
                      style: TextStyle(
                        fontSize: 10,
                        color: Color(0xFFC62828),
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  )
                else
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F5E9),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      "EN CURSO",
                      style: TextStyle(
                        fontSize: 10,
                        color: Color(0xFF2E7D32),
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                Text(
                  "V-${viaje.id}",
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade500,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            // Row 2: Titulo Viaje
            Text(
              viaje.destino,
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 16,
                color: Color(0xFF2C3E50),
              ),
            ),
            const SizedBox(height: 4),
            
            // Location sub
            Row(
              children: [
                Icon(Icons.location_on_outlined, size: 14, color: Colors.blue.shade600),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    "Ruta Activa", // Replace with real string if available
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Row 3: Staff & Pax
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "GUÍA",
                        style: TextStyle(fontSize: 10, color: Colors.grey.shade500, fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        viaje.guiaNombre,
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF2C3E50)),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "TURISTAS",
                        style: TextStyle(fontSize: 10, color: Colors.grey.shade500, fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        "${viaje.turistas} pax",
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF2C3E50)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }


  Marker _buildMarker(Viaje viaje, int index, List<Viaje> filteredList) {
    final isSelected = _selectedIndex == index;
    final color = _getColor(viaje.estado);

    return Marker(
      point: LatLng(viaje.latitud, viaje.longitud),
      width: isSelected ? 50 : 40, // Crece si está seleccionado
      height: isSelected ? 50 : 40,
      child: GestureDetector(
        onTap: () {
          setState(() => _selectedIndex = index);
          _animateCameraTo(viaje);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          decoration: BoxDecoration(
            color: isSelected ? color : color.withValues(alpha: 0.8),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: isSelected ? 3 : 2),
            boxShadow: [
              if (isSelected)
                BoxShadow(
                  color: color.withValues(alpha: 0.4),
                  blurRadius: 12,
                  spreadRadius: 2,
                ),
              const BoxShadow(blurRadius: 4, color: Colors.black38),
            ],
          ),
          child: Icon(
            _getIcon(viaje.estado),
            color: Colors.white,
            size: isSelected ? 26 : 20,
          ),
        ),
      ),
    );
  }

  // --- LÓGICA DE CONTROL ---

  void _animateCameraTo(Viaje viaje) {
    _mapController.move(
      LatLng(viaje.latitud, viaje.longitud),
      13.0, // Zoom óptimo para ver detalle
    );
  }

  void _recenterMap(List<Viaje> viajesVisibles) {
    if (viajesVisibles.isEmpty) return;

    // CASO 1: Solo hay 1 viaje visible
    if (viajesVisibles.length == 1) {
      final viaje = viajesVisibles.first;
      _mapController.move(
        LatLng(viaje.latitud, viaje.longitud),
        12.0, // Zoom fijo para un solo punto
      );
      setState(() => _selectedIndex = -1);
      return;
    }

    // CASO 2: Múltiples viajes - calcular bounds
    final points =
        viajesVisibles.map((v) => LatLng(v.latitud, v.longitud)).toList();
    final bounds = LatLngBounds.fromPoints(points);
    _mapController.fitCamera(
      CameraFit.bounds(
        bounds: bounds,
        padding: const EdgeInsets.all(50),
        maxZoom: 15.0,
      ),
    );
    // Opcional: Deseleccionar al hacer zoom out
    setState(() => _selectedIndex = -1);
  }

  // --- UTILIDADES ---
  Color _getColor(String estado) {
    if (estado == 'EN_CURSO') return Colors.green;
    if (estado == 'PROGRAMADO') return Colors.blue;
    return Colors.grey;
  }

  IconData _getIcon(String estado) {
    if (estado == 'EN_CURSO') return Icons.directions_bus;
    if (estado == 'PROGRAMADO') return Icons.calendar_today;
    return Icons.flag;
  }
}
