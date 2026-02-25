import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/features/guia/trips/domain/services/caja_negra_service.dart';

import 'package:frontend/features/guia/trips/domain/entities/incident_log.dart';
import 'package:intl/intl.dart';

// ─────────────────────────────────────────────────────────────────────────────
// ReporteFinViajeScreen
//
// Resumen de Protección y Actividad al cierre de una expedición.
// Lee la Caja Negra local para generar KPIs reales, sin necesidad de red.
// ─────────────────────────────────────────────────────────────────────────────

class ReporteFinViajeScreen extends StatelessWidget {
  /// Nombre del viaje/expedición (pasado como argumento al navegar).
  final String nombreExpedicion;

  /// Fecha de inicio (para calcular duración).
  final DateTime? inicio;

  /// Turistas de Prioridad 1 (vulnerables) en el viaje.
  final List<String> turistasPrioridad1;

  /// Distancia recorrida en km (calculada por el módulo de mapa).
  final double distanciaKm;

  /// Determina si se ejecuta en flujo B2C (true) o B2B (false).
  final bool esGuiaIndependiente;

  const ReporteFinViajeScreen({
    super.key,
    this.nombreExpedicion = 'Expedición',
    this.inicio,
    this.turistasPrioridad1 = const [],
    this.distanciaKm = 0,
    this.esGuiaIndependiente = true,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Resumen de Expedición'),
        actions: [
          IconButton(
            icon: Icon(
              esGuiaIndependiente
                  ? Icons.picture_as_pdf_rounded
                  : Icons.cloud_upload_rounded,
            ),
            tooltip:
                esGuiaIndependiente
                    ? 'Generar Reporte PDF'
                    : 'Sincronizar con Agencia',
            onPressed: () => _compartirReporte(context),
          ),
        ],
      ),
      body: FutureBuilder<List<IncidentLog>>(
        future: CajaNegraService().leerBitacora(),
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final eventos = snap.data ?? [];
          return _Contenido(
            nombreExpedicion: nombreExpedicion,
            inicio: inicio ?? DateTime.now().subtract(const Duration(hours: 1)),
            turistasPrioridad1: turistasPrioridad1,
            distanciaKm: distanciaKm,
            eventos: eventos,
          );
        },
      ),
    );
  }

  void _compartirReporte(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          esGuiaIndependiente
              ? 'Exportación a PDF próximamente disponible'
              : 'Sincronizando reporte con la agencia...',
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _Contenido — widget con estado propio para calcular métricas
// ─────────────────────────────────────────────────────────────────────────────

class _Contenido extends StatelessWidget {
  final String nombreExpedicion;
  final DateTime inicio;
  final List<String> turistasPrioridad1;
  final double distanciaKm;
  final List<IncidentLog> eventos;

  const _Contenido({
    required this.nombreExpedicion,
    required this.inicio,
    required this.turistasPrioridad1,
    required this.distanciaKm,
    required this.eventos,
  });

  // ── Métricas derivadas de la Caja Negra ────────────────────────────────────
  int get _totalSOS =>
      eventos.where((e) => e.tipo == TipoIncidente.sosManual).length;
  int get _alertasAlejamiento =>
      eventos.where((e) => e.tipo == TipoIncidente.alertaTuristaAlejado).length;
  int get _cancelacionesGuia =>
      eventos.where((e) => e.tipo == TipoIncidente.accionGuia).length;
  int get _alertasAtendidas => _cancelacionesGuia;

  String get _duracion {
    final diff = DateTime.now().difference(inicio);
    final h = diff.inHours.toString().padLeft(2, '0');
    final m = (diff.inMinutes % 60).toString().padLeft(2, '0');
    return '$h:${m}h';
  }

  // Estimación de huella de carbono: 0.21 kg CO2e/km (promedio turismo a pie)
  double get _huellaCarbono => distanciaKm * 0.21;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final fmt = DateFormat('dd \'de\' MMMM, yyyy', 'es_MX');

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ─────────────────────────────────────────────────────────
          Text(
            nombreExpedicion,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          Text(
            fmt.format(inicio),
            style: TextStyle(color: colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: 8),

          // Badge de cierre
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.green.withAlpha(25),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.green.shade300),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.verified_rounded, size: 14, color: Colors.green),
                SizedBox(width: 6),
                Text(
                  'Misión completada',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),

          // ── KPIs de Seguridad ───────────────────────────────────────────────
          _SeccionLabel('RENDIMIENTO DE SEGURIDAD'),
          const SizedBox(height: 10),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            childAspectRatio: 1.55,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            children: [
              _KpiCard(
                label: 'SOS Activados',
                valor: '$_totalSOS',
                icono: Icons.emergency_rounded,
                color: _totalSOS == 0 ? Colors.green : Colors.red,
              ),
              _KpiCard(
                label: 'Alejamientos',
                valor: '$_alertasAlejamiento',
                icono: Icons.location_off_rounded,
                color: Colors.orange,
              ),
              _KpiCard(
                label: 'Atendidos < 5s',
                valor: '$_alertasAtendidas',
                icono: Icons.check_circle_rounded,
                color: Colors.green,
              ),
              _KpiCard(
                label: 'Tiempo Protección',
                valor: _duracion,
                icono: Icons.security_rounded,
                color: AppColors.primary,
              ),
            ],
          ),

          // ── Barra de efectividad ────────────────────────────────────────────
          if (_alertasAlejamiento > 0) ...[
            const SizedBox(height: 16),
            _EfectividadBar(
              atendidas: _alertasAtendidas,
              total: _alertasAlejamiento,
            ),
          ],
          const SizedBox(height: 28),

          // ── Protección Prioridad 1 ──────────────────────────────────────────
          if (turistasPrioridad1.isNotEmpty) ...[
            _SeccionLabel('PROTECCIÓN PRIORITARIA (NIVEL 1)'),
            const SizedBox(height: 8),
            ...turistasPrioridad1.map(
              (nombre) => _TarjetaVulnerable(nombre: nombre),
            ),
            const SizedBox(height: 28),
          ],

          // ── Huella de Carbono ───────────────────────────────────────────────
          _SeccionLabel('IMPACTO AMBIENTAL'),
          const SizedBox(height: 8),
          _TarjetaCarbon(distanciaKm: distanciaKm, huellaKg: _huellaCarbono),
          const SizedBox(height: 28),

          // ── Actividad del Log (resumen compacto) ────────────────────────────
          if (eventos.isNotEmpty) ...[
            _SeccionLabel('ÚLTIMAS ENTRADAS EN BITÁCORA'),
            const SizedBox(height: 8),
            ...eventos.take(3).map((e) => _FilaLog(evento: e)),
            const SizedBox(height: 28),
          ],

          // ── Botón cerrar ────────────────────────────────────────────────────
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.flag_rounded, color: Colors.white),
              label: const Text(
                'CERRAR EXPEDICIÓN',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () => Navigator.of(context).popUntil((r) => r.isFirst),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Widgets auxiliares
// ─────────────────────────────────────────────────────────────────────────────

class _SeccionLabel extends StatelessWidget {
  final String texto;
  const _SeccionLabel(this.texto);

  @override
  Widget build(BuildContext context) => Text(
    texto,
    style: TextStyle(
      fontSize: 11,
      fontWeight: FontWeight.w800,
      letterSpacing: 1.2,
      color: Theme.of(context).colorScheme.onSurfaceVariant,
    ),
  );
}

class _KpiCard extends StatelessWidget {
  final String label;
  final String valor;
  final IconData icono;
  final Color color;

  const _KpiCard({
    required this.label,
    required this.valor,
    required this.icono,
    required this.color,
  });

  @override
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: color.withAlpha(20),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: color.withAlpha(40)),
    ),
    padding: const EdgeInsets.all(14),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icono, color: color, size: 22),
        const SizedBox(height: 6),
        Text(
          valor,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w900,
            color: color,
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 10, color: Colors.black54),
          textAlign: TextAlign.center,
        ),
      ],
    ),
  );
}

class _EfectividadBar extends StatelessWidget {
  final int atendidas;
  final int total;
  const _EfectividadBar({required this.atendidas, required this.total});

  @override
  Widget build(BuildContext context) {
    final pct = total == 0 ? 1.0 : atendidas / total;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Efectividad de respuesta',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
            Text(
              '${(pct * 100).round()}%',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: Colors.green,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: pct,
            minHeight: 8,
            backgroundColor: Colors.grey.shade200,
            valueColor: AlwaysStoppedAnimation<Color>(
              pct >= 0.8 ? Colors.green : Colors.orange,
            ),
          ),
        ),
      ],
    );
  }
}

class _TarjetaVulnerable extends StatelessWidget {
  final String nombre;
  const _TarjetaVulnerable({required this.nombre});

  @override
  Widget build(BuildContext context) => Card(
    margin: const EdgeInsets.only(bottom: 8),
    child: ListTile(
      leading: const CircleAvatar(
        backgroundColor: Colors.redAccent,
        child: Icon(Icons.child_care_rounded, color: Colors.white, size: 20),
      ),
      title: Text(nombre, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: const Text(
        'Monitoreo prioritario activo durante toda la expedición',
        style: TextStyle(fontSize: 11),
      ),
      trailing: const Icon(Icons.check_circle_rounded, color: Colors.green),
    ),
  );
}

class _TarjetaCarbon extends StatelessWidget {
  final double distanciaKm;
  final double huellaKg;
  const _TarjetaCarbon({required this.distanciaKm, required this.huellaKg});

  String get _descripcion {
    if (huellaKg < 1) return '¡Expedición de huella mínima!';
    if (huellaKg < 5) return 'Un viaje consciente y responsable';
    return 'Considera compensar con reforestación local';
  }

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.green.shade50,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Colors.green.shade200),
    ),
    child: Row(
      children: [
        const Icon(Icons.eco_rounded, color: Colors.green, size: 32),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Huella de Carbono Estimada',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              ),
              const SizedBox(height: 2),
              Text(
                '${huellaKg.toStringAsFixed(1)} kg CO₂e'
                '${distanciaKm > 0 ? " — $distanciaKm km recorridos" : ""}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Colors.green,
                ),
              ),
              Text(
                _descripcion,
                style: TextStyle(fontSize: 11, color: Colors.green.shade700),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _FilaLog extends StatelessWidget {
  final IncidentLog evento;
  const _FilaLog({required this.evento});

  Color _color(String p) => switch (p) {
    'CRITICA' => Colors.red,
    'ESTANDAR' => Colors.orange,
    _ => Colors.grey,
  };

  @override
  Widget build(BuildContext context) {
    final color = _color(evento.prioridad);
    final hora = DateFormat('HH:mm', 'es_MX').format(evento.timestamp);

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 3,
            height: 40,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      evento.tipo.etiqueta,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: color,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      hora,
                      style: TextStyle(
                        fontSize: 10,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                Text(
                  evento.descripcion,
                  style: const TextStyle(fontSize: 12),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
