import 'package:flutter/material.dart';
import '../../../features/agencia/users/domain/entities/turista.dart';
import '../../widgets/trip_detail/passenger_detail_modal.dart';

class TripPassengerList extends StatefulWidget {
  final List<Turista> turistas;
  final String estadoViaje; // 'PROGRAMADO', 'EN_CURSO', 'FINALIZADO'
  final bool isLive;
  final FocusNode? searchFocusNode;
  final bool highlightSearch;
  final String? focusAlertId; // ← NUEVO: ID de alerta para resaltar

  const TripPassengerList({
    super.key,
    required this.turistas,
    required this.estadoViaje,
    this.isLive = true,
    this.searchFocusNode,
    this.highlightSearch = false,
    this.focusAlertId, // ← NUEVO
  });

  @override
  State<TripPassengerList> createState() => _TripPassengerListState();
}

class _TripPassengerListState extends State<TripPassengerList> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Auto-scroll al turista enfocado si hay un alert_focus
    if (widget.focusAlertId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToFocusedItem();
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToFocusedItem() {
    // Buscar el índice del turista que coincide con el focusAlertId
    final index = widget.turistas.indexWhere(
      (t) => t.id == widget.focusAlertId,
    );

    if (index != -1 && _scrollController.hasClients) {
      // Altura estimada de cada item (ajustar según diseño real)
      const double itemHeight = 80.0;
      final double targetPosition = index * itemHeight;

      _scrollController.animateTo(
        targetPosition,
        duration: const Duration(milliseconds: 800),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          // Header Search
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: Color(0xFFEEEEEE))),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  widget.isLive
                      ? 'NÓMINA (PAX: ${widget.turistas.length})'
                      : 'LISTA DE PARTICIPANTES (${widget.turistas.length} personas)',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  focusNode: widget.searchFocusNode,
                  decoration: InputDecoration(
                    hintText: 'Buscar Turista...',
                    prefixIcon: Icon(
                      Icons.search,
                      size: 18,
                      color: widget.highlightSearch ? Colors.blue : Colors.grey,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 0,
                      horizontal: 12,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                      borderSide: const BorderSide(
                        color: Colors.blue,
                        width: 2,
                      ),
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                  ),
                ),
              ],
            ),
          ),

          // List
          Expanded(
            child: ListView.builder(
              controller: _scrollController, // ← Conectar ScrollController
              padding: EdgeInsets.zero,
              itemCount: widget.turistas.length,
              itemBuilder: (context, index) {
                final turista = widget.turistas[index];
                final bool isFocused =
                    turista.id == widget.focusAlertId; // ← Detectar foco

                return _buildPaxItem(
                  context: context,
                  turista: turista,
                  isLive: widget.isLive,
                  isFocused: isFocused, // ← Pasar estado de foco
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  PaxStatus _mapEstadoToStatus(String status) {
    switch (status.toUpperCase()) {
      case 'SOS':
        return PaxStatus.critical;
      case 'ADVERTENCIA':
      case 'ALERTA':
        return PaxStatus.warning;
      case 'OK':
        return PaxStatus.ok;
      case 'OFFLINE':
        return PaxStatus.offline;
      default:
        return PaxStatus.ok;
    }
  }

  Widget _buildPaxItem({
    required BuildContext context,
    required Turista turista,
    required bool isLive,
    required bool isFocused, // ← NUEVO: Indica si este item debe resaltarse
  }) {
    final status = _mapEstadoToStatus(turista.status);
    Color statusColor;
    IconData statusIcon;

    switch (status) {
      case PaxStatus.critical:
        statusColor = Colors.red;
        statusIcon = Icons.warning_rounded;
        break;
      case PaxStatus.warning:
        statusColor = Colors.amber.shade700;
        statusIcon = Icons.info_outline;
        break;
      case PaxStatus.ok:
        statusColor = Colors.green;
        statusIcon = Icons.check_circle_outline;
        break;
      case PaxStatus.offline:
        statusColor = Colors.grey;
        statusIcon = Icons.cloud_off;
        break;
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        color: isFocused ? Colors.orange.withValues(alpha: 0.15) : Colors.white,
        border:
            isFocused
                ? Border.all(color: Colors.orange, width: 3)
                : const Border(bottom: BorderSide(color: Color(0xFFF5F5F5))),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            showDialog(
              context: context,
              builder:
                  (context) => PassengerDetailModal(
                    turista: turista,
                    estadoViaje: widget.estadoViaje, // ← Corregido
                  ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Status Icon
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Icon(statusIcon, color: statusColor, size: 18),
                ),
                const SizedBox(width: 12),

                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              turista.nombre,
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                                color:
                                    status == PaxStatus.offline
                                        ? Colors.grey
                                        : Colors.black87,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (status == PaxStatus.critical)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                'SOS!',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      if (status == PaxStatus.offline)
                        const Text(
                          'Sin conexión',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        )
                      else
                        Row(
                          children: [
                            Icon(
                              Icons.location_on,
                              size: 12,
                              color:
                                  turista.enCampo ? Colors.green : Colors.grey,
                            ),
                            Text(
                              turista.enCampo ? ' En Campo' : ' Fuera de Campo',
                              style: TextStyle(
                                fontSize: 12,
                                color:
                                    turista.enCampo
                                        ? Colors.green
                                        : Colors.grey.shade700,
                              ),
                            ),
                          ],
                        ),

                      const SizedBox(height: 8),
                      // Telemetry
                      if (status != PaxStatus.offline)
                        Row(
                          children: [
                            Icon(
                              Icons.battery_std,
                              size: 14,
                              color:
                                  turista.bateria < 0.2
                                      ? Colors.red
                                      : Colors.green,
                            ),
                            Text(
                              '${(turista.bateria * 100).toInt()}%',
                              style: const TextStyle(
                                fontSize: 11,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Icon(
                              Icons.signal_cellular_alt,
                              size: 14,
                              color: Colors.grey,
                            ),
                          ],
                        ),

                      // Actions if Critical
                      if (status == PaxStatus.critical) ...[
                        const SizedBox(height: 8),
                        SizedBox(
                          height: 28,
                          child: ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red.shade50,
                              elevation: 0,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                              ),
                            ),
                            child: const Text(
                              'ACCIONES DE PÁNICO',
                              style: TextStyle(color: Colors.red, fontSize: 11),
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

enum PaxStatus { critical, warning, ok, offline }
