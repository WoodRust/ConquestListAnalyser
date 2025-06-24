import 'package:flutter_test/flutter_test.dart';
import 'package:conquest_analyzer/services/list_parser.dart';
import 'package:conquest_analyzer/services/scoring_engine.dart';
import 'package:conquest_analyzer/services/unit_database_interface.dart';
import 'package:conquest_analyzer/models/unit.dart';

void main() {
  group('Regiment Class Count End-to-End Tests', () {
    late ListParser parser;
    late ScoringEngine scoringEngine;
    late MockUnitDatabase mockDatabase;

    setUp(() {
      mockDatabase = MockUnitDatabase();
      parser = ListParser(database: mockDatabase);
      scoringEngine = ScoringEngine();
    });

    test(
        'should correctly parse and count regiment classes from real list format',
        () async {
      // Test with the actual format from the provided examples
      const input = '''
=== The Last Argument of Kings ===

test [1990/2000]
Nords


== Vargyr Lord [160]: Wild Beasts

 * Goltr Beastpack (3) [160]: 

 * Goltr Beastpack (3) [160]: 

 * Werewargs (3) [160]: 

 * Werewargs (3) [160]: 


== Shaman [80]: 

 * Raiders (3) [140]: Captain

 * Raiders (3) [140]: Captain

 * Raiders (3) [140]: Captain

 * Bearsarks (3) [200]: Savage


== (Warlord) Volva [100]: 

 * Raiders (3) [140]: Captain


== Volva [100]: 

 * Huskarls (3) [150]: 
''';

      final armyList = await parser.parseList(input);
      final score = scoringEngine.calculateScores(armyList);

      // Verify parsing worked correctly
      expect(armyList.name, equals('test'));
      expect(armyList.faction, equals('Nords'));
      expect(armyList.totalPoints, equals(1990));
      expect(armyList.pointsLimit, equals(2000));

      // Based on mock database setup:
      // Characters: Vargyr Lord, Shaman, Volva, Volva (4 total)
      // Light regiments: Raiders (4 total), Werewargs (2 total) = 6 total
      // Medium regiments: Goltr Beastpack (2 total), Bearsarks (1 total), Huskarls (1 total) = 4 total
      // Heavy regiments: 0
      expect(armyList.characters.length, equals(4));
      expect(armyList.lightRegimentCount, equals(6));
      expect(armyList.mediumRegimentCount, equals(4));
      expect(armyList.heavyRegimentCount, equals(0));

      // Verify score calculation includes these counts
      expect(score.armyList.lightRegimentCount, equals(6));
      expect(score.armyList.mediumRegimentCount, equals(4));
      expect(score.armyList.heavyRegimentCount, equals(0));

      // Verify consistency
      expect(
          armyList.regiments.length, equals(14)); // 10 regiments + 4 characters
      expect(armyList.nonCharacterRegiments.length, equals(10));
    });

    test('should handle The Spires army list format correctly', () async {
      const input = '''
=== The Last Argument of Kings ===

Redbeard [2000/2000]
The Spires
The Sovereign Lineage


== (Warlord) Lineage Highborne [120]: Cascading Degeneration, Command Pheromones, Pheromantic Override

 * Avatara (3) [170]: Superior Creations

 * Avatara (3) [170]: Superior Creations

 * Incarnate Sentinels (4) [280]: 


== Pheromancer [120]: Avatar Projection, Attracting Pheromones

 * Stryx (3) [120]: 

 * Stryx (3) [120]: 

 * Brute Drones (3) [170]: 

 * Abomination (1) [150]: 


== High Clone Executor [130]: Marksman Variant, Suppress Pain, Disperse, Eagle Eye

 * Vanguard Clones (3) [150]: Superior Creations

 * Vanguard Clones (3) [150]: Superior Creations

 * Marksman Clones (3) [150]:
''';

      final armyList = await parser.parseList(input);

      expect(armyList.name, equals('Redbeard'));
      expect(armyList.faction, equals('The Spires'));
      expect(armyList.totalPoints, equals(2000));

      // Based on mock database - Spires units would be classified as:
      // Characters: Lineage Highborne, Pheromancer, High Clone Executor (3 total)
      // Regiments: Various unit types (9 total regiments)
      expect(armyList.characters.length, equals(3));
      expect(armyList.nonCharacterRegiments.length, equals(9));

      // Check that we have some distribution of regiment classes
      final totalClassified = armyList.lightRegimentCount +
          armyList.mediumRegimentCount +
          armyList.heavyRegimentCount;
      expect(totalClassified, equals(armyList.nonCharacterRegiments.length));
    });

    test('should handle Hundred Kingdoms army list format correctly', () async {
      const input = '''
=== The Last Argument of Kings ===

Reiem [1995/2000]
The Hundred Kingdoms
[object Object]


== (Warlord) Imperial Officer [100]: 

 * Steel Legion (3) [160]: 

 * Steel Legion (3) [160]: 

 * Hunter Cadre (3) [180]: Null Mage

 * Hunter Cadre (3) [180]: Null Mage


== Chapter Mage [105]: School of Water, Art of War

 * Mercenary Crossbowmen (3) [110]: 


== Chapter Mage [80]: School of Fire

 * Mercenary Crossbowmen (3) [110]: 


== Noble Lord [165]: Dynastic Ally, Armor of Dominion, Gilded Rampart, Weapon Master, Graceful Combatant, Get in Position

 * Household Guard (6) [285]: Armsmaster

 * Men at Arms (3) [110]: 

 * Men at Arms (3) [110]: 

 * Longbowmen (3) [140]:
''';

      final armyList = await parser.parseList(input);
      final score = scoringEngine.calculateScores(armyList);

      expect(armyList.name, equals('Reiem'));
      expect(armyList.faction, equals('The Hundred Kingdoms'));
      expect(armyList.totalPoints, equals(1995));

      // Should have characters and regiments
      expect(armyList.characters.length, greaterThan(0));
      expect(armyList.nonCharacterRegiments.length, greaterThan(0));

      // Should have valid regiment class counts
      expect(armyList.lightRegimentCount, greaterThanOrEqualTo(0));
      expect(armyList.mediumRegimentCount, greaterThanOrEqualTo(0));
      expect(armyList.heavyRegimentCount, greaterThanOrEqualTo(0));

      // Consistency check
      final totalClassed = armyList.lightRegimentCount +
          armyList.mediumRegimentCount +
          armyList.heavyRegimentCount;
      expect(totalClassed, equals(armyList.nonCharacterRegiments.length));

      // Verify score calculation works
      expect(score.totalWounds, greaterThan(0));
      expect(score.armyList.regimentClassBreakdown, isA<Map<String, int>>());
    });

    test('should maintain data integrity through complete workflow', () async {
      const input = '''
=== The Last Argument of Kings ===
Workflow Test [1000/2000]
Test Faction

== Test Character [150]: 
 * Light Unit (2) [240]: 
 * Medium Unit (1) [160]: 
 * Heavy Unit (1) [200]: 
 * Light Unit (1) [120]: 
''';

      // Parse the list
      final armyList = await parser.parseList(input);

      // Calculate scores
      final score = scoringEngine.calculateScores(armyList);

      // Verify all data is consistent across the workflow
      expect(armyList.name, equals(score.armyList.name));
      expect(armyList.faction, equals(score.armyList.faction));
      expect(armyList.totalPoints, equals(score.armyList.totalPoints));
      expect(
          armyList.regiments.length, equals(score.armyList.regiments.length));

      // Verify regiment class counts are consistent
      expect(armyList.lightRegimentCount,
          equals(score.armyList.lightRegimentCount));
      expect(armyList.mediumRegimentCount,
          equals(score.armyList.mediumRegimentCount));
      expect(armyList.heavyRegimentCount,
          equals(score.armyList.heavyRegimentCount));

      // Verify the breakdown map is consistent
      final breakdown = armyList.regimentClassBreakdown;
      expect(breakdown['light'], equals(armyList.lightRegimentCount));
      expect(breakdown['medium'], equals(armyList.mediumRegimentCount));
      expect(breakdown['heavy'], equals(armyList.heavyRegimentCount));

      // Verify the data makes sense
      expect(armyList.lightRegimentCount, equals(2)); // 2 Light Units
      expect(armyList.mediumRegimentCount, equals(1)); // 1 Medium Unit
      expect(armyList.heavyRegimentCount, equals(1)); // 1 Heavy Unit
      expect(armyList.characters.length, equals(1)); // 1 Character
    });

    test('should handle edge cases in real army list formats', () async {
      // Test with unusual formatting and edge cases
      const input = '''
=== The Last Argument of Kings ===

Edge Case Army [500/2000]
Test Faction


== Character With Long Name And Many Upgrades [200]: Upgrade One, Upgrade Two, Very Long Upgrade Name

 * Unit With (Parentheses) In Name (1) [150]: Special Upgrade

 * Another Unit (2) [150]: 
''';

      final armyList = await parser.parseList(input);
      final score = scoringEngine.calculateScores(armyList);

      // Should parse successfully despite unusual formatting
      expect(armyList.name, equals('Edge Case Army'));
      expect(armyList.totalPoints, equals(500));
      expect(armyList.regiments.length, equals(3)); // 1 character + 2 regiments

      // Should still calculate regiment class counts correctly
      expect(armyList.characters.length, equals(1));
      expect(armyList.nonCharacterRegiments.length, equals(2));

      final totalClassed = armyList.lightRegimentCount +
          armyList.mediumRegimentCount +
          armyList.heavyRegimentCount;
      expect(totalClassed, equals(2));

      // Should work in scoring engine
      expect(score.totalWounds, greaterThan(0));
      expect(score.armyList.lightRegimentCount, greaterThanOrEqualTo(0));
      expect(score.armyList.mediumRegimentCount, greaterThanOrEqualTo(0));
      expect(score.armyList.heavyRegimentCount, greaterThanOrEqualTo(0));
    });
  });
}

/// Mock database with comprehensive unit definitions for testing
class MockUnitDatabase implements UnitDatabaseInterface {
  final Map<String, Unit> _units = {
    // Nords units
    'vargyr lord': Unit(
      name: 'Vargyr Lord',
      faction: 'Nords',
      type: 'character',
      regimentClass: 'character',
      characteristics: const UnitCharacteristics(
          march: 7,
          volley: 1,
          clash: 3,
          attacks: 5,
          wounds: 3,
          resolve: 3,
          defense: 2,
          evasion: 1),
      specialRules: const [],
      numericSpecialRules: const {},
      supremacyAbilities: const [],
      drawEvents: const [],
      points: 160,
    ),
    'shaman': Unit(
      name: 'Shaman',
      faction: 'Nords',
      type: 'character',
      regimentClass: 'character',
      characteristics: const UnitCharacteristics(
          march: 6,
          volley: 2,
          clash: 3,
          attacks: 4,
          wounds: 3,
          resolve: 3,
          defense: 1,
          evasion: 1),
      specialRules: const [],
      numericSpecialRules: const {},
      supremacyAbilities: const [],
      drawEvents: const [],
      points: 80,
    ),
    'volva': Unit(
      name: 'Volva',
      faction: 'Nords',
      type: 'character',
      regimentClass: 'character',
      characteristics: const UnitCharacteristics(
          march: 6,
          volley: 2,
          clash: 3,
          attacks: 4,
          wounds: 3,
          resolve: 3,
          defense: 1,
          evasion: 1),
      specialRules: const [],
      numericSpecialRules: const {},
      supremacyAbilities: const [],
      drawEvents: const [],
      points: 100,
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
          evasion: 1),
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
          evasion: 1),
      specialRules: const [],
      numericSpecialRules: const {},
      supremacyAbilities: const [],
      drawEvents: const [],
      points: 170,
      pointsPerAdditionalStand: 60,
    ),
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
          evasion: 1),
      specialRules: const [],
      numericSpecialRules: const {},
      supremacyAbilities: const [],
      drawEvents: const [],
      points: 120,
      pointsPerAdditionalStand: 40,
    ),
    'bearsarks': Unit(
      name: 'Bearsarks',
      faction: 'Nords',
      type: 'infantry',
      regimentClass: 'medium',
      characteristics: const UnitCharacteristics(
          march: 5,
          volley: 1,
          clash: 3,
          attacks: 5,
          wounds: 6,
          resolve: 3,
          defense: 2,
          evasion: 1),
      specialRules: const [],
      numericSpecialRules: const {},
      supremacyAbilities: const [],
      drawEvents: const [],
      points: 200,
      pointsPerAdditionalStand: 65,
    ),
    'huskarls': Unit(
      name: 'Huskarls',
      faction: 'Nords',
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
          evasion: 1),
      specialRules: const [],
      numericSpecialRules: const {},
      supremacyAbilities: const [],
      drawEvents: const [],
      points: 150,
      pointsPerAdditionalStand: 50,
    ),

    // Spires units
    'lineage highborne': Unit(
      name: 'Lineage Highborne',
      faction: 'The Spires',
      type: 'character',
      regimentClass: 'character',
      characteristics: const UnitCharacteristics(
          march: 6,
          volley: 2,
          clash: 4,
          attacks: 5,
          wounds: 3,
          resolve: 4,
          defense: 2,
          evasion: 2),
      specialRules: const [],
      numericSpecialRules: const {},
      supremacyAbilities: const [],
      drawEvents: const [],
      points: 120,
    ),
    'pheromancer': Unit(
      name: 'Pheromancer',
      faction: 'The Spires',
      type: 'character',
      regimentClass: 'character',
      characteristics: const UnitCharacteristics(
          march: 6,
          volley: 3,
          clash: 3,
          attacks: 4,
          wounds: 3,
          resolve: 3,
          defense: 1,
          evasion: 2),
      specialRules: const [],
      numericSpecialRules: const {},
      supremacyAbilities: const [],
      drawEvents: const [],
      points: 120,
    ),
    'high clone executor': Unit(
      name: 'High Clone Executor',
      faction: 'The Spires',
      type: 'character',
      regimentClass: 'character',
      characteristics: const UnitCharacteristics(
          march: 6,
          volley: 4,
          clash: 3,
          attacks: 4,
          wounds: 3,
          resolve: 3,
          defense: 2,
          evasion: 1),
      specialRules: const [],
      numericSpecialRules: const {},
      supremacyAbilities: const [],
      drawEvents: const [],
      points: 130,
    ),
    'avatara': Unit(
      name: 'Avatara',
      faction: 'The Spires',
      type: 'brute',
      regimentClass: 'heavy',
      characteristics: const UnitCharacteristics(
          march: 4,
          volley: 1,
          clash: 4,
          attacks: 6,
          wounds: 6,
          resolve: 4,
          defense: 3,
          evasion: 1),
      specialRules: const [],
      numericSpecialRules: const {},
      supremacyAbilities: const [],
      drawEvents: const [],
      points: 170,
      pointsPerAdditionalStand: 55,
    ),
    'incarnate sentinels': Unit(
      name: 'Incarnate Sentinels',
      faction: 'The Spires',
      type: 'infantry',
      regimentClass: 'heavy',
      characteristics: const UnitCharacteristics(
          march: 4,
          volley: 1,
          clash: 4,
          attacks: 4,
          wounds: 6,
          resolve: 4,
          defense: 3,
          evasion: 1),
      specialRules: const [],
      numericSpecialRules: const {},
      supremacyAbilities: const [],
      drawEvents: const [],
      points: 280,
      pointsPerAdditionalStand: 70,
    ),
    'stryx': Unit(
      name: 'Stryx',
      faction: 'The Spires',
      type: 'cavalry',
      regimentClass: 'light',
      characteristics: const UnitCharacteristics(
          march: 8,
          volley: 2,
          clash: 2,
          attacks: 4,
          wounds: 4,
          resolve: 2,
          defense: 1,
          evasion: 2),
      specialRules: const [],
      numericSpecialRules: const {},
      supremacyAbilities: const [],
      drawEvents: const [],
      points: 120,
      pointsPerAdditionalStand: 40,
    ),
    'brute drones': Unit(
      name: 'Brute Drones',
      faction: 'The Spires',
      type: 'brute',
      regimentClass: 'medium',
      characteristics: const UnitCharacteristics(
          march: 5,
          volley: 1,
          clash: 3,
          attacks: 5,
          wounds: 5,
          resolve: 3,
          defense: 2,
          evasion: 1),
      specialRules: const [],
      numericSpecialRules: const {},
      supremacyAbilities: const [],
      drawEvents: const [],
      points: 170,
      pointsPerAdditionalStand: 55,
    ),
    'abomination': Unit(
      name: 'Abomination',
      faction: 'The Spires',
      type: 'monster',
      regimentClass: 'heavy',
      characteristics: const UnitCharacteristics(
          march: 5,
          volley: 1,
          clash: 4,
          attacks: 6,
          wounds: 8,
          resolve: 4,
          defense: 3,
          evasion: 1),
      specialRules: const [],
      numericSpecialRules: const {},
      supremacyAbilities: const [],
      drawEvents: const [],
      points: 150,
    ),
    'vanguard clones': Unit(
      name: 'Vanguard Clones',
      faction: 'The Spires',
      type: 'infantry',
      regimentClass: 'light',
      characteristics: const UnitCharacteristics(
          march: 6,
          volley: 2,
          clash: 2,
          attacks: 4,
          wounds: 4,
          resolve: 2,
          defense: 1,
          evasion: 1),
      specialRules: const [],
      numericSpecialRules: const {},
      supremacyAbilities: const [],
      drawEvents: const [],
      points: 150,
      pointsPerAdditionalStand: 50,
    ),
    'marksman clones': Unit(
      name: 'Marksman Clones',
      faction: 'The Spires',
      type: 'infantry',
      regimentClass: 'light',
      characteristics: const UnitCharacteristics(
          march: 6,
          volley: 4,
          clash: 2,
          attacks: 3,
          wounds: 4,
          resolve: 2,
          defense: 1,
          evasion: 1),
      specialRules: const [],
      numericSpecialRules: const {},
      supremacyAbilities: const [],
      drawEvents: const [],
      points: 150,
      pointsPerAdditionalStand: 50,
    ),

    // Hundred Kingdoms units
    'imperial officer': Unit(
      name: 'Imperial Officer',
      faction: 'The Hundred Kingdoms',
      type: 'character',
      regimentClass: 'character',
      characteristics: const UnitCharacteristics(
          march: 6,
          volley: 3,
          clash: 3,
          attacks: 4,
          wounds: 3,
          resolve: 3,
          defense: 2,
          evasion: 1),
      specialRules: const [],
      numericSpecialRules: const {},
      supremacyAbilities: const [],
      drawEvents: const [],
      points: 100,
    ),
    'chapter mage': Unit(
      name: 'Chapter Mage',
      faction: 'The Hundred Kingdoms',
      type: 'character',
      regimentClass: 'character',
      characteristics: const UnitCharacteristics(
          march: 6,
          volley: 4,
          clash: 2,
          attacks: 3,
          wounds: 3,
          resolve: 3,
          defense: 1,
          evasion: 1),
      specialRules: const [],
      numericSpecialRules: const {},
      supremacyAbilities: const [],
      drawEvents: const [],
      points: 105,
    ),
    'noble lord': Unit(
      name: 'Noble Lord',
      faction: 'The Hundred Kingdoms',
      type: 'character',
      regimentClass: 'character',
      characteristics: const UnitCharacteristics(
          march: 6,
          volley: 2,
          clash: 4,
          attacks: 5,
          wounds: 3,
          resolve: 4,
          defense: 3,
          evasion: 2),
      specialRules: const [],
      numericSpecialRules: const {},
      supremacyAbilities: const [],
      drawEvents: const [],
      points: 165,
    ),
    'steel legion': Unit(
      name: 'Steel Legion',
      faction: 'The Hundred Kingdoms',
      type: 'infantry',
      regimentClass: 'heavy',
      characteristics: const UnitCharacteristics(
          march: 4,
          volley: 1,
          clash: 4,
          attacks: 3,
          wounds: 6,
          resolve: 4,
          defense: 4,
          evasion: 1),
      specialRules: const [],
      numericSpecialRules: const {},
      supremacyAbilities: const [],
      drawEvents: const [],
      points: 160,
      pointsPerAdditionalStand: 55,
    ),
    'hunter cadre': Unit(
      name: 'Hunter Cadre',
      faction: 'The Hundred Kingdoms',
      type: 'infantry',
      regimentClass: 'medium',
      characteristics: const UnitCharacteristics(
          march: 6,
          volley: 3,
          clash: 3,
          attacks: 4,
          wounds: 5,
          resolve: 3,
          defense: 2,
          evasion: 1),
      specialRules: const [],
      numericSpecialRules: const {},
      supremacyAbilities: const [],
      drawEvents: const [],
      points: 180,
      pointsPerAdditionalStand: 60,
    ),
    'mercenary crossbowmen': Unit(
      name: 'Mercenary Crossbowmen',
      faction: 'The Hundred Kingdoms',
      type: 'infantry',
      regimentClass: 'light',
      characteristics: const UnitCharacteristics(
          march: 6,
          volley: 4,
          clash: 2,
          attacks: 3,
          wounds: 4,
          resolve: 2,
          defense: 1,
          evasion: 1),
      specialRules: const [],
      numericSpecialRules: const {},
      supremacyAbilities: const [],
      drawEvents: const [],
      points: 110,
      pointsPerAdditionalStand: 35,
    ),
    'household guard': Unit(
      name: 'Household Guard',
      faction: 'The Hundred Kingdoms',
      type: 'infantry',
      regimentClass: 'heavy',
      characteristics: const UnitCharacteristics(
          march: 5,
          volley: 1,
          clash: 4,
          attacks: 4,
          wounds: 5,
          resolve: 3,
          defense: 3,
          evasion: 1),
      specialRules: const [],
      numericSpecialRules: const {},
      supremacyAbilities: const [],
      drawEvents: const [],
      points: 285,
      pointsPerAdditionalStand: 45,
    ),
    'men at arms': Unit(
      name: 'Men at Arms',
      faction: 'The Hundred Kingdoms',
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
          evasion: 1),
      specialRules: const [],
      numericSpecialRules: const {},
      supremacyAbilities: const [],
      drawEvents: const [],
      points: 110,
      pointsPerAdditionalStand: 35,
    ),
    'longbowmen': Unit(
      name: 'Longbowmen',
      faction: 'The Hundred Kingdoms',
      type: 'infantry',
      regimentClass: 'light',
      characteristics: const UnitCharacteristics(
          march: 6,
          volley: 4,
          clash: 2,
          attacks: 3,
          wounds: 4,
          resolve: 2,
          defense: 1,
          evasion: 1),
      specialRules: const [],
      numericSpecialRules: const {},
      supremacyAbilities: const [],
      drawEvents: const [],
      points: 140,
      pointsPerAdditionalStand: 45,
    ),

    // Test units
    'test character': Unit(
      name: 'Test Character',
      faction: 'Test Faction',
      type: 'character',
      regimentClass: 'character',
      characteristics: const UnitCharacteristics(
          march: 6,
          volley: 2,
          clash: 3,
          attacks: 4,
          wounds: 3,
          resolve: 3,
          defense: 2,
          evasion: 1),
      specialRules: const [],
      numericSpecialRules: const {},
      supremacyAbilities: const [],
      drawEvents: const [],
      points: 150,
    ),
    'character with long name and many upgrades': Unit(
      name: 'Character With Long Name And Many Upgrades',
      faction: 'Test Faction',
      type: 'character',
      regimentClass: 'character',
      characteristics: const UnitCharacteristics(
          march: 6,
          volley: 3,
          clash: 4,
          attacks: 5,
          wounds: 4,
          resolve: 4,
          defense: 2,
          evasion: 1),
      specialRules: const [],
      numericSpecialRules: const {},
      supremacyAbilities: const [],
      drawEvents: const [],
      points: 200,
    ),
    'light unit': Unit(
      name: 'Light Unit',
      faction: 'Test Faction',
      type: 'infantry',
      regimentClass: 'light',
      characteristics: const UnitCharacteristics(
          march: 6,
          volley: 2,
          clash: 2,
          attacks: 4,
          wounds: 4,
          resolve: 2,
          defense: 1,
          evasion: 1),
      specialRules: const [],
      numericSpecialRules: const {},
      supremacyAbilities: const [],
      drawEvents: const [],
      points: 120,
      pointsPerAdditionalStand: 40,
    ),
    'medium unit': Unit(
      name: 'Medium Unit',
      faction: 'Test Faction',
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
          evasion: 1),
      specialRules: const [],
      numericSpecialRules: const {},
      supremacyAbilities: const [],
      drawEvents: const [],
      points: 160,
    ),
    'heavy unit': Unit(
      name: 'Heavy Unit',
      faction: 'Test Faction',
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
          evasion: 1),
      specialRules: const [],
      numericSpecialRules: const {},
      supremacyAbilities: const [],
      drawEvents: const [],
      points: 200,
    ),
    'unit with (parentheses) in name': Unit(
      name: 'Unit With (Parentheses) In Name',
      faction: 'Test Faction',
      type: 'infantry',
      regimentClass: 'medium',
      characteristics: const UnitCharacteristics(
          march: 5,
          volley: 2,
          clash: 3,
          attacks: 4,
          wounds: 5,
          resolve: 3,
          defense: 2,
          evasion: 1),
      specialRules: const [],
      numericSpecialRules: const {},
      supremacyAbilities: const [],
      drawEvents: const [],
      points: 150,
    ),
    'another unit': Unit(
      name: 'Another Unit',
      faction: 'Test Faction',
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
          evasion: 1),
      specialRules: const [],
      numericSpecialRules: const {},
      supremacyAbilities: const [],
      drawEvents: const [],
      points: 150,
      pointsPerAdditionalStand: 50,
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
  List<String> get availableFactions =>
      ['Nords', 'The Spires', 'The Hundred Kingdoms', 'Test Faction'];

  @override
  bool get isLoaded => true;
}
