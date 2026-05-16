import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:frontend/core/navigation/routes_guia.dart';
import 'package:frontend/features/guia/home/presentation/blocs/agencia_home_bloc/agencia_home_cubit.dart';
import 'package:frontend/features/guia/home/presentation/blocs/eco_mode/eco_mode_cubit.dart';
import 'package:frontend/features/guia/home/presentation/blocs/personal_home_bloc/personal_home_cubit.dart'
    show FiltroEstado;
import 'package:frontend/features/guia/trips/presentation/widgets/activity_list_with_filter.dart';
import 'package:frontend/features/guia/home/presentation/widgets/grupo_turistas_tab.dart';

// ────────────────────────────────────────────────────────────────────────────
// AGENCIA MAIN LAYOUT — Dashboard B2B
// Estructura unificada con PersonalMainLayout: tabs Itinerario | Grupo
// Acento: Azul corporativo Veltur  #1A237E / #3D5AF1
// ────────────────────────────────────────────────────────────────────────────

import 'package:frontend/features/guia/shared/theme/guia_theme.dart';
import 'package:frontend/features/guia/shared/widgets/guia_custom_app_bar.dart';
import 'package:frontend/features/guia/shared/widgets/weather_widget.dart'
    show WeatherWidget;

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

class _AgenciaMainLayoutState extends State<AgenciaMainLayout>
    with SingleTickerProviderStateMixin {
  late final TabController _tabCtrl;
  late final ValueNotifier<int> _tabIndex;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
    _tabIndex = ValueNotifier(0);
    _tabCtrl.addListener(() => _tabIndex.value = _tabCtrl.index);
    context.read<AgenciaHomeCubit>().cargarDatos(widget.folio);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    _tabIndex.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AgenciaHomeCubit, AgenciaHomeState>(
      builder: (context, state) {
        if (state is AgenciaHomeLoading) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(color: GuiaColors.secondary),
            ),
          );
        }
        if (state is AgenciaHomeLoaded) {
          return _buildContent(context, state);
        }
        return const Scaffold(body: SizedBox.shrink());
      },
    );
  }

  Widget _buildContent(BuildContext context, AgenciaHomeLoaded state) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F3FF),
      appBar: _buildAppBar(context, state),
      body: Column(
        children: [
          // ── Header compacto: resumen del grupo ──────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Nombre del viaje + folio
                _TripHeader(state: state),
                const SizedBox(height: 8),
                // Chips de estado
                _ResumenEstados(state: state),
              ],
            ),
          ),

          // ── TabBar ──────────────────────────────────────────────────────
          TabBar(
            controller: _tabCtrl,
            labelColor: GuiaColors.primary,
            unselectedLabelColor: Colors.grey,
            labelStyle: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 13,
            ),
            unselectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 13,
            ),
            indicatorColor: GuiaColors.primary,
            indicatorWeight: 3,
            dividerColor: Colors.transparent,
            tabs: const [
              Tab(
                height: 40,
                text: 'Itinerario',
                icon: Icon(Icons.route_rounded, size: 18),
              ),
              Tab(
                height: 40,
                text: 'Grupo',
                icon: Icon(Icons.group_rounded, size: 18),
              ),
            ],
          ),

          // ── Contenido (tabs) ───────────────────────────────────────────
          Expanded(
            child: ValueListenableBuilder<int>(
              valueListenable: _tabIndex,
              builder: (context, index, _) {
                // Convertir FiltroEstadoAgencia → FiltroEstado para compatibilidad
                final filtroAgencia = state.filtroActivo;
                final filtro = switch (filtroAgencia) {
                  FiltroEstadoAgencia.todas => FiltroEstado.todas,
                  FiltroEstadoAgencia.pendientes => FiltroEstado.pendientes,
                  FiltroEstadoAgencia.completadas => FiltroEstado.completadas,
                };

                return IndexedStack(
                  index: index,
                  children: [
                    // Tab 0: Itinerario
                    ActivityListWithFilter(
                      key: const PageStorageKey('agencia_tab_itinerario'),
                      actividades: state.actividades,
                      esGestion: true,
                      externalFiltro: filtro,
                      onFiltroChanged: (nuevoFiltro) {
                        final agenciaFiltro = switch (nuevoFiltro) {
                          FiltroEstado.todas => FiltroEstadoAgencia.todas,
                          FiltroEstado.pendientes =>
                            FiltroEstadoAgencia.pendientes,
                          FiltroEstado.completadas =>
                            FiltroEstadoAgencia.completadas,
                        };
                        context.read<AgenciaHomeCubit>().cambiarFiltro(
                          agenciaFiltro,
                        );
                      },
                    ),
                    // Tab 1: Grupo
                    GrupoTuristasTab(
                      key: const PageStorageKey('agencia_tab_grupo'),
                      turistas: state.listaTuristas,
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(
    BuildContext context,
    AgenciaHomeLoaded state,
  ) {
    return GuiaCustomAppBar(
      title: '', // Custom bottom widget handles this
      subtitle: 'Modo Agencia',
      icon: Icons.business_center_rounded,
      actions: [
        const WeatherWidget(isCompact: true),
        if (state.enAlerta > 0)
          Padding(
            padding: const EdgeInsets.only(right: 4),
            child: _BadgeContador(
              count: state.enAlerta,
              label: 'Alertas',
              color: Colors.red.shade300,
            ),
          ),
        _AddButton(tabIndex: _tabIndex, onPressed: _onAdd),
        _OverflowMenu(onSelected: (v) => _onMenu(v, state)),
      ],
      customBottomWidget: Row(
        children: [
          const CircleAvatar(
            radius: 20,
            backgroundColor: Colors.white24,
            child: Icon(Icons.badge_outlined, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Bienvenido, ${widget.nombreGuia}',
              style: GuiaTextStyles.appBarTitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withAlpha(25),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.white.withAlpha(50)),
            ),
            child: Text(
              'Folio: ${state.folio}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.battery_saver_rounded, color: Colors.white),
            tooltip: 'Modo Eco',
            onPressed: () => context.read<EcoModeCubit>().enableEcoMode(),
          ),
        ],
      ),
    );
  }

  void _onAdd() {
    if (_tabCtrl.index == 0) {
      // Navegar a la pantalla de gestión de cambios (Ajustar Itinerario)
      context.push(RoutesGuia.itineraryChanges);
    } else {
      // Para añadir turistas, por ahora mantenemos el mensaje o navegamos
      // si existiera una ruta dedicada.
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Añadir turista (próximamente)')),
      );
    }
  }

  void _onMenu(String v, AgenciaHomeLoaded state) {
    switch (v) {
      case 'gestion':
        context.push(RoutesGuia.itineraryChanges);
      case 'finalizar':
        context.push(
          RoutesGuia.reporteFinViaje,
          extra: {
            'nombre': state.nombreViaje,
            'inicio': DateTime.now().subtract(const Duration(hours: 4)),
            'distanciaKm': 0.0,
            'esGuiaIndependiente': false,
          },
        );
    }
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
//  Sub-widgets privados
// ═══════════════════════════════════════════════════════════════════════════════

// ── Header del viaje ──────────────────────────────────────────────────────────

class _TripHeader extends StatelessWidget {
  final AgenciaHomeLoaded state;
  const _TripHeader({required this.state});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  state.nombreViaje,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  state.destino,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ],
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
                Icon(
                  Icons.people_outline,
                  size: 14,
                  color: Colors.blue.shade700,
                ),
                const SizedBox(width: 4),
                Text(
                  '${state.totalParticipantes}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.blue.shade700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Chips de estado (Sincronizados / Offline / Alertas) ──────────────────────

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

// ── Widgets atómicos (const-friendly, ultra-ligeros) ─────────────────────────

class _AddButton extends StatelessWidget {
  final ValueNotifier<int> tabIndex;
  final VoidCallback onPressed;
  const _AddButton({required this.tabIndex, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int>(
      valueListenable: tabIndex,
      builder:
          (_, idx, __) => IconButton(
            icon: const Icon(Icons.add_rounded),
            tooltip: idx == 0 ? 'Añadir actividad' : 'Añadir turista',
            onPressed: onPressed,
          ),
    );
  }
}

class _OverflowMenu extends StatelessWidget {
  final ValueChanged<String> onSelected;
  const _OverflowMenu({required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert_rounded),
      onSelected: onSelected,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      itemBuilder:
          (_) => const [
            PopupMenuItem(
              value: 'gestion',
              child: _MenuItem(
                Icons.edit_calendar_rounded,
                'Gestión de Cambios',
              ),
            ),
            PopupMenuItem(
              value: 'finalizar',
              child: _MenuItem(Icons.flag_rounded, 'Finalizar Expedición'),
            ),
          ],
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icon;
  final String text;
  const _MenuItem(this.icon, this.text);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey.shade700),
        const SizedBox(width: 12),
        Text(text, style: const TextStyle(fontSize: 14)),
      ],
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
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), // Reducido padding
      decoration: BoxDecoration(
        color: color.withAlpha(180),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row( // Agregamos un row pequeño
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.warning_amber_rounded, size: 12, color: Colors.white),
          const SizedBox(width: 4),
          Text(
            '$count', // Solo el número para ahorrar espacio
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}
