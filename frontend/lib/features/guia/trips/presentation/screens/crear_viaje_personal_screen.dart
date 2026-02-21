import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:frontend/features/agencia/trips/domain/entities/actividad_itinerario.dart';
import 'package:frontend/features/agencia/trips/data/models/trip_draft_model.dart';
import 'package:frontend/core/theme/app_colors.dart';
import 'package:frontend/features/guia/trips/presentation/widgets/contactos_confianza_widget.dart';

// ────────────────────────────────────────────────────────────────────────────
// CREAR VIAJE PERSONAL — Flujo B2C (Guía Independiente)
//
// 3 pasos tipo "Wizard" optimizado para móvil:
//   Paso 1 – Base        : nombre, destino, fechas
//   Paso 2 – Ruta        : actividades (DraggableScrollableSheet)
//   Paso 3 – Seguridad   : contactos de confianza + geocerca pre-calculada
//
// Reutiliza: TripDraftModel · ActividadItinerario · TipoActividad
// Guarda en: SharedPreferences (offline-first) → sync en background
// ────────────────────────────────────────────────────────────────────────────

const _naranja = Color(0xFFE65100);
const _naranjaClaro = Color(0xFFFFF3E0);
const _uuid = Uuid();

class CrearViajePersonalScreen extends StatefulWidget {
  const CrearViajePersonalScreen({super.key});

  @override
  State<CrearViajePersonalScreen> createState() =>
      _CrearViajePersonalScreenState();
}

class _CrearViajePersonalScreenState extends State<CrearViajePersonalScreen> {
  int _pasoActual = 0;
  bool _guardando = false;

  // ── Paso 1 ────────────────────────────────────────────────────────────────
  final _nombreCtrl = TextEditingController();
  final _destinoCtrl = TextEditingController();
  DateTime? _fechaInicio;
  DateTime? _fechaFin;

  // ── Paso 2 ────────────────────────────────────────────────────────────────
  final List<ActividadItinerario> _actividades = [];

  // ── Paso 3 ────────────────────────────────────────────────────────────────
  final List<ContactoConfianza> _contactos = [];
  double _radioGeocerca = 300.0;

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _destinoCtrl.dispose();
    super.dispose();
  }

  // ── Validación por paso ───────────────────────────────────────────────────
  bool get _paso1Valido =>
      _nombreCtrl.text.trim().isNotEmpty &&
      _destinoCtrl.text.trim().isNotEmpty &&
      _fechaInicio != null &&
      _fechaFin != null &&
      !_fechaFin!.isBefore(_fechaInicio!);

  bool get _paso2Valido => _actividades.isNotEmpty;

  // ── Guardado offline (SharedPreferences) ─────────────────────────────────
  Future<void> _publicarYProteger() async {
    setState(() => _guardando = true);

    final draft = TripDraftModel(
      destino: _destinoCtrl.text.trim(),
      fechaInicio: _fechaInicio!.toIso8601String(),
      fechaFin: _fechaFin!.toIso8601String(),
      actividades: _actividades,
    );

    final prefs = await SharedPreferences.getInstance();
    final lista = prefs.getStringList('VIAJES_PERSONALES_DRAFT') ?? [];
    final entry = json.encode({
      'id': _uuid.v4(),
      'nombre': _nombreCtrl.text.trim(),
      'radio': _radioGeocerca,
      'contactos': _contactos.map((c) => c.toMap()).toList(),
      'draft': draft.toJson(),
      'syncPendiente': true,
      'creadoEn': DateTime.now().toIso8601String(),
    });
    lista.add(entry);
    await prefs.setStringList('VIAJES_PERSONALES_DRAFT', lista);

    if (!mounted) return;
    setState(() => _guardando = false);

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
                    color: _naranjaClaro,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.shield_rounded,
                    color: _naranja,
                    size: 36,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  '¡Expedición creada!',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _FilaInfo(
                  Icons.location_on_rounded,
                  'Destino: ${_destinoCtrl.text.trim()}',
                ),
                const SizedBox(height: 6),
                _FilaInfo(
                  Icons.radar_rounded,
                  'Radio de geocerca: ${_radioGeocerca.round()} m',
                ),
                const SizedBox(height: 6),
                _FilaInfo(
                  Icons.people_rounded,
                  'Contactos SOS: ${_contactos.length}',
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
                    '✅ Viaje guardado localmente.\n'
                    'La protección inteligente funcionará aunque pierdas la señal.\n'
                    'Se sincronizará con OhtliAni cuando haya red.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.green,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
            actions: [
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _naranja,
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
      backgroundColor: const Color(0xFFFFF8F0),
      appBar: AppBar(
        title: const Text('Nueva Expedición'),
        backgroundColor: _naranja,
        foregroundColor: Colors.white,
        actions: [
          if (_pasoActual == 2)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: TextButton.icon(
                onPressed: _guardando ? null : _publicarYProteger,
                icon:
                    _guardando
                        ? const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                        : const Icon(
                          Icons.shield_rounded,
                          color: Colors.white,
                          size: 16,
                        ),
                label: Text(
                  _guardando ? 'Guardando…' : 'Publicar',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
        ],
      ),
      body: Stepper(
        currentStep: _pasoActual,
        type: StepperType.horizontal,
        controlsBuilder:
            (ctx, details) => _ControlesStepper(
              details: details,
              pasoActual: _pasoActual,
              paso1Valido: _paso1Valido,
              paso2Valido: _paso2Valido,
              guardando: _guardando,
              onPublicar: _publicarYProteger,
            ),
        onStepTapped: (i) {
          if (i < _pasoActual) setState(() => _pasoActual = i);
        },
        onStepContinue: () {
          if (_pasoActual == 0 && !_paso1Valido) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Completa nombre, destino y fechas'),
                backgroundColor: Colors.orange,
              ),
            );
            return;
          }
          if (_pasoActual == 1 && !_paso2Valido) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Agrega al menos una actividad'),
                backgroundColor: Colors.orange,
              ),
            );
            return;
          }
          if (_pasoActual < 2) setState(() => _pasoActual++);
        },
        onStepCancel: () {
          if (_pasoActual > 0) setState(() => _pasoActual--);
        },
        steps: [
          Step(
            title: const Text('Base'),
            isActive: _pasoActual >= 0,
            state: _pasoActual > 0 ? StepState.complete : StepState.indexed,
            content: _FormularioBase(
              nombreCtrl: _nombreCtrl,
              destinoCtrl: _destinoCtrl,
              fechaInicio: _fechaInicio,
              fechaFin: _fechaFin,
              onFechaInicio: (d) => setState(() => _fechaInicio = d),
              onFechaFin: (d) => setState(() => _fechaFin = d),
            ),
          ),
          Step(
            title: const Text('Ruta'),
            isActive: _pasoActual >= 1,
            state: _pasoActual > 1 ? StepState.complete : StepState.indexed,
            content: _ListaActividadesMobile(
              actividades: _actividades,
              fechaBase: _fechaInicio ?? DateTime.now(),
              onChanged:
                  (lista) => setState(() {
                    _actividades
                      ..clear()
                      ..addAll(lista);
                  }),
            ),
          ),
          Step(
            title: const Text('Seguridad'),
            isActive: _pasoActual >= 2,
            state: StepState.indexed,
            content: _ConfiguracionSeguridad(
              contactos: _contactos,
              radioGeocerca: _radioGeocerca,
              actividades: _actividades,
              onContactosChanged:
                  (c) => setState(() {
                    _contactos
                      ..clear()
                      ..addAll(c);
                  }),
              onRadioChanged: (r) => setState(() => _radioGeocerca = r),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Paso 1: Formulario base ───────────────────────────────────────────────────

class _FormularioBase extends StatelessWidget {
  final TextEditingController nombreCtrl;
  final TextEditingController destinoCtrl;
  final DateTime? fechaInicio;
  final DateTime? fechaFin;
  final void Function(DateTime) onFechaInicio;
  final void Function(DateTime) onFechaFin;

  const _FormularioBase({
    required this.nombreCtrl,
    required this.destinoCtrl,
    required this.fechaInicio,
    required this.fechaFin,
    required this.onFechaInicio,
    required this.onFechaFin,
  });

  Future<void> _elegirFecha(BuildContext ctx, bool esInicio) async {
    final hoy = DateTime.now();
    final inicial =
        esInicio
            ? (fechaInicio ?? hoy)
            : (fechaFin ?? (fechaInicio ?? hoy).add(const Duration(days: 1)));
    final picked = await showDatePicker(
      context: ctx,
      initialDate: inicial,
      firstDate: hoy,
      lastDate: hoy.add(const Duration(days: 365 * 2)),
      builder:
          (c, child) => Theme(
            data: Theme.of(
              c,
            ).copyWith(colorScheme: const ColorScheme.light(primary: _naranja)),
            child: child!,
          ),
    );
    if (picked == null) return;
    if (esInicio) {
      onFechaInicio(picked);
    } else {
      onFechaFin(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _Campo(
          label: 'Nombre de la expedición',
          icono: Icons.explore_rounded,
          controller: nombreCtrl,
        ),
        const SizedBox(height: 12),
        _Campo(
          label: 'Destino',
          icono: Icons.location_on_rounded,
          controller: destinoCtrl,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _SelectorFecha(
                label: 'Inicio',
                fecha: fechaInicio,
                onTap: () => _elegirFecha(context, true),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _SelectorFecha(
                label: 'Fin',
                fecha: fechaFin,
                onTap: () => _elegirFecha(context, false),
                error:
                    fechaFin != null &&
                    fechaInicio != null &&
                    fechaFin!.isBefore(fechaInicio!),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ── Paso 2: Lista de actividades mobile-first ─────────────────────────────────

class _ListaActividadesMobile extends StatelessWidget {
  final List<ActividadItinerario> actividades;
  final DateTime fechaBase;
  final void Function(List<ActividadItinerario>) onChanged;

  const _ListaActividadesMobile({
    required this.actividades,
    required this.fechaBase,
    required this.onChanged,
  });

  void _abrirSheet(BuildContext ctx, {ActividadItinerario? editando}) {
    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (_) => _ActividadSheet(
            fechaBase: fechaBase,
            actividad: editando,
            onGuardar: (a) {
              final lista = List<ActividadItinerario>.from(actividades);
              final idx = lista.indexWhere((x) => x.id == a.id);
              if (idx >= 0) {
                lista[idx] = a;
              } else {
                lista.add(a);
              }
              onChanged(lista);
            },
            onEliminar:
                editando == null
                    ? null
                    : (id) {
                      onChanged(actividades.where((a) => a.id != id).toList());
                    },
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (actividades.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.grey.shade200,
                style: BorderStyle.solid,
              ),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.route_rounded,
                  size: 36,
                  color: Colors.grey.shade300,
                ),
                const SizedBox(height: 8),
                Text(
                  'Sin actividades aún',
                  style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
                ),
                const SizedBox(height: 4),
                Text(
                  'Toca "＋ Añadir" para empezar tu ruta',
                  style: TextStyle(color: Colors.grey.shade400, fontSize: 11),
                ),
              ],
            ),
          )
        else
          ...actividades.map(
            (a) => _TarjetaActividad(
              actividad: a,
              onTap: () => _abrirSheet(context, editando: a),
            ),
          ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => _abrirSheet(context),
            icon: const Icon(Icons.add_circle_rounded),
            label: const Text('Añadir actividad'),
            style: OutlinedButton.styleFrom(
              foregroundColor: _naranja,
              side: const BorderSide(color: _naranja),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Paso 3: Seguridad pasiva (delega contactos al widget standalone) ─────────

class _ConfiguracionSeguridad extends StatelessWidget {
  final List<ContactoConfianza> contactos;
  final double radioGeocerca;
  final List<ActividadItinerario> actividades;
  final void Function(List<ContactoConfianza>) onContactosChanged;
  final void Function(double) onRadioChanged;

  const _ConfiguracionSeguridad({
    required this.contactos,
    required this.radioGeocerca,
    required this.actividades,
    required this.onContactosChanged,
    required this.onRadioChanged,
  });

  // Radio sugerido ISO 31000 según actividades
  double get _radioSugerido {
    final tipos = actividades.map((a) => a.tipo).toSet();
    if (tipos.contains(TipoActividad.aventura)) return 500;
    if (tipos.contains(TipoActividad.traslado)) return 400;
    if (tipos.contains(TipoActividad.visitaGuiada)) return 300;
    return 200;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Radio de geocerca ─────────────────────────────────────────────
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: _naranjaClaro,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _naranja.withAlpha(60)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.radar_rounded, color: _naranja, size: 18),
                  const SizedBox(width: 8),
                  const Text(
                    'Radio de geocerca',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                      color: _naranja,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: _naranja.withAlpha(20),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${radioGeocerca.round()} m',
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                        color: _naranja,
                      ),
                    ),
                  ),
                ],
              ),
              if (actividades.isNotEmpty) ...[
                const SizedBox(height: 6),
                GestureDetector(
                  onTap: () => onRadioChanged(_radioSugerido),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: _naranja.withAlpha(80)),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.auto_fix_high_rounded,
                          size: 14,
                          color: _naranja,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'ISO 31000 sugiere ${_radioSugerido.round()} m '
                            'según tus actividades — toca para aplicar',
                            style: const TextStyle(
                              fontSize: 10,
                              color: _naranja,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: _naranja,
                  thumbColor: _naranja,
                  overlayColor: _naranja.withAlpha(30),
                ),
                child: Slider(
                  value: radioGeocerca,
                  min: 50,
                  max: 1000,
                  divisions: 19,
                  label: '${radioGeocerca.round()} m',
                  onChanged: onRadioChanged,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // ── Contactos de confianza (widget reutilizable) ───────────────────
        ContactosConfianzaWidget(
          contactos: contactos,
          onChanged: onContactosChanged,
        ),

        const SizedBox(height: 12),
        // Aviso offline
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.blue.shade100),
          ),
          child: const Row(
            children: [
              Icon(Icons.offline_pin_rounded, color: Colors.blue, size: 18),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Las geocercas se pre-calculan para cada actividad.\n'
                  'Funcionan offline y se sincronizarán en segundo '
                  'plano cuando tengas conexión.',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.blue,
                    height: 1.4,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Bottom Sheet: Editor de actividad ─────────────────────────────────────────

class _ActividadSheet extends StatefulWidget {
  final DateTime fechaBase;
  final ActividadItinerario? actividad;
  final void Function(ActividadItinerario) onGuardar;
  final void Function(String)? onEliminar;

  const _ActividadSheet({
    required this.fechaBase,
    required this.onGuardar,
    this.actividad,
    this.onEliminar,
  });

  @override
  State<_ActividadSheet> createState() => _ActividadSheetState();
}

class _ActividadSheetState extends State<_ActividadSheet> {
  final _tituloCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  TipoActividad _tipo = TipoActividad.visitaGuiada;
  late TimeOfDay _inicio;
  late TimeOfDay _fin;

  @override
  void initState() {
    super.initState();
    final a = widget.actividad;
    _tituloCtrl.text = a?.titulo ?? '';
    _descCtrl.text = a?.descripcion ?? '';
    _tipo = a?.tipo ?? TipoActividad.visitaGuiada;
    _inicio =
        a != null
            ? TimeOfDay.fromDateTime(a.horaInicio)
            : const TimeOfDay(hour: 9, minute: 0);
    _fin =
        a != null
            ? TimeOfDay.fromDateTime(a.horaFin)
            : const TimeOfDay(hour: 11, minute: 0);
  }

  @override
  void dispose() {
    _tituloCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  DateTime _toDateTime(TimeOfDay t) => DateTime(
    widget.fechaBase.year,
    widget.fechaBase.month,
    widget.fechaBase.day,
    t.hour,
    t.minute,
  );

  Future<void> _elegirHora(bool esInicio) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: esInicio ? _inicio : _fin,
      builder:
          (c, child) => Theme(
            data: Theme.of(
              c,
            ).copyWith(colorScheme: const ColorScheme.light(primary: _naranja)),
            child: child!,
          ),
    );
    if (picked == null) return;
    setState(() => esInicio ? _inicio = picked : _fin = picked);
  }

  void _guardar() {
    if (_tituloCtrl.text.trim().isEmpty) return;
    final horaIni = _toDateTime(_inicio);
    final horaFin = _toDateTime(_fin);
    if (!horaFin.isAfter(horaIni)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('La hora de fin debe ser posterior al inicio'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    widget.onGuardar(
      ActividadItinerario(
        id: widget.actividad?.id ?? _uuid.v4(),
        titulo: _tituloCtrl.text.trim(),
        descripcion: _descCtrl.text.trim(),
        tipo: _tipo,
        horaInicio: horaIni,
        horaFin: horaFin,
        radioGeocerca: 100,
      ),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final colorTipo = _colorTipo(_tipo);
    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder:
          (_, scroll) => Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Column(
              children: [
                // Handle
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                // Título del sheet
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: colorTipo.withAlpha(25),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          _iconoTipo(_tipo),
                          color: colorTipo,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        widget.actividad == null ? 'Nueva actividad' : 'Editar',
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                        ),
                      ),
                      const Spacer(),
                      if (widget.onEliminar != null)
                        IconButton(
                          icon: const Icon(
                            Icons.delete_outline,
                            color: Colors.red,
                          ),
                          onPressed: () {
                            widget.onEliminar!(widget.actividad!.id);
                            Navigator.pop(context);
                          },
                        ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                // Contenido
                Expanded(
                  child: ListView(
                    controller: scroll,
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                    children: [
                      // Título
                      TextField(
                        controller: _tituloCtrl,
                        decoration: InputDecoration(
                          labelText: 'Nombre de la actividad',
                          prefixIcon: const Icon(Icons.title),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Tipo
                      const Text(
                        'Tipo de actividad',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children:
                            TipoActividad.values.map((t) {
                              final sel = t == _tipo;
                              return GestureDetector(
                                onTap: () => setState(() => _tipo = t),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 150),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color:
                                        sel
                                            ? _colorTipo(t).withAlpha(25)
                                            : Colors.grey.shade100,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color:
                                          sel
                                              ? _colorTipo(t)
                                              : Colors.grey.shade200,
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        _iconoTipo(t),
                                        size: 14,
                                        color:
                                            sel
                                                ? _colorTipo(t)
                                                : Colors.grey.shade500,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        _labelTipo(t),
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight:
                                              sel
                                                  ? FontWeight.w700
                                                  : FontWeight.normal,
                                          color:
                                              sel
                                                  ? _colorTipo(t)
                                                  : Colors.grey.shade600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                      ),
                      const SizedBox(height: 14),

                      // Horarios
                      Row(
                        children: [
                          Expanded(
                            child: _SelectorHora(
                              label: 'Inicio',
                              hora: _inicio,
                              onTap: () => _elegirHora(true),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _SelectorHora(
                              label: 'Fin',
                              hora: _fin,
                              onTap: () => _elegirHora(false),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Descripción
                      TextField(
                        controller: _descCtrl,
                        maxLines: 2,
                        decoration: InputDecoration(
                          labelText: 'Descripción (opcional)',
                          prefixIcon: const Icon(Icons.notes_rounded),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Botón guardar
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton.icon(
                          onPressed: _guardar,
                          icon: const Icon(Icons.check_rounded),
                          label: const Text(
                            'Guardar actividad',
                            style: TextStyle(fontWeight: FontWeight.w800),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _naranja,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
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

// ── Helpers de tipo de actividad ──────────────────────────────────────────────

Color _colorTipo(TipoActividad t) => switch (t) {
  TipoActividad.traslado => Colors.blue,
  TipoActividad.visitaGuiada => const Color(0xFF6A1B9A),
  TipoActividad.checkIn => Colors.teal,
  TipoActividad.tiempoLibre => Colors.pink,
  TipoActividad.comida => Colors.orange,
  TipoActividad.hospedaje => Colors.indigo,
  TipoActividad.aventura => Colors.green.shade700,
  TipoActividad.cultura => Colors.brown,
  TipoActividad.otro => Colors.grey,
};

IconData _iconoTipo(TipoActividad t) => switch (t) {
  TipoActividad.traslado => Icons.directions_car_rounded,
  TipoActividad.visitaGuiada => Icons.tour_rounded,
  TipoActividad.checkIn => Icons.hotel_rounded,
  TipoActividad.tiempoLibre => Icons.self_improvement_rounded,
  TipoActividad.comida => Icons.restaurant_rounded,
  TipoActividad.hospedaje => Icons.bed_rounded,
  TipoActividad.aventura => Icons.hiking_rounded,
  TipoActividad.cultura => Icons.museum_rounded,
  TipoActividad.otro => Icons.more_horiz_rounded,
};

String _labelTipo(TipoActividad t) => switch (t) {
  TipoActividad.traslado => 'Traslado',
  TipoActividad.visitaGuiada => 'Visita',
  TipoActividad.checkIn => 'Check-in',
  TipoActividad.tiempoLibre => 'Libre',
  TipoActividad.comida => 'Comida',
  TipoActividad.hospedaje => 'Hotel',
  TipoActividad.aventura => 'Aventura',
  TipoActividad.cultura => 'Cultura',
  TipoActividad.otro => 'Otro',
};

// ── Widgets auxiliares ────────────────────────────────────────────────────────

class _Campo extends StatelessWidget {
  final String label;
  final IconData icono;
  final TextEditingController controller;

  const _Campo({
    required this.label,
    required this.icono,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) => TextField(
    controller: controller,
    decoration: InputDecoration(
      labelText: label,
      prefixIcon: Icon(icono, size: 18),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.grey.shade200),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
    ),
  );
}

class _SelectorFecha extends StatelessWidget {
  final String label;
  final DateTime? fecha;
  final VoidCallback onTap;
  final bool error;

  const _SelectorFecha({
    required this.label,
    required this.fecha,
    required this.onTap,
    this.error = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color:
                error
                    ? Colors.red
                    : fecha != null
                    ? _naranja
                    : Colors.grey.shade200,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_today_rounded,
              size: 16,
              color:
                  error
                      ? Colors.red
                      : fecha != null
                      ? _naranja
                      : Colors.grey,
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                fecha != null
                    ? '${fecha!.day}/${fecha!.month}/${fecha!.year}'
                    : label,
                style: TextStyle(
                  fontSize: 12,
                  color:
                      fecha != null
                          ? (error ? Colors.red : const Color(0xFF1A1A2E))
                          : Colors.grey,
                  fontWeight:
                      fecha != null ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SelectorHora extends StatelessWidget {
  final String label;
  final TimeOfDay hora;
  final VoidCallback onTap;

  const _SelectorHora({
    required this.label,
    required this.hora,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: _naranjaClaro,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: _naranja.withAlpha(80)),
        ),
        child: Row(
          children: [
            const Icon(Icons.access_time_rounded, size: 16, color: _naranja),
            const SizedBox(width: 6),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(fontSize: 9, color: _naranja),
                ),
                Text(
                  hora.format(context),
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                    color: _naranja,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TarjetaActividad extends StatelessWidget {
  final ActividadItinerario actividad;
  final VoidCallback onTap;

  const _TarjetaActividad({required this.actividad, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final color = _colorTipo(actividad.tipo);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.shade100),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(8),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withAlpha(20),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(_iconoTipo(actividad.tipo), color: color, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    actividad.titulo,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                  Text(
                    '${TimeOfDay.fromDateTime(actividad.horaInicio).format(context)} – '
                    '${TimeOfDay.fromDateTime(actividad.horaFin).format(context)}',
                    style: const TextStyle(fontSize: 11, color: Colors.grey),
                  ),
                ],
              ),
            ),
            const Icon(Icons.edit_rounded, size: 16, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}

class _FilaInfo extends StatelessWidget {
  final IconData icono;
  final String texto;
  const _FilaInfo(this.icono, this.texto);

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Icon(icono, size: 15, color: AppColors.primary),
      const SizedBox(width: 8),
      Expanded(child: Text(texto, style: const TextStyle(fontSize: 12))),
    ],
  );
}

// ── Controles del Stepper ─────────────────────────────────────────────────────

class _ControlesStepper extends StatelessWidget {
  final ControlsDetails details;
  final int pasoActual;
  final bool paso1Valido;
  final bool paso2Valido;
  final bool guardando;
  final VoidCallback onPublicar;

  const _ControlesStepper({
    required this.details,
    required this.pasoActual,
    required this.paso1Valido,
    required this.paso2Valido,
    required this.guardando,
    required this.onPublicar,
  });

  @override
  Widget build(BuildContext context) {
    final esUltimo = pasoActual == 2;
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Row(
        children: [
          if (pasoActual > 0)
            OutlinedButton(
              onPressed: details.onStepCancel,
              style: OutlinedButton.styleFrom(
                foregroundColor: _naranja,
                side: const BorderSide(color: _naranja),
              ),
              child: const Text('Atrás'),
            ),
          if (pasoActual > 0) const SizedBox(width: 10),
          Expanded(
            child: ElevatedButton(
              onPressed:
                  esUltimo
                      ? (guardando ? null : onPublicar)
                      : details.onStepContinue,
              style: ElevatedButton.styleFrom(
                backgroundColor: _naranja,
                foregroundColor: Colors.white,
                disabledBackgroundColor: Colors.orange.shade200,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child:
                  esUltimo
                      ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (guardando)
                            const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          else
                            const Icon(Icons.shield_rounded, size: 16),
                          const SizedBox(width: 8),
                          Text(
                            guardando ? 'Guardando…' : 'Publicar y Proteger',
                            style: const TextStyle(fontWeight: FontWeight.w800),
                          ),
                        ],
                      )
                      : const Text(
                        'Continuar',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
            ),
          ),
        ],
      ),
    );
  }
}
