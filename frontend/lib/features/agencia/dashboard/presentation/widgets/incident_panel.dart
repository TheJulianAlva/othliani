import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:frontend/features/agencia/shared/domain/entities/alerta.dart';
import 'package:frontend/features/agencia/trips/domain/entities/viaje.dart';

class IncidentPanel extends StatelessWidget {
  final List<Viaje>? viajes;
  final List<Alerta>? incidentes;

  const IncidentPanel({super.key, this.viajes, this.incidentes});

  @override
  Widget build(BuildContext context) {
    final trips = viajes ?? [];
    final alerts = incidentes ?? [];

    // Priorizar viajes con alertas primero, luego en curso, luego otros.
    final sortedTrips = List<Viaje>.from(trips)..sort((a, b) {
      if (a.alertasActivas > 0 && b.alertasActivas == 0) return -1;
      if (b.alertasActivas > 0 && a.alertasActivas == 0) return 1;
      if (a.estado == 'EN_CURSO' && b.estado != 'EN_CURSO') return -1;
      if (b.estado == 'EN_CURSO' && a.estado != 'EN_CURSO') return 1;
      return 0;
    });

    final enCursoCount = trips.where((v) => v.estado == 'EN_CURSO').length;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // CABECERA
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      const Icon(Icons.list_alt_rounded, size: 20, color: Color(0xFF1B3B6F)),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          "Estado de Operaciones Activas",
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF1B3B6F),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8EEFF),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    "$enCursoCount EN CURSO",
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1B3B6F),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: Colors.grey.shade100),

          // LISTA DE VIAJES
          Expanded(
            child: sortedTrips.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.directions_bus_filled_outlined, size: 40, color: Colors.grey.shade300),
                        const SizedBox(height: 8),
                        const Text("No hay viajes para mostrar", style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: sortedTrips.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final viaje = sortedTrips[index];
                      return _buildTripCard(context, viaje, alerts);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildTripCard(BuildContext context, Viaje viaje, List<Alerta> alerts) {
    // Determinar estilo en base al estado y alertas
    final bool hasAlerts = viaje.alertasActivas > 0;
    
    // Obtener alertas de este viaje
    final tripAlerts = alerts.where((a) => a.viajeId == viaje.id).toList();
    final topAlert = tripAlerts.isNotEmpty ? tripAlerts.first : null;

    Color borderColor;
    Color dotColor;
    String statusText;
    Color statusTextColor = Colors.grey.shade700;
    Widget? extraIcon;

    if (hasAlerts) {
      borderColor = const Color(0xFFE53935); // Red
      dotColor = const Color(0xFFE53935);
      statusText = topAlert?.mensaje ?? "Alerta Activa";
      statusTextColor = const Color(0xFFE53935);
      extraIcon = const Icon(Icons.warning_rounded, color: Color(0xFFE53935), size: 14);
    } else if (viaje.estado == 'EN_CURSO') {
      borderColor = const Color(0xFF4CAF50); // Green
      dotColor = const Color(0xFF4CAF50);
      statusText = "Actividad en curso";
      statusTextColor = const Color(0xFF2E7D32);
    } else {
      borderColor = const Color(0xFFFF9800); // Orange / Pending
      dotColor = const Color(0xFFFF9800);
      statusText = "En preparación";
      statusTextColor = const Color(0xFFE65100);
    }

    return InkWell(
      onTap: () {
        final focusParam = topAlert?.turistaId != null
            ? '?alert_focus=${topAlert!.turistaId}&return_to=dashboard'
            : '?return_to=dashboard';
        context.push('/viajes/${viaje.id}$focusParam');
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: borderColor.withValues(alpha: 0.5), width: 1.5),
          boxShadow: [
            BoxShadow(
              color: borderColor.withValues(alpha: 0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Row 1: Destino y Dot
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    viaje.destino,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                      color: Color(0xFF2C3E50),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: dotColor,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            
            // Row 2: Guía y Estatus
            Row(
              children: [
                Icon(Icons.badge_outlined, size: 14, color: Colors.grey.shade500),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    viaje.guiaNombre,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  "  |  ",
                  style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
                ),
                if (extraIcon != null) ...[
                  extraIcon,
                  const SizedBox(width: 4),
                ],
                Expanded(
                  child: Text(
                    statusText,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: statusTextColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            
            // Row 3 (Optional): Hora o info extra
            if (!hasAlerts) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.schedule, size: 12, color: Colors.grey.shade500),
                    const SizedBox(width: 4),
                    Text(
                      viaje.horaInicio,
                      style: TextStyle(fontSize: 11, color: Colors.grey.shade600, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }
}
