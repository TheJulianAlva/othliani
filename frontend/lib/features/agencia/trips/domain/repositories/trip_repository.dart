import 'package:dartz/dartz.dart';
import '../../../../../../core/error/failures.dart';
import '../entities/viaje.dart';
import '../../../users/domain/entities/turista.dart';
import '../../../users/domain/entities/guia.dart';

abstract class TripRepository {
  Future<Either<Failure, List<Viaje>>> getListaViajes();
  Future<Either<Failure, Viaje>> getDetalleViaje(String id);
  Future<Either<Failure, List<Turista>>> getTuristasPorViaje(String id);
  Future<Either<Failure, List<Guia>>> getListaGuias(); // Added
  Future<Either<Failure, void>> cancelarViaje(String id);

  // Gestión de creación
  Future<List<String>> buscarFotosDestino(String query);
  Future<void> crearViaje(Viaje viaje);
}
