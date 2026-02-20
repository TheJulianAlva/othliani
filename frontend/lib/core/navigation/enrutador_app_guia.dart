import 'package:go_router/go_router.dart';
import 'package:frontend/features/guia/auth/presentation/screens/guia_onboarding_screen.dart';
import 'package:frontend/features/guia/auth/presentation/screens/guia_login_screen.dart';
import 'package:frontend/features/guia/auth/presentation/screens/guia_recover_password_screen.dart';
import 'package:frontend/features/guia/auth/presentation/screens/guia_email_confirmation_screen.dart';
import 'package:frontend/features/guia/auth/presentation/screens/guia_email_verification_screen.dart';
import 'package:frontend/features/guia/auth/presentation/screens/guia_subscription_picker_screen.dart';
import 'package:frontend/features/guia/auth/presentation/screens/guia_mock_payment_screen.dart';
import 'package:frontend/features/guia/auth/presentation/screens/guia_payment_success_screen.dart';
import 'package:frontend/features/guia/auth/presentation/screens/guia_register_screen.dart';

import 'package:frontend/features/guia/shared/screens/guia_home_screen.dart';
import 'package:frontend/features/guia/shared/screens/guia_map_screen.dart';
import 'package:frontend/features/guia/shared/screens/guia_chat_screen.dart';
import 'package:frontend/features/guia/shared/screens/guia_alerts_screen.dart';
import 'package:frontend/features/guia/shared/screens/guia_profile_screen.dart';
import 'package:frontend/features/guia/shared/screens/guia_itinerary_screen.dart';
import 'package:frontend/features/guia/shared/screens/guia_participants_screen.dart';
import 'routes_guia.dart';
import 'transitions.dart';

class EnrutadorAppGuia {
  static GoRouter createRouter(String initialLocation) {
    return GoRouter(
      initialLocation: initialLocation,
      routes: [
        // ── Autenticación (Clean Architecture) ──────────────────────────
        GoRoute(
          path: RoutesGuia.onboarding,
          name: 'guia_onboarding',
          pageBuilder:
              (context, state) => CustomTransitionPage(
                key: state.pageKey,
                child: const GuiaOnboardingScreen(),
                transitionsBuilder: fadeSlideTransition,
              ),
        ),
        GoRoute(
          path: RoutesGuia.login,
          name: 'guia_login',
          pageBuilder:
              (context, state) => CustomTransitionPage(
                key: state.pageKey,
                child: const GuiaLoginScreen(),
                transitionsBuilder: fadeSlideTransition,
              ),
        ),
        GoRoute(
          path: RoutesGuia.forgotPassword,
          name: 'guia_forgot_password',
          pageBuilder:
              (context, state) => CustomTransitionPage(
                key: state.pageKey,
                child: const GuiaRecoverPasswordScreen(),
                transitionsBuilder: fadeSlideTransition,
              ),
        ),
        GoRoute(
          path: RoutesGuia.emailConfirmation,
          name: 'guia_email_confirmation',
          pageBuilder:
              (context, state) => CustomTransitionPage(
                key: state.pageKey,
                child: const GuiaEmailConfirmationScreen(),
                transitionsBuilder: fadeSlideTransition,
              ),
        ),
        GoRoute(
          path: RoutesGuia.register,
          name: 'guia_register',
          pageBuilder:
              (context, state) => CustomTransitionPage(
                key: state.pageKey,
                child: const GuiaRegisterScreen(),
                transitionsBuilder: fadeSlideTransition,
              ),
        ),
        GoRoute(
          path: RoutesGuia.emailVerification,
          name: 'guia_email_verification',
          pageBuilder:
              (context, state) => CustomTransitionPage(
                key: state.pageKey,
                child: const GuiaEmailVerificationScreen(),
                transitionsBuilder: fadeSlideTransition,
              ),
        ),
        GoRoute(
          path: RoutesGuia.subscriptionPicker,
          name: 'guia_subscription_picker',
          pageBuilder:
              (context, state) => CustomTransitionPage(
                key: state.pageKey,
                child: const GuiaSubscriptionPickerScreen(),
                transitionsBuilder: fadeSlideTransition,
              ),
        ),
        GoRoute(
          path: RoutesGuia.mockPayment,
          name: 'guia_mock_payment',
          pageBuilder: (context, state) {
            final extra = state.extra as Map<String, dynamic>? ?? {};
            return CustomTransitionPage(
              key: state.pageKey,
              child: GuiaMockPaymentScreen(
                plan: extra['plan'] as String? ?? 'Pro',
                precio: (extra['precio'] as num?)?.toDouble() ?? 19.0,
              ),
              transitionsBuilder: fadeSlideTransition,
            );
          },
        ),
        GoRoute(
          path: RoutesGuia.paymentSuccess,
          name: 'guia_payment_success',
          pageBuilder:
              (context, state) => CustomTransitionPage(
                key: state.pageKey,
                child: const GuiaPaymentSuccessScreen(),
                transitionsBuilder: fadeSlideTransition,
              ),
        ),

        // ── Pantallas principales ────────────────────────────────────────
        GoRoute(
          path: RoutesGuia.home,
          name: 'guia_home',
          pageBuilder:
              (context, state) => CustomTransitionPage(
                key: state.pageKey,
                child: const GuiaHomeScreen(),
                transitionsBuilder: fadeSlideTransition,
              ),
        ),
        GoRoute(
          path: RoutesGuia.map,
          name: 'guia_map',
          pageBuilder:
              (context, state) => CustomTransitionPage(
                key: state.pageKey,
                child: const GuiaMapScreen(),
                transitionsBuilder: fadeSlideTransition,
              ),
        ),
        GoRoute(
          path: RoutesGuia.chat,
          name: 'guia_chat',
          pageBuilder:
              (context, state) => CustomTransitionPage(
                key: state.pageKey,
                child: const GuiaChatScreen(),
                transitionsBuilder: fadeSlideTransition,
              ),
        ),
        GoRoute(
          path: RoutesGuia.alerts,
          name: 'guia_alerts',
          pageBuilder:
              (context, state) => CustomTransitionPage(
                key: state.pageKey,
                child: const GuiaAlertsScreen(),
                transitionsBuilder: fadeSlideTransition,
              ),
        ),
        GoRoute(
          path: RoutesGuia.profile,
          name: 'guia_profile',
          pageBuilder:
              (context, state) => CustomTransitionPage(
                key: state.pageKey,
                child: const GuiaProfileScreen(),
                transitionsBuilder: fadeSlideTransition,
              ),
        ),
        GoRoute(
          path: RoutesGuia.itinerary,
          name: 'guia_itinerary',
          pageBuilder:
              (context, state) => CustomTransitionPage(
                key: state.pageKey,
                child: const GuiaItineraryScreen(),
                transitionsBuilder: fadeSlideTransition,
              ),
        ),
        GoRoute(
          path: RoutesGuia.participants,
          name: 'guia_participants',
          pageBuilder:
              (context, state) => CustomTransitionPage(
                key: state.pageKey,
                child: const GuiaParticipantsScreen(),
                transitionsBuilder: fadeSlideTransition,
              ),
        ),
      ],
    );
  }
}
