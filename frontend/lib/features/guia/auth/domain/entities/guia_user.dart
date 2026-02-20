import 'package:equatable/equatable.dart';

class GuiaUser extends Equatable {
  final String id;
  final String email;
  final String name;
  final int permissionLevel;

  const GuiaUser({
    required this.id,
    required this.email,
    required this.name,
    this.permissionLevel = 1,
  });

  @override
  List<Object?> get props => [id, email, name, permissionLevel];
}
