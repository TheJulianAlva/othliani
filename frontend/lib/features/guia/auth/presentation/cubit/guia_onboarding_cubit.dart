import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:frontend/core/usecase/usecase.dart';
import 'package:frontend/features/guia/auth/domain/usecases/onboarding_guia_usecase.dart';

// ── Estados ─────────────────────────────────────────────────────────────────

abstract class GuiaOnboardingState extends Equatable {
  const GuiaOnboardingState();

  @override
  List<Object?> get props => [];
}

class GuiaOnboardingInitial extends GuiaOnboardingState {}

class GuiaOnboardingLoading extends GuiaOnboardingState {}

class GuiaOnboardingCompleted extends GuiaOnboardingState {}

// ── Cubit ────────────────────────────────────────────────────────────────────

class GuiaOnboardingCubit extends Cubit<GuiaOnboardingState> {
  final CompleteOnboardingGuiaUseCase completeOnboardingUseCase;

  GuiaOnboardingCubit({required this.completeOnboardingUseCase})
    : super(GuiaOnboardingInitial());

  Future<void> completeOnboarding() async {
    emit(GuiaOnboardingLoading());
    await completeOnboardingUseCase(NoParams());
    emit(GuiaOnboardingCompleted());
  }
}
