import '../../core/mock/mock_database.dart';
import '../models/dashboard_stats_model.dart';

abstract class AgenciaDataSource {
  Future<DashboardStatsModel> getStats();
}

class AgenciaMockDataSourceImpl implements AgenciaDataSource {
  final MockDatabase db;

  AgenciaMockDataSourceImpl(this.db);

  @override
  Future<DashboardStatsModel> getStats() async {
    try {
      final data = await db.getDashboardStats();
      return DashboardStatsModel.fromJson(data);
    } catch (e) {
      throw Exception('Error en base de datos simulada');
    }
  }
}
