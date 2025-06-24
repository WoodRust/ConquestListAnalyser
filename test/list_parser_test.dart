import 'package:flutter_test/flutter_test.dart';
import 'package:conquest_analyzer/services/list_parser.dart';
import 'package:conquest_analyzer/services/unit_database_interface.dart';
import 'package:conquest_analyzer/models/unit.dart';

void main() {
  group('ListParser Tests', () {
    late ListParser parser;
    late MockUnitDatabase mockDatabase;

    setUp(() {
      mockDatabase = MockUnitDatabase();
      parser = ListParser(database: mockDatabase);
    });

    test('should parse basic army list correctly', () async {
      const input = '''
=== The Last Argument of Kings ===

test [1990/2000]
Nords

== Vargyr Lord [160]: Wild Beasts

 * Goltr Beastpack (3) [160]: 
 * Werewargs (3) [160]: 
''';

      final armyList = await parser.parseList(input);

      expect(armyList.name, equals('test'));
      expect(armyList.faction, equals('Nords'));
      expect(armyList.totalPoints, equals(1990));
      expect(armyList.pointsLimit, equals(2000));
      expect(armyList.regiments.length, equals(2));
    });

    test('should parse regiment lines correctly', () async {
      const input = '''
=== The Last Argument of Kings ===

test [500/2000]
Nords

== Shaman [80]: 

 * Raiders (3) [140]: Captain
''';

      final armyList = await parser.parseList(input);
      final regiment = armyList.regiments.first;

      expect(regiment.unit.name, equals('Raiders'));
      expect(regiment.stands, equals(3));
      expect(regiment.pointsCost, equals(140));
      expect(regiment.upgrades, contains('Captain'));
    });

    test('should handle missing units gracefully', () async {
      const input = '''
=== The Last Argument of Kings ===

test [500/2000]
Nords

== Character [100]: 

 * Unknown Unit (3) [140]: 
''';

      final armyList = await parser.parseList(input);
      expect(armyList.regiments.length,
          equals(0)); // Unknown unit should be skipped
    });
  });
}

/// Mock implementation for testing
class MockUnitDatabase implements UnitDatabaseInterface {
  final Map<String, Unit> _units = {
    'raiders': Unit(
      name: 'Raiders',
      faction: 'Nords',
      type: 'infantry',
      regimentClass: 'light',
      characteristics: const UnitCharacteristics(
        march: 6,
        volley: 1,
        clash: 2,
        attacks: 4,
        wounds: 4,
        resolve: 2,
        defense: 1,
        evasion: 1,
      ),
      specialRules: const [],
      numericSpecialRules: const {},
      supremacyAbilities: const [],
      drawEvents: const [],
      points: 120,
      pointsPerAdditionalStand: 40,
    ),
    'goltr beastpack': Unit(
      name: 'Goltr Beastpack',
      faction: 'Nords',
      type: 'cavalry',
      regimentClass: 'medium',
      characteristics: const UnitCharacteristics(
        march: 6,
        volley: 1,
        clash: 3,
        attacks: 5,
        wounds: 5,
        resolve: 3,
        defense: 3,
        evasion: 1,
      ),
      specialRules: const [],
      numericSpecialRules: const {},
      supremacyAbilities: const [],
      drawEvents: const [],
      points: 160,
      pointsPerAdditionalStand: 50,
    ),
    'werewargs': Unit(
      name: 'Werewargs',
      faction: 'Nords',
      type: 'brute',
      regimentClass: 'light',
      characteristics: const UnitCharacteristics(
        march: 7,
        volley: 1,
        clash: 2,
        attacks: 6,
        wounds: 5,
        resolve: 3,
        defense: 2,
        evasion: 1,
      ),
      specialRules: const [],
      numericSpecialRules: const {},
      supremacyAbilities: const [],
      drawEvents: const [],
      points: 170,
      pointsPerAdditionalStand: 60,
    ),
  };

  @override
  Future<void> loadData() async {
    // Mock implementation - no async loading needed
  }

  @override
  Unit? findUnit(String unitName) {
    return _units[unitName.toLowerCase()];
  }

  @override
  List<Unit> getUnitsForFaction(String faction) {
    return [];
  }

  @override
  List<String> get availableFactions => ['nords'];

  @override
  bool get isLoaded => true;
}
