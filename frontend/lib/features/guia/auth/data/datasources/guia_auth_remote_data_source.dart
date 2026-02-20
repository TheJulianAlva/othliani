import 'package:frontend/features/guia/auth/data/models/guia_user_model.dart';

abstract class GuiaAuthRemoteDataSource {
  Future<GuiaUserModel> login(String email, String password);
  Future<void> sendPasswordResetEmail(String email);
  Future<GuiaUserModel> loginWithAgencyToken(String token);

  // B2B Agency flow
  Future<void> verifyFolio(String folio);
  Future<GuiaUserModel> loginWithAgencyAccess(String folio, String phone);
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
