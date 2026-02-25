import '../entities/personal_home_data.dart';
import '../repositories/guia_home_repository.dart';

class GetPersonalHomeDataUseCase {
  final GuiaHomeRepository repository;

  GetPersonalHomeDataUseCase(this.repository);

  Future<PersonalHomeData> call(String nombreGuia) async {
    return await repository.getPersonalHomeData(nombreGuia);
  }
}
