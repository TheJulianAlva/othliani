import 'package:equatable/equatable.dart';
import '../../core/mock/mock_models.dart';

class DashboardData extends Equatable {
  final int viajesActivos;
  final int viajesProgramados;
  final int turistasEnCampo;
  final int alertasCriticas;
  final int guiasOffline;

  // Real lists for UI
  final List<MockViaje> viajesEnMapa;
  final List<MockAlerta> alertasRecientes;

  const DashboardData({
    required this.viajesActivos,
    required this.viajesProgramados,
    required this.turistasEnCampo,
    required this.alertasCriticas,
    required this.guiasOffline,
    required this.viajesEnMapa,
    required this.alertasRecientes,
  });

  @override
  List<Object?> get props => [
    viajesActivos,
    viajesProgramados,
    turistasEnCampo,
    alertasCriticas,
    guiasOffline,
    viajesEnMapa,
    alertasRecientes,
  ];
}
