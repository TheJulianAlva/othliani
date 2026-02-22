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
import 'package:frontend/features/guia/auth/presentation/screens/pantalla_folio_agencia.dart';
import 'package:frontend/features/guia/auth/presentation/screens/pantalla_telefono_guia.dart';
import 'package:frontend/core/di/service_locator.dart';
import 'package:frontend/features/guia/auth/presentation/cubit/guia_agency_login_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:frontend/features/guia/home/presentation/screens/home_wrapper_screen.dart';
import 'package:frontend/features/guia/shared/screens/guia_map_screen.dart';
import 'package:frontend/features/guia/shared/screens/guia_chat_screen.dart';
import 'package:frontend/features/guia/shared/screens/guia_alerts_screen.dart';
import 'package:frontend/features/guia/shared/screens/guia_profile_screen.dart';
import 'package:frontend/features/guia/shared/screens/guia_itinerary_screen.dart';
import 'package:frontend/features/guia/shared/screens/guia_participants_screen.dart';
import 'package:frontend/features/turista/tools/presentation/screens/currency_converter_screen.dart';
import 'package:frontend/features/guia/home/presentation/screens/pantalla_gestion_cambios.dart';
import 'package:frontend/features/guia/trips/presentation/screens/crear_viaje_personal_screen.dart';
import 'package:frontend/features/guia/home/presentation/screens/sos_alarm_screen.dart';
import 'package:frontend/features/guia/trips/presentation/screens/bitacora_seguridad_screen.dart';
import 'package:frontend/features/guia/trips/presentation/screens/reporte_fin_viaje_screen.dart';
import 'package:frontend/features/guia/trips/presentation/screens/expedition_log_screen.dart';
import 'package:frontend/features/guia/home/presentation/screens/pantalla_alertas_guia.dart';
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

        // ── Flujo B2B: Agencia ───────────────────────────────────────────
        GoRoute(
          path: RoutesGuia.agencyFolio,
          name: 'guia_agency_folio',
          pageBuilder:
              (context, state) => CustomTransitionPage(
                key: state.pageKey,
                child: BlocProvider(
                  create: (_) => sl<GuiaAgencyLoginCubit>(),
                  child: const PantallaFolioAgencia(),
                ),
                transitionsBuilder: fadeSlideTransition,
              ),
        ),
        GoRoute(
          path: RoutesGuia.agencyPhone,
          name: 'guia_agency_phone',
          pageBuilder: (context, state) {
            final folio = state.extra as String? ?? '';
            return CustomTransitionPage(
              key: state.pageKey,
              child: BlocProvider(
                create: (_) => sl<GuiaAgencyLoginCubit>(),
                child: PantallaPhoneGuia(folio: folio),
              ),
              transitionsBuilder: fadeSlideTransition,
            );
          },
        ),

        // ── Pantallas principales ────────────────────────────────────────
        GoRoute(
          path: RoutesGuia.home,
          name: 'guia_home',
          pageBuilder:
              (context, state) => CustomTransitionPage(
                key: state.pageKey,
                child: const HomeWrapperScreen(),
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
        GoRoute(
          path: RoutesGuia.converter,
          name: 'guia_converter',
          pageBuilder:
              (context, state) => CustomTransitionPage(
                key: state.pageKey,
                child: const CurrencyConverterScreen(),
                transitionsBuilder: fadeSlideTransition,
              ),
        ),
        GoRoute(
          path: RoutesGuia.itineraryChanges,
          name: 'guia_itinerary_changes',
          pageBuilder:
              (context, state) => CustomTransitionPage(
                key: state.pageKey,
                child: const PantallaGestionCambios(),
                transitionsBuilder: fadeSlideTransition,
              ),
        ),
        GoRoute(
          path: RoutesGuia.createPersonalTrip,
          name: 'guia_create_personal_trip',
          pageBuilder:
              (context, state) => CustomTransitionPage(
                key: state.pageKey,
                child: const CrearViajePersonalScreen(),
                transitionsBuilder: fadeSlideTransition,
              ),
        ),
        GoRoute(
          path: RoutesGuia.sos,
          name: 'guia_sos',
          pageBuilder:
              (context, state) => CustomTransitionPage(
                key: state.pageKey,
                child: SOSAlarmScreen(alerta: state.extra as AlertaSOS?),
                transitionsBuilder: fadeSlideTransition,
              ),
        ),
        GoRoute(
          path: RoutesGuia.bitacora,
          name: 'guia_bitacora',
          pageBuilder:
              (context, state) => CustomTransitionPage(
                key: state.pageKey,
                child: const BitacoraSeguridadScreen(),
                transitionsBuilder: fadeSlideTransition,
              ),
        ),
        GoRoute(
          path: RoutesGuia.reporteFinViaje,
          name: 'guia_reporte_fin_viaje',
          pageBuilder:
              (context, state) => CustomTransitionPage(
                key: state.pageKey,
                child: ReporteFinViajeScreen(
                  nombreExpedicion:
                      (state.extra as Map<String, dynamic>?)?['nombre']
                          as String? ??
                      'Expedición',
                  inicio:
                      (state.extra as Map<String, dynamic>?)?['inicio']
                          as DateTime?,
                  turistasPrioridad1:
                      ((state.extra as Map<String, dynamic>?)?['prioridad1']
                              as List<dynamic>?)
                          ?.cast<String>() ??
                      [],
                  distanciaKm:
                      ((state.extra as Map<String, dynamic>?)?['distanciaKm']
                              as num?)
                          ?.toDouble() ??
                      0,
                ),
                transitionsBuilder: fadeSlideTransition,
              ),
        ),
        GoRoute(
          path: RoutesGuia.expeditionLog,
          name: 'guia_expedition_log',
          pageBuilder:
              (context, state) => CustomTransitionPage(
                key: state.pageKey,
                child: ExpeditionLogScreen(),
                transitionsBuilder: fadeSlideTransition,
              ),
        ),
        // ── Alerta Turista ───────────────────────────────────────
        GoRoute(
          path: RoutesGuia.alertaTurista,
          name: 'guia_alerta_turista',
          pageBuilder: (context, state) {
            final params = state.extra as AlertaTuristaParams;
            return CustomTransitionPage(
              key: state.pageKey,
              child: PantallaAlertasGuia(
                turista: params.turista,
                motivoAlerta: params.motivoAlerta,
                distanciaMetros: params.distanciaMetros,
              ),
              transitionsBuilder: fadeSlideTransition,
            );
          },
        ),
      ],
    );
  }
}
