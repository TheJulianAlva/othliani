import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum FontSizeOption { small, medium, large, extraLarge }

class AccessibilityProvider extends ChangeNotifier {
  FontSizeOption _fontSize = FontSizeOption.medium;
  bool _highContrast = false;
  bool _screenReader = false;
  bool _reduceAnimations = false;
  bool _hapticFeedback = true;

  FontSizeOption get fontSize => _fontSize;
  bool get highContrast => _highContrast;
  bool get screenReader => _screenReader;
  bool get reduceAnimations => _reduceAnimations;
  bool get hapticFeedback => _hapticFeedback;

  double get fontScale {
    switch (_fontSize) {
      case FontSizeOption.small:
        return 0.85;
      case FontSizeOption.medium:
        return 1.0;
      case FontSizeOption.large:
        return 1.15;
      case FontSizeOption.extraLarge:
        return 1.3;
    }
  }

  AccessibilityProvider() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final fontSizeIndex = prefs.getInt('fontSize') ?? 1;
    _fontSize = FontSizeOption.values[fontSizeIndex];
    _highContrast = prefs.getBool('highContrast') ?? false;
    _screenReader = prefs.getBool('screenReader') ?? false;
    _reduceAnimations = prefs.getBool('reduceAnimations') ?? false;
    _hapticFeedback = prefs.getBool('hapticFeedback') ?? true;
    notifyListeners();
  }

  Future<void> setFontSize(FontSizeOption size) async {
    _fontSize = size;
    notifyListeners();
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('fontSize', size.index);
  }

  Future<void> setHighContrast(bool value) async {
    _highContrast = value;
    notifyListeners();
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('highContrast', value);
  }

  Future<void> setScreenReader(bool value) async {
    _screenReader = value;
    notifyListeners();
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('screenReader', value);
  }

  Future<void> setReduceAnimations(bool value) async {
    _reduceAnimations = value;
    notifyListeners();
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('reduceAnimations', value);
  }

  Future<void> setHapticFeedback(bool value) async {
    _hapticFeedback = value;
    notifyListeners();
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hapticFeedback', value);
  }
}
