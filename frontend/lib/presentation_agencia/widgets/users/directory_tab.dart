import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/features/agencia/users/blocs/usuarios/usuarios_bloc.dart';
import 'package:frontend/features/agencia/users/domain/entities/turista.dart';

class DirectoryTab extends StatelessWidget {
  const DirectoryTab({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UsuariosBloc, UsuariosState>(
      builder: (context, state) {
        if (state is UsuariosLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is UsuariosLoaded) {
          final turistas = state.turistas;

          return Column(
            children: [
              // Resumen CRM
              Container(
                padding: const EdgeInsets.all(16),
                color: Colors.grey.shade50,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Base de Datos de Clientes (${turistas.length})',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0F4C75),
                      ),
                    ),
                    OutlinedButton.icon(
                      icon: const Icon(Icons.download, size: 16),
                      label: const Text('Exportar CSV'),
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
              ),

              // Toolbar de búsqueda
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: '🔍 Buscar turista...',
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
                  ],
                ),
              ),

              // Header
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
                    Expanded(flex: 3, child: _buildHeaderCell('NOMBRE')),
                    Expanded(flex: 2, child: _buildHeaderCell('ÚLTIMO VIAJE')),
                    Expanded(flex: 2, child: _buildHeaderCell('ESTATUS')),
                    Expanded(flex: 1, child: _buildHeaderCell('ACCIONES')),
                  ],
                ),
              ),

              // Lista de Turistas
              Expanded(
                child: ListView.separated(
                  padding: EdgeInsets.zero,
                  itemCount: turistas.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final turista = turistas[index];
                    return _TuristaRow(turista: turista);
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

class _TuristaRow extends StatelessWidget {
  final Turista turista;

  const _TuristaRow({required this.turista});

  @override
  Widget build(BuildContext context) {
    final initials =
        turista.nombre.split(' ').map((n) => n[0]).take(2).join().toUpperCase();

    Color avatarColor;
    switch (turista.id.hashCode % 5) {
      case 0:
        avatarColor = Colors.orange.shade100;
        break;
      case 1:
        avatarColor = Colors.pink.shade100;
        break;
      case 2:
        avatarColor = Colors.teal.shade100;
        break;
      case 3:
        avatarColor = Colors.amber.shade100;
        break;
      default:
        avatarColor = Colors.cyan.shade100;
    }

    return InkWell(
      onTap: () {},
      hoverColor: const Color(0xFFF5F5F5),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            // Nombre
            Expanded(
              flex: 3,
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: avatarColor,
                    radius: 16,
                    child: Text(
                      initials,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange.shade900,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    turista.nombre,
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF0F4C75),
                    ),
                  ),
                ],
              ),
            ),
            // Último viaje
            Expanded(
              flex: 2,
              child: Text(
                'Viaje #${turista.viajeId}',
                style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
              ),
            ),
            // Estatus
            Expanded(flex: 2, child: _buildStatusBadge(turista.status)),
            // Acciones
            Expanded(
              flex: 1,
              child: IconButton(
                icon: const Icon(Icons.history, size: 18, color: Colors.grey),
                onPressed: () {
                  // Aquí podrías abrir el historial de ese turista
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Historial de ${turista.nombre}'),
                      duration: const Duration(seconds: 1),
                    ),
                  );
                },
                tooltip: 'Ver Historial',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    IconData icon;

    switch (status) {
      case 'OK':
        color = Colors.green;
        icon = Icons.check_circle;
        break;
      case 'ADVERTENCIA':
        color = Colors.orange;
        icon = Icons.warning;
        break;
      case 'SOS':
        color = Colors.red;
        icon = Icons.error;
        break;
      case 'OFFLINE':
        color = Colors.grey;
        icon = Icons.signal_wifi_off;
        break;
      default:
        color = Colors.grey;
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
            status,
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
