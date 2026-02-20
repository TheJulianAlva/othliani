import 'package:frontend/features/guia/auth/domain/entities/guia_user.dart';

class GuiaUserModel extends GuiaUser {
  const GuiaUserModel({
    required super.id,
    required super.email,
    required super.name,
    super.permissionLevel,
  });

  factory GuiaUserModel.fromJson(Map<String, dynamic> json) {
    return GuiaUserModel(
      id: json['id'],
      email: json['email'],
      name: json['name'],
      permissionLevel: json['permissionLevel'] ?? 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'permissionLevel': permissionLevel,
    };
  }
}
