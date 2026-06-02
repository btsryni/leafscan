import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/detection_result.dart';

/// Singleton service to manage local coffee leaf diagnosis history using SharedPreferences.
class HistoryService {
  static final HistoryService _instance = HistoryService._internal();
  factory HistoryService() => _instance;
  HistoryService._internal();

  static const String _storageKey = 'leafscan_history_cache';
  static const String _initializedKey = 'leafscan_history_initialized';

  /// Pre-seeds mockup history items on first-ever launch (no items pre-seeded to prevent hardcoded feel on clean installations).
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final isInitialized = prefs.getBool(_initializedKey) ?? false;

    if (!isInitialized) {
      await prefs.setBool(_initializedKey, true);
    }
  }

  /// Fetches all stored history results.
  Future<List<DetectionResult>> getHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_storageKey);
    if (jsonString == null) return [];

    try {
      final list = json.decode(jsonString) as List<dynamic>;
      return list.map((item) => DetectionResult.fromJson(item as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }

  /// Overwrites the full history cache.
  Future<void> saveHistory(List<DetectionResult> list) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = json.encode(list.map((item) => item.toJson()).toList());
    await prefs.setString(_storageKey, jsonString);
  }

  /// Adds a single new scan result to the top of the history list.
  Future<void> addResult(DetectionResult result) async {
    final list = await getHistory();
    list.insert(0, result);
    await saveHistory(list);
  }

  /// Purges a single entry by its unique ID.
  Future<void> deleteResult(String id) async {
    final list = await getHistory();
    list.removeWhere((item) => item.id == id);
    await saveHistory(list);
  }

  /// Completely empties the history storage database.
  Future<void> clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_storageKey);
  }
}
