import 'package:flutter_bloc/flutter_bloc.dart';

// ─────────────────────────────────────────────────────────────────────────────
// EcoModeCubit
//
// Estado: bool  true = Modo Eco activo (pantalla negra OLED)
//               false = Modo normal
// ─────────────────────────────────────────────────────────────────────────────

class EcoModeCubit extends Cubit<bool> {
  EcoModeCubit() : super(false); // Inicia apagado

  void enableEcoMode() => emit(true);
  void disableEcoMode() => emit(false);
  void toggleEcoMode() => emit(!state);
}
