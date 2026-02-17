import 'package:equatable/equatable.dart';

class AuthUser extends Equatable {
  final String id;
  final String email;
  final String name;
  final String role; // 'ADMIN', 'AGENCY_ADMIN', 'GUIDE'

  const AuthUser({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
  });

  @override
  List<Object?> get props => [id, email, name, role];
}
