import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:frontend/core/navigation/routes_guia.dart';
import 'package:frontend/features/guia/home/presentation/blocs/agencia_home_bloc/agencia_home_cubit.dart';
import 'package:frontend/features/guia/home/presentation/blocs/eco_mode/eco_mode_cubit.dart';
import 'package:frontend/features/guia/home/presentation/shared_widgets/sos_button.dart';
import 'package:frontend/features/guia/home/presentation/shared_widgets/weather_widget.dart';
import 'package:frontend/features/guia/home/presentation/shared_widgets/map_preview_card.dart';

// ────────────────────────────────────────────────────────────────────────────
// AGENCIA MAIN LAYOUT — Dashboard B2B
// Prioridad: Lista de personas (Pase de lista) → Control del grupo → Geocerca
// Acento: Azul corporativo OhtliAni  #1A237E / #3D5AF1
// ────────────────────────────────────────────────────────────────────────────

const _azulPrimario = Color(0xFF1A237E);
const _azulSecundario = Color(0xFF3D5AF1);
const _azulClaro = Color(0xFFE8EEFF);

class AgenciaMainLayout extends StatefulWidget {
  final String nombreGuia;
  final String folio;

  const AgenciaMainLayout({
    super.key,
    required this.nombreGuia,
    required this.folio,
  });

  @override
  State<AgenciaMainLayout> createState() => _AgenciaMainLayoutState();
}

class _AgenciaMainLayoutState extends State<AgenciaMainLayout> {
  @override
  void initState() {
    super.initState();
    context.read<AgenciaHomeCubit>().cargarDatos(widget.folio);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F3FF),
      body: BlocBuilder<AgenciaHomeCubit, AgenciaHomeState>(
        builder: (context, state) {
          if (state is AgenciaHomeLoading) {
            return const Center(
              child: CircularProgressIndicator(color: _azulSecundario),
            );
          }
          if (state is AgenciaHomeLoaded) {
            return _buildContent(context, state);
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, AgenciaHomeLoaded state) {
    return CustomScrollView(
      slivers: [
        // ── SliverAppBar corporativo ─────────────────────────────────────
        SliverAppBar(
          expandedHeight: 140,
          pinned: true,
          backgroundColor: _azulPrimario,
          automaticallyImplyLeading: false,
          flexibleSpace: FlexibleSpaceBar(
            background: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [_azulPrimario, _azulSecundario],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              padding: const EdgeInsets.fromLTRB(20, 50, 20, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Folio banner persistente
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(20),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: Colors.white.withAlpha(60)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.business_center,
                          color: Color(0xFF90CAF9),
                          size: 14,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Folio activo: ${state.folio}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 18,
                        backgroundColor: Colors.white.withAlpha(30),
                        child: const Icon(
                          Icons.badge_outlined,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Bienvenido, ${widget.nombreGuia}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                          ),
                        ),
                      ),
                      _BadgeContador(
                        count: state.enAlerta,
                        label: 'Alertas',
                        color: Colors.red.shade300,
                      ),
                      const SizedBox(width: 8),
                      // ── Botón Modo Eco ───────────────────────────────
                      Tooltip(
                        message: 'Activar Modo Eco',
                        child: GestureDetector(
                          onTap:
                              () =>
                                  context.read<EcoModeCubit>().enableEcoMode(),
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.white.withAlpha(20),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: Colors.white.withAlpha(50),
                              ),
                            ),
                            child: const Icon(
                              Icons.battery_saver_rounded,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                        ),
                      ),
                    ],
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
              // ── Clima ──────────────────────────────────────────────────
              const WeatherWidget(),
              const SizedBox(height: 14),

              // ── Resumen del grupo ──────────────────────────────────────
              _SeccionTitulo(
                titulo: 'Pase de lista · ${state.totalParticipantes} inscritos',
              ),
              const SizedBox(height: 8),
              _ResumenEstados(state: state),
              const SizedBox(height: 12),
              _ListaParticipantes(participantes: state.participantes),
              const SizedBox(height: 18),

              // ── Mapa / Geocerca ────────────────────────────────────────
              _SeccionTitulo(titulo: 'Geocerca institucional'),
              const SizedBox(height: 8),
              _GeocercaBanner(geocercaRadio: state.geocercaRadio),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: () => context.push(RoutesGuia.map),
                child: const MapPreviewCard(
                  locationLabel:
                      'Monitoreo de grupo en tiempo real · Toca para abrir',
                ),
              ),
              const SizedBox(height: 18),

              // ── Comunicación con central ───────────────────────────────
              _SeccionTitulo(titulo: 'Panel de comunicación'),
              const SizedBox(height: 8),
              _PanelComunicacion(),
              const SizedBox(height: 14),

              // ── Historial de alertas (ISO 31000 trazabilidad) ──────────
              _SeccionTitulo(titulo: 'Historial de alertas'),
              const SizedBox(height: 8),
              _HistorialAlertas(alertas: state.historialAlertas),
              const SizedBox(height: 18),

              // ── Accesos rápidos ────────────────────────────────────────
              _AccesosRapidos(
                items: [
                  (Icons.map_rounded, 'Mapa', RoutesGuia.map),
                  (Icons.route_rounded, 'Gestión', RoutesGuia.itineraryChanges),
                  (Icons.chat_bubble_rounded, 'Chat', RoutesGuia.chat),
                  (Icons.list_alt_rounded, 'Itinerario', RoutesGuia.itinerary),
                  (Icons.notifications_rounded, 'Alertas', RoutesGuia.alerts),
                  (Icons.people_rounded, 'Grupo', RoutesGuia.participants),
                  (Icons.currency_exchange, 'Conversor', RoutesGuia.converter),
                  (Icons.person_rounded, 'Perfil', RoutesGuia.profile),
                ],
                accentColor: _azulSecundario,
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

// ── Sub-widgets privados B2B ──────────────────────────────────────────────────

class _ResumenEstados extends StatelessWidget {
  final AgenciaHomeLoaded state;
  const _ResumenEstados({required this.state});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _ChipEstado(
          count: state.sincronizados,
          label: 'Sincronizados',
          color: const Color(0xFF1B5E20),
          bgColor: const Color(0xFFE8F5E9),
          icono: Icons.wifi,
        ),
        const SizedBox(width: 8),
        _ChipEstado(
          count: state.offline,
          label: 'Offline',
          color: Colors.grey.shade700,
          bgColor: Colors.grey.shade100,
          icono: Icons.wifi_off,
        ),
        const SizedBox(width: 8),
        _ChipEstado(
          count: state.enAlerta,
          label: 'Alertas',
          color: const Color(0xFFB71C1C),
          bgColor: const Color(0xFFFFEBEE),
          icono: Icons.warning_rounded,
        ),
      ],
    );
  }
}

class _ChipEstado extends StatelessWidget {
  final int count;
  final String label;
  final Color color;
  final Color bgColor;
  final IconData icono;
  const _ChipEstado({
    required this.count,
    required this.label,
    required this.color,
    required this.bgColor,
    required this.icono,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Icon(icono, color: color, size: 18),
            const SizedBox(height: 4),
            Text(
              '$count',
              style: TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 18,
                color: color,
              ),
            ),
            Text(
              label,
              style: TextStyle(fontSize: 9, color: color),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _ListaParticipantes extends StatelessWidget {
  final List<ParticipanteMock> participantes;
  const _ListaParticipantes({required this.participantes});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: participantes.length,
      separatorBuilder: (_, __) => const SizedBox(height: 6),
      itemBuilder: (_, i) {
        final p = participantes[i];
        final (color, bgColor, icono, etiqueta) = switch (p.estado) {
          EstadoParticipante.sincronizado => (
            const Color(0xFF2E7D32),
            const Color(0xFFE8F5E9),
            Icons.check_circle_rounded,
            'Sincronizado',
          ),
          EstadoParticipante.offline => (
            Colors.grey.shade600,
            Colors.grey.shade100,
            Icons.wifi_off_rounded,
            'Offline',
          ),
          EstadoParticipante.alerta => (
            const Color(0xFFB71C1C),
            const Color(0xFFFFEBEE),
            Icons.warning_rounded,
            'Alerta',
          ),
        };
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey.shade100),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: bgColor,
                child: Icon(icono, size: 16, color: color),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  p.nombre,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 13,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  etiqueta,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _GeocercaBanner extends StatelessWidget {
  final String geocercaRadio;
  const _GeocercaBanner({required this.geocercaRadio});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _azulClaro,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _azulSecundario.withAlpha(60)),
      ),
      child: Row(
        children: [
          const Icon(Icons.fence, color: _azulPrimario, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Geocerca activa',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    color: _azulPrimario,
                  ),
                ),
                Text(
                  geocercaRadio,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF3949AB),
                  ),
                ),
              ],
            ),
          ),
          TextButton.icon(
            onPressed: () => context.push(RoutesGuia.itineraryChanges),
            icon: const Icon(Icons.edit_rounded, size: 14),
            label: const Text('Solicitar\nmodif.', textAlign: TextAlign.center),
            style: TextButton.styleFrom(
              foregroundColor: _azulSecundario,
              textStyle: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PanelComunicacion extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _BtnComunicacion(
            icono: Icons.headset_mic_rounded,
            label: 'Voz con central',
            color: _azulPrimario,
            onTap: () {},
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _BtnComunicacion(
            icono: Icons.chat_rounded,
            label: 'Chat agencia',
            color: _azulSecundario,
            onTap: () => context.push(RoutesGuia.chat),
          ),
        ),
      ],
    );
  }
}

class _BtnComunicacion extends StatelessWidget {
  final IconData icono;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _BtnComunicacion({
    required this.icono,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icono, color: Colors.white, size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HistorialAlertas extends StatelessWidget {
  final List<AlertaHistorial> alertas;
  const _HistorialAlertas({required this.alertas});

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
        itemCount: alertas.length,
        separatorBuilder:
            (_, __) => Divider(height: 1, color: Colors.grey.shade100),
        itemBuilder: (_, i) {
          final a = alertas[i];
          return ListTile(
            dense: true,
            leading: const Icon(
              Icons.notifications_active_rounded,
              color: Color(0xFFE53935),
              size: 18,
            ),
            title: Text(a.descripcion, style: const TextStyle(fontSize: 12)),
            trailing: Text(
              a.hora,
              style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
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

class _BadgeContador extends StatelessWidget {
  final int count;
  final String label;
  final Color color;
  const _BadgeContador({
    required this.count,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    if (count == 0) return const SizedBox.shrink();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(180),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        '$count $label',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
