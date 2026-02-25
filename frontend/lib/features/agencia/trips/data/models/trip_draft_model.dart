import '../../domain/entities/actividad_itinerario.dart';

class TripDraftModel {
  // Datos Paso 1
  final String? destino;
  final String? fechaInicio; // ISO String
  final String? fechaFin;
  final String? horaInicio; // "HH:mm"
  final String? horaFin; // "HH:mm"
  final bool isMultiDay;
  final String? guiaId;
  final List<String> coGuiasIds; // Guías auxiliares
  final String? fotoPortadaUrl; // 📸 Persistencia de foto elegida
  final double? lat;
  final double? lng;

  // Datos Paso 2 (Itinerario)
  final List<ActividadItinerario> actividades;

  TripDraftModel({
    this.destino,
    this.fechaInicio,
    this.fechaFin,
    this.horaInicio,
    this.horaFin,
    this.isMultiDay = false,
    this.guiaId,
    this.coGuiasIds = const [],
    this.fotoPortadaUrl,
    this.lat,
    this.lng,
    this.actividades = const [],
  });

  Map<String, dynamic> toJson() => {
    'destino': destino,
    'fechaInicio': fechaInicio,
    'fechaFin': fechaFin,
    'horaInicio': horaInicio,
    'horaFin': horaFin,
    'isMultiDay': isMultiDay,
    'guiaId': guiaId,
    'coGuiasIds': coGuiasIds,
    'fotoPortadaUrl': fotoPortadaUrl,
    'lat': lat,
    'lng': lng,
    'actividades': actividades.map((x) => x.toJson()).toList(),
  };

  factory TripDraftModel.fromJson(Map<String, dynamic> json) => TripDraftModel(
    destino: json['destino'],
    fechaInicio: json['fechaInicio'],
    fechaFin: json['fechaFin'],
    horaInicio: json['horaInicio'],
    horaFin: json['horaFin'],
    isMultiDay: json['isMultiDay'] as bool? ?? false,
    guiaId: json['guiaId'],
    coGuiasIds:
        json['coGuiasIds'] != null
            ? List<String>.from(json['coGuiasIds'] as List)
            : [],
    fotoPortadaUrl: json['fotoPortadaUrl'],
    lat: json['lat'],
    lng: json['lng'],
    actividades:
        json['actividades'] != null
            ? (json['actividades'] as List)
                .map((i) => ActividadItinerario.fromJson(i))
                .toList()
            : [],
  );
}
