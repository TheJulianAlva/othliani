import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_map/flutter_map.dart'; // <--- Importante
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:frontend/features/agencia/trips/blocs/trip_creation/trip_creation_cubit.dart';
import 'package:frontend/features/agencia/trips/domain/entities/actividad_itinerario.dart';
import 'package:frontend/core/navigation/routes_agencia.dart'; // Importar rutas
import 'package:frontend/core/di/service_locator.dart' as di; // Importar DI
import '../../widgets/trips/destino_field_widget.dart'; // <--- Validar ubicación

class TripCreationScreen extends StatelessWidget {
  const TripCreationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => di.sl<TripCreationCubit>(), // Usar DI
      child: Scaffold(
        appBar: AppBar(title: const Text("Nuevo Viaje Inteligente")),
        body: const _TripCreationForm(),
      ),
    );
  }
}

class _TripCreationForm extends StatelessWidget {
  const _TripCreationForm();

  // Token de Mapbox desde variables de entorno
  static String get _mapboxAccessToken =>
      dotenv.env['MAPBOX_ACCESS_TOKEN'] ?? '';

  String _generarUrlMapaEstatico(LatLng punto) {
    // Parámetros: Longitud, Latitud
    final lat = punto.latitude;
    final lon = punto.longitude;

    // API Styles v1 (Moderna) con Pin Simplificado (pin-s+ff0000)
    // Evita error 410 (v4 Gone) y 422 (Icono no encontrado en v1)
    return 'https://api.mapbox.com/styles/v1/mapbox/streets-v12/static/pin-s+ff0000($lon,$lat)/$lon,$lat,14/400x400?access_token=$_mapboxAccessToken';
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<TripCreationCubit>();

    return BlocBuilder<TripCreationCubit, TripCreationState>(
      builder: (context, state) {
        return Stepper(
          type: StepperType.horizontal,
          currentStep: state.currentStep,
          controlsBuilder: (context, details) {
            // PASO 1: Ocultar controles automáticos (ya están integrados en el Split View)
            if (state.currentStep == 0) {
              return const SizedBox.shrink();
            }
            // PASO 2 y 3: Controles estándar
            return Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: Row(
                children: [
                  ElevatedButton(
                    onPressed: details.onStepContinue,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[800],
                      foregroundColor: Colors.white,
                    ),
                    child: const Text("Continuar"),
                  ),
                  const SizedBox(width: 12),
                  TextButton(
                    onPressed: details.onStepCancel,
                    child: const Text("Atrás"),
                  ),
                ],
              ),
            );
          },
          onStepContinue: () {
            if (state.currentStep == 2) {
              cubit.saveTrip().then(
                // ignore: use_build_context_synchronously
                (_) => context.go(RoutesAgencia.viajes),
              ); // Guardar y salir
            } else {
              cubit.nextStep();
            }
          },
          onStepCancel: cubit.prevStep,
          steps: [
            // PASO 1: DATOS GENERALES
            Step(
              title: const Text("Datos"),
              content: _buildGeneralInfoStep(
                context,
                state,
                onContinue: cubit.nextStep,
                onCancel: cubit.prevStep,
              ),
              isActive: state.currentStep >= 0,
            ),

            // PASO 2: ITINERARIO (El corazón del sistema)
            Step(
              title: const Text("Itinerario"),
              content: _buildItineraryStep(context, state),
              isActive: state.currentStep >= 1,
            ),

            // PASO 3: RESUMEN Y SEGURIDAD
            Step(
              title: const Text("Revisión"),
              content: _buildReviewStep(state),
              isActive: state.currentStep >= 2,
            ),
          ],
        );
      },
    );
  }

  // --- PASO 1: DATOS GENERALES (VERSIÓN PRO SPLIT VIEW) ---
  Widget _buildGeneralInfoStep(
    BuildContext context,
    TripCreationState state, {
    VoidCallback? onContinue,
    VoidCallback? onCancel,
  }) {
    final cubit = context.read<TripCreationCubit>();

    return Container(
      // Altura fija o calculada para obligar a ocupar espacio en Desktop/Tablet
      height: MediaQuery.of(context).size.height * 0.7,
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --- COLUMNA IZQUIERDA: FORMULARIO (40%) ---
          Expanded(
            flex: 2,
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    // Scroll solo para el formulario
                    padding: const EdgeInsets.only(right: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Configuración Operativa",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 24),

                        // 1. NOMBRE DEL VIAJE (Sincronizado con Mapa)
                        DestinoFieldWidget(
                          initialValue: state.destino,
                          onChanged: (v) {
                            cubit.onDestinoChanged(v);
                            debugPrint("🟢 1. El Cubit recibió el texto: $v");
                          },
                          hasPhotos: state.fotosCandidatas.isNotEmpty,
                          decoration: _inputDecoration(
                            'Nombre del Viaje / Destino',
                            Icons.place,
                          ).copyWith(
                            suffixIcon:
                                state.fotosCandidatas.isNotEmpty
                                    ? const Icon(
                                      Icons.photo_library,
                                      color: Colors.green,
                                    )
                                    : null,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // 2. UBICACIÓN (Selector Intuitivo)
                        InkWell(
                          onTap: () => _showMapPicker(context),
                          borderRadius: BorderRadius.circular(12),
                          child: InputDecorator(
                            decoration: _inputDecoration(
                              'Ubicación / Punto de Encuentro',
                              Icons.pin_drop,
                            ).copyWith(
                              suffixIcon: const Icon(
                                Icons.map,
                                color: Colors.blue,
                              ),
                            ),
                            child: Text(
                              state.location != null
                                  ? "${state.location!.latitude.toStringAsFixed(4)}, ${state.location!.longitude.toStringAsFixed(4)}"
                                  : "Toca para abrir el mapa...",
                              style: TextStyle(
                                color:
                                    state.location != null
                                        ? Colors.black
                                        : Colors.grey[600],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // 3. SELECTOR DE GUÍA CON CO-GUÍAS
                        _buildGuiaSelector(context, state, cubit),
                        const SizedBox(height: 16),

                        // 4. SELECTOR DE FECHAS (Extraído)
                        _buildDateSelector(context, state, cubit),
                      ],
                    ),
                  ),
                ),
                // --- BOTONES DE ACCIÓN (Integrados aquí para estar cerca del form) ---
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: onCancel,
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text("Cancelar"),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: onContinue,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue[800],
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                        ),
                        child: const Text(
                          "Continuar",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // LÍNEA DIVISORIA VERTICAL
          VerticalDivider(width: 1, color: Colors.grey[300]),

          // --- COLUMNA DERECHA: GALERÍA VISUAL (60%) ---
          Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.only(left: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Portada del Viaje (App Turista)",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Selecciona la imagen que verán tus clientes:",
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 16),

                  // EL GRAN MOSAICO QUE LLENA EL ESPACIO
                  Expanded(
                    child:
                        (state.location == null &&
                                state.fotosCandidatas.isEmpty)
                            ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.image_search,
                                    size: 64,
                                    color: Colors.grey[300],
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    "Escribe un destino y selecciona ubicación\npara ver sugerencias visuales",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: Colors.grey[500]),
                                  ),
                                ],
                              ),
                            )
                            : GridView.builder(
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2, // 2 columnas de fotos
                                    crossAxisSpacing: 12,
                                    mainAxisSpacing: 12,
                                    childAspectRatio:
                                        1.3, // Fotos rectangulares
                                  ),
                              itemCount:
                                  (state.location != null ? 1 : 0) +
                                  state.fotosCandidatas.length,
                              itemBuilder: (context, index) {
                                final bool showMap = state.location != null;
                                final bool isMapItem = showMap && index == 0;
                                final int photoIndex =
                                    showMap ? index - 1 : index;

                                // OPCIÓN A: MAPA
                                if (isMapItem) {
                                  final url = _generarUrlMapaEstatico(
                                    state.location!,
                                  );
                                  return _buildSelectableCard(
                                    isSelected:
                                        state.fotoPortadaUrl?.contains(
                                          "mapbox",
                                        ) ??
                                        false,
                                    onTap: () => cubit.seleccionarFoto(url),
                                    child: Stack(
                                      fit: StackFit.expand,
                                      children: [
                                        Image.network(url, fit: BoxFit.cover),
                                        Container(color: Colors.black26),
                                        const Center(
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              Icon(
                                                Icons.map,
                                                color: Colors.white,
                                                size: 48,
                                              ),
                                              Text(
                                                "Usar Mapa",
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }

                                // OPCIÓN B: FOTOS
                                final url = state.fotosCandidatas[photoIndex];
                                return _buildSelectableCard(
                                  isSelected: state.fotoPortadaUrl == url,
                                  onTap: () => cubit.seleccionarFoto(url),
                                  child: Image.network(
                                    url,
                                    fit: BoxFit.cover,
                                    // 👇 AGREGA ESTO: Engañamos al servidor diciendo que somos un navegador
                                    headers: const {
                                      'User-Agent':
                                          'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36',
                                    },
                                    loadingBuilder:
                                        (_, child, loading) =>
                                            loading == null
                                                ? child
                                                : const Center(
                                                  child:
                                                      CircularProgressIndicator(),
                                                ),
                                    errorBuilder: (context, error, stackTrace) {
                                      debugPrint(
                                        "🚨 Error visualizando foto: $error",
                                      ); // Chismoso activado
                                      return const Center(
                                        child: Icon(
                                          Icons.broken_image,
                                          color: Colors.grey,
                                        ),
                                      );
                                    },
                                  ),
                                );
                              },
                            ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- ESTILOS MODERNOS ---
  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: Colors.blueGrey),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.blue[800]!, width: 2),
      ),
      filled: true,
      fillColor: Colors.grey[50],
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    );
  }

  // --- MODAL DE SELECCIÓN DE GUÍA ---
  void _showGuiaPicker(
    BuildContext context,
    TripCreationState state, {
    required bool isCoGuia,
  }) {
    final cubit = context.read<TripCreationCubit>();
    cubit.searchGuia(''); // Resetear búsqueda al abrir

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (ctx) => BlocProvider<TripCreationCubit>.value(
            value: cubit,
            child: BlocBuilder<TripCreationCubit, TripCreationState>(
              builder:
                  (context, currentState) => DraggableScrollableSheet(
                    initialChildSize: 0.7,
                    expand: false,
                    builder:
                        (_, scrollController) => Column(
                          children: [
                            // Cabecera del Modal
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                children: [
                                  Text(
                                    isCoGuia
                                        ? "Seleccionar Guía Auxiliar"
                                        : "Seleccionar Guía Principal",
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  TextField(
                                    decoration: InputDecoration(
                                      hintText: "Buscar guía por nombre...",
                                      prefixIcon: const Icon(Icons.search),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                      filled: true,
                                      fillColor: Colors.grey[100],
                                    ),
                                    onChanged:
                                        (v) => context
                                            .read<TripCreationCubit>()
                                            .searchGuia(v),
                                  ),
                                ],
                              ),
                            ),
                            const Divider(height: 1),
                            // Lista Filtrada y Ordenada
                            Expanded(
                              child: _buildGuideList(
                                context,
                                currentState,
                                scrollController,
                                isCoGuia,
                                cubit,
                              ),
                            ),
                          ],
                        ),
                  ),
            ),
          ),
    ).whenComplete(() => cubit.searchGuia('')); // Limpiar búsqueda al cerrar
  }

  // --- WIDGETS AUXILIARES ---
  Widget _buildGuideList(
    BuildContext context,
    TripCreationState state,
    ScrollController scrollController,
    bool isCoGuia,
    TripCreationCubit cubit,
  ) {
    // 1. Filtrar lista para excluir al guía principal si estamos seleccionando auxiliares
    final listaGuias =
        state.guiasFiltrados.where((g) {
          if (isCoGuia &&
              state.selectedGuiaId != null &&
              g['id'] == state.selectedGuiaId) {
            return false;
          }
          return true;
        }).toList();

    // 2. Empty State Real (Si la lista filtrada queda vacía)
    if (listaGuias.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.person_search, size: 64, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              "No se encontraron guías",
              style: TextStyle(
                color: Colors.grey[500],
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    // 3. Lista de Resultados
    return ListView.separated(
      controller: scrollController,
      itemCount: listaGuias.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (ctx, i) {
        final guia = listaGuias[i];
        final String statusLabel = guia['status'] as String;
        final bool disponible = statusLabel == 'Disponible';
        final bool isSelected = state.coGuiasIds.contains(guia['id']);

        // Colores e iconos según estado
        Color statusColor;
        IconData statusIcon;

        if (statusLabel == 'Disponible') {
          statusColor = Colors.green;
          statusIcon = Icons.check_circle;
        } else if (statusLabel == 'Ocupado en otro viaje') {
          statusColor = Colors.red;
          statusIcon = Icons.sensors;
        } else if (statusLabel == 'Tiene viaje programado') {
          statusColor = Colors.orange;
          statusIcon = Icons.event;
        } else {
          statusColor = Colors.grey;
          statusIcon = Icons.circle;
        }

        return ListTile(
          enabled: disponible,
          tileColor: isSelected ? Colors.teal[50] : null,
          leading: CircleAvatar(
            backgroundColor: disponible ? Colors.blue[100] : Colors.grey[300],
            child: Text(
              guia['name'][0],
              style: TextStyle(
                color: disponible ? Colors.blue[900] : Colors.grey,
              ),
            ),
          ),
          title: Text(
            guia['name'],
            style: TextStyle(
              color: disponible ? Colors.black : Colors.grey,
              decoration: disponible ? null : TextDecoration.lineThrough,
            ),
          ),
          subtitle: Row(
            children: [
              Icon(statusIcon, size: 14, color: statusColor),
              const SizedBox(width: 4),
              Text(
                statusLabel,
                style: TextStyle(
                  color: statusColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          trailing:
              disponible
                  ? (isCoGuia
                      ? (isSelected
                          ? const Icon(Icons.check_circle, color: Colors.teal)
                          : const Icon(Icons.add_circle_outline))
                      : (state.selectedGuiaId == guia['id']
                          ? const Icon(Icons.check_circle, color: Colors.blue)
                          : null))
                  : null,
          onTap: () {
            if (disponible) {
              if (isCoGuia) {
                cubit.toggleCoGuia(guia['id'] as String);
              } else {
                cubit.setGuia(guia['id'] as String);
                Navigator.pop(context);
              }
            }
          },
        );
      },
    );
  }

  // --- WIDGETS AUXILIARES ---
  Widget _buildDateField(
    BuildContext context,
    String label,
    DateTime? val,
    Function(DateTime) onPick, {
    DateTime? firstDate, // Parámetro opcional para fecha mínima
    bool disabled = false, // Parámetro para deshabilitar el campo
  }) {
    final minDate = firstDate ?? DateTime.now(); // Por defecto: hoy

    // VALIDAR: Si val es anterior a minDate, usar minDate como initialDate
    final safeInitialDate =
        (val != null && val.isBefore(minDate)) ? minDate : (val ?? minDate);

    return InkWell(
      onTap:
          disabled
              ? () {
                // Mostrar modal explicando por qué está deshabilitado
                _showDateRequiredModal(context);
              }
              : () async {
                final d = await showDatePicker(
                  context: context,
                  initialDate: safeInitialDate, // Usar fecha segura
                  firstDate: minDate, // Bloquea fechas anteriores
                  lastDate: DateTime(2030),
                );
                if (d != null) onPick(d);
              },
      child: InputDecorator(
        decoration: _inputDecoration(label, Icons.calendar_today).copyWith(
          // Cambiar estilo si está deshabilitado
          enabled: !disabled,
        ),
        child: Text(
          val != null ? "${val.day}/${val.month}/${val.year}" : "Seleccionar",
          style: TextStyle(
            fontSize: 14,
            color: disabled ? Colors.grey.shade400 : null,
          ),
        ),
      ),
    );
  }

  Widget _buildTimeField(
    BuildContext context,
    String label,
    TimeOfDay? val,
    Function(TimeOfDay) onPick, {
    TimeOfDay? minTime, // Parámetro opcional para hora mínima
    bool disabled = false, // Parámetro para deshabilitar el campo
  }) {
    return InkWell(
      onTap:
          disabled
              ? () {
                // Mostrar modal explicando por qué está deshabilitado
                _showTimeRequiredModal(context);
              }
              : () async {
                final t = await showTimePicker(
                  context: context,
                  initialTime: val ?? TimeOfDay.now(),
                  builder: (context, child) {
                    // FUERZA FORMATO 12 HORAS (AM/PM) VISUALMENTE
                    return MediaQuery(
                      data: MediaQuery.of(
                        context,
                      ).copyWith(alwaysUse24HourFormat: false),
                      child: child!,
                    );
                  },
                );

                if (t != null) {
                  // VALIDACIÓN DE LÓGICA HORARIA (Solo aplica si minTime existe)
                  if (minTime != null) {
                    final double selected = t.hour + t.minute / 60.0;
                    final double min = minTime.hour + minTime.minute / 60.0;

                    if (selected <= min) {
                      // ignore: use_build_context_synchronously
                      _showTimeErrorModal(context);
                      return; // No guardamos el valor inválido
                    }
                  }
                  onPick(t);
                }
              },
      child: InputDecorator(
        decoration: _inputDecoration(label, Icons.access_time).copyWith(
          // Cambiar estilo si está deshabilitado
          enabled: !disabled,
        ),
        // Muestra AM/PM en el texto del input
        child: Text(
          val != null ? val.format(context) : "--:-- --",
          style: TextStyle(
            fontSize: 14,
            color: disabled ? Colors.grey.shade400 : null,
          ),
        ),
      ),
    );
  }

  // --- SELECTOR DE GUÍA CON CO-GUÍAS ---
  Widget _buildGuiaSelector(
    BuildContext context,
    TripCreationState state,
    TripCreationCubit cubit,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Selector de Guía Principal
        InkWell(
          onTap: () => _showGuiaPicker(context, state, isCoGuia: false),
          child: InputDecorator(
            decoration: _inputDecoration('Guía Responsable', Icons.badge),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                state.selectedGuiaId == null
                    ? Text(
                      "Seleccionar Guía...",
                      style: TextStyle(color: Colors.grey[600]),
                    )
                    : _buildSelectedGuiaChip(
                      context,
                      state,
                      guiaId: state.selectedGuiaId!,
                      isRemovable: false,
                    ),
                const Icon(Icons.arrow_drop_down, color: Colors.grey),
              ],
            ),
          ),
        ),

        // Botón para agregar Co-Guías
        if (state.selectedGuiaId != null) ...[
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: () => _showGuiaPicker(context, state, isCoGuia: true),
            icon: const Icon(Icons.add, size: 18),
            label: const Text("Agregar Guía Auxiliar"),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.teal[700],
              side: BorderSide(color: Colors.teal[300]!),
            ),
          ),
        ],

        // Lista de Co-Guías seleccionados
        if (state.coGuiasIds.isNotEmpty) ...[
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children:
                state.coGuiasIds
                    .map(
                      (id) => _buildSelectedGuiaChip(
                        context,
                        state,
                        guiaId: id,
                        isRemovable: true,
                      ),
                    )
                    .toList(),
          ),
        ],
      ],
    );
  }

  Widget _buildSelectedGuiaChip(
    BuildContext context,
    TripCreationState state, {
    required String guiaId,
    required bool isRemovable,
  }) {
    // Manejar caso cuando no hay guías cargados aún
    if (state.availableGuides.isEmpty) {
      return const Text(
        "Cargando guías...",
        style: TextStyle(color: Colors.grey),
      );
    }

    final Map<String, dynamic> guia = state.availableGuides.firstWhere(
      (g) => g['id'] == guiaId,
      orElse: () => state.availableGuides.first,
    );

    // Determinar si es principal o auxiliar
    final bool isPrincipal = guiaId == state.selectedGuiaId;

    return Chip(
      avatar: CircleAvatar(
        backgroundColor: isPrincipal ? Colors.blue[800] : Colors.teal[700],
        child: Text(
          guia['name'][0],
          style: const TextStyle(fontSize: 10, color: Colors.white),
        ),
      ),
      label: Text(guia['name']),
      deleteIcon: isRemovable ? const Icon(Icons.close, size: 16) : null,
      onDeleted:
          isRemovable
              ? () => context.read<TripCreationCubit>().toggleCoGuia(guiaId)
              : null,
      backgroundColor: isPrincipal ? Colors.blue[50] : Colors.teal[50],
    );
  }

  // --- PASO 2: CONSTRUCTOR DE ITINERARIO ---
  Widget _buildItineraryStep(BuildContext context, TripCreationState state) {
    return Column(
      children: [
        // Botón para agregar actividad
        ElevatedButton.icon(
          icon: const Icon(Icons.add),
          label: const Text("Agregar Actividad"),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue[800],
            foregroundColor: Colors.white,
          ),
          onPressed: () => _showAddActivityModal(context),
        ),
        const SizedBox(height: 16),

        // Lista visual de actividades
        if (state.itinerario.isEmpty)
          const Padding(
            padding: EdgeInsets.all(24.0),
            child: Text(
              "El itinerario está vacío. Agrega actividades para configurar la seguridad.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          )
        else
          ...state.itinerario.map((actividad) => _buildActivityCard(actividad)),
      ],
    );
  }

  // Tarjeta de Actividad (Muestra si es Segura o Privada)
  Widget _buildActivityCard(ActividadItinerario actividad) {
    // Distinción visual clara entre Tiempo Libre y Actividad Monitoreada
    final bool esPrivado = actividad.tipo == TipoActividad.tiempoLibre;

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      // Borde lateral: Verde (Monitoreado) o Gris (Privado)
      shape: Border(
        left: BorderSide(
          color: esPrivado ? Colors.grey : Colors.green,
          width: 4,
        ),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: esPrivado ? Colors.grey[200] : Colors.green[50],
          child: Icon(
            esPrivado ? Icons.visibility_off : Icons.security,
            color: esPrivado ? Colors.grey : Colors.green[800],
            size: 20,
          ),
        ),
        title: Text(
          actividad.titulo,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          "${actividad.horaInicio.hour.toString().padLeft(2, '0')}:${actividad.horaInicio.minute.toString().padLeft(2, '0')} - ${actividad.horaFin.hour.toString().padLeft(2, '0')}:${actividad.horaFin.minute.toString().padLeft(2, '0')}\n${esPrivado ? '🔒 Rastreo GPS Desactivado' : '📡 Monitoreo Activo'}",
          style: TextStyle(fontSize: 12, color: Colors.grey[700]),
        ),
        trailing:
            actividad.huellaCarbono > 0
                ? Chip(
                  label: Text("${actividad.huellaCarbono}kg CO2"),
                  avatar: const Icon(Icons.eco, size: 14, color: Colors.green),
                )
                : null,
      ),
    );
  }

  // --- PASO 3: RESUMEN Y MÉTRICAS ---
  Widget _buildReviewStep(TripCreationState state) {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.grey[50],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Resumen de Impacto y Seguridad",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildKpiRow(Icons.timer, "Horas Monitoreadas", "12 hrs"),
          _buildKpiRow(
            Icons.visibility_off,
            "Horas de Privacidad",
            "4 hrs",
          ), // [cite: 6]
          _buildKpiRow(
            Icons.eco,
            "Huella de Carbono Total",
            "${state.totalHuellaCarbono} kg",
          ), //
          const SizedBox(height: 24),
          const Text(
            "Al guardar, se generarán las geocercas automáticas.",
            style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildKpiRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.blue[800], size: 20),
          const SizedBox(width: 12),
          Expanded(child: Text(label)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  // --- MODAL: ERROR DE VALIDACIÓN DE HORA ---
  void _showTimeErrorModal(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder:
          (ctx) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            elevation: 8,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.orange.shade50, Colors.white],
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Icono animado
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade100,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.access_time_filled,
                      size: 48,
                      color: Colors.orange.shade700,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Título
                  Text(
                    "Hora Inválida",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade800,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Mensaje
                  Text(
                    "El viaje no puede terminar antes de empezar.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.grey.shade600,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Sugerencia
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.blue.shade200, width: 1),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.lightbulb_outline,
                          size: 20,
                          color: Colors.blue.shade700,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            "Selecciona una hora posterior a la de inicio",
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.blue.shade900,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Botón de acción
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(ctx),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange.shade600,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                      ),
                      child: const Text(
                        "Entendido",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
    );
  }

  // --- MODAL: ADVERTENCIA DE FECHA RESETEADA ---
  void _showDateResetModal(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder:
          (ctx) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            elevation: 8,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.blue.shade50, Colors.white],
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Icono animado
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade100,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.event_repeat,
                      size: 48,
                      color: Colors.blue.shade700,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Título
                  Text(
                    "Fecha Actualizada",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade800,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Mensaje
                  Text(
                    "La fecha de fin se ha reseteado porque debe ser posterior a la fecha de inicio.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.grey.shade600,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Sugerencia
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.amber.shade200,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          size: 20,
                          color: Colors.amber.shade700,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            "Por favor, selecciona una nueva fecha de finalización",
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.amber.shade900,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Botón de acción
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(ctx),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade600,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                      ),
                      child: const Text(
                        "Entendido",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
    );
  }

  // --- MODAL: FECHA DE INICIO REQUERIDA ---
  void _showDateRequiredModal(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder:
          (ctx) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            elevation: 8,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.purple.shade50, Colors.white],
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Icono
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.purple.shade100,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.event_busy,
                      size: 48,
                      color: Colors.purple.shade700,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Título
                  Text(
                    "Fecha de Inicio Requerida",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade800,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Mensaje
                  Text(
                    "Primero debes seleccionar la fecha de inicio del viaje.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.grey.shade600,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Sugerencia
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.indigo.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.indigo.shade200,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.arrow_upward,
                          size: 20,
                          color: Colors.indigo.shade700,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            "Selecciona primero \"Inicia el...\" arriba",
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.indigo.shade900,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Botón de acción
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(ctx),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple.shade600,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                      ),
                      child: const Text(
                        "Entendido",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
    );
  }

  // --- MODAL: HORA DE INICIO REQUERIDA ---
  void _showTimeRequiredModal(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder:
          (ctx) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            elevation: 8,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.teal.shade50, Colors.white],
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Icono
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.teal.shade100,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.schedule,
                      size: 48,
                      color: Colors.teal.shade700,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Título
                  Text(
                    "Hora de Inicio Requerida",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade800,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Mensaje
                  Text(
                    "Primero debes seleccionar la hora de inicio del viaje.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.grey.shade600,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Sugerencia
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.cyan.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.cyan.shade200, width: 1),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.arrow_back,
                          size: 20,
                          color: Colors.cyan.shade700,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            "Selecciona primero \"Inicio\" a la izquierda",
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.cyan.shade900,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Botón de acción
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(ctx),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.teal.shade600,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                      ),
                      child: const Text(
                        "Entendido",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
    );
  }

  // --- MODAL: AGREGAR ACTIVIDAD (Simplificado para Demo) ---
  void _showAddActivityModal(BuildContext context) {
    // Simulación de agregar una actividad rápida
    final nueva = ActividadItinerario(
      id: DateTime.now().toString(),
      titulo: "Visita a Pirámides",
      tipo: TipoActividad.visitaGuiada,
      horaInicio: DateTime.now(),
      horaFin: DateTime.now().add(const Duration(hours: 2)),
      ubicacionCentral: const LatLng(19.6925, -98.8439),
      huellaCarbono: 2.5,
      guiaResponsableId: 'gui-01',
    );

    context.read<TripCreationCubit>().addActivity(nueva);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Actividad agregada al itinerario")),
    );
  }

  // --- FUNCIÓN: BÚSQUEDA DE LUGARES (Nominatim API) ---
  Future<List<dynamic>> _buscarLugar(String query) async {
    if (query.isEmpty) return [];

    final url = Uri.parse(
      'https://nominatim.openstreetmap.org/search?q=$query&format=json&limit=5',
    );

    try {
      final response = await http.get(
        url,
        headers: {
          'User-Agent': 'com.othliani.app', // CRUCIAL para Nominatim
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return [];
    } catch (e) {
      debugPrint("Error buscando lugar: $e");
      return [];
    }
  }

  // --- MODAL: SELECTOR DE MAPA CON BÚSQUEDA ---
  void _showMapPicker(BuildContext context) {
    final MapController mapController = MapController();
    List<dynamic> searchResults = [];
    bool isSearching = false;

    // Capturar el cubit ANTES del StatefulBuilder
    final cubit = context.read<TripCreationCubit>();

    // Obtener ubicación previa si existe
    final LatLng initialCenter =
        cubit.state.location ?? const LatLng(19.4326, -99.1332);
    final double initialZoom = cubit.state.location != null ? 15.0 : 13.0;

    showDialog(
      context: context,
      builder:
          (ctx) => StatefulBuilder(
            builder: (context, setModalState) {
              return Dialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: SizedBox(
                  width: 700,
                  height: 600,
                  child: Stack(
                    children: [
                      // CAPA 1: EL MAPA (Al fondo)
                      FlutterMap(
                        mapController: mapController,
                        options: MapOptions(
                          initialCenter:
                              initialCenter, // Usar ubicación calculada
                          initialZoom: initialZoom,
                          onTap: (_, latlng) {
                            cubit.setLocation(latlng);
                            Navigator.pop(ctx);
                          },
                        ),
                        children: [
                          TileLayer(
                            urlTemplate:
                                'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                            userAgentPackageName: 'com.othliani.app',
                          ),
                        ],
                      ),

                      // CAPA 2: BARRA DE BÚSQUEDA FLOTANTE
                      Positioned(
                        top: 20,
                        left: 20,
                        right: 20,
                        child: Column(
                          children: [
                            // EL INPUT DE TEXTO
                            Card(
                              elevation: 4,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: TextField(
                                decoration: InputDecoration(
                                  hintText:
                                      "Buscar 'Teotihuacán', 'Hotel Xcaret'...",
                                  prefixIcon: const Icon(Icons.search),
                                  suffixIcon:
                                      isSearching
                                          ? const SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: Padding(
                                              padding: EdgeInsets.all(10),
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                              ),
                                            ),
                                          )
                                          : null,
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 14,
                                  ),
                                ),
                                textInputAction: TextInputAction.search,
                                onSubmitted: (value) async {
                                  setModalState(() => isSearching = true);

                                  final resultados = await _buscarLugar(value);

                                  setModalState(() {
                                    searchResults = resultados;
                                    isSearching = false;
                                  });
                                },
                              ),
                            ),

                            // LA LISTA DE RESULTADOS
                            if (searchResults.isNotEmpty)
                              Container(
                                margin: const EdgeInsets.only(top: 8),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(8),
                                  boxShadow: const [
                                    BoxShadow(
                                      color: Colors.black26,
                                      blurRadius: 10,
                                    ),
                                  ],
                                ),
                                constraints: const BoxConstraints(
                                  maxHeight: 200,
                                ),
                                child: ListView.separated(
                                  shrinkWrap: true,
                                  itemCount: searchResults.length,
                                  separatorBuilder:
                                      (_, __) => const Divider(height: 1),
                                  itemBuilder: (context, index) {
                                    final lugar = searchResults[index];
                                    return ListTile(
                                      leading: const Icon(
                                        Icons.place,
                                        color: Colors.blueGrey,
                                      ),
                                      title: Text(
                                        lugar['display_name'].split(',')[0],
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      subtitle: Text(
                                        lugar['display_name'],
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(fontSize: 10),
                                      ),
                                      onTap: () {
                                        // 1. Extraer coordenadas
                                        final double lat = double.parse(
                                          lugar['lat'],
                                        );
                                        final double lon = double.parse(
                                          lugar['lon'],
                                        );
                                        final nuevoPunto = LatLng(lat, lon);

                                        // 2. Mover el mapa ahí
                                        mapController.move(nuevoPunto, 15);

                                        // 3. Limpiar búsqueda
                                        setModalState(() => searchResults = []);
                                      },
                                    );
                                  },
                                ),
                              ),
                          ],
                        ),
                      ),

                      // CAPA 3: INSTRUCCIÓN
                      Positioned(
                        bottom: 20,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black54,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              "Toca cualquier punto para confirmar",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
    );
  }
  // --- WIDGETS AUXILIARES PARA SPLIT VIEW ---

  // Lógica de Fechas extraída
  Widget _buildDateSelector(
    BuildContext context,
    TripCreationState state,
    TripCreationCubit cubit,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(),
        const SizedBox(height: 16),
        // SWITCH DE DURACIÓN
        Row(
          children: [
            Icon(Icons.date_range, color: Colors.blueGrey[700]),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Duración del Viaje",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  state.isMultiDay
                      ? "Varios Días (Expedición)"
                      : "Un Día (Excursión)",
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
            const Spacer(),
            Switch(
              value: state.isMultiDay,
              onChanged: (val) => cubit.toggleMultiDay(val),
              thumbColor: WidgetStateProperty.resolveWith<Color>(
                (states) =>
                    states.contains(WidgetState.selected)
                        ? Colors.blue[800]!
                        : Colors.grey[400]!,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // FECHAS Y HORAS (GRID)
        if (!state.isMultiDay)
          // CASO A: UN SOLO DÍA
          Row(
            children: [
              Expanded(
                flex: 2,
                child: _buildDateField(
                  context,
                  "Fecha",
                  state.fechaInicio,
                  (d) => cubit.setDates(start: d, end: d),
                  firstDate: DateTime.now(), // Regla 1: No viajes al pasado
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTimeField(
                  context,
                  "Inicio",
                  state.horaInicio,
                  (t) => cubit.setHoraInicio(t),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTimeField(
                  context,
                  "Fin",
                  state.horaFin,
                  (t) => cubit.setHoraFin(t),
                  minTime: state.horaInicio, // Regla 2: Fin > Inicio
                  disabled:
                      state.horaInicio ==
                      null, // Deshabilitar si no hay hora de inicio
                ),
              ),
            ],
          )
        else
          // CASO B: MULTIDÍA
          Column(
            children: [
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: _buildDateField(
                      context,
                      "Inicia el...",
                      state.fechaInicio,
                      (d) {
                        // Si cambia inicio y había una fecha fin, mostrar modal
                        final hadEndDate = state.fechaFin != null;
                        cubit.setDates(start: d, end: null);

                        if (hadEndDate) {
                          // Mostrar modal informando el reset
                          Future.delayed(const Duration(milliseconds: 100), () {
                            // ignore: use_build_context_synchronously
                            _showDateResetModal(context);
                          });
                        }
                      },
                      firstDate: DateTime.now(), // Regla 1: No viajes al pasado
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildTimeField(
                      context,
                      "A las...",
                      state.horaInicio,
                      (t) => cubit.setHoraInicio(t),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: _buildDateField(
                      context,
                      "Termina el...",
                      state.fechaFin,
                      (d) => cubit.setDates(start: state.fechaInicio, end: d),
                      // Regla 2: El fin debe ser AL MENOS el día siguiente del inicio
                      firstDate:
                          state.fechaInicio?.add(const Duration(days: 1)) ??
                          DateTime.now().add(const Duration(days: 1)),
                      // Deshabilitar si no hay fecha de inicio
                      disabled: state.fechaInicio == null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildTimeField(
                      context,
                      "A las...",
                      state.horaFin,
                      (t) => cubit.setHoraFin(t),
                    ),
                  ),
                ],
              ),
            ],
          ),
      ],
    );
  }

  // Widget auxiliar para el efecto de selección "Pro"
  Widget _buildSelectableCard({
    required bool isSelected,
    required VoidCallback onTap,
    required Widget child,
  }) {
    return InkWell(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border:
              isSelected
                  ? Border.all(color: Colors.blue[800]!, width: 4)
                  : Border.all(color: Colors.grey[300]!),
          boxShadow:
              isSelected
                  ? [
                    BoxShadow(
                      color: Colors.blue.withValues(alpha: 0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                  : [],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(
            8,
          ), // Un poco menos que el borde externo
          child: child,
        ),
      ),
    );
  }
}
