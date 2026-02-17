import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/features/agencia/users/presentation/blocs/usuarios/usuarios_bloc.dart';
import 'package:frontend/features/agencia/users/domain/entities/guia.dart';
import 'package:frontend/features/agencia/trips/presentation/widgets/common/trip_status_chip.dart';

class GuidesTab extends StatelessWidget {
  const GuidesTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UsuariosBloc, UsuariosState>(
      builder: (context, state) {
        if (state is UsuariosLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is UsuariosLoaded) {
          final guias = state.guias;

          return Column(
            children: [
              // License / Subscription Status Bar
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                color: Colors.blue.shade50,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'ESTADO DE TU SUSCRIPCIÓN B2B',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F4C75),
                        letterSpacing: 1.1,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(4),
                                child: LinearProgressIndicator(
                                  value: guias.length / 15,
                                  minHeight: 10,
                                  backgroundColor: Colors.white,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.green,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Estás usando ${guias.length} de 15 licencias de Guía.',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF0F4C75),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 24),
                        ElevatedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.upgrade, size: 16),
                          label: const Text('ADQUIRIR MÁS'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green.shade600,
                            foregroundColor: Colors.white,
                            textStyle: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Toolbar
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: '🔍 Buscar Guía...',
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                          ),
                          prefixIcon: const Icon(
                            Icons.search,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Chip(
                      label: Text('${guias.length} Guías Totales'),
                      backgroundColor: Colors.blue.shade50,
                    ),
                  ],
                ),
              ),

              // Sticky Header
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  border: Border(
                    bottom: BorderSide(color: Colors.grey.shade300),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(flex: 3, child: _buildHeaderCell('EMPLEADO')),
                    Expanded(flex: 2, child: _buildHeaderCell('ESTADO')),
                    Expanded(
                      flex: 2,
                      child: _buildHeaderCell('VIAJES ASIGNADOS'),
                    ),
                    Expanded(flex: 2, child: _buildHeaderCell('ACCIONES')),
                  ],
                ),
              ),

              // List Content (Scrollable)
              Expanded(
                child: ListView.separated(
                  padding: EdgeInsets.zero,
                  itemCount: guias.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final guia = guias[index];
                    return _GuideRow(guia: guia);
                  },
                ),
              ),
            ],
          );
        } else if (state is UsuariosError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text(state.message),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    context.read<UsuariosBloc>().add(LoadUsuariosEvent());
                  },
                  child: const Text('Reintentar'),
                ),
              ],
            ),
          );
        }
        return const Center(child: Text('No hay datos disponibles'));
      },
    );
  }

  Widget _buildHeaderCell(String text) {
    return Text(
      text,
      style: TextStyle(
        color: Colors.grey.shade600,
        fontWeight: FontWeight.bold,
        fontSize: 12,
      ),
    );
  }
}

class _GuideRow extends StatelessWidget {
  final Guia guia;

  const _GuideRow({required this.guia});

  @override
  Widget build(BuildContext context) {
    final initials =
        guia.nombre.split(' ').map((n) => n[0]).take(2).join().toUpperCase();

    Color avatarColor;
    switch (guia.id.hashCode % 5) {
      case 0:
        avatarColor = Colors.blue.shade100;
        break;
      case 1:
        avatarColor = Colors.purple.shade100;
        break;
      case 2:
        avatarColor = Colors.orange.shade100;
        break;
      case 3:
        avatarColor = Colors.green.shade100;
        break;
      default:
        avatarColor = Colors.pink.shade100;
    }

    return InkWell(
      onTap: () {},
      hoverColor: const Color(0xFFF5F5F5),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            // Empleado
            Expanded(
              flex: 3,
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: avatarColor,
                    radius: 16,
                    child: Text(
                      initials,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F4C75),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    guia.nombre,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0F4C75),
                    ),
                  ),
                ],
              ),
            ),
            // Estado
            Expanded(flex: 2, child: _buildStatusBadge(guia.status)),
            // Viajes Asignados
            Expanded(flex: 2, child: _buildTripAssignmentInfo(guia)),
            // Acciones
            Expanded(
              flex: 2,
              child: Row(
                children: [
                  TextButton(
                    onPressed: () {},
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 8,
                      ),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Text(
                      'Ver Perfil',
                      style: TextStyle(fontSize: 11),
                    ),
                  ),
                  PopupMenuButton(
                    itemBuilder:
                        (_) => [
                          const PopupMenuItem(
                            value: 'editar',
                            child: Text("Editar Permisos"),
                          ),
                          const PopupMenuItem(
                            value: 'desactivar',
                            child: Text("Desactivar"),
                          ),
                        ],
                    icon: const Icon(
                      Icons.more_vert,
                      size: 18,
                      color: Colors.grey,
                    ),
                    padding: EdgeInsets.zero,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTripAssignmentInfo(Guia guia) {
    if (guia.viajesAsignados == 0) {
      return Text(
        '0 viajes',
        style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
      );
    }

    // Inferir estado del viaje desde el status del guía
    String estadoViaje;
    if (guia.status == 'EN_RUTA') {
      estadoViaje = 'EN_CURSO';
    } else if (guia.status == 'ONLINE' && guia.viajesAsignados > 0) {
      estadoViaje = 'PROGRAMADO';
    } else {
      estadoViaje = 'FINALIZADO';
    }

    return Row(
      children: [
        Text(
          '${guia.viajesAsignados} ',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade800,
          ),
        ),
        TripStatusChip(estado: estadoViaje, compact: true),
      ],
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    String text;
    IconData icon;

    switch (status) {
      case 'ONLINE':
        color = Colors.green;
        text = 'ONLINE';
        icon = Icons.check_circle;
        break;
      case 'EN_RUTA':
        color = Colors.blue;
        text = 'EN RUTA';
        icon = Icons.navigation;
        break;
      default:
        color = Colors.grey;
        text = 'OFFLINE';
        icon = Icons.circle;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
