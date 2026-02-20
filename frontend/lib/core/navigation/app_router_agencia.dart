import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/core/di/service_locator.dart' as di;
import 'routes_agencia.dart';
import '../../features/agencia/trips/domain/entities/viaje.dart';

// Importa tus Widgets de Pantalla
import '../../features/agencia/auth/presentation/screens/login_screen.dart';
import '../../features/agencia/dashboard/presentation/screens/dashboard_screen.dart';
import '../../features/agencia/trips/presentation/screens/trips_screen.dart';
import '../../features/agencia/trips/presentation/screens/trip_detail_screen.dart';
import '../../features/agencia/trips/presentation/screens/trip_creation_screen.dart';
import '../../features/agencia/trips/presentation/screens/itinerary_builder_screen.dart';
import '../../features/agencia/users/presentation/screens/users_screen.dart';
import '../../features/agencia/audit/presentation/screens/audit_screen.dart';
import '../../features/agencia/settings/presentation/screens/settings_screen.dart';
import '../../features/agencia/shared/presentation/widgets/agency_layout.dart'; // Layout actualizado

// Importa tus BLoCs
import '../../features/agencia/dashboard/presentation/blocs/dashboard/dashboard_bloc.dart';
import '../../features/agencia/trips/presentation/blocs/viajes/viajes_bloc.dart';
import '../../features/agencia/trips/presentation/blocs/detalle_viaje/detalle_viaje_bloc.dart';
import '../../features/agencia/users/presentation/blocs/usuarios/usuarios_bloc.dart';
import '../../features/agencia/audit/presentation/blocs/auditoria/auditoria_bloc.dart';

class AppRouterAgencia {
  static final GlobalKey<NavigatorState> _rootNavigatorKey =
      GlobalKey<NavigatorState>();

  static final GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: RoutesAgencia.login,
    routes: [
      // 1. RUTAS PÚBLICAS
      GoRoute(
        path: RoutesAgencia.root,
        redirect: (_, __) => RoutesAgencia.dashboard,
      ),
      GoRoute(
        path: RoutesAgencia.login,
        builder: (context, state) => const AgencyLoginScreen(),
      ),

      // 2. STATEFUL SHELL ROUTE (Tabs persistentes)
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return AgencyLayout(navigationShell: navigationShell);
        },
        branches: [
          // A. DASHBOARD
          StatefulShellBranch(
            // navigatorKey: _dashboardNavigatorKey,
            routes: [
              GoRoute(
                path: RoutesAgencia.dashboard,
                pageBuilder:
                    (context, state) => NoTransitionPage(
                      child: BlocProvider(
                        create:
                            (_) =>
                                di.sl<DashboardBloc>()
                                  ..add(LoadDashboardData()),
                        child: const DashboardScreen(),
                      ),
                    ),
              ),
            ],
          ),

          // B. GESTIÓN DE VIAJES
          StatefulShellBranch(
            // navigatorKey: _viajesNavigatorKey,
            routes: [
              GoRoute(
                path: RoutesAgencia.viajes,
                pageBuilder: (context, state) {
                  final filter = state.uri.queryParameters['filter'];
                  return NoTransitionPage(
                    child: BlocProvider(
                      create:
                          (_) =>
                              di.sl<ViajesBloc>()..add(
                                LoadViajesEvent(
                                  filterStatus:
                                      filter != null
                                          ? filter.toUpperCase()
                                          : 'TODOS',
                                ),
                              ),
                      child: const TripsScreen(),
                    ),
                  );
                },
                routes: [
                  GoRoute(
                    path: 'nuevo',
                    builder: (context, state) => const TripCreationScreen(),
                  ),
                  GoRoute(
                    path: 'itinerary-builder',
                    builder: (context, state) {
                      final Viaje viaje = state.extra as Viaje;
                      return ItineraryBuilderScreen(viajeBase: viaje);
                    },
                  ),
                  GoRoute(
                    path: ':id',
                    builder: (context, state) {
                      final viajeId = state.pathParameters['id']!;
                      final section = state.uri.queryParameters['section'];
                      final returnTo = state.uri.queryParameters['return_to'];
                      final alertFocus =
                          state.uri.queryParameters['alert_focus'];

                      return BlocProvider(
                        create: (_) => di.sl<DetalleViajeBloc>(),
                        child: TripDetailScreen(
                          viajeId: viajeId,
                          highlightSection: section,
                          returnTo: returnTo,
                          alertFocus: alertFocus,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),

          // C. USUARIOS
          StatefulShellBranch(
            // navigatorKey: _usuariosNavigatorKey,
            routes: [
              GoRoute(
                path: RoutesAgencia.usuarios,
                pageBuilder: (context, state) {
                  final activeTab = state.uri.queryParameters['tab'] ?? 'guias';
                  return NoTransitionPage(
                    child: BlocProvider(
                      create:
                          (_) =>
                              di.sl<UsuariosBloc>()..add(LoadUsuariosEvent()),
                      child: UsersScreen(initialTab: activeTab),
                    ),
                  );
                },
              ),
            ],
          ),

          // D. AUDITORÍA
          StatefulShellBranch(
            // navigatorKey: _auditoriaNavigatorKey,
            routes: [
              GoRoute(
                path: RoutesAgencia.auditoria,
                pageBuilder: (context, state) {
                  final nivel = state.uri.queryParameters['nivel'];
                  return NoTransitionPage(
                    child: BlocProvider(
                      create:
                          (_) =>
                              di.sl<AuditoriaBloc>()
                                ..add(LoadAuditoriaEvent(filterNivel: nivel)),
                      child: const AuditScreen(),
                    ),
                  );
                },
              ),
            ],
          ),

          // E. CONFIGURACIÓN
          StatefulShellBranch(
            // navigatorKey: _configNavigatorKey,
            routes: [
              GoRoute(
                path: RoutesAgencia.configuracion,
                pageBuilder:
                    (context, state) =>
                        const NoTransitionPage(child: SettingsScreen()),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}
