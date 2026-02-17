import 'package:frontend/features/turista/home/domain/entities/activity.dart';

class ActivityModel extends Activity {
  const ActivityModel({
    required super.id,
    required super.title,
    required super.description,
    required super.time,
    required super.status,
  });

  factory ActivityModel.fromJson(Map<String, dynamic> json) {
    return ActivityModel(
      id: json['id'] ?? '',
      title: json['title'],
      description: json['description'],
      time: json['time'],
      status: _statusFromString(json['status']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'time': time,
      'status': _statusToString(status),
    };
  }

  static ActivityStatus _statusFromString(String status) {
    switch (status) {
      case 'terminada':
        return ActivityStatus.finished;
      case 'en_curso':
        return ActivityStatus.inProgress;
      default:
        return ActivityStatus.pending;
    }
  }

  static String _statusToString(ActivityStatus status) {
    switch (status) {
      case ActivityStatus.finished:
        return 'terminada';
      case ActivityStatus.inProgress:
        return 'en_curso';
      case ActivityStatus.pending:
        return 'pendiente';
    }
  }
}
