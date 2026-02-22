import '../../domain/entities/agencia_home_data.dart';
import '../../domain/entities/personal_home_data.dart';
import '../../domain/repositories/guia_home_repository.dart';
import '../datasources/guia_home_mock_datasource.dart';

class GuiaHomeRepositoryImpl implements GuiaHomeRepository {
  final GuiaHomeRemoteDataSource remoteDataSource;

  GuiaHomeRepositoryImpl({required this.remoteDataSource});

  @override
  Future<AgenciaHomeData> getAgenciaHomeData(String folio) async {
    // Aquí puedes capturar excepciones y convertirlas en Failures
    return await remoteDataSource.getAgenciaHomeData(folio);
  }

  @override
  Future<PersonalHomeData> getPersonalHomeData(String nombreGuia) async {
    return await remoteDataSource.getPersonalHomeData(nombreGuia);
  }
}
