import '../../domain/entities/agencia_home_data.dart';
import '../../domain/entities/personal_home_data.dart';
import '../../domain/repositories/guia_home_repository.dart';
import '../datasources/guia_home_mock_datasource.dart'; // <--- Importamos tu Mock
import '../datasources/guia_home_remote_datasource.dart';

class GuiaHomeRepositoryImpl implements GuiaHomeRepository {
  final GuiaHomeRemoteDataSource remoteDataSource;
  final GuiaHomeMockDataSource mockDataSource;

  GuiaHomeRepositoryImpl({
    required this.remoteDataSource,
    // Al poner el '?' y quitar el 'required', la línea 86 del locator de GitHub dejará de fallar
    GuiaHomeMockDataSource? mockDataSource, 
  }) : mockDataSource = mockDataSource ?? GuiaHomeMockDataSource();

  @override
  Future<AgenciaHomeData> getAgenciaHomeData(String folio) async {
    // Aquí puedes decidir si quieres que la agencia también sea mock o remote
    return await remoteDataSource.getAgenciaHomeData(folio);
  }

  @override
  Future<PersonalHomeData> getPersonalHomeData(String nombreGuia) async {
    // Mientras estés probando tu Dashboard V2, dejamos que use el Mock.
    // Lo mejor es que el Locator de GitHub ni se entera de este cambio.
    return await mockDataSource.getPersonalHomeData(nombreGuia);
  }
}
