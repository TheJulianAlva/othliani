import 'package:flutter/material.dart';
import '../../core/theme/app_constants.dart';

import 'pantalla_detalle_actividad.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class TripHomeScreen extends StatefulWidget {
  const TripHomeScreen({super.key});

  @override
  State<TripHomeScreen> createState() => _TripHomeScreenState();
}

class _TripHomeScreenState extends State<TripHomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selectedFilter = 'Todas';

  // Datos de ejemplo de actividades por día
  final Map<String, List<Map<String, dynamic>>> _activitiesByDay = {
    'Día 1': [
      {
        'time': '08:00 AM',
        'title': 'Desayuno en el hotel',
        'description':
            'Buffet completo con opciones locales e internacionales. Disfruta de frutas frescas, pan recién horneado y café de la región.',
        'status': 'terminada',
      },
      {
        'time': '10:00 AM',
        'title': 'Visita a zona arqueológica',
        'description':
            'Recorrido guiado por las ruinas mayas de Tulum. Aprende sobre la historia y cultura de esta antigua civilización costera.',
        'status': 'terminada',
      },
      {
        'time': '01:00 PM',
        'title': 'Comida en restaurante local',
        'description':
            'Degustación de platillos típicos de la región. Incluye cochinita pibil, tacos de pescado y agua de jamaica.',
        'status': 'en_curso',
      },
      {
        'time': '03:30 PM',
        'title': 'Tiempo libre en la playa',
        'description':
            'Relájate en las hermosas playas de arena blanca. Actividades opcionales: snorkel, kayak o simplemente disfrutar del sol.',
        'status': 'pendiente',
      },
      {
        'time': '06:00 PM',
        'title': 'Cena de bienvenida',
        'description':
            'Cena especial con vista al mar. Menú de tres tiempos con especialidades del chef y música en vivo.',
        'status': 'pendiente',
      },
    ],
    'Día 2': [
      {
        'time': '07:00 AM',
        'title': 'Yoga en la playa',
        'description':
            'Sesión de yoga matutina frente al mar. Perfecta para comenzar el día con energía y relajación.',
        'status': 'pendiente',
      },
      {
        'time': '09:00 AM',
        'title': 'Desayuno buffet',
        'description':
            'Desayuno completo con opciones saludables y tradicionales.',
        'status': 'pendiente',
      },
      {
        'time': '11:00 AM',
        'title': 'Tour en cenote',
        'description':
            'Explora los místicos cenotes mayas. Incluye equipo de snorkel y guía experto.',
        'status': 'pendiente',
      },
      {
        'time': '02:00 PM',
        'title': 'Comida típica yucateca',
        'description':
            'Prueba los mejores platillos de la cocina yucateca en un restaurante tradicional.',
        'status': 'pendiente',
      },
      {
        'time': '05:00 PM',
        'title': 'Paseo en catamarán',
        'description':
            'Navega por la costa al atardecer. Incluye bebidas y música.',
        'status': 'pendiente',
      },
    ],
    'Día 3': [
      {
        'time': '08:30 AM',
        'title': 'Desayuno continental',
        'description': 'Desayuno ligero antes de la excursión del día.',
        'status': 'pendiente',
      },
      {
        'time': '10:00 AM',
        'title': 'Excursión a Chichén Itzá',
        'description':
            'Visita una de las 7 maravillas del mundo moderno. Tour guiado completo.',
        'status': 'pendiente',
      },
      {
        'time': '01:30 PM',
        'title': 'Comida en ruta',
        'description': 'Almuerzo incluido durante la excursión.',
        'status': 'pendiente',
      },
      {
        'time': '06:00 PM',
        'title': 'Regreso al hotel',
        'description': 'Tiempo libre para descansar.',
        'status': 'pendiente',
      },
      {
        'time': '08:00 PM',
        'title': 'Cena de despedida',
        'description': 'Última cena del viaje con show cultural mexicano.',
        'status': 'pendiente',
      },
    ],
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: _activitiesByDay.keys.length,
      vsync: this,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> _getFilteredActivities(String day) {
    final activities = _activitiesByDay[day] ?? [];
    if (_selectedFilter == 'Todas') {
      return activities;
    }
    return activities
        .where(
          (activity) => activity['status'] == _selectedFilter.toLowerCase(),
        )
        .toList();
  }

  Map<String, int> _getStatusCounts(String day) {
    final activities = _activitiesByDay[day] ?? [];
    return {
      'terminada': activities.where((a) => a['status'] == 'terminada').length,
      'en_curso': activities.where((a) => a['status'] == 'en_curso').length,
      'pendiente': activities.where((a) => a['status'] == 'pendiente').length,
    };
  }

  double _getProgress(String day) {
    final activities = _activitiesByDay[day] ?? [];
    if (activities.isEmpty) return 0.0;
    final completed = activities
        .where((a) => a['status'] == 'terminada')
        .length;
    return completed / activities.length;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final currentDay = _activitiesByDay.keys.elementAt(_tabController.index);
    final filteredActivities = _getFilteredActivities(currentDay);
    final statusCounts = _getStatusCounts(currentDay);
    final progress = _getProgress(currentDay);

    return Column(
      children: [
        // Trip Card
        Container(
          margin: const EdgeInsets.all(AppSpacing.md),
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(AppBorderRadius.md),
            border: Border.all(color: theme.dividerColor),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(AppBorderRadius.sm),
                ),
                child: Icon(Icons.image, size: 35, color: theme.iconTheme.color),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            l10n.active,
                            style: const TextStyle(
                              fontSize: 11,
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Cancún-Tulum',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      l10n.allIncluded,
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Tabs de días
        Container(
          margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(AppBorderRadius.sm),
          ),
          child: TabBar(
            controller: _tabController,
            labelColor: theme.colorScheme.onPrimary,
            unselectedLabelColor: theme.colorScheme.onSurfaceVariant,
            indicator: BoxDecoration(
              color: theme.colorScheme.primary,
              borderRadius: BorderRadius.circular(AppBorderRadius.sm),
            ),
            indicatorSize: TabBarIndicatorSize.tab,
            dividerColor: Colors.transparent,
            onTap: (index) => setState(() {}),
            tabs: _activitiesByDay.keys
                .map(
                  (day) => Tab(
                    child: Text(
                      day,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ),
                )
                .toList(),
          ),
        ),

        const SizedBox(height: AppSpacing.md),

        // Progress indicator
        Container(
          margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(AppBorderRadius.sm),
            border: Border.all(color: theme.dividerColor),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    l10n.dayProgress,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '${(progress * 100).toStringAsFixed(0)}%',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 8,
                  backgroundColor: theme.colorScheme.surfaceContainerHighest,
                  valueColor: AlwaysStoppedAnimation<Color>(theme.colorScheme.primary),
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8.0,
                runSpacing: 8.0,
                alignment: WrapAlignment.spaceAround,
                children: [
                  _buildStatusBadge(
                    '✓ ${statusCounts['terminada']}',
                    Colors.green,
                  ),
                  _buildStatusBadge(
                    '⟳ ${statusCounts['en_curso']}',
                    Colors.orange,
                  ),
                  _buildStatusBadge(
                    '○ ${statusCounts['pendiente']}',
                    Colors.grey,
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: AppSpacing.md),

        // Filtros
        Container(
          height: 40,
          margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              _buildFilterChip('Todas', l10n.all),
              const SizedBox(width: 8),
              _buildFilterChip('Terminada', l10n.finished),
              const SizedBox(width: 8),
              _buildFilterChip('En_curso', l10n.inProgress),
              const SizedBox(width: 8),
              _buildFilterChip('Pendiente', l10n.pending),
            ],
          ),
        ),

        const SizedBox(height: AppSpacing.md),

        // Lista de actividades
        Expanded(
          child: filteredActivities.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.filter_list_off,
                        size: 48,
                        color: theme.disabledColor,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l10n.noActivities,
                        style: TextStyle(color: theme.disabledColor),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                  ),
                  itemCount: filteredActivities.length,
                  itemBuilder: (context, index) {
                    final activity = filteredActivities[index];
                    return _buildActivityCard(activity, index);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildStatusBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  Widget _buildFilterChip(String filterKey, String label) {
    final theme = Theme.of(context);
    final isSelected = _selectedFilter == filterKey;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedFilter = filterKey;
        });
      },
      selectedColor: theme.colorScheme.primary.withValues(alpha: 0.2),
      checkmarkColor: theme.colorScheme.primary,
      labelStyle: TextStyle(
        color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurface,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        fontSize: 12,
      ),
      backgroundColor: theme.cardColor,
      side: BorderSide(
        color: isSelected ? theme.colorScheme.primary : theme.dividerColor,
      ),
    );
  }

  Widget _buildActivityCard(Map<String, dynamic> activity, int index) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final status = activity['status'] as String;
    Color statusColor;
    String statusLabel;
    IconData statusIcon;

    switch (status) {
      case 'terminada':
        statusColor = Colors.green;
        statusLabel = l10n.finished;
        statusIcon = Icons.check_circle;
        break;
      case 'en_curso':
        statusColor = Colors.orange;
        statusLabel = l10n.inProgress;
        statusIcon = Icons.play_circle;
        break;
      case 'pendiente':
      default:
        statusColor = Colors.grey;
        statusLabel = l10n.pending;
        statusIcon = Icons.circle_outlined;
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ActivityDetailScreen(
                activityTitle: activity['title'],
                activityTime: activity['time'],
                activityDescription: activity['description'],
              ),
            ),
          );
        },
        borderRadius: BorderRadius.circular(AppBorderRadius.md),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(AppBorderRadius.md),
            border: Border.all(
              color: status == 'en_curso'
                  ? statusColor.withValues(alpha: 0.5)
                  : theme.dividerColor,
              width: status == 'en_curso' ? 2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Status icon
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(statusIcon, color: statusColor, size: 24),
              ),

              const SizedBox(width: AppSpacing.md),

              // Activity info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      crossAxisAlignment: WrapCrossAlignment.center,
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            activity['time'],
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: statusColor,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            statusLabel,
                            style: const TextStyle(
                              fontSize: 10,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      activity['title'],
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      activity['description'],
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),

              const SizedBox(width: AppSpacing.sm),

              // Arrow icon
              Icon(Icons.arrow_forward_ios, size: 14, color: theme.disabledColor),
            ],
          ),
        ),
      ),
    );
  }
}
