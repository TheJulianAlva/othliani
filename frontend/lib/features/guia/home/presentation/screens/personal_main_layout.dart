import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:frontend/core/navigation/routes_guia.dart';
import 'package:frontend/features/guia/home/presentation/blocs/personal_home_bloc/personal_home_cubit.dart';
import 'package:frontend/features/guia/home/presentation/shared_widgets/sos_button.dart';
import 'package:frontend/features/guia/home/presentation/shared_widgets/weather_widget.dart';
import 'package:frontend/features/guia/home/presentation/shared_widgets/map_preview_card.dart';

// ────────────────────────────────────────────────────────────────────────────
// PERSONAL MAIN LAYOUT — Dashboard B2C
// Prioridad: Mapa · Itinerario · Control autónomo
// Acento: Naranja tierra / Ámbar  #E65100 / #FF6D00  —  tono aventurero
// ────────────────────────────────────────────────────────────────────────────

const _naranjaPrimario = Color(0xFFE65100);
const _naranjaSecundario = Color(0xFFFF6D00);
const _naranjaClaro = Color(0xFFFFF3E0);

class PersonalMainLayout extends StatefulWidget {
  final String nombreGuia;
  const PersonalMainLayout({super.key, required this.nombreGuia});

  @override
  State<PersonalMainLayout> createState() => _PersonalMainLayoutState();
}

class _PersonalMainLayoutState extends State<PersonalMainLayout> {
  @override
  void initState() {
    super.initState();
    context.read<PersonalHomeCubit>().cargarDatos(widget.nombreGuia);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F0),
      body: BlocBuilder<PersonalHomeCubit, PersonalHomeState>(
        builder: (context, state) {
          if (state is PersonalHomeLoading) {
            return const Center(
              child: CircularProgressIndicator(color: _naranjaSecundario),
            );
          }
          if (state is PersonalHomeLoaded) {
            return _buildContent(context, state);
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, PersonalHomeLoaded state) {
    return CustomScrollView(
      slivers: [
        // ── SliverAppBar aventurero ──────────────────────────────────────
        SliverAppBar(
          expandedHeight: 130,
          pinned: true,
          backgroundColor: _naranjaPrimario,
          automaticallyImplyLeading: false,
          flexibleSpace: FlexibleSpaceBar(
            background: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [_naranjaPrimario, _naranjaSecundario],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              padding: const EdgeInsets.fromLTRB(20, 50, 20, 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: Colors.white.withAlpha(30),
                    child: const Icon(
                      Icons.person_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          'Hola, ${state.nombreGuia}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                          ),
                        ),
                        const Text(
                          'Guía independiente',
                          style: TextStyle(color: Colors.white70, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                  // Modo Explorador switch en el header
                  _ModoExploradorSwitch(
                    activo: state.modoExplorador,
                    compact: true,
                  ),
                ],
              ),
            ),
          ),
        ),

        // ── Cuerpo ───────────────────────────────────────────────────────
        SliverPadding(
          padding: const EdgeInsets.all(18),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              // ── Clima ─────────────────────────────────────────────────
              const WeatherWidget(),
              const SizedBox(height: 14),

              // ── Mapa (prioridad visual) ───────────────────────────────
              _SeccionTitulo(titulo: 'Mi ruta'),
              const SizedBox(height: 8),
              const MapPreviewCard(
                locationLabel: 'Seguimiento personal en tiempo real',
              ),
              const SizedBox(height: 10),

              // ── Geocerca configurable ─────────────────────────────────
              _GeocercaSelector(geocercaMetros: state.geocercaMetros),
              const SizedBox(height: 18),

              // ── Modo Explorador ───────────────────────────────────────
              _SeccionTitulo(titulo: 'Modo Explorador'),
              const SizedBox(height: 8),
              _ModoExploradorCard(activo: state.modoExplorador),
              const SizedBox(height: 18),

              // ── Itinerario propio ──────────────────────────────────────
              _SeccionTituloConAccion(
                titulo: 'Mi itinerario',
                accion: '+ Añadir',
                onAccion: () {},
              ),
              const SizedBox(height: 8),
              _ListaActividades(actividades: state.actividades),
              const SizedBox(height: 18),

              // ── Estadísticas de seguridad ──────────────────────────────
              _SeccionTitulo(titulo: 'Estadísticas del viaje'),
              const SizedBox(height: 8),
              _StatsGrid(state: state),
              const SizedBox(height: 14),

              // ── Huella de carbono ──────────────────────────────────────
              _HuellaCarbono(kg: state.huellaCarbono),
              const SizedBox(height: 18),

              // ── Contactos de emergencia ────────────────────────────────
              _SeccionTitulo(titulo: 'Contactos de emergencia'),
              const SizedBox(height: 8),
              _ListaContactos(contactos: state.contactos),
              const SizedBox(height: 18),

              // ── Accesos rápidos ────────────────────────────────────────
              _AccesosRapidos(
                items: [
                  (Icons.list_alt_rounded, 'Itinerario', RoutesGuia.itinerary),
                  (Icons.people_rounded, 'Grupo', RoutesGuia.participants),
                  (Icons.chat_bubble_rounded, 'Chat', RoutesGuia.chat),
                  (Icons.person_rounded, 'Perfil', RoutesGuia.profile),
                ],
                accentColor: _naranjaSecundario,
              ),
              const SizedBox(height: 20),

              // ── SOS ────────────────────────────────────────────────────
              const SosButton(),
              const SizedBox(height: 16),
            ]),
          ),
        ),
      ],
    );
  }
}

// ── Sub-widgets privados B2C ──────────────────────────────────────────────────

class _GeocercaSelector extends StatelessWidget {
  final int geocercaMetros;
  const _GeocercaSelector({required this.geocercaMetros});

  @override
  Widget build(BuildContext context) {
    const radios = [50, 200, 500];
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _naranjaClaro,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _naranjaSecundario.withAlpha(60)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.radar, color: _naranjaPrimario, size: 18),
              const SizedBox(width: 8),
              const Text(
                'Radio de geocerca',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                  color: _naranjaPrimario,
                ),
              ),
              const Spacer(),
              Text(
                '$geocercaMetros m',
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 13,
                  color: _naranjaPrimario,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children:
                radios.map((r) {
                  final selected = r == geocercaMetros;
                  return GestureDetector(
                    onTap:
                        () => context.read<PersonalHomeCubit>().cambiarGeocerca(
                          r,
                        ),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 18,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: selected ? _naranjaSecundario : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color:
                              selected
                                  ? _naranjaSecundario
                                  : Colors.grey.shade300,
                        ),
                      ),
                      child: Text(
                        '$r m',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: selected ? Colors.white : Colors.grey.shade600,
                        ),
                      ),
                    ),
                  );
                }).toList(),
          ),
        ],
      ),
    );
  }
}

class _ModoExploradorCard extends StatelessWidget {
  final bool activo;
  const _ModoExploradorCard({required this.activo});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: activo ? _naranjaClaro : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color:
              activo ? _naranjaSecundario.withAlpha(80) : Colors.grey.shade200,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.explore_rounded,
            color: activo ? _naranjaSecundario : Colors.grey,
            size: 28,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activo
                      ? 'Monitoreo inteligente activo'
                      : 'Monitoreo en pausa',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    color: activo ? _naranjaPrimario : Colors.grey.shade700,
                  ),
                ),
                Text(
                  activo
                      ? 'Sin horario rígido – total autonomía'
                      : 'Activa para explorar sin restricciones',
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: activo,
            onChanged:
                (_) => context.read<PersonalHomeCubit>().toggleModoExplorador(),
            activeColor: _naranjaSecundario,
          ),
        ],
      ),
    );
  }
}

class _ModoExploradorSwitch extends StatelessWidget {
  final bool activo;
  final bool compact;
  const _ModoExploradorSwitch({required this.activo, this.compact = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.explore_rounded,
          color: Colors.white.withAlpha(180),
          size: 14,
        ),
        const SizedBox(width: 4),
        Switch.adaptive(
          value: activo,
          onChanged:
              (_) => context.read<PersonalHomeCubit>().toggleModoExplorador(),
          activeColor: Colors.orange.shade200,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
      ],
    );
  }
}

class _ListaActividades extends StatelessWidget {
  final List<ActividadItinerario> actividades;
  const _ListaActividades({required this.actividades});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(vertical: 6),
        itemCount: actividades.length,
        separatorBuilder:
            (_, __) => Divider(height: 1, color: Colors.grey.shade100),
        itemBuilder: (_, i) {
          final a = actividades[i];
          return ListTile(
            dense: true,
            leading: Icon(
              a.completada
                  ? Icons.check_circle_rounded
                  : Icons.radio_button_unchecked,
              color: a.completada ? _naranjaPrimario : Colors.grey.shade400,
              size: 20,
            ),
            title: Text(
              a.nombre,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                decoration: a.completada ? TextDecoration.lineThrough : null,
                color: a.completada ? Colors.grey : const Color(0xFF1A1A2E),
              ),
            ),
            trailing: Text(
              '${a.horaInicio}–${a.horaFin}',
              style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
            ),
          );
        },
      ),
    );
  }
}

class _StatsGrid extends StatelessWidget {
  final PersonalHomeLoaded state;
  const _StatsGrid({required this.state});

  @override
  Widget build(BuildContext context) {
    final stats = [
      (Icons.straighten, '${state.kmRecorridos} km', 'Distancia'),
      (Icons.timer_rounded, '${state.minActivos} min', 'Tiempo activo'),
      (Icons.terrain_rounded, '${state.altitudActualM.toInt()} m', 'Altitud'),
    ];
    return Row(
      children:
          stats.map((s) {
            return Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade100),
                ),
                child: Column(
                  children: [
                    Icon(s.$1, color: _naranjaSecundario, size: 20),
                    const SizedBox(height: 4),
                    Text(
                      s.$2,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                        color: Color(0xFF1A1A2E),
                      ),
                    ),
                    Text(
                      s.$3,
                      style: TextStyle(
                        fontSize: 9,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
    );
  }
}

class _HuellaCarbono extends StatelessWidget {
  final double kg;
  const _HuellaCarbono({required this.kg});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F8E9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF558B2F).withAlpha(60)),
      ),
      child: Row(
        children: [
          const Text('🌿', style: TextStyle(fontSize: 26)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Turismo Regenerativo',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                    color: Color(0xFF33691E),
                  ),
                ),
                Text(
                  'Huella de carbono estimada: $kg kg CO₂',
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF558B2F),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF558B2F).withAlpha(30),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '≈ $kg kg',
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 11,
                color: Color(0xFF33691E),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ListaContactos extends StatelessWidget {
  final List<ContactoEmergencia> contactos;
  const _ListaContactos({required this.contactos});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(vertical: 6),
        itemCount: contactos.length,
        separatorBuilder:
            (_, __) => Divider(height: 1, color: Colors.grey.shade100),
        itemBuilder: (_, i) {
          final c = contactos[i];
          return ListTile(
            dense: true,
            leading: CircleAvatar(
              radius: 16,
              backgroundColor: _naranjaClaro,
              child: const Icon(
                Icons.person,
                color: _naranjaSecundario,
                size: 16,
              ),
            ),
            title: Text(
              c.nombre,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
            subtitle: Text(
              c.relacion,
              style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  c.telefono,
                  style: TextStyle(fontSize: 10, color: Colors.grey.shade600),
                ),
                const SizedBox(width: 4),
                const Icon(
                  Icons.phone_rounded,
                  size: 14,
                  color: Color(0xFFE65100),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ── Shared helpers ────────────────────────────────────────────────────────────

class _SeccionTitulo extends StatelessWidget {
  final String titulo;
  const _SeccionTitulo({required this.titulo});

  @override
  Widget build(BuildContext context) {
    return Text(
      titulo,
      style: const TextStyle(
        fontWeight: FontWeight.w800,
        fontSize: 14,
        color: Color(0xFF1A1A2E),
        letterSpacing: 0.2,
      ),
    );
  }
}

class _SeccionTituloConAccion extends StatelessWidget {
  final String titulo;
  final String accion;
  final VoidCallback onAccion;
  const _SeccionTituloConAccion({
    required this.titulo,
    required this.accion,
    required this.onAccion,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            titulo,
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 14,
              color: Color(0xFF1A1A2E),
              letterSpacing: 0.2,
            ),
          ),
        ),
        TextButton.icon(
          onPressed: onAccion,
          icon: const Icon(Icons.add_circle_rounded, size: 16),
          label: Text(accion),
          style: TextButton.styleFrom(
            foregroundColor: _naranjaSecundario,
            textStyle: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

class _AccesosRapidos extends StatelessWidget {
  final List<(IconData, String, String)> items;
  final Color accentColor;
  const _AccesosRapidos({required this.items, required this.accentColor});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 4,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 8,
      crossAxisSpacing: 8,
      children:
          items.map((a) {
            return GestureDetector(
              onTap: () => context.push(a.$3),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: accentColor.withAlpha(20),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(a.$1, color: accentColor, size: 22),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    a.$2,
                    style: const TextStyle(
                      fontSize: 10,
                      color: Color(0xFF555577),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
    );
  }
}
