import '../../core/mock/mock_models.dart';
import '../../domain/entities/dashboard_data.dart';

class DashboardDataModel extends DashboardData {
  const DashboardDataModel({
    required super.viajesActivos,
    required super.viajesProgramados,
    required super.turistasEnCampo,
    required super.alertasCriticas,
    required super.guiasOffline,
    required super.viajesEnMapa,
    required super.alertasRecientes,
  });

  factory DashboardDataModel.fromJson(Map<String, dynamic> json) {
    return DashboardDataModel(
      viajesActivos: json['viajes_activos'],
      viajesProgramados: json['viajes_programados'],
      turistasEnCampo: json['turistas_campo'],
      alertasCriticas: json['alertas_criticas'],
      guiasOffline: json['guias_offline'],
      viajesEnMapa:
          (json['viajes_mapa'] as List).map((e) => e as MockViaje).toList(),
      alertasRecientes:
          (json['alertas_recientes'] as List)
              .map((e) => e as MockAlerta)
              .toList(),
    );
  }
}
