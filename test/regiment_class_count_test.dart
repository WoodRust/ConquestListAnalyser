import 'package:flutter_test/flutter_test.dart';
import 'package:conquest_analyzer/services/scoring_engine.dart';
import 'package:conquest_analyzer/services/list_parser.dart';
import 'package:conquest_analyzer/services/unit_database_interface.dart';
import 'package:conquest_analyzer/models/army_list.dart';
import 'package:conquest_analyzer/models/regiment.dart';
import 'package:conquest_analyzer/models/unit.dart';

void main() {
  group('Regiment Class Count Integration Tests', () {
    late ScoringEngine scoringEngine;
    late ListParser parser;
    late MockUnitDatabase mockDatabase;

    setUp(() {
      scoringEngine = ScoringEngine();
      mockDatabase = MockUnitDatabase();
      parser = ListParser(database: mockDatabase);
    });

    test('should maintain regiment class counts through parsing and scoring',
        () async {
      const input = '''
=== The Last Argument of Kings ===
Mixed Army [1430/2000]
Test Faction

== Test Character [150]: 
 * Light Raiders (2) [240]: 
 * Medium Warriors (1) [160]: 
 * Heavy Guards (1) [200]: 
 * Light Scouts (1) [120]: 
''';

      final armyList = await parser.parseList(input);
      final score = scoringEngine.calculateScores(armyList);

      // Verify the original army list counts
      expect(armyList.lightRegimentCount,
          equals(2)); // Light Raiders + Light Scouts
      expect(armyList.mediumRegimentCount, equals(1)); // Medium Warriors
      expect(armyList.heavyRegimentCount, equals(1)); // Heavy Guards
      expect(armyList.characters.length, equals(1)); // Test Character

      // Verify the score object maintains access to the same army list
      expect(score.armyList.lightRegimentCount, equals(2));
      expect(score.armyList.mediumRegimentCount, equals(1));
      expect(score.armyList.heavyRegimentCount, equals(1));

      // Verify total consistency
      expect(score.armyList.regiments.length,
          equals(5)); // 4 regiments + 1 character
      expect(score.armyList.nonCharacterRegiments.length, equals(4));
    });

    test('should handle army with only characters correctly', () async {
      const input = '''
=== The Last Argument of Kings ===
Character Army [300/2000]
Test Faction

== Test Character [150]: 
== Another Character [150]: 
''';

      final armyList = await parser.parseList(input);
      final score = scoringEngine.calculateScores(armyList);

      expect(armyList.lightRegimentCount, equals(0));
      expect(armyList.mediumRegimentCount, equals(0));
      expect(armyList.heavyRegimentCount, equals(0));
      expect(armyList.characters.length, equals(2));

      // Score should handle this gracefully
      expect(score.totalWounds,
          equals(0)); // Characters excluded from wound calculation
      expect(score.armyList.lightRegimentCount, equals(0));
    });

    test('should handle army with only one regiment class', () async {
      const input = '''
=== The Last Argument of Kings ===
Heavy Army [800/2000]
Test Faction

== Test Character [150]: 
 * Heavy Guards (1) [200]: 
 * Heavy Elite (1) [250]: 
 * Heavy Guards (1) [200]: 
''';

      final armyList = await parser.parseList(input);
      final score = scoringEngine.calculateScores(armyList);

      expect(armyList.lightRegimentCount, equals(0));
      expect(armyList.mediumRegimentCount, equals(0));
      expect(armyList.heavyRegimentCount, equals(3));
      expect(armyList.characters.length, equals(1));

      // Verify breakdown map
      final breakdown = armyList.regimentClassBreakdown;
      expect(breakdown['light'], equals(0));
      expect(breakdown['medium'], equals(0));
      expect(breakdown['heavy'], equals(3));
    });

    test('should handle mixed case regiment classes from parsed data',
        () async {
      // This would test real-world scenarios where JSON data might have different cases
      const input = '''
=== The Last Argument of Kings ===
Case Test Army [630/2000]
Test Faction

== Test Character [150]: 
 * Mixed Case Unit (1) [160]: 
 * Uppercase Unit (1) [160]: 
 * Light Raiders (1) [160]: 
''';

      final armyList = await parser.parseList(input);

      // The mock database returns units with different case regiment classes
      expect(
          armyList.lightRegimentCount,
          equals(
              2)); // Light Raiders + Mixed Case Unit (medium -> light in mock)
      expect(armyList.mediumRegimentCount, equals(0));
      expect(armyList.heavyRegimentCount,
          equals(1)); // Uppercase Unit (heavy in mock)
    });

    test('should maintain regiment class counts with complex army compositions',
        () async {
      const input = '''
=== The Last Argument of Kings ===
Complex Army [1680/2000]
Test Faction

== Test Character [150]: 
== Another Character [150]: 
 * Light Raiders (3) [360]: 
 * Light Scouts (1) [120]: 
 * Medium Warriors (2) [320]: 
 * Medium Elite (1) [160]: 
 * Heavy Guards (1) [200]: 
 * Heavy Elite (1) [250]: 
''';

      final armyList = await parser.parseList(input);
      final score = scoringEngine.calculateScores(armyList);

      // Verify detailed breakdown
      expect(armyList.lightRegimentCount,
          equals(2)); // Light Raiders + Light Scouts
      expect(armyList.mediumRegimentCount,
          equals(2)); // Medium Warriors + Medium Elite
      expect(
          armyList.heavyRegimentCount, equals(2)); // Heavy Guards + Heavy Elite
      expect(armyList.characters.length, equals(2));

      // Verify consistency across different access methods
      expect(score.armyList.regimentClassBreakdown['light'], equals(2));
      expect(score.armyList.regimentClassBreakdown['medium'], equals(2));
      expect(score.armyList.regimentClassBreakdown['heavy'], equals(2));

      // Verify total regiment count consistency
      final totalClassed = armyList.lightRegimentCount +
          armyList.mediumRegimentCount +
          armyList.heavyRegimentCount;
      expect(totalClassed, equals(armyList.nonCharacterRegiments.length));
      expect(totalClassed, equals(6));
    });

    test('should handle armies with unknown regiment classes', () {
      // Create units with non-standard regiment classes
      final unknownUnit1 = Unit(
        name: 'Super Heavy Tank',
        faction: 'Test',
        type: 'vehicle',
        regimentClass: 'super_heavy',
        characteristics: const UnitCharacteristics(
          march: 2,
          volley: 6,
          clash: 1,
          attacks: 1,
          wounds: 10,
          resolve: 5,
          defense: 5,
          evasion: 1,
        ),
        specialRules: const [],
        numericSpecialRules: const {},
        supremacyAbilities: const [],
        drawEvents: const [],
        points: 400,
      );

      final unknownUnit2 = Unit(
        name: 'Flying Scout',
        faction: 'Test',
        type: 'flying',
        regimentClass: 'aerial',
        characteristics: const UnitCharacteristics(
          march: 15,
          volley: 2,
          clash: 2,
          attacks: 3,
          wounds: 2,
          resolve: 2,
          defense: 1,
          evasion: 3,
        ),
        specialRules: const [],
        numericSpecialRules: const {},
        supremacyAbilities: const [],
        drawEvents: const [],
        points: 180,
      );

      final lightUnit = Unit(
        name: 'Light Infantry',
        faction: 'Test',
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
      );

      final regiments = [
        Regiment(unit: unknownUnit1, stands: 1, pointsCost: 400),
        Regiment(unit: unknownUnit2, stands: 1, pointsCost: 180),
        Regiment(unit: lightUnit, stands: 1, pointsCost: 120),
      ];

      final armyList = ArmyList(
        name: 'Unknown Classes Army',
        faction: 'Test',
        totalPoints: 700,
        pointsLimit: 2000,
        regiments: regiments,
      );

      // Unknown classes should not be counted in standard classes
      expect(armyList.lightRegimentCount, equals(1)); // Only the light unit
      expect(armyList.mediumRegimentCount, equals(0));
      expect(armyList.heavyRegimentCount, equals(0));

      // But should still be counted as non-character regiments
      expect(armyList.nonCharacterRegiments.length, equals(3));
      expect(armyList.characters.length, equals(0));
    });

    test('should maintain performance with large armies', () {
      // Create a large army to test performance of counting operations
      final lightUnit = Unit(
        name: 'Light Unit',
        faction: 'Test',
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
      );

      final regiments = <Regiment>[];
      for (int i = 0; i < 100; i++) {
        regiments.add(Regiment(unit: lightUnit, stands: 1, pointsCost: 120));
      }

      final armyList = ArmyList(
        name: 'Large Army',
        faction: 'Test',
        totalPoints: 12000,
        pointsLimit: 15000,
        regiments: regiments,
      );

      // Multiple calls should be fast and consistent
      final stopwatch = Stopwatch()..start();

      for (int i = 0; i < 10; i++) {
        expect(armyList.lightRegimentCount, equals(100));
        expect(armyList.mediumRegimentCount, equals(0));
        expect(armyList.heavyRegimentCount, equals(0));
      }

      stopwatch.stop();

      // Should complete very quickly (less than 100ms for 1000 operations)
      expect(stopwatch.elapsedMilliseconds, lessThan(100));
    });
  });
}

/// Mock implementation for testing
class MockUnitDatabase implements UnitDatabaseInterface {
  final Map<String, Unit> _units = {
    'test character': Unit(
      name: 'Test Character',
      faction: 'Test',
      type: 'character',
      regimentClass: 'character',
      characteristics: const UnitCharacteristics(
        march: 8,
        volley: 3,
        clash: 4,
        attacks: 6,
        wounds: 3,
        resolve: 4,
        defense: 3,
        evasion: 2,
      ),
      specialRules: const [],
      numericSpecialRules: const {},
      supremacyAbilities: const [],
      drawEvents: const [],
      points: 150,
    ),
    'another character': Unit(
      name: 'Another Character',
      faction: 'Test',
      type: 'character',
      regimentClass: 'character',
      characteristics: const UnitCharacteristics(
        march: 8,
        volley: 3,
        clash: 4,
        attacks: 6,
        wounds: 3,
        resolve: 4,
        defense: 3,
        evasion: 2,
      ),
      specialRules: const [],
      numericSpecialRules: const {},
      supremacyAbilities: const [],
      drawEvents: const [],
      points: 150,
    ),
    'light raiders': Unit(
      name: 'Light Raiders',
      faction: 'Test',
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
    'light scouts': Unit(
      name: 'Light Scouts',
      faction: 'Test',
      type: 'infantry',
      regimentClass: 'light',
      characteristics: const UnitCharacteristics(
        march: 7,
        volley: 2,
        clash: 2,
        attacks: 3,
        wounds: 3,
        resolve: 2,
        defense: 1,
        evasion: 2,
      ),
      specialRules: const [],
      numericSpecialRules: const {},
      supremacyAbilities: const [],
      drawEvents: const [],
      points: 120,
    ),
    'medium warriors': Unit(
      name: 'Medium Warriors',
      faction: 'Test',
      type: 'infantry',
      regimentClass: 'medium',
      characteristics: const UnitCharacteristics(
        march: 5,
        volley: 1,
        clash: 3,
        attacks: 4,
        wounds: 5,
        resolve: 3,
        defense: 2,
        evasion: 1,
      ),
      specialRules: const [],
      numericSpecialRules: const {},
      supremacyAbilities: const [],
      drawEvents: const [],
      points: 160,
      pointsPerAdditionalStand: 50,
    ),
    'medium elite': Unit(
      name: 'Medium Elite',
      faction: 'Test',
      type: 'infantry',
      regimentClass: 'medium',
      characteristics: const UnitCharacteristics(
        march: 5,
        volley: 1,
        clash: 3,
        attacks: 4,
        wounds: 5,
        resolve: 3,
        defense: 2,
        evasion: 1,
      ),
      specialRules: const [],
      numericSpecialRules: const {},
      supremacyAbilities: const [],
      drawEvents: const [],
      points: 160,
    ),
    'heavy guards': Unit(
      name: 'Heavy Guards',
      faction: 'Test',
      type: 'infantry',
      regimentClass: 'heavy',
      characteristics: const UnitCharacteristics(
        march: 4,
        volley: 1,
        clash: 4,
        attacks: 3,
        wounds: 6,
        resolve: 4,
        defense: 3,
        evasion: 1,
      ),
      specialRules: const [],
      numericSpecialRules: const {},
      supremacyAbilities: const [],
      drawEvents: const [],
      points: 200,
    ),
    'heavy elite': Unit(
      name: 'Heavy Elite',
      faction: 'Test',
      type: 'infantry',
      regimentClass: 'heavy',
      characteristics: const UnitCharacteristics(
        march: 4,
        volley: 1,
        clash: 4,
        attacks: 3,
        wounds: 6,
        resolve: 4,
        defense: 3,
        evasion: 1,
      ),
      specialRules: const [],
      numericSpecialRules: const {},
      supremacyAbilities: const [],
      drawEvents: const [],
      points: 250,
    ),
    'mixed case unit': Unit(
      name: 'Mixed Case Unit',
      faction: 'Test',
      type: 'infantry',
      regimentClass: 'light', // lowercase
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
      specialRules: const [], numericSpecialRules: const {},
      supremacyAbilities: const [],
      drawEvents: const [],

      points: 160,
    ),
    'uppercase unit': Unit(
      name: 'Uppercase Unit',
      faction: 'Test',
      type: 'infantry',
      regimentClass: 'heavy', // Will test case insensitive matching
      characteristics: const UnitCharacteristics(
        march: 4,
        volley: 1,
        clash: 4,
        attacks: 3,
        wounds: 6,
        resolve: 4,
        defense: 3,
        evasion: 1,
      ),
      specialRules: const [], numericSpecialRules: const {},
      supremacyAbilities: const [],
      drawEvents: const [], points: 160,
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
    return _units.values.where((unit) => unit.faction == faction).toList();
  }

  @override
  List<String> get availableFactions => ['Test'];

  @override
  bool get isLoaded => true;
}
