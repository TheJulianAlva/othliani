import 'package:flutter/material.dart';
import 'package:frontend/features/agencia/trips/domain/entities/actividad_itinerario.dart';

class ActivityEditDialog extends StatefulWidget {
  final ActividadItinerario actividad;
  final Function(ActividadItinerario) onSave;
  final Function(String) onDelete;

  const ActivityEditDialog({
    super.key,
    required this.actividad,
    required this.onSave,
    required this.onDelete,
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

  @override
  void initState() {
    super.initState();
    _tituloCtrl = TextEditingController(text: widget.actividad.titulo);
    _descCtrl = TextEditingController(text: widget.actividad.descripcion);
    _recomendacionesCtrl = TextEditingController(
      text: widget.actividad.recomendaciones,
    );
    _horaInicio = widget.actividad.horaInicio;
    _horaFin = widget.actividad.horaFin;
  }

  @override
  void dispose() {
    _tituloCtrl.dispose();
    _descCtrl.dispose();
    _recomendacionesCtrl.dispose();
    super.dispose();
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
          const Text(
            "Editar Actividad",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
              TextField(
                controller: _tituloCtrl,
                decoration: InputDecoration(
                  labelText: "Título de la actividad",
                  prefixIcon: const Icon(Icons.title),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
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
                      onChanged: (t) => setState(() => _horaInicio = t),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildTimePicker(
                      label: "Fin",
                      time: _horaFin,
                      icon: Icons.stop_circle_outlined,
                      onChanged: (t) => setState(() => _horaFin = t),
                    ),
                  ),
                ],
              ),

              // Duración calculada en tiempo real
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Builder(
                  builder: (_) {
                    final diff = _horaFin.difference(_horaInicio).inMinutes;
                    final valido = diff > 0;
                    return Row(
                      children: [
                        Icon(
                          valido ? Icons.timer_outlined : Icons.warning_amber,
                          size: 14,
                          color: valido ? Colors.grey[500] : Colors.orange,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          valido
                              ? "Duración: ${diff ~/ 60}h ${diff % 60}m"
                              : "⚠ La hora de fin debe ser posterior al inicio",
                          style: TextStyle(
                            fontSize: 12,
                            color: valido ? Colors.grey[500] : Colors.orange,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(height: 8),

              // --- DESCRIPCIÓN ---
              TextField(
                controller: _descCtrl,
                maxLines: 3,
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
                ),
              ),
              const SizedBox(height: 16),

              // --- RECOMENDACIONES ---
              TextField(
                controller: _recomendacionesCtrl,
                maxLines: 2,
                decoration: InputDecoration(
                  labelText: "Recomendaciones (ej: Llevar botas)",
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
                  // TODO Fase 5: Abrir selector de mapa
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
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
      actions: [
        // BOTÓN ELIMINAR
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
                          Navigator.pop(ctx); // Cierra confirmación
                          widget.onDelete(widget.actividad.id);
                          Navigator.pop(context); // Cierra el dialog principal
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
        const Spacer(),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text("Cancelar"),
        ),
        const SizedBox(width: 4),
        // BOTÓN GUARDAR
        ElevatedButton.icon(
          onPressed: _guardarCambios,
          icon: const Icon(Icons.check),
          label: const Text("Guardar"),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue[800],
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
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
    // Validar que horaFin > horaInicio
    if (!_horaFin.isAfter(_horaInicio)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            "La hora de fin debe ser posterior a la hora de inicio",
          ),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final actividadActualizada = ActividadItinerario(
      id: widget.actividad.id,
      tipo: widget.actividad.tipo,
      titulo:
          _tituloCtrl.text.trim().isEmpty
              ? widget.actividad.titulo
              : _tituloCtrl.text.trim(),
      descripcion: _descCtrl.text.trim(),
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
