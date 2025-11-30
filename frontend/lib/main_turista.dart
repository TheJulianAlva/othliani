import 'package:flutter/material.dart';
import 'core/navigation/app_router_turista.dart';

void main() {
  runApp(const TuristaApp());
}

class TuristaApp extends StatelessWidget {
  const TuristaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'OthliAni — Turista',
      debugShowCheckedModeBanner: false,
      routerConfig: AppRouterTurista.router,
      // theme: AppTheme.light, // si ya tienes tu tema en core/theme/
      // darkTheme: AppTheme.dark,
    );
  }
}
