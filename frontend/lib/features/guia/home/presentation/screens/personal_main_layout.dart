import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/features/guia/home/presentation/blocs/personal_home_bloc/personal_home_cubit.dart';
import 'package:frontend/features/guia/home/presentation/blocs/eco_mode/eco_mode_cubit.dart';
import 'package:frontend/features/guia/home/presentation/shared_widgets/weather_widget.dart';
import 'package:frontend/features/guia/home/presentation/shared_widgets/map_preview_card.dart';
import 'package:frontend/features/guia/home/presentation/shared_widgets/activity_list_with_filter.dart';
import 'package:frontend/features/agencia/users/domain/entities/turista.dart';
import 'package:frontend/features/guia/home/presentation/screens/gestion_turistas_screen.dart';

class PersonalMainLayout extends StatefulWidget {
  final String nombreGuia;
  const PersonalMainLayout({super.key, required this.nombreGuia});

  @override
  State<PersonalMainLayout> createState() => _PersonalMainLayoutState();
}

class _PersonalMainLayoutState extends State<PersonalMainLayout> {
  bool _mostrandoTuristas = false;
  List<Turista> _turistas = [];

  @override
  void initState() {
    super.initState();
    context.read<PersonalHomeCubit>().cargarDatos(widget.nombreGuia);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      transitionBuilder: (child, animation) {
        final isEntering = child.key == const ValueKey('turistas')
            ? _mostrandoTuristas
            : !_mostrandoTuristas;
        final offset = isEntering ? const Offset(1.0, 0.0) : const Offset(-1.0, 0.0);
        return SlideTransition(
          position: Tween<Offset>(begin: offset, end: Offset.zero)
              .animate(animation),
          child: child,
        );
      },
      child: _mostrandoTuristas
          ? GestionTuristasScreen(
              key: const ValueKey('turistas'),
              turistas: _turistas,
              onVolver: () => setState(() => _mostrandoTuristas = false),
            )
          : _buildHomeScaffold(),
    );
  }

  Widget _buildHomeScaffold() {
    return Scaffold(
      key: const ValueKey('home'),
      backgroundColor: const Color(0xFFF8F9FA),
      body: BlocBuilder<PersonalHomeCubit, PersonalHomeState>(
        builder: (context, state) {
          if (state is PersonalHomeLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is PersonalHomeLoaded) {
            return _buildModernContent(context, state);
          } else if (state is PersonalHomeError) {
            return Center(child: Text(state.message));
          }
          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: const Color(0xFF00AE00),
        child: const Icon(Icons.add_rounded, color: Colors.white),
      ),
    );
  }

  Widget _buildModernContent(BuildContext context, PersonalHomeLoaded state) {
    // Si no hay viaje, mostramos el estado vacío original
    if (!state.data.viajeActivo) return _buildEmptyState();

    return CustomScrollView(
      slivers: [
        // Un AppBar más moderno y limpio
        SliverAppBar(
          expandedHeight: 150,
          pinned: true,
          flexibleSpace: FlexibleSpaceBar(
            title: Text(
              'Hola, ${state.data.nombreGuia}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            background: Stack(
              fit: StackFit.expand,
              children: [
                _buildHeaderBackground(),
                // Mini-clima en la esquina superior izquierda (debajo del status bar, y lejos del título)
                Positioned(
                  top:
                      MediaQuery.of(context).padding.top +
                      28, // Mayor "Safe Area" superior
                  left:
                      28, // Alejado bastante del borde izquierdo para celulares con esquinas redondas
                  child: const WeatherWidget(isCompact: true),
                ),
              ],
            ),
          ),
          actions: [
            // Botón de Modo Eco que ya tenías
            IconButton(
              icon: const Icon(Icons.battery_saver),
              onPressed: () => context.read<EcoModeCubit>().enableEcoMode(),
            ),
          ],
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildStatusHeader(state),
                const SizedBox(height: 16),
                const SizedBox(height: 16),

                // --- NUEVO: Resumen de Viaje y Progreso ---
                _buildTripProgressCard(state),
                const SizedBox(height: 25),

                _buildMapSection(), // Vista de mapa
                const SizedBox(height: 16),
                // --- NUEVO: Lista de Actividades Interactiva ---
                _buildSectionTitle('Gestión de Actividades'),
                const SizedBox(height: 12),

                ActivityListWithFilter(
                  actividades: state.data.actividades,
                  esGestion: true,
                ),

                const SizedBox(height: 25),
                _buildSectionTitle('Acciones de Guía'),
                const SizedBox(height: 12),
                _buildActionCard(
                  icon: Icons.edit_calendar_rounded,
                  title: 'Solicitar Cambio de Itinerario',
                  subtitle: 'Por clima o logística',
                  onTap: () {},
                ),
                _buildActionCard(
                  icon: Icons.group_add_rounded,
                  title: 'Añadir Turista Manual',
                  subtitle: 'Registro fuera de sistema',
                  onTap: () {},
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
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

  Widget _buildHeaderBackground() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color.fromARGB(255, 0, 174, 0),
            Color.fromARGB(255, 186, 247, 212),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
    );
  }

  Widget _buildMapSection() {
    return const MapPreviewCard(
      locationLabel: 'Seguimiento personal · Toca para abrir mapa',
    );
  }

  Widget _buildTripProgressCard(PersonalHomeLoaded state) {
    final totalActividades = state.data.actividades.length;
    final completadas =
        state.data.actividades.where((a) => a.completada).length;
    final double progreso =
        totalActividades > 0 ? (completadas / totalActividades) : 0.0;
    final destino = state.data.nombreViaje;
    final turistas = state.data.participantes;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 15),
        ],
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
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Colors.black87,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 12),
              GestureDetector(
                onTap:
                    () => _mostrarGestionTuristas(
                      context,
                      state.data.listaTuristas,
                    ),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blueGrey.shade50,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(0xFF007BFF).withOpacity(0.5),
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.people_outline,
                        size: 14,
                        color: Color(0xFF0056b3),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '$turistas',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0056b3),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$completadas / $totalActividades actividades',
                style: TextStyle(
                  color: Colors.grey.shade800,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                '${(progreso * 100).toInt()}%',
                style: const TextStyle(
                  color: Color(0xFF00AE00),
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0, end: progreso),
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeOutCubic,
              builder: (context, value, _) {
                return LinearProgressIndicator(
                  value: value,
                  backgroundColor: Colors.grey.shade200,
                  color: const Color(0xFF00AE00),
                  minHeight: 10,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusHeader(PersonalHomeLoaded state) {
    // 1. Validar si hay actividades en el estado
    if (state.data.actividades.isEmpty) {
      return const SizedBox.shrink();
    }

    // 2. Buscar la primera actividad que no esté completada
    final actividadesPendientes =
        state.data.actividades.where((a) => !a.completada).toList();

    if (actividadesPendientes.isEmpty) {
      return const SizedBox.shrink(); // También podrías mostrar un texto indicando "Día libre"
    }

    // 3. Obtener la actividad relevante
    final actividadActual = actividadesPendientes.first;

    // 4. Implementamos lógica real con DateTime para saber si está en curso o es próxima
    final ahora = DateTime.now();
    bool esEnCurso = false;

    // Simplificamos la comparación. En un caso ideal también considerarías la fecha,
    // pero para un itinerario del mismo día esto funciona perfecto:
    final inicioHoraMinuto =
        (actividadActual.horaInicio.hour * 60) +
        actividadActual.horaInicio.minute;
    final finHoraMinuto =
        (actividadActual.horaFin.hour * 60) + actividadActual.horaFin.minute;
    final ahoraHoraMinuto = (ahora.hour * 60) + ahora.minute;

    if (ahoraHoraMinuto >= inicioHoraMinuto &&
        ahoraHoraMinuto <= finHoraMinuto) {
      esEnCurso = true;
    }

    // Variables de UI dinámicas según el estado "esEnCurso"
    String prefijo = esEnCurso ? 'Actividad en curso:' : 'Próxima actividad:';
    Color colorPunto = esEnCurso ? const Color(0xFF00AE00) : Colors.orange;
    Color colorTexto =
        esEnCurso ? const Color(0xFF006400) : Colors.orange.shade900;
    Color colorFondo =
        esEnCurso
            ? const Color(0xFF00AE00).withOpacity(0.1)
            : Colors.orange.withOpacity(0.1);
    Color colorBorde =
        esEnCurso
            ? const Color(0xFF00AE00).withOpacity(0.3)
            : Colors.orange.withOpacity(0.3);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorFondo,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorBorde),
      ),
      child: Row(
        children: [
          CircleAvatar(backgroundColor: colorPunto, radius: 6),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              '$prefijo ${actividadActual.nombre}',
              style: TextStyle(
                color: colorTexto,
                fontWeight: FontWeight.w800, // Mayor contraste
                fontSize: 13,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        color: Colors.grey.shade600,
        fontSize: 12,
        fontWeight: FontWeight.bold,
        letterSpacing: 1,
      ),
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade200),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: Colors.blueGrey.shade700, size: 22),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded, color: Colors.grey),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _mostrarGestionTuristas(BuildContext context, List<Turista> turistas) {
    setState(() {
      _turistas = turistas;
      _mostrandoTuristas = true;
    });
  }
}
