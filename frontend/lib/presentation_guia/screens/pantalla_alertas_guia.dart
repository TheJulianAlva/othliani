import 'package:flutter/material.dart';

class AlertsScreenGuia extends StatefulWidget {
  const AlertsScreenGuia({super.key});

  @override
  State<AlertsScreenGuia> createState() => _AlertsScreenGuiaState();
}

class _AlertsScreenGuiaState extends State<AlertsScreenGuia> {
  // Mock alerts data
  final List<Map<String, dynamic>> _alerts = [
    {
      'id': '1',
      'title': 'Punto de reunión cambiado',
      'message': 'Nos vemos en la entrada principal a las 2:00 PM.',
      'severity': 'info',
      'time': '10:30 AM',
    },
    {
      'id': '2',
      'title': 'Retraso por tráfico',
      'message': 'Llegaremos 15 minutos tarde al restaurante.',
      'severity': 'warning',
      'time': '12:45 PM',
    },
  ];

  void _showCreateAlertDialog() {
    final titleController = TextEditingController();
    final messageController = TextEditingController();
    String severity = 'info';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Crear Nueva Alerta'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Título'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: messageController,
                decoration: const InputDecoration(labelText: 'Mensaje'),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: severity,
                decoration: const InputDecoration(labelText: 'Tipo de Alerta'),
                items: const [
                  DropdownMenuItem(value: 'info', child: Text('Información')),
                  DropdownMenuItem(value: 'warning', child: Text('Advertencia')),
                  DropdownMenuItem(value: 'urgent', child: Text('Urgente')),
                ],
                onChanged: (value) {
                  setState(() => severity = value!);
                },
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
                if (titleController.text.isNotEmpty && messageController.text.isNotEmpty) {
                  // Add to list (mock)
                  this.setState(() {
                    _alerts.insert(0, {
                      'id': DateTime.now().toString(),
                      'title': titleController.text,
                      'message': messageController.text,
                      'severity': severity,
                      'time': 'Ahora',
                    });
                  });
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Alerta enviada a todos los turistas')),
                  );
                }
              },
              child: const Text('Enviar'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Alertas'),
      ),
      body: _alerts.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications_none, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  const Text('No hay alertas activas'),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _alerts.length,
              itemBuilder: (context, index) {
                final alert = _alerts[index];
                Color color;
                IconData icon;

                switch (alert['severity']) {
                  case 'warning':
                    color = Colors.orange;
                    icon = Icons.warning_amber;
                    break;
                  case 'urgent':
                    color = Colors.red;
                    icon = Icons.report_problem;
                    break;
                  case 'info':
                  default:
                    color = Colors.blue;
                    icon = Icons.info_outline;
                    break;
                }

                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: color.withValues(alpha: 0.1),
                      child: Icon(icon, color: color),
                    ),
                    title: Text(
                      alert['title'],
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(alert['message']),
                        const SizedBox(height: 8),
                        Text(
                          alert['time'],
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                    isThreeLine: true,
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline),
                      onPressed: () {
                        setState(() {
                          _alerts.removeAt(index);
                        });
                      },
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreateAlertDialog,
        icon: const Icon(Icons.add_alert),
        label: const Text('Crear Alerta'),
      ),
    );
  }
}
