import 'package:flutter_test/flutter_test.dart';
import 'package:conquest_analyzer/models/army_list.dart';
import 'package:conquest_analyzer/models/regiment.dart';
import 'package:conquest_analyzer/models/unit.dart';
import 'package:conquest_analyzer/services/scoring_engine.dart';

void main() {
  late ScoringEngine scoringEngine;

  setUp(() {
    scoringEngine = ScoringEngine();
  });

  group('Scoring Stands - Monster Tests', () {
    test('Monster with scoringStands override (Jotnar Seidr = 6)', () {
      final unit = Unit(
        name: 'Jotnar Seidr',
        faction: 'Nords',
        type: 'monster',
        regimentClass: 'character',
        characteristics: UnitCharacteristics(
          march: 7,
          volley: 2,
          clash: 3,
          attacks: 12,
          wounds: 20,
          resolve: 4,
          defense: 3,
          evasion: 2,
        ),
        specialRules: const [],
        numericSpecialRules: const {'scoringStands': 6},
        supremacyAbilities: const [],
        drawEvents: const [],
        points: 260,
      );

      final regiment = Regiment(unit: unit, stands: 1, pointsCost: 260);
      final armyList = ArmyList(
        name: 'Test',
        faction: 'Nords',
        totalPoints: 260,
        pointsLimit: 2000,
        regiments: [regiment],
      );

      final score = scoringEngine.calculateScores(armyList);
      expect(score.scoringStands, equals(6),
          reason: 'Jotnar Seidr should count as 6 scoring stands');
    });

    test('Monster without scoringStands (Mountain Jotnar = 3 default)', () {
      final unit = Unit(
        name: 'Mountain Jotnar',
        faction: 'Nords',
        type: 'monster',
        regimentClass: 'medium',
        characteristics: UnitCharacteristics(
          march: 7,
          volley: 1,
          clash: 3,
          attacks: 12,
          wounds: 18,
          resolve: 3,
          defense: 3,
          evasion: 0,
        ),
        specialRules: const [],
        numericSpecialRules: const {},
        supremacyAbilities: const [],
        drawEvents: const [],
        points: 210,
      );

      final regiment = Regiment(unit: unit, stands: 1, pointsCost: 210);
      final armyList = ArmyList(
        name: 'Test',
        faction: 'Nords',
        totalPoints: 210,
        pointsLimit: 2000,
        regiments: [regiment],
      );

      final score = scoringEngine.calculateScores(armyList);
      expect(score.scoringStands, equals(3),
          reason: 'Mountain Jotnar should default to 3 scoring stands');
    });

    test('Character monster uses monster rules not character rules', () {
      final jotnarSeidr = Unit(
        name: 'Jotnar Seidr',
        faction: 'Nords',
        type: 'monster',
        regimentClass: 'character',
        characteristics: UnitCharacteristics(
          march: 7,
          volley: 2,
          clash: 3,
          attacks: 12,
          wounds: 20,
          resolve: 4,
          defense: 3,
          evasion: 2,
        ),
        specialRules: const [],
        numericSpecialRules: const {'scoringStands': 6},
        supremacyAbilities: const [],
        drawEvents: const [],
        points: 260,
      );

      final regiment = Regiment(unit: jotnarSeidr, stands: 1, pointsCost: 260);
      final armyList = ArmyList(
        name: 'Test',
        faction: 'Nords',
        totalPoints: 260,
        pointsLimit: 2000,
        regiments: [regiment],
      );

      final score = scoringEngine.calculateScores(armyList);
      expect(score.scoringStands, equals(6),
          reason:
              'Character monster should use monster scoring (6), not character scoring (1)');
    });
  });

  group('Scoring Stands - Regiment Class Tests', () {
    test('Light regiment does not score (0 stands)', () {
      final unit = Unit(
        name: 'Raiders',
        faction: 'Nords',
        type: 'infantry',
        regimentClass: 'light',
        characteristics: UnitCharacteristics(
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
      );

      final regiment = Regiment(unit: unit, stands: 3, pointsCost: 200);
      final armyList = ArmyList(
        name: 'Test',
        faction: 'Nords',
        totalPoints: 200,
        pointsLimit: 2000,
        regiments: [regiment],
      );

      final score = scoringEngine.calculateScores(armyList);
      expect(score.scoringStands, equals(0),
          reason: 'Light regiments should not contribute to scoring stands');
    });

    test('Medium regiment counts each stand', () {
      final unit = Unit(
        name: 'Huskarls',
        faction: 'Nords',
        type: 'infantry',
        regimentClass: 'medium',
        characteristics: UnitCharacteristics(
          march: 6,
          volley: 1,
          clash: 3,
          attacks: 5,
          wounds: 4,
          resolve: 3,
          defense: 2,
          evasion: 0,
        ),
        specialRules: const [],
        numericSpecialRules: const {},
        supremacyAbilities: const [],
        drawEvents: const [],
        points: 150,
        pointsPerAdditionalStand: 50,
      );

      final regiment = Regiment(unit: unit, stands: 4, pointsCost: 300);
      final armyList = ArmyList(
        name: 'Test',
        faction: 'Nords',
        totalPoints: 300,
        pointsLimit: 2000,
        regiments: [regiment],
      );

      final score = scoringEngine.calculateScores(armyList);
      expect(score.scoringStands, equals(4),
          reason: 'Medium regiment with 4 stands should count as 4 scoring stands');
    });

    test('Heavy regiment counts each stand', () {
      final unit = Unit(
        name: 'Bearsarks',
        faction: 'Nords',
        type: 'infantry',
        regimentClass: 'heavy',
        characteristics: UnitCharacteristics(
          march: 6,
          volley: 1,
          clash: 3,
          attacks: 5,
          wounds: 4,
          resolve: 4,
          defense: 2,
          evasion: 1,
        ),
        specialRules: const [],
        numericSpecialRules: const {},
        supremacyAbilities: const [],
        drawEvents: const [],
        points: 170,
        pointsPerAdditionalStand: 60,
      );

      final regiment = Regiment(unit: unit, stands: 3, pointsCost: 290);
      final armyList = ArmyList(
        name: 'Test',
        faction: 'Nords',
        totalPoints: 290,
        pointsLimit: 2000,
        regiments: [regiment],
      );

      final score = scoringEngine.calculateScores(armyList);
      expect(score.scoringStands, equals(3),
          reason: 'Heavy regiment with 3 stands should count as 3 scoring stands');
    });
  });

  group('Scoring Stands - Character Tests', () {
    test('Character connected to medium regiment counts as 1', () {
      final character = Unit(
        name: 'Jarl',
        faction: 'Nords',
        type: 'infantry',
        regimentClass: 'character',
        characteristics: UnitCharacteristics(
          march: null,
          volley: 2,
          clash: 3,
          attacks: 6,
          wounds: 4,
          resolve: 3,
          defense: 2,
          evasion: 0,
        ),
        specialRules: const [],
        numericSpecialRules: const {},
        supremacyAbilities: const [],
        drawEvents: const [],
        points: 100,
      );

      final mediumUnit = Unit(
        name: 'Huskarls',
        faction: 'Nords',
        type: 'infantry',
        regimentClass: 'medium',
        characteristics: UnitCharacteristics(
          march: 6,
          volley: 1,
          clash: 3,
          attacks: 5,
          wounds: 4,
          resolve: 3,
          defense: 2,
          evasion: 0,
        ),
        specialRules: const [],
        numericSpecialRules: const {},
        supremacyAbilities: const [],
        drawEvents: const [],
        points: 150,
        pointsPerAdditionalStand: 50,
      );

      final characterRegiment =
          Regiment(unit: character, stands: 1, pointsCost: 100);
      final mediumRegiment =
          Regiment(unit: mediumUnit, stands: 3, pointsCost: 250);
      final armyList = ArmyList(
        name: 'Test',
        faction: 'Nords',
        totalPoints: 350,
        pointsLimit: 2000,
        regiments: [characterRegiment, mediumRegiment],
      );

      final score = scoringEngine.calculateScores(armyList);
      expect(score.scoringStands, equals(4),
          reason:
              'Character (1) + medium regiment (3 stands) should total 4 scoring stands');
    });

    test('Character connected to light regiment counts as 0', () {
      final character = Unit(
        name: 'Jarl',
        faction: 'Nords',
        type: 'infantry',
        regimentClass: 'character',
        characteristics: UnitCharacteristics(
          march: null,
          volley: 2,
          clash: 3,
          attacks: 6,
          wounds: 4,
          resolve: 3,
          defense: 2,
          evasion: 0,
        ),
        specialRules: const [],
        numericSpecialRules: const {},
        supremacyAbilities: const [],
        drawEvents: const [],
        points: 100,
      );

      final lightUnit = Unit(
        name: 'Raiders',
        faction: 'Nords',
        type: 'infantry',
        regimentClass: 'light',
        characteristics: UnitCharacteristics(
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
      );

      final characterRegiment =
          Regiment(unit: character, stands: 1, pointsCost: 100);
      final lightRegiment = Regiment(unit: lightUnit, stands: 3, pointsCost: 200);
      final armyList = ArmyList(
        name: 'Test',
        faction: 'Nords',
        totalPoints: 300,
        pointsLimit: 2000,
        regiments: [characterRegiment, lightRegiment],
      );

      final score = scoringEngine.calculateScores(armyList);
      expect(score.scoringStands, equals(0),
          reason:
              'Character connected to light regiment should count as 0 (light = 0 too)');
    });

    test('Character with no warband counts as 1', () {
      final character = Unit(
        name: 'Jarl',
        faction: 'Nords',
        type: 'infantry',
        regimentClass: 'character',
        characteristics: UnitCharacteristics(
          march: null,
          volley: 2,
          clash: 3,
          attacks: 6,
          wounds: 4,
          resolve: 3,
          defense: 2,
          evasion: 0,
        ),
        specialRules: const [],
        numericSpecialRules: const {},
        supremacyAbilities: const [],
        drawEvents: const [],
        points: 100,
      );

      final characterRegiment =
          Regiment(unit: character, stands: 1, pointsCost: 100);
      final armyList = ArmyList(
        name: 'Test',
        faction: 'Nords',
        totalPoints: 100,
        pointsLimit: 2000,
        regiments: [characterRegiment],
      );

      final score = scoringEngine.calculateScores(armyList);
      expect(score.scoringStands, equals(1),
          reason: 'Character with no warband should count as 1 scoring stand');
    });

    test('Character connected to heavy regiment (priority over medium)', () {
      final character = Unit(
        name: 'Jarl',
        faction: 'Nords',
        type: 'infantry',
        regimentClass: 'character',
        characteristics: UnitCharacteristics(
          march: null,
          volley: 2,
          clash: 3,
          attacks: 6,
          wounds: 4,
          resolve: 3,
          defense: 2,
          evasion: 0,
        ),
        specialRules: const [],
        numericSpecialRules: const {},
        supremacyAbilities: const [],
        drawEvents: const [],
        points: 100,
      );

      final mediumUnit = Unit(
        name: 'Huskarls',
        faction: 'Nords',
        type: 'infantry',
        regimentClass: 'medium',
        characteristics: UnitCharacteristics(
          march: 6,
          volley: 1,
          clash: 3,
          attacks: 5,
          wounds: 4,
          resolve: 3,
          defense: 2,
          evasion: 0,
        ),
        specialRules: const [],
        numericSpecialRules: const {},
        supremacyAbilities: const [],
        drawEvents: const [],
        points: 150,
        pointsPerAdditionalStand: 50,
      );

      final heavyUnit = Unit(
        name: 'Bearsarks',
        faction: 'Nords',
        type: 'infantry',
        regimentClass: 'heavy',
        characteristics: UnitCharacteristics(
          march: 6,
          volley: 1,
          clash: 3,
          attacks: 5,
          wounds: 4,
          resolve: 4,
          defense: 2,
          evasion: 1,
        ),
        specialRules: const [],
        numericSpecialRules: const {},
        supremacyAbilities: const [],
        drawEvents: const [],
        points: 170,
        pointsPerAdditionalStand: 60,
      );

      final characterRegiment =
          Regiment(unit: character, stands: 1, pointsCost: 100);
      final mediumRegiment =
          Regiment(unit: mediumUnit, stands: 3, pointsCost: 250);
      final heavyRegiment =
          Regiment(unit: heavyUnit, stands: 2, pointsCost: 230);
      final armyList = ArmyList(
        name: 'Test',
        faction: 'Nords',
        totalPoints: 580,
        pointsLimit: 2000,
        regiments: [characterRegiment, mediumRegiment, heavyRegiment],
      );

      final score = scoringEngine.calculateScores(armyList);
      expect(score.scoringStands, equals(6),
          reason:
              'Character (1) connects to heavy (2) not medium (3), total = 6 stands');
    });
  });

  group('Scoring Stands - Edge Cases', () {
    test('Warband with only lights and monsters forces character to light', () {
      final character = Unit(
        name: 'Jarl',
        faction: 'Nords',
        type: 'infantry',
        regimentClass: 'character',
        characteristics: UnitCharacteristics(
          march: null,
          volley: 2,
          clash: 3,
          attacks: 6,
          wounds: 4,
          resolve: 3,
          defense: 2,
          evasion: 0,
        ),
        specialRules: const [],
        numericSpecialRules: const {},
        supremacyAbilities: const [],
        drawEvents: const [],
        points: 100,
      );

      final lightUnit = Unit(
        name: 'Raiders',
        faction: 'Nords',
        type: 'infantry',
        regimentClass: 'light',
        characteristics: UnitCharacteristics(
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
      );

      final monsterUnit = Unit(
        name: 'Mountain Jotnar',
        faction: 'Nords',
        type: 'monster',
        regimentClass: 'medium',
        characteristics: UnitCharacteristics(
          march: 7,
          volley: 1,
          clash: 3,
          attacks: 12,
          wounds: 18,
          resolve: 3,
          defense: 3,
          evasion: 0,
        ),
        specialRules: const [],
        numericSpecialRules: const {},
        supremacyAbilities: const [],
        drawEvents: const [],
        points: 210,
      );

      final characterRegiment =
          Regiment(unit: character, stands: 1, pointsCost: 100);
      final lightRegiment = Regiment(unit: lightUnit, stands: 3, pointsCost: 200);
      final monsterRegiment =
          Regiment(unit: monsterUnit, stands: 1, pointsCost: 210);
      final armyList = ArmyList(
        name: 'Test',
        faction: 'Nords',
        totalPoints: 510,
        pointsLimit: 2000,
        regiments: [characterRegiment, lightRegiment, monsterRegiment],
      );

      final score = scoringEngine.calculateScores(armyList);
      expect(score.scoringStands, equals(3),
          reason:
              'Character must connect to light (0) since monster ineligible, total = monster (3) only');
    });

    test('Multiple regiments of same class', () {
      final mediumUnit = Unit(
        name: 'Huskarls',
        faction: 'Nords',
        type: 'infantry',
        regimentClass: 'medium',
        characteristics: UnitCharacteristics(
          march: 6,
          volley: 1,
          clash: 3,
          attacks: 5,
          wounds: 4,
          resolve: 3,
          defense: 2,
          evasion: 0,
        ),
        specialRules: const [],
        numericSpecialRules: const {},
        supremacyAbilities: const [],
        drawEvents: const [],
        points: 150,
        pointsPerAdditionalStand: 50,
      );

      final regiment1 = Regiment(unit: mediumUnit, stands: 3, pointsCost: 250);
      final regiment2 = Regiment(unit: mediumUnit, stands: 4, pointsCost: 300);
      final regiment3 = Regiment(unit: mediumUnit, stands: 2, pointsCost: 200);
      final armyList = ArmyList(
        name: 'Test',
        faction: 'Nords',
        totalPoints: 750,
        pointsLimit: 2000,
        regiments: [regiment1, regiment2, regiment3],
      );

      final score = scoringEngine.calculateScores(armyList);
      expect(score.scoringStands, equals(9),
          reason: '3 medium regiments (3+4+2 stands) should total 9 scoring stands');
    });

    test('Complex army with all unit types', () {
      final character = Unit(
        name: 'Jarl',
        faction: 'Nords',
        type: 'infantry',
        regimentClass: 'character',
        characteristics: UnitCharacteristics(
          march: null,
          volley: 2,
          clash: 3,
          attacks: 6,
          wounds: 4,
          resolve: 3,
          defense: 2,
          evasion: 0,
        ),
        specialRules: const [],
        numericSpecialRules: const {},
        supremacyAbilities: const [],
        drawEvents: const [],
        points: 100,
      );

      final lightUnit = Unit(
        name: 'Raiders',
        faction: 'Nords',
        type: 'infantry',
        regimentClass: 'light',
        characteristics: UnitCharacteristics(
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
      );

      final mediumUnit = Unit(
        name: 'Huskarls',
        faction: 'Nords',
        type: 'infantry',
        regimentClass: 'medium',
        characteristics: UnitCharacteristics(
          march: 6,
          volley: 1,
          clash: 3,
          attacks: 5,
          wounds: 4,
          resolve: 3,
          defense: 2,
          evasion: 0,
        ),
        specialRules: const [],
        numericSpecialRules: const {},
        supremacyAbilities: const [],
        drawEvents: const [],
        points: 150,
        pointsPerAdditionalStand: 50,
      );

      final heavyUnit = Unit(
        name: 'Bearsarks',
        faction: 'Nords',
        type: 'infantry',
        regimentClass: 'heavy',
        characteristics: UnitCharacteristics(
          march: 6,
          volley: 1,
          clash: 3,
          attacks: 5,
          wounds: 4,
          resolve: 4,
          defense: 2,
          evasion: 1,
        ),
        specialRules: const [],
        numericSpecialRules: const {},
        supremacyAbilities: const [],
        drawEvents: const [],
        points: 170,
        pointsPerAdditionalStand: 60,
      );

      final monsterUnit = Unit(
        name: 'Mountain Jotnar',
        faction: 'Nords',
        type: 'monster',
        regimentClass: 'medium',
        characteristics: UnitCharacteristics(
          march: 7,
          volley: 1,
          clash: 3,
          attacks: 12,
          wounds: 18,
          resolve: 3,
          defense: 3,
          evasion: 0,
        ),
        specialRules: const [],
        numericSpecialRules: const {},
        supremacyAbilities: const [],
        drawEvents: const [],
        points: 210,
      );

      final characterRegiment =
          Regiment(unit: character, stands: 1, pointsCost: 100);
      final lightRegiment = Regiment(unit: lightUnit, stands: 3, pointsCost: 200);
      final mediumRegiment =
          Regiment(unit: mediumUnit, stands: 4, pointsCost: 300);
      final heavyRegiment =
          Regiment(unit: heavyUnit, stands: 2, pointsCost: 230);
      final monsterRegiment =
          Regiment(unit: monsterUnit, stands: 1, pointsCost: 210);
      final armyList = ArmyList(
        name: 'Test',
        faction: 'Nords',
        totalPoints: 1040,
        pointsLimit: 2000,
        regiments: [
          characterRegiment,
          lightRegiment,
          mediumRegiment,
          heavyRegiment,
          monsterRegiment
        ],
      );

      final score = scoringEngine.calculateScores(armyList);
      // Character connects to heavy (1) + light (0) + medium (4) + heavy (2) + monster (3) = 10
      expect(score.scoringStands, equals(10),
          reason:
              'Character (1 - connects to heavy) + light (0) + medium (4) + heavy (2) + monster (3) = 10 stands');
    });
  });
}
