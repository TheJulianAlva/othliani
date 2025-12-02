import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';

import 'core/navigation/enrutador_app_guia.dart';
import 'core/navigation/routes_guia.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/dark_theme.dart';
import 'core/providers/locale_provider.dart';
import 'core/providers/theme_provider.dart';
import 'core/providers/accessibility_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final prefs = await SharedPreferences.getInstance();
  final isLoggedIn = prefs.getBool('isLoggedInGuia') ?? false;

  String initialRoute;
  if (!isLoggedIn) {
    initialRoute = RoutesGuia.login;
  } else {
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
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AccessibilityProvider()),
      ],
      child: Consumer3<LocaleProvider, ThemeProvider, AccessibilityProvider>(
        builder: (context, localeProvider, themeProvider, accessibilityProvider, child) {
          return MaterialApp.router(
            title: 'OthliAni - Guía',
            debugShowCheckedModeBanner: false,
            
            // Localization
            locale: localeProvider.locale,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('es'),
              Locale('en'),
            ],
            
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
                  textScaler: TextScaler.linear(accessibilityProvider.fontScale),
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
