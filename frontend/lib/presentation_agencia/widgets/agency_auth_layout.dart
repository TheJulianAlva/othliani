import 'package:flutter/material.dart';

class AgencyAuthLayout extends StatelessWidget {
  final Widget child;

  const AgencyAuthLayout({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth > 800) {
          return Scaffold(
            body: Row(
              children: [
                // Left Column (Brand)
                Expanded(
                  flex: 1, // 50%
                  child: _buildBrandSection(context, isMobile: false),
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
        } else {
          // Mobile/Tablet: Single Scroll View
          return Scaffold(
            body: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(
                    height: 250,
                    width: double.infinity,
                    child: _buildBrandSection(context, isMobile: true),
                  ),
                  Container(
                    color: Colors.white,
                    padding: const EdgeInsets.all(24.0),
                    alignment: Alignment.center,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 450),
                      child: child,
                    ),
                  ),
                ],
              ),
            ),
          );
        }
      },
    );
  }

  Widget _buildBrandSection(BuildContext context, {required bool isMobile}) {
    return Container(
      color: const Color(0xFF0F4C75),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Container(
            color: const Color(0xFF0F4C75).withValues(alpha: 0.9), // Overlay
          ),
          Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(isMobile ? 24.0 : 48.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.business,
                      size: isMobile ? 40 : 60,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      '"Transformando el\nriesgo en confianza\noperativa."',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: isMobile ? 24 : 32,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Serif',
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Gestión logística y seguridad centralizada.',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: isMobile ? 14 : 18,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
