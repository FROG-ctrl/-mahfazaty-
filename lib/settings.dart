import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// These keys are separate from all wallet/transaction persistence keys.
class AppSettings extends ChangeNotifier {
  AppSettings();
  static final instance = AppSettings();
  String themeId = 'green';
  String language = 'ar';
  String profileName = '';
  bool get isEnglish => language == 'en';
  static const themeIds = [
    'green',
    'blue',
    'orange',
    'purple',
    'white',
    'black',
  ];
  Future<void> load() async {
    final p = await SharedPreferences.getInstance();
    final saved = p.getString('appearance.theme');
    themeId = themeIds.contains(saved) ? saved! : 'green';
    language = p.getString('appearance.language') == 'en' ? 'en' : 'ar';
    profileName = p.getString('profile.localName') ?? '';
    notifyListeners();
  }

  Future<void> setTheme(String value) async {
    if (!themeIds.contains(value)) return;
    final p = await SharedPreferences.getInstance();
    await p.setString('appearance.theme', value);
    themeId = value;
    notifyListeners();
  }

  Future<void> setLanguage(String value) async {
    if (value != 'ar' && value != 'en') return;
    final p = await SharedPreferences.getInstance();
    await p.setString('appearance.language', value);
    language = value;
    notifyListeners();
  }

  Future<void> setProfileName(String value) async {
    final p = await SharedPreferences.getInstance();
    await p.setString('profile.localName', value.trim());
    profileName = value.trim();
    notifyListeners();
  }
}
