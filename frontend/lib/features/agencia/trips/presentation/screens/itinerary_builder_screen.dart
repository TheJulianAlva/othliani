import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/itinerary_builder/itinerary_builder_cubit.dart';
import '../../domain/entities/actividad_itinerario.dart'; // Para TipoActividad

// Configuración visual de las herramientas
final List<Map<String, dynamic>> _catalogoHerramientas = [
  {
    'tipo': TipoActividad.hospedaje,
    'icon': Icons.hotel_rounded,
    'color': Colors.purple,
    'label': 'Hospedaje',
  },
  {
    'tipo': TipoActividad.comida,
    'icon': Icons.restaurant_rounded,
    'color': Colors.orange,
    'label': 'Alimentos',
  },
  {
    'tipo': TipoActividad.traslado,
    'icon': Icons.directions_bus_rounded,
    'color': Colors.blue,
    'label': 'Traslado',
  },
  {
    'tipo': TipoActividad.cultura,
    'icon': Icons.museum_rounded,
    'color': Colors.brown,
    'label': 'Cultura / Museo',
  },
  {
    'tipo': TipoActividad.aventura,
    'icon': Icons.hiking_rounded,
    'color': Colors.green,
    'label': 'Aventura',
  },
  {
    'tipo': TipoActividad.tiempoLibre,
    'icon': Icons.beach_access_rounded,
    'color': Colors.teal,
    'label': 'Tiempo Libre',
  },
];

class ItineraryBuilderScreen extends StatelessWidget {
  final int duracionDias; // Viene de la pantalla anterior o del viaje
  final TimeOfDay? horaInicio; // ✨ Hora de inicio del viaje
  final TimeOfDay? horaFin; // ✨ Hora de fin del viaje

  const ItineraryBuilderScreen({
    super.key,
    this.duracionDias = 3,
    this.horaInicio,
    this.horaFin,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create:
          (_) =>
              ItineraryBuilderCubit()
                ..init(duracionDias, horaInicio: horaInicio, horaFin: horaFin),
      child: Scaffold(
        backgroundColor: Colors.grey[50], // Fondo neutro
        appBar: AppBar(
          title: const Text("Constructor de Itinerario"),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black87,
          elevation: 0.5,
          // Override del botón de atrás para usar Navigator.pop
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              // Usar Navigator.pop para regresar a la pantalla anterior
              // preservando el estado del formulario
              Navigator.of(context).pop();
            },
          ),
          actions: [
            // Botón para guardar todo
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.save),
                label: const Text("Guardar Viaje"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[800],
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
        body: BlocListener<ItineraryBuilderCubit, ItineraryBuilderState>(
          listener: (context, state) {
            // Mostrar Modal cuando hay un error
            if (state.errorMessage != null) {
              showDialog(
                context: context,
                builder:
                    (dialogContext) => AlertDialog(
                      icon: const Icon(
                        Icons.warning_amber_rounded,
                        color: Colors.orange,
                        size: 48,
                      ),
                      title: const Text('Tiempo Insuficiente'),
                      content: Text(
                        state.errorMessage!,
                        textAlign: TextAlign.center,
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(dialogContext).pop(),
                          child: const Text('Entendido'),
                        ),
                      ],
                    ),
              );
            }
          },
          child: const _BodyContent(),
        ),
      ),
    );
  }
}

class _BodyContent extends StatelessWidget {
  const _BodyContent();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // ---------------------------------------------
        // PANEL IZQUIERDO: CAJA DE HERRAMIENTAS (20%)
        // ---------------------------------------------
        Expanded(
          flex: 2,
          child: Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Bloques de Actividad",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 4),
                Text(
                  "Arrastra al itinerario",
                  style: TextStyle(color: Colors.grey[500], fontSize: 12),
                ),
                const SizedBox(height: 16),

                // Lista Generada Dinámicamente
                Expanded(
                  child: ListView.builder(
                    itemCount: _catalogoHerramientas.length,
                    itemBuilder: (context, index) {
                      final item = _catalogoHerramientas[index];
                      return _buildDraggableToolItem(
                        tipo: item['tipo'],
                        icon: item['icon'],
                        color: item['color'],
                        label: item['label'],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),

        // Separador vertical
        const VerticalDivider(width: 1, thickness: 1),

        // ---------------------------------------------
        // PANEL CENTRAL: LÍNEA DE TIEMPO (50%)
        // ---------------------------------------------
        Expanded(
          flex: 5,
          child: Column(
            children: [
              // Navegación de Días
              const _DaysTabBar(),

              // La Línea de Tiempo
              Expanded(child: const _TimelineDropZone()),
            ],
          ),
        ),

        // Separador vertical
        const VerticalDivider(width: 1, thickness: 1),

        // ---------------------------------------------
        // PANEL DERECHO: VISTA PREVIA Y MAPA (30%)
        // ---------------------------------------------
        Expanded(
          flex: 3,
          child: Column(
            children: [
              // Mapa
              Expanded(
                flex: 1,
                child: Container(
                  color: Colors.blue[50],
                  child: const Center(child: Text("Mapa Interactivo")),
                ),
              ),
              const Divider(height: 1),
              // Estadísticas / Eco Calc
              Expanded(
                flex: 1,
                child: Container(
                  color: Colors.white,
                  padding: const EdgeInsets.all(16),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ✨ NUEVO: Indicador de Tiempo Restante
                        const _TimeRemainingIndicator(),
                        const SizedBox(height: 20),
                        const Divider(),
                        const SizedBox(height: 10),

                        const Text(
                          "Resumen del Día",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 10),
                        _buildStatRow(
                          Icons.eco,
                          "Huella de Carbono",
                          "0 kg CO2",
                        ),
                        _buildStatRow(
                          Icons.schedule,
                          "Duración Total",
                          "0 hrs",
                        ),
                        _buildStatRow(
                          Icons.attach_money,
                          "Costo Estimado",
                          "\$0.00",
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Widget Draggable para herramientas
  Widget _buildDraggableToolItem({
    required TipoActividad tipo,
    required IconData icon,
    required Color color,
    required String label,
  }) {
    // El widget base que usaremos para el diseño
    final baseCard = Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
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
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
          ),
          const Icon(Icons.drag_indicator, color: Colors.grey, size: 16),
        ],
      ),
    );

    return Draggable<TipoActividad>(
      data: tipo, // 📦 EL DATO QUE VIAJA (Lo importante)
      // 1. Lo que se ve bajo el dedo mientras arrastras
      feedback: Material(
        color: Colors.transparent,
        child: Transform.scale(
          scale: 1.05, // Un poco más grande para efecto 3D
          child: SizedBox(
            width: 200, // Ancho fijo para que no se deforme
            child: Opacity(
              opacity: 0.9,
              child: baseCard, // Reutilizamos el diseño
            ),
          ),
        ),
      ),

      // 2. Lo que queda en la lista original (una sombra gris)
      childWhenDragging: Opacity(opacity: 0.3, child: baseCard),

      // 3. El estado normal en reposo
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12.0),
        child: baseCard,
      ),
    );
  }

  Widget _buildStatRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey),
          const SizedBox(width: 8),
          Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 13)),
          const Spacer(),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

// Widget auxiliar para las pestañas de días
class _DaysTabBar extends StatelessWidget {
  const _DaysTabBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      color: Colors.white,
      child: BlocBuilder<ItineraryBuilderCubit, ItineraryBuilderState>(
        builder: (context, state) {
          return ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: state.totalDias,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            itemBuilder: (context, index) {
              final isSelected = state.diaSeleccionadoIndex == index;
              return GestureDetector(
                onTap:
                    () =>
                        context.read<ItineraryBuilderCubit>().cambiarDia(index),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 8,
                  ),
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.blue[800] : Colors.grey[100],
                    borderRadius: BorderRadius.circular(20),
                    border:
                        isSelected
                            ? null
                            : Border.all(color: Colors.grey[300]!),
                  ),
                  child: Center(
                    child: Text(
                      "Día ${index + 1}",
                      style: TextStyle(
                        color: isSelected ? Colors.white : Colors.grey[700],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

// ============================================
// ZONA DE DROP: TIMELINE
// ============================================
class _TimelineDropZone extends StatelessWidget {
  const _TimelineDropZone();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ItineraryBuilderCubit, ItineraryBuilderState>(
      builder: (context, state) {
        final actividades = state.actividadesDelDiaActual;

        // EL TARGET QUE ACEPTA EL DROP
        return DragTarget<TipoActividad>(
          // 1. Validar si aceptamos (siempre true por ahora)
          onWillAcceptWithDetails: (details) => true,

          // 2. Cuando el usuario suelta el ítem
          onAcceptWithDetails: (details) {
            context.read<ItineraryBuilderCubit>().onActivityDropped(
              details.data,
            );
          },

          // 3. El constructor visual
          builder: (context, candidateData, rejectedData) {
            // Si están arrastrando algo encima, cambiamos el color de fondo
            final isHovering = candidateData.isNotEmpty;

            return Container(
              color:
                  isHovering
                      ? Colors.blue.withValues(alpha: 0.05)
                      : Colors.grey[50],
              child:
                  actividades.isEmpty
                      ? _buildEmptyState()
                      : ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: actividades.length,
                        separatorBuilder: (_, __) => _buildConnectorLine(),
                        itemBuilder: (context, index) {
                          return _ItineraryItemCard(
                            activity: actividades[index],
                          );
                        },
                      ),
            );
          },
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.add_circle_outline_outlined,
            size: 48,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            "Arrastra bloques aquí\npara construir el día",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[400]),
          ),
        ],
      ),
    );
  }

  Widget _buildConnectorLine() {
    return Container(
      margin: const EdgeInsets.only(left: 28), // Alineado con el timeline
      height: 20,
      width: 2,
      color: Colors.grey[300],
    );
  }
}

// ============================================
// TARJETA DE ACTIVIDAD
// ============================================
class _ItineraryItemCard extends StatelessWidget {
  final ActividadItinerario activity;

  const _ItineraryItemCard({required this.activity});

  @override
  Widget build(BuildContext context) {
    // Formato de hora simple
    final start =
        "${activity.horaInicio.hour}:${activity.horaInicio.minute.toString().padLeft(2, '0')}";
    final end =
        "${activity.horaFin.hour}:${activity.horaFin.minute.toString().padLeft(2, '0')}";

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Columna de Hora
        Column(
          children: [
            Text(
              start,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
            const SizedBox(height: 4),
            Text(end, style: TextStyle(color: Colors.grey[500], fontSize: 11)),
          ],
        ),
        const SizedBox(width: 12),

        // Línea vertical con punto (Timeline)
        Column(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: Colors.blue[800], // Podrías variar color según tipo
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
                boxShadow: const [
                  BoxShadow(color: Colors.black12, blurRadius: 2),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(width: 12),

        // Tarjeta de Contenido
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 2,
                  offset: Offset(0, 1),
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(
                  _getIconForType(activity.tipo),
                  color: Colors.grey[700],
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        activity.titulo,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      if (activity.descripcion.isNotEmpty)
                        Text(
                          activity.descripcion,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit, size: 18, color: Colors.grey),
                  onPressed: () {
                    // TODO: Abrir modal de edición (Fase 4)
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  IconData _getIconForType(TipoActividad tipo) {
    // Mapeo rápido para visualización
    switch (tipo) {
      case TipoActividad.hospedaje:
        return Icons.hotel;
      case TipoActividad.comida:
        return Icons.restaurant;
      case TipoActividad.traslado:
        return Icons.directions_bus;
      case TipoActividad.cultura:
        return Icons.museum;
      case TipoActividad.aventura:
        return Icons.hiking;
      case TipoActividad.tiempoLibre:
        return Icons.beach_access;
      default:
        return Icons.local_activity;
    }
  }
}

// ============================================
// INDICADOR DE TIEMPO RESTANTE
// ============================================
class _TimeRemainingIndicator extends StatelessWidget {
  const _TimeRemainingIndicator();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ItineraryBuilderCubit, ItineraryBuilderState>(
      builder: (context, state) {
        final tiempoRestante = state.tiempoRestanteHoy;
        final tiempoUsado = state.tiempoUsadoHoy;
        final tiempoTotal =
            state.horaFinDia.difference(state.horaInicioDia).inMinutes;

        // Convertir a horas y minutos
        final horasRestantes = tiempoRestante ~/ 60;
        final minutosRestantes = tiempoRestante % 60;
        final horasUsadas = tiempoUsado ~/ 60;
        final minutosUsados = tiempoUsado % 60;

        // Determinar color según tiempo restante
        Color indicatorColor;
        IconData indicatorIcon;
        String statusText;

        if (tiempoRestante > 240) {
          // > 4 horas
          indicatorColor = Colors.green;
          indicatorIcon = Icons.check_circle;
          statusText = "Tiempo disponible";
        } else if (tiempoRestante > 120) {
          // 2-4 horas
          indicatorColor = Colors.orange;
          indicatorIcon = Icons.warning;
          statusText = "Tiempo limitado";
        } else {
          // < 2 horas
          indicatorColor = Colors.red;
          indicatorIcon = Icons.error;
          statusText = "Poco tiempo";
        }

        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: indicatorColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: indicatorColor, width: 2),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(indicatorIcon, color: indicatorColor, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    statusText,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: indicatorColor,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Tiempo usado
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Usado:", style: TextStyle(fontSize: 12)),
                  Text(
                    "${horasUsadas}h ${minutosUsados}m",
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),

              // Tiempo restante
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Restante:", style: TextStyle(fontSize: 12)),
                  Text(
                    "${horasRestantes}h ${minutosRestantes}m",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: indicatorColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Barra de progreso
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: tiempoTotal > 0 ? tiempoUsado / tiempoTotal : 0,
                  backgroundColor: Colors.grey[200],
                  valueColor: AlwaysStoppedAnimation<Color>(indicatorColor),
                  minHeight: 6,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
