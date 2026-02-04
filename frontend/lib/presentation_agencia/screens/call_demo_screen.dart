import 'package:flutter/material.dart';
import '../widgets/connected_call_dialog.dart';

class CallDemoScreen extends StatelessWidget {
  const CallDemoScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Demo de Llamada VoIP'),
        backgroundColor: const Color(0xFF1a237e),
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFF1a237e),
              const Color(0xFF0d47a1).withOpacity(0.8),
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.phone_in_talk, size: 80, color: Colors.white),
              const SizedBox(height: 24),
              const Text(
                'Pantalla de Llamada Conectada',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 40),
                child: Text(
                  'Presiona el botón para ver la pantalla de llamada con estado de carga y conexión',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                ),
              ),
              const SizedBox(height: 48),
              ElevatedButton.icon(
                onPressed: () {
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder:
                        (context) => const ConnectedCallDialog(
                          tripId: '204',
                          guideName: 'Juan Pérez',
                        ),
                  );
                },
                icon: const Icon(Icons.call, size: 24),
                label: const Text(
                  'Iniciar Llamada Demo',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4CAF50),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 8,
                  shadowColor: const Color(0xFF4CAF50).withOpacity(0.5),
                ),
              ),
              const SizedBox(height: 24),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 40),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: Colors.white70,
                          size: 20,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Características:',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _buildFeatureItem('Estado de carga con animación'),
                    _buildFeatureItem(
                      'Transición automática a llamada conectada',
                    ),
                    _buildFeatureItem('Contador de duración en tiempo real'),
                    _buildFeatureItem('Controles de micrófono y altavoz'),
                    _buildFeatureItem('Animación de pulso en el avatar'),
                    _buildFeatureItem('Diseño moderno con gradientes'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          const Icon(Icons.check_circle, color: Color(0xFF4CAF50), size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(color: Colors.white70, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}
