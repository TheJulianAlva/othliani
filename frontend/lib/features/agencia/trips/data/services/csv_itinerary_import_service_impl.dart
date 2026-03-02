import 'package:csv/csv.dart';
import 'package:uuid/uuid.dart';
import '../../domain/services/itinerary_import_service.dart';
import '../../domain/entities/actividad_itinerario.dart';

class CsvItineraryImportServiceImpl implements ItineraryImportService {
  @override
  Future<List<ActividadImportada>> parseCsv(String csvString) async {
    final normalizedString = csvString.replaceAll('\r\n', '\n');

    List<List<dynamic>> rows = const CsvToListConverter(
      fieldDelimiter: ',',
      eol: '\n',
      shouldParseNumbers: false,
    ).convert(normalizedString);

    if (rows.isEmpty) return [];

    // ✨ 1. MAPEO DINÁMICO DE CABECERAS (Fuzzy Matching)
    // Inicializamos asumiendo que no encontramos nada (-1)
    Map<String, int> columnMap = {
      'dia': -1,
      'inicio': -1,
      'fin': -1,
      'titulo': -1,
      'desc': -1,
      'tipo': -1,
    };

    final headerRow = rows[0];

    // Analizamos la Fila 0 para descubrir en qué columna está cada cosa
    for (int i = 0; i < headerRow.length; i++) {
      final colName = headerRow[i].toString().toLowerCase().trim();

      if (colName.contains('dia') ||
          colName.contains('day') ||
          colName.contains('fecha')) {
        columnMap['dia'] = i;
      } else if (colName.contains('inicio') ||
          colName.contains('start') ||
          colName.contains('hora_inicio')) {
        columnMap['inicio'] = i;
      } else if (colName.contains('fin') ||
          colName.contains('end') ||
          colName.contains('termino')) {
        columnMap['fin'] = i;
      } else if (colName.contains('titulo') ||
          colName.contains('nombre') ||
          colName.contains('actividad')) {
        columnMap['titulo'] = i;
      } else if (colName.contains('desc') ||
          colName.contains('detalle') ||
          colName.contains('nota')) {
        columnMap['desc'] = i;
      } else if (colName.contains('tipo') || colName.contains('categoria')) {
        columnMap['tipo'] = i;
      }
    }

    // 🚨 SISTEMA DE EMERGENCIA (Fallback):
    // Si el usuario no puso cabeceras y mandó los datos directos,
    // o le puso nombres incomprensibles, forzamos el orden estándar.
    if (columnMap['titulo'] == -1 && columnMap['inicio'] == -1) {
      columnMap = {
        'dia': 0,
        'inicio': 1,
        'fin': 2,
        'titulo': 3,
        'desc': 4,
        'tipo': 5,
      };
    }

    List<ActividadImportada> actividadesResultantes = [];
    final baseDate = DateTime.now();

    // 2. ITERAR LOS DATOS USANDO EL MAPA DESCUBIERTO
    for (int i = 1; i < rows.length; i++) {
      var row = rows[i];
      if (row.isEmpty ||
          row.every((element) => element.toString().trim().isEmpty)) {
        continue;
      }

      // Helper para extraer datos de la fila de forma segura evitando IndexOutOfBound
      String extraerDato(String key) {
        int index = columnMap[key] ?? -1;
        if (index >= 0 && index < row.length) {
          return row[index].toString().trim();
        }
        return "";
      }

      try {
        // --- EXTRAER USANDO LOS NOMBRES INFERIDOS ---
        final diaStr = extraerDato('dia');
        final diaRaw = int.tryParse(diaStr) ?? 1;
        final diaIndex = diaRaw > 0 ? diaRaw - 1 : 0;

        final horaInicioStr = extraerDato('inicio');
        final horaInicio = _parseTime(horaInicioStr, baseDate, defaultHour: 8);

        final horaFinStr = extraerDato('fin');
        DateTime horaFin;
        if (horaFinStr.isEmpty) {
          horaFin = horaInicio.add(const Duration(hours: 1));
        } else {
          horaFin = _parseTime(
            horaFinStr,
            baseDate,
            defaultHour: horaInicio.hour + 1,
          );
        }

        if (horaFin.isBefore(horaInicio)) {
          horaFin = horaInicio.add(const Duration(hours: 1));
        }

        String titulo = extraerDato('titulo');
        if (titulo.isEmpty) {
          titulo = "⚠️ Completar Título";
        }

        String descripcion = extraerDato('desc');
        if (descripcion.isEmpty) {
          descripcion = "Falta información. Edita esta tarjeta.";
        }

        final tipo = _parseTipo(extraerDato('tipo'));

        // 3. CREAR EL OBJETO
        final actividad = ActividadItinerario(
          id: const Uuid().v4(),
          titulo: titulo,
          descripcion: descripcion,
          horaInicio: horaInicio,
          horaFin: horaFin,
          tipo: tipo,
        );

        actividadesResultantes.add(
          ActividadImportada(diaIndex: diaIndex, actividad: actividad),
        );
      } catch (e) {
        // print("Fila $i irrecuperable: $e");
        continue;
      }
    }

    return actividadesResultantes;
  }

  // --- Parseador de Tiempo Tolerante a Fallos ---
  DateTime _parseTime(
    String timeStr,
    DateTime baseDate, {
    required int defaultHour,
  }) {
    final cleanedTime = timeStr.trim().replaceAll(
      RegExp(r'[^0-9:]'),
      '',
    ); // Quita letras como "AM/PM" si las hay
    final parts = cleanedTime.split(':');

    int h = defaultHour, m = 0;
    if (parts.isNotEmpty && parts[0].isNotEmpty) {
      h = int.tryParse(parts[0]) ?? defaultHour;
    }
    if (parts.length > 1 && parts[1].isNotEmpty) {
      m = int.tryParse(parts[1]) ?? 0;
    }

    // Validar rango (0-23 hrs, 0-59 mins)
    if (h < 0 || h > 23) {
      h = defaultHour;
    }
    if (m < 0 || m > 59) {
      m = 0;
    }

    return DateTime(baseDate.year, baseDate.month, baseDate.day, h, m);
  }

  // --- Parseador de Tipo Inteligente ---
  TipoActividad _parseTipo(String tipoStr) {
    final t = tipoStr.toLowerCase().trim();
    if (t.isEmpty) {
      return TipoActividad.tiempoLibre;
    }

    if (t.contains('hospedaje') ||
        t.contains('hotel') ||
        t.contains('dormir')) {
      return TipoActividad.hospedaje;
    }
    if (t.contains('comida') ||
        t.contains('restaurante') ||
        t.contains('desayuno') ||
        t.contains('cena')) {
      return TipoActividad.comida;
    }
    if (t.contains('traslado') ||
        t.contains('vuelo') ||
        t.contains('bus') ||
        t.contains('tren')) {
      return TipoActividad.traslado;
    }
    if (t.contains('cultura') ||
        t.contains('museo') ||
        t.contains('historia')) {
      return TipoActividad.cultura;
    }
    if (t.contains('aventura') ||
        t.contains('tour') ||
        t.contains('caminata')) {
      return TipoActividad.aventura;
    }

    return TipoActividad.tiempoLibre;
  }
}
