import 'package:flutter/material.dart';
import 'package:frontend/core/theme/info_modal.dart';

class FolioScreen extends StatelessWidget {
  const FolioScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      //resizeToAvoidBottomInset: false, // El teclado no empuja el contenido
      backgroundColor: const Color(0xFFF2F2F2), // Gris muy claro de fondo
      body: SafeArea(
        child: Center(
          // Centra vertical y horizontalmente
          child: SingleChildScrollView(
            // Permite scroll si el contenido se queda detrás del teclado en pantallas pequeñas
            child: SizedBox(
              width: double.infinity,
              child: Card(
                elevation: 20,
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 50,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      const Text(
                        'Bienvenido a\nOtlhiani',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Coloque su folio de viaje',
                        style: TextStyle(fontSize: 14, color: Colors.black54),
                      ),
                      const SizedBox(height: 35),

                      // Campo de texto (solo frontend, sin validaciones)
                      const TextField(
                        decoration: InputDecoration(
                          hintText: 'XXXXX-XXXXXX-XXX',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 14,
                          ),
                        ),
                        textCapitalization: TextCapitalization.characters,
                      ),

                      const SizedBox(height: 35),

                      // Botón Ingresar
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            // Acción futura
                            print("Ventana de numero de telefono");
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF3F51B5),
                            foregroundColor: Colors.white,
                            minimumSize: const Size.fromHeight(44),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text('Ingresar'),
                        ),
                      ),

                      const SizedBox(height: 80),

                      // Enlace Privacidad
                      GestureDetector(
                        onTap: () {
                          // Acción futura

                          InfoModal.show(
                            context: context,
                            title: 'Aviso de Privacidad',
                            content: '''                                     
Este es el texto de ejemplo para el Aviso de Privacidad.
Incluye políticas de datos personales, finalidad del tratamiento,
mecanismos de acceso, rectificación y cancelación, etc.
Por favor, asegúrese de leer y comprender estos términos antes de continuar.
                                      ''',
                          );
                        },
                        child: Text(
                          'Privacidad',
                          style: TextStyle(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
