import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:frontend/features/guia/auth/data/models/guia_user_model.dart';
import 'package:frontend/features/guia/home/presentation/blocs/agencia_home_bloc/agencia_home_cubit.dart';
import 'package:frontend/features/guia/home/presentation/blocs/personal_home_bloc/personal_home_cubit.dart';
import 'package:frontend/features/guia/home/presentation/screens/agencia_main_layout.dart';
import 'package:frontend/features/guia/home/presentation/screens/personal_main_layout.dart';
import 'package:frontend/core/di/service_locator.dart';

/// Punto de entrada único para el home del guía.
///
/// Lee el [GuiaUserModel] cacheado y despacha al layout correcto:
/// - [permissionLevel] == 2 → [AgenciaMainLayout] (B2B)
/// - [permissionLevel] == 1 → [PersonalMainLayout] (B2C)
class HomeWrapperScreen extends StatefulWidget {
  const HomeWrapperScreen({super.key});

  @override
  State<HomeWrapperScreen> createState() => _HomeWrapperScreenState();
}

class _HomeWrapperScreenState extends State<HomeWrapperScreen> {
  GuiaUserModel? _user;
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargarUsuario();
  }

  Future<void> _cargarUsuario() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString('CACHED_GUIA_USER');
    if (jsonStr != null) {
      final model = GuiaUserModel.fromJson(json.decode(jsonStr));
      if (mounted) {
        setState(() {
          _user = model;
          _cargando = false;
        });
      }
    } else {
      if (mounted) {
        setState(() => _cargando = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_cargando) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final user = _user;

    // Sin sesión guardada → fallback al layout personal vacío
    if (user == null) {
      return BlocProvider(
        create: (_) => sl<PersonalHomeCubit>(),
        child: const PersonalMainLayout(nombreGuia: 'Guía'),
      );
    }

    // Sesión B2B (agencia)
    if (user.permissionLevel == 2) {
      // Extraer el folio del ID guardado: guia_b2b_ag_001 → AG-001
      final folio = _folioDesdeId(user.id);
      return BlocProvider(
        create: (_) => sl<AgenciaHomeCubit>(),
        child: AgenciaMainLayout(nombreGuia: user.name, folio: folio),
      );
    }

    // Sesión B2C (personal)
    return BlocProvider(
      create: (_) => sl<PersonalHomeCubit>(),
      child: PersonalMainLayout(nombreGuia: user.name),
    );
  }

  /// Convierte el ID generado en el datasource ("guia_b2b_ag_001") a folio ("AG-001").
  String _folioDesdeId(String id) {
    // Formato: guia_b2b_ag_001
    final partes = id.replaceFirst('guia_b2b_', '').toUpperCase().split('_');
    if (partes.length >= 2) return '${partes[0]}-${partes[1]}';
    return id.toUpperCase();
  }
}
