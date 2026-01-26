import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';
import 'core/navigation/app_router_agencia.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Ensure window manager is initialized
  await windowManager.ensureInitialized();

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
    return MaterialApp.router(
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
    );
  }
}
