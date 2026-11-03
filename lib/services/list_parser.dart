import '../models/regiment.dart';
import '../models/army_list.dart';
import '../models/unit.dart';
import 'unit_database.dart';
import 'unit_database_interface.dart';

/// Service for parsing flat text army lists into structured data
class ListParser {
  final UnitDatabaseInterface _database;
  int _sourceGroupSequence = 0;

  ListParser({UnitDatabaseInterface? database})
      : _database = database ?? UnitDatabase.instance;

  /// Parse a flat text army list into an ArmyList object
  Future<ArmyList> parseList(String inputText) async {
    await _database.loadData();
    _sourceGroupSequence = 0;

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
      } else if (!line.startsWith('*') &&
          line.contains('[') &&
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
        // Character line: "== Vargyr Lord [160]: Wild Beasts" or "== (Warlord) Volva [100]: "
        final character = _parseCharacterLine(line);
        if (character != null) {
          regiments.add(character);
        }
      } else if (line.startsWith('* ')) {
        // Regiment line: "* Goltr Beastpack (3) [160]: "
        regiments.addAll(_parseRegimentLine(line));
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
    final regexPattern = r'== (?:\(([^)]+)\)\s+)?(.+?) \[(\d+)\]:?(.*)';
    final regex = RegExp(regexPattern);
    final match = regex.firstMatch(line);

    if (match == null) {
      print('Failed to parse character line: $line');
      return null;
    }

    final designation = match.group(1)?.trim(); // "Warlord" or null
    final unitName = match.group(2)!.trim();
    final pointsCost = int.parse(match.group(3)!);
    final upgradesText = match.group(4)?.trim() ?? '';

    // Check if this character is a warlord
    final isWarlord = designation?.toLowerCase() == 'warlord';

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
      isWarlord: isWarlord,
    );
  }

  /// Parse a regiment line. A War Chariot line expands to one Regiment per chariot.
  List<Regiment> _parseRegimentLine(String line) {
    final regex = RegExp(r'^\* (.+) \((\d+)\) \[(\d+)\]:?(.*)$');
    final match = regex.firstMatch(line);

    if (match == null) {
      print('Failed to parse regiment line: $line');
      return [];
    }

    final unitName = match.group(1)!.trim();
    final stands = int.parse(match.group(2)!);
    final pointsCost = int.parse(match.group(3)!);
    final upgradesText = match.group(4)?.trim() ?? '';

    if (unitName.toLowerCase() == 'modular regiment') {
      final modular = _parseModularRegiment(stands, pointsCost, upgradesText);
      return modular == null ? [] : [modular];
    }

    if (unitName.toLowerCase().startsWith('war chariots')) {
      return _parseWarChariots(
        unitName,
        stands,
        pointsCost,
        upgradesText,
      );
    }

    final unit = _database.findUnit(unitName);
    if (unit == null) {
      print('Unit not found in database: $unitName');
      return [];
    }

    final upgrades = _splitUpgrades(upgradesText);
    final auxiliaryStands = unit.auxiliaryOptions
        .where((option) => upgrades.any(
            (upgrade) => upgrade.toLowerCase() == option.name.toLowerCase()))
        .toList();

    return [
      Regiment(
        unit: unit,
        stands: stands,
        pointsCost: pointsCost,
        upgrades: upgrades,
        auxiliaryStands: auxiliaryStands,
        isWarlord: false,
      ),
    ];
  }

  List<String> _splitUpgrades(String text) {
    if (text.isEmpty) return [];
    return text
        .split(',')
        .map((upgrade) => upgrade.trim())
        .where((upgrade) => upgrade.isNotEmpty)
        .toList();
  }

  /// Parse a Yoroni Modular Regiment composition such as
  /// "Tengu Ayakashi (L), Tengu Ayakashi (2), Kappa Bushi".
  /// Returns null (and logs a warning) if the composition breaks the build rules.
  Regiment? _parseModularRegiment(
      int stands, int pointsCost, String compositionText) {
    final counts = <String, int>{};
    final units = <String, Unit>{};
    String? leaderName;
    final token = RegExp(r'\(([^)]*)\)');

    for (final entry in _splitUpgrades(compositionText)) {
      final name = entry.replaceAll(token, '').trim();
      var quantity = 1;
      var isLeader = false;
      for (final match in token.allMatches(entry)) {
        final value = match.group(1)!.trim();
        if (value.toUpperCase() == 'L') {
          isLeader = true;
        } else {
          quantity = int.tryParse(value) ?? quantity;
        }
      }

      final unit = _database.findUnit(name);
      if (unit == null || !unit.isModularStand) {
        print('Modular Regiment stand not recognised: $name');
        return null;
      }
      units[unit.name] = unit;
      counts[unit.name] = (counts[unit.name] ?? 0) + quantity;

      if (isLeader) {
        if (leaderName != null && leaderName != unit.name) {
          print('Modular Regiment has more than one leader: $compositionText');
          return null;
        }
        leaderName = unit.name;
      }
    }

    if (counts.isEmpty) {
      print('Modular Regiment has no stands: $compositionText');
      return null;
    }
    leaderName ??= counts.keys.first;

    final total = counts.values.fold(0, (sum, count) => sum + count);
    final leaderCount = counts[leaderName]!;
    final otherCount = total - leaderCount;
    if (total != stands || total < 2 || otherCount >= leaderCount) {
      print('Invalid Modular Regiment (expected $stands stands, '
          'found $total with $leaderCount $leaderName): $compositionText');
      return null;
    }

    final leader = units[leaderName]!;
    final modifiers = <String, int>{};
    void addModifiers(Map<String, int> source) => source.forEach(
        (key, value) => modifiers[key] = (modifiers[key] ?? 0) + value);
    addModifiers(leader.commandModifiers);
    for (final unit in units.values) {
      addModifiers(unit.regimentModifiers);
    }

    final leaderUnit = leader.copyWith(
      characteristics: leader.characteristics.applyModifiers(modifiers),
      specialRules: [
        ...leader.specialRules,
        const SpecialRule(
          name: 'Leader',
          description: 'The Modular Regiment\'s Command Stand and Leader.',
        ),
      ],
    );

    final auxiliaryStands = <AuxiliaryProfile>[];
    counts.forEach((name, count) {
      if (name == leaderName) return;
      final unit = units[name]!;
      final profile = AuxiliaryProfile.fromUnit(
        unit,
        characteristics: unit.characteristics.applyModifiers(modifiers),
      );
      for (var index = 0; index < count; index++) {
        auxiliaryStands.add(profile);
      }
    });

    return Regiment(
      unit: leaderUnit,
      stands: leaderCount,
      pointsCost: pointsCost,
      auxiliaryStands: auxiliaryStands,
      isModular: true,
    );
  }

  List<Regiment> _parseWarChariots(
    String groupName,
    int count,
    int pointsCost,
    String upgradesText,
  ) {
    final groupId = 'war-chariots-${_sourceGroupSequence++}';
    final selectionText =
        upgradesText.trim().replaceFirst(RegExp(r'^:\s*'), '');
    final selectedNames = <String>[];
    final repeated = RegExp(r'^(.+?)\s*\((\d+)\)$');
    for (final rawSelection in _splitUpgrades(selectionText)) {
      final selection = repeated.firstMatch(rawSelection);
      final rawName = selection?.group(1)?.trim() ?? rawSelection;
      final quantity = int.tryParse(selection?.group(2) ?? '1') ?? 1;
      for (var index = 0; index < quantity; index++) {
        selectedNames.add(_canonicalChariotName(rawName));
      }
    }

    if (selectedNames.length != count) {
      print(
          'War Chariot count mismatch: expected $count, found ${selectedNames.length} in $selectionText');
      return [];
    }

    final perChariotPoints = pointsCost ~/ count;
    final result = <Regiment>[];
    for (final selectedName in selectedNames) {
      final unit = _database.findUnit(selectedName);
      if (unit == null) {
        print('War Chariot not found in database: $selectedName');
        continue;
      }
      result.add(Regiment(
        unit: unit,
        stands: 1,
        pointsCost: perChariotPoints,
        sourceGroupId: groupId,
        sourceGroupName: groupName,
        sourceGroupPoints: pointsCost,
      ));
    }
    return result;
  }

  String _canonicalChariotName(String name) {
    final normalized = name.trim().toLowerCase();
    if (normalized == 'flogobollon' || normalized == 'flogobolon') {
      return 'Flogobolon';
    }
    if (normalized == 'skorpios') return 'Skorpios';
    return name.trim();
  }
}
