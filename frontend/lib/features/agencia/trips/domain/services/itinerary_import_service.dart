import '../entities/actividad_itinerario.dart';

// Wrapper para enlazar la actividad con el día en que va (Día 1, Día 2, etc.)
class ActividadImportada {
  final int diaIndex; // 0 para el Día 1, 1 para el Día 2...
  final ActividadItinerario actividad;

  ActividadImportada({required this.diaIndex, required this.actividad});
}

abstract class ItineraryImportService {
  /// Recibe el texto crudo del CSV y devuelve una lista estructurada
  Future<List<ActividadImportada>> parseCsv(String csvString);
}
