import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:frontend/core/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';

import 'core/navigation/enrutador_app_turista.dart';
import 'core/navigation/routes_turista.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/dark_theme.dart';
import 'core/providers/locale_provider.dart';
import 'core/providers/theme_provider.dart';
import 'core/providers/accessibility_provider.dart';
import 'core/di/service_locator.dart' as di;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await di.setupServiceLocator();

  final prefs = await SharedPreferences.getInstance();
  final seenOnboarding = prefs.getBool('seenOnboarding') ?? false;
  final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

  String initialRoute;
  if (!seenOnboarding) {
    initialRoute = RoutesTurista.onboarding;
  } else if (!isLoggedIn) {
    initialRoute = RoutesTurista.folio;
  } else {
    initialRoute = RoutesTurista.home;
  }

  runApp(MainApp(initialRoute: initialRoute));
}

class MainApp extends StatefulWidget {
  final String initialRoute;

  const MainApp({super.key, required this.initialRoute});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _router = EnrutadorAppTurista.createRouter(widget.initialRoute);
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AccessibilityProvider()),
      ],
      child: Consumer3<LocaleProvider, ThemeProvider, AccessibilityProvider>(
        builder: (
          context,
          localeProvider,
          themeProvider,
          accessibilityProvider,
          child,
        ) {
          return MaterialApp.router(
            title: 'OthliAni - Turista',
            debugShowCheckedModeBanner: false,

            // Localization
            locale: localeProvider.locale,
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
            themeMode: themeProvider.themeMode,

            // Router
            routerConfig: _router,

            // Accessibility
            builder: (context, child) {
              return MediaQuery(
                data: MediaQuery.of(context).copyWith(
                  textScaler: TextScaler.linear(
                    accessibilityProvider.fontScale,
                  ),
                ),
                child: child!,
              );
            },
          );
        },
      ),
    );
  }
}
