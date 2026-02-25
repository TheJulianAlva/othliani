import '../entities/agencia_home_data.dart';
import '../repositories/guia_home_repository.dart';

class GetAgenciaHomeDataUseCase {
  final GuiaHomeRepository repository;

  GetAgenciaHomeDataUseCase(this.repository);

  Future<AgenciaHomeData> call(String folio) async {
    return await repository.getAgenciaHomeData(folio);
  }
}
