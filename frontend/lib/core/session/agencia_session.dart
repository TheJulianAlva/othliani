/// Sesión de la agencia autenticada.
/// Se llena una sola vez tras un login exitoso y es accesible desde
/// cualquier capa sin romper Clean Architecture.
class AgenciaSession {
  AgenciaSession._();
  static final AgenciaSession instance = AgenciaSession._();

  String? _agenciaId;
  String? _nombreComercial;

  // ── Setters (solo el LoginBloc debe llamarlos) ───────────────────────────

  void inicializar({required String agenciaId, required String nombre}) {
    _agenciaId = agenciaId;
    _nombreComercial = nombre;
  }

  void cerrar() {
    _agenciaId = null;
    _nombreComercial = null;
  }

  // ── Getters ──────────────────────────────────────────────────────────────

  /// Lanza [StateError] si no hay sesión activa (no se llamó [inicializar]).
  String get agenciaId {
    if (_agenciaId == null) {
      throw StateError('AgenciaSession: no hay sesión activa. '
          'Llama a inicializar() tras el login.');
    }
    return _agenciaId!;
  }

  String get nombreComercial => _nombreComercial ?? 'Veltur Agencia';

  bool get estaAutenticada => _agenciaId != null;
}
