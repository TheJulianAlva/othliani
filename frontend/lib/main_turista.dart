import 'package:flutter/material.dart';
import 'core/navigation/app_router_turista.dart';
import 'core/theme/app_theme.dart';

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
      theme: AppTheme.lightTheme,
    );
  }
}
