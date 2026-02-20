import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/trip_draft_model.dart';

const String kTripDraft = 'current_trip_draft';

class TripLocalDataSource {
  /// Guarda el estado actual (Sobrescribe lo anterior)
  Future<void> saveDraft(TripDraftModel draft) async {
    final prefs = await SharedPreferences.getInstance();
    final String jsonString = jsonEncode(draft.toJson());
    await prefs.setString(kTripDraft, jsonString);
    // print("💾 Autoguardado completado");
  }

  /// Recupera el borrador si existe
  Future<TripDraftModel?> getDraft() async {
    final prefs = await SharedPreferences.getInstance();
    final String? jsonString = prefs.getString(kTripDraft);

    if (jsonString != null) {
      try {
        return TripDraftModel.fromJson(jsonDecode(jsonString));
      } catch (e) {
        // Si hay error al parsear (versiones viejas, datos corruptos), limpiamos
        await clearDraft();
        return null;
      }
    }
    return null;
  }

  /// Borra el borrador (cuando se guarda exitosamente el viaje real)
  Future<void> clearDraft() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(kTripDraft);
  }
}
