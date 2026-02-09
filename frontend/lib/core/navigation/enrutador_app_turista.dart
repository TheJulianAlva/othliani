import 'package:frontend/presentation_turista/screens/pantalla_telefono.dart';
import 'package:frontend/presentation_turista/screens/pantalla_verificacion_sms.dart';

import 'package:frontend/features/turista/auth/presentation/screens/onboarding_screen.dart';
import 'package:frontend/features/turista/auth/presentation/screens/register_screen.dart';

import 'package:frontend/features/turista/auth/presentation/screens/login_screen.dart';
import 'package:frontend/features/turista/auth/presentation/screens/forgot_password_screen.dart';

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

import 'package:frontend/features/turista/auth/presentation/bloc/auth_bloc.dart';
import 'package:frontend/features/turista/auth/presentation/bloc/auth_state.dart';
import 'package:frontend/core/navigation/go_router_refresh_stream.dart';

import 'routes_turista.dart';
import 'transitions.dart';

class EnrutadorAppTurista {
  static GoRouter createRouter(String initialLocation, AuthBloc authBloc) {
    return GoRouter(
      initialLocation: initialLocation,
      refreshListenable: GoRouterRefreshStream(authBloc.stream),
      redirect: (context, state) {
        final authState = authBloc.state;
        final isAuth = authState.status == AuthStatus.authenticated;
        final isLoggingIn =
            state.matchedLocation == RoutesTurista.login ||
            state.matchedLocation == RoutesTurista.register ||
            state.matchedLocation == RoutesTurista.folio ||
            state.matchedLocation == RoutesTurista.phoneConfirm ||
            state.matchedLocation == RoutesTurista.smsVerification ||
            state.matchedLocation == RoutesTurista.forgotPassword ||
            state.matchedLocation == RoutesTurista.emailVerification ||
            state.matchedLocation == RoutesTurista.onboarding;

        if (!isAuth && !isLoggingIn) {
          return RoutesTurista.folio;
        }

        if (isAuth && isLoggingIn) {
          return RoutesTurista.home;
        }

        return null;
      },

      routes: [
        GoRoute(
          path: RoutesTurista.folio,
          name: 'turista_folio',
          pageBuilder:
              (context, state) => CustomTransitionPage(
                key: state.pageKey,
                child: const FolioScreen(),
                transitionsBuilder: fadeSlideTransition,
              ),
        ),
        GoRoute(
          path: RoutesTurista.phoneConfirm,
          name: 'turista_phone_confirm',
          pageBuilder:
              (context, state) => CustomTransitionPage(
                key: state.pageKey,
                child: const PhoneScreen(),
                transitionsBuilder: fadeSlideTransition,
              ),
        ),
        GoRoute(
          path: RoutesTurista.smsVerification,
          name: 'turista_sms_verification',
          pageBuilder:
              (context, state) => CustomTransitionPage(
                key: state.pageKey,
                child: const SmsVerificationScreen(),
                transitionsBuilder: fadeSlideTransition,
              ),
        ),
        GoRoute(
          path: RoutesTurista.onboarding,
          name: 'turista_onboarding',
          pageBuilder:
              (context, state) => CustomTransitionPage(
                key: state.pageKey,
                child: const OnboardingScreen(),
                transitionsBuilder: fadeSlideTransition,
              ),
        ),
        GoRoute(
          path: RoutesTurista.register,
          name: 'turista_register',
          pageBuilder:
              (context, state) => CustomTransitionPage(
                key: state.pageKey,
                child: const RegisterScreen(),
                transitionsBuilder: fadeSlideTransition,
              ),
        ),
        GoRoute(
          path: RoutesTurista.login,
          name: 'turista_login',
          pageBuilder:
              (context, state) => CustomTransitionPage(
                key: state.pageKey,
                child: const LoginScreen(),
                transitionsBuilder: fadeSlideTransition,
              ),
        ),
        GoRoute(
          path: RoutesTurista.forgotPassword,
          name: 'turista_forgot_password',
          pageBuilder:
              (context, state) => CustomTransitionPage(
                key: state.pageKey,
                child: const ForgotPasswordScreen(),
                transitionsBuilder: fadeSlideTransition,
              ),
        ),
        GoRoute(
          path: RoutesTurista.emailVerification,
          name: 'turista_email_verification',
          pageBuilder:
              (context, state) => CustomTransitionPage(
                key: state.pageKey,
                child: const EmailVerificationScreen(),
                transitionsBuilder: fadeSlideTransition,
              ),
        ),
        GoRoute(
          path: RoutesTurista.home,
          name: 'turista_home',
          pageBuilder:
              (context, state) => CustomTransitionPage(
                key: state.pageKey,
                child: const MainShellScreen(),
                transitionsBuilder: fadeSlideTransition,
              ),
        ),
        GoRoute(
          path: RoutesTurista.itinerary,
          name: 'turista_itinerary',
          pageBuilder:
              (context, state) => CustomTransitionPage(
                key: state.pageKey,
                child: const ItineraryScreen(),
                transitionsBuilder: fadeSlideTransition,
              ),
        ),
        GoRoute(
          path: RoutesTurista.map,
          name: 'turista_map',
          pageBuilder:
              (context, state) => CustomTransitionPage(
                key: state.pageKey,
                child: const MapScreen(),
                transitionsBuilder: fadeSlideTransition,
              ),
        ),
        GoRoute(
          path: RoutesTurista.chat,
          name: 'turista_chat',
          pageBuilder:
              (context, state) => CustomTransitionPage(
                key: state.pageKey,
                child: const ChatScreen(),
                transitionsBuilder: fadeSlideTransition,
              ),
        ),
        GoRoute(
          path: RoutesTurista.config,
          name: 'turista_config',
          pageBuilder:
              (context, state) => CustomTransitionPage(
                key: state.pageKey,
                child: const ConfigScreen(),
                transitionsBuilder: fadeSlideTransition,
              ),
        ),
        GoRoute(
          path: RoutesTurista.profile,
          name: 'turista_profile',
          pageBuilder:
              (context, state) => CustomTransitionPage(
                key: state.pageKey,
                child: const ProfileScreen(),
                transitionsBuilder: fadeSlideTransition,
              ),
        ),
        GoRoute(
          path: RoutesTurista.currencyConverter,
          name: 'turista_currency_converter',
          pageBuilder:
              (context, state) => CustomTransitionPage(
                key: state.pageKey,
                child: const CurrencyConverterScreen(),
                transitionsBuilder: fadeSlideTransition,
              ),
        ),
        GoRoute(
          path: RoutesTurista.accessibility,
          name: 'turista_accessibility',
          pageBuilder:
              (context, state) => CustomTransitionPage(
                key: state.pageKey,
                child: const AccessibilityScreen(),
                transitionsBuilder: fadeSlideTransition,
              ),
        ),
      ],
    );
  }
}
