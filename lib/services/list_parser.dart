import '../models/unit.dart';
import '../models/regiment.dart';
import '../models/army_list.dart';
import 'unit_database.dart';

/// Service for parsing flat text army lists into structured data
class ListParser {
  final UnitDatabase _database;

  ListParser({UnitDatabase? database})
      : _database = database ?? UnitDatabase.instance;

  /// Parse a flat text army list into an ArmyList object
  Future<ArmyList> parseList(String inputText) async {
    await _database.loadData();

    final lines = inputText.split('\n').map((line) => line.trim()).toList();

    String? listName;
    String? faction;
    int? totalPoints;
    int? pointsLimit;
    final List<Regiment> regiments = [];

    for (final line in lines) {
      if (line.isEmpty) continue;

      // Parse header information
      if (line.startsWith('=== ') && line.endsWith(' ===')) {
        // Game name line - skip
        continue;
      } else if (line.contains('[') &&
          line.contains('/') &&
          line.contains(']')) {
        // Points line: "Redbeard [2000/2000]"
        final parts = line.split('[');
        if (parts.length == 2) {
          listName = parts[0].trim();
          final pointsPart = parts[1].replaceAll(']', '');
          final pointsSplit = pointsPart.split('/');
          if (pointsSplit.length == 2) {
            totalPoints = int.tryParse(pointsSplit[0]);
            pointsLimit = int.tryParse(pointsSplit[1]);
          }
        }
      } else if (!line.startsWith('==') &&
          !line.startsWith('*') &&
          listName != null &&
          faction == null) {
        // Faction line
        faction = line.trim();
      } else if (line.startsWith('== ')) {
        // Character line: "== Vargyr Lord [160]: Wild Beasts"
        final character = _parseCharacterLine(line);
        if (character != null) {
          regiments.add(character);
        }
      } else if (line.startsWith('== ')) {
        // Character line: "== Vargyr Lord [160]: Wild Beasts"
        print('Found character line: $line');
        final character = _parseCharacterLine(line);
        if (character != null) {
          print('Successfully parsed character: ${character.unit.name}');
          regiments.add(character);
        } else {
          print('Failed to parse character line');
        }
      } else if (line.startsWith('* ')) {
        // Regiment line: "* Goltr Beastpack (3) [160]: "
        final regiment = _parseRegimentLine(line);
        if (regiment != null) {
          regiments.add(regiment);
        }
      }
    }

    if (listName == null ||
        faction == null ||
        totalPoints == null ||
        pointsLimit == null) {
      throw Exception('Failed to parse list header information');
    }

    return ArmyList(
      name: listName,
      faction: faction,
      totalPoints: totalPoints,
      pointsLimit: pointsLimit,
      regiments: regiments,
    );
  }

  /// Parse a character line
  Regiment? _parseCharacterLine(String line) {
    // Format: "== Vargyr Lord [160]: Wild Beasts" or "== (Warlord) Volva [100]: "
    final regexPattern = r'== (?:\([^)]+\)\s+)?(.+?) \[(\d+)\]:?(.*)';
    final regex = RegExp(regexPattern);
    final match = regex.firstMatch(line);

    if (match == null) {
      print('Failed to parse character line: $line');
      return null;
    }

    final unitName = match.group(1)!.trim();
    final pointsCost = int.parse(match.group(2)!);
    final upgradesText = match.group(3)?.trim() ?? '';

    final unit = _database.findUnit(unitName);
    if (unit == null) {
      print('Character not found in database: $unitName');
      return null;
    }

    final upgrades = upgradesText.isEmpty
        ? <String>[]
        : upgradesText
            .split(',')
            .map((u) => u.trim())
            .where((u) => u.isNotEmpty)
            .toList();

    return Regiment(
      unit: unit,
      stands: 1, // Characters are always 1 stand
      pointsCost: pointsCost,
      upgrades: upgrades,
    );
  }

  /// Parse a single regiment line
  Regiment? _parseRegimentLine(String line) {
    // Format: "* Goltr Beastpack (3) [160]: "
    final regexPattern = r'\* (.+?) \((\d+)\) \[(\d+)\]:?(.*)';
    final regex = RegExp(regexPattern);
    final match = regex.firstMatch(line);

    if (match == null) {
      print('Failed to parse regiment line: $line');
      return null;
    }

    final unitName = match.group(1)!.trim();
    final stands = int.parse(match.group(2)!);
    final pointsCost = int.parse(match.group(3)!);
    final upgradesText = match.group(4)?.trim() ?? '';

    final unit = _database.findUnit(unitName);
    if (unit == null) {
      print('Unit not found in database: $unitName');
      return null;
    }

    final upgrades = upgradesText.isEmpty
        ? <String>[]
        : upgradesText
            .split(',')
            .map((u) => u.trim())
            .where((u) => u.isNotEmpty)
            .toList();

    return Regiment(
      unit: unit,
      stands: stands,
      pointsCost: pointsCost,
      upgrades: upgrades,
    );
  }
}
