import '../../domain/entities/categoria_actividad.dart';
import '../../domain/repositories/categorias_repository.dart';
import '../datasources/mock_categorias_datasource.dart';
// Cuando llegue la API real, reemplaza la línea anterior con:
// import '../datasources/api_categorias_datasource.dart';

/// Implementación del repositorio de categorías.
///
/// Este es el ÚNICO archivo que tocas cuando cambia la fuente de datos.
/// Paso a producción:
///   1. Crear [ApiCategoriasDataSource]
///   2. Cambiar el import de arriba
///   3. Actualizar el tipo de [_dataSource]
///   4. Registrar en service_locator.dart
class CategoriasRepositoryImpl implements CategoriasRepository {
  final MockCategoriasDataSource _dataSource;
  // En producción será: final ApiCategoriasDataSource _dataSource;

  const CategoriasRepositoryImpl(this._dataSource);

  @override
  Future<List<CategoriaActividad>> obtenerCategorias(String agenciaId) =>
      _dataSource.fetchCategorias(agenciaId);

  @override
  Future<void> guardarCategoriaPersonalizada(
    String agenciaId,
    CategoriaActividad categoria,
  ) => _dataSource.postCategoria(agenciaId, categoria);
}
