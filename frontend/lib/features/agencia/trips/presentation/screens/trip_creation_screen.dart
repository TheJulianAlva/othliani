import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_map/flutter_map.dart'; // <--- Importante
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:frontend/features/agencia/trips/presentation/blocs/trip_creation/trip_creation_cubit.dart';
import 'package:frontend/core/navigation/routes_agencia.dart'; // Importar rutas
import 'package:frontend/core/di/service_locator.dart' as di; // Importar DI
import 'package:frontend/core/widgets/saving_overlay.dart'; // ✨ Overlay de guardado
import '../widgets/destino_field_widget.dart'; // <--- Validar ubicación
import '../../../shared/presentation/widgets/draft_guard_widget.dart'; // 🛡️ Draft Guard
import 'package:file_picker/file_picker.dart';
import '../../data/datasources/csv_itinerary_parser.dart';

class TripCreationScreen extends StatelessWidget {
  const TripCreationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create:
          (_) =>
              di.sl<TripCreationCubit>()..checkForDraft(), // 💾 Check for draft
      child: BlocListener<TripCreationCubit, TripCreationState>(
        listenWhen:
            (previous, current) => !previous.draftFound && current.draftFound,
        listener: (context, state) {
          _showDraftRecoveryDialog(context, state);
        },
        child: BlocBuilder<TripCreationCubit, TripCreationState>(
          builder: (context, state) {
            final bool hayDatos =
                state.destino.isNotEmpty ||
                state.location != null ||
                state.selectedGuiaId != null ||
                state.fechaInicio != null;

            return DraftGuardWidget(
              shouldWarn: hayDatos,
              // Cuando hay pasos anteriores, el gesto de atrás del sistema
              // debe ir al paso previo, NO mostrar el diálogo de advertencia.
              onBackOverride:
                  state.currentStep > 0
                      ? () => context.read<TripCreationCubit>().prevStep()
                      : null,
              child: Scaffold(
                appBar: AppBar(
                  title: const Text("Nuevo Viaje Inteligente"),
                  // Override del botón de atrás para manejar navegación entre pasos
                  leading: IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () {
                      final cubit = context.read<TripCreationCubit>();
                      if (state.currentStep > 0) {
                        // Si estamos en paso 2 o 3, regresar al paso anterior
                        cubit.prevStep();
                      } else {
                        // Si estamos en paso 1, intentar salir (el DraftGuard interceptará si es necesario)
                        // Usamos maybePop para disparar el PopScope del DraftGuard
                        Navigator.maybePop(context);
                      }
                    },
                  ),
                ),
                body: const _TripCreationForm(),
              ),
            );
          },
        ),
      ),
    );
  }

  void _showDraftRecoveryDialog(BuildContext context, TripCreationState state) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (ctx) => AlertDialog(
            title: const Text("Borrador Encontrado"),
            content: Text(
              "Tienes un viaje pendiente a \"${state.draftData?.destino ?? 'un destino'}\".\n¿Quieres continuar donde lo dejaste?",
            ),
            actions: [
              TextButton(
                onPressed: () {
                  context.read<TripCreationCubit>().discardDraft();
                  Navigator.of(ctx).pop();
                },
                style: TextButton.styleFrom(foregroundColor: Colors.grey),
                child: const Text("Descartar"),
              ),
              ElevatedButton(
                onPressed: () {
                  context.read<TripCreationCubit>().restoreDraft();
                  Navigator.of(ctx).pop();
                },
                child: const Text("Restaurar"),
              ),
            ],
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
        // ✨ FASE 12: Simplificación - Pantalla única de datos antes del Itinerario
        return Stepper(
          // type: StepperType.horizontal, // Opcional: horizontal si hay espacio
          currentStep: state.currentStep,
          onStepContinue: () {
            if (state.currentStep == 0) {
              if (cubit.isStep1Valid) {
                cubit.nextStep();
              }
            } else {
              // En paso 1 (Itinerario), la acción principal es el botón grande
              // Pero si le dan continue, podríamos ir al builder también
              final ruta =
                  '${RoutesAgencia.viajes}/${RoutesAgencia.itineraryBuilder}';
              context.push(ruta, extra: cubit.viajeTemporal);
            }
          },
          onStepCancel: () {
            if (state.currentStep > 0) {
              cubit.prevStep();
            } else {
              context.go(RoutesAgencia.viajes);
            }
          },
          controlsBuilder: (context, details) {
            // Personalizamos los controles para ocultarlos en el paso 2
            if (state.currentStep == 1) return const SizedBox.shrink();

            return Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed:
                          cubit.isStep1Valid ? details.onStepContinue : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[800],
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: Colors.blue[200],
                        disabledForegroundColor: Colors.white70,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text("Continuar al Itinerario"),
                    ),
                  ),
                  const SizedBox(width: 16),
                  TextButton(
                    onPressed: () async {
                      final hayDatos =
                          state.destino.isNotEmpty ||
                          state.location != null ||
                          state.selectedGuiaId != null;

                      if (hayDatos) {
                        final salir =
                            await DraftGuardWidget.showExitDialog(context) ??
                            false;
                        if (salir && context.mounted) {
                          // Overlay de guardado antes de salir
                          await SavingOverlay.showAndWait(
                            context,
                            mensaje: "Guardando borrador...",
                            duration: const Duration(milliseconds: 800),
                          );
                          if (context.mounted) {
                            context.go(RoutesAgencia.viajes);
                          }
                        }
                      } else {
                        context.go(RoutesAgencia.viajes);
                      }
                    },
                    child: const Text("Cancelar"),
                  ),
                ],
              ),
            );
          },
          steps: [
            Step(
              title: const Text("Datos Generales"),
              content: _buildGeneralInfoStep(
                context,
                state,
              ), // Sin botones internos
              isActive: state.currentStep >= 0,
              state:
                  state.currentStep > 0
                      ? StepState.complete
                      : StepState.editing,
            ),
            Step(
              title: const Text("Planificación"),
              content: _buildItineraryStep(context, state),
              isActive: state.currentStep >= 1,
              state: StepState.indexed,
            ),
          ],
        );
      },
    );
  }

  // --- PASO 1: DATOS GENERALES (VERSIÓN PRO SPLIT VIEW) ---
  Widget _buildGeneralInfoStep(BuildContext context, TripCreationState state) {
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

                        // 1. CLAVE BASE DEL VIAJE (Identificador Único) con Autocompletado
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Autocomplete<Map<String, String>>(
                                // 🔑 Key única basada en claveBase para forzar
                                // reconstrucción al restaurar el borrador.
                                key: ValueKey('clave_${state.claveBase ?? ''}'),
                                initialValue:
                                    state.claveBase != null
                                        ? TextEditingValue(
                                          text: state.claveBase!,
                                        )
                                        : null,
                                optionsBuilder: (
                                  TextEditingValue textEditingValue,
                                ) {
                                  if (textEditingValue.text.isEmpty) {
                                    return const Iterable<
                                      Map<String, String>
                                    >.empty();
                                  }
                                  return cubit.clavesHistorial.where((
                                    Map<String, String> option,
                                  ) {
                                    return option['clave']!
                                            .toLowerCase()
                                            .contains(
                                              textEditingValue.text
                                                  .toLowerCase(),
                                            ) ||
                                        option['destino']!
                                            .toLowerCase()
                                            .contains(
                                              textEditingValue.text
                                                  .toLowerCase(),
                                            );
                                  });
                                },
                                displayStringForOption:
                                    (Map<String, String> option) =>
                                        option['clave']!,
                                onSelected: (Map<String, String> selection) {
                                  cubit.onClaveBaseChanged(selection['clave']!);
                                },
                                fieldViewBuilder: (
                                  context,
                                  controller,
                                  focusNode,
                                  onEditingComplete,
                                ) {
                                  // Sincronizar el texto del field con el estado (ej. cuando se llena desde el Modal)
                                  if (state.claveBase != null &&
                                      controller.text != state.claveBase) {
                                    WidgetsBinding.instance
                                        .addPostFrameCallback((_) {
                                          if (controller.text !=
                                                  state.claveBase &&
                                              state.claveBase != null) {
                                            controller.text = state.claveBase!;
                                          }
                                        });
                                  }

                                  return TextFormField(
                                    controller: controller,
                                    focusNode: focusNode,
                                    onChanged:
                                        (v) => cubit.onClaveBaseChanged(v),
                                    textCapitalization:
                                        TextCapitalization.characters,
                                    decoration: _inputDecoration(
                                      'Buscar o crear Clave (Ej. MEX)',
                                      Icons.vpn_key,
                                    ).copyWith(errorText: cubit.claveError),
                                  );
                                },
                                optionsViewBuilder: (
                                  context,
                                  onSelected,
                                  options,
                                ) {
                                  return Align(
                                    alignment: Alignment.topLeft,
                                    child: Material(
                                      elevation: 4.0,
                                      borderRadius: BorderRadius.circular(8),
                                      child: ConstrainedBox(
                                        constraints: const BoxConstraints(
                                          maxHeight: 200,
                                          maxWidth: 350,
                                        ),
                                        child: ListView.builder(
                                          padding: EdgeInsets.zero,
                                          shrinkWrap: true,
                                          itemCount: options.length,
                                          itemBuilder: (
                                            BuildContext context,
                                            int index,
                                          ) {
                                            final option = options.elementAt(
                                              index,
                                            );
                                            return ListTile(
                                              leading: const Icon(
                                                Icons.history,
                                                color: Colors.blueGrey,
                                              ),
                                              title: Text(
                                                option['clave']!,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              subtitle: Text(
                                                option['destino']!,
                                              ),
                                              onTap: () {
                                                onSelected(option);
                                              },
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                            const SizedBox(width: 8),
                            // Botón de más para crear nueva clave + ubicación
                            Container(
                              decoration: BoxDecoration(
                                color:
                                    Colors.blue[50], // Tono suave de la marca
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.blue[100]!),
                              ),
                              height:
                                  56, // para que cuadre visualmente con el Input
                              child: IconButton(
                                icon: const Icon(
                                  Icons.add_location_alt,
                                  color: Colors.blue,
                                ),
                                tooltip: 'Registrar nueva Clave',
                                onPressed: () {
                                  _showNuevaClaveModal(context, cubit);
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // 2. NOMBRE DEL VIAJE (Sincronizado con Mapa)
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

  // --- MODAL DE NUEVA CLAVE ---
  void _showNuevaClaveModal(BuildContext context, TripCreationCubit cubit) {
    String nuevaClave = '';

    showDialog(
      context: context,
      builder:
          (ctx) => BlocProvider<TripCreationCubit>.value(
            value: cubit,
            child: BlocBuilder<TripCreationCubit, TripCreationState>(
              builder: (context, state) {
                return AlertDialog(
                  title: const Text(
                    'Registrar Nueva Clave',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Ingresa la nueva clave base y la ubicación predeterminada. Ésta se guardará en el catálogo general.',
                        style: TextStyle(fontSize: 13, color: Colors.grey),
                      ),
                      const SizedBox(height: 20),
                      TextField(
                        decoration: _inputDecoration(
                          'Nueva Clave (Ej. MTY)',
                          Icons.vpn_key,
                        ),
                        textCapitalization: TextCapitalization.characters,
                        onChanged: (v) => nuevaClave = v.toUpperCase(),
                      ),
                      const SizedBox(height: 12),
                      DestinoFieldWidget(
                        initialValue: state.destino,
                        onChanged: (v) => cubit.onDestinoChanged(v),
                        hasPhotos: state.fotosCandidatas.isNotEmpty,
                        decoration: _inputDecoration(
                          'Nombre del Viaje / Destino',
                          Icons.place,
                        ),
                      ),
                      const SizedBox(height: 12),
                      InkWell(
                        onTap: () => _showMapPicker(context),
                        borderRadius: BorderRadius.circular(12),
                        child: InputDecorator(
                          decoration: _inputDecoration(
                            'Ubicación en el Mapa',
                            Icons.map,
                          ).copyWith(
                            suffixIcon: const Icon(
                              Icons.location_on,
                              color: Colors.blue,
                            ),
                          ),
                          child: Text(
                            state.location != null
                                ? "\${state.location!.latitude.toStringAsFixed(4)}, \${state.location!.longitude.toStringAsFixed(4)}"
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
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text(
                        'Cancelar',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        // 1. Validar si la clave ya existe en el historial
                        final exists = cubit.clavesHistorial.any(
                          (element) => element['clave'] == nuevaClave,
                        );
                        if (exists) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                '⚠️ Error: La clave $nuevaClave ya existe en el catálogo.',
                              ),
                              backgroundColor: Colors.red.shade600,
                            ),
                          );
                          return;
                        }

                        // 2. Validar que todo esté lleno
                        if (nuevaClave.isNotEmpty &&
                            state.destino.isNotEmpty &&
                            state.location != null) {
                          // Guardamos la clave permanentemente en esta sesión
                          cubit.registrarNuevaClaveMock(
                            nuevaClave,
                            state.destino,
                            state.location!,
                          );
                          cubit.onClaveBaseChanged(nuevaClave);
                          Navigator.pop(ctx);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Por favor completa: Clave, Destino y Ubicación en Mapa.',
                              ),
                              backgroundColor: Colors.orange,
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[800],
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Guardar'),
                    ),
                  ],
                );
              },
            ),
          ),
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
  // --- PASO 2: CONSTRUCTOR DE ITINERARIO (Pantalla Intermedia) ---
  Widget _buildItineraryStep(BuildContext context, TripCreationState state) {
    // Calcular duración del viaje en días para mostrar info
    final int duracionDias;
    if (state.isMultiDay &&
        state.fechaInicio != null &&
        state.fechaFin != null) {
      duracionDias = state.fechaFin!.difference(state.fechaInicio!).inDays + 1;
    } else {
      duracionDias = 1;
    }

    return Container(
      padding: const EdgeInsets.all(32),
      constraints: const BoxConstraints(maxWidth: 600), // Limitar ancho
      child: Column(
        mainAxisSize: MainAxisSize.min, // Ajustar al contenido
        children: [
          Icon(Icons.map_outlined, size: 80, color: Colors.blue[800]),
          const SizedBox(height: 24),
          Text(
            "Constructor de Itinerario Visual",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.grey[800],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            "Configura las actividades, paradas y horarios para tu viaje de $duracionDias ${duracionDias == 1 ? 'día' : 'días'}.",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
          const SizedBox(height: 32),

          // Botón Principal de Acción
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              icon: const Icon(Icons.edit_road, size: 28),
              label: const Text(
                "Abrir Constructor de Itinerario",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[800],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 24,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 4,
              ),
              onPressed: () {
                final cubit = context.read<TripCreationCubit>();
                final ruta =
                    '${RoutesAgencia.viajes}/${RoutesAgencia.itineraryBuilder}';
                debugPrint("🚀 Navegando a $ruta con Viaje Temporal");
                context.push(ruta, extra: cubit.viajeTemporal);
              },
            ),
          ),

          const SizedBox(height: 24),

          // Botón Importar Itinerario Completo por CSV
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              icon: const Icon(Icons.upload_file, size: 22),
              label: const Text(
                "Importar Itinerario Completo (CSV)",
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.teal[700],
                side: BorderSide(color: Colors.teal[300]!),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 18,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () async {
                final resultado = await showDialog<bool>(
                  context: context,
                  builder:
                      (ctx) => AlertDialog(
                        icon: Icon(
                          Icons.description_outlined,
                          color: Colors.teal[700],
                          size: 40,
                        ),
                        title: const Text('Importar Itinerario Completo'),
                        content: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text(
                                'El archivo CSV debe tener esta estructura:',
                              ),
                              const SizedBox(height: 12),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.grey[100],
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.grey[300]!),
                                ),
                                child: const Text(
                                  'dia,titulo,descripcion,hora_inicio,hora_fin,tipo,recomendaciones\\n'
                                  '1,Check-in,Registro,08:00,09:00,hospedaje,Llevar ID\\n'
                                  '1,Desayuno,Restaurante,09:00,10:00,alimentos,\\n'
                                  '2,Traslado,Bus a playa,07:00,09:00,traslado,\\n'
                                  '2,Playa,Día libre,09:30,16:00,tiempoLibre,Protector solar',
                                  style: TextStyle(
                                    fontFamily: 'monospace',
                                    fontSize: 11,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Tipos válidos: hospedaje, alimentos, traslado, cultura, aventura, tiempoLibre',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Formato de hora: HH:mm (24 horas)',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'La columna "dia" indica el número de día (1, 2, 3...)',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, false),
                            child: const Text('Cancelar'),
                          ),
                          ElevatedButton.icon(
                            icon: const Icon(Icons.folder_open),
                            label: const Text('Seleccionar CSV'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.teal[700],
                              foregroundColor: Colors.white,
                            ),
                            onPressed: () => Navigator.pop(ctx, true),
                          ),
                        ],
                      ),
                );
                if (resultado != true) return;
                // ignore: use_build_context_synchronously
                if (!context.mounted) return;

                final result = await FilePicker.platform.pickFiles(
                  type: FileType.custom,
                  allowedExtensions: ['csv'],
                  withData: true,
                );
                if (result == null || result.files.single.bytes == null) return;

                final csvContent = utf8.decode(result.files.single.bytes!);
                // ignore: use_build_context_synchronously
                if (!context.mounted) return;

                try {
                  final cubit = context.read<TripCreationCubit>();
                  final viaje = cubit.viajeTemporal;

                  // Validar CSV antes de navegar
                  final mapa = CsvItineraryParser.parseFullTrip(
                    csvContent,
                    viaje.fechaInicio,
                  );

                  // Navegar al builder con CSV pre-cargado
                  final ruta =
                      '\${RoutesAgencia.viajes}/\${RoutesAgencia.itineraryBuilder}';
                  // ignore: use_build_context_synchronously
                  if (!context.mounted) return;
                  // Pasar un map con viaje + datos CSV
                  context.push(ruta, extra: {'viaje': viaje, 'csvData': mapa});
                } on FormatException catch (e) {
                  // ignore: use_build_context_synchronously
                  if (!context.mounted) return;
                  showDialog(
                    context: context,
                    builder:
                        (ctx) => AlertDialog(
                          icon: const Icon(
                            Icons.error_outline,
                            color: Colors.red,
                            size: 40,
                          ),
                          title: const Text('Error en CSV'),
                          content: Text(e.message),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(ctx),
                              child: const Text('Entendido'),
                            ),
                          ],
                        ),
                  );
                }
              },
            ),
          ),

          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 16),

          Text(
            "💡 Tip: Puedes arrastrar y soltar actividades en la línea de tiempo dentro del constructor.",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  // --- MODAL: ERROR DE VALIDACIÓN DE HORA ---
  // ✨ NUEVO: Modal cuando el viaje no tiene mínimo 2 horas de duración

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

  // --- MODAL: HORA DE INICIO RESETEADA ---

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

  // --- MODAL: ERROR DE HORA PASADA ---

  // --- MODAL: HORA DE INICIO REQUERIDA ---

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
    // ✨ Controlador del TextField de búsqueda del mapa
    final mapSearchController = TextEditingController();
    List<dynamic> searchResults = [];
    bool isSearching = false;
    // Rastrear si el usuario escribió algo en el campo de búsqueda del mapa
    bool mapSearchHasText = false;

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
                          onTap: (_, latlng) async {
                            // Hacer geocoding inverso para obtener el nombre
                            try {
                              final url = Uri.parse(
                                'https://nominatim.openstreetmap.org/reverse?lat=${latlng.latitude}&lon=${latlng.longitude}&format=json',
                              );
                              final response = await http.get(
                                url,
                                headers: {'User-Agent': 'com.othliani.app'},
                              );
                              if (response.statusCode == 200) {
                                final data = json.decode(response.body);
                                // ✨ Solo sugerir nombre si el usuario NO escribió nada en el campo de búsqueda del mapa
                                if (!mapSearchHasText) {
                                  final nombre =
                                      data['address']['city'] ??
                                      data['address']['town'] ??
                                      data['address']['village'] ??
                                      data['display_name'].split(',')[0];
                                  cubit.setLocationAndSearchPhotos(
                                    latlng,
                                    nombreSugerido: nombre,
                                  );
                                } else {
                                  // El usuario ya escribió algo → solo actualizar coordenadas
                                  cubit.setLocationAndSearchPhotos(latlng);
                                }
                              } else {
                                cubit.setLocationAndSearchPhotos(latlng);
                              }
                            } catch (e) {
                              debugPrint('Error en geocoding: $e');
                              cubit.setLocationAndSearchPhotos(latlng);
                            }
                            if (ctx.mounted) {
                              Navigator.pop(ctx);
                            }
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
                                controller: mapSearchController,
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
                                // ✨ Rastrear si el usuario escribió algo
                                onChanged: (value) {
                                  setModalState(() {
                                    mapSearchHasText = value.trim().isNotEmpty;
                                  });
                                },
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

                                        // 3. Extraer nombre del lugar
                                        final nombreLugar =
                                            lugar['display_name'].split(',')[0];

                                        // 4. Guardar en el Cubit CON AUTOCOMPLETADO Y FOTOS
                                        cubit.setLocationAndSearchPhotos(
                                          nuevoPunto,
                                          nombreSugerido: nombreLugar,
                                        );

                                        // 5. Limpiar búsqueda (mantener modal abierto)
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

        // FECHAS (sin horas — el usuario las define desde las actividades)
        if (!state.isMultiDay)
          // CASO A: UN SOLO DÍA
          _buildDateField(
            context,
            "Fecha",
            state.fechaInicio,
            (d) {
              final hadEndDate = state.fechaFin != null;
              final endDateWasAfterNew =
                  state.fechaFin != null && d.isAfter(state.fechaFin!);
              cubit.setFechaInicio(d);
              if (hadEndDate && endDateWasAfterNew) {
                Future.delayed(const Duration(milliseconds: 100), () {
                  // ignore: use_build_context_synchronously
                  _showDateResetModal(context);
                });
              }
            },
            // La fecha de inicio mínima es mañana
            firstDate: DateTime.now().add(const Duration(days: 1)),
          )
        else
          // CASO B: MULTIDÍA
          Column(
            children: [
              _buildDateField(
                context,
                "Inicia el...",
                state.fechaInicio,
                (d) {
                  final hadEndDate = state.fechaFin != null;
                  final endDateWasAfterNew =
                      state.fechaFin != null && d.isAfter(state.fechaFin!);
                  cubit.setFechaInicio(d);
                  if (hadEndDate && endDateWasAfterNew) {
                    Future.delayed(const Duration(milliseconds: 100), () {
                      // ignore: use_build_context_synchronously
                      _showDateResetModal(context);
                    });
                  }
                },
                // La fecha de inicio mínima es mañana
                firstDate: DateTime.now().add(const Duration(days: 1)),
              ),
              const SizedBox(height: 16),
              _buildDateField(
                context,
                "Termina el...",
                state.fechaFin,
                (d) => cubit.setDates(start: state.fechaInicio, end: d),
                firstDate:
                    state.fechaInicio?.add(const Duration(days: 1)) ??
                    DateTime.now().add(const Duration(days: 2)),
                disabled: state.fechaInicio == null,
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
