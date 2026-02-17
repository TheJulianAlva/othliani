import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:frontend/features/agencia/trips/blocs/detalle_viaje/detalle_viaje_bloc.dart';
import '../../widgets/trips/trip_detail/trip_control_panel.dart';
import '../../widgets/trips/trip_detail/trip_map_viewer.dart';
import '../../widgets/trips/trip_detail/trip_passenger_list.dart';
import 'package:frontend/features/agencia/trips/domain/entities/viaje.dart';
import 'package:frontend/features/agencia/users/domain/entities/turista.dart';

class TripDetailScreen extends StatefulWidget {
  final String viajeId;
  final String? highlightSection;
  final String? returnTo; // <--- Para navegación contextual
  final String? alertFocus; // <--- NUEVO: ID de alerta para resaltar turista

  const TripDetailScreen({
    super.key,
    required this.viajeId,
    this.highlightSection,
    this.returnTo,
    this.alertFocus, // <--- Recibimos el parámetro
  });

  @override
  State<TripDetailScreen> createState() => _TripDetailScreenState();
}

class _TripDetailScreenState extends State<TripDetailScreen> {
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    // Load trip details and tourists
    context.read<DetalleViajeBloc>().add(
      LoadDetalleViajeEvent(id: widget.viajeId),
    );

    // Auto-focus search if highlighting turistas section
    if (widget.highlightSection == 'turistas') {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _searchFocusNode.requestFocus();
      });
    }
  }

  @override
  void didUpdateWidget(TripDetailScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Si el viajeId cambió, recargar los datos
    if (oldWidget.viajeId != widget.viajeId) {
      context.read<DetalleViajeBloc>().add(
        LoadDetalleViajeEvent(id: widget.viajeId),
      );
    }
  }

  @override
  void dispose() {
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F8),
      appBar: _buildAppBar(context),
      body: BlocBuilder<DetalleViajeBloc, DetalleViajeState>(
        builder: (context, state) {
          if (state is DetalleViajeLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is DetalleViajeLoaded) {
            return _buildDetailView(state.viaje, state.turistas);
          } else if (state is DetalleViajeError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(state.message, style: const TextStyle(fontSize: 16)),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      context.read<DetalleViajeBloc>().add(
                        LoadDetalleViajeEvent(id: widget.viajeId),
                      );
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }
          return const Center(
            child: Text('No se encontró información del viaje'),
          );
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.black87),
        onPressed: () {
          // NAVEGACIÓN CONTEXTUAL INTELIGENTE
          if (widget.returnTo == 'dashboard') {
            // Si vino del dashboard, forzamos la vuelta allá
            context.go('/dashboard');
          } else {
            // Comportamiento normal (volver a la lista de viajes)
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/viajes');
            }
          }
        },
      ),
      title: BlocBuilder<DetalleViajeBloc, DetalleViajeState>(
        builder: (context, state) {
          if (state is DetalleViajeLoaded) {
            return Row(
              children: [
                Flexible(
                  child: Text(
                    'VIAJE #${widget.viajeId}: ${state.viaje.destino.toUpperCase()}',
                    style: const TextStyle(
                      color: Color(0xFF0F4C75),
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 16),
                _buildStatusBadge(state.viaje.estado),
                const SizedBox(width: 16),
                const Icon(Icons.people, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  '${state.viaje.turistas} pax',
                  style: const TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
              ],
            );
          }
          return Text(
            'VIAJE #${widget.viajeId}',
            style: const TextStyle(
              color: Color(0xFF0F4C75),
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          );
        },
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16.0),
          child: IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.grey),
            onPressed: () {},
          ),
        ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1.0),
        child: Container(color: Colors.grey.shade200, height: 1.0),
      ),
    );
  }

  Widget _buildStatusBadge(String estado) {
    Color color;
    String text;

    switch (estado) {
      case 'EN_CURSO':
        color = Colors.green;
        text = 'EN CURSO';
        break;
      case 'PROGRAMADO':
        color = Colors.blue;
        text = 'PROGRAMADO';
        break;
      case 'FINALIZADO':
        color = Colors.grey;
        text = 'FINALIZADO';
        break;
      default:
        color = Colors.orange;
        text = estado;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildDetailView(Viaje viaje, List<Turista> turistas) {
    // Adaptive layout based on trip status
    if (viaje.estado == 'EN_CURSO') {
      return _buildLiveCockpitMode(viaje, turistas);
    } else {
      return _buildReportMode(viaje, turistas);
    }
  }

  // MODO 1: LIVE COCKPIT (Viajes EN_CURSO)
  Widget _buildLiveCockpitMode(Viaje viaje, List<Turista> turistas) {
    final bool highlightTuristas = widget.highlightSection == 'turistas';

    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // 1. Control Panel (Left - 20%)
        Expanded(
          flex: 20,
          child: TripControlPanel(
            viaje: viaje,
            guideHasAlert:
                viaje.id == '205', // Mock logic: Viaje 205 tiene alerta de Guía
          ),
        ),

        // Divider
        VerticalDivider(width: 1, color: Colors.grey.shade300),

        // 2. Map Viewer (Center - 55%)
        Expanded(
          flex: 55,
          child: TripMapViewer(viaje: viaje, turistas: turistas),
        ),

        // Divider
        VerticalDivider(width: 1, color: Colors.grey.shade300),

        // 3. Passenger List (Right - 25%) with highlight animation
        Expanded(
          flex: 25,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeOut,
            decoration: BoxDecoration(
              color:
                  highlightTuristas
                      ? Colors.blue.withValues(alpha: 0.05)
                      : Colors.white,
              border: Border(
                top:
                    highlightTuristas
                        ? const BorderSide(color: Colors.blue, width: 2)
                        : BorderSide.none,
                bottom:
                    highlightTuristas
                        ? const BorderSide(color: Colors.blue, width: 2)
                        : BorderSide.none,
                right:
                    highlightTuristas
                        ? const BorderSide(color: Colors.blue, width: 2)
                        : BorderSide.none,
              ),
            ),
            child: TripPassengerList(
              turistas: turistas,
              estadoViaje: viaje.estado,
              isLive: true,
              searchFocusNode: _searchFocusNode,
              highlightSearch: highlightTuristas,
              focusAlertId:
                  widget.alertFocus, // ← Pasar ID de alerta para resaltar
            ),
          ),
        ),
      ],
    );
  }

  // MODO 2: REPORTE / EXPEDIENTE (Viajes FINALIZADO/PROGRAMADO)
  Widget _buildReportMode(Viaje viaje, List<Turista> turistas) {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Header Informativo (Sin Mapa)
          _buildHeaderReporte(viaje, turistas.length),

          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 24),

          // 2. Título de Sección
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Lista de Participantes (Manifiesto)",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              // Botones administrativos
              OutlinedButton.icon(
                icon: const Icon(Icons.download, size: 18),
                label: const Text("Exportar Excel"),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('📊 Exportación simulada'),
                      backgroundColor: Colors.green,
                    ),
                  );
                },
              ),
            ],
          ),

          const SizedBox(height: 16),

          // 3. La Lista ocupa TODA la pantalla (Más columnas, más detalle)
          Expanded(
            child: TripPassengerList(
              turistas: turistas,
              estadoViaje: viaje.estado,
              isLive: false,
              searchFocusNode: _searchFocusNode,
              highlightSearch: false,
              focusAlertId:
                  widget.alertFocus, // ← Pasar ID de alerta para resaltar
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderReporte(Viaje viaje, int totalPax) {
    return Row(
      children: [
        _infoBox(
          "Estado",
          viaje.estado,
          viaje.estado == 'FINALIZADO' ? Colors.grey : Colors.blue,
        ),
        const SizedBox(width: 24),
        _infoBox("Total Pasajeros", "$totalPax Pax", Colors.black),
        const SizedBox(width: 24),
        _infoBox("Destino", viaje.destino, Colors.black),
        const Spacer(),
      ],
    );
  }

  Widget _infoBox(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
