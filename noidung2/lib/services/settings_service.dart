import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/reading_settings.dart';

class SettingsService {
  static const String _settingsKey = 'reading_settings';

  // Lưu cài đặt
  Future<void> saveSettings(ReadingSettings settings) async {
    final prefs = await SharedPreferences.getInstance();
    final settingsMap = settings.toMap();
    await prefs.setString(_settingsKey, json.encode(settingsMap));
  }

  // Đọc cài đặt
  Future<ReadingSettings> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final String? settingsJson = prefs.getString(_settingsKey);
    
    if (settingsJson == null) {
      return ReadingSettings(); // Trả về cài đặt mặc định
    }
    
    try {
      final Map<String, dynamic> settingsMap = json.decode(settingsJson);
      return ReadingSettings.fromMap(settingsMap);
    } catch (e) {
      return ReadingSettings();
    }
  }

  // Xóa cài đặt
  Future<void> clearSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_settingsKey);
  }
}