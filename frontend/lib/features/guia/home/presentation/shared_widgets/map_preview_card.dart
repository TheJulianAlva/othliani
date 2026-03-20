import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:frontend/core/navigation/routes_guia.dart';

/// Tarjeta de acceso rápido al mapa — compartida entre el layout B2B y B2C.
class MapPreviewCard extends StatelessWidget {
  final String locationLabel;

  const MapPreviewCard({
    super.key,
    this.locationLabel = 'Ver ubicación en tiempo real',
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push(RoutesGuia.map),
      child: Container(
        height: 85,
        decoration: BoxDecoration(
          color: const Color(0xFF2C3E50),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(20),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
            // Nueva sombra difuminada para efecto Neumórfico/Glassmórfico de "flote"
            BoxShadow(
              color: const Color(0xFF3D5AF1).withAlpha(40),
              blurRadius: 20,
              spreadRadius: -5,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Textura fotorrealista de mapa estático
            ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Opacity(
                opacity: 0.40, // 20% como sugirió la recomendación
                child: Image.network(
                  'https://images.unsplash.com/photo-1524661135-423995f22d0b?q=80&w=1000&auto=format&fit=crop', // Imagen de mapa genérica de alta calidad
                  width: double.infinity,
                  height: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            // Capa oscura azulada (overlay)
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF1A237E).withAlpha(210), // ~0.82 opacity
                    const Color(0xFF3D5AF1).withAlpha(180), // ~0.70 opacity
                  ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
              ),
            ),
            // Contenido
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                children: [
                  const Icon(Icons.map_rounded, color: Colors.white, size: 36),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Mapa en vivo',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          locationLabel,
                          style: TextStyle(
                            color: Colors.white.withAlpha(200),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.white,
                    size: 16,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
