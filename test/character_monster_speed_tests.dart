import 'package:flutter_test/flutter_test.dart';
import 'package:conquest_analyzer/services/scoring_engine.dart';
import 'package:conquest_analyzer/models/army_list.dart';
import 'package:conquest_analyzer/models/regiment.dart';
import 'package:conquest_analyzer/models/unit.dart';

void main() {
  group('Character Monster Speed Tests', () {
    late ScoringEngine scoringEngine;
    late Unit regularCharacterUnit;
    late Unit characterMonsterUnit;
    late Unit regularRegimentUnit;
    late Unit fastCharacterMonsterUnit;
    late Unit slowCharacterMonsterUnit;

    setUp(() {
      scoringEngine = ScoringEngine();

      // Regular character (should be excluded from speed)
      regularCharacterUnit = Unit(
        name: 'Regular Character',
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

      // Character monster (should be included in speed)
      characterMonsterUnit = Unit(
        name: 'Dragon Lord',
        faction: 'Test',
        type: 'monster',
        regimentClass: 'character',
        characteristics: const UnitCharacteristics(
          march: 10, // Fast movement
          volley: 4,
          clash: 5,
          attacks: 8,
          wounds: 8,
          resolve: 5,
          defense: 4,
          evasion: 2,
        ),
        specialRules: const [],
        numericSpecialRules: const {'cleave': 3},
        supremacyAbilities: const [],
        drawEvents: const [],
        points: 400,
      );

      // Regular regiment (should be included in speed)
      regularRegimentUnit = Unit(
        name: 'Infantry Regiment',
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
      );

      // Fast character monster
      fastCharacterMonsterUnit = Unit(
        name: 'Flying Dragon',
        faction: 'Test',
        type: 'monster',
        regimentClass: 'character',
        characteristics: const UnitCharacteristics(
          march: 12, // Very fast
          volley: 3,
          clash: 4,
          attacks: 6,
          wounds: 6,
          resolve: 4,
          defense: 3,
          evasion: 3,
        ),
        specialRules: const [],
        numericSpecialRules: const {},
        supremacyAbilities: const [],
        drawEvents: const [],
        points: 350,
      );

      // Slow character monster
      slowCharacterMonsterUnit = Unit(
        name: 'Ancient Turtle',
        faction: 'Test',
        type: 'monster',
        regimentClass: 'character',
        characteristics: const UnitCharacteristics(
          march: 3, // Very slow
          volley: 1,
          clash: 5,
          attacks: 4,
          wounds: 12,
          resolve: 6,
          defense: 5,
          evasion: 1,
        ),
        specialRules: const [],
        numericSpecialRules: const {},
        supremacyAbilities: const [],
        drawEvents: const [],
        points: 450,
      );
    });

    test('should include character monster in speed calculation', () {
      final regiments = [
        Regiment(
            unit: regularCharacterUnit,
            stands: 1,
            pointsCost: 150), // March 8, excluded
        Regiment(
            unit: characterMonsterUnit,
            stands: 1,
            pointsCost: 400), // March 10, included
        Regiment(
            unit: regularRegimentUnit,
            stands: 1,
            pointsCost: 160), // March 5, included
      ];

      final armyList = ArmyList(
        name: 'Character Monster Speed Test',
        faction: 'Test',
        totalPoints: 710,
        pointsLimit: 2000,
        regiments: regiments,
      );

      final score = scoringEngine.calculateScores(armyList);

      // Speed calculation should include character monster and regular regiment
      // Average of: 10 (character monster) + 5 (regular regiment) = 15 / 2 = 7.5
      expect(score.averageSpeed, equals(7.5));
    });

    test('should exclude regular characters but include character monsters',
        () {
      final regiments = [
        Regiment(
            unit: regularCharacterUnit,
            stands: 1,
            pointsCost: 150), // March 8, excluded
        Regiment(
            unit: fastCharacterMonsterUnit,
            stands: 1,
            pointsCost: 350), // March 12, included
        Regiment(
            unit: slowCharacterMonsterUnit,
            stands: 1,
            pointsCost: 450), // March 3, included
        Regiment(
            unit: regularRegimentUnit,
            stands: 1,
            pointsCost: 160), // March 5, included
      ];

      final armyList = ArmyList(
        name: 'Mixed Speed Test',
        faction: 'Test',
        totalPoints: 1110,
        pointsLimit: 2000,
        regiments: regiments,
      );

      final score = scoringEngine.calculateScores(armyList);

      // Speed calculation should exclude regular character
      // Average of: 12 (fast monster) + 3 (slow monster) + 5 (regiment) = 20 / 3 ≈ 6.67
      expect(score.averageSpeed, closeTo(6.67, 0.01));
    });

    test('should handle army with only character monsters for speed', () {
      final regiments = [
        Regiment(
            unit: fastCharacterMonsterUnit,
            stands: 1,
            pointsCost: 350), // March 12
        Regiment(
            unit: slowCharacterMonsterUnit,
            stands: 1,
            pointsCost: 450), // March 3
      ];

      final armyList = ArmyList(
        name: 'Character Monster Only Speed',
        faction: 'Test',
        totalPoints: 800,
        pointsLimit: 2000,
        regiments: regiments,
      );

      final score = scoringEngine.calculateScores(armyList);

      // Average of: 12 (fast monster) + 3 (slow monster) = 15 / 2 = 7.5
      expect(score.averageSpeed, equals(7.5));
    });

    test('should handle army with only regular characters for speed', () {
      final regiments = [
        Regiment(unit: regularCharacterUnit, stands: 1, pointsCost: 150),
      ];

      final armyList = ArmyList(
        name: 'Regular Character Only Speed',
        faction: 'Test',
        totalPoints: 150,
        pointsLimit: 2000,
        regiments: regiments,
      );

      final score = scoringEngine.calculateScores(armyList);

      // No units included in speed calculation
      expect(score.averageSpeed, equals(0.0));
    });

    test('should handle character monster with null march value', () {
      final immobileCharacterMonster = Unit(
        name: 'Immobile Ancient',
        faction: 'Test',
        type: 'monster',
        regimentClass: 'character',
        characteristics: const UnitCharacteristics(
          march: null, // Immobile
          volley: 5,
          clash: 2,
          attacks: 2,
          wounds: 15,
          resolve: 6,
          defense: 6,
          evasion: 1,
        ),
        specialRules: const [],
        numericSpecialRules: const {},
        supremacyAbilities: const [],
        drawEvents: const [],
        points: 500,
      );

      final regiments = [
        Regiment(
            unit: immobileCharacterMonster,
            stands: 1,
            pointsCost: 500), // March null (0)
        Regiment(
            unit: regularRegimentUnit, stands: 1, pointsCost: 160), // March 5
      ];

      final armyList = ArmyList(
        name: 'Immobile Character Monster Test',
        faction: 'Test',
        totalPoints: 660,
        pointsLimit: 2000,
        regiments: regiments,
      );

      final score = scoringEngine.calculateScores(armyList);

      // Average of: 0 (immobile monster) + 5 (regiment) = 5 / 2 = 2.5
      expect(score.averageSpeed, equals(2.5));
    });

    test('should handle complex army with multiple character monster types',
        () {
      final regiments = [
        Regiment(
            unit: regularCharacterUnit,
            stands: 1,
            pointsCost: 150), // March 8, excluded
        Regiment(
            unit: fastCharacterMonsterUnit,
            stands: 1,
            pointsCost: 350), // March 12, included
        Regiment(
            unit: characterMonsterUnit,
            stands: 1,
            pointsCost: 400), // March 10, included
        Regiment(
            unit: slowCharacterMonsterUnit,
            stands: 1,
            pointsCost: 450), // March 3, included
        Regiment(
            unit: regularRegimentUnit,
            stands: 2,
            pointsCost: 260), // March 5, included
      ];

      final armyList = ArmyList(
        name: 'Complex Character Monster Army',
        faction: 'Test',
        totalPoints: 1610,
        pointsLimit: 2000,
        regiments: regiments,
      );

      final score = scoringEngine.calculateScores(armyList);

      // Speed calculation includes: 12 + 10 + 3 + 5 = 30 / 4 = 7.5
      expect(score.averageSpeed, equals(7.5));

      // Verify other metrics still work correctly
      expect(score.totalWounds,
          greaterThan(0)); // Should include character monsters
      expect(score.expectedHitVolume, greaterThan(0.0)); // All units contribute
      expect(score.toughness,
          greaterThan(0.0)); // Should include character monsters
      expect(
          score.evasion, greaterThan(0.0)); // Should include character monsters
    });

    test(
        'should maintain precision with fractional averages including character monsters',
        () {
      final regiments = [
        Regiment(
            unit: characterMonsterUnit, stands: 1, pointsCost: 400), // March 10
        Regiment(
            unit: regularRegimentUnit, stands: 1, pointsCost: 160), // March 5
        Regiment(
            unit: slowCharacterMonsterUnit,
            stands: 1,
            pointsCost: 450), // March 3
      ];

      final armyList = ArmyList(
        name: 'Fractional Speed Test',
        faction: 'Test',
        totalPoints: 1010,
        pointsLimit: 2000,
        regiments: regiments,
      );

      final score = scoringEngine.calculateScores(armyList);

      // Average of: 10 + 5 + 3 = 18 / 3 = 6.0
      expect(score.averageSpeed, equals(6.0));
    });

    test('should verify character monster speed affects shareable text', () {
      final regiments = [
        Regiment(
            unit: characterMonsterUnit, stands: 1, pointsCost: 400), // March 10
        Regiment(
            unit: regularRegimentUnit, stands: 1, pointsCost: 160), // March 5
      ];

      final armyList = ArmyList(
        name: 'Speed Text Test',
        faction: 'Test',
        totalPoints: 560,
        pointsLimit: 2000,
        regiments: regiments,
      );

      final score = scoringEngine.calculateScores(armyList);
      final shareableText = score.toShareableText();

      expect(shareableText, contains('Army List Analysis: Speed Text Test'));
      expect(shareableText, contains('Average Speed: 7.5')); // (10 + 5) / 2
    });

    test('should compare old vs new speed calculation behavior', () {
      // Test that demonstrates the change in behavior
      final regiments = [
        Regiment(
            unit: regularCharacterUnit,
            stands: 1,
            pointsCost: 150), // March 8, excluded
        Regiment(
            unit: characterMonsterUnit,
            stands: 1,
            pointsCost: 400), // March 10, NOW included
        Regiment(
            unit: regularRegimentUnit,
            stands: 1,
            pointsCost: 160), // March 5, included
      ];

      final armyList = ArmyList(
        name: 'Behavior Change Test',
        faction: 'Test',
        totalPoints: 710,
        pointsLimit: 2000,
        regiments: regiments,
      );

      final score = scoringEngine.calculateScores(armyList);

      // NEW behavior: includes character monster
      // Average of: 10 (character monster) + 5 (regiment) = 15 / 2 = 7.5
      expect(score.averageSpeed, equals(7.5));

      // OLD behavior would have been:
      // Average of: 5 (regiment only) = 5 / 1 = 5.0
      expect(score.averageSpeed, isNot(equals(5.0)));
    });

    test('should handle edge case with zero march character monster', () {
      final zeroMarchCharacterMonster = Unit(
        name: 'Stationary Guardian',
        faction: 'Test',
        type: 'monster',
        regimentClass: 'character',
        characteristics: const UnitCharacteristics(
          march: 0, // Explicitly zero movement
          volley: 3,
          clash: 4,
          attacks: 3,
          wounds: 10,
          resolve: 5,
          defense: 4,
          evasion: 1,
        ),
        specialRules: const [],
        numericSpecialRules: const {},
        supremacyAbilities: const [],
        drawEvents: const [],
        points: 300,
      );

      final regiments = [
        Regiment(
            unit: zeroMarchCharacterMonster,
            stands: 1,
            pointsCost: 300), // March 0
        Regiment(
            unit: regularRegimentUnit, stands: 1, pointsCost: 160), // March 5
      ];

      final armyList = ArmyList(
        name: 'Zero March Monster Test',
        faction: 'Test',
        totalPoints: 460,
        pointsLimit: 2000,
        regiments: regiments,
      );

      final score = scoringEngine.calculateScores(armyList);

      // Average of: 0 (zero march monster) + 5 (regiment) = 5 / 2 = 2.5
      expect(score.averageSpeed, equals(2.5));
    });
  });
}
