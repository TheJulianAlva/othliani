import 'package:equatable/equatable.dart';

abstract class GuiaForgotPasswordState extends Equatable {
  const GuiaForgotPasswordState();

  @override
  List<Object?> get props => [];
}

class GuiaForgotPasswordInitial extends GuiaForgotPasswordState {}

class GuiaForgotPasswordLoading extends GuiaForgotPasswordState {}

class GuiaForgotPasswordSuccess extends GuiaForgotPasswordState {}

class GuiaForgotPasswordFailure extends GuiaForgotPasswordState {
  final String message;

  const GuiaForgotPasswordFailure(this.message);

  @override
  List<Object?> get props => [message];
}
