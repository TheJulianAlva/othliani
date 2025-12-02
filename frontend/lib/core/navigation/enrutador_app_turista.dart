import 'package:frontend/presentation_turista/screens/pantalla_telefono.dart';
import 'package:frontend/presentation_turista/screens/pantalla_verificacion_sms.dart';
import 'package:frontend/presentation_turista/screens/pantalla_introduccion.dart';
import 'package:frontend/presentation_turista/screens/pantalla_registro.dart';
import 'package:frontend/presentation_turista/screens/pantalla_inicio_sesion.dart';
import 'package:frontend/presentation_turista/screens/pantalla_olvido_contrasena.dart';
import 'package:frontend/presentation_turista/screens/pantalla_verificacion_email.dart';
import 'package:frontend/presentation_turista/screens/pantalla_inicio.dart';
import 'package:frontend/presentation_turista/screens/pantalla_itinerario.dart';
import 'package:frontend/presentation_turista/screens/pantalla_mapa.dart';
import 'package:frontend/presentation_turista/screens/pantalla_chat.dart';
import 'package:frontend/presentation_turista/screens/pantalla_configuracion.dart';
import 'package:frontend/presentation_turista/screens/pantalla_perfil.dart';
import 'package:frontend/presentation_turista/screens/pantalla_conversor_divisas.dart';
import 'package:frontend/presentation_turista/screens/pantalla_accesibilidad.dart';
import 'package:go_router/go_router.dart';
import '../../presentation_turista/screens/pantalla_folio.dart';

import 'routes_turista.dart';
import 'transitions.dart';

class EnrutadorAppTurista {
  static GoRouter createRouter(String initialLocation) {
    return GoRouter(
      initialLocation: initialLocation,
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
        GoRoute(
          path: RoutesTurista.smsVerification,
          name: 'turista_sms_verification',
          pageBuilder: (context, state) => CustomTransitionPage(
            key: state.pageKey,
            child: const SmsVerificationScreen(),
            transitionsBuilder: fadeSlideTransition,
          ),
        ),
        GoRoute(
          path: RoutesTurista.onboarding,
          name: 'turista_onboarding',
          pageBuilder: (context, state) => CustomTransitionPage(
            key: state.pageKey,
            child: const OnboardingScreen(),
            transitionsBuilder: fadeSlideTransition,
          ),
        ),
        GoRoute(
          path: RoutesTurista.register,
          name: 'turista_register',
          pageBuilder: (context, state) => CustomTransitionPage(
            key: state.pageKey,
            child: const RegisterScreen(),
            transitionsBuilder: fadeSlideTransition,
          ),
        ),
        GoRoute(
          path: RoutesTurista.login,
          name: 'turista_login',
          pageBuilder: (context, state) => CustomTransitionPage(
            key: state.pageKey,
            child: const LoginScreen(),
            transitionsBuilder: fadeSlideTransition,
          ),
        ),
        GoRoute(
          path: RoutesTurista.forgotPassword,
          name: 'turista_forgot_password',
          pageBuilder: (context, state) => CustomTransitionPage(
            key: state.pageKey,
            child: const ForgotPasswordScreen(),
            transitionsBuilder: fadeSlideTransition,
          ),
        ),
        GoRoute(
          path: RoutesTurista.emailVerification,
          name: 'turista_email_verification',
          pageBuilder: (context, state) => CustomTransitionPage(
            key: state.pageKey,
            child: const EmailVerificationScreen(),
            transitionsBuilder: fadeSlideTransition,
          ),
        ),
        GoRoute(
          path: RoutesTurista.home,
          name: 'turista_home',
          pageBuilder: (context, state) => CustomTransitionPage(
            key: state.pageKey,
            child: const MainShellScreen(),
            transitionsBuilder: fadeSlideTransition,
          ),
        ),
        GoRoute(
          path: RoutesTurista.itinerary,
          name: 'turista_itinerary',
          pageBuilder: (context, state) => CustomTransitionPage(
            key: state.pageKey,
            child: const ItineraryScreen(),
            transitionsBuilder: fadeSlideTransition,
          ),
        ),
        GoRoute(
          path: RoutesTurista.map,
          name: 'turista_map',
          pageBuilder: (context, state) => CustomTransitionPage(
            key: state.pageKey,
            child: const MapScreen(),
            transitionsBuilder: fadeSlideTransition,
          ),
        ),
        GoRoute(
          path: RoutesTurista.chat,
          name: 'turista_chat',
          pageBuilder: (context, state) => CustomTransitionPage(
            key: state.pageKey,
            child: const ChatScreen(),
            transitionsBuilder: fadeSlideTransition,
          ),
        ),
        GoRoute(
          path: RoutesTurista.config,
          name: 'turista_config',
          pageBuilder: (context, state) => CustomTransitionPage(
            key: state.pageKey,
            child: const ConfigScreen(),
            transitionsBuilder: fadeSlideTransition,
          ),
        ),
        GoRoute(
          path: RoutesTurista.profile,
          name: 'turista_profile',
          pageBuilder: (context, state) => CustomTransitionPage(
            key: state.pageKey,
            child: const ProfileScreen(),
            transitionsBuilder: fadeSlideTransition,
          ),
        ),
        GoRoute(
          path: RoutesTurista.currencyConverter,
          name: 'turista_currency_converter',
          pageBuilder: (context, state) => CustomTransitionPage(
            key: state.pageKey,
            child: const CurrencyConverterScreen(),
            transitionsBuilder: fadeSlideTransition,
          ),
        ),
        GoRoute(
          path: RoutesTurista.accessibility,
          name: 'turista_accessibility',
          pageBuilder: (context, state) => CustomTransitionPage(
            key: state.pageKey,
            child: const AccessibilityScreen(),
            transitionsBuilder: fadeSlideTransition,
          ),
        ),
      ],
    );
  }
}