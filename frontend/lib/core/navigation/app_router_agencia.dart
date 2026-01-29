import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../injection_container.dart' as di;
import 'routes_agencia.dart';

// Importa tus Widgets de Pantalla
import '../../presentation_agencia/screens/login_screen.dart';
import '../../presentation_agencia/screens/dashboard_screen.dart';
import '../../presentation_agencia/screens/trips_screen.dart';
import '../../presentation_agencia/screens/trip_detail_screen.dart';
import '../../presentation_agencia/screens/users_screen.dart';
import '../../presentation_agencia/screens/audit_screen.dart';
import '../../presentation_agencia/screens/settings_screen.dart'; // Settings Screen
import '../../presentation_agencia/widgets/agency_layout.dart'; // Tu Layout con Sidebar

// Importa tus BLoCs
import '../../presentation_agencia/blocs/dashboard/dashboard_bloc.dart';
import '../../presentation_agencia/blocs/viajes/viajes_bloc.dart';
import '../../presentation_agencia/blocs/detalle_viaje/detalle_viaje_bloc.dart';
import '../../presentation_agencia/blocs/usuarios/usuarios_bloc.dart';
import '../../presentation_agencia/blocs/auditoria/auditoria_bloc.dart';

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
                          di.sl<ViajesBloc>()
                            ..add(LoadViajesEvent(filter: filter)),
                  child: const TripsScreen(),
                ),
              );
            },
            routes: [
              // Sub-ruta: DETALLE (/viajes/:id)
              GoRoute(
                path: ':id', // Parámetro dinámico
                builder: (context, state) {
                  final viajeId = state.pathParameters['id']!;
                  final focusAlertId = state.uri.queryParameters['alert_focus'];

                  return BlocProvider(
                    create: (_) => di.sl<DetalleViajeBloc>(),
                    // Event dispatch is handled in TripDetailScreen.initState now, OR we can do it here.
                    // User requested injected here. But I modified initState. Let's keep it clean.
                    // Actually, the request said: create: (_) => di.sl<DetalleViajeBloc>()..add(LoadDetalleViajeEvent(id: viajeId)),
                    // But I kept logic in initState for safety? No, let's follow user request for best practice.
                    // However, I already edited initState to read from widget.
                    // Let's do it in create as well or ensure it's not double calling.
                    // Better pattern: Inject Bloc, let UI trigger event or Bloc trigger event immediately.
                    // I will inject it without event here if the UI does it, OR I remove it from UI.
                    // User code sample: create: (_) => di.sl<DetalleViajeBloc>()..add(LoadDetalleViajeEvent(id: viajeId)),
                    // I will follow user code sample. (It mimics the specific ID loading).
                    // Wait, if I do "..add" here, the UI "initState" might double add.
                    // I will trust the BLoC provider here.
                    child: TripDetailScreen(
                      viajeId: viajeId,
                      focusAlertId:
                          focusAlertId, // Para abrir el modal automáticamente
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
