import '../../core/mock/mock_database.dart';
import '../../data/models/dashboard_data_model.dart';

abstract class AgenciaDataSource {
  Future<DashboardDataModel> getDashboardData();
}

class AgenciaMockDataSourceImpl implements AgenciaDataSource {
  final MockDatabase db;

  AgenciaMockDataSourceImpl(this.db);

  @override
  Future<DashboardDataModel> getDashboardData() async {
    try {
      final data = await db.getDashboardFullData();
      return DashboardDataModel.fromJson(data);
    } catch (e) {
      throw Exception('Error en base de datos simulada');
    }
  }
}
