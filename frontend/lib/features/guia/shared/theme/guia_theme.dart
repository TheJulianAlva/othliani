import 'package:flutter/material.dart';

class GuiaColors {
  // Paleta principal para Guía B2C y B2B
  static const Color primary = Color(0xFF1A237E); // Azul corporativo / Verde de gestión
  static const Color secondary = Color(0xFF3D5AF1); 
  static const Color lightBackground = Color(0xFFE8EEFF);
  
  // Fondos generales
  static const Color background = Color(0xFFF0F3FF); // Fondo de Scaffold general
  static const Color backgroundAlternative = Color(0xFFF8F9FA); // Fondo gris muy claro
  
  // Colores de estado
  static const Color statusOk = Color(0xFF1B5E20);
  static const Color statusOkBg = Color(0xFFE8F5E9);
  
  static const Color statusOffline = Color(0xFF616161);
  static const Color statusOfflineBg = Color(0xFFF5F5F5);
  
  static const Color statusAlert = Color(0xFFB71C1C);
  static const Color statusAlertBg = Color(0xFFFFEBEE);

  static const Color statusWarning = Color(0xFFFF6D00);
  static const Color statusWarningBg = Color(0xFFFFF3E0);
}

class GuiaTextStyles {
  // AppBar Styles
  static const TextStyle appBarTitle = TextStyle(
    color: Colors.white,
    fontWeight: FontWeight.w700,
    fontSize: 18,
  );
  
  static const TextStyle appBarSubtitle = TextStyle(
    color: Colors.white,
    fontWeight: FontWeight.w500,
    fontSize: 13,
  );
  
  static const TextStyle appBarSmallLabel = TextStyle(
    color: Colors.white,
    fontWeight: FontWeight.w700,
    fontSize: 13,
  );

  // General App Styles
  static const TextStyle sectionTitle = TextStyle(
    fontWeight: FontWeight.w800,
    fontSize: 14,
    color: Color(0xFF1A1A2E),
    letterSpacing: 0.2,
  );
  
  static const TextStyle body = TextStyle(
    fontSize: 13,
    color: Colors.black87,
  );
}
