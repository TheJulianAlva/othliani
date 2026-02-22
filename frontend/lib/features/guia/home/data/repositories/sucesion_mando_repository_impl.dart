import '../../domain/repositories/sucesion_mando_repository.dart';
import '../datasources/sucesion_mando_datasource.dart';

class SucesionMandoRepositoryImpl implements SucesionMandoRepository {
  final SucesionMandoDataSource dataSource;

  SucesionMandoRepositoryImpl({required this.dataSource});

  @override
  Future<void> transferirMandoAgencia({
    required String sucesorId,
    required String sucesorNombre,
    required String viajeId,
  }) async {
    return await dataSource.transferirMandoAgencia(
      sucesorId: sucesorId,
      sucesorNombre: sucesorNombre,
      viajeId: viajeId,
    );
  }

  @override
  Future<void> notificarDashboardAgencia({
    required String viajeId,
    required double lat,
    required double lng,
  }) async {
    return await dataSource.notificarDashboardAgencia(
      viajeId: viajeId,
      lat: lat,
      lng: lng,
    );
  }

  @override
  Future<void> enviarSmsEmergencia({
    required String telefono,
    required String nombreContacto,
    required double lat,
    required double lng,
  }) async {
    return await dataSource.enviarSmsEmergencia(
      telefono: telefono,
      nombreContacto: nombreContacto,
      lat: lat,
      lng: lng,
    );
  }

  @override
  Future<void> marcarProtocolo911({
    required double lat,
    required double lng,
  }) async {
    return await dataSource.marcarProtocolo911(lat: lat, lng: lng);
  }
}
