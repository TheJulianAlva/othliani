import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/features/agencia/trips/domain/entities/actividad_itinerario.dart';
import 'package:frontend/features/agencia/trips/presentation/blocs/itinerary_builder/itinerary_builder_cubit.dart';
import 'package:latlong2/latlong.dart';
import 'location_picker_modal.dart'; // ✨ FASE 5: Selector de ubicación

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

  // ✨ FASE 5: Imagen seleccionada de Pexels
  String? _selectedImage;
  // ✨ Carrusel de fotos
  final PageController _fotoPageCtrl = PageController(viewportFraction: 0.38);
  int _fotoPaginaActual = 0;

  // Errores de validación
  String? _errorTitulo;
  String? _errorHoras;

  // ✨ FASE 5: Ubicación seleccionada en el mapa
  LatLng? _ubicacion;

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
    // ✨ FASE 5: Inicializar imagen y ubicación desde la actividad
    _selectedImage = widget.actividad.imagenUrl;
    _ubicacion = widget.actividad.ubicacionCentral;

    // ✨ FASE 5: Escuchar cambios en título para buscar fotos (Pexels)
    _tituloCtrl.addListener(() {
      // Solo buscar si el cubit está disponible
      try {
        context.read<ItineraryBuilderCubit>().onTituloChanged(_tituloCtrl.text);
      } catch (_) {}
    });
  }

  bool _esTituloDefault(String titulo) {
    // Título vacío → siempre placeholder
    if (titulo.trim().isEmpty) return true;

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
    _fotoPageCtrl.dispose(); // ✨ FASE 5
    super.dispose();
  }

  // ¿El formulario está listo para guardar?
  bool get _puedeGuardar {
    final tituloValido =
        !_tituloEsPlaceholder && _tituloCtrl.text.trim().isNotEmpty;
    final descValida = !_descEsPlaceholder && _descCtrl.text.trim().isNotEmpty;

    // En modo creación (isNew), no se validan horas ni ubicación obligatoria
    if (widget.isNew) {
      return tituloValido && descValida;
    }

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
        finValido &&
        _ubicacion != null; // 📍 Ubicación obligatoria
  }

  @override
  Widget build(BuildContext context) {
    final colorTipo = _getColorForType(widget.actividad.tipo);

    // ✨ FASE 5: Escuchar el estado del cubit para mostrar fotos sugeridas
    return BlocBuilder<ItineraryBuilderCubit, ItineraryBuilderState>(
      builder: (context, itineraryState) {
        final fotos = itineraryState.imagenesSugeridas;

        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
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
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
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
                  // ✨ FASE 5: Banner de imagen seleccionada
                  if (_selectedImage != null) ...[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Stack(
                        children: [
                          // Imagen de fondo
                          SizedBox(
                            height: 130,
                            width: double.infinity,
                            child: Image.network(
                              _selectedImage!,
                              fit: BoxFit.cover,
                            ),
                          ),
                          // Gradiente inferior para texto legible
                          Positioned(
                            bottom: 0,
                            left: 0,
                            right: 0,
                            height: 50,
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.bottomCenter,
                                  end: Alignment.topCenter,
                                  colors: [
                                    Colors.black.withValues(alpha: 0.55),
                                    Colors.transparent,
                                  ],
                                ),
                              ),
                            ),
                          ),
                          // Botón × para quitar la imagen
                          Positioned(
                            top: 6,
                            right: 6,
                            child: GestureDetector(
                              onTap:
                                  () => setState(() => _selectedImage = null),
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.55),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.close,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              ),
                            ),
                          ),
                          // Chip "Foto Pexels" en esquina inferior izquierda
                          Positioned(
                            bottom: 8,
                            left: 10,
                            child: Row(
                              children: [
                                Icon(
                                  Icons.auto_awesome,
                                  color: Colors.white.withValues(alpha: 0.9),
                                  size: 12,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Foto Pexels seleccionada',
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.9),
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                  ] else
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
                  const SizedBox(height: 12),

                  // ✨ FASE 5: CARRUSEL DE FOTOS SUGERIDAS (Pexels)
                  if (fotos.isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.auto_awesome,
                              size: 14,
                              color: Colors.blue[700],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Fotos sugeridas (Pexels)',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.blue[700],
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const Spacer(),
                            // Flechas de navegación
                            IconButton(
                              icon: const Icon(Icons.chevron_left, size: 20),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(
                                minWidth: 28,
                                minHeight: 28,
                              ),
                              onPressed:
                                  _fotoPaginaActual > 0
                                      ? () {
                                        _fotoPageCtrl.previousPage(
                                          duration: const Duration(
                                            milliseconds: 300,
                                          ),
                                          curve: Curves.easeInOut,
                                        );
                                      }
                                      : null,
                            ),
                            Text(
                              '${_fotoPaginaActual + 1}/${fotos.length}',
                              style: const TextStyle(
                                fontSize: 11,
                                color: Colors.grey,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.chevron_right, size: 20),
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(
                                minWidth: 28,
                                minHeight: 28,
                              ),
                              onPressed:
                                  _fotoPaginaActual < fotos.length - 1
                                      ? () {
                                        _fotoPageCtrl.nextPage(
                                          duration: const Duration(
                                            milliseconds: 300,
                                          ),
                                          curve: Curves.easeInOut,
                                        );
                                      }
                                      : null,
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        SizedBox(
                          height: 90,
                          child: PageView.builder(
                            controller: _fotoPageCtrl,
                            itemCount: fotos.length,
                            physics: const BouncingScrollPhysics(),
                            onPageChanged:
                                (i) => setState(() => _fotoPaginaActual = i),
                            itemBuilder: (ctx, i) {
                              final url = fotos[i];
                              final isSelected = _selectedImage == url;
                              return GestureDetector(
                                onTap:
                                    () => setState(() => _selectedImage = url),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  margin: EdgeInsets.symmetric(
                                    horizontal: 4,
                                    vertical: isSelected ? 0 : 6,
                                  ),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    border:
                                        isSelected
                                            ? Border.all(
                                              color: Colors.blue[700]!,
                                              width: 2.5,
                                            )
                                            : Border.all(
                                              color: Colors.transparent,
                                              width: 2.5,
                                            ),
                                    boxShadow:
                                        isSelected
                                            ? [
                                              BoxShadow(
                                                color: Colors.blue.withValues(
                                                  alpha: 0.4,
                                                ),
                                                blurRadius: 8,
                                              ),
                                            ]
                                            : [],
                                    image: DecorationImage(
                                      image: NetworkImage(url),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  child:
                                      isSelected
                                          ? Container(
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              color: Colors.blue.withValues(
                                                alpha: 0.25,
                                              ),
                                            ),
                                            child: const Center(
                                              child: Icon(
                                                Icons.check_circle,
                                                color: Colors.white,
                                                size: 32,
                                              ),
                                            ),
                                          )
                                          : null,
                                ),
                              );
                            },
                          ),
                        ),
                        // Dots indicadores
                        const SizedBox(height: 6),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(fotos.length, (i) {
                            return AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              margin: const EdgeInsets.symmetric(horizontal: 2),
                              width: _fotoPaginaActual == i ? 12 : 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color:
                                    _fotoPaginaActual == i
                                        ? Colors.blue[700]
                                        : Colors.grey[300],
                                borderRadius: BorderRadius.circular(3),
                              ),
                            );
                          }),
                        ),
                        const SizedBox(height: 4),
                      ],
                    ),

                  const SizedBox(height: 4),

                  // --- HORARIOS (solo visible en modo EDICIÓN, no al crear) ---
                  if (!widget.isNew) ...[
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
                          final diff =
                              _horaFin.difference(_horaInicio).inMinutes;
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
                            mensaje =
                                "⚠ La hora de fin debe ser posterior al inicio";
                          } else if (!inicioValido) {
                            final h = widget.minTime!.hour;
                            final m = widget.minTime!.minute.toString().padLeft(
                              2,
                              '0',
                            );
                            final p = h >= 12 ? 'PM' : 'AM';
                            final h12 = h == 0 ? 12 : (h > 12 ? h - 12 : h);
                            mensaje =
                                "⚠ No puede iniciar antes de las $h12:$m $p";
                          } else if (!finValido) {
                            final h = widget.maxTime!.hour;
                            final m = widget.maxTime!.minute.toString().padLeft(
                              2,
                              '0',
                            );
                            final p = h >= 12 ? 'PM' : 'AM';
                            final h12 = h == 0 ? 12 : (h > 12 ? h - 12 : h);
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
                                esError
                                    ? Icons.error_outline
                                    : Icons.timer_outlined,
                                size: 14,
                                color:
                                    esError ? Colors.orange : Colors.grey[500],
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  mensaje,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color:
                                        esError
                                            ? Colors.orange
                                            : Colors.grey[500],
                                  ),
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 8),
                  ] else ...[
                    // Mensaje indicativo en modo creación
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            size: 14,
                            color: Colors.blue[400],
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              "⏰ Podrás ajustar los horarios con el ✏️ al editar la actividad.",
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.blue[400],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],

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

                  // ✨ FASE 5: BOTÓN DE UBICACIÓN REAL
                  OutlinedButton.icon(
                    onPressed: _pickLocation,
                    icon: Icon(
                      _ubicacion != null
                          ? Icons.location_on
                          : Icons.add_location_alt_outlined,
                      color: _ubicacion != null ? Colors.green : Colors.grey,
                    ),
                    label: Text(
                      _ubicacion != null
                          ? 'Ubicación guardada (✅ ${_ubicacion!.latitude.toStringAsFixed(4)}, ${_ubicacion!.longitude.toStringAsFixed(4)})'
                          : 'Agregar Ubicación en Mapa',
                      style: TextStyle(
                        color:
                            _ubicacion != null
                                ? Colors.green[700]
                                : Colors.grey[700],
                        fontSize: 13,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(44),
                      side: BorderSide(
                        color:
                            _ubicacion != null
                                ? Colors.green
                                : Colors.grey.shade300,
                      ),
                      backgroundColor:
                          _ubicacion != null ? Colors.green[50] : null,
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
                          !_descEsPlaceholder &&
                          _descCtrl.text.trim().isNotEmpty;
                      final textosOk = tituloOk && descOk;

                      final ubicacionOk = _ubicacion != null;

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
                                border: Border.all(
                                  color: Colors.amber.shade200,
                                ),
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

                      // Textos ok pero falta ubicación
                      if (!ubicacionOk) {
                        return Column(
                          children: [
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.orange.shade50,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: Colors.orange.shade200,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.location_off_outlined,
                                    size: 16,
                                    color: Colors.orange.shade700,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      "¿Dónde se realizará? Agrega la ubicación en el mapa",
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.orange.shade800,
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
                label: const Text(
                  "Eliminar",
                  style: TextStyle(color: Colors.red),
                ),
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
      }, // cierre builder del BlocBuilder
    ); // cierre BlocBuilder
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
          DateTime newDt = DateTime(
            time.year,
            time.month,
            time.day,
            picked.hour,
            picked.minute,
          );

          // ✨ FIX: Corrección para actividades nocturnas (Horas Extra)
          // Si estamos editando la HORA FIN y la hora seleccionada es menor que la de inicio,
          // asumimos que es el día siguiente.
          if (label == "Fin") {
            // Si la nueva fecha (mismo día) es anterior al inicio...
            if (newDt.isBefore(_horaInicio) ||
                newDt.isAtSameMomentAs(_horaInicio)) {
              // ...probamos sumando un día
              final newDtNextDay = newDt.add(const Duration(days: 1));

              // Verificamos si este "siguiente día" es válido respecto al maxTime
              if (widget.maxTime != null) {
                if (newDtNextDay.isBefore(widget.maxTime!) ||
                    newDtNextDay.isAtSameMomentAs(widget.maxTime!)) {
                  newDt = newDtNextDay;
                }
              } else {
                // Si no hay límite estricto, permitimos el cambio de día
                newDt = newDtNextDay;
              }
            } else {
              // Si seleccionó una hora POSTERIOR en el mismo día (ej. 23:00 -> 23:30),
              // nos aseguramos de que no tenga un día extra acumulado por error previo
              // (Volvemos al día base del inicio si es posible)
              if (newDt.difference(_horaInicio).inHours > 24) {
                newDt = newDt.subtract(const Duration(days: 1));
              }

              // Caso especial: Si ya teníamos un día extra (es decir time.day > _horaInicio.day)
              // y el usuario selecciona una hora que "cabe" en el día siguiente (madrugada),
              // mantenemos el día siguiente. Pero si selecciona una hora "tarde" (ej. 23:00),
              // quizás quería volver al día original.
              // SOLUCIÓN SIMPLE: Siempre reconstruir basándonos en _horaInicio.

              // Mejor enfoque: Reconstruir newDt usando el día de _horaInicio predeterminado.
              // Y solo sumar día si es necesario.
              final baseSameDay = DateTime(
                _horaInicio.year,
                _horaInicio.month,
                _horaInicio.day,
                picked.hour,
                picked.minute,
              );

              if (baseSameDay.isBefore(_horaInicio) ||
                  baseSameDay.isAtSameMomentAs(_horaInicio)) {
                // Es madrugada del día siguiente
                newDt = baseSameDay.add(const Duration(days: 1));
              } else {
                // Es tarde del mismo día
                newDt = baseSameDay;
              }
            }
          }

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

    // Validar horas (solo en modo edición, no al crear por primera vez)
    if (!widget.isNew) {
      if (!_horaFin.isAfter(_horaInicio)) {
        setState(
          () => _errorHoras = "La hora de fin debe ser posterior al inicio",
        );
        return;
      }

      // Validar solapamiento con otras actividades del día (solo en modo edición)
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

      // ✨ FASE 5: Validar que la ubicación haya sido seleccionada (REQUERIDO en edición)
      if (_ubicacion == null) {
        showDialog(
          context: context,
          builder:
              (ctx) => AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                title: Row(
                  children: [
                    Icon(Icons.location_off_rounded, color: Colors.orange[800]),
                    const SizedBox(width: 10),
                    const Text("Ubicación Requerida"),
                  ],
                ),
                content: const Text(
                  "Es obligatorio seleccionar una ubicación en el mapa para guardar esta actividad.\n\nPor favor, asigna una ubicación geográfica.",
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text("Cancelar"),
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(ctx); // Cierra la alerta
                      _pickLocation(); // Abre el selector de mapa
                    },
                    icon: const Icon(Icons.add_location_alt_outlined),
                    label: const Text("Seleccionar ahora"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[800],
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
        );
        setState(() {
          // Podríamos agregar un estado de error visual al botón si fuera necesario
        });
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
      ubicacionCentral: _ubicacion, // ✨ FASE 5: ubicación real del mapa
      radioGeocerca: widget.actividad.radioGeocerca,
      poligonoGeocerca: widget.actividad.poligonoGeocerca,
      urlFotoPuntoReunion: widget.actividad.urlFotoPuntoReunion,
      huellaCarbono: widget.actividad.huellaCarbono,
      guiaResponsableId: widget.actividad.guiaResponsableId,
      imagenUrl: _selectedImage, // ✨ FASE 5: guardar foto seleccionada
    );

    widget.onSave(actividadActualizada);
    // ✨ FASE 5: Limpiar sugerencias al salir del diálogo
    try {
      context.read<ItineraryBuilderCubit>().clearSuggestions();
    } catch (_) {}
    Navigator.pop(context);
  }

  /// ✨ FASE 5: Abre el mapa y devuelve la ubicación seleccionada
  Future<void> _pickLocation() async {
    final LatLng? result = await showModalBottomSheet<LatLng>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (ctx) => SizedBox(
            height: MediaQuery.of(context).size.height * 0.92,
            child: LocationPickerModal(initialLocation: _ubicacion),
          ),
    );

    if (result != null && mounted) {
      setState(() => _ubicacion = result);
    }
  }

  IconData _getIconForType(TipoActividad tipo) {
    switch (tipo) {
      case TipoActividad.hospedaje:
        return Icons.hotel_rounded;
      case TipoActividad.comida:
        return Icons.restaurant_rounded;
      case TipoActividad.traslado:
        return Icons.directions_bus_rounded;
      case TipoActividad.visitaGuiada:
      case TipoActividad.cultura:
        return Icons.museum_rounded;
      case TipoActividad.checkIn:
        return Icons.location_on_rounded;
      case TipoActividad.aventura:
        return Icons.hiking_rounded;
      case TipoActividad.tiempoLibre:
        return Icons.beach_access_rounded;
      case TipoActividad.otro:
        return Icons.extension_rounded; // Categoría personalizada
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
      case TipoActividad.visitaGuiada:
      case TipoActividad.cultura:
        return Colors.brown;
      case TipoActividad.checkIn:
        return Colors.green;
      case TipoActividad.aventura:
        return Colors.green;
      case TipoActividad.tiempoLibre:
        return Colors.teal;
      case TipoActividad.otro:
        return Colors.deepPurple; // Categoría personalizada
    }
  }
}
