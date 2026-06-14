import 'package:hive_flutter/hive_flutter.dart';
import 'dart:convert';

class LocalStorageService {
  static final LocalStorageService _instance = LocalStorageService._internal();
  factory LocalStorageService() => _instance;
  LocalStorageService._internal();

  final Box _cacheBox = Hive.box('app_cache');

  // Save any JSON-compatible data with optional userId prefix for privacy
  Future<void> saveData(String key, dynamic data, {String? userId}) async {
    if (data == null) return;
    String finalKey = userId != null ? '${userId}_$key' : key;
    String jsonString = jsonEncode(data);
    await _cacheBox.put(finalKey, jsonString);
  }

  // Load data with optional userId prefix
  dynamic getData(String key, {String? userId}) {
    String finalKey = userId != null ? '${userId}_$key' : key;
    String? jsonString = _cacheBox.get(finalKey);
    if (jsonString == null) return null;
    try {
      return jsonDecode(jsonString);
    } catch (e) {
      return null;
    }
  }

  // Helper to save a list of maps
  Future<void> saveList(String key, List<Map<String, dynamic>> list, {String? userId}) async {
    await saveData(key, list, userId: userId);
  }

  // Helper to load a list of maps
  List<Map<String, dynamic>> getList(String key, {String? userId}) {
    final data = getData(key, userId: userId);
    if (data != null && data is List) {
      return List<Map<String, dynamic>>.from(data.map((e) => Map<String, dynamic>.from(e)));
    }
    return [];
  }

  // Clear specific key
  Future<void> clearData(String key, {String? userId}) async {
    String finalKey = userId != null ? '${userId}_$key' : key;
    await _cacheBox.delete(finalKey);
  }

  // Clear all cache
  Future<void> clearAll() async {
    await _cacheBox.clear();
  }
}
