import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/core/di/service_locator.dart';
import 'package:frontend/core/l10n/app_localizations.dart';
import 'package:frontend/core/theme/app_constants.dart';
import 'package:frontend/features/turista/home/domain/entities/activity.dart';
import 'package:frontend/features/turista/home/presentation/bloc/trip_bloc.dart';
import 'package:frontend/features/turista/home/presentation/bloc/trip_event.dart';
import 'package:frontend/features/turista/home/presentation/bloc/trip_state.dart';
import 'package:frontend/features/turista/home/presentation/screens/activity_detail_screen.dart';

class TripHomeScreen extends StatelessWidget {
  const TripHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<TripBloc>()..add(TripStarted()),
      child: const _TripHomeView(),
    );
  }
}

class _TripHomeView extends StatefulWidget {
  const _TripHomeView();

  @override
  State<_TripHomeView> createState() => _TripHomeViewState();
}

class _TripHomeViewState extends State<_TripHomeView>
    with TickerProviderStateMixin {
  TabController? _tabController;

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  // Helper to filter activities based on selected filter
  List<Activity> _filterActivities(List<Activity> activities, String filter) {
    if (filter == 'Todas') {
      final sorted = List<Activity>.from(activities);
      // Sort logic: 'inProgress' first
      sorted.sort((a, b) {
        if (a.status == ActivityStatus.inProgress &&
            b.status != ActivityStatus.inProgress) {
          return -1;
        }
        if (a.status != ActivityStatus.inProgress &&
            b.status == ActivityStatus.inProgress) {
          return 1;
        }
        return 0;
      });
      return sorted;
    }

    ActivityStatus statusFilter;
    if (filter == 'Terminada') {
      statusFilter = ActivityStatus.finished;
    } else if (filter == 'En_curso') {
      statusFilter = ActivityStatus.inProgress;
    } else {
      statusFilter = ActivityStatus.pending;
    }

    return activities.where((a) => a.status == statusFilter).toList();
  }

  Map<String, int> _getStatusCounts(List<Activity> activities) {
    return {
      'terminada':
          activities.where((a) => a.status == ActivityStatus.finished).length,
      'en_curso':
          activities.where((a) => a.status == ActivityStatus.inProgress).length,
      'pendiente':
          activities.where((a) => a.status == ActivityStatus.pending).length,
    };
  }

  double _getProgress(List<Activity> activities) {
    if (activities.isEmpty) return 0.0;
    final completed =
        activities.where((a) => a.status == ActivityStatus.finished).length;
    return completed / activities.length;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return BlocConsumer<TripBloc, TripState>(
      listener: (context, state) {
        if (state is TripLoaded && _tabController == null) {
          _tabController = TabController(
            length: state.trip.days.length,
            vsync: this,
          );
          _tabController?.addListener(() {
            if (_tabController!.indexIsChanging) {
              final newDay = state.trip.days[_tabController!.index];
              context.read<TripBloc>().add(TripDayChanged(newDay));
            }
          });
        }
      },
      builder: (context, state) {
        if (state is TripLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is TripError) {
          return Center(child: Text(state.message));
        } else if (state is TripLoaded) {
          final trip = state.trip;
          final currentDayActivities =
              trip.activitiesByDay[state.selectedDay] ?? [];
          final filteredActivities = _filterActivities(
            currentDayActivities,
            state.selectedFilter,
          );
          final statusCounts = _getStatusCounts(currentDayActivities);
          final progress = _getProgress(currentDayActivities);

          // Ensure tab controller index matches selected day (for initial load)
          if (_tabController != null && trip.days.contains(state.selectedDay)) {
            final index = trip.days.indexOf(state.selectedDay);
            if (_tabController!.index != index) {
              _tabController!.animateTo(index);
            }
          }

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
                      child: Icon(
                        Icons.image,
                        size: 35,
                        color: theme.iconTheme.color,
                      ),
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
                            trip.title,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            trip.description,
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Tabs de días
              if (_tabController != null)
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
                    onTap: (index) {
                      // Add event handled by listener, but explicit tap safe too
                      final newDay = trip.days[index];
                      context.read<TripBloc>().add(TripDayChanged(newDay));
                    },
                    tabs:
                        trip.days
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
                        backgroundColor:
                            theme.colorScheme.surfaceContainerHighest,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          theme.colorScheme.primary,
                        ),
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
                    _buildFilterChip(
                      context,
                      'Todas',
                      l10n.all,
                      state.selectedFilter,
                    ),
                    const SizedBox(width: 8),
                    _buildFilterChip(
                      context,
                      'Terminada',
                      l10n.finished,
                      state.selectedFilter,
                    ),
                    const SizedBox(width: 8),
                    _buildFilterChip(
                      context,
                      'En_curso',
                      l10n.inProgress,
                      state.selectedFilter,
                    ),
                    const SizedBox(width: 8),
                    _buildFilterChip(
                      context,
                      'Pendiente',
                      l10n.pending,
                      state.selectedFilter,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppSpacing.md),

              // Lista de actividades
              Expanded(
                child:
                    filteredActivities.isEmpty
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
                            return ActivityCard(activity: activity);
                          },
                        ),
              ),
            ],
          );
        }
        return const SizedBox.shrink();
      },
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

  Widget _buildFilterChip(
    BuildContext context,
    String filterKey,
    String label,
    String selectedFilter,
  ) {
    final theme = Theme.of(context);
    final isSelected = selectedFilter == filterKey;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        context.read<TripBloc>().add(TripFilterChanged(filterKey));
      },
      selectedColor: theme.colorScheme.primary.withValues(alpha: 0.2),
      checkmarkColor: theme.colorScheme.primary,
      labelStyle: TextStyle(
        color:
            isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.onSurface,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
        fontSize: 12,
      ),
      backgroundColor: theme.cardColor,
      side: BorderSide(
        color: isSelected ? theme.colorScheme.primary : theme.dividerColor,
      ),
    );
  }
}

class ActivityCard extends StatefulWidget {
  final Activity activity;

  const ActivityCard({super.key, required this.activity});

  @override
  State<ActivityCard> createState() => _ActivityCardState();
}

class _ActivityCardState extends State<ActivityCard> {
  bool _showDescription = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final status = widget.activity.status;
    Color statusColor;
    String statusLabel;
    IconData statusIcon;

    switch (status) {
      case ActivityStatus.finished:
        statusColor = Colors.green;
        statusLabel = l10n.finished;
        statusIcon = Icons.check_circle;
        break;
      case ActivityStatus.inProgress:
        statusColor = Colors.orange;
        statusLabel = l10n.inProgress;
        statusIcon = Icons.play_circle;
        break;
      case ActivityStatus.pending:
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
              builder:
                  (context) => ActivityDetailScreen(
                    activityTitle: widget.activity.title,
                    activityTime: widget.activity.time,
                    activityDescription: widget.activity.description,
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
              color:
                  status == ActivityStatus.inProgress
                      ? statusColor.withValues(alpha: 0.5)
                      : theme.dividerColor,
              width: status == ActivityStatus.inProgress ? 2 : 1,
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
                            color: theme.colorScheme.primary.withValues(
                              alpha: 0.1,
                            ),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            widget.activity.time,
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
                      widget.activity.title,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 4),
                    if (_showDescription)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 8),
                          Text(
                            widget.activity.description,
                            style: theme.textTheme.bodySmall,
                          ),
                          const SizedBox(height: 12),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _showDescription = false;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                vertical: 4,
                                horizontal: 8,
                              ),
                              child: Text(
                                'Ver menos',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      )
                    else
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: GestureDetector(
                          onTap: () {
                            // Prevent triggering the parent InkWell
                            setState(() {
                              _showDescription = true;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              vertical: 4,
                              horizontal: 0,
                            ),
                            child: Text(
                              'Ver más detalles...',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              const SizedBox(width: AppSpacing.sm),

              // Arrow icon for navigation
              Icon(
                Icons.arrow_forward_ios,
                size: 14,
                color: theme.disabledColor,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
