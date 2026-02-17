import '../../domain/entities/dashboard_stats.dart';

class DashboardStatsModel extends DashboardStats {
  const DashboardStatsModel({
    required super.viajesActivos,
    required super.turistasEnCampo,
    required super.alertasCriticas,
    required super.guiasOffline,
  });

  factory DashboardStatsModel.fromJson(Map<String, dynamic> json) {
    return DashboardStatsModel(
      viajesActivos: json['viajes_activos'],
      turistasEnCampo: json['turistas_campo'],
      alertasCriticas: json['alertas_criticas'],
      guiasOffline: json['guias_offline'],
    );
  }
}
