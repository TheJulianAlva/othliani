import 'package:flutter/foundation.dart';

/// Servicio singleton para rastrear si hay cambios sin guardar en toda la aplicación.
/// Útil para prevenir cierre de app o logout accidental.
class UnsavedChangesService {
  final ValueNotifier<bool> _isDirtyNotifier = ValueNotifier(false);

  ValueNotifier<bool> get isDirtyNotifier => _isDirtyNotifier;
  bool get isDirty => _isDirtyNotifier.value;

  void setDirty(bool value) {
    if (_isDirtyNotifier.value != value) {
      _isDirtyNotifier.value = value;
      if (kDebugMode) {
        print("📝 UnsavedChangesService: Dirty state changed to $value");
      }
    }
  }

  /// Resetea el estado a "limpio" (sin cambios sin guardar)
  void reset() {
    setDirty(false);
  }
}
