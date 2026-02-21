import 'package:flutter/material.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/features/guia/home/presentation/widgets/mapa_monitoreo_widget.dart';

// ────────────────────────────────────────────────────────────────────────────
// PANTALLA DE GESTIÓN DE CAMBIOS DE ITINERARIO
// Permite al guía ajustar actividades en tiempo real y sincronizar
// los nuevos límites de geocerca con todos los participantes.
// (ISO 31000 – Resiliencia Operativa)
// ────────────────────────────────────────────────────────────────────────────

class PantallaGestionCambios extends StatefulWidget {
  const PantallaGestionCambios({super.key});

  @override
  State<PantallaGestionCambios> createState() => _PantallaGestionCambiosState();
}

class _PantallaGestionCambiosState extends State<PantallaGestionCambios> {
  // Campos editables de la actividad actual
  final _horaInicioCtrl = TextEditingController(text: '10:00 AM');
  final _horaFinCtrl = TextEditingController(text: '02:00 PM');
  final _puntoReunCtrl = TextEditingController(
    text: 'Puerta 2 – Estacionamiento',
  );
  final _descripcionCtrl = TextEditingController(
    text: 'Recorrido guiado por la Pirámide del Sol y la Luna.',
  );

  // Radio de geocerca ajustable por el guía
  double _radioGeocerca = 300.0;

  // ID del turista seleccionado desde el mapa
  String? _turistaSeleccionado;

  bool _sincronizando = false;

  @override
  void dispose() {
    _horaInicioCtrl.dispose();
    _horaFinCtrl.dispose();
    _puntoReunCtrl.dispose();
    _descripcionCtrl.dispose();
    super.dispose();
  }

  // ── Simulación de sincronización ISO 31000 ────────────────────────────────
  Future<void> _simularSincronizacion() async {
    setState(() => _sincronizando = true);

    // Simula latencia de red (~2s)
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    setState(() => _sincronizando = false);

    await showDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withAlpha(20),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.sync_rounded,
                    size: 40,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  '¡Geocerca actualizada!',
                  style: TextStyle(fontSize: 16),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _FilaSincronizacionItem(
                  icono: Icons.access_time_rounded,
                  texto:
                      'Nueva hora: ${_horaInicioCtrl.text} – ${_horaFinCtrl.text}',
                ),
                const SizedBox(height: 6),
                _FilaSincronizacionItem(
                  icono: Icons.location_on_rounded,
                  texto: 'Punto: ${_puntoReunCtrl.text}',
                ),
                const SizedBox(height: 6),
                _FilaSincronizacionItem(
                  icono: Icons.radar_rounded,
                  texto: 'Radio ajustado a ${_radioGeocerca.round()} m',
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green.shade200),
                  ),
                  child: const Text(
                    'Cambios sincronizados con 24 dispositivos.\n'
                    'Geocerca re-evaluada según ISO 31000.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.green,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
            actions: [
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Entendido'),
                ),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F3FF),
      appBar: AppBar(
        title: const Text('Ajustar Itinerario'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.history_rounded),
            tooltip: 'Historial de cambios',
            onPressed:
                () => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Historial ISO 31000 disponible en producción',
                    ),
                  ),
                ),
          ),
        ],
      ),
      body: Column(
        children: [
          // ── Mapa (40% de la pantalla) ─────────────────────────────────
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.36,
            child: MapaMonitoreoWidget(
              radioMetros: _radioGeocerca,
              onTuristaTapped:
                  (id) => setState(() => _turistaSeleccionado = id),
            ),
          ),

          // ── Panel turista seleccionado ────────────────────────────────
          if (_turistaSeleccionado != null)
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  const Icon(
                    Icons.person_pin_rounded,
                    color: Colors.orange,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Turista seleccionado: $_turistaSeleccionado',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close, size: 16),
                    onPressed:
                        () => setState(() => _turistaSeleccionado = null),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),

          // ── Editor de actividad ───────────────────────────────────────
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Encabezado de la actividad
                  Row(
                    children: [
                      Container(
                        width: 4,
                        height: 36,
                        color: AppColors.primary,
                        margin: const EdgeInsets.only(right: 10),
                      ),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Actividad actual',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey,
                              ),
                            ),
                            Text(
                              'Visita a las Pirámides de Teotihuacán',
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Campo: Hora inicio
                  _CampoEditor(
                    label: 'Hora de inicio',
                    controller: _horaInicioCtrl,
                    icono: Icons.access_time_rounded,
                  ),
                  const SizedBox(height: 10),
                  _CampoEditor(
                    label: 'Hora de fin',
                    controller: _horaFinCtrl,
                    icono: Icons.timer_off_rounded,
                  ),
                  const SizedBox(height: 10),
                  _CampoEditor(
                    label: 'Punto de reunión',
                    controller: _puntoReunCtrl,
                    icono: Icons.location_on_rounded,
                  ),
                  const SizedBox(height: 10),
                  _CampoEditor(
                    label: 'Descripción',
                    controller: _descripcionCtrl,
                    icono: Icons.notes_rounded,
                    lineas: 2,
                  ),
                  const SizedBox(height: 16),

                  // Slider de radio de geocerca
                  Text(
                    'Radio de geocerca: ${_radioGeocerca.round()} m',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                  SliderTheme(
                    data: SliderTheme.of(context).copyWith(
                      activeTrackColor: AppColors.primary,
                      thumbColor: AppColors.primary,
                      overlayColor: AppColors.primary.withAlpha(30),
                    ),
                    child: Slider(
                      value: _radioGeocerca,
                      min: 50,
                      max: 1000,
                      divisions: 19,
                      label: '${_radioGeocerca.round()} m',
                      onChanged: (v) => setState(() => _radioGeocerca = v),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _ChipRadio(
                        label: '50 m',
                        onTap: () => setState(() => _radioGeocerca = 50),
                      ),
                      _ChipRadio(
                        label: '200 m',
                        onTap: () => setState(() => _radioGeocerca = 200),
                      ),
                      _ChipRadio(
                        label: '300 m',
                        onTap: () => setState(() => _radioGeocerca = 300),
                      ),
                      _ChipRadio(
                        label: '500 m',
                        onTap: () => setState(() => _radioGeocerca = 500),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Botón de sincronización
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton.icon(
                      onPressed: _sincronizando ? null : _simularSincronizacion,
                      icon:
                          _sincronizando
                              ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                              : const Icon(Icons.sync_rounded),
                      label: Text(
                        _sincronizando
                            ? 'Sincronizando...'
                            : 'ACTUALIZAR GEOCERCA Y NOTIFICAR',
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 13,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange.shade700,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        disabledBackgroundColor: Colors.orange.shade300,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Campo de edición ──────────────────────────────────────────────────────────

class _CampoEditor extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final IconData icono;
  final int lineas;

  const _CampoEditor({
    required this.label,
    required this.controller,
    required this.icono,
    this.lineas = 1,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: lineas,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icono, size: 18, color: Colors.grey),
        suffixIcon: const Icon(Icons.edit, size: 16, color: Colors.grey),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 12,
        ),
      ),
    );
  }
}

// ── Chip de selección rápida de radio ─────────────────────────────────────────

class _ChipRadio extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _ChipRadio({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Text(
          label,
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}

// ── Fila de detalle en el diálogo de confirmación ─────────────────────────────

class _FilaSincronizacionItem extends StatelessWidget {
  final IconData icono;
  final String texto;
  const _FilaSincronizacionItem({required this.icono, required this.texto});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icono, size: 15, color: AppColors.primary),
        const SizedBox(width: 8),
        Expanded(child: Text(texto, style: const TextStyle(fontSize: 12))),
      ],
    );
  }
}
