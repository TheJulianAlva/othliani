import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/features/guia/auth/data/models/guia_user_model.dart';
import 'package:frontend/features/guia/auth/domain/entities/guia_user.dart';

void main() {
  const tUserModel = GuiaUserModel(
    id: '123',
    name: 'Roberto Sánchez',
    email: 'roberto@agencia.com',
    phone: '5551234567',
    permissionLevel: 1,
    authStatus: AuthStatus.unauthenticated,
  );

  // Simulamos un JSON crudo que nos regresaría el servidor o el caché local
  final Map<String, dynamic> tJson = {
    "id": "123",
    "name": "Roberto Sánchez",
    "email": "roberto@agencia.com",
    "phone": "5551234567",
    "emergencyContact": null,
    "permissionLevel": 1,
    "authStatus": "unauthenticated",
  };

  group('GuiaUserModel', () {
    test('Debe ser una subclase de la entidad GuiaUser', () {
      expect(tUserModel, isA<GuiaUser>());
    });

    test(
      'fromJson - Debe retornar un modelo válido cuando el JSON es correcto',
      () {
        // Act
        final result = GuiaUserModel.fromJson(tJson);

        // Assert
        expect(result, equals(tUserModel));
      },
    );

    test('toJson - Debe retornar un mapa JSON con los datos correctos', () {
      // Act
      final result = tUserModel.toJson();

      // Assert
      expect(result, equals(tJson));
    });
  });
}
