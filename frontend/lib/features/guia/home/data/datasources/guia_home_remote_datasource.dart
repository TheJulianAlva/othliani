import 'package:frontend/features/guia/home/domain/entities/agencia_home_data.dart';
import 'package:frontend/features/guia/home/domain/entities/personal_home_data.dart';

abstract class GuiaHomeRemoteDataSource {
  Future<AgenciaHomeData> getAgenciaHomeData(String folio);
  Future<PersonalHomeData> getPersonalHomeData(String nombreGuia);
}
