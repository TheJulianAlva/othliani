import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:frontend/features/guia/auth/data/models/guia_user_model.dart';

abstract class GuiaAuthRemoteDataSource {
  Future<GuiaUserModel> login(String email, String password);
  Future<void> sendPasswordResetEmail(String email);
  Future<GuiaUserModel> loginWithAgencyToken(String token);

  // B2B Agency flow
  Future<void> verifyFolio(String folio);
  Future<GuiaUserModel> loginWithAgencyAccess(String folio, String phone);
}

class GuiaAuthRemoteDataSourceImpl implements GuiaAuthRemoteDataSource {
  final Dio dio;

  GuiaAuthRemoteDataSourceImpl({required this.dio});

  @override
  Future<GuiaUserModel> login(String email, String password) async {
    try {
      final response = await dio.post('/usuarios/login', data: {
        'correo': email,
        'password': password,
      });

      var responseData = response.data;
      if (responseData is String) {
        responseData = json.decode(responseData);
      }

      final data = responseData['usuario'] as Map<String, dynamic>;
      
      return GuiaUserModel(
        id: data['id'] as String,
        email: data['correo'] as String,
        name: data['nombre_completo'] as String,
        permissionLevel: 1, // Por ahora fijo para el demo
      );
    } catch (e) {
      throw Exception('Credenciales inválidas o error de servidor');
    }
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    throw UnimplementedError('Not implemented yet');
  }

  @override
  Future<GuiaUserModel> loginWithAgencyToken(String token) async {
    throw UnimplementedError('Not implemented yet');
  }

  @override
  Future<void> verifyFolio(String folio) async {
    // Para el demo, asumimos que cualquier folio es válido aquí y la verdadera
    // validación ocurre al mandar el teléfono cruzado con el folio.
    await Future.delayed(const Duration(milliseconds: 500));
  }

  @override
  Future<GuiaUserModel> loginWithAgencyAccess(String folio, String phone) async {
    try {
      debugPrint('GuiaAuthRemote: Enviando login-agencia con folio: $folio, telefono: $phone');
      final response = await dio.post('/usuarios/login-agencia', data: {
        'folio': folio,
        'telefono': phone,
      });

      debugPrint('GuiaAuthRemote: Respuesta recibida: ${response.data}');

      var responseData = response.data;
      if (responseData is String) {
        responseData = json.decode(responseData);
      }

      final data = responseData['usuario'] as Map<String, dynamic>;

      return GuiaUserModel(
        id: data['id'] as String,
        email: data['correo'] as String,
        name: data['nombre_completo'] as String,
        permissionLevel: 2, // Agencia B2B access
      );
    } catch (e, stack) {
      debugPrint('GuiaAuthRemote: Error en login B2B: $e');
      debugPrint('GuiaAuthRemote: StackTrace: $stack');
      throw Exception('Folio o teléfono incorrectos: $e');
    }
  }
}


class GuiaAuthMockDataSource implements GuiaAuthRemoteDataSource {
  @override
  Future<GuiaUserModel> login(String email, String password) async {
    // Simula retardo de red
    await Future.delayed(const Duration(seconds: 2));

    if (email == 'error@test.com') {
      throw Exception('Usuario no encontrado');
    }

    return const GuiaUserModel(
      id: 'guia_001',
      email: 'juanmorales@outlook.com',
      name: 'Juan Morales',
      permissionLevel: 1,
    );
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    await Future.delayed(const Duration(seconds: 1));
    if (email == 'error@test.com') {
      throw Exception('Correo no encontrado');
    }
  }

  @override
  Future<GuiaUserModel> loginWithAgencyToken(String token) async {
    await Future.delayed(const Duration(seconds: 1));
    return const GuiaUserModel(
      id: 'guia_agency_001',
      email: 'guia@agencia.com',
      name: 'Guía Agencia',
      permissionLevel: 2,
    );
  }

  // ── B2B Agency flow ───────────────────────────────────────────────────────

  /// Mapa: folio → teléfono registrado por la agencia
  static const Map<String, String> _mockFolios = {
    'AG-001': '7225698563',
    'AG-002': '5512345678',
    'AG-003': '3310203040',
  };

  @override
  Future<void> verifyFolio(String folio) async {
    await Future.delayed(const Duration(seconds: 1));
    if (!_mockFolios.containsKey(folio.toUpperCase().trim())) {
      throw Exception(
        'Folio no encontrado. Verifica los datos o ponte en contacto con el administrador de la agencia',
      );
    }
  }

  @override
  Future<GuiaUserModel> loginWithAgencyAccess(
    String folio,
    String phone,
  ) async {
    await Future.delayed(const Duration(seconds: 1));
    final canonFolio = folio.toUpperCase().trim();
    final registeredPhone = _mockFolios[canonFolio];

    if (registeredPhone == null) {
      throw Exception(
        'Folio no encontrado. Verifica los datos o ponte en contacto con el administrador de la agencia',
      );
    }

    if (phone.trim() != registeredPhone) {
      throw Exception(
        'El número de teléfono no coincide con el folio ingresado. Contacta a tu agencia',
      );
    }

    return GuiaUserModel(
      id: 'guia_b2b_${canonFolio.replaceAll('-', '_').toLowerCase()}',
      email: 'guia_${canonFolio.toLowerCase()}@agencia.com',
      name: 'Guía $canonFolio',
      permissionLevel: 2,
    );
  }
}
