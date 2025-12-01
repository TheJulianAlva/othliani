import 'package:flutter/material.dart';
import '../widgets/walkie_talkie_button.dart';

class ConfigScreen extends StatelessWidget {
  const ConfigScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Configuración')),
      body: Stack(
        children: [
          ListView(
            children: [
              ListTile(
                leading: const Icon(Icons.language),
                title: const Text('Idioma'),
                subtitle: const Text('Español'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Cambiar idioma próximamente'),
                    ),
                  );
                },
              ),
              const Divider(),
              SwitchListTile(
                secondary: const Icon(Icons.dark_mode),
                title: const Text('Modo Oscuro'),
                value: false,
                onChanged: (bool value) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Cambiar tema próximamente')),
                  );
                },
              ),
              const Divider(),
              SwitchListTile(
                secondary: const Icon(Icons.notifications),
                title: const Text('Notificaciones'),
                value: true,
                onChanged: (bool value) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Configurar notificaciones próximamente'),
                    ),
                  );
                },
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.accessibility),
                title: const Text('Accesibilidad'),
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Accesibilidad próximamente')),
                  );
                },
              ),
            ],
          ),
          const WalkieTalkieButton(),
        ],
      ),
    );
  }
}
