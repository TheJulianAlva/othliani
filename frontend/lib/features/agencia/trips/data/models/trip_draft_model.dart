import '../../domain/entities/actividad_itinerario.dart';

class TripDraftModel {
  // Datos Paso 1
  final String? destino;
  final String? fechaInicio; // ISO String
  final String? fechaFin;
  final String? guiaId;
  final String? fotoPortadaUrl; // 📸 Persistencia de foto elegida
  final double? lat;
  final double? lng;

  // Datos Paso 2 (Itinerario)
  final List<ActividadItinerario> actividades;

  TripDraftModel({
    this.destino,
    this.fechaInicio,
    this.fechaFin,
    this.guiaId,
    this.fotoPortadaUrl,
    this.lat,
    this.lng,
    this.actividades = const [],
  });

  Map<String, dynamic> toJson() => {
    'destino': destino,
    'fechaInicio': fechaInicio,
    'fechaFin': fechaFin,
    'guiaId': guiaId,
    'fotoPortadaUrl': fotoPortadaUrl,
    'lat': lat,
    'lng': lng,
    'actividades': actividades.map((x) => x.toJson()).toList(),
  };

  factory TripDraftModel.fromJson(Map<String, dynamic> json) => TripDraftModel(
    destino: json['destino'],
    fechaInicio: json['fechaInicio'],
    fechaFin: json['fechaFin'],
    guiaId: json['guiaId'],
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
