import 'package:frontend/presentation_turista/screens/phone_screen.dart';
import 'package:go_router/go_router.dart';
import '../../presentation_turista/screens/folio_screen.dart';

import 'routes_turista.dart';
import 'transitions.dart';

class AppRouterTurista {
  static final GoRouter router = GoRouter(
    initialLocation: RoutesTurista.folio,
    routes: [
      GoRoute(
        path: RoutesTurista.folio,
        name: 'turista_folio',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const FolioScreen(),
          transitionsBuilder: fadeSlideTransition,
        ),
      ),
      GoRoute(
        path: RoutesTurista.phoneConfirm,
        name: 'turista_phone_confirm',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const PhoneScreen(),
          transitionsBuilder: fadeSlideTransition,
        ),
      ),
      // Ejemplo de ruta con parámetro (si la usas luego)
      // GoRoute(
      //   path: '/trip/:id',
      //   name: 'turista_trip_details',
      //   pageBuilder: (context, state) => CustomTransitionPage(
      //     key: state.pageKey,
      //     child: TripDetailsScreen(tripId: state.pathParameters['id']!),
      //     transitionsBuilder: slideUpTransition,
      //   ),
      // ),
    ],
  );
}
