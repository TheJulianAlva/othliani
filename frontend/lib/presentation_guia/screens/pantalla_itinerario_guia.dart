import 'package:flutter/material.dart';
import 'package:frontend/presentation_turista/widgets/itinerary_event_card.dart';

class ItineraryScreenGuia extends StatefulWidget {
  const ItineraryScreenGuia({super.key});

  @override
  State<ItineraryScreenGuia> createState() => _ItineraryScreenGuiaState();
}

class _ItineraryScreenGuiaState extends State<ItineraryScreenGuia> {
  // Mock itinerary data
  final List<Map<String, String>> _events = [
    {
      'time': '09:00',
      'title': 'Desayuno Grupal',
      'description': 'Buffet en el hotel principal.',
    },
    {
      'time': '10:30',
      'title': 'Salida al Museo',
      'description': 'Reunión en el lobby para abordar el autobús.',
    },
    {
      'time': '13:00',
      'title': 'Comida Libre',
      'description': 'Tiempo libre para comer en el centro de la ciudad.',
    },
  ];

  void _showEditEventDialog({int? index}) {
    final isEditing = index != null;
    final timeController = TextEditingController(text: isEditing ? _events[index]['time'] : '');
    final titleController = TextEditingController(text: isEditing ? _events[index]['title'] : '');
    final descController = TextEditingController(text: isEditing ? _events[index]['description'] : '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isEditing ? 'Editar Evento' : 'Nuevo Evento'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: timeController,
                decoration: const InputDecoration(labelText: 'Hora (HH:MM)', hintText: '09:00'),
                keyboardType: TextInputType.datetime,
              ),
              const SizedBox(height: 8),
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Título'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: descController,
                decoration: const InputDecoration(labelText: 'Descripción'),
                maxLines: 3,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          if (isEditing)
            TextButton(
              onPressed: () {
                setState(() {
                  _events.removeAt(index);
                });
                Navigator.pop(context);
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Eliminar'),
            ),
          ElevatedButton(
            onPressed: () {
              if (timeController.text.isNotEmpty && titleController.text.isNotEmpty) {
                setState(() {
                  final newEvent = {
                    'time': timeController.text,
                    'title': titleController.text,
                    'description': descController.text,
                  };
                  if (isEditing) {
                    _events[index] = newEvent;
                  } else {
                    _events.add(newEvent);
                    _events.sort((a, b) => a['time']!.compareTo(b['time']!));
                  }
                });
                Navigator.pop(context);
              }
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestionar Itinerario'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _events.length,
        itemBuilder: (context, index) {
          final event = _events[index];
          return GestureDetector(
            onTap: () => _showEditEventDialog(index: index),
            child: Stack(
              children: [
                ItineraryEventCard(
                  time: event['time']!,
                  title: event['title']!,
                  description: event['description']!,
                ),
                const Positioned(
                  top: 8,
                  right: 8,
                  child: Icon(Icons.edit, size: 16, color: Colors.grey),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showEditEventDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
