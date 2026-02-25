import 'package:frontend/features/guia/auth/domain/entities/guia_user.dart';

class GuiaUserModel extends GuiaUser {
  const GuiaUserModel({
    required super.id,
    required super.email,
    required super.name,
    super.phone,
    super.emergencyContact,
    super.permissionLevel,
    super.authStatus,
  });

  factory GuiaUserModel.fromJson(Map<String, dynamic> json) {
    return GuiaUserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      name: json['name'] as String,
      phone: json['phone'] as String?,
      emergencyContact: json['emergencyContact'] as String?,
      permissionLevel: json['permissionLevel'] as int? ?? 1,
      authStatus: AuthStatus.values.firstWhere(
        (e) => e.name == (json['authStatus'] as String? ?? 'unauthenticated'),
        orElse: () => AuthStatus.unauthenticated,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'phone': phone,
      'emergencyContact': emergencyContact,
      'permissionLevel': permissionLevel,
      'authStatus': authStatus.name,
    };
  }
}
