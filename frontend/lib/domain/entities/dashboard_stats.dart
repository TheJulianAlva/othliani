import 'package:equatable/equatable.dart';

class DashboardStats extends Equatable {
  final int viajesActivos;
  final int turistasEnCampo;
  final int alertasCriticas;
  final int guiasOffline;

  const DashboardStats({
    required this.viajesActivos,
    required this.turistasEnCampo,
    required this.alertasCriticas,
    required this.guiasOffline,
  });

  @override
  List<Object?> get props => [
    viajesActivos,
    turistasEnCampo,
    alertasCriticas,
    guiasOffline,
  ];
}
