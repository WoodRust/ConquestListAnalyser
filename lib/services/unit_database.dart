import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/unit.dart';
import 'unit_database_interface.dart';

/// Service for loading and managing unit data
class UnitDatabase implements UnitDatabaseInterface {
  static UnitDatabase? _instance;
  static UnitDatabase get instance => _instance ??= UnitDatabase._();
  UnitDatabase._();

  final Map<String, List<Unit>> _factionUnits = {};
  bool _isLoaded = false;

  @override
  Future<void> loadData() async {
    if (_isLoaded) return;

    await _loadFactionData('nords');
    _isLoaded = true;
  }

  /// Load data for a specific faction
  Future<void> _loadFactionData(String faction) async {
    try {
      final String jsonString =
          await rootBundle.loadString('assets/data/$faction.json');
      final List<dynamic> jsonList = json.decode(jsonString);

      final units = jsonList.map((json) => Unit.fromJson(json)).toList();
      _factionUnits[faction] = units;

      print('Loaded ${units.length} units for faction: $faction');
    } catch (e) {
      print('Error loading faction data for $faction: $e');
      throw Exception('Failed to load $faction data: $e');
    }
  }

  @override
  Unit? findUnit(String unitName) {
    final normalizedName = unitName.trim().toLowerCase();

    for (final units in _factionUnits.values) {
      for (final unit in units) {
        if (unit.name.toLowerCase() == normalizedName) {
          return unit;
        }
      }
    }
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
}
