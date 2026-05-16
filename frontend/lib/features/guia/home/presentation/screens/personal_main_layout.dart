import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/features/guia/home/presentation/blocs/personal_home_bloc/personal_home_cubit.dart';
import 'package:frontend/features/guia/home/presentation/blocs/eco_mode/eco_mode_cubit.dart';
import 'package:frontend/features/guia/shared/widgets/weather_widget.dart';
import 'package:frontend/features/guia/trips/presentation/widgets/activity_list_with_filter.dart';
import 'package:frontend/features/guia/home/presentation/widgets/personal_home_widgets.dart';
import 'package:frontend/features/guia/home/presentation/widgets/grupo_turistas_tab.dart';

import 'package:frontend/features/guia/shared/theme/guia_theme.dart';
import 'package:frontend/features/guia/shared/widgets/guia_custom_app_bar.dart';

class PersonalMainLayout extends StatefulWidget {
  final String nombreGuia;
  const PersonalMainLayout({super.key, required this.nombreGuia});

  @override
  State<PersonalMainLayout> createState() => _PersonalMainLayoutState();
}

class _PersonalMainLayoutState extends State<PersonalMainLayout>
    with SingleTickerProviderStateMixin {
  late final TabController _tabCtrl;
  late final ValueNotifier<int> _tabIndex;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 2, vsync: this);
    _tabIndex = ValueNotifier(0);
    _tabCtrl.addListener(() => _tabIndex.value = _tabCtrl.index);
    context.read<PersonalHomeCubit>().cargarDatos(widget.nombreGuia);
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    _tabIndex.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GuiaColors.backgroundAlternative,
      appBar: _buildAppBar(context),
      body: BlocBuilder<PersonalHomeCubit, PersonalHomeState>(
        builder:
            (_, state) => switch (state) {
              PersonalHomeLoading() => const Center(
                child: CircularProgressIndicator(),
              ),
              PersonalHomeError(:final message) => Center(child: Text(message)),
              PersonalHomeLoaded() when !state.data.viajeActivo =>
                const EmptyStateWidget(),
              PersonalHomeLoaded() => _Body(
                state: state,
                tabCtrl: _tabCtrl,
                tabIndex: _tabIndex,
              ),
              _ => const SizedBox.shrink(),
            },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return GuiaCustomAppBar(
      title: '', // Custom bottom widget handles this
      subtitle: 'Modo Independiente',
      icon: Icons.explore_rounded,
      actions: [
        const WeatherWidget(isCompact: true),
        _AddButton(tabIndex: _tabIndex, onPressed: _onAdd),
        _OverflowMenu(onSelected: _onMenu),
      ],
      customBottomWidget: Row(
        children: [
          const CircleAvatar(
            radius: 20,
            backgroundColor: Colors.white24,
            child: Icon(Icons.person_rounded, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: BlocSelector<PersonalHomeCubit, PersonalHomeState, String>(
              selector: (s) => s is PersonalHomeLoaded ? s.data.nombreGuia : widget.nombreGuia,
              builder: (_, n) => Text(
                'Bienvenido, $n',
                style: GuiaTextStyles.appBarTitle,
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
    final msg =
        _tabCtrl.index == 0
            ? 'Añadir actividad (próximamente)'
            : 'Añadir turista (próximamente)';
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  void _onMenu(String v) {
    final msg =
        v == 'ajustar'
            ? 'Ajustar itinerario (próximamente)'
            : 'Reportar incidente (próximamente)';
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }
}

class _Body extends StatelessWidget {
  final PersonalHomeLoaded state;
  final TabController tabCtrl;
  final ValueNotifier<int> tabIndex;

  const _Body({
    required this.state,
    required this.tabCtrl,
    required this.tabIndex,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              StatusHeaderWidget(state: state),
              if (state.data.actividades.isNotEmpty) const SizedBox(height: 10),
              TripProgressCardWidget(state: state),
            ],
          ),
        ),
        TabBar(
          controller: tabCtrl,
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
        Expanded(
          child: ValueListenableBuilder<int>(
            valueListenable: tabIndex,
            builder: (context, index, _) {
              return IndexedStack(
                index: index,
                children: [
                  ActivityListWithFilter(
                    key: const PageStorageKey('tab_itinerario'),
                    actividades: state.data.actividades,
                    esGestion: true,
                  ),
                  GrupoTuristasTab(
                    key: const PageStorageKey('tab_grupo'),
                    turistas: state.data.listaTuristas,
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}

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
              value: 'ajustar',
              child: _MenuItem(
                Icons.edit_calendar_rounded,
                'Ajustar Itinerario',
              ),
            ),
            PopupMenuItem(
              value: 'incidente',
              child: _MenuItem(
                Icons.report_problem_outlined,
                'Reportar Incidente',
              ),
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
