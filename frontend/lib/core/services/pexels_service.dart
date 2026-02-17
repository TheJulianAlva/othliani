import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class PexelsService {
  // API Key de Pexels desde variables de entorno
  static String get _apiKey => dotenv.env['PEXELS_API_KEY'] ?? '';

  Future<List<String>> buscarFotos(String query) async {
    if (query.trim().isEmpty) return [];

    try {
      final uri = Uri.parse(
        'https://api.pexels.com/v1/search?query=${Uri.encodeComponent(query)}&per_page=6&orientation=landscape&locale=es-ES',
      );

      final response = await http.get(uri, headers: {'Authorization': _apiKey});

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List<dynamic> photos = data['photos'];
        if (photos.isNotEmpty) {
          debugPrint(
            "📸 URL de Pexels encontrada: ${photos[0]['src']['medium']}",
          );
        }
        // Extraemos las URLs de tamaño 'medium' o 'large'
        return photos
            .map<String>((json) => json['src']['large2x'] as String)
            .toList();
      } else {
        debugPrint('Error Pexels: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      debugPrint('Error de conexión Pexels: $e');
      return [];
    }
  }
}
