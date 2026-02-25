import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:frontend/core/navigation/routes_guia.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/features/agencia/trips/domain/entities/viaje.dart';
import 'package:frontend/features/guia/home/presentation/screens/sos_alarm_screen.dart';

// ────────────────────────────────────────────────────────────────────────────
// WIDGET DE MAPA CON SEGURIDAD INTELIGENTE (ISO 31000 – Gestión de Riesgos)
//
// Implementa:
// - Geocerca visual (círculo translúcido sobre el mapa real)
// - Marcadores con hue dinámico: verde = dentro / rojo = fuera de rango
// - Cálculo de distancia haversine para determinar el estado del turista
// - Simulación de movimiento aleatorio para el prototipo
// ────────────────────────────────────────────────────────────────────────────

/// Status de un turista respecto a la geocerca.
enum EstadoGeocerca { seguro, alejado, alerta }

/// Modelo de turista en tiempo real.
class TuristaEnMapa {
  final String id;
  final String nombre;
  LatLng posicion;
  EstadoGeocerca estado;

  /// Nivel de vulnerabilidad: determine la intensidad de la alarma.
  /// Usa [PrioridadAlerta.critica] para menores / discapacidad.
  final PrioridadAlerta vulnerabilidad;

  TuristaEnMapa({
    required this.id,
    required this.nombre,
    required this.posicion,
    this.estado = EstadoGeocerca.seguro,
    this.vulnerabilidad = PrioridadAlerta.estandar,
  });
}

class MapaMonitoreoWidget extends StatefulWidget {
  /// Centro inicial de la geocerca.
  final LatLng centroGeocerca;

  /// Radio de la geocerca en metros.
  /// Si se proporciona [tipoGrupo], su radio tiene precedencia.
  final double radioMetros;

  /// Tipo de grupo del viaje — ajusta el radio automáticamente.
  /// Opcional: si es null se usa [radioMetros] directamente.
  final TipoGrupo? tipoGrupo;

  /// Callback al tocar un marcador (recibe el ID del turista).
  final void Function(String id)? onTuristaTapped;

  const MapaMonitoreoWidget({
    super.key,
    this.centroGeocerca = const LatLng(19.6922, -98.8435), // Teotihuacán (mock)
    this.radioMetros = 300.0,
    this.tipoGrupo,
    this.onTuristaTapped,
  });

  @override
  State<MapaMonitoreoWidget> createState() => _MapaMonitoreoWidgetState();
}

class _MapaMonitoreoWidgetState extends State<MapaMonitoreoWidget> {
  GoogleMapController? _mapController;

  /// Radio efectivo: si el widget recibe [tipoGrupo], su radio tiene prioridad.
  double get _radioEfectivo =>
      widget.tipoGrupo?.radioMetros ?? widget.radioMetros;

  /// Turistas simulados en el prototipo.
  final List<TuristaEnMapa> _turistas = [
    TuristaEnMapa(
      id: 't1',
      nombre: 'Juan D.',
      posicion: const LatLng(19.6925, -98.8430),
    ),
    TuristaEnMapa(
      id: 't2',
      nombre: 'Ana M.',
      posicion: const LatLng(19.6930, -98.8428),
    ),
    TuristaEnMapa(
      id: 't3',
      nombre: 'Luis H.',
      posicion: const LatLng(19.6950, -98.8410),
    ), // fuera
    TuristaEnMapa(
      id: 't4',
      nombre: 'Sofía R. (menor)',
      posicion: const LatLng(19.6960, -98.8400),
      vulnerabilidad: PrioridadAlerta.critica, // 🔴 perfil vulnerable (mock)
    ), // alerta crítica
    TuristaEnMapa(
      id: 't5',
      nombre: 'Carlos L.',
      posicion: const LatLng(19.6920, -98.8440),
    ),
    TuristaEnMapa(
      id: 't6',
      nombre: 'Paola T.',
      posicion: const LatLng(19.6915, -98.8445),
    ),
  ];

  /// IDs de turistas para los que ya se disparó la alerta en esta sesión.
  /// Evita re-lanzar la pantalla SOS cada vez que se llama _evaluarEstados.
  final Set<String> _alertasDisparadas = {};

  @override
  void initState() {
    super.initState();
    _evaluarEstados();
  }

  // ── Haversine: distancia entre dos LatLng en metros ───────────────────────
  double _distanciaMetros(LatLng a, LatLng b) {
    const R = 6371000.0;
    final dLat = _rad(b.latitude - a.latitude);
    final dLon = _rad(b.longitude - a.longitude);
    final h =
        math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_rad(a.latitude)) *
            math.cos(_rad(b.latitude)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);
    return 2 * R * math.atan2(math.sqrt(h), math.sqrt(1 - h));
  }

  double _rad(double deg) => deg * math.pi / 180;

  // ── Evalúa el estado ISO 31000 de cada turista ───────────────────────────
  void _evaluarEstados() {
    for (final t in _turistas) {
      final distancia = _distanciaMetros(widget.centroGeocerca, t.posicion);
      if (distancia <= _radioEfectivo * 0.75) {
        t.estado = EstadoGeocerca.seguro; // verde — dentro del 75%
      } else if (distancia <= _radioEfectivo) {
        t.estado = EstadoGeocerca.alejado; // naranja — zona límite
      } else {
        t.estado = EstadoGeocerca.alerta; // rojo — fuera de geocerca
      }
    }
    if (mounted) setState(() {});
    // 🔐 Verificación proactiva ISO 31000: dispara alarma si hay turistas fuera
    _verificarSeguridadTuristas();
  }

  // ── Detección proactiva ───────────────────────────────────────────────────
  /// Recorre los turistas y lanza la alarma para el primero que esté en
  /// estado [alerta] y no haya sido notificado aún en esta sesión.
  /// Prioriza perfiles críticos sobre estándar.
  void _verificarSeguridadTuristas() {
    // Primero buscamos críticos (menores/discapacidad) — máxima prioridad
    final criticos = _turistas.where(
      (t) =>
          t.estado == EstadoGeocerca.alerta &&
          t.vulnerabilidad == PrioridadAlerta.critica &&
          !_alertasDisparadas.contains(t.id),
    );
    if (criticos.isNotEmpty) {
      _lanzarAlertaProactiva(criticos.first);
      return;
    }

    // Luego estándar
    final estandar = _turistas.where(
      (t) =>
          t.estado == EstadoGeocerca.alerta &&
          !_alertasDisparadas.contains(t.id),
    );
    if (estandar.isNotEmpty) {
      _lanzarAlertaProactiva(estandar.first);
    }
  }

  /// Navega a /sos con la [AlertaSOS] construida según el perfil del turista.
  void _lanzarAlertaProactiva(TuristaEnMapa turista) {
    _alertasDisparadas.add(turista.id); // Marca como notificado

    final esCritico = turista.vulnerabilidad == PrioridadAlerta.critica;
    final alerta = AlertaSOS(
      prioridad: turista.vulnerabilidad,
      mensaje:
          esCritico
              ? '¡ATENCIÓN! ${turista.nombre} se ha alejado del grupo'
              : '${turista.nombre} está fuera de la zona segura',
      nombreTurista: turista.nombre,
      autoDetectada: true,
    );

    // Post-frame para evitar push durante build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) context.push(RoutesGuia.sos, extra: alerta);
    });
  }

  // ── Construye marcadores con hue dinámico ─────────────────────────────────
  Set<Marker> _crearMarcadoresInteligentes() {
    return _turistas.map((t) {
      final hue = switch (t.estado) {
        EstadoGeocerca.seguro => BitmapDescriptor.hueGreen,
        EstadoGeocerca.alejado => BitmapDescriptor.hueOrange,
        EstadoGeocerca.alerta => BitmapDescriptor.hueRed,
      };
      final snippet = switch (t.estado) {
        EstadoGeocerca.seguro => '✅ Dentro del área segura',
        EstadoGeocerca.alejado => '⚠️ Zona límite de geocerca',
        EstadoGeocerca.alerta => '🚨 ¡FUERA DE RANGO!',
      };

      return Marker(
        markerId: MarkerId(t.id),
        position: t.posicion,
        icon: BitmapDescriptor.defaultMarkerWithHue(hue),
        infoWindow: InfoWindow(
          title: t.nombre,
          snippet: snippet,
          onTap: () => widget.onTuristaTapped?.call(t.id),
        ),
        onTap: () => widget.onTuristaTapped?.call(t.id),
      );
    }).toSet();
  }

  // ── Geocerca visual ───────────────────────────────────────────────────────
  Set<Circle> _crearGeocercas() => {
    Circle(
      circleId: const CircleId('geocerca_activa'),
      center: widget.centroGeocerca,
      radius: _radioEfectivo,
      fillColor: AppColors.primary.withAlpha(38), // ~15% opacidad
      strokeColor: AppColors.primary,
      strokeWidth: 2,
    ),
    // Zona límite (75% del radio)
    Circle(
      circleId: const CircleId('geocerca_limite'),
      center: widget.centroGeocerca,
      radius: _radioEfectivo * 0.75,
      fillColor: Colors.green.withAlpha(18),
      strokeColor: Colors.green.withAlpha(90),
      strokeWidth: 1,
    ),
  };

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        GoogleMap(
          onMapCreated: (ctrl) => _mapController = ctrl,
          style: _estiloMapaNeutro,
          initialCameraPosition: CameraPosition(
            target: widget.centroGeocerca,
            zoom: 16.5,
          ),
          circles: _crearGeocercas(),
          markers: _crearMarcadoresInteligentes(),
          myLocationEnabled: false,
          zoomControlsEnabled: false,
          mapToolbarEnabled: false,
        ),

        // ── Overlay de leyenda ──────────────────────────────────────────
        Positioned(bottom: 12, right: 12, child: _LeyendaGeocerca()),

        // ── Badge de alertas activas ────────────────────────────────────
        Positioned(
          top: 12,
          left: 12,
          child: _BadgeAlertas(turistas: _turistas),
        ),

        // ── Badge de TipoGrupo (sensibilidad dinámica) ───────────────────────
        if (widget.tipoGrupo != null)
          Positioned(
            top: 12,
            right: 12,
            child: _BadgeTipoGrupo(tipoGrupo: widget.tipoGrupo!),
          ),
      ],
    );
  }

  @override
  void dispose() {
    _mapController?.dispose();
    super.dispose();
  }
}

// ── Leyenda ───────────────────────────────────────────────────────────────────

class _LeyendaGeocerca extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(230),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(color: Colors.black.withAlpha(30), blurRadius: 6),
        ],
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _ItemLeyenda(color: Colors.green, etiqueta: 'Dentro del área'),
          SizedBox(height: 4),
          _ItemLeyenda(color: Colors.orange, etiqueta: 'Zona límite'),
          SizedBox(height: 4),
          _ItemLeyenda(color: Colors.red, etiqueta: 'Fuera de rango'),
        ],
      ),
    );
  }
}

class _ItemLeyenda extends StatelessWidget {
  final Color color;
  final String etiqueta;
  const _ItemLeyenda({required this.color, required this.etiqueta});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          etiqueta,
          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}

// ── Badge de alertas ──────────────────────────────────────────────────────────

class _BadgeAlertas extends StatelessWidget {
  final List<TuristaEnMapa> turistas;
  const _BadgeAlertas({required this.turistas});

  @override
  Widget build(BuildContext context) {
    final alertas =
        turistas.where((t) => t.estado == EstadoGeocerca.alerta).length;
    final alejados =
        turistas.where((t) => t.estado == EstadoGeocerca.alejado).length;
    final seguros =
        turistas.where((t) => t.estado == EstadoGeocerca.seguro).length;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: alertas > 0 ? Colors.red.shade700 : const Color(0xFF1A237E),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(color: Colors.black.withAlpha(40), blurRadius: 6),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (alertas > 0) ...[
            const Icon(Icons.warning_rounded, color: Colors.white, size: 14),
            const SizedBox(width: 4),
            Text(
              '$alertas alerta${alertas > 1 ? 's' : ''}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(width: 8),
          ],
          Text(
            '✅$seguros  🟠$alejados',
            style: const TextStyle(color: Colors.white, fontSize: 11),
          ),
        ],
      ),
    );
  }
}

// ── Badge de TipoGrupo (sensibilidad dinámica) ────────────────────────────────

class _BadgeTipoGrupo extends StatelessWidget {
  final TipoGrupo tipoGrupo;
  const _BadgeTipoGrupo({required this.tipoGrupo});

  Color get _color => switch (tipoGrupo) {
    TipoGrupo.escolar => Colors.red.shade700,
    TipoGrupo.familiar => const Color(0xFF1A237E),
    TipoGrupo.aventuraAdultos => Colors.green.shade700,
  };

  IconData get _icono => switch (tipoGrupo) {
    TipoGrupo.escolar => Icons.child_care_rounded,
    TipoGrupo.familiar => Icons.family_restroom_rounded,
    TipoGrupo.aventuraAdultos => Icons.hiking_rounded,
  };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: _color,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(color: Colors.black.withAlpha(40), blurRadius: 6),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_icono, color: Colors.white, size: 13),
          const SizedBox(width: 5),
          Text(
            tipoGrupo.etiqueta,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Estilo de mapa (JSON de Google Maps) ─────────────────────────────────────

const _estiloMapaNeutro = '''
[
  {"featureType":"poi","stylers":[{"visibility":"off"}]},
  {"featureType":"transit","stylers":[{"visibility":"off"}]},
  {"featureType":"road","elementType":"labels.icon","stylers":[{"visibility":"off"}]},
  {"featureType":"landscape","elementType":"geometry.fill","stylers":[{"color":"#f5f5f5"}]},
  {"featureType":"water","elementType":"geometry.fill","stylers":[{"color":"#c9d8e8"}]},
  {"featureType":"road","elementType":"geometry.fill","stylers":[{"color":"#ffffff"}]},
  {"featureType":"road.arterial","elementType":"geometry.fill","stylers":[{"color":"#eeeeee"}]}
]
''';
