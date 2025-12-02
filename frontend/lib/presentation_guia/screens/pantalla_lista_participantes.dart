import 'package:flutter/material.dart';

class ParticipantsScreenGuia extends StatefulWidget {
  const ParticipantsScreenGuia({super.key});

  @override
  State<ParticipantsScreenGuia> createState() => _ParticipantsScreenGuiaState();
}

class _ParticipantsScreenGuiaState extends State<ParticipantsScreenGuia> {
  // Mock participants data
  final List<Map<String, String>> _participants = [
    {'name': 'Juan Morales', 'email': 'juan@example.com', 'status': 'Confirmado'},
    {'name': 'Maria Lopez', 'email': 'maria@example.com', 'status': 'Confirmado'},
    {'name': 'Pedro Sanchez', 'email': 'pedro@example.com', 'status': 'Pendiente'},
  ];

  void _showAddParticipantDialog() {
    final emailController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Agregar Participante'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Ingresa el correo electrónico del turista para enviarle una invitación.'),
            const SizedBox(height: 16),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'Correo Electrónico'),
              keyboardType: TextInputType.emailAddress,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              if (emailController.text.isNotEmpty) {
                setState(() {
                  _participants.add({
                    'name': 'Invitado',
                    'email': emailController.text,
                    'status': 'Invitado',
                  });
                });
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Invitación enviada a ${emailController.text}')),
                );
              }
            },
            child: const Text('Enviar Invitación'),
          ),
        ],
      ),
    );
  }

  void _confirmRemoveParticipant(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Participante'),
        content: Text('¿Estás seguro de que quieres eliminar a ${_participants[index]['name']} del viaje?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _participants.removeAt(index);
              });
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Participantes'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _participants.length,
        itemBuilder: (context, index) {
          final participant = _participants[index];
          return Card(
            child: ListTile(
              leading: CircleAvatar(
                child: Text(participant['name']![0]),
              ),
              title: Text(participant['name']!),
              subtitle: Text(participant['email']!),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: participant['status'] == 'Confirmado'
                          ? Colors.green.withValues(alpha: 0.1)
                          : Colors.orange.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      participant['status']!,
                      style: TextStyle(
                        fontSize: 12,
                        color: participant['status'] == 'Confirmado'
                            ? Colors.green
                            : Colors.orange,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.more_vert),
                    onPressed: () => _confirmRemoveParticipant(index),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddParticipantDialog,
        icon: const Icon(Icons.person_add),
        label: const Text('Invitar'),
      ),
    );
  }
}
