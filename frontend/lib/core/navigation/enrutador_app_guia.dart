import 'package:go_router/go_router.dart';
import 'package:frontend/presentation_guia/screens/pantalla_login_guia.dart';
import 'package:frontend/presentation_guia/screens/pantalla_registro_guia.dart';
import 'package:frontend/presentation_guia/screens/pantalla_inicio_guia.dart';
import 'package:frontend/presentation_guia/screens/pantalla_mapa_guia.dart';
import 'package:frontend/presentation_guia/screens/pantalla_chat_guia.dart';
import 'package:frontend/presentation_guia/screens/pantalla_alertas_guia.dart';
import 'package:frontend/presentation_guia/screens/pantalla_perfil_guia.dart';
import 'package:frontend/presentation_guia/screens/pantalla_itinerario_guia.dart';
import 'package:frontend/presentation_guia/screens/pantalla_lista_participantes.dart';
import 'routes_guia.dart';
import 'transitions.dart'; // Reusing transitions from tourist app if available, otherwise I might need to create it or import from core

// Assuming transitions.dart is in the same folder or I need to check where it is.
// It was imported as 'transitions.dart' in tourist router, so it should be in lib/core/navigation/transitions.dart

class EnrutadorAppGuia {
  static GoRouter createRouter(String initialLocation) {
    return GoRouter(
      initialLocation: initialLocation,
      routes: [
        GoRoute(
          path: RoutesGuia.login,
          name: 'guia_login',
          pageBuilder:
              (context, state) => CustomTransitionPage(
                key: state.pageKey,
                child: const LoginScreenGuia(),
                transitionsBuilder: fadeSlideTransition,
              ),
        ),
        GoRoute(
          path: RoutesGuia.register,
          name: 'guia_register',
          pageBuilder:
              (context, state) => CustomTransitionPage(
                key: state.pageKey,
                child: const RegisterScreenGuia(),
                transitionsBuilder: fadeSlideTransition,
              ),
        ),
        GoRoute(
          path: RoutesGuia.home,
          name: 'guia_home',
          pageBuilder:
              (context, state) => CustomTransitionPage(
                key: state.pageKey,
                child: const HomeScreenGuia(),
                transitionsBuilder: fadeSlideTransition,
              ),
        ),
        GoRoute(
          path: RoutesGuia.map,
          name: 'guia_map',
          pageBuilder:
              (context, state) => CustomTransitionPage(
                key: state.pageKey,
                child: const MapScreenGuia(),
                transitionsBuilder: fadeSlideTransition,
              ),
        ),
        GoRoute(
          path: RoutesGuia.chat,
          name: 'guia_chat',
          pageBuilder:
              (context, state) => CustomTransitionPage(
                key: state.pageKey,
                child: const ChatScreenGuia(),
                transitionsBuilder: fadeSlideTransition,
              ),
        ),
        GoRoute(
          path: RoutesGuia.alerts,
          name: 'guia_alerts',
          pageBuilder:
              (context, state) => CustomTransitionPage(
                key: state.pageKey,
                child: const AlertsScreenGuia(),
                transitionsBuilder: fadeSlideTransition,
              ),
        ),
        GoRoute(
          path: RoutesGuia.profile,
          name: 'guia_profile',
          pageBuilder:
              (context, state) => CustomTransitionPage(
                key: state.pageKey,
                child: const ProfileScreenGuia(),
                transitionsBuilder: fadeSlideTransition,
              ),
        ),
        GoRoute(
          path: RoutesGuia.itinerary,
          name: 'guia_itinerary',
          pageBuilder:
              (context, state) => CustomTransitionPage(
                key: state.pageKey,
                child: const ItineraryScreenGuia(),
                transitionsBuilder: fadeSlideTransition,
              ),
        ),
        GoRoute(
          path: RoutesGuia.participants,
          name: 'guia_participants',
          pageBuilder:
              (context, state) => CustomTransitionPage(
                key: state.pageKey,
                child: const ParticipantsScreenGuia(),
                transitionsBuilder: fadeSlideTransition,
              ),
        ),
      ],
    );
  }
}
