import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:frontend/core/usecase/usecase.dart';
import 'package:frontend/features/turista/auth/domain/usecases/complete_onboarding_usecase.dart';

abstract class OnboardingState extends Equatable {
  const OnboardingState();
  @override
  List<Object> get props => [];
}

class OnboardingInitial extends OnboardingState {}

class OnboardingLoading extends OnboardingState {}

class OnboardingCompleted extends OnboardingState {}

class OnboardingCubit extends Cubit<OnboardingState> {
  final CompleteOnboardingUseCase completeOnboardingUseCase;

  OnboardingCubit({required this.completeOnboardingUseCase})
    : super(OnboardingInitial());

  Future<void> completeOnboarding() async {
    emit(OnboardingLoading());
    await completeOnboardingUseCase(NoParams());
    emit(OnboardingCompleted());
  }
}
