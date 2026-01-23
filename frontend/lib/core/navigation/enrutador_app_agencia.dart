import 'package:go_router/go_router.dart';
import '../../presentation_agencia/screens/dashboard_screen.dart';
import '../../presentation_agencia/screens/trips_screen.dart';
import '../../presentation_agencia/screens/users_screen.dart';
import '../../presentation_agencia/screens/audit_screen.dart';
import '../../presentation_agencia/screens/settings_screen.dart';
import '../../presentation_agencia/widgets/agency_layout.dart';
import 'routes_agencia.dart';
import 'transitions.dart';

class EnrutadorAppAgencia {
  static GoRouter createRouter(String initialLocation) {
    return GoRouter(
      initialLocation: initialLocation,
      routes: [
        ShellRoute(
          builder: (context, state, child) {
            return AgencyLayout(child: child);
          },
          routes: [
            GoRoute(
              path: RoutesAgencia.dashboard,
              name: 'agencia_dashboard',
              pageBuilder:
                  (context, state) => CustomTransitionPage(
                    key: state.pageKey,
                    child: const DashboardScreen(),
                    transitionsBuilder: fadeSlideTransition,
                  ),
            ),
            GoRoute(
              path: RoutesAgencia.viajes,
              name: 'agencia_viajes',
              pageBuilder:
                  (context, state) => CustomTransitionPage(
                    key: state.pageKey,
                    child: const TripsScreen(),
                    transitionsBuilder: fadeSlideTransition,
                  ),
            ),
            GoRoute(
              path: RoutesAgencia.usuarios,
              name: 'agencia_usuarios',
              pageBuilder:
                  (context, state) => CustomTransitionPage(
                    key: state.pageKey,
                    child: const UsersScreen(),
                    transitionsBuilder: fadeSlideTransition,
                  ),
            ),
            GoRoute(
              path: RoutesAgencia.auditoria,
              name: 'agencia_auditoria',
              pageBuilder:
                  (context, state) => CustomTransitionPage(
                    key: state.pageKey,
                    child: const AuditScreen(),
                    transitionsBuilder: fadeSlideTransition,
                  ),
            ),
            GoRoute(
              path: RoutesAgencia.configuracion,
              name: 'agencia_configuracion',
              pageBuilder:
                  (context, state) => CustomTransitionPage(
                    key: state.pageKey,
                    child: const SettingsScreen(),
                    transitionsBuilder: fadeSlideTransition,
                  ),
            ),
          ],
        ),
      ],
    );
  }
}
