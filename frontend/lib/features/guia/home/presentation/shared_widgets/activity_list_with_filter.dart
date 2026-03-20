import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:frontend/features/guia/trips/domain/entities/actividad_itinerario.dart';
import 'package:frontend/features/guia/home/presentation/shared_widgets/activity_card.dart';
import 'package:frontend/features/guia/home/presentation/blocs/personal_home_bloc/personal_home_cubit.dart';

// ─── Constantes ───
const _kDarkChip = Color(0xFF1A1A2E);
const _kGreenChip = Color(0xFF00AE00);

/// Normaliza un [DateTime] a solo año-mes-día.
DateTime _soloFecha(DateTime dt) => DateTime(dt.year, dt.month, dt.day);

class ActivityListWithFilter extends StatefulWidget {
  final List<ActividadItinerario> actividades;
  final bool esGestion;

  const ActivityListWithFilter({
    super.key,
    required this.actividades,
    this.esGestion = false,
  });

  @override
  State<ActivityListWithFilter> createState() => _ActivityListWithFilterState();
}

class _ActivityListWithFilterState extends State<ActivityListWithFilter> {
  DateTime? _selectedDate;

  List<DateTime> get _diasUnicos =>
      widget.actividades.map((a) => _soloFecha(a.horaInicio)).toSet().toList()..sort();

  @override
  void initState() {
    super.initState();
    if (widget.actividades.isNotEmpty) _selectedDate = _diasUnicos.first;
  }

  @override
  void didUpdateWidget(covariant ActivityListWithFilter oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.actividades != oldWidget.actividades && widget.actividades.isNotEmpty) {
      final dias = _diasUnicos;
      if (_selectedDate == null || !dias.contains(_selectedDate)) {
        setState(() => _selectedDate = dias.first);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Estado vacío — muestra tarjeta de ejemplo
    if (widget.actividades.isEmpty) {
      final hoy = DateTime.now();
      return Column(
        children: [
          const SizedBox(height: 25),
          ActivityCard(
            actividad: ActividadItinerario(
              nombre: 'Ruinas Arqueológicas',
              horaInicio: DateTime(hoy.year, hoy.month, hoy.day, 9),
              horaFin: DateTime(hoy.year, hoy.month, hoy.day, 11),
              completada: true,
            ),
            esGestion: widget.esGestion,
          ),
        ],
      );
    }

    final dias = _diasUnicos;
    _selectedDate ??= dias.first;

    final delDia = widget.actividades
        .where((a) => _soloFecha(a.horaInicio) == _selectedDate);

    final filtro = context.select<PersonalHomeCubit, FiltroEstado>(
      (cubit) => cubit.state is PersonalHomeLoaded
          ? (cubit.state as PersonalHomeLoaded).filtroActivo
          : FiltroEstado.todas,
    );

    final filtradas = delDia.where((a) {
      return switch (filtro) {
        FiltroEstado.pendientes => !a.completada,
        FiltroEstado.completadas => a.completada,
        FiltroEstado.todas => true,
      };
    }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _DaySelector(
          days: dias,
          selected: _selectedDate!,
          onSelected: (d) => setState(() => _selectedDate = d),
        ),
        _FilterChips(filtro: filtro, actividadesDelDia: delDia),
        const SizedBox(height: 15),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: filtradas.isEmpty
              ? const _EmptyState(key: ValueKey('empty'))
              : Column(
                  key: ValueKey('${_selectedDate?.toIso8601String()}_$filtro'),
                  children: [
                    for (final act in filtradas)
                      ActivityCard(actividad: act, esGestion: widget.esGestion),
                  ],
                ),
        ),
      ],
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
//  Widgets privados extraídos
// ═══════════════════════════════════════════════════════════════════

/// Selector horizontal de días.
class _DaySelector extends StatelessWidget {
  final List<DateTime> days;
  final DateTime selected;
  final ValueChanged<DateTime> onSelected;

  const _DaySelector({
    required this.days,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    if (days.isEmpty) return const SizedBox.shrink();
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (var i = 0; i < days.length; i++)
            _DayChip(
              label: 'Día ${i + 1}',
              isSelected: selected == days[i],
              onTap: () => onSelected(days[i]),
            ),
        ],
      ),
    );
  }
}

class _DayChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _DayChip({required this.label, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? _kDarkChip : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Colors.transparent : Colors.grey.shade200,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}

/// Chips de filtro: Todas / Pendientes / Completadas.
class _FilterChips extends StatelessWidget {
  final FiltroEstado filtro;
  final Iterable<ActividadItinerario> actividadesDelDia;

  const _FilterChips({required this.filtro, required this.actividadesDelDia});

  @override
  Widget build(BuildContext context) {
    final pendientes = actividadesDelDia.where((a) => !a.completada).length;
    final completadas = actividadesDelDia.where((a) => a.completada).length;

    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _chip(context, 'Todas', FiltroEstado.todas),
            const SizedBox(width: 8),
            _chip(context, 'Pendientes ($pendientes)', FiltroEstado.pendientes),
            const SizedBox(width: 8),
            _chip(context, 'Completadas ($completadas)', FiltroEstado.completadas),
          ],
        ),
      ),
    );
  }

  Widget _chip(BuildContext context, String label, FiltroEstado value) {
    final isSelected = value == filtro;
    return FilterChip(
      label: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? Colors.white : Colors.black87,
        ),
      ),
      selected: isSelected,
      onSelected: (_) => context.read<PersonalHomeCubit>().cambiarFiltro(value),
      backgroundColor: Colors.transparent,
      selectedColor: _kGreenChip,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: isSelected ? Colors.transparent : Colors.grey.shade300),
      ),
      showCheckmark: false,
      padding: const EdgeInsets.symmetric(horizontal: 4),
    );
  }
}

/// Estado vacío cuando no hay actividades para el filtro actual.
class _EmptyState extends StatelessWidget {
  const _EmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.check_circle_outline_rounded, size: 60, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(
              'Aún no has terminado ninguna actividad.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600, fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              '¡Mucho éxito en el recorrido!',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade500, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}
