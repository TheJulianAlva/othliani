import 'package:flutter/material.dart';
import 'package:frontend/features/guia/trips/data/datasources/caja_negra_local_datasource.dart';
import 'package:frontend/features/guia/trips/domain/services/caja_negra_service.dart';
import 'package:intl/intl.dart';

// ─────────────────────────────────────────────────────────────────────────────
// BitacoraSeguridad — pantalla de auditoría local para el guía
//
// Muestra todos los eventos registrados en la Caja Negra ordenados del más
// reciente al más antiguo. Incluye filtro por tipo y botón de limpieza.
// ─────────────────────────────────────────────────────────────────────────────

class BitacoraSeguridadScreen extends StatefulWidget {
  const BitacoraSeguridadScreen({super.key});

  @override
  State<BitacoraSeguridadScreen> createState() =>
      _BitacoraSeguridadScreenState();
}

class _BitacoraSeguridadScreenState extends State<BitacoraSeguridadScreen> {
  late Future<List<EventoSeguridad>> _eventosFuture;
  TipoEventoSeguridad? _filtroActivo;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  void _cargar() =>
      setState(() => _eventosFuture = CajaNegraService().leerBitacora());

  Future<void> _confirmarLimpiar() async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('Borrar Bitácora'),
            content: const Text(
              '¿Eliminar todos los registros? Esta acción no se puede deshacer.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text(
                  'Borrar',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );
    if (confirmar == true) {
      await CajaNegraService().limpiarBitacora();
      _cargar();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bitácora de Seguridad'),
        actions: [
          // Filtro por tipo
          PopupMenuButton<TipoEventoSeguridad?>(
            icon: Icon(
              Icons.filter_list_rounded,
              color: _filtroActivo != null ? colorScheme.primary : null,
            ),
            tooltip: 'Filtrar',
            onSelected: (t) => setState(() => _filtroActivo = t),
            itemBuilder:
                (_) => [
                  const PopupMenuItem(value: null, child: Text('Todos')),
                  ...TipoEventoSeguridad.values.map(
                    (t) => PopupMenuItem(value: t, child: Text(t.etiqueta)),
                  ),
                ],
          ),
          // Limpiar
          IconButton(
            icon: const Icon(Icons.delete_sweep_rounded),
            tooltip: 'Limpiar bitácora',
            onPressed: _confirmarLimpiar,
          ),
        ],
      ),
      body: FutureBuilder<List<EventoSeguridad>>(
        future: _eventosFuture,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(child: Text('Error: ${snap.error}'));
          }

          var eventos = snap.data ?? [];
          if (_filtroActivo != null) {
            eventos = eventos.where((e) => e.tipo == _filtroActivo).toList();
          }

          if (eventos.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.receipt_long_rounded,
                    size: 64,
                    color: colorScheme.onSurfaceVariant.withAlpha(80),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _filtroActivo != null
                        ? 'Sin eventos del tipo "${_filtroActivo!.etiqueta}"'
                        : 'No hay eventos registrados aún',
                    style: TextStyle(color: colorScheme.onSurfaceVariant),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async => _cargar(),
            child: ListView.separated(
              padding: const EdgeInsets.all(12),
              itemCount: eventos.length,
              separatorBuilder: (_, __) => const SizedBox(height: 6),
              itemBuilder: (_, i) => _TarjetaEvento(evento: eventos[i]),
            ),
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// _TarjetaEvento
// ─────────────────────────────────────────────────────────────────────────────

class _TarjetaEvento extends StatelessWidget {
  final EventoSeguridad evento;
  const _TarjetaEvento({required this.evento});

  Color _colorPrioridad(BuildContext ctx) => switch (evento.prioridad) {
    'CRITICA' => Colors.red.shade700,
    'ESTANDAR' => Colors.orange.shade700,
    _ => Theme.of(ctx).colorScheme.onSurfaceVariant,
  };

  IconData get _icono => switch (evento.tipo) {
    TipoEventoSeguridad.inicioProteccion => Icons.play_circle_rounded,
    TipoEventoSeguridad.finProteccion => Icons.stop_circle_rounded,
    TipoEventoSeguridad.alertaAlejamiento => Icons.location_off_rounded,
    TipoEventoSeguridad.sosManual => Icons.emergency_rounded,
    TipoEventoSeguridad.accionGuia => Icons.check_circle_rounded,
    TipoEventoSeguridad.sincronizacion => Icons.sync_rounded,
  };

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final colorPrior = _colorPrioridad(context);
    final fmt = DateFormat('dd/MM HH:mm:ss', 'es_MX');

    return Card(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Ícono con color de prioridad
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: colorPrior.withAlpha(20),
                shape: BoxShape.circle,
              ),
              child: Icon(_icono, size: 20, color: colorPrior),
            ),
            const SizedBox(width: 12),

            // Contenido
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tipo + prioridad
                  Row(
                    children: [
                      Text(
                        evento.tipo.etiqueta,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 12,
                          color: colorPrior,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: colorPrior.withAlpha(18),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          evento.prioridad,
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            color: colorPrior,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),

                  // Descripción
                  Text(
                    evento.descripcion,
                    style: const TextStyle(fontSize: 13),
                  ),
                  const SizedBox(height: 4),

                  // Timestamp + coordenadas
                  Row(
                    children: [
                      Icon(
                        Icons.access_time_rounded,
                        size: 11,
                        color: colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 3),
                      Text(
                        fmt.format(evento.timestamp),
                        style: TextStyle(
                          fontSize: 11,
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      if (evento.coordenadas.isNotEmpty) ...[
                        const SizedBox(width: 10),
                        Icon(
                          Icons.location_on_rounded,
                          size: 11,
                          color: colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          evento.coordenadas,
                          style: TextStyle(
                            fontSize: 11,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
