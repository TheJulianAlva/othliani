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

  // --- PASO 1: DATOS GENERALES ROBUSTOS ---
  Widget _buildGeneralInfoStep(BuildContext context, TripCreationState state) {
    final cubit = context.read<TripCreationCubit>();

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Información Operativa",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          // 1. NOMBRE DEL VIAJE
          TextFormField(
            initialValue: state.destino,
            decoration: const InputDecoration(
              labelText: 'Nombre del Viaje / Destino',
              hintText: 'Ej: Excursión a Teotihuacán',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.label_outline),
            ),
            onChanged:
                (v) => cubit.updateBasicInfo(
                  v,
                  state.fechaInicio ?? DateTime.now(),
                  state.fechaFin ?? DateTime.now(),
                ),
          ),
          const SizedBox(height: 24),

          // 2. UBICACIÓN EXACTA (MAPA + COORDENADAS)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  children: [
                    TextFormField(
                      decoration: const InputDecoration(
                        labelText: 'Coordenadas (Lat, Lng)',
                        hintText: '19.4326, -99.1332',
                        prefixIcon: Icon(Icons.pin_drop),
                        border: OutlineInputBorder(),
                      ),
                      // Si hay ubicación seleccionada, mostramos el texto
                      controller:
                          state.location != null
                              ? TextEditingController(
                                text:
                                    "${state.location!.latitude.toStringAsFixed(4)}, ${state.location!.longitude.toStringAsFixed(4)}",
                              )
                              : null,
                    ),
                    const SizedBox(height: 8),
                    OutlinedButton.icon(
                      icon: const Icon(Icons.map),
                      label: const Text("Seleccionar en Mapa"),
                      onPressed:
                          () => _showMapPicker(
                            context,
                          ), // Abre un modal con mapa grande
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              // PREVIEW DEL MAPA (Pequeño)
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.grey[200],
                ),
                child:
                    state.location == null
                        ? const Center(
                          child: Icon(Icons.map, color: Colors.grey),
                        )
                        : ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: FlutterMap(
                            options: MapOptions(
                              initialCenter: state.location!,
                              initialZoom: 13,
                              interactionOptions: const InteractionOptions(
                                flags: InteractiveFlag.none,
                              ), // Estático
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

          const Divider(height: 32),

          // 3. ASIGNACIÓN DE GUÍA (Selector Realista)
          DropdownButtonFormField<String>(
            initialValue: state.selectedGuiaId,
            decoration: const InputDecoration(
              labelText: 'Guía Responsable',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.badge),
            ),
            items:
                state.availableGuides.map((g) {
                  return DropdownMenuItem(
                    value: g['id'] as String,
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 12,
                          backgroundColor: Colors.blue[100],
                          child: Text(
                            (g['name'] as String)[0],
                            style: const TextStyle(fontSize: 10),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(g['name']),
                        const SizedBox(width: 8),
                        // Badge de disponibilidad
                        if (g['status'] == 'Ocupado')
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.orange[100],
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              "OCUPADO",
                              style: TextStyle(
                                fontSize: 10,
                                color: Colors.orange,
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                }).toList(),
            onChanged: (v) => cubit.setGuia(v),
          ),

          const Divider(height: 32),

          // 4. LOGÍSTICA DE TIEMPO (Switch Corto/Largo)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "¿Es un viaje de varios días?",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Switch(
                value: state.isMultiDay,
                onChanged: (val) => cubit.toggleMultiDay(val),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // SELECTORES DE FECHA (Lógica Dinámica)
          Row(
            children: [
              // FECHA INICIO
              Expanded(
                child: _buildDatePickerField(
                  context: context,
                  label: state.isMultiDay ? "Fecha Inicio" : "Fecha del Viaje",
                  selectedDate: state.fechaInicio,
                  onPicked: (d) {
                    // Lógica simple: Si es 1 día, Inicio y Fin son el mismo día
                    if (!state.isMultiDay) {
                      cubit.setDates(start: d, end: d);
                    } else {
                      cubit.setDates(start: d, end: state.fechaFin);
                    }
                  },
                ),
              ),
              const SizedBox(width: 16),
              // FECHA FIN (Solo visible si es Multidía) o HORA FIN
              Expanded(
                child:
                    state.isMultiDay
                        ? _buildDatePickerField(
                          context: context,
                          label: "Fecha Fin",
                          selectedDate: state.fechaFin,
                          onPicked:
                              (d) => cubit.setDates(
                                start: state.fechaInicio,
                                end: d,
                              ),
                        )
                        : _buildTimePickerField(
                          context,
                          "Hora Estimada Fin",
                        ), // Implementa un TimePicker simple
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- WIDGETS AUXILIARES ---

  // Modal con Mapa Grande para seleccionar punto
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
                          Navigator.pop(ctx); // Cierra al tocar
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
                        ), // Mira central
                      ],
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      "Toca en el mapa para seleccionar el punto de encuentro",
                    ),
                  ),
                ],
              ),
            ),
          ),
    );
  }

  Widget _buildDatePickerField({
    required BuildContext context,
    required String label,
    DateTime? selectedDate,
    required Function(DateTime) onPicked,
  }) {
    return InkWell(
      onTap: () async {
        final d = await showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime.now(),
          lastDate: DateTime(2030),
        );
        if (d != null) onPicked(d);
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          prefixIcon: const Icon(Icons.calendar_today),
        ),
        child: Text(
          selectedDate != null
              ? "${selectedDate.day}/${selectedDate.month}/${selectedDate.year}"
              : "Seleccionar",
        ),
      ),
    );
  }

  Widget _buildTimePickerField(BuildContext context, String label) {
    return InkWell(
      onTap: () async {
        // Implementa showTimePicker aquí
      },
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          prefixIcon: const Icon(Icons.access_time),
        ),
        child: const Text("18:00 (Ejemplo)"),
      ),
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
            esPrivado
                ? Icons.visibility_off
                : Icons.security, // [cite: 6] Iconografía de privacidad
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
}
