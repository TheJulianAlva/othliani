import '../entities/categoria_actividad.dart';

/// Contrato de acceso a las categorías de actividad de una agencia.
/// La UI y el Cubit dependen SOLO de esta interfaz — nunca de la implementación.
///
/// Cuando llegue la API real, crea [ApiCategoriasDataSource] y actualiza
/// [CategoriasRepositoryImpl]. Nada más cambia.
abstract class CategoriasRepository {
  /// Devuelve las categorías disponibles para la agencia: defaults + personalizadas.
  /// [agenciaId] se usará cuando llegue el backend para filtrar por agencia.
  Future<List<CategoriaActividad>> obtenerCategorias(String agenciaId);

  /// Persiste una categoría nueva creada por el usuario.
  Future<void> guardarCategoriaPersonalizada(
    String agenciaId,
    CategoriaActividad categoria,
  );
}
