import 'package:flutter/material.dart';
import 'package:frontend/features/agencia/trips/domain/entities/actividad_itinerario.dart';

class ActivityEditDialog extends StatefulWidget {
  final ActividadItinerario actividad;
  final Function(ActividadItinerario) onSave;
  final Function(String) onDelete;

  /// Si es true, cancelar elimina la actividad (recién creada, sin guardar aún)
  final bool isNew;

  /// Lista de actividades del día para validar solapamiento y nombres únicos
  final List<ActividadItinerario> actividadesDelDia;

  /// Hora mínima permitida para el inicio (ej. hora de inicio del día)
  final DateTime? minTime;

  /// Hora máxima permitida para el fin (ej. hora fin del día o límite con horas extra)
  final DateTime? maxTime;

  const ActivityEditDialog({
    super.key,
    required this.actividad,
    required this.onSave,
    required this.onDelete,
    this.isNew = false,
    this.actividadesDelDia = const [],
    this.minTime,
    this.maxTime,
  });

  @override
  State<ActivityEditDialog> createState() => _ActivityEditDialogState();
}

class _ActivityEditDialogState extends State<ActivityEditDialog> {
  late TextEditingController _tituloCtrl;
  late TextEditingController _descCtrl;
  late TextEditingController _recomendacionesCtrl;
  late DateTime _horaInicio;
  late DateTime _horaFin;

  // Textos por defecto (placeholder)
  static const String _tituloDefault = "Nombre de la actividad";
  static const String _descDefault = "Describe la actividad para el turista...";

  bool _tituloEsPlaceholder = false;
  bool _descEsPlaceholder = false;

  // Errores de validación
  String? _errorTitulo;
  String? _errorHoras;

  @override
  void initState() {
    super.initState();

    // Si el título es el default del cubit, tratarlo como placeholder
    final tituloInicial = widget.actividad.titulo;
    _tituloEsPlaceholder = _esTituloDefault(tituloInicial);
    _tituloCtrl = TextEditingController(
      text: _tituloEsPlaceholder ? _tituloDefault : tituloInicial,
    );

    // Si la descripción es el default del cubit, tratarla como placeholder
    final descInicial = widget.actividad.descripcion;
    _descEsPlaceholder = _esDescDefault(descInicial);
    _descCtrl = TextEditingController(
      text: _descEsPlaceholder ? _descDefault : descInicial,
    );

    _recomendacionesCtrl = TextEditingController(
      text: widget.actividad.recomendaciones,
    );
    _horaInicio = widget.actividad.horaInicio;
    _horaFin = widget.actividad.horaFin;
  }

  bool _esTituloDefault(String titulo) {
    const defaults = [
      "Check-in Hotel",
      "Alimentos",
      "Traslado",
      "Visita Cultural",
      "Actividad Aventura",
      "Tiempo Libre",
      "Nueva Actividad",
    ];
    return defaults.contains(titulo);
  }

  bool _esDescDefault(String desc) {
    return desc == "Toca para editar detalles" || desc.isEmpty;
  }

  @override
  void dispose() {
    _tituloCtrl.dispose();
    _descCtrl.dispose();
    _recomendacionesCtrl.dispose();
    super.dispose();
  }

  // ¿El formulario está listo para guardar?
  bool get _puedeGuardar {
    final tituloValido =
        !_tituloEsPlaceholder && _tituloCtrl.text.trim().isNotEmpty;
    final descValida = !_descEsPlaceholder && _descCtrl.text.trim().isNotEmpty;
    final horasValidas = _horaFin.isAfter(_horaInicio);

    // Validar minTime (solo chequear horas/minutos para evitar problemas de fecha base)
    bool inicioValido = true;
    if (widget.minTime != null) {
      final min = widget.minTime!;
      if (_horaInicio.isBefore(min)) {
        inicioValido = false;
      }
    }

    // Validar maxTime
    bool finValido = true;
    if (widget.maxTime != null) {
      final max = widget.maxTime!;
      if (_horaFin.isAfter(max)) {
        finValido = false;
      }
    }

    return tituloValido &&
        descValida &&
        horasValidas &&
        inicioValido &&
        finValido;
  }

  @override
  Widget build(BuildContext context) {
    final colorTipo = _getColorForType(widget.actividad.tipo);

    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      contentPadding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      title: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: colorTipo.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              _getIconForType(widget.actividad.tipo),
              color: colorTipo,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            widget.isNew ? "Nueva Actividad" : "Editar Actividad",
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
      content: SizedBox(
        width: 480,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),

              // --- TÍTULO ---
              GestureDetector(
                onTap: () {
                  if (_tituloEsPlaceholder) {
                    setState(() {
                      _tituloEsPlaceholder = false;
                      _tituloCtrl.clear();
                    });
                  }
                },
                child: TextField(
                  controller: _tituloCtrl,
                  onChanged: (_) => setState(() => _errorTitulo = null),
                  style: TextStyle(
                    color: _tituloEsPlaceholder ? Colors.grey[400] : null,
                    fontStyle:
                        _tituloEsPlaceholder
                            ? FontStyle.italic
                            : FontStyle.normal,
                  ),
                  decoration: InputDecoration(
                    labelText: "Título de la actividad",
                    errorText: _errorTitulo,
                    prefixIcon: const Icon(Icons.title),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    helperText:
                        _tituloEsPlaceholder ? "Toca para escribir" : null,
                    helperStyle: TextStyle(
                      color: Colors.blue[400],
                      fontSize: 11,
                    ),
                  ),
                  onTap: () {
                    if (_tituloEsPlaceholder) {
                      setState(() {
                        _tituloEsPlaceholder = false;
                        _tituloCtrl.clear();
                      });
                    }
                  },
                ),
              ),
              const SizedBox(height: 16),

              // --- HORARIOS ---
              Row(
                children: [
                  Expanded(
                    child: _buildTimePicker(
                      label: "Inicio",
                      time: _horaInicio,
                      icon: Icons.play_circle_outline,
                      onChanged:
                          (t) => setState(() {
                            _horaInicio = t;
                            _errorHoras = null;
                          }),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildTimePicker(
                      label: "Fin",
                      time: _horaFin,
                      icon: Icons.stop_circle_outlined,
                      onChanged:
                          (t) => setState(() {
                            _horaFin = t;
                            _errorHoras = null;
                          }),
                    ),
                  ),
                ],
              ),

              // Duración calculada + error de horas
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Builder(
                  builder: (_) {
                    final diff = _horaFin.difference(_horaInicio).inMinutes;
                    final valido = diff > 0;

                    // Validar minTime
                    bool inicioValido = true;
                    if (widget.minTime != null &&
                        _horaInicio.isBefore(widget.minTime!)) {
                      inicioValido = false;
                    }

                    // Validar maxTime
                    bool finValido = true;
                    if (widget.maxTime != null &&
                        _horaFin.isAfter(widget.maxTime!)) {
                      finValido = false;
                    }

                    String mensaje;
                    if (_errorHoras != null) {
                      mensaje = _errorHoras!;
                    } else if (!valido) {
                      mensaje = "⚠ La hora de fin debe ser posterior al inicio";
                    } else if (!inicioValido) {
                      final h = widget.minTime!.hour;
                      final m = widget.minTime!.minute.toString().padLeft(
                        2,
                        '0',
                      );
                      final p = h >= 12 ? 'PM' : 'AM';
                      final h12 = h == 0 ? 12 : (h > 12 ? h - 12 : h);
                      mensaje = "⚠ No puede iniciar antes de las $h12:$m $p";
                    } else if (!finValido) {
                      final h = widget.maxTime!.hour;
                      final m = widget.maxTime!.minute.toString().padLeft(
                        2,
                        '0',
                      );
                      final p = h >= 12 ? 'PM' : 'AM';
                      final h12 = h == 0 ? 12 : (h > 12 ? h - 12 : h);
                      // ✨ Mensaje más educativo: Explicar que el límite depende del horario del día
                      mensaje =
                          "⚠ Límite del día + extra: $h12:$m $p. Ajusta la Hora Fin del Día para extender.";
                    } else {
                      mensaje = "Duración: ${diff ~/ 60}h ${diff % 60}m";
                    }

                    final esError =
                        _errorHoras != null ||
                        !valido ||
                        !inicioValido ||
                        !finValido;

                    return Row(
                      children: [
                        Icon(
                          esError ? Icons.error_outline : Icons.timer_outlined,
                          size: 14,
                          color: esError ? Colors.orange : Colors.grey[500],
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            mensaje,
                            style: TextStyle(
                              fontSize: 12,
                              color: esError ? Colors.orange : Colors.grey[500],
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(height: 8),

              // --- DESCRIPCIÓN ---
              GestureDetector(
                onTap: () {
                  if (_descEsPlaceholder) {
                    setState(() {
                      _descEsPlaceholder = false;
                      _descCtrl.clear();
                    });
                  }
                },
                child: TextField(
                  controller: _descCtrl,
                  maxLines: 3,
                  onChanged: (_) => setState(() {}),
                  style: TextStyle(
                    color: _descEsPlaceholder ? Colors.grey[400] : null,
                    fontStyle:
                        _descEsPlaceholder
                            ? FontStyle.italic
                            : FontStyle.normal,
                  ),
                  decoration: InputDecoration(
                    labelText: "Descripción para el turista",
                    alignLabelWithHint: true,
                    prefixIcon: const Padding(
                      padding: EdgeInsets.only(bottom: 48),
                      child: Icon(Icons.description_outlined),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    helperText:
                        _descEsPlaceholder ? "Toca para escribir" : null,
                    helperStyle: TextStyle(
                      color: Colors.blue[400],
                      fontSize: 11,
                    ),
                  ),
                  onTap: () {
                    if (_descEsPlaceholder) {
                      setState(() {
                        _descEsPlaceholder = false;
                        _descCtrl.clear();
                      });
                    }
                  },
                ),
              ),
              const SizedBox(height: 16),

              // --- RECOMENDACIONES (opcional) ---
              TextField(
                controller: _recomendacionesCtrl,
                maxLines: 2,
                decoration: InputDecoration(
                  labelText: "Recomendaciones (opcional)",
                  hintText: "Ej: Llevar botas, protector solar...",
                  alignLabelWithHint: true,
                  prefixIcon: const Padding(
                    padding: EdgeInsets.only(bottom: 24),
                    child: Icon(Icons.tips_and_updates_outlined),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // --- PLACEHOLDER: UBICACIÓN ---
              OutlinedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Selector de mapa próximamente (Fase 5)"),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
                icon: const Icon(Icons.map_outlined),
                label: const Text("Seleccionar Ubicación en Mapa"),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(44),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),

              // Indicador de validación dinámico
              Builder(
                builder: (context) {
                  final tituloOk =
                      !_tituloEsPlaceholder &&
                      _tituloCtrl.text.trim().isNotEmpty;
                  final descOk =
                      !_descEsPlaceholder && _descCtrl.text.trim().isNotEmpty;
                  final textosOk = tituloOk && descOk;

                  if (!textosOk) {
                    return Column(
                      children: [
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.amber.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.amber.shade200),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.info_outline,
                                size: 16,
                                color: Colors.amber.shade700,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  "Completa el título y la descripción para guardar",
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.amber.shade800,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  }

                  // Si textos ok pero no puede guardar, es error de hora
                  if (!_puedeGuardar) {
                    return Column(
                      children: [
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.red.shade200),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.access_time_filled,
                                size: 16,
                                color: Colors.red.shade700,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  "Horario inválido. Revisa las horas marcadas.",
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.red.shade800,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  }

                  return const SizedBox.shrink();
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
      actionsAlignment: MainAxisAlignment.spaceBetween,
      actions: [
        // BOTÓN ELIMINAR (solo si no es nueva) — queda a la izquierda
        if (!widget.isNew)
          TextButton.icon(
            onPressed: () {
              showDialog(
                context: context,
                builder:
                    (ctx) => AlertDialog(
                      title: const Text("¿Eliminar actividad?"),
                      content: Text(
                        "Se eliminará \"${widget.actividad.titulo}\" del itinerario.",
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(ctx),
                          child: const Text("Cancelar"),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pop(ctx);
                            widget.onDelete(widget.actividad.id);
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text("Eliminar"),
                        ),
                      ],
                    ),
              );
            },
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            label: const Text("Eliminar", style: TextStyle(color: Colors.red)),
          ),
        // Cancelar y Guardar — quedan a la derecha
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextButton(
              onPressed: () {
                if (widget.isNew) {
                  widget.onDelete(widget.actividad.id);
                }
                Navigator.pop(context);
              },
              child: const Text("Cancelar"),
            ),
            const SizedBox(width: 4),
            ElevatedButton.icon(
              onPressed: _puedeGuardar ? _guardarCambios : null,
              icon: const Icon(Icons.check),
              label: const Text("Guardar"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[800],
                foregroundColor: Colors.white,
                disabledBackgroundColor: Colors.grey[300],
                disabledForegroundColor: Colors.grey[500],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTimePicker({
    required String label,
    required DateTime time,
    required IconData icon,
    required Function(DateTime) onChanged,
  }) {
    final h = time.hour;
    final m = time.minute.toString().padLeft(2, '0');
    final periodo = h >= 12 ? 'PM' : 'AM';
    final h12 = h == 0 ? 12 : (h > 12 ? h - 12 : h);

    return InkWell(
      onTap: () async {
        final picked = await showTimePicker(
          context: context,
          initialTime: TimeOfDay.fromDateTime(time),
          builder:
              (ctx, child) => MediaQuery(
                data: MediaQuery.of(ctx).copyWith(alwaysUse24HourFormat: false),
                child: child!,
              ),
        );
        if (picked != null) {
          final newDt = DateTime(
            time.year,
            time.month,
            time.day,
            picked.hour,
            picked.minute,
          );
          onChanged(newDt);
        }
      },
      borderRadius: BorderRadius.circular(10),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, size: 18),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
        child: Text(
          "$h12:$m $periodo",
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
      ),
    );
  }

  void _guardarCambios() {
    final titulo = _tituloCtrl.text.trim();
    final desc = _descCtrl.text.trim();

    // Validar título no vacío
    if (titulo.isEmpty || _tituloEsPlaceholder) {
      setState(() => _errorTitulo = "El título es obligatorio");
      return;
    }

    // Validar nombre único (excluyendo la actividad actual)
    final nombreDuplicado = widget.actividadesDelDia.any(
      (a) =>
          a.id != widget.actividad.id &&
          a.titulo.trim().toLowerCase() == titulo.toLowerCase(),
    );
    if (nombreDuplicado) {
      setState(() => _errorTitulo = "Ya existe una actividad con este nombre");
      return;
    }

    // Validar horas
    if (!_horaFin.isAfter(_horaInicio)) {
      setState(
        () => _errorHoras = "La hora de fin debe ser posterior al inicio",
      );
      return;
    }

    // Validar solapamiento con otras actividades del día
    for (final otra in widget.actividadesDelDia) {
      if (otra.id == widget.actividad.id) continue;
      final seSolapa =
          _horaInicio.isBefore(otra.horaFin) &&
          _horaFin.isAfter(otra.horaInicio);
      if (seSolapa) {
        final h1 = otra.horaInicio.hour;
        final m1 = otra.horaInicio.minute.toString().padLeft(2, '0');
        final p1 = h1 >= 12 ? 'PM' : 'AM';
        final h12a = h1 == 0 ? 12 : (h1 > 12 ? h1 - 12 : h1);
        final h2 = otra.horaFin.hour;
        final m2 = otra.horaFin.minute.toString().padLeft(2, '0');
        final p2 = h2 >= 12 ? 'PM' : 'AM';
        final h12b = h2 == 0 ? 12 : (h2 > 12 ? h2 - 12 : h2);
        setState(
          () =>
              _errorHoras =
                  "Se solapa con \"${otra.titulo}\" ($h12a:$m1 $p1 – $h12b:$m2 $p2)",
        );
        return;
      }
    }

    final actividadActualizada = ActividadItinerario(
      id: widget.actividad.id,
      tipo: widget.actividad.tipo,
      titulo: titulo,
      descripcion: desc,
      horaInicio: _horaInicio,
      horaFin: _horaFin,
      recomendaciones: _recomendacionesCtrl.text.trim(),
      holguraMinutos: widget.actividad.holguraMinutos,
      ubicacionCentral: widget.actividad.ubicacionCentral,
      radioGeocerca: widget.actividad.radioGeocerca,
      poligonoGeocerca: widget.actividad.poligonoGeocerca,
      urlFotoPuntoReunion: widget.actividad.urlFotoPuntoReunion,
      huellaCarbono: widget.actividad.huellaCarbono,
      guiaResponsableId: widget.actividad.guiaResponsableId,
    );

    widget.onSave(actividadActualizada);
    Navigator.pop(context);
  }

  IconData _getIconForType(TipoActividad tipo) {
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

  Color _getColorForType(TipoActividad tipo) {
    switch (tipo) {
      case TipoActividad.hospedaje:
        return Colors.purple;
      case TipoActividad.comida:
        return Colors.orange;
      case TipoActividad.traslado:
        return Colors.blue;
      case TipoActividad.cultura:
        return Colors.brown;
      case TipoActividad.aventura:
        return Colors.green;
      case TipoActividad.tiempoLibre:
        return Colors.teal;
      case TipoActividad.visitaGuiada:
        return Colors.indigo;
      case TipoActividad.checkIn:
        return Colors.cyan;
      default:
        return Colors.grey;
    }
  }
}
