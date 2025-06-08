import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  late SharedPreferences _prefs;
  bool _isInitialized = false;
  static const String _dataPrefix = 'puzzle_game_';

  Future<void> initialize() async {
    if (_isInitialized) return;

    _prefs = await SharedPreferences.getInstance();
    _isInitialized = true;
  }

  Future<bool> _saveData(String key, Map<String, dynamic> data) async {
    await _ensureInitialized();

    try {
      return await _saveToLocal(key, data);
    } catch (e) {
      debugPrint('Error saving data: $e');
      // TODO: log
      return false;
    }
  }

  Future<Map<String, dynamic>?> _loadData(String key) async {
    await _ensureInitialized();

    try {
      return await _loadFromLocal(key);
    } catch (e) {
      debugPrint('Error loading data from cloud: $e');
      // TODO: log
    }
    return null;
  }

  // Local storage method
  Future<bool> _saveToLocal(String key, Map<String, dynamic> data) async {
    try {
      final jsonData = json.encode(data);
      return await _prefs.setString('$_dataPrefix$key', jsonData);
    } catch (e) {
      debugPrint('Error saving to local storage: $e');
      return false;
    }
  }

  Future<Map<String, dynamic>?> _loadFromLocal(String key) async {
    try {
      final jsonData = _prefs.getString('$_dataPrefix$key');
      if (jsonData != null) {
        return json.decode(jsonData) as Map<String, dynamic>;
      }
    } catch (e) {
      debugPrint('Error loading from local storage: $e');
    }
    return null;
  }

  // Helper methods
  Future<void> _ensureInitialized() async {
    if (!_isInitialized) {
      await initialize();
    }
  }

  // Model implementation
  Future<int> getLevel() async {
    final data = await _loadData('level');
    if (data != null && data.containsKey('level')) {
      return data['level'] as int;
    }
    return 1; // Default level if not set
  }

  set level(int value) {
    _saveData('level', {'level': value});
  }
}
