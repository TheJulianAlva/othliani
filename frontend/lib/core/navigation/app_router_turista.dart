import 'package:frontend/presentation_turista/screens/phone_screen.dart';
import 'package:frontend/presentation_turista/screens/sms_verification_screen.dart';
import 'package:frontend/presentation_turista/screens/onboarding_screen.dart';
import 'package:frontend/presentation_turista/screens/register_screen.dart';
import 'package:frontend/presentation_turista/screens/login_screen.dart';
import 'package:frontend/presentation_turista/screens/forgot_password_screen.dart';
import 'package:frontend/presentation_turista/screens/email_verification_screen.dart';
import 'package:frontend/presentation_turista/screens/home_screen.dart';
import 'package:frontend/presentation_turista/screens/itinerary_screen.dart';
import 'package:frontend/presentation_turista/screens/map_screen.dart';
import 'package:frontend/presentation_turista/screens/chat_screen.dart';
import 'package:frontend/presentation_turista/screens/config_screen.dart';
import 'package:frontend/presentation_turista/screens/profile_screen.dart';
import 'package:frontend/presentation_turista/screens/currency_converter_screen.dart';
import 'package:go_router/go_router.dart';
import '../../presentation_turista/screens/folio_screen.dart';

import 'routes_turista.dart';
import 'transitions.dart';

class AppRouterTurista {
  static final GoRouter router = GoRouter(
    initialLocation: RoutesTurista.onboarding,
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
          child: const HomeScreen(),
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
