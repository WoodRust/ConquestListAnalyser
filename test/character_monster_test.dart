import 'package:flutter_test/flutter_test.dart';
import 'package:conquest_analyzer/services/scoring_engine.dart';
import 'package:conquest_analyzer/models/army_list.dart';
import 'package:conquest_analyzer/models/regiment.dart';
import 'package:conquest_analyzer/models/unit.dart';

void main() {
  group('Character Monster Wound Tests', () {
    late ScoringEngine scoringEngine;
    late Unit regularCharacterUnit;
    late Unit characterMonsterUnit;
    late Unit regularRegimentUnit;
    late Unit monsterRegimentUnit;

    setUp(() {
      scoringEngine = ScoringEngine();

      // Regular character (should be excluded from wounds)
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

      // Character monster (should be included in wounds)
      characterMonsterUnit = Unit(
        name: 'Dragon Lord',
        faction: 'Test',
        type: 'monster',
        regimentClass: 'character',
        characteristics: const UnitCharacteristics(
          march: 8,
          volley: 4,
          clash: 5,
          attacks: 8,
          wounds: 8, // High wounds typical of monsters
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

      // Regular regiment (should be included in wounds)
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

      // Monster regiment (should be included in wounds)
      monsterRegimentUnit = Unit(
        name: 'Beast Regiment',
        faction: 'Test',
        type: 'monster',
        regimentClass: 'heavy',
        characteristics: const UnitCharacteristics(
          march: 6,
          volley: 1,
          clash: 4,
          attacks: 6,
          wounds: 7,
          resolve: 4,
          defense: 3,
          evasion: 1,
        ),
        specialRules: const [],
        numericSpecialRules: const {'cleave': 2},
        supremacyAbilities: const [],
        drawEvents: const [],
        points: 300,
      );
    });

    test('should include character monster wounds in total wounds calculation',
        () {
      final regiments = [
        Regiment(
            unit: regularCharacterUnit,
            stands: 1,
            pointsCost: 150), // 3 wounds - excluded
        Regiment(
            unit: characterMonsterUnit,
            stands: 1,
            pointsCost: 400), // 8 wounds - included
        Regiment(
            unit: regularRegimentUnit,
            stands: 2,
            pointsCost: 250), // 10 wounds - included
      ];

      final armyList = ArmyList(
        name: 'Character Monster Test Army',
        faction: 'Test',
        totalPoints: 800,
        pointsLimit: 2000,
        regiments: regiments,
      );

      final score = scoringEngine.calculateScores(armyList);

      // Total wounds should be: 8 (character monster) + 10 (regiment) = 18
      // Regular character's 3 wounds should be excluded
      expect(score.totalWounds, equals(18));
      expect(score.pointsPerWound, closeTo(44.44, 0.01)); // 800 / 18
    });

    test('should include character monster in toughness calculation', () {
      final regiments = [
        Regiment(
            unit: regularCharacterUnit,
            stands: 1,
            pointsCost: 150), // Defense 3, excluded
        Regiment(
            unit: characterMonsterUnit,
            stands: 1,
            pointsCost: 400), // Defense 4, 8 wounds - included
        Regiment(
            unit: regularRegimentUnit,
            stands: 1,
            pointsCost: 160), // Defense 2, 5 wounds - included
      ];

      final armyList = ArmyList(
        name: 'Toughness Test Army',
        faction: 'Test',
        totalPoints: 710,
        pointsLimit: 2000,
        regiments: regiments,
      );

      final score = scoringEngine.calculateScores(armyList);

      // Toughness calculation:
      // Character monster: Defense 4 × 8 wounds = 32
      // Regular regiment: Defense 2 × 5 wounds = 10
      // Regular character excluded
      // Total: (32 + 10) / (8 + 5) = 42 / 13 ≈ 3.23
      expect(score.toughness, closeTo(3.23, 0.01));
    });

    test('should include character monster in evasion calculation', () {
      final regiments = [
        Regiment(
            unit: regularCharacterUnit,
            stands: 1,
            pointsCost: 150), // Evasion 2, excluded
        Regiment(
            unit: characterMonsterUnit,
            stands: 1,
            pointsCost: 400), // Evasion 2, 8 wounds - included
        Regiment(
            unit: regularRegimentUnit,
            stands: 1,
            pointsCost: 160), // Evasion 1, 5 wounds - included
      ];

      final armyList = ArmyList(
        name: 'Evasion Test Army',
        faction: 'Test',
        totalPoints: 710,
        pointsLimit: 2000,
        regiments: regiments,
      );

      final score = scoringEngine.calculateScores(armyList);

      // Evasion calculation:
      // Character monster: Evasion 2 × 8 wounds = 16
      // Regular regiment: Evasion 1 × 5 wounds = 5
      // Regular character excluded
      // Total: (16 + 5) / (8 + 5) = 21 / 13 ≈ 1.62
      expect(score.evasion, closeTo(1.62, 0.01));
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
            pointsCost: 400), // March 8, included
        Regiment(
            unit: regularRegimentUnit,
            stands: 1,
            pointsCost: 160), // March 5, included
        Regiment(
            unit: monsterRegimentUnit,
            stands: 1,
            pointsCost: 300), // March 6, included
      ];

      final armyList = ArmyList(
        name: 'Speed Test Army',
        faction: 'Test',
        totalPoints: 1010,
        pointsLimit: 2000,
        regiments: regiments,
      );

      final score = scoringEngine.calculateScores(armyList);

      // Speed calculation should include character monster but exclude regular character
      // Average of: 8 (character monster) + 5 (regular regiment) + 6 (monster regiment) = 19 / 3 ≈ 6.33
      expect(score.averageSpeed, closeTo(6.33, 0.01));
    });

    test('should include character monster in hit volume calculation', () {
      final regiments = [
        Regiment(
            unit: characterMonsterUnit,
            stands: 1,
            pointsCost: 400), // Should contribute to hit volume
      ];

      final armyList = ArmyList(
        name: 'Hit Volume Test Army',
        faction: 'Test',
        totalPoints: 400,
        pointsLimit: 2000,
        regiments: regiments,
      );

      final score = scoringEngine.calculateScores(armyList);

      // Character monster should contribute to hit volume
      // 8 attacks, clash 5 = (5+1)/6 = 1.0 hit chance
      // Expected hits = 8 * 1.0 = 8.0
      expect(score.expectedHitVolume, equals(8.0));

      // Should also contribute to cleave rating
      // Cleave rating = 8.0 * 3 = 24.0
      expect(score.cleaveRating, equals(24.0));
    });

    test('should handle army with only character monsters', () {
      final regiments = [
        Regiment(
            unit: characterMonsterUnit, stands: 1, pointsCost: 400), // 8 wounds
      ];

      final armyList = ArmyList(
        name: 'Character Monster Only Army',
        faction: 'Test',
        totalPoints: 400,
        pointsLimit: 2000,
        regiments: regiments,
      );

      final score = scoringEngine.calculateScores(armyList);

      expect(score.totalWounds, equals(8));
      expect(score.pointsPerWound, equals(50.0)); // 400 / 8
      expect(score.toughness, equals(4.0)); // Defense 4
      expect(score.evasion, equals(2.0)); // Evasion 2
      expect(score.averageSpeed, equals(0.0)); // No non-character regiments
    });

    test('should handle army with only regular characters', () {
      final regiments = [
        Regiment(unit: regularCharacterUnit, stands: 1, pointsCost: 150),
      ];

      final armyList = ArmyList(
        name: 'Regular Character Only Army',
        faction: 'Test',
        totalPoints: 150,
        pointsLimit: 2000,
        regiments: regiments,
      );

      final score = scoringEngine.calculateScores(armyList);

      expect(score.totalWounds, equals(0)); // No wounds counted
      expect(score.pointsPerWound, equals(0.0)); // Division by zero protection
      expect(score.toughness, equals(0.0)); // No regiments for toughness
      expect(score.evasion, equals(0.0)); // No regiments for evasion
      expect(score.averageSpeed, equals(0.0)); // No non-character regiments
      expect(score.expectedHitVolume,
          greaterThan(0.0)); // Character still contributes to combat
    });

    test('should correctly identify character monsters in army list', () {
      final regiments = [
        Regiment(unit: regularCharacterUnit, stands: 1, pointsCost: 150),
        Regiment(unit: characterMonsterUnit, stands: 1, pointsCost: 400),
        Regiment(unit: regularRegimentUnit, stands: 1, pointsCost: 160),
        Regiment(unit: monsterRegimentUnit, stands: 1, pointsCost: 300),
      ];

      final armyList = ArmyList(
        name: 'Mixed Army',
        faction: 'Test',
        totalPoints: 1010,
        pointsLimit: 2000,
        regiments: regiments,
      );

      // Test ArmyList character monster getter
      final characterMonsters = armyList.characterMonsters;
      expect(characterMonsters.length, equals(1));
      expect(characterMonsters.first.unit.name, equals('Dragon Lord'));

      // Test total characters
      final allCharacters = armyList.characters;
      expect(allCharacters.length,
          equals(2)); // Both regular and monster characters

      // Test non-character regiments
      final nonCharacters = armyList.nonCharacterRegiments;
      expect(nonCharacters.length,
          equals(2)); // Both regular and monster regiments
    });

    test('should handle mixed army with all unit types', () {
      final regiments = [
        Regiment(
            unit: regularCharacterUnit,
            stands: 1,
            pointsCost: 150), // 3 wounds - excluded
        Regiment(
            unit: characterMonsterUnit,
            stands: 1,
            pointsCost: 400), // 8 wounds - included
        Regiment(
            unit: regularRegimentUnit,
            stands: 2,
            pointsCost: 250), // 10 wounds - included
        Regiment(
            unit: monsterRegimentUnit,
            stands: 1,
            pointsCost: 300), // 7 wounds - included
      ];

      final armyList = ArmyList(
        name: 'Complete Mixed Army',
        faction: 'Test',
        totalPoints: 1100,
        pointsLimit: 2000,
        regiments: regiments,
      );

      final score = scoringEngine.calculateScores(armyList);

      // Total wounds: 8 (character monster) + 10 (regiment) + 7 (monster regiment) = 25
      expect(score.totalWounds, equals(25));
      expect(score.pointsPerWound, equals(44.0)); // 1100 / 25

      // Toughness calculation includes character monster:
      // Character monster: Defense 4 × 8 wounds = 32
      // Regular regiment: Defense 2 × 10 wounds = 20
      // Monster regiment: Defense 3 × 7 wounds = 21
      // Total: (32 + 20 + 21) / (8 + 10 + 7) = 73 / 25 = 2.92
      expect(score.toughness, equals(2.92));

      // Speed calculation excludes all characters:
      // Average of: 5 (regular regiment) + 6 (monster regiment) = 11 / 2 = 5.5
      expect(score.averageSpeed, equals(5.5));

      // All units contribute to hit volume
      expect(score.expectedHitVolume, greaterThan(0.0));
    });

    test('should maintain backwards compatibility', () {
      // Test that existing functionality still works correctly
      final regiments = [
        Regiment(unit: regularRegimentUnit, stands: 2, pointsCost: 250),
        Regiment(unit: monsterRegimentUnit, stands: 1, pointsCost: 300),
      ];

      final armyList = ArmyList(
        name: 'Backwards Compatibility Test',
        faction: 'Test',
        totalPoints: 550,
        pointsLimit: 2000,
        regiments: regiments,
      );

      final score = scoringEngine.calculateScores(armyList);

      // All existing calculations should work as before
      expect(score.totalWounds, equals(17)); // 10 + 7
      expect(score.pointsPerWound, closeTo(32.35, 0.01)); // 550 / 17
      expect(score.averageSpeed, equals(5.5)); // (5 + 6) / 2
      expect(score.expectedHitVolume, greaterThan(0.0));
      expect(score.cleaveRating, greaterThan(0.0));
    });

    test('should handle edge cases with character monsters', () {
      // Test with zero stands character monster
      final zeroStandsRegiment = Regiment(
        unit: characterMonsterUnit,
        stands: 0,
        pointsCost: 0,
      );

      final armyList = ArmyList(
        name: 'Edge Case Army',
        faction: 'Test',
        totalPoints: 0,
        pointsLimit: 2000,
        regiments: [zeroStandsRegiment],
      );

      final score = scoringEngine.calculateScores(armyList);

      expect(score.totalWounds, equals(0)); // 0 stands = 0 wounds
      expect(score.pointsPerWound, equals(0.0));
      expect(score.toughness, equals(0.0));
      expect(score.evasion, equals(0.0));
    });
  });
}
