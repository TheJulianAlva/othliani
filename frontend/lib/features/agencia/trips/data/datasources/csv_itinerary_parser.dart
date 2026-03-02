import 'package:uuid/uuid.dart';
import 'package:csv/csv.dart';
import '../../domain/entities/actividad_itinerario.dart';

/// Utilidad para parsear archivos CSV e importar itinerarios.
///
/// **Estructura CSV de un día:**
/// ```
/// titulo,descripcion,hora_inicio,hora_fin,tipo,recomendaciones
/// Check-in Hotel,Registro en hotel,08:00,09:00,hospedaje,Llevar ID
/// ```
///
/// **Estructura CSV de viaje completo:**
/// ```
/// dia,titulo,descripcion,hora_inicio,hora_fin,tipo,recomendaciones
/// 1,Check-in Hotel,Registro,08:00,09:00,hospedaje,Llevar ID
/// ```
class CsvItineraryParser {
  CsvItineraryParser._();

  // ── Tipos válidos ──
  static final _tipoMap = {
    'hospedaje': TipoActividad.hospedaje,
    'alimentos': TipoActividad.comida,
    'traslado': TipoActividad.traslado,
    'cultura': TipoActividad.cultura,
    'aventura': TipoActividad.aventura,
    'tiempolibre': TipoActividad.tiempoLibre,
    'tiempo_libre': TipoActividad.tiempoLibre,
    'tiempo libre': TipoActividad.tiempoLibre,
  };

  /// Mensaje de ayuda para mostrar al usuario con la estructura esperada.
  static String get ayudaCsvDia => '''Estructura esperada del CSV (un día):

titulo,descripcion,hora_inicio,hora_fin,tipo,recomendaciones
Check-in,Registro en el hotel,08:00,09:00,hospedaje,Llevar ID
Desayuno,En el restaurante,09:00,10:00,alimentos,
Tour,Visita al centro,10:30,13:00,cultura,Zapatos cómodos

Tipos válidos: hospedaje, alimentos, traslado, cultura, aventura, tiempoLibre
Formato de hora: HH:mm (24 horas)
El campo recomendaciones es opcional.''';

  static String get ayudaCsvCompleto =>
      '''Estructura esperada del CSV (viaje completo):

dia,titulo,descripcion,hora_inicio,hora_fin,tipo,recomendaciones
1,Check-in,Registro en hotel,08:00,09:00,hospedaje,Llevar ID
1,Desayuno,Restaurante,09:00,10:00,alimentos,
2,Traslado,Bus a la playa,07:00,09:00,traslado,
2,Playa,Día libre,09:30,16:00,tiempoLibre,Protector solar

Tipos válidos: hospedaje, alimentos, traslado, cultura, aventura, tiempoLibre
Formato de hora: HH:mm (24 horas)
El campo recomendaciones es opcional.''';

  // ── Parsear CSV de un solo día ──
  static List<ActividadItinerario> parseSingleDay(
    String csvContent,
    DateTime fechaBase,
  ) {
    final rows = const CsvToListConverter(eol: '\n').convert(csvContent.trim());
    if (rows.isEmpty) throw FormatException('El CSV está vacío');

    // Verificar header
    final header =
        rows.first.map((e) => e.toString().trim().toLowerCase()).toList();
    final expectedHeader = [
      'titulo',
      'descripcion',
      'hora_inicio',
      'hora_fin',
      'tipo',
    ];
    for (final col in expectedHeader) {
      if (!header.contains(col)) {
        throw FormatException(
          'Falta la columna "$col" en el encabezado del CSV',
        );
      }
    }

    final actividades = <ActividadItinerario>[];

    for (int i = 1; i < rows.length; i++) {
      final row = rows[i];
      if (row.length < 5) continue; // saltar filas vacías o incompletas

      try {
        final titulo = row[header.indexOf('titulo')].toString().trim();
        final descripcion =
            row[header.indexOf('descripcion')].toString().trim();
        final horaInicioStr =
            row[header.indexOf('hora_inicio')].toString().trim();
        final horaFinStr = row[header.indexOf('hora_fin')].toString().trim();
        final tipoStr =
            row[header.indexOf('tipo')].toString().trim().toLowerCase();
        final recomendaciones =
            header.contains('recomendaciones')
                ? row[header.indexOf('recomendaciones')].toString().trim()
                : '';

        if (titulo.isEmpty) continue;

        final horaInicio = _parseTime(horaInicioStr, fechaBase);
        final horaFin = _parseTime(horaFinStr, fechaBase);
        final tipo = _tipoMap[tipoStr] ?? TipoActividad.tiempoLibre;

        actividades.add(
          ActividadItinerario(
            id: const Uuid().v4(),
            titulo: titulo,
            descripcion:
                descripcion.isNotEmpty ? descripcion : 'Actividad importada',
            horaInicio: horaInicio,
            horaFin: horaFin,
            tipo: tipo,
            recomendaciones: recomendaciones,
          ),
        );
      } catch (e) {
        throw FormatException('Error en la fila ${i + 1}: $e');
      }
    }

    if (actividades.isEmpty) {
      throw FormatException('No se encontraron actividades válidas en el CSV');
    }

    return actividades;
  }

  // ── Parsear CSV de viaje completo ──
  static Map<int, List<ActividadItinerario>> parseFullTrip(
    String csvContent,
    DateTime fechaInicio,
  ) {
    final rows = const CsvToListConverter(eol: '\n').convert(csvContent.trim());
    if (rows.isEmpty) throw FormatException('El CSV está vacío');

    // Verificar header
    final header =
        rows.first.map((e) => e.toString().trim().toLowerCase()).toList();
    final expectedHeader = [
      'dia',
      'titulo',
      'descripcion',
      'hora_inicio',
      'hora_fin',
      'tipo',
    ];
    for (final col in expectedHeader) {
      if (!header.contains(col)) {
        throw FormatException(
          'Falta la columna "$col" en el encabezado del CSV',
        );
      }
    }

    final mapa = <int, List<ActividadItinerario>>{};

    for (int i = 1; i < rows.length; i++) {
      final row = rows[i];
      if (row.length < 6) continue;

      try {
        final diaNum = int.parse(row[header.indexOf('dia')].toString().trim());
        final diaIndex = diaNum - 1; // día 1 → index 0
        final fechaDia = fechaInicio.add(Duration(days: diaIndex));
        final fechaBase = DateTime(fechaDia.year, fechaDia.month, fechaDia.day);

        final titulo = row[header.indexOf('titulo')].toString().trim();
        final descripcion =
            row[header.indexOf('descripcion')].toString().trim();
        final horaInicioStr =
            row[header.indexOf('hora_inicio')].toString().trim();
        final horaFinStr = row[header.indexOf('hora_fin')].toString().trim();
        final tipoStr =
            row[header.indexOf('tipo')].toString().trim().toLowerCase();
        final recomendaciones =
            header.contains('recomendaciones')
                ? row[header.indexOf('recomendaciones')].toString().trim()
                : '';

        if (titulo.isEmpty) continue;

        final horaInicio = _parseTime(horaInicioStr, fechaBase);
        final horaFin = _parseTime(horaFinStr, fechaBase);
        final tipo = _tipoMap[tipoStr] ?? TipoActividad.tiempoLibre;

        final actividad = ActividadItinerario(
          id: const Uuid().v4(),
          titulo: titulo,
          descripcion:
              descripcion.isNotEmpty ? descripcion : 'Actividad importada',
          horaInicio: horaInicio,
          horaFin: horaFin,
          tipo: tipo,
          recomendaciones: recomendaciones,
        );

        mapa.putIfAbsent(diaIndex, () => []);
        mapa[diaIndex]!.add(actividad);
      } catch (e) {
        throw FormatException('Error en la fila ${i + 1}: $e');
      }
    }

    if (mapa.isEmpty) {
      throw FormatException('No se encontraron actividades válidas en el CSV');
    }

    return mapa;
  }

  // ── Parsear hora "HH:mm" con fecha base ──
  static DateTime _parseTime(String timeStr, DateTime fechaBase) {
    final parts = timeStr.split(':');
    if (parts.length != 2) {
      throw FormatException('Formato de hora inválido: "$timeStr". Use HH:mm');
    }
    final hora = int.parse(parts[0]);
    final minuto = int.parse(parts[1]);
    if (hora < 0 || hora > 23 || minuto < 0 || minuto > 59) {
      throw FormatException('Hora fuera de rango: "$timeStr"');
    }
    return DateTime(
      fechaBase.year,
      fechaBase.month,
      fechaBase.day,
      hora,
      minuto,
    );
  }
}
