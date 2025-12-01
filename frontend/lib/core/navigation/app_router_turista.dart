import 'package:frontend/presentation_turista/screens/phone_screen.dart';
import 'package:frontend/presentation_turista/screens/sms_verification_screen.dart';
import 'package:frontend/presentation_turista/screens/splash_screen.dart';
import 'package:frontend/presentation_turista/screens/onboarding_screen.dart';
import 'package:go_router/go_router.dart';
import '../../presentation_turista/screens/folio_screen.dart';

import 'routes_turista.dart';
import 'transitions.dart';

class AppRouterTurista {
  static final GoRouter router = GoRouter(
    initialLocation: RoutesTurista.splash,
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
        path: RoutesTurista.splash,
        name: 'turista_splash',
        pageBuilder: (context, state) => CustomTransitionPage(
          key: state.pageKey,
          child: const SplashScreen(),
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
