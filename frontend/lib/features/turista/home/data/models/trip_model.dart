import 'package:frontend/features/turista/home/domain/entities/trip.dart';
import 'package:frontend/features/turista/home/data/models/activity_model.dart';

class TripModel extends Trip {
  const TripModel({
    required super.id,
    required super.title,
    required super.description,
    required super.activitiesByDay,
  });

  factory TripModel.fromJson(Map<String, dynamic> json) {
    final activitiesMap = <String, List<ActivityModel>>{};

    if (json['activitiesByDay'] != null) {
      (json['activitiesByDay'] as Map<String, dynamic>).forEach((key, value) {
        if (value is List) {
          activitiesMap[key] =
              value
                  .map((e) => ActivityModel.fromJson(e as Map<String, dynamic>))
                  .toList();
        }
      });
    }

    return TripModel(
      id: json['id'] ?? '',
      title: json['title'],
      description: json['description'],
      activitiesByDay: activitiesMap,
    );
  }

  Map<String, dynamic> toJson() {
    final activitiesJson = <String, dynamic>{};
    activitiesByDay.forEach((key, value) {
      activitiesJson[key] =
          value.map((e) => (e as ActivityModel).toJson()).toList();
    });

    return {
      'id': id,
      'title': title,
      'description': description,
      'activitiesByDay': activitiesJson,
    };
  }
}
