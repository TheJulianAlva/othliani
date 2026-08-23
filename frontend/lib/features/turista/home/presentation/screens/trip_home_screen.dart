import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/core/demo/demo_config.dart';
import 'package:frontend/core/di/service_locator.dart';
import 'package:frontend/core/l10n/app_localizations.dart';
import 'package:frontend/core/navigation/routes_turista.dart';
import 'package:frontend/core/theme/app_constants.dart';
import 'package:frontend/core/theme/veltur_tokens.dart';
import 'package:frontend/features/turista/home/domain/entities/activity.dart';
import 'package:frontend/features/turista/home/presentation/bloc/trip_bloc.dart';
import 'package:frontend/features/turista/home/presentation/bloc/trip_event.dart';
import 'package:frontend/features/turista/home/presentation/bloc/trip_state.dart';
import 'package:frontend/features/turista/home/presentation/screens/activity_detail_screen.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

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
  GoogleMapController? _mapController;
  final LatLng _center = const LatLng(
    20.2114,
    -87.4654,
  );

  io.Socket? socket;

  @override
  void initState() {
    super.initState();
    _requestLocationPermission();
    _conectarAlWebSocket();
  }

  void _conectarAlWebSocket() {
    final serverUrl = kDemoMode ? kDemoServerUrl : 'http://10.170.6.0:3000';
    socket = io.io(serverUrl, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': true,
    });

    socket!.onConnect((_) {
      debugPrint('Turista conectado a la Torre de Control 🗼');
      socket!.emit('unirseAlViaje', {'viaje_id': 'viaje_123', 'folio': 'GTO-4'});
    });

    socket!.onConnectError((err) {
      debugPrint('Turista socket connect error: $err');
    });

    socket!.onError((err) {
      debugPrint('Turista socket error: $err');
    });

    socket!.onDisconnect((_) {
      debugPrint('Turista desconectado del socket');
    });

    socket!.on('alertaAmarilla', (data) {
      debugPrint('Turista recibió alertaAmarilla: $data');
      _mostrarAlertaEnPantalla(data['mensaje']);
    });
  }

  void _mostrarAlertaEnPantalla(String mensaje) {
    final tokens = VelturTokens.of(context);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(tokens.radiusLg),
        ),
        backgroundColor: tokens.warnSoft,
        title: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: tokens.warn, size: 30),
            const SizedBox(width: 10),
            Text(
              "¡Aviso Importante!",
              style: TextStyle(color: tokens.warn, fontWeight: FontWeight.w600),
            ),
          ],
        ),
        content: Text(
          mensaje,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: tokens.warn),
            onPressed: () {
              Navigator.of(dialogContext).pop();
              context.read<TripBloc>().add(TripStarted());
            },
            child: const Text("Entendido"),
          ),
        ],
      ),
    );
  }

  Future<void> _requestLocationPermission() async {
    final status = await Permission.locationWhenInUse.request();
    if (status.isDenied || status.isPermanentlyDenied) {
      debugPrint('TripHomeScreen: location permission denied');
    }
  }

  @override
  void dispose() {
    _tabController?.dispose();
    _mapController?.dispose();
    socket?.disconnect();
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
    final tokens = VelturTokens.of(context);

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

          final inProgressActivity =
              currentDayActivities
                  .where((a) => a.status == ActivityStatus.inProgress)
                  .firstOrNull;

          return Stack(
            children: [
              // Fondo Interactivo de Mapa
              Positioned.fill(
                child: GoogleMap(
                  onMapCreated: (controller) => _mapController = controller,
                  initialCameraPosition: CameraPosition(
                    target: _center,
                    zoom: 14.0,
                  ),
                  myLocationEnabled: true,
                  myLocationButtonEnabled: false,
                  zoomControlsEnabled: false,
                  markers: {
                    Marker(
                      markerId: const MarkerId('tourist'),
                      position: const LatLng(20.2114, -87.4654),
                      icon: BitmapDescriptor.defaultMarkerWithHue(
                        BitmapDescriptor.hueAzure,
                      ),
                    ),
                    Marker(
                      markerId: const MarkerId('guide'),
                      position: const LatLng(20.2090, -87.4500),
                      icon: BitmapDescriptor.defaultMarkerWithHue(
                        BitmapDescriptor.hueOrange,
                      ),
                    ),
                  },
                ),
              ),

              // Panel Deslizable
              DraggableScrollableSheet(
                initialChildSize: 0.95,
                minChildSize: 0.15,
                maxChildSize: 0.95,
                snap: true,
                builder: (context, scrollController) {
                  return Container(
                    decoration: BoxDecoration(
                      color: theme.scaffoldBackgroundColor,
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(tokens.radiusLg),
                      ),
                      boxShadow: [
                        BoxShadow(
                          // Warm shadow tint (shadow-lg) at this panel's
                          // upward offset — the token list's own offsets
                          // point downward, so only the tint colour is
                          // reused here, not the geometry.
                          color: tokens.shadowLg.first.color,
                          blurRadius: 10,
                          offset: const Offset(0, -5),
                        ),
                      ],
                    ),
                    child: CustomScrollView(
                      controller: scrollController,
                      slivers: [
                        // Pill handle
                        SliverToBoxAdapter(
                          child: Center(
                            child: Container(
                              margin: const EdgeInsets.symmetric(vertical: 12),
                              width: 40,
                              height: 5,
                              decoration: BoxDecoration(
                                color: tokens.border,
                                borderRadius: BorderRadius.circular(
                                  tokens.radiusFull,
                                ),
                              ),
                            ),
                          ),
                        ),

                        SliverToBoxAdapter(
                          child: Column(
                            children: [
                              if (inProgressActivity != null)
                                Container(
                                  margin: const EdgeInsets.all(AppSpacing.md),
                                  padding: const EdgeInsets.all(20),
                                  decoration: BoxDecoration(
                                    color: theme.primaryColor,
                                    borderRadius: BorderRadius.circular(
                                      tokens.radiusXl,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: theme.primaryColor.withValues(
                                          alpha: 0.3,
                                        ),
                                        blurRadius: 12,
                                        offset: const Offset(0, 4),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          const Text(
                                            'ACTIVIDAD EN CURSO',
                                            style: TextStyle(
                                              color: Colors.white70,
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                              letterSpacing: 1.2,
                                            ),
                                          ),
                                          Row(
                                            children: [
                                              Icon(
                                                Icons.wb_sunny,
                                                color: tokens.warn,
                                                size: 16,
                                              ),
                                              const SizedBox(width: 4),
                                              const Text(
                                                '32°C',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 12,
                                                ),
                                              ),
                                              const SizedBox(width: 12),
                                              const Icon(
                                                Icons.checkroom,
                                                color: Colors.white,
                                                size: 16,
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        inProgressActivity.title,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 22,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 24),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 16,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withValues(
                                            alpha: 0.1,
                                          ),
                                          borderRadius: BorderRadius.circular(
                                            tokens.radiusMd,
                                          ),
                                        ),
                                        child: const Center(
                                          child: Column(
                                            children: [
                                              Text(
                                                '⏱️ Tiempo Libre',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                              SizedBox(height: 8),
                                              Text(
                                                'Faltan 45 min para regresar',
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              else
                                // Trip Card
                                Container(
                                  margin: const EdgeInsets.all(AppSpacing.md),
                                  padding: const EdgeInsets.all(AppSpacing.md),
                                  decoration: BoxDecoration(
                                    color: theme.cardColor,
                                    borderRadius: BorderRadius.circular(
                                      tokens.radiusXl,
                                    ),
                                    border: Border.all(
                                      color: theme.dividerColor,
                                    ),
                                    boxShadow: tokens.shadowSm,
                                  ),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 80,
                                        height: 80,
                                        decoration: BoxDecoration(
                                          color: tokens.surfaceWarm,
                                          borderRadius: BorderRadius.circular(
                                            tokens.radiusMd,
                                          ),
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
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Wrap(
                                              children: [
                                                Container(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                        horizontal: 8,
                                                        vertical: 4,
                                                      ),
                                                  decoration: BoxDecoration(
                                                    color: tokens.safeSoft,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          tokens.radiusFull,
                                                        ),
                                                  ),
                                                  child: Text(
                                                    l10n.active,
                                                    style: TextStyle(
                                                      fontSize: 11,
                                                      color: tokens.safe,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              trip.title,
                                              style: theme.textTheme.titleMedium
                                                  ?.copyWith(
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
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: AppSpacing.md,
                                  ),
                                  decoration: BoxDecoration(
                                    color: tokens.surfaceWarm,
                                    borderRadius: BorderRadius.circular(
                                      tokens.radiusMd,
                                    ),
                                  ),
                                  child: TabBar(
                                    controller: _tabController,
                                    labelColor: theme.colorScheme.onPrimary,
                                    unselectedLabelColor:
                                        theme.colorScheme.onSurfaceVariant,
                                    indicator: BoxDecoration(
                                      color: theme.colorScheme.primary,
                                      borderRadius: BorderRadius.circular(
                                        tokens.radiusMd,
                                      ),
                                    ),
                                    indicatorSize: TabBarIndicatorSize.tab,
                                    dividerColor: Colors.transparent,
                                    onTap: (index) {
                                      // Add event handled by listener, but explicit tap safe too
                                      final newDay = trip.days[index];
                                      context.read<TripBloc>().add(
                                        TripDayChanged(newDay),
                                      );
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
                                margin: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.md,
                                ),
                                padding: const EdgeInsets.all(AppSpacing.md),
                                decoration: BoxDecoration(
                                  color: theme.cardColor,
                                  borderRadius: BorderRadius.circular(
                                    tokens.radiusMd,
                                  ),
                                  border: Border.all(color: theme.dividerColor),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          l10n.dayProgress,
                                          style: theme.textTheme.bodyMedium
                                              ?.copyWith(
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
                                      borderRadius: BorderRadius.circular(
                                        tokens.radiusSm,
                                      ),
                                      child: LinearProgressIndicator(
                                        value: progress,
                                        minHeight: 8,
                                        backgroundColor: tokens.surfaceWarm,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
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
                                          context,
                                          '✓ ${statusCounts['terminada']}',
                                          tokens.safe,
                                        ),
                                        _buildStatusBadge(
                                          context,
                                          '⟳ ${statusCounts['en_curso']}',
                                          tokens.warn,
                                        ),
                                        _buildStatusBadge(
                                          context,
                                          '○ ${statusCounts['pendiente']}',
                                          tokens.textMuted,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: AppSpacing.md),

                              // Encabezado + botón de mapa
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.md,
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Actividades',
                                      style: theme.textTheme.titleSmall
                                          ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                    ),
                                    TextButton.icon(
                                      onPressed: () => context.push(
                                        RoutesTurista.itineraryMap,
                                      ),
                                      icon: const Icon(
                                        Icons.map_outlined,
                                        size: 16,
                                      ),
                                      label: const Text('Ver en mapa'),
                                      style: TextButton.styleFrom(
                                        tapTargetSize:
                                            MaterialTapTargetSize.shrinkWrap,
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 4),

                              // Filtros
                              Container(
                                height: 40,
                                margin: const EdgeInsets.symmetric(
                                  horizontal: AppSpacing.md,
                                ),
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
                            ],
                          ),
                        ),

                        // Lista de actividades
                        filteredActivities.isEmpty
                            ? SliverToBoxAdapter(
                              child: Center(
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 40),
                                  child: Column(
                                    children: [
                                      Icon(
                                        Icons.filter_list_off,
                                        size: 48,
                                        color: theme.disabledColor,
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        l10n.noActivities,
                                        style: TextStyle(
                                          color: theme.disabledColor,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            )
                            : SliverPadding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.md,
                              ),
                              sliver: SliverList(
                                delegate: SliverChildBuilderDelegate((
                                  context,
                                  index,
                                ) {
                                  final activity = filteredActivities[index];
                                  return ActivityCard(activity: activity);
                                }, childCount: filteredActivities.length),
                              ),
                            ),

                        // Padding final para que el FAB no tape el ultimo elemento
                        const SliverToBoxAdapter(child: SizedBox(height: 80)),
                      ],
                    ),
                  );
                },
              ),
            ],
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildStatusBadge(BuildContext context, String label, Color color) {
    final theme = Theme.of(context);
    final tokens = VelturTokens.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(tokens.radiusSm),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelLarge?.copyWith(color: color),
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
    final tokens = VelturTokens.of(context);
    final isSelected = selectedFilter == filterKey;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        context.read<TripBloc>().add(TripFilterChanged(filterKey));
      },
      selectedColor: theme.colorScheme.primary.withValues(alpha: 0.2),
      checkmarkColor: theme.colorScheme.primary,
      labelStyle: theme.textTheme.labelLarge?.copyWith(
        color:
            isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.onSurface,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
      backgroundColor: theme.cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(tokens.radiusFull),
        side: BorderSide(
          color: isSelected ? theme.colorScheme.primary : theme.dividerColor,
        ),
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
    final tokens = VelturTokens.of(context);
    final l10n = AppLocalizations.of(context)!;
    final status = widget.activity.status;
    Color statusColor;
    String statusLabel;
    IconData statusIcon;

    switch (status) {
      case ActivityStatus.finished:
        statusColor = tokens.safe;
        statusLabel = l10n.finished;
        statusIcon = Icons.check_circle;
        break;
      case ActivityStatus.inProgress:
        statusColor = tokens.warn;
        statusLabel = l10n.inProgress;
        statusIcon = Icons.play_circle;
        break;
      case ActivityStatus.pending:
        statusColor = tokens.textMuted;
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
        borderRadius: BorderRadius.circular(tokens.radiusMd),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(tokens.radiusMd),
            border: Border.all(
              color:
                  status == ActivityStatus.inProgress
                      ? statusColor.withValues(alpha: 0.5)
                      : theme.dividerColor,
              width: status == ActivityStatus.inProgress ? 2 : 1,
            ),
            boxShadow: tokens.shadowSm,
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
                          Row(
                            children: [
                              Icon(
                                Icons.wb_sunny,
                                size: 18,
                                color: tokens.warn,
                              ),
                              const SizedBox(width: 4),
                              Text('32°C', style: theme.textTheme.bodySmall),
                              const SizedBox(width: 16),
                              Icon(
                                Icons.checkroom,
                                size: 18,
                                color: tokens.textMuted,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Ropa cómoda',
                                style: theme.textTheme.bodySmall,
                              ),
                            ],
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
