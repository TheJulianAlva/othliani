import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Define FontSizeOption if it was in AccessibilityProvider
enum FontSizeOption { small, medium, large, extraLarge }

class AccessibilityState extends Equatable {
  final FontSizeOption fontSize;
  final bool highContrast;
  final bool screenReader;
  final bool reduceAnimations;
  final bool hapticFeedback;

  const AccessibilityState({
    this.fontSize = FontSizeOption.medium,
    this.highContrast = false,
    this.screenReader = false,
    this.reduceAnimations = false,
    this.hapticFeedback = true,
  });

  AccessibilityState copyWith({
    FontSizeOption? fontSize,
    bool? highContrast,
    bool? screenReader,
    bool? reduceAnimations,
    bool? hapticFeedback,
  }) {
    return AccessibilityState(
      fontSize: fontSize ?? this.fontSize,
      highContrast: highContrast ?? this.highContrast,
      screenReader: screenReader ?? this.screenReader,
      reduceAnimations: reduceAnimations ?? this.reduceAnimations,
      hapticFeedback: hapticFeedback ?? this.hapticFeedback,
    );
  }

  @override
  List<Object?> get props => [
    fontSize,
    highContrast,
    screenReader,
    reduceAnimations,
    hapticFeedback,
  ];
}

class AccessibilityCubit extends Cubit<AccessibilityState> {
  AccessibilityCubit() : super(const AccessibilityState());

  void setFontSize(FontSizeOption option) =>
      emit(state.copyWith(fontSize: option));
  void setHighContrast(bool value) => emit(state.copyWith(highContrast: value));
  void setScreenReader(bool value) => emit(state.copyWith(screenReader: value));
  void setReduceAnimations(bool value) =>
      emit(state.copyWith(reduceAnimations: value));
  void setHapticFeedback(bool value) =>
      emit(state.copyWith(hapticFeedback: value));
}
