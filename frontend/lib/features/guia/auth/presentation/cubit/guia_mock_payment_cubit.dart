import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:frontend/features/guia/auth/domain/usecases/activate_subscription_guia_usecase.dart';

// ── States ────────────────────────────────────────────────────────────────

abstract class GuiaMockPaymentState extends Equatable {
  const GuiaMockPaymentState();
  @override
  List<Object?> get props => [];
}

class GuiaMockPaymentInitial extends GuiaMockPaymentState {}

class GuiaMockPaymentProcessing extends GuiaMockPaymentState {}

class GuiaMockPaymentSuccess extends GuiaMockPaymentState {}

class GuiaMockPaymentFailure extends GuiaMockPaymentState {
  final String message;
  const GuiaMockPaymentFailure(this.message);
  @override
  List<Object> get props => [message];
}

// ── Cubit ─────────────────────────────────────────────────────────────────

class GuiaMockPaymentCubit extends Cubit<GuiaMockPaymentState> {
  final ActivateSubscriptionGuiaUseCase activateSubscriptionUseCase;

  GuiaMockPaymentCubit({required this.activateSubscriptionUseCase})
    : super(GuiaMockPaymentInitial());

  Future<void> activateSubscription(
    ActivateSubscriptionGuiaParams params,
  ) async {
    emit(GuiaMockPaymentProcessing());

    final result = await activateSubscriptionUseCase(params);

    result.fold(
      (failure) => emit(GuiaMockPaymentFailure(failure.message)),
      (_) => emit(GuiaMockPaymentSuccess()),
    );
  }
}
