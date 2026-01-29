import 'package:equatable/equatable.dart';
import 'viaje.dart';
import 'alerta.dart';

class DashboardData extends Equatable {
  final int viajesActivos;
  final int viajesProgramados;
  final int turistasEnCampo;
  final int turistasSinRed;
  final int alertasCriticas;
  final int guiasOffline;
  final int guiasTotal;

  // Real lists for UI (using Domain Entities)
  final List<Viaje> viajesEnMapa;
  final List<Alerta> alertasRecientes;

  const DashboardData({
    required this.viajesActivos,
    required this.viajesProgramados,
    required this.turistasEnCampo,
    required this.turistasSinRed,
    required this.alertasCriticas,
    required this.guiasOffline,
    required this.guiasTotal,
    required this.viajesEnMapa,
    required this.alertasRecientes,
  });

  @override
  List<Object?> get props => [
    viajesActivos,
    viajesProgramados,
    turistasEnCampo,
    turistasSinRed,
    alertasCriticas,
    guiasOffline,
    guiasTotal,
    viajesEnMapa,
    alertasRecientes,
  ];
}
