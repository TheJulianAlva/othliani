import 'package:flutter/material.dart';
import '../../core/theme/app_constants.dart';

class ItineraryEventCard extends StatelessWidget {
  final String time;
  final String title;
  final String description;

  const ItineraryEventCard({
    super.key,
    required this.time,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      child: ListTile(
        leading: CircleAvatar(
          child: Text(time, style: const TextStyle(fontSize: 12)),
        ),
        title: Text(title),
        subtitle: Text(description),
        trailing: const Icon(Icons.location_on),
      ),
    );
  }
}
