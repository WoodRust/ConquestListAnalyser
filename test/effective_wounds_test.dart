import 'package:flutter_test/flutter_test.dart';
import 'package:conquest_analyzer/services/scoring_engine.dart';
import 'package:conquest_analyzer/models/army_list.dart';
import 'package:conquest_analyzer/models/regiment.dart';
import 'package:conquest_analyzer/models/unit.dart';

void main() {
  group('Effective Wounds Tests', () {
    late ScoringEngine scoringEngine;
    late Unit lowDefenseUnit;
    late Unit mediumDefenseUnit;
    late Unit highEvasionUnit;
    late Unit perfectDefenseUnit;

    setUp(() {
      scoringEngine = ScoringEngine();

      // Unit with very low defense (1)
      lowDefenseUnit = Unit(
        name: 'Low Defense Unit',
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

      // Unit with medium defense (3)
      mediumDefenseUnit = Unit(
        name: 'Medium Defense Unit',
        faction: 'Test',
        type: 'infantry',
        regimentClass: 'medium',
        characteristics: const UnitCharacteristics(
          march: 5,
          volley: 2,
          clash: 3,
          attacks: 4,
          wounds: 5,
          resolve: 3,
          defense: 3,
          evasion: 2,
        ),
        specialRules: const [],
        numericSpecialRules: const {},
        supremacyAbilities: const [],
        drawEvents: const [],
        points: 160,
      );

      // Unit with high evasion (4) but low defense (1)
      highEvasionUnit = Unit(
        name: 'High Evasion Unit',
        faction: 'Test',
        type: 'cavalry',
        regimentClass: 'light',
        characteristics: const UnitCharacteristics(
          march: 8,
          volley: 1,
          clash: 2,
          attacks: 4,
          wounds: 4,
          resolve: 2,
          defense: 1,
          evasion: 4,
        ),
        specialRules: const [],
        numericSpecialRules: const {},
        supremacyAbilities: const [],
        drawEvents: const [],
        points: 150,
      );

      // Unit with perfect defense (5)
      perfectDefenseUnit = Unit(
        name: 'Perfect Defense Unit',
        faction: 'Test',
        type: 'monster',
        regimentClass: 'heavy',
        characteristics: const UnitCharacteristics(
          march: 4,
          volley: 0,
          clash: 5,
          attacks: 6,
          wounds: 8,
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
    });

    test('should calculate effective wounds for single regiment', () {
      final regiments = [
        Regiment(unit: lowDefenseUnit, stands: 1, pointsCost: 120),
      ];
      final armyList = ArmyList(
        name: 'Single Regiment Army',
        faction: 'Test',
        totalPoints: 120,
        pointsLimit: 2000,
        regiments: regiments,
      );
      final score = scoringEngine.calculateScores(armyList);

      // Low defense unit: 4 wounds × (6/(6-1)) = 4 × 1.2 = 4.8
      expect(score.effectiveWoundsDefense, equals(4.8));
    });

    test('should use higher of defense or evasion', () {
      final regiments = [
        Regiment(unit: highEvasionUnit, stands: 1, pointsCost: 150),
      ];
      final armyList = ArmyList(
        name: 'High Evasion Army',
        faction: 'Test',
        totalPoints: 150,
        pointsLimit: 2000,
        regiments: regiments,
      );
      final score = scoringEngine.calculateScores(armyList);

      // High evasion unit: 4 wounds × (6/(6-4)) = 4 × 3.0 = 12.0
      expect(score.effectiveWoundsDefense, equals(12.0));
    });

    test('should handle perfect defense without division by zero', () {
      final regiments = [
        Regiment(unit: perfectDefenseUnit, stands: 1, pointsCost: 400),
      ];
      final armyList = ArmyList(
        name: 'Perfect Defense Army',
        faction: 'Test',
        totalPoints: 400,
        pointsLimit: 2000,
        regiments: regiments,
      );
      final score = scoringEngine.calculateScores(armyList);

      // Perfect defense unit: 8 wounds × (6/(6-5)) = 8 × 6.0 = 48.0
      expect(score.effectiveWoundsDefense, equals(48.0));
    });

    test('should handle empty army list', () {
      final armyList = ArmyList(
        name: 'Empty Army',
        faction: 'Test',
        totalPoints: 0,
        pointsLimit: 2000,
        regiments: const [],
      );
      final score = scoringEngine.calculateScores(armyList);
      expect(score.effectiveWoundsDefense, equals(0.0));
    });

    test('should handle multiple regiments with different defensive profiles',
        () {
      final regiments = [
        Regiment(
            unit: lowDefenseUnit,
            stands: 3,
            pointsCost: 240), // 12 wounds, defense 1
        Regiment(
            unit: mediumDefenseUnit,
            stands: 1,
            pointsCost: 160), // 5 wounds, defense 3
        Regiment(
            unit: highEvasionUnit,
            stands: 2,
            pointsCost: 240), // 8 wounds, evasion 4
      ];
      final armyList = ArmyList(
        name: 'Complex Army',
        faction: 'Test',
        totalPoints: 640,
        pointsLimit: 2000,
        regiments: regiments,
      );
      final score = scoringEngine.calculateScores(armyList);

      // Low defense: 12 wounds × (6/(6-1)) = 12 × 1.2 = 14.4
      // Medium defense: 5 wounds × (6/(6-3)) = 5 × 2.0 = 10.0
      // High evasion: 8 wounds × (6/(6-4)) = 8 × 3.0 = 24.0
      // Total effective wounds = 14.4 + 10.0 + 24.0 = 48.4
      expect(score.effectiveWoundsDefense, equals(48.4));
    });

    test('should include effective wounds in shareable text format', () {
      final regiments = [
        Regiment(unit: mediumDefenseUnit, stands: 2, pointsCost: 200),
        Regiment(unit: highEvasionUnit, stands: 1, pointsCost: 150),
      ];
      final armyList = ArmyList(
        name: 'Effective Wounds Test Army',
        faction: 'Test',
        totalPoints: 350,
        pointsLimit: 2000,
        regiments: regiments,
      );
      final score = scoringEngine.calculateScores(armyList);
      final shareableText = score.toShareableText();

      expect(shareableText,
          contains('Army List Analysis: Effective Wounds Test Army'));
      expect(shareableText, contains('Effective Wounds'));
      expect(shareableText, contains('Calculated:'));
    });

    test('should handle armies with same defensive values', () {
      final regiments = [
        Regiment(
            unit: mediumDefenseUnit,
            stands: 1,
            pointsCost: 160), // 5 wounds, defense 3
        Regiment(
            unit: mediumDefenseUnit,
            stands: 2,
            pointsCost: 250), // 10 wounds, defense 3
      ];
      final armyList = ArmyList(
        name: 'Uniform Defense Army',
        faction: 'Test',
        totalPoints: 410,
        pointsLimit: 2000,
        regiments: regiments,
      );
      final score = scoringEngine.calculateScores(armyList);

      // Both regiments have defense 3
      // Total wounds: 5 + 10 = 15
      // Effective wounds: 15 × (6/(6-3)) = 15 × 2.0 = 30.0
      expect(score.effectiveWoundsDefense, equals(30.0));
    });

    test('should handle very large armies correctly', () {
      final regiments = <Regiment>[];

      // Create a large army with mixed defensive values
      for (int i = 0; i < 20; i++) {
        regiments
            .add(Regiment(unit: lowDefenseUnit, stands: 1, pointsCost: 120));
      }
      for (int i = 0; i < 15; i++) {
        regiments
            .add(Regiment(unit: mediumDefenseUnit, stands: 1, pointsCost: 160));
      }
      for (int i = 0; i < 10; i++) {
        regiments
            .add(Regiment(unit: highEvasionUnit, stands: 1, pointsCost: 150));
      }

      final armyList = ArmyList(
        name: 'Large Army',
        faction: 'Test',
        totalPoints: 8300,
        pointsLimit: 10000,
        regiments: regiments,
      );
      final score = scoringEngine.calculateScores(armyList);

      // 20 × (4 wounds × 1.2) = 20 × 4.8 = 96.0
      // 15 × (5 wounds × 2.0) = 15 × 10.0 = 150.0
      // 10 × (4 wounds × 3.0) = 10 × 12.0 = 120.0
      // Total: 96.0 + 150.0 + 120.0 = 366.0
      expect(score.effectiveWoundsDefense, equals(366.0));
      expect(score.effectiveWoundsDefense, greaterThan(0.0));
    });

    test('should exclude regular characters from effective wounds calculation',
        () {
      // Create a character unit
      final characterUnit = Unit(
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
      );

      final regiments = [
        Regiment(
            unit: characterUnit,
            stands: 1,
            pointsCost: 150), // Should be excluded
        Regiment(
            unit: mediumDefenseUnit,
            stands: 1,
            pointsCost: 160), // Should be included
      ];
      final armyList = ArmyList(
        name: 'Character Test Army',
        faction: 'Test',
        totalPoints: 310,
        pointsLimit: 2000,
        regiments: regiments,
      );
      final score = scoringEngine.calculateScores(armyList);

      // Only the medium defense unit should contribute
      // 5 wounds × (6/(6-3)) = 5 × 2.0 = 10.0
      expect(score.effectiveWoundsDefense, equals(10.0));
    });

    test('should include character monsters in effective wounds calculation',
        () {
      // Create a character monster unit
      final characterMonsterUnit = Unit(
        name: 'Dragon Lord',
        faction: 'Test',
        type: 'monster',
        regimentClass: 'character',
        characteristics: const UnitCharacteristics(
          march: 8,
          volley: 4,
          clash: 5,
          attacks: 8,
          wounds: 8,
          resolve: 5,
          defense: 4,
          evasion: 2,
        ),
        specialRules: const [],
        numericSpecialRules: const {},
        supremacyAbilities: const [],
        drawEvents: const [],
        points: 400,
      );

      final regiments = [
        Regiment(
            unit: characterMonsterUnit,
            stands: 1,
            pointsCost: 400), // Should be included
        Regiment(
            unit: mediumDefenseUnit,
            stands: 1,
            pointsCost: 160), // Should be included
      ];
      final armyList = ArmyList(
        name: 'Character Monster Test Army',
        faction: 'Test',
        totalPoints: 560,
        pointsLimit: 2000,
        regiments: regiments,
      );
      final score = scoringEngine.calculateScores(armyList);

      // Character monster: 8 wounds × (6/(6-4)) = 8 × 3.0 = 24.0
      // Medium defense unit: 5 wounds × (6/(6-3)) = 5 × 2.0 = 10.0
      // Total: 24.0 + 10.0 = 34.0
      expect(score.effectiveWoundsDefense, equals(34.0));
    });
  });
}
