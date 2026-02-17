import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart'; // Para PointerDeviceKind
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
  late PageController _pageController;

  // Estado de Filtros
  bool _showEnCurso = true;
  bool _showProgramados = false;
  bool _showFinalizados = false;

  // Estado de Selección
  int _selectedIndex = -1; // -1 significa ninguno seleccionado

  @override
  void initState() {
    super.initState();
    // viewportFraction: 0.85 hace que se vea un pedacito de la siguiente tarjeta
    _pageController = PageController(viewportFraction: 0.85);
  }

  @override
  void dispose() {
    _pageController.dispose();
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
                userAgentPackageName: 'com.othliani.app',
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

          // --- CAPA 2: FILTROS SUPERIORES ---
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip(
                    'En Curso',
                    Colors.green,
                    _showEnCurso,
                    (v) => setState(() => _showEnCurso = v),
                  ),
                  const SizedBox(width: 8),
                  _buildFilterChip(
                    'Programados',
                    Colors.blue,
                    _showProgramados,
                    (v) => setState(() => _showProgramados = v),
                  ),
                  const SizedBox(width: 8),
                  _buildFilterChip(
                    'Finalizados',
                    Colors.grey,
                    _showFinalizados,
                    (v) => setState(() => _showFinalizados = v),
                  ),
                ],
              ),
            ),
          ),

          // --- CAPA 3: BOTÓN RE-CENTRAR (Móvil) ---
          // Se mueve hacia arriba si el carrusel está visible
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
            bottom:
                filteredViajes.isEmpty
                    ? 16
                    : 160, // 160 = altura carrusel + margen
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

          // --- CAPA 4: CARRUSEL DE TARJETAS (NUEVO) ---
          if (filteredViajes.isNotEmpty)
            Positioned(
              bottom: 16,
              left: 0,
              right: 0,
              height: 130, // Altura del carrusel
              child: ScrollConfiguration(
                // Habilita el scroll con mouse drag en Web/Desktop
                behavior: ScrollConfiguration.of(context).copyWith(
                  dragDevices: {
                    PointerDeviceKind.touch,
                    PointerDeviceKind.mouse, // ← Clave para arrastre con mouse
                  },
                ),
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: filteredViajes.length,
                  onPageChanged: (index) {
                    setState(() => _selectedIndex = index);
                    _animateCameraTo(filteredViajes[index]);
                  },
                  itemBuilder: (context, index) {
                    final viaje = filteredViajes[index];
                    final isSelected = _selectedIndex == index;

                    return AnimatedScale(
                      scale: isSelected ? 1.0 : 0.9, // Efecto visual de foco
                      duration: const Duration(milliseconds: 300),
                      child: _buildTripCard(viaje, index),
                    );
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }

  // --- WIDGETS AUXILIARES ---

  Widget _buildTripCard(Viaje viaje, int pageIndex) {
    final bool hasAlerts = viaje.alertasActivas > 0;
    final Color stateColor = _getColor(viaje.estado);

    return GestureDetector(
      onTap: () {
        // Al tocar la tarjeta, navegamos al detalle del viaje
        context.go('/viajes/${viaje.id}?return_to=dashboard');
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
          // Borde izquierdo de color según estado (Identidad visual rápida)
          border: Border(
            left: BorderSide(color: stateColor, width: 4),
            top: BorderSide(color: Colors.grey.shade100),
            right: BorderSide(color: Colors.grey.shade100),
            bottom: BorderSide(color: Colors.grey.shade100),
          ),
          // Nota: No podemos usar borderRadius con bordes de colores no uniformes
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // 1. CABECERA: Destino y Hora
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    "Viaje #${viaje.id} - ${viaje.destino}",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    viaje.horaInicio,
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey[800],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            // 2. CUERPO: Guía y Pasajeros
            Row(
              children: [
                // Avatar del Guía (Simulado con iniciales)
                CircleAvatar(
                  radius: 10,
                  backgroundColor: Colors.blue[50],
                  child: Text(
                    viaje.guiaNombre.isNotEmpty
                        ? viaje.guiaNombre.substring(0, 1)
                        : '?',
                    style: TextStyle(fontSize: 10, color: Colors.blue[800]),
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    viaje.guiaNombre,
                    style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(Icons.group, size: 14, color: Colors.grey[400]),
                Text(
                  " ${viaje.turistas}",
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),

            // 3. PIE: Estatus y Alertas
            Row(
              children: [
                // Badge de Estado
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: stateColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    viaje.estado,
                    style: TextStyle(
                      fontSize: 10,
                      color: stateColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                const SizedBox(width: 8),

                // Indicador de Alertas (Solo si existen) - COLOR DINÁMICO
                if (hasAlerts) ...[
                  () {
                    // Determinar severidad máxima de las alertas de este viaje
                    final alertasDelViaje =
                        widget.alertas
                            .where((a) => a.viajeId == viaje.id)
                            .toList();
                    final maxSeverity = _getMaxSeverity(alertasDelViaje);
                    final severityColor = _getSeverityColor(maxSeverity);
                    final severityBgColor = _getSeverityBgColor(maxSeverity);

                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: severityBgColor,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: severityColor.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.warning_amber,
                            size: 12,
                            color: severityColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            "${viaje.alertasActivas} ${viaje.alertasActivas == 1 ? 'Alerta' : 'Alertas'}",
                            style: TextStyle(
                              fontSize: 10,
                              color: severityColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    );
                  }(),
                ],

                const Spacer(),

                // Botón "Ver detalle" - SIEMPRE visible con cursor pointer
                MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap:
                        () => context.go(
                          '/viajes/${viaje.id}?return_to=dashboard',
                        ),
                    child: Text(
                      "Ver detalle →",
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.blue[900],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
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
          // Al tocar el marker, movemos el carrusel a esa posición
          _pageController.animateToPage(
            index,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
          );
          // Y seleccionamos visualmente
          setState(() => _selectedIndex = index);
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

  // Widget FilterChip (Reutilizado del paso anterior)
  Widget _buildFilterChip(
    String label,
    Color color,
    bool isSelected,
    Function(bool) onChanged,
  ) {
    return FilterChip(
      label: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : color,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
      selected: isSelected,
      onSelected: onChanged,
      backgroundColor: Colors.white.withValues(alpha: 0.95),
      selectedColor: color,
      checkmarkColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isSelected ? Colors.transparent : color.withValues(alpha: 0.3),
        ),
      ),
      padding: EdgeInsets.zero,
      visualDensity: VisualDensity.compact,
    );
  }

  // --- MÉTODOS PARA SEVERIDAD DE ALERTAS ---

  String _getMaxSeverity(List<Alerta> alertas) {
    if (alertas.isEmpty) return 'info';

    // Prioridad: critical > warning > info
    bool hasCritical = false;
    bool hasWarning = false;

    for (final alerta in alertas) {
      final tipo = alerta.tipo;
      if (tipo == 'PANICO' || tipo == 'CONECTIVIDAD') {
        hasCritical = true;
      } else if (tipo == 'DESCONEXION' ||
          tipo == 'LEJANIA' ||
          tipo == 'BATERIA') {
        hasWarning = true;
      }
    }

    if (hasCritical) return 'critical';
    if (hasWarning) return 'warning';
    return 'info';
  }

  Color _getSeverityColor(String severity) {
    switch (severity) {
      case 'critical':
        return Colors.red;
      case 'warning':
        return Colors.amber.shade800;
      default:
        return Colors.blue;
    }
  }

  Color _getSeverityBgColor(String severity) {
    switch (severity) {
      case 'critical':
        return Colors.red[50]!;
      case 'warning':
        return Colors.amber[50]!;
      default:
        return Colors.blue[50]!;
    }
  }
}
