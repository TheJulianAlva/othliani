import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:frontend/core/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';

import 'core/di/service_locator.dart';
import 'core/di/guia_locator.dart';
import 'core/navigation/enrutador_app_guia.dart';
import 'core/navigation/routes_guia.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/dark_theme.dart';
import 'features/guia/settings/presentation/cubit/guia_theme_cubit.dart';
import 'features/guia/settings/presentation/cubit/guia_locale_cubit.dart';
import 'features/guia/settings/presentation/cubit/guia_accessibility_cubit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar inyección de dependencias
  await initSharedDependencies();
  await initGuiaDependencies();

  final prefs = await SharedPreferences.getInstance();
  final onboardingCompletado = prefs.getBool('GUIA_ONBOARDING_DONE') ?? false;
  final isLoggedIn = prefs.getBool('isLoggedInGuia') ?? false;

  String initialRoute;
  if (!onboardingCompletado) {
    // Primera vez o onboarding incompleto → mostrar onboarding
    initialRoute = RoutesGuia.onboarding;
  } else if (!isLoggedIn) {
    // Onboarding completado pero sin sesión → login
    initialRoute = RoutesGuia.login;
  } else {
    // Sesión activa → pantalla principal
    initialRoute = RoutesGuia.home;
  }

  runApp(MainAppGuia(initialRoute: initialRoute));
}

class MainAppGuia extends StatefulWidget {
  final String initialRoute;

  const MainAppGuia({super.key, required this.initialRoute});

  @override
  State<MainAppGuia> createState() => _MainAppGuiaState();
}

class _MainAppGuiaState extends State<MainAppGuia> {
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _router = EnrutadorAppGuia.createRouter(widget.initialRoute);
  }

  @override
  Widget build(BuildContext context) {
    // Los cubits se crean directamente aquí en vez de usar guia_locator.
    // NOTE: Mover al guia_locator.dart cuando se coordine con el equipo.
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => GuiaThemeCubit(sharedPreferences: sl())),
        BlocProvider(create: (_) => GuiaLocaleCubit(sharedPreferences: sl())),
        BlocProvider(
          create: (_) => GuiaAccessibilityCubit(sharedPreferences: sl()),
        ),
      ],
      child: _GuiaAppView(router: _router),
    );
  }
}

/// Vista interna que escucha los cambios de los Cubits y reconstruye
/// el MaterialApp cuando el tema, idioma o accesibilidad cambian.
class _GuiaAppView extends StatelessWidget {
  final GoRouter router;
  
  const _GuiaAppView({required this.router});

  @override
  Widget build(BuildContext context) {
    // context.watch escucha cambios y reconstruye automáticamente
    final themeMode = context.watch<GuiaThemeCubit>().state;
    final locale = context.watch<GuiaLocaleCubit>().state;
    final accessibilityState = context.watch<GuiaAccessibilityCubit>().state;

    return MaterialApp.router(
      title: 'Veltur - Guía',
      debugShowCheckedModeBanner: false,

      // Localization
      locale: locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('es'), Locale('en')],

      // Theme
      theme: AppTheme.lightTheme,
      darkTheme: DarkTheme.theme,
      themeMode: themeMode,

      // Router
      routerConfig: router,

      // Accessibility
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.linear(accessibilityState.fontScale),
          ),
          child: child!,
        );
      },
    );
  }
}
