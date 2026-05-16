import 'package:flutter/material.dart';
import 'package:frontend/features/guia/home/presentation/blocs/personal_home_bloc/personal_home_cubit.dart';

class EmptyStateWidget extends StatelessWidget {
  const EmptyStateWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.explore_off_rounded, size: 80, color: Colors.grey),
          SizedBox(height: 20),
          Text(
            'No tienes expediciones activas',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }
}

class HeaderBackgroundWidget extends StatelessWidget {
  const HeaderBackgroundWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF00AE00), Color(0xFFBAF7D4)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
    );
  }
}

class TripProgressCardWidget extends StatefulWidget {
  final PersonalHomeLoaded state;

  const TripProgressCardWidget({super.key, required this.state});

  @override
  State<TripProgressCardWidget> createState() => _TripProgressCardWidgetState();
}

class _TripProgressCardWidgetState extends State<TripProgressCardWidget> {
  bool _isExpanded = true;

  @override
  Widget build(BuildContext context) {
    final state = widget.state;
    final totalActividades = state.data.actividades.length;
    final completadas = state.data.actividades.where((a) => a.completada).length;
    final double progreso = totalActividades > 0 ? (completadas / totalActividades) : 0.0;
    final destino = state.data.nombreViaje;
    final turistas = state.data.participantes;

    return GestureDetector(
      onTap: () => setState(() => _isExpanded = !_isExpanded),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    destino,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Colors.black87,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.people_outline, size: 14, color: Colors.blue.shade700),
                      const SizedBox(width: 4),
                      Text(
                        '$turistas',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: Colors.blue.shade700,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Icon(
                  _isExpanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                  color: Colors.grey.shade400,
                  size: 20,
                ),
              ],
            ),
            if (_isExpanded) ...[
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '$completadas / $totalActividades actividades',
                    style: TextStyle(
                      color: Colors.grey.shade700,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '${(progreso * 100).toInt()}%',
                    style: const TextStyle(
                      color: Color(0xFF00AE00),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progreso,
                  backgroundColor: Colors.grey.shade200,
                  color: const Color(0xFF00AE00),
                  minHeight: 6,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class StatusHeaderWidget extends StatelessWidget {
  final PersonalHomeLoaded state;

  const StatusHeaderWidget({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    if (state.data.actividades.isEmpty) {
      return const SizedBox.shrink();
    }

    final actividadesPendientes =
        state.data.actividades.where((a) => !a.completada).toList();

    if (actividadesPendientes.isEmpty) {
      return const SizedBox.shrink();
    }

    final actividadActual = actividadesPendientes.first;
    final ahora = DateTime.now();
    final inicioHoraMinuto =
        (actividadActual.horaInicio.hour * 60) +
        actividadActual.horaInicio.minute;
    final finHoraMinuto =
        (actividadActual.horaFin.hour * 60) + actividadActual.horaFin.minute;
    final ahoraHoraMinuto = (ahora.hour * 60) + ahora.minute;

    final esEnCurso =
        ahoraHoraMinuto >= inicioHoraMinuto && ahoraHoraMinuto <= finHoraMinuto;
    final colorPrincipal = esEnCurso ? const Color(0xFF00AE00) : Colors.orange;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: colorPrincipal.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorPrincipal.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          CircleAvatar(backgroundColor: colorPrincipal, radius: 4),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              '${esEnCurso ? 'Actividad en curso:' : 'Próxima actividad:'} ${actividadActual.nombre}',
              style: TextStyle(
                color:
                    esEnCurso
                        ? const Color(0xFF006400)
                        : Colors.orange.shade900,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
