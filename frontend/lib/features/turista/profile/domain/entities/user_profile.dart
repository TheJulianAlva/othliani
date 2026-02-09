import 'package:equatable/equatable.dart';

class UserProfile extends Equatable {
  final String name;
  final String email;
  final String? avatarUrl;

  const UserProfile({required this.name, required this.email, this.avatarUrl});

  @override
  List<Object?> get props => [name, email, avatarUrl];
}
