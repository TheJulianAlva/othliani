import 'package:dartz/dartz.dart';
import '../../domain/repositories/user_repository.dart';
import '../../../../../../core/error/failures.dart';
import '../../../../../../data/datasources/agencia_mock_data_source.dart'; // Or abstract interface?
import '../../domain/entities/turista.dart';
import '../../domain/entities/guia.dart';

class UserRepositoryImpl implements UserRepository {
  final AgenciaDataSource dataSource;

  UserRepositoryImpl(this.dataSource);

  @override
  Future<Either<Failure, List<Turista>>> getListaClientes() async {
    try {
      // Assuming getTuristas exists in DataSource or we use getListaClientes logic (which returned Turistas)
      final result = await dataSource.getTuristas();
      return Right(result);
    } catch (e) {
      return Left(ServerFailure());
    }
  }

  @override
  Future<Either<Failure, List<Guia>>> getListaGuias() async {
    try {
      final result = await dataSource.getGuias(); // Or getListaGuias
      return Right(result);
    } catch (e) {
      return Left(ServerFailure());
    }
  }
}
