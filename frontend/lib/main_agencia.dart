import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart'; // Importar localizaciones
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:window_manager/window_manager.dart';
import 'features/agencia/shared/presentation/blocs/sync/sync_bloc.dart';
import 'core/navigation/app_router_agencia.dart';
import 'core/di/service_locator.dart' as di_shared;
import 'core/di/agencia_locator.dart' as di_agencia;
import 'core/di/service_locator.dart'; // Para sl

import 'package:flutter_dotenv/flutter_dotenv.dart'; // Importar dotenv

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Ensure window manager is initialized
  await windowManager.ensureInitialized();
  await dotenv.load(fileName: ".env"); // Cargar variables de entorno
  await dotenv.load(fileName: ".env"); // Cargar variables de entorno
  await di_shared.initSharedDependencies(); // Initialize Shared Dependencies
  await di_agencia.initAgenciaDependencies(); // Initialize Agencia Dependencies

  WindowOptions windowOptions = const WindowOptions(
    size: Size(1280, 720),
    minimumSize: Size(1024, 600), // Minimum size to avoiding heavy overflows
    center: true,
    backgroundColor: Colors.transparent,
    skipTaskbar: false,
    titleBarStyle: TitleBarStyle.normal,
  );

  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });

  runApp(const AgencyApp());
}

class AgencyApp extends StatelessWidget {
  const AgencyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [BlocProvider<SyncBloc>(create: (_) => sl<SyncBloc>())],
      child: MaterialApp.router(
        title: 'OthliAni Agencia',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF1A237E), // Azul oscuro serio
            brightness: Brightness.light,
          ),
          useMaterial3: true,
          fontFamily:
              'Roboto', // Usando fuente del sistema por defecto o Roboto si está disponible
          scaffoldBackgroundColor: const Color(
            0xFFF4F6F8,
          ), // Gris muy claro especificado en wireframe
        ),
        routerConfig: AppRouterAgencia.router,
        debugShowCheckedModeBanner: false,
        // Configuración de Localización
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('es', 'ES'), // Español
          Locale('en', 'US'), // Inglés (fallback)
        ],
      ),
    );
  }
}
