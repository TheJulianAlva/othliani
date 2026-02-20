import 'package:flutter/material.dart';

// ────────────────────────────────────────────────────────────────────────────
// GESTIÓN DE CAMBIOS DE ITINERARIO
// Pantalla exclusiva del guía: ver actividades, editarlas y simular
// la sincronización de la geocerca con el grupo (ISO 31000).
// ────────────────────────────────────────────────────────────────────────────

const _azulPrimario = Color(0xFF1A237E);
const _azulSecundario = Color(0xFF3D5AF1);

// ── Modelo de actividad editable ──────────────────────────────────────────────

class _Actividad {
  String nombre;
  String horaInicio;
  String horaFin;
  String puntReunion;
  String descripcion;
  bool completada;

  _Actividad({
    required this.nombre,
    required this.horaInicio,
    required this.horaFin,
    required this.puntReunion,
    required this.descripcion,
    this.completada = false,
  });

  _Actividad copyWith({
    String? nombre,
    String? horaInicio,
    String? horaFin,
    String? puntReunion,
    String? descripcion,
  }) => _Actividad(
    nombre: nombre ?? this.nombre,
    horaInicio: horaInicio ?? this.horaInicio,
    horaFin: horaFin ?? this.horaFin,
    puntReunion: puntReunion ?? this.puntReunion,
    descripcion: descripcion ?? this.descripcion,
    completada: completada,
  );
}

// ── Pantalla principal: Itinerario del guía ───────────────────────────────────

class GuiaItineraryScreen extends StatefulWidget {
  const GuiaItineraryScreen({super.key});

  @override
  State<GuiaItineraryScreen> createState() => _GuiaItineraryScreenState();
}

class _GuiaItineraryScreenState extends State<GuiaItineraryScreen> {
  int _diaSeleccionado = 0;
  int _filtro = 1; // 0=pendientes 1=en progreso 2=todas

  final List<String> _dias = ['Día 1', 'Día 2', 'Día 3', 'Día 4'];

  final List<List<_Actividad>> _actividadesPorDia = [
    // Día 1
    [
      _Actividad(
        nombre: 'Ruinas arqueológicas',
        horaInicio: '08:00',
        horaFin: '12:00',
        puntReunion: 'Estado de Quintana Roo',
        descripcion:
            'Lugar cultural y de valor histórico de las culturas mesoamericanas',
        completada: false,
      ),
      _Actividad(
        nombre: 'Cenote Maya',
        horaInicio: '13:00',
        horaFin: '15:00',
        puntReunion: 'Cenote Ik Kil',
        descripcion: 'Visita al cenote más famoso de la región yucateca',
        completada: false,
      ),
      _Actividad(
        nombre: 'Plaza comercial',
        horaInicio: '15:30',
        horaFin: '17:30',
        puntReunion: 'La Isla Shopping Village',
        descripcion: 'Recorrido por la plaza con tiempo libre',
        completada: false,
      ),
      _Actividad(
        nombre: 'Restaurante',
        horaInicio: '19:00',
        horaFin: '21:00',
        puntReunion: 'Centro de Cancún',
        descripcion: 'Cena grupal en restaurante de cocina yucateca',
        completada: false,
      ),
    ],
    // Día 2
    [
      _Actividad(
        nombre: 'Visita Tulum',
        horaInicio: '09:00',
        horaFin: '13:00',
        puntReunion: 'Zona Arqueológica Tulum',
        descripcion: 'Ruinas al borde del mar Caribe',
        completada: false,
      ),
      _Actividad(
        nombre: 'Playa Paraíso',
        horaInicio: '14:00',
        horaFin: '17:00',
        puntReunion: 'Acceso público km 3',
        descripcion: 'Tiempo libre en la playa',
        completada: false,
      ),
    ],
    // Día 3
    [
      _Actividad(
        nombre: 'Xcaret Park',
        horaInicio: '09:00',
        horaFin: '18:00',
        puntReunion: 'Entrada principal Xcaret',
        descripcion: 'Parque eco-arqueológico completo',
        completada: false,
      ),
    ],
    // Día 4
    [
      _Actividad(
        nombre: 'Snorkel Cozumel',
        horaInicio: '08:00',
        horaFin: '14:00',
        puntReunion: 'Muelle fiscal Cozumel',
        descripcion: 'Tour de snorkel en arrecifes de coral',
        completada: false,
      ),
      _Actividad(
        nombre: 'Traslado aeropuerto',
        horaInicio: '17:00',
        horaFin: '19:00',
        puntReunion: 'Lobby del hotel',
        descripcion: 'Traslado final al aeropuerto internacional',
        completada: false,
      ),
    ],
  ];

  List<_Actividad> get _actividadesFiltradas {
    final lista = _actividadesPorDia[_diaSeleccionado];
    return switch (_filtro) {
      0 => lista.where((a) => !a.completada).toList(),
      1 =>
        lista
            .where((a) => !a.completada)
            .toList(), // "En progreso" = pendientes para el mock
      _ => lista,
    };
  }

  void _editarActividad(int index) async {
    final actividad = _actividadesFiltradas[index];
    final globalIndex = _actividadesPorDia[_diaSeleccionado].indexOf(actividad);

    final resultado = await Navigator.of(context).push<_Actividad>(
      MaterialPageRoute(
        builder: (_) => _EditorActividad(actividad: actividad, esNueva: false),
      ),
    );

    if (resultado != null && mounted) {
      setState(() {
        _actividadesPorDia[_diaSeleccionado][globalIndex] = resultado;
      });
      _mostrarSincronizando();
    }
  }

  void _crearActividad() async {
    final nueva = _Actividad(
      nombre: '',
      horaInicio: '08:00',
      horaFin: '10:00',
      puntReunion: '',
      descripcion: '',
    );
    final resultado = await Navigator.of(context).push<_Actividad>(
      MaterialPageRoute(
        builder: (_) => _EditorActividad(actividad: nueva, esNueva: true),
      ),
    );
    if (resultado != null && mounted) {
      setState(() {
        _actividadesPorDia[_diaSeleccionado].add(resultado);
      });
      _mostrarSincronizando();
    }
  }

  void _eliminarActividad(int index) {
    final actividad = _actividadesFiltradas[index];
    final globalIndex = _actividadesPorDia[_diaSeleccionado].indexOf(actividad);
    setState(() => _actividadesPorDia[_diaSeleccionado].removeAt(globalIndex));
  }

  void _mostrarSincronizando() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Row(
          children: [
            SizedBox(
              width: 14,
              height: 14,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Text('Sincronizando nueva geocerca con el grupo...'),
            ),
          ],
        ),
        duration: Duration(seconds: 3),
        backgroundColor: Color(0xFF1A237E),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F3FF),
      appBar: AppBar(
        title: const Text('viajes'),
        backgroundColor: _azulPrimario,
        foregroundColor: Colors.white,
        actions: [
          IconButton(icon: const Icon(Icons.person_rounded), onPressed: () {}),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header del viaje ─────────────────────────────────────────
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Cancún – Tulum',
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Color(0xFF2E7D32),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      'Status: Activo',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF2E7D32),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Icon(Icons.people, size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    const Text('30', style: TextStyle(fontSize: 12)),
                  ],
                ),
              ],
            ),
          ),

          // ── Selector de días ─────────────────────────────────────────
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Actividades',
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 20,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit, size: 18),
                      onPressed: _crearActividad,
                      color: _azulSecundario,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: List.generate(_dias.length, (i) {
                      final sel = i == _diaSeleccionado;
                      return GestureDetector(
                        onTap: () => setState(() => _diaSeleccionado = i),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 7,
                          ),
                          decoration: BoxDecoration(
                            color: sel ? _azulSecundario : Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            _dias[i],
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: sel ? Colors.white : Colors.grey.shade700,
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
                const SizedBox(height: 10),
                // Filtros
                Row(
                  children: [
                    _FiltroChip(
                      label: 'pendientes',
                      sel: _filtro == 0,
                      onTap: () => setState(() => _filtro = 0),
                    ),
                    const SizedBox(width: 8),
                    _FiltroChip(
                      label: 'en progreso',
                      sel: _filtro == 1,
                      onTap: () => setState(() => _filtro = 1),
                      color: _azulPrimario,
                    ),
                    const SizedBox(width: 8),
                    _FiltroChip(
                      label: 'todas',
                      sel: _filtro == 2,
                      onTap: () => setState(() => _filtro = 2),
                      color: Colors.grey.shade600,
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 8),

          // ── Lista de actividades ─────────────────────────────────────
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: _actividadesFiltradas.length,
              itemBuilder: (_, i) {
                final a = _actividadesFiltradas[i];
                return _TarjetaActividad(
                  actividad: a,
                  onEditar: () => _editarActividad(i),
                  onEliminar: () => _eliminarActividad(i),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _crearActividad,
        backgroundColor: _azulSecundario,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
    );
  }
}

// ── Tarjeta de actividad ──────────────────────────────────────────────────────

class _TarjetaActividad extends StatelessWidget {
  final _Actividad actividad;
  final VoidCallback onEditar;
  final VoidCallback onEliminar;
  const _TarjetaActividad({
    required this.actividad,
    required this.onEditar,
    required this.onEliminar,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  actividad.nombre,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.edit, size: 16, color: _azulSecundario),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: onEditar,
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: Icon(
                  Icons.delete_outline,
                  size: 16,
                  color: Colors.red.shade300,
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                onPressed: onEliminar,
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            actividad.descripcion,
            style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }
}

// ── Editor de actividad (p1.1.2 del boceto) ───────────────────────────────────

class _EditorActividad extends StatefulWidget {
  final _Actividad actividad;
  final bool esNueva;
  const _EditorActividad({required this.actividad, required this.esNueva});

  @override
  State<_EditorActividad> createState() => _EditorActividadState();
}

class _EditorActividadState extends State<_EditorActividad> {
  late final TextEditingController _nombre;
  late final TextEditingController _descripcion;
  late String _horaInicio;
  late String _horaFin;
  String? _puntoSeleccionado;

  final _puntos = [
    'Estado de Quintana Roo',
    'Cenote Ik Kil',
    'La Isla Shopping Village',
    'Zona Arqueológica Tulum',
    'Muelle fiscal Cozumel',
    'Lobby del hotel',
    'Acceso principal',
  ];

  final _horas = List.generate(48, (i) {
    final h = i ~/ 2;
    final m = i % 2 == 0 ? '00' : '30';
    return '${h.toString().padLeft(2, '0')}:$m';
  });

  @override
  void initState() {
    super.initState();
    _nombre = TextEditingController(text: widget.actividad.nombre);
    _descripcion = TextEditingController(text: widget.actividad.descripcion);
    _horaInicio = widget.actividad.horaInicio;
    _horaFin = widget.actividad.horaFin;
    _puntoSeleccionado =
        _puntos.contains(widget.actividad.puntReunion)
            ? widget.actividad.puntReunion
            : null;
  }

  @override
  void dispose() {
    _nombre.dispose();
    _descripcion.dispose();
    super.dispose();
  }

  void _guardar() {
    if (_nombre.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('El nombre es obligatorio')));
      return;
    }
    Navigator.of(context).pop(
      widget.actividad.copyWith(
        nombre: _nombre.text.trim(),
        horaInicio: _horaInicio,
        horaFin: _horaFin,
        puntReunion: _puntoSeleccionado ?? '',
        descripcion: _descripcion.text.trim(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F3FF),
      appBar: AppBar(
        title: const Text('viajes'),
        backgroundColor: _azulPrimario,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Nombre
            TextField(
              controller: _nombre,
              decoration: InputDecoration(
                hintText: 'nombre....',
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
              ),
            ),
            const SizedBox(height: 12),

            // Estado
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: const BoxDecoration(
                      color: Colors.amber,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Pendiente',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Detalles de la actividad',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                  ),
                  const SizedBox(height: 14),

                  // Horario
                  Row(
                    children: [
                      const Icon(
                        Icons.access_time_rounded,
                        size: 18,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _SelectorHora(
                          valor: _horaInicio,
                          horas: _horas,
                          onCambio: (v) => setState(() => _horaInicio = v),
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8),
                        child: Text('a', style: TextStyle(color: Colors.grey)),
                      ),
                      Expanded(
                        child: _SelectorHora(
                          valor: _horaFin,
                          horas: _horas,
                          onCambio: (v) => setState(() => _horaFin = v),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Punto de reunión
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_rounded,
                        size: 18,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey.shade300),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: DropdownButton<String>(
                            value: _puntoSeleccionado,
                            hint: const Text(
                              'seleccionar',
                              style: TextStyle(fontSize: 12),
                            ),
                            isExpanded: true,
                            underline: const SizedBox(),
                            items:
                                _puntos
                                    .map(
                                      (p) => DropdownMenuItem(
                                        value: p,
                                        child: Text(
                                          p,
                                          style: const TextStyle(fontSize: 12),
                                        ),
                                      ),
                                    )
                                    .toList(),
                            onChanged:
                                (v) => setState(() => _puntoSeleccionado = v),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Descripción
                  const Text(
                    'descripcion',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _descripcion,
                    maxLines: 3,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color(0xFFF5F7FF),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey.shade200),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey.shade200),
                      ),
                      contentPadding: const EdgeInsets.all(10),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Botones
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: _azulSecundario,
                      side: const BorderSide(color: _azulSecundario),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text(
                      'cancelar',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _guardar,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2E7D32),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: Text(
                      widget.esNueva ? 'crear' : 'realizar cambios',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
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
}

// ── Helpers ───────────────────────────────────────────────────────────────────

class _SelectorHora extends StatelessWidget {
  final String valor;
  final List<String> horas;
  final ValueChanged<String> onCambio;
  const _SelectorHora({
    required this.valor,
    required this.horas,
    required this.onCambio,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButton<String>(
        value: valor,
        isExpanded: true,
        underline: const SizedBox(),
        style: const TextStyle(fontSize: 12, color: Color(0xFF1A1A2E)),
        items:
            horas
                .map((h) => DropdownMenuItem(value: h, child: Text(h)))
                .toList(),
        onChanged: (v) {
          if (v != null) onCambio(v);
        },
      ),
    );
  }
}

class _FiltroChip extends StatelessWidget {
  final String label;
  final bool sel;
  final VoidCallback onTap;
  final Color color;
  const _FiltroChip({
    required this.label,
    required this.sel,
    required this.onTap,
    this.color = Colors.grey,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: sel ? color : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: sel ? Colors.white : Colors.grey.shade600,
          ),
        ),
      ),
    );
  }
}
