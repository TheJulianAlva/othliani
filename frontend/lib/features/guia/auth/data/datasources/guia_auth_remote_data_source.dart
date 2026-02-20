import 'package:frontend/features/guia/auth/data/models/guia_user_model.dart';

abstract class GuiaAuthRemoteDataSource {
  Future<GuiaUserModel> login(String email, String password);
  Future<void> sendPasswordResetEmail(String email);
  Future<GuiaUserModel> loginWithAgencyToken(String token);
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
    // Stub: flujo de autenticación mediante token de agencia
    await Future.delayed(const Duration(seconds: 1));
    return const GuiaUserModel(
      id: 'guia_agency_001',
      email: 'guia@agencia.com',
      name: 'Guía Agencia',
      permissionLevel: 2,
    );
  }
}
