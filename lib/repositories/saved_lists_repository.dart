import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/list_score.dart';

/// Repository for managing saved army lists with persistence
class SavedListsRepository {
  static const String _savedListsKey = 'saved_lists';

  /// Save a list with its scores
  Future<void> saveList(String id, ListScore listScore) async {
    final prefs = await SharedPreferences.getInstance();
    
    // Get existing saved lists
    final savedLists = await getAllSavedLists();
    
    // Add or update this list
    savedLists[id] = listScore.toJson();
    
    // Save back to preferences
    await prefs.setString(_savedListsKey, jsonEncode(savedLists));
  }

  /// Load a specific list by ID
  Future<ListScore?> loadList(String id) async {
    final savedLists = await getAllSavedLists();
    final listJson = savedLists[id];
    
    if (listJson == null) return null;
    
    return ListScore.fromJson(listJson);
  }

  /// Get all saved lists as a map of ID -> ListScore JSON
  Future<Map<String, dynamic>> getAllSavedLists() async {
    final prefs = await SharedPreferences.getInstance();
    final savedListsString = prefs.getString(_savedListsKey);
    
    if (savedListsString == null) return {};
    
    return Map<String, dynamic>.from(jsonDecode(savedListsString));
  }

  /// Get metadata for all saved lists (without full regiment data)
  Future<List<SavedListMetadata>> getListMetadata() async {
    final savedLists = await getAllSavedLists();
    
    return savedLists.entries.map((entry) {
      final listData = entry.value as Map<String, dynamic>;
      final armyListData = listData['armyList'] as Map<String, dynamic>;
      
      return SavedListMetadata(
        id: entry.key,
        name: armyListData['name'] as String,
        faction: armyListData['faction'] as String,
        totalPoints: armyListData['totalPoints'] as int,
        pointsLimit: armyListData['pointsLimit'] as int,
        savedAt: DateTime.parse(listData['calculatedAt'] as String),
      );
    }).toList()
      ..sort((a, b) => b.savedAt.compareTo(a.savedAt)); // Most recent first
  }

  /// Delete a saved list
  Future<void> deleteList(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final savedLists = await getAllSavedLists();
    
    savedLists.remove(id);
    
    await prefs.setString(_savedListsKey, jsonEncode(savedLists));
  }

  /// Clear all saved lists
  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_savedListsKey);
  }

  /// Generate a unique ID for a list (timestamp-based)
  String generateId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }
}

/// Metadata for a saved list (lightweight representation)
class SavedListMetadata {
  final String id;
  final String name;
  final String faction;
  final int totalPoints;
  final int pointsLimit;
  final DateTime savedAt;

  const SavedListMetadata({
    required this.id,
    required this.name,
    required this.faction,
    required this.totalPoints,
    required this.pointsLimit,
    required this.savedAt,
  });
}
