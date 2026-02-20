import 'package:equatable/equatable.dart';

/// Estado del ciclo de vida de la cuenta del guía
enum AuthStatus {
  unauthenticated, // Sin sesión
  emailPending, // Registro exitoso, correo sin verificar
  paymentPending, // Correo verificado, suscripción sin activar
  active, // Cuenta completamente activa
}

class GuiaUser extends Equatable {
  final String id;
  final String email;
  final String name;
  final String? phone;
  final String? emergencyContact;
  final int permissionLevel;
  final AuthStatus authStatus;

  const GuiaUser({
    required this.id,
    required this.email,
    required this.name,
    this.phone,
    this.emergencyContact,
    this.permissionLevel = 1,
    this.authStatus = AuthStatus.unauthenticated,
  });

  @override
  List<Object?> get props => [
    id,
    email,
    name,
    phone,
    emergencyContact,
    permissionLevel,
    authStatus,
  ];
}
