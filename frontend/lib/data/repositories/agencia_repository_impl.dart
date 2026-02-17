import 'package:dartz/dartz.dart';
import '../../domain/repositories/agencia_repository.dart';
import '../../features/agencia/dashboard/domain/entities/dashboard_data.dart';
import '../datasources/agencia_mock_data_source.dart';
import '../../core/error/failures.dart';
import '../../features/agencia/trips/domain/entities/viaje.dart';
// import '../../features/agencia/users/domain/entities/guia.dart';
// import '../../features/agencia/users/domain/entities/turista.dart';
// import '../../features/agencia/audit/domain/entities/log_auditoria.dart';

import 'package:connectivity_plus/connectivity_plus.dart'; // ✨ Nuevo Import
import '../../core/services/pexels_service.dart'; // Restaurado

class AgenciaRepositoryImpl implements AgenciaRepository {
  final AgenciaDataSource dataSource;
  final PexelsService pexelsService;
  final Connectivity connectivity; // ✨ Nueva Inyección

  AgenciaRepositoryImpl(this.dataSource, this.pexelsService, this.connectivity);

  // ✨ Implementación del Stream
  @override
  Stream<List<ConnectivityResult>> get onConnectivityChanged =>
      connectivity.onConnectivityChanged;

  // ... (métodos existentes)

  // ✅ Implementación real de la búsqueda de fotos
  @override
  Future<List<String>> buscarFotosDestino(String query) async {
    try {
      // Aquí decidimos usar Pexels. Si mañana usamos Google, solo cambiamos esto.
      return await pexelsService.buscarFotos(query);
    } catch (e) {
      return []; // Manejo de errores básico
    }
  }

  @override
  Future<void> crearViaje(Viaje viaje) async {
    // Aquí llamaríamos a la API real. Por ahora, al mock.
    // Necesitamos asegurarnos de que el DataSource tenga este método (lo agregaremos)
    // return dataSource.createViaje(viaje);
    // Por ahora simulamos
    await Future.delayed(const Duration(seconds: 1));
  }

  @override
  Future<Either<Failure, DashboardData>> getDashboardData() async {
    try {
      final result = await dataSource.getDashboardData();
      return Right(result);
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, List<Viaje>>> getListaViajes() async {
    try {
      final result = await dataSource.getListaViajes();
      return Right(result);
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, Viaje>> getDetalleViaje(String id) async {
    try {
      final result = await dataSource.getDetalleViaje(id);
      if (result != null) {
        return Right(result);
      } else {
        return Left(ServerFailure());
      }
    } catch (e) {
      return Left(ServerFailure());
    }
  }
}
