import 'package:dartz/dartz.dart';
import '../../domain/repositories/trip_repository.dart';
import '../../../../../../core/error/failures.dart';
import '../../../../../../core/services/pexels_service.dart';
import 'package:frontend/features/agencia/shared/data/datasources/agencia_datasource.dart'; // Legacy datasource usage
import '../../domain/entities/viaje.dart';
import '../../../users/domain/entities/turista.dart';
import '../../../users/domain/entities/guia.dart';

class TripRepositoryImpl implements TripRepository {
  final AgenciaDataSource dataSource;
  final PexelsService pexelsService;

  TripRepositoryImpl(this.dataSource, this.pexelsService);

  @override
  Future<Either<Failure, List<Viaje>>> getListaViajes() async {
    try {
      final result = await dataSource.getListaViajes();
      // Need to cast or map if the datasource returns legacy entities?
      // Ensure AgenciaDataSource imports the NEW Viaje entity or handles the path change.
      // This is a tricky part. I must update AgenciaMockDataSource imports too.
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

  @override
  Future<Either<Failure, List<Turista>>> getTuristasPorViaje(String id) async {
    try {
      final result = await dataSource.getTuristasByViajeId(id);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, List<Guia>>> getListaGuias() async {
    try {
      final result = await dataSource.getListaGuias();
      return Right(result);
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, void>> cancelarViaje(String id) async {
    try {
      final result = await dataSource.simularDeleteViaje(id);
      if (result) {
        return const Right(null);
      } else {
        return Left(ServerFailure());
      }
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<List<String>> buscarFotosDestino(String query) async {
    try {
      return await pexelsService.buscarFotos(query);
    } catch (e) {
      return [];
    }
  }

  @override
  Future<void> crearViaje(Viaje viaje) async {
    // await dataSource.createViaje(viaje); // Pending datasource implementation
    await Future.delayed(const Duration(seconds: 1));
  }
}
