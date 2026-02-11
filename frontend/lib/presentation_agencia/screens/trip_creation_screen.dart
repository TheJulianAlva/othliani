import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_map/flutter_map.dart'; // <--- Importante
import 'package:latlong2/latlong.dart';
import '../blocs/trip_creation/trip_creation_cubit.dart';
import '../../domain/entities/actividad_itinerario.dart';
import '../../core/navigation/routes_agencia.dart'; // Importar rutas

class TripCreationScreen extends StatelessWidget {
  const TripCreationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => TripCreationCubit(),
      child: Scaffold(
        appBar: AppBar(title: const Text("Nuevo Viaje Inteligente")),
        body: const _TripCreationForm(),
      ),
    );
  }
}

class _TripCreationForm extends StatelessWidget {
  const _TripCreationForm();

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<TripCreationCubit>();

    return BlocBuilder<TripCreationCubit, TripCreationState>(
      builder: (context, state) {
        return Stepper(
          type: StepperType.horizontal,
          currentStep: state.currentStep,
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
              content: _buildGeneralInfoStep(context, state),
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

  // --- PASO 1: DATOS GENERALES (VERSIÓN PRO) ---
  Widget _buildGeneralInfoStep(BuildContext context, TripCreationState state) {
    final cubit = context.read<TripCreationCubit>();

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 16,
      ), // Espaciado
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // TÍTULO DE SECCIÓN
          Text(
            "Detalles del Viaje",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.blueGrey[800],
            ),
          ),
          const SizedBox(height: 24),

          // 1. NOMBRE DEL VIAJE (Input Moderno)
          TextFormField(
            initialValue: state.destino,
            decoration: _inputDecoration(
              'Nombre del Viaje / Destino',
              Icons.place,
            ),
            onChanged:
                (v) => cubit.updateBasicInfo(
                  v,
                  state.fechaInicio ?? DateTime.now(),
                  state.fechaFin ?? DateTime.now(),
                ),
          ),
          const SizedBox(height: 24),

          // 2. UBICACIÓN (Mapa + Coordenadas)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  children: [
                    InputDecorator(
                      decoration: _inputDecoration(
                        'Ubicación / Punto de Encuentro',
                        Icons.pin_drop,
                      ),
                      child: Text(
                        state.location != null
                            ? "${state.location!.latitude.toStringAsFixed(4)}, ${state.location!.longitude.toStringAsFixed(4)}"
                            : "No seleccionada",
                        style: TextStyle(
                          color:
                              state.location != null
                                  ? Colors.black
                                  : Colors.grey,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.map),
                        label: const Text("Seleccionar en Mapa"),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onPressed: () => _showMapPicker(context),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              // Preview Mapa
              Container(
                width: 120,
                height: 130, // Alineado con input + botón
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.grey[100],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child:
                      state.location == null
                          ? const Center(
                            child: Icon(
                              Icons.map,
                              color: Colors.grey,
                              size: 40,
                            ),
                          )
                          : FlutterMap(
                            options: MapOptions(
                              initialCenter: state.location!,
                              initialZoom: 13,
                              interactionOptions: const InteractionOptions(
                                flags: InteractiveFlag.none,
                              ),
                            ),
                            children: [
                              TileLayer(
                                urlTemplate:
                                    'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                userAgentPackageName: 'com.othliani.app',
                              ),
                              MarkerLayer(
                                markers: [
                                  Marker(
                                    point: state.location!,
                                    child: const Icon(
                                      Icons.location_on,
                                      color: Colors.red,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // 2. SELECTOR DE GUÍA AVANZADO (Input ReadOnly que abre Modal)
          InkWell(
            onTap: () => _showGuiaPicker(context, state),
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
                      : _buildSelectedGuiaChip(state),
                  const Icon(Icons.arrow_drop_down, color: Colors.grey),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 24),

          // 3. SWITCH DE DURACIÓN
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
                activeThumbColor: Colors.blue[800],
              ),
            ],
          ),
          const SizedBox(height: 24),

          // 4. FECHAS Y HORAS (GRID)
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
                        (d) => cubit.setDates(start: d, end: state.fechaFin),
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
  void _showGuiaPicker(BuildContext context, TripCreationState state) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (ctx) => DraggableScrollableSheet(
            initialChildSize: 0.7,
            expand: false,
            builder:
                (_, scrollController) => Column(
                  children: [
                    // Cabecera del Modal
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: TextField(
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
                            (v) =>
                                context.read<TripCreationCubit>().searchGuia(v),
                      ),
                    ),
                    const Divider(height: 1),
                    // Lista Filtrada y Ordenada
                    Expanded(
                      child: ListView.separated(
                        controller: scrollController,
                        itemCount: state.guiasFiltrados.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (ctx, i) {
                          final guia = state.guiasFiltrados[i];
                          final bool disponible =
                              guia['status'] == 'Disponible';

                          return ListTile(
                            enabled:
                                disponible, // Desactiva clic si está ocupado
                            leading: CircleAvatar(
                              backgroundColor:
                                  disponible
                                      ? Colors.blue[100]
                                      : Colors.grey[300],
                              child: Text(
                                guia['name'][0],
                                style: TextStyle(
                                  color:
                                      disponible
                                          ? Colors.blue[900]
                                          : Colors.grey,
                                ),
                              ),
                            ),
                            title: Text(
                              guia['name'],
                              style: TextStyle(
                                color: disponible ? Colors.black : Colors.grey,
                                decoration:
                                    disponible
                                        ? null
                                        : TextDecoration.lineThrough,
                              ),
                            ),
                            subtitle: Text(
                              disponible
                                  ? "✅ Disponible"
                                  : "⛔ Ocupado en otro viaje",
                            ),
                            trailing:
                                disponible
                                    ? (state.selectedGuiaId == guia['id']
                                        ? const Icon(
                                          Icons.check_circle,
                                          color: Colors.blue,
                                        )
                                        : null)
                                    : null,
                            onTap: () {
                              context.read<TripCreationCubit>().setGuia(
                                guia['id'],
                              );
                              Navigator.pop(ctx);
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
          ),
    );
  }

  // --- WIDGETS AUXILIARES ---
  Widget _buildDateField(
    BuildContext context,
    String label,
    DateTime? val,
    Function(DateTime) onPick,
  ) {
    return InkWell(
      onTap: () async {
        final d = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime(2020),
          lastDate: DateTime(2030),
        );
        if (d != null) onPick(d);
      },
      child: InputDecorator(
        decoration: _inputDecoration(label, Icons.calendar_today),
        child: Text(
          val != null ? "${val.day}/${val.month}/${val.year}" : "Seleccionar",
          style: const TextStyle(fontSize: 14),
        ),
      ),
    );
  }

  Widget _buildTimeField(
    BuildContext context,
    String label,
    TimeOfDay? val,
    Function(TimeOfDay) onPick,
  ) {
    return InkWell(
      onTap: () async {
        final t = await showTimePicker(
          context: context,
          initialTime: TimeOfDay.now(),
        );
        if (t != null) onPick(t);
      },
      child: InputDecorator(
        decoration: _inputDecoration(label, Icons.access_time),
        child: Text(
          val != null ? val.format(context) : "--:--",
          style: const TextStyle(fontSize: 14),
        ),
      ),
    );
  }

  Widget _buildSelectedGuiaChip(TripCreationState state) {
    final guia = state.availableGuides.firstWhere(
      (g) => g['id'] == state.selectedGuiaId,
      orElse: () => state.availableGuides.first,
    );
    return Chip(
      avatar: CircleAvatar(
        backgroundColor: Colors.blue[800],
        child: Text(
          guia['name'][0],
          style: const TextStyle(fontSize: 10, color: Colors.white),
        ),
      ),
      label: Text(guia['name']),
      backgroundColor: Colors.blue[50],
      side: BorderSide.none,
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

  // --- MODAL DE MAPA ---
  void _showMapPicker(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (ctx) => Dialog(
            child: SizedBox(
              width: 600,
              height: 500,
              child: Column(
                children: [
                  Expanded(
                    child: FlutterMap(
                      options: MapOptions(
                        initialCenter: const LatLng(
                          19.4326,
                          -99.1332,
                        ), // CDMX default
                        initialZoom: 12,
                        onTap: (_, latlng) {
                          context.read<TripCreationCubit>().setLocation(latlng);
                          Navigator.pop(ctx);
                        },
                      ),
                      children: [
                        TileLayer(
                          urlTemplate:
                              'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          userAgentPackageName: 'com.othliani.app',
                        ),
                        const Center(
                          child: Icon(
                            Icons.location_searching,
                            color: Colors.blue,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(12),
                    color: Colors.white,
                    child: const Text(
                      "Toca en el mapa para establecer el punto de encuentro.",
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ),
    );
  }
}
