import '../../domain/entities/categoria_actividad.dart';

/// DataSource "While we wait" — simula la futura API de categorías.
///
/// Cuando el backend esté listo:
/// 1. Crea [ApiCategoriasDataSource] con `dio.get('/categorias')`.
/// 2. Cámbialo en [CategoriasRepositoryImpl].
/// 3. Borra este archivo. ¡Nada más!
class MockCategoriasDataSource {
  // "Base de datos" en RAM. En producción será Firestore / REST / GraphQL.
  final List<CategoriaActividad> _store = [...CategoriaActividad.defaults()];

  /// Simula una petición GET /categorias?agenciaId={agenciaId}
  Future<List<CategoriaActividad>> fetchCategorias(String agenciaId) async {
    // Latencia simulada para que el estado loading sea visible en tests
    await Future.delayed(const Duration(milliseconds: 300));
    return List.unmodifiable(_store);
  }

  /// Simula una petición POST /categorias
  Future<void> postCategoria(
    String agenciaId,
    CategoriaActividad categoria,
  ) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _store.add(categoria);
  }
}
