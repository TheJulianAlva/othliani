import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../../../../../features/guia/trips/data/datasources/caja_negra_local_datasource.dart';

// ─────────────────────────────────────────────────────────────────────────────
// ExpeditionLogScreen — Bitácora de Seguridad Personal ("Caja Negra" B2C)
//
// Historial cronológico inalterable de todos los eventos de seguridad de la
// sesión. Permite al guía revisar, filtrar y exportar el log al finalizar.
// ─────────────────────────────────────────────────────────────────────────────

class ExpeditionLogScreen extends StatefulWidget {
  const ExpeditionLogScreen({super.key});

  @override
  State<ExpeditionLogScreen> createState() => _ExpeditionLogScreenState();
}

class _ExpeditionLogScreenState extends State<ExpeditionLogScreen> {
  final _dsource = CajaNegraLocalDataSource();

  List<EventoSeguridad> _todos = [];
  bool _soloCriticos = false;
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    final eventos = await _dsource.leerEventos();
    if (mounted) {
      setState(() {
        _todos = eventos;
        _cargando = false;
      });
    }
  }

  List<EventoSeguridad> get _filtrados =>
      _soloCriticos
          ? _todos.where((e) => e.prioridad == 'CRITICA').toList()
          : _todos;

  // ── Exportar resumen por texto ─────────────────────────────────────────────
  Future<void> _exportar() async {
    if (_todos.isEmpty) return;
    final buf = StringBuffer();
    buf.writeln('📋 BITÁCORA DE SEGURIDAD — OhtliAni');
    buf.writeln(
      'Generada: ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now())}',
    );
    buf.writeln('─' * 40);
    for (final e in _todos.reversed) {
      buf.writeln(
        '[${DateFormat('HH:mm:ss').format(e.timestamp)}] '
        '${e.tipo.etiqueta} (${e.prioridad})\n'
        '  ${e.descripcion}'
        '${e.coordenadas.isNotEmpty ? '\n  📍 ${e.coordenadas}' : ''}',
      );
      buf.writeln();
    }
    await Clipboard.setData(ClipboardData(text: buf.toString()));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bitácora copiada al portapapeles'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          'Bitácora de Seguridad',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        backgroundColor: const Color(0xFF1A237E),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          // Toggle filtro críticos
          Padding(
            padding: const EdgeInsets.only(right: 4),
            child: FilterChip(
              label: const Text(
                'Solo críticos',
                style: TextStyle(fontSize: 11, color: Colors.white),
              ),
              selected: _soloCriticos,
              onSelected: (v) => setState(() => _soloCriticos = v),
              selectedColor: Colors.red.shade700,
              backgroundColor: Colors.white.withAlpha(20),
              checkmarkColor: Colors.white,
              side: BorderSide.none,
            ),
          ),
          // Exportar
          IconButton(
            icon: const Icon(Icons.share_rounded),
            tooltip: 'Exportar bitácora',
            onPressed: _exportar,
          ),
        ],
      ),
      body:
          _cargando
              ? const Center(child: CircularProgressIndicator())
              : _filtrados.isEmpty
              ? _VistaVacia(soloCriticos: _soloCriticos)
              : RefreshIndicator(
                onRefresh: _cargar,
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 12,
                  ),
                  itemCount: _filtrados.length,
                  itemBuilder:
                      (_, i) => _ItemTimeline(
                        evento: _filtrados[i],
                        esUltimo: i == _filtrados.length - 1,
                      ),
                ),
              ),
      // Resumen en pie
      bottomNavigationBar: _todos.isEmpty ? null : _ResumenPie(eventos: _todos),
    );
  }
}

// ── Item de la línea de tiempo ────────────────────────────────────────────────

class _ItemTimeline extends StatelessWidget {
  final EventoSeguridad evento;
  final bool esUltimo;
  const _ItemTimeline({required this.evento, required this.esUltimo});

  Color get _color => switch (evento.prioridad) {
    'CRITICA' => Colors.red.shade700,
    'ESTANDAR' => Colors.orange.shade700,
    _ => Colors.blue.shade700,
  };

  IconData get _icono => switch (evento.tipo) {
    TipoEventoSeguridad.inicioProteccion => Icons.shield_rounded,
    TipoEventoSeguridad.finProteccion => Icons.shield_outlined,
    TipoEventoSeguridad.alertaAlejamiento => Icons.person_off_rounded,
    TipoEventoSeguridad.sosManual => Icons.warning_amber_rounded,
    TipoEventoSeguridad.accionGuia => Icons.swipe_right_alt_rounded,
    TipoEventoSeguridad.sincronizacion => Icons.cloud_done_rounded,
  };

  @override
  Widget build(BuildContext context) {
    final hora = DateFormat('HH:mm:ss').format(evento.timestamp);
    final fecha = DateFormat('dd/MM').format(evento.timestamp);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Eje de la línea de tiempo ──────────────────────────────────
          SizedBox(
            width: 48,
            child: Column(
              children: [
                Text(
                  hora,
                  style: TextStyle(fontSize: 9, color: Colors.grey.shade500),
                ),
                Text(
                  fecha,
                  style: TextStyle(fontSize: 8, color: Colors.grey.shade400),
                ),
                const SizedBox(height: 4),
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: _color.withAlpha(20),
                    shape: BoxShape.circle,
                    border: Border.all(color: _color, width: 1.5),
                  ),
                  child: Icon(_icono, size: 14, color: _color),
                ),
                if (!esUltimo)
                  Expanded(
                    child: VerticalDivider(
                      color: Colors.grey.shade300,
                      width: 1,
                      thickness: 1,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),

          // ── Tarjeta del evento ────────────────────────────────────────
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(12),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
                border:
                    evento.prioridad == 'CRITICA'
                        ? Border.all(color: Colors.red.shade200)
                        : null,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          evento.tipo.etiqueta,
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 12,
                            color: _color,
                          ),
                        ),
                      ),
                      // Badge de prioridad
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: _color.withAlpha(20),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          evento.prioridad,
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: _color,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    evento.descripcion,
                    style: const TextStyle(fontSize: 12, height: 1.4),
                  ),
                  if (evento.coordenadas.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_rounded,
                          size: 11,
                          color: Colors.grey.shade500,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          evento.coordenadas,
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  ],
                  if (!evento.sincronizado) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.cloud_off_rounded,
                          size: 11,
                          color: Colors.orange.shade400,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          'Pendiente de sincronización',
                          style: TextStyle(
                            fontSize: 9,
                            color: Colors.orange.shade400,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Pie de resumen ────────────────────────────────────────────────────────────

class _ResumenPie extends StatelessWidget {
  final List<EventoSeguridad> eventos;
  const _ResumenPie({required this.eventos});

  @override
  Widget build(BuildContext context) {
    final criticos = eventos.where((e) => e.prioridad == 'CRITICA').length;
    final noSync = eventos.where((e) => !e.sincronizado).length;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        children: [
          _StatChip(
            icono: Icons.event_note_rounded,
            valor: '${eventos.length}',
            etiqueta: 'eventos',
            color: Colors.blue,
          ),
          const SizedBox(width: 12),
          _StatChip(
            icono: Icons.warning_rounded,
            valor: '$criticos',
            etiqueta: 'críticos',
            color: Colors.red,
          ),
          const Spacer(),
          if (noSync > 0)
            _StatChip(
              icono: Icons.cloud_off_rounded,
              valor: '$noSync',
              etiqueta: 'sin sync',
              color: Colors.orange,
            ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final IconData icono;
  final String valor;
  final String etiqueta;
  final Color color;
  const _StatChip({
    required this.icono,
    required this.valor,
    required this.etiqueta,
    required this.color,
  });

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(icono, size: 14, color: color),
      const SizedBox(width: 4),
      Text(
        '$valor $etiqueta',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    ],
  );
}

// ── Vista vacía ───────────────────────────────────────────────────────────────

class _VistaVacia extends StatelessWidget {
  final bool soloCriticos;
  const _VistaVacia({required this.soloCriticos});

  @override
  Widget build(BuildContext context) => Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.history_rounded, size: 64, color: Colors.grey.shade300),
        const SizedBox(height: 16),
        Text(
          soloCriticos
              ? 'Sin alertas críticas registradas'
              : 'La bitácora está vacía',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade400,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Los eventos de seguridad aparecerán aquí\nconforme ocurran durante la expedición.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade400),
        ),
      ],
    ),
  );
}
