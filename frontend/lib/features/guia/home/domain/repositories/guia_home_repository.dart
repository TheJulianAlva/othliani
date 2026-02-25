import '../entities/agencia_home_data.dart';
import '../entities/personal_home_data.dart';

abstract class GuiaHomeRepository {
  Future<AgenciaHomeData> getAgenciaHomeData(String folio);
  Future<PersonalHomeData> getPersonalHomeData(String nombreGuia);
}
