import 'package:flutter_test/flutter_test.dart';
import 'package:frontend/features/guia/auth/domain/entities/guia_user.dart';

void main() {
  // 1. Arrange: Preparamos los datos de prueba
  const tGuiaUser1 = GuiaUser(
    id: '123',
    name: 'Roberto Sánchez',
    email: 'roberto@agencia.com',
    phone: '5551234567',
    permissionLevel: 1, // Ej: B2B
  );

  const tGuiaUser2 = GuiaUser(
    id: '123',
    name: 'Roberto Sánchez',
    email: 'roberto@agencia.com',
    phone: '5551234567',
    permissionLevel: 1,
  );

  const tGuiaPersonal = GuiaUser(
    id: '456',
    name: 'Carlos Ruiz',
    email: 'carlos@personal.com',
    phone: '5559876543',
    permissionLevel: 2, // Ej: B2C
  );

  group('GuiaUser Entity', () {
    test(
      'Debe ser una subclase de Equatable (comparación por valor, no por referencia)',
      () {
        // Assert
        expect(tGuiaUser1, equals(tGuiaUser2));
        expect(tGuiaUser1 == tGuiaUser2, isTrue);
      },
    );

    test('Usuarios con diferentes IDs o propiedades no deben ser iguales', () {
      // Assert
      expect(tGuiaUser1, isNot(equals(tGuiaPersonal)));
    });

    test('Debe instanciar correctamente con status por defecto', () {
      // Assert
      expect(tGuiaUser1.authStatus, equals(AuthStatus.unauthenticated));
    });
  });
}
