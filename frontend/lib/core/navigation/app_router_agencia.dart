import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../injection_container.dart' as di;
import 'routes_agencia.dart';

// Importa tus Widgets de Pantalla
import '../../features/agencia/auth/presentation/screens/login_screen.dart';
import '../../presentation_agencia/screens/dashboard/dashboard_screen.dart';
import '../../presentation_agencia/screens/trips/trips_screen.dart';
import '../../presentation_agencia/screens/trips/trip_detail_screen.dart';
import '../../presentation_agencia/screens/trips/trip_creation_screen.dart';
import '../../presentation_agencia/screens/users/users_screen.dart';
import '../../presentation_agencia/screens/audit/audit_screen.dart';
import '../../presentation_agencia/screens/settings/settings_screen.dart';
import '../../presentation_agencia/widgets/shared/agency_layout.dart'; // Tu Layout con Sidebar

// Importa tus BLoCs
import '../../features/agencia/dashboard/blocs/dashboard/dashboard_bloc.dart';
import '../../features/agencia/trips/blocs/viajes/viajes_bloc.dart';
import '../../features/agencia/trips/blocs/detalle_viaje/detalle_viaje_bloc.dart';
import '../../features/agencia/users/blocs/usuarios/usuarios_bloc.dart';
import '../../features/agencia/audit/blocs/auditoria/auditoria_bloc.dart';

class AppRouterAgencia {
  static final GlobalKey<NavigatorState> _rootNavigatorKey =
      GlobalKey<NavigatorState>();
  static final GlobalKey<NavigatorState> _shellNavigatorKey =
      GlobalKey<NavigatorState>();

  static final GoRouter router = GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: RoutesAgencia.login, // Empieza en Login
    routes: [
      // 1. RUTAS PÚBLICAS (Sin Sidebar)
      GoRoute(
        path: RoutesAgencia.root,
        redirect: (_, __) => RoutesAgencia.dashboard,
      ),
      GoRoute(
        path: RoutesAgencia.login,
        builder: (context, state) => const AgencyLoginScreen(),
      ),

      // 2. SHELL ROUTE (Layout con Sidebar Persistente)
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        // Este builder envuelve todas las rutas hijas con tu AgencyLayout
        builder: (context, state, child) {
          // Calculamos qué item del menú está activo según la URL
          String activeItem = 'Dashboard';
          final uri = state.uri.toString();
          if (uri.contains('viajes')) activeItem = 'Viajes';
          if (uri.contains('usuarios')) activeItem = 'Usuarios';
          if (uri.contains('auditoria')) activeItem = 'Auditoría';
          if (uri.contains('configuracion')) activeItem = 'Configuración';

          return AgencyLayout(activeItem: activeItem, child: child);
        },
        routes: [
          // A. DASHBOARD
          GoRoute(
            path: RoutesAgencia.dashboard,
            pageBuilder:
                (context, state) => NoTransitionPage(
                  child: BlocProvider(
                    // Inyectamos y cargamos datos AL ENTRAR
                    create:
                        (_) => di.sl<DashboardBloc>()..add(LoadDashboardData()),
                    child: const DashboardScreen(),
                  ),
                ),
          ),

          // B. GESTIÓN DE VIAJES
          GoRoute(
            path: RoutesAgencia.viajes,
            pageBuilder: (context, state) {
              // Leemos si hay filtro en la URL: /viajes?filter=en_curso
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
              // 1. NUEVO VIAJE (Antes de :id para evitar conflicto)
              GoRoute(
                path: 'nuevo',
                builder: (context, state) => const TripCreationScreen(),
              ),

              // 2. DETALLE (/viajes/:id)
              GoRoute(
                path: ':id', // Parámetro dinámico
                builder: (context, state) {
                  final viajeId = state.pathParameters['id']!;
                  final section = state.uri.queryParameters['section'];
                  final returnTo = state.uri.queryParameters['return_to'];
                  final alertFocus =
                      state.uri.queryParameters['alert_focus']; // <--- NUEVO

                  return BlocProvider(
                    create: (_) => di.sl<DetalleViajeBloc>(),
                    child: TripDetailScreen(
                      viajeId: viajeId,
                      highlightSection: section,
                      returnTo: returnTo,
                      alertFocus: alertFocus, // <--- Pasamos al widget
                    ),
                  );
                },
              ),
            ],
          ),

          // C. USUARIOS
          GoRoute(
            path: RoutesAgencia.usuarios,
            pageBuilder: (context, state) {
              // Leemos la tab activa: /usuarios?tab=clientes
              final activeTab = state.uri.queryParameters['tab'] ?? 'guias';

              return NoTransitionPage(
                child: BlocProvider(
                  create:
                      (_) => di.sl<UsuariosBloc>()..add(LoadUsuariosEvent()),
                  child: UsersScreen(initialTab: activeTab),
                ),
              );
            },
          ),

          // D. AUDITORÍA
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

          // E. CONFIGURACIÓN
          GoRoute(
            path: RoutesAgencia.configuracion,
            pageBuilder:
                (context, state) =>
                    const NoTransitionPage(child: SettingsScreen()),
          ),
        ],
      ),
    ],
  );
}
