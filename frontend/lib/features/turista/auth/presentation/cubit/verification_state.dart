import 'package:equatable/equatable.dart';

abstract class VerificationState extends Equatable {
  const VerificationState();

  @override
  List<Object> get props => [];
}

class VerificationInitial extends VerificationState {}

class VerificationLoading extends VerificationState {}

class FolioVerified extends VerificationState {
  final bool isValid;

  const FolioVerified(this.isValid);

  @override
  List<Object> get props => [isValid];
}

class PhoneCodeSent extends VerificationState {}

class PhoneVerified extends VerificationState {
  final bool isValid;

  const PhoneVerified(this.isValid);

  @override
  List<Object> get props => [isValid];
}

class EmailSent extends VerificationState {}

class VerificationError extends VerificationState {
  final String message;

  const VerificationError(this.message);

  @override
  List<Object> get props => [message];
}
