import 'package:flutter_test/flutter_test.dart';
import 'package:conquest_analyzer/services/scoring_engine.dart';
import 'package:conquest_analyzer/models/army_list.dart';
import 'package:conquest_analyzer/models/regiment.dart';
import 'package:conquest_analyzer/models/unit.dart';

void main() {
  group('ScoringEngine Integration Tests with Toughness', () {
    late ScoringEngine scoringEngine;
    late Unit testUnitBasic;
    late Unit testUnitWithCleave;
    late Unit testUnitWithBarrage;
    late Unit testCharacterUnit;

    setUp(() {
      scoringEngine = ScoringEngine();

      testUnitBasic = Unit(
        name: 'Basic Infantry',
        faction: 'Test',
        type: 'infantry',
        regimentClass: 'medium',
        characteristics: const UnitCharacteristics(
          march: 6,
          volley: 2,
          clash: 3,
          attacks: 4,
          wounds: 5,
          resolve: 3,
          defense: 2, // Medium defense
          evasion: 1,
        ),
        specialRules: const [],
        numericSpecialRules: const {},
        supremacyAbilities: const [],
        drawEvents: const [],
        points: 140,
      );

      testUnitWithCleave = Unit(
        name: 'Cleaving Unit',
        faction: 'Test',
        type: 'brute',
        regimentClass: 'heavy',
        characteristics: const UnitCharacteristics(
          march: 5,
          volley: 1,
          clash: 3,
          attacks: 5,
          wounds: 6,
          resolve: 4,
          defense: 3, // High defense
          evasion: 1,
        ),
        specialRules: const [],
        numericSpecialRules: const {'cleave': 2},
        supremacyAbilities: const [],
        drawEvents: const [],
        points: 200,
      );

      testUnitWithBarrage = Unit(
        name: 'Archer Unit',
        faction: 'Test',
        type: 'infantry',
        regimentClass: 'light',
        characteristics: const UnitCharacteristics(
          march: 7,
          volley: 4,
          clash: 2,
          attacks: 3,
          wounds: 4,
          resolve: 2,
          defense: 1, // Low defense
          evasion: 1,
        ),
        specialRules: const [],
        numericSpecialRules: const {
          'barrage': 3,
          'armorPiercingValue': 1,
          'barrageRange': 24
        },
        supremacyAbilities: const [],
        drawEvents: const [],
        points: 160,
      );

      testCharacterUnit = Unit(
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
          defense: 4, // High defense - should be excluded from toughness
          evasion: 2,
        ),
        specialRules: const [],
        numericSpecialRules: const {'cleave': 1, 'barrage': 1},
        supremacyAbilities: const [],
        drawEvents: const [],
        points: 150,
      );
    });

    test('should calculate complete score sheet including toughness', () {
      final regiments = [
        Regiment(
            unit: testUnitBasic,
            stands: 2,
            pointsCost: 200), // Defense 2, 10 wounds
        Regiment(
            unit: testUnitWithCleave,
            stands: 1,
            pointsCost: 200), // Defense 3, 6 wounds
        Regiment(
            unit: testUnitWithBarrage,
            stands: 1,
            pointsCost: 160), // Defense 1, 4 wounds
        Regiment(
            unit: testCharacterUnit,
            stands: 1,
            pointsCost: 150), // Defense 4, excluded
      ];

      final armyList = ArmyList(
        name: 'Complete Test Army',
        faction: 'Test',
        totalPoints: 710,
        pointsLimit: 2000,
        regiments: regiments,
      );

      final score = scoringEngine.calculateScores(armyList);

      // Verify all metrics are calculated
      expect(score.totalWounds, equals(20)); // 10 + 6 + 4 (character excluded)
      expect(score.pointsPerWound, equals(35.5)); // 710 / 20
      expect(score.expectedHitVolume, greaterThan(0.0));
      expect(score.cleaveRating, greaterThan(0.0));
      expect(score.rangedExpectedHits, greaterThan(0.0));
      expect(score.rangedArmorPiercingRating, greaterThan(0.0));
      expect(score.maxRange, equals(24));
      expect(score.averageSpeed, equals(6.0)); // (6 + 5 + 7) / 3

      // Verify toughness calculation:
      // Basic: Defense 2 × 10 wounds = 20
      // Cleave: Defense 3 × 6 wounds = 18
      // Archer: Defense 1 × 4 wounds = 4
      // Character excluded
      // Total: (20 + 18 + 4) / (10 + 6 + 4) = 42 / 20 = 2.1
      expect(score.toughness, equals(2.1));

      // Verify toughness is included in shareable text
      final shareableText = score.toShareableText();
      expect(shareableText, contains('Toughness: 2.1'));
    });

    test('should handle army with varying defensive profiles', () {
      final lightUnit = Unit(
        name: 'Light Skirmishers',
        faction: 'Test',
        type: 'infantry',
        regimentClass: 'light',
        characteristics: const UnitCharacteristics(
          march: 7,
          volley: 3,
          clash: 2,
          attacks: 4,
          wounds: 3,
          resolve: 2,
          defense: 1, // Very low defense
          evasion: 2,
        ),
        specialRules: const [],
        numericSpecialRules: const {},
        supremacyAbilities: const [],
        drawEvents: const [],
        points: 100,
      );

      final heavyUnit = Unit(
        name: 'Heavy Guard',
        faction: 'Test',
        type: 'infantry',
        regimentClass: 'heavy',
        characteristics: const UnitCharacteristics(
          march: 4,
          volley: 1,
          clash: 4,
          attacks: 3,
          wounds: 7,
          resolve: 4,
          defense: 4, // Very high defense
          evasion: 1,
        ),
        specialRules: const [],
        numericSpecialRules: const {'cleave': 3},
        supremacyAbilities: const [],
        drawEvents: const [],
        points: 250,
      );

      final regiments = [
        Regiment(
            unit: lightUnit, stands: 3, pointsCost: 230), // Defense 1, 9 wounds
        Regiment(
            unit: heavyUnit,
            stands: 2,
            pointsCost: 430), // Defense 4, 14 wounds
      ];

      final armyList = ArmyList(
        name: 'Defensive Contrast Army',
        faction: 'Test',
        totalPoints: 660,
        pointsLimit: 2000,
        regiments: regiments,
      );

      final score = scoringEngine.calculateScores(armyList);

      // Light: Defense 1 × 9 wounds = 9
      // Heavy: Defense 4 × 14 wounds = 56
      // Total: (9 + 56) / (9 + 14) = 65 / 23 ≈ 2.83
      expect(score.toughness, closeTo(2.83, 0.01));
      expect(score.totalWounds, equals(23));
    });

    test(
        'should verify toughness excludes characters but includes their combat capability',
        () {
      final regiments = [
        Regiment(
            unit: testCharacterUnit, stands: 1, pointsCost: 150), // Character
        Regiment(
            unit: testUnitBasic,
            stands: 1,
            pointsCost: 140), // Defense 2, 5 wounds
      ];

      final armyList = ArmyList(
        name: 'Character + Regiment Army',
        faction: 'Test',
        totalPoints: 290,
        pointsLimit: 2000,
        regiments: regiments,
      );

      final score = scoringEngine.calculateScores(armyList);

      // Toughness: Only basic unit counts = Defense 2 × 5 wounds / 5 wounds = 2.0
      expect(score.toughness, equals(2.0));

      // But character should contribute to combat metrics
      expect(score.expectedHitVolume, greaterThan(5.0)); // Character adds hits
      expect(score.cleaveRating, greaterThan(0.0)); // Character has cleave
      expect(
          score.rangedExpectedHits, greaterThan(0.0)); // Character has barrage

      // Wounds calculation excludes character
      expect(score.totalWounds, equals(5)); // Only regiment wounds
    });

    test('should handle edge case armies for toughness', () {
      // Test character-only army
      final characterOnlyRegiments = [
        Regiment(unit: testCharacterUnit, stands: 1, pointsCost: 150),
      ];

      final characterOnlyArmy = ArmyList(
        name: 'Character Only',
        faction: 'Test',
        totalPoints: 150,
        pointsLimit: 2000,
        regiments: characterOnlyRegiments,
      );

      final characterOnlyScore =
          scoringEngine.calculateScores(characterOnlyArmy);
      expect(characterOnlyScore.toughness, equals(0.0));
      expect(characterOnlyScore.totalWounds, equals(0));
      expect(characterOnlyScore.expectedHitVolume,
          greaterThan(0.0)); // Character still fights

      // Test empty army
      final emptyArmy = ArmyList(
        name: 'Empty',
        faction: 'Test',
        totalPoints: 0,
        pointsLimit: 2000,
        regiments: const [],
      );

      final emptyScore = scoringEngine.calculateScores(emptyArmy);
      expect(emptyScore.toughness, equals(0.0));
      expect(emptyScore.totalWounds, equals(0));
      expect(emptyScore.expectedHitVolume, equals(0.0));
    });

    test('should maintain consistent precision in toughness calculations', () {
      final regiments = [
        Regiment(
            unit: testUnitBasic,
            stands: 1,
            pointsCost: 140), // Defense 2, 5 wounds
        Regiment(
            unit: testUnitWithCleave,
            stands: 1,
            pointsCost: 200), // Defense 3, 6 wounds
        Regiment(
            unit: testUnitWithBarrage,
            stands: 1,
            pointsCost: 160), // Defense 1, 4 wounds
      ];

      final armyList = ArmyList(
        name: 'Precision Test Army',
        faction: 'Test',
        totalPoints: 500,
        pointsLimit: 2000,
        regiments: regiments,
      );

      final score = scoringEngine.calculateScores(armyList);

      // Defense 2 × 5 = 10, Defense 3 × 6 = 18, Defense 1 × 4 = 4
      // Total: (10 + 18 + 4) / (5 + 6 + 4) = 32 / 15 ≈ 2.1333...
      expect(score.toughness, closeTo(2.13, 0.01));

      // Verify string representation shows one decimal place
      final stringOutput = score.toString();
      expect(stringOutput, contains('toughness: 2.1'));
    });

    test('should work correctly with all existing scoring metrics', () {
      final regiments = [
        Regiment(unit: testUnitWithCleave, stands: 2, pointsCost: 350),
        Regiment(unit: testUnitWithBarrage, stands: 1, pointsCost: 160),
      ];

      final armyList = ArmyList(
        name: 'Full Integration Test',
        faction: 'Test',
        totalPoints: 510,
        pointsLimit: 2000,
        regiments: regiments,
      );

      final score = scoringEngine.calculateScores(armyList);

      // Verify all existing metrics still work
      expect(score.armyList, equals(armyList));
      expect(score.totalWounds, equals(16)); // 2×6 + 1×4 = 16
      expect(score.pointsPerWound, equals(31.875)); // 510/16
      expect(score.expectedHitVolume, greaterThan(0.0));
      expect(score.cleaveRating, greaterThan(0.0));
      expect(score.rangedExpectedHits, greaterThan(0.0));
      expect(score.rangedArmorPiercingRating, greaterThan(0.0));
      expect(score.maxRange, equals(24));
      expect(score.averageSpeed, equals(6.0)); // (5 + 7) / 2
      expect(score.calculatedAt, isA<DateTime>());

      // And new toughness metric
      // Cleave: Defense 3 × 12 wounds = 36
      // Archer: Defense 1 × 4 wounds = 4
      // Total: (36 + 4) / (12 + 4) = 40 / 16 = 2.5
      expect(score.toughness, equals(2.5));

      // Verify shareable text includes all metrics including toughness
      final shareableText = score.toShareableText();
      expect(
          shareableText, contains('Army List Analysis: Full Integration Test'));
      expect(shareableText, contains('Faction: Test'));
      expect(shareableText, contains('Points: 510/2000'));
      expect(shareableText, contains('Total Wounds: 16'));
      expect(shareableText, contains('Points per Wound: 31.88'));
      expect(shareableText, contains('Average Speed: 6.0'));
      expect(shareableText, contains('Toughness: 2.5'));
    });
  });
}
