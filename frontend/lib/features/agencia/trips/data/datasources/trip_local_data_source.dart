import 'dart:convert';
import 'package:flutter/foundation.dart'; // Para compute()
import 'package:shared_preferences/shared_preferences.dart';
import '../models/trip_draft_model.dart';
import '../../domain/entities/categoria_actividad.dart';

const String kTripDraft = 'current_trip_draft';
const String kCustomCategories = 'custom_activity_categories';

// ─── Top-level functions (requeridas por compute / Isolates) ─────────────────

/// Serializa el mapa a JSON en un hilo secundario
String _encodeDraft(Map<String, dynamic> map) => jsonEncode(map);

/// Deserializa el JSON a mapa en un hilo secundario
Map<String, dynamic> _decodeDraft(String json) =>
    jsonDecode(json) as Map<String, dynamic>;

// ─────────────────────────────────────────────────────────────────────────────

class TripLocalDataSource {
  /// Guarda el borrador actual usando compute() para no bloquear el hilo principal
  Future<void> saveDraft(TripDraftModel draft) async {
    final prefs = await SharedPreferences.getInstance();

    // Serialización en hilo secundario → nunca congela la UI
    final String jsonString = await compute(_encodeDraft, draft.toJson());

    await prefs.setString(kTripDraft, jsonString);
  }

  /// Recupera el borrador si existe, deserializando en hilo secundario
  Future<TripDraftModel?> getDraft() async {
    final prefs = await SharedPreferences.getInstance();
    final String? jsonString = prefs.getString(kTripDraft);

    if (jsonString == null) return null;

    try {
      final map = await compute(_decodeDraft, jsonString);
      return TripDraftModel.fromJson(map);
    } catch (_) {
      // Datos corruptos o de versión vieja → limpiamos
      await clearDraft();
      return null;
    }
  }

  /// Borra el borrador (cuando el viaje se guarda exitosamente)
  Future<void> clearDraft() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(kTripDraft);
  }

  // ─── Categorías Personalizadas de la Agencia ────────────────────────────

  /// Guarda las categorías personalizadas (se mantienen entre viajes)
  Future<void> saveCustomCategories(List<CategoriaActividad> categorias) async {
    final prefs = await SharedPreferences.getInstance();
    final soloPersonalizadas = categorias.where((c) => c.esPersonalizada);
    final list = soloPersonalizadas.map((c) => c.toJson()).toList();
    await prefs.setString(kCustomCategories, jsonEncode(list));
  }

  /// Recupera las categorías personalizadas guardadas
  Future<List<CategoriaActividad>> getCustomCategories() async {
    final prefs = await SharedPreferences.getInstance();
    final String? json = prefs.getString(kCustomCategories);
    if (json == null) return [];
    try {
      final list = jsonDecode(json) as List<dynamic>;
      return list
          .map((e) => CategoriaActividad.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }
}
