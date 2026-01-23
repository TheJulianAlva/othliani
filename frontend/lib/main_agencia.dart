import 'package:flutter/material.dart';
import 'core/navigation/app_router_agencia.dart';

void main() {
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
