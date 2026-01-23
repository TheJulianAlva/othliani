import 'package:flutter/material.dart';

class AgencyAuthLayout extends StatelessWidget {
  final Widget child;

  const AgencyAuthLayout({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          // Left Column (Brand)
          Expanded(
            flex: 1, // 50%
            child: Container(
              color: const Color(0xFF0F4C75), // Brand Overlay Color (Fallback)
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Placeholder for Background Image
                  // Image.asset('assets/images/auth_bg.jpg', fit: BoxFit.cover),
                  Container(
                    color: const Color(
                      0xFF0F4C75,
                    ).withValues(alpha: 0.9), // Overlay
                  ),

                  // Quote / Mission
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(48.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Icon(Icons.business, size: 60, color: Colors.white),
                          SizedBox(height: 24),
                          Text(
                            '"Transformando el\nriesgo en confianza\noperativa."',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Serif', // Or specific font
                              height: 1.2,
                            ),
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Gestión logística y seguridad centralizada.',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Right Column (Form)
          Expanded(
            flex: 1, // 50%
            child: Container(
              color: Colors.white,
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(48.0),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 450),
                    child: child,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
