import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/unit.dart';
import 'unit_database_interface.dart';

/// Service for loading and managing unit data from multiple factions
class UnitDatabase implements UnitDatabaseInterface {
  static UnitDatabase? _instance;
  static UnitDatabase get instance => _instance ??= UnitDatabase._();
  UnitDatabase._();

  final Map<String, List<Unit>> _factionUnits = {};
  bool _isLoaded = false;

  /// List of all available faction files
  /// Add new faction filenames here when new factions are added
  static const List<String> _availableFactions = [
    'nords',
    'sorcererKings',
    'wadrhun',
    'dweghom',
    'oldDominion',
    'cityStates',
    'spires',
    'hundredKingdoms',
    'wHorrors',
  ];

  @override
  Future<void> loadData() async {
    if (_isLoaded) return;

    // Load all available faction data files
    for (final faction in _availableFactions) {
      try {
        await _loadFactionData(faction);
      } catch (e) {
        print('Warning: Could not load faction data for $faction: $e');
        // Continue loading other factions even if one fails
      }
    }

    _isLoaded = true;
    print(
        'Unit database loaded with ${_factionUnits.length} factions and ${_getTotalUnits()} total units');
  }

  /// Load data for a specific faction
  Future<void> _loadFactionData(String faction) async {
    try {
      final String jsonString =
          await rootBundle.loadString('assets/data/$faction.json');
      final List<dynamic> jsonList = json.decode(jsonString);
      final units = jsonList.map((json) => Unit.fromJson(json)).toList();

      _factionUnits[faction.toLowerCase()] = units;
      print('Loaded ${units.length} units for faction: $faction');
    } catch (e) {
      print('Error loading faction data for $faction: $e');
      throw Exception('Failed to load $faction data: $e');
    }
  }

  @override
  Unit? findUnit(String unitName) {
    final normalizedName = unitName.trim().toLowerCase();

    // Search through all loaded factions
    for (final factionName in _factionUnits.keys) {
      final units = _factionUnits[factionName]!;
      for (final unit in units) {
        if (unit.name.toLowerCase() == normalizedName) {
          print('Found unit "$unitName" in faction: $factionName');
          return unit;
        }
      }
    }

    print('Unit not found in any faction: "$unitName"');
    return null;
  }

  @override
  List<Unit> getUnitsForFaction(String faction) {
    return _factionUnits[faction.toLowerCase()] ?? [];
  }

  @override
  List<String> get availableFactions => _factionUnits.keys.toList();

  @override
  bool get isLoaded => _isLoaded;

  /// Get total number of units across all factions
  int _getTotalUnits() {
    return _factionUnits.values.fold(0, (total, units) => total + units.length);
  }

  /// Get detailed loading status for debugging
  Map<String, int> getFactionLoadStatus() {
    return Map.fromEntries(_factionUnits.entries
        .map((entry) => MapEntry(entry.key, entry.value.length)));
  }

  /// Manually load additional faction (for future extensibility)
  Future<void> loadAdditionalFaction(String factionName) async {
    if (_factionUnits.containsKey(factionName.toLowerCase())) {
      print('Faction $factionName already loaded');
      return;
    }

    try {
      await _loadFactionData(factionName);
    } catch (e) {
      print('Failed to load additional faction $factionName: $e');
      rethrow;
    }
  }

  /// Clear all loaded data (useful for testing or reloading)
  void clearData() {
    _factionUnits.clear();
    _isLoaded = false;
  }
}
