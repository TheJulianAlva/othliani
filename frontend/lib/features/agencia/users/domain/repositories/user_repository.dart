import 'package:dartz/dartz.dart';
import '../../../../../../core/error/failures.dart';
import '../entities/turista.dart';
import '../entities/guia.dart';

abstract class UserRepository {
  Future<Either<Failure, List<Turista>>> getListaClientes();
  Future<Either<Failure, List<Guia>>> getListaGuias();
  // Future<Either<Failure, List<Turista>>> getTuristasPorViaje(String id); // Delegated to TripRepository for now
}
