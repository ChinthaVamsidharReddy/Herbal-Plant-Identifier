import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import '../services/language_service.dart';
class LanguageService extends ChangeNotifier {
  String _currentLanguage = "en";

  String get currentLanguage => _currentLanguage;

  Future<void> loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    _currentLanguage = prefs.getString("language") ?? "en";
    notifyListeners();
  }

  Future<void> changeLanguage(String lang) async {
    _currentLanguage = lang;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("language", lang);
    notifyListeners();
  }
}