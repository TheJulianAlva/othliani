import 'package:equatable/equatable.dart';
import 'package:frontend/features/guia/auth/domain/entities/guia_user.dart';

abstract class GuiaLoginState extends Equatable {
  const GuiaLoginState();

  @override
  List<Object?> get props => [];
}

class GuiaLoginInitial extends GuiaLoginState {}

class GuiaLoginLoading extends GuiaLoginState {}

class GuiaLoginSuccess extends GuiaLoginState {
  final GuiaUser user;

  const GuiaLoginSuccess(this.user);

  @override
  List<Object?> get props => [user];
}

class GuiaLoginFailure extends GuiaLoginState {
  final String message;

  const GuiaLoginFailure(this.message);

  @override
  List<Object?> get props => [message];
}
