import 'package:flutter_test/flutter_test.dart';
import 'package:conquest_analyzer/services/scoring_engine.dart';
import 'package:conquest_analyzer/models/army_list.dart';
import 'package:conquest_analyzer/models/regiment.dart';
import 'package:conquest_analyzer/models/unit.dart';

void main() {
  group('Evasion Score Tests', () {
    late ScoringEngine scoringEngine;
    late Unit lowEvasionUnit;
    late Unit mediumEvasionUnit;
    late Unit highEvasionUnit;
    late Unit characterUnit;

    setUp(() {
      scoringEngine = ScoringEngine();

      lowEvasionUnit = Unit(
        name: 'Heavy Infantry',
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
          evasion: 1, // Low evasion
        ),
        specialRules: const [],
        numericSpecialRules: const {},
        supremacyAbilities: const [],
        drawEvents: const [],
        points: 200,
      );

      mediumEvasionUnit = Unit(
        name: 'Medium Infantry',
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
          evasion: 2, // Medium evasion
        ),
        specialRules: const [],
        numericSpecialRules: const {},
        supremacyAbilities: const [],
        drawEvents: const [],
        points: 160,
      );

      highEvasionUnit = Unit(
        name: 'Light Cavalry',
        faction: 'Test',
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
          evasion: 3, // High evasion
        ),
        specialRules: const [],
        numericSpecialRules: const {},
        supremacyAbilities: const [],
        drawEvents: const [],
        points: 150,
      );

      characterUnit = Unit(
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
          evasion: 4, // Very high evasion - should be excluded
        ),
        specialRules: const [],
        numericSpecialRules: const {},
        supremacyAbilities: const [],
        drawEvents: const [],
        points: 150,
      );
    });

    test('should calculate evasion correctly for single regiment', () {
      final regiments = [
        Regiment(unit: mediumEvasionUnit, stands: 2, pointsCost: 200),
      ];

      final armyList = ArmyList(
        name: 'Single Regiment Army',
        faction: 'Test',
        totalPoints: 200,
        pointsLimit: 2000,
        regiments: regiments,
      );

      final score = scoringEngine.calculateScores(armyList);

      // 2 stands × 5 wounds = 10 total wounds
      // Evasion 2 × 10 wounds = 20
      // Evasion = 20 / 10 = 2.0
      expect(score.evasion, equals(2.0));
    });

    test('should calculate wound-weighted average evasion correctly', () {
      final regiments = [
        Regiment(
            unit: lowEvasionUnit,
            stands: 1,
            pointsCost: 200), // Evasion 1, 6 wounds
        Regiment(
            unit: highEvasionUnit,
            stands: 1,
            pointsCost: 150), // Evasion 3, 4 wounds
      ];

      final armyList = ArmyList(
        name: 'Mixed Evasion Army',
        faction: 'Test',
        totalPoints: 350,
        pointsLimit: 2000,
        regiments: regiments,
      );

      final score = scoringEngine.calculateScores(armyList);

      // Low evasion: Evasion 1 × 6 wounds = 6
      // High evasion: Evasion 3 × 4 wounds = 12
      // Total: (6 + 12) / (6 + 4) = 18 / 10 = 1.8
      expect(score.evasion, equals(1.8));
    });

    test('should exclude characters from evasion calculation', () {
      final regiments = [
        Regiment(
            unit: characterUnit,
            stands: 1,
            pointsCost: 150), // Evasion 4, excluded
        Regiment(
            unit: mediumEvasionUnit,
            stands: 2,
            pointsCost: 200), // Evasion 2, 10 wounds
      ];

      final armyList = ArmyList(
        name: 'Army with Character',
        faction: 'Test',
        totalPoints: 350,
        pointsLimit: 2000,
        regiments: regiments,
      );

      final score = scoringEngine.calculateScores(armyList);

      // Character excluded, only medium evasion unit counts
      // Evasion 2 × 10 wounds = 20 / 10 = 2.0
      expect(score.evasion, equals(2.0));
    });

    test('should handle multiple regiments with different wound counts', () {
      final regiments = [
        Regiment(
            unit: lowEvasionUnit,
            stands: 2,
            pointsCost: 320), // Evasion 1, 12 wounds
        Regiment(
            unit: mediumEvasionUnit,
            stands: 1,
            pointsCost: 160), // Evasion 2, 5 wounds
        Regiment(
            unit: highEvasionUnit,
            stands: 3,
            pointsCost: 300), // Evasion 3, 12 wounds
      ];

      final armyList = ArmyList(
        name: 'Complex Army',
        faction: 'Test',
        totalPoints: 780,
        pointsLimit: 2000,
        regiments: regiments,
      );

      final score = scoringEngine.calculateScores(armyList);

      // Low: Evasion 1 × 12 wounds = 12
      // Medium: Evasion 2 × 5 wounds = 10
      // High: Evasion 3 × 12 wounds = 36
      // Total: (12 + 10 + 36) / (12 + 5 + 12) = 58 / 29 = 2.0
      expect(score.evasion, equals(2.0));
    });

    test('should return 0 for army with only characters', () {
      final regiments = [
        Regiment(unit: characterUnit, stands: 1, pointsCost: 150),
      ];

      final armyList = ArmyList(
        name: 'Character Only Army',
        faction: 'Test',
        totalPoints: 150,
        pointsLimit: 2000,
        regiments: regiments,
      );

      final score = scoringEngine.calculateScores(armyList);

      // No non-character regiments = 0 evasion
      expect(score.evasion, equals(0.0));
    });

    test('should return 0 for empty army', () {
      final armyList = ArmyList(
        name: 'Empty Army',
        faction: 'Test',
        totalPoints: 0,
        pointsLimit: 2000,
        regiments: const [],
      );

      final score = scoringEngine.calculateScores(armyList);
      expect(score.evasion, equals(0.0));
    });

    test('should handle armies with same evasion values', () {
      final regiments = [
        Regiment(
            unit: mediumEvasionUnit,
            stands: 1,
            pointsCost: 160), // Evasion 2, 5 wounds
        Regiment(
            unit: mediumEvasionUnit,
            stands: 2,
            pointsCost: 250), // Evasion 2, 10 wounds
        Regiment(
            unit: mediumEvasionUnit,
            stands: 3,
            pointsCost: 340), // Evasion 2, 15 wounds
      ];

      final armyList = ArmyList(
        name: 'Uniform Evasion Army',
        faction: 'Test',
        totalPoints: 750,
        pointsLimit: 2000,
        regiments: regiments,
      );

      final score = scoringEngine.calculateScores(armyList);

      // All units have Evasion 2, so weighted average should be 2.0
      expect(score.evasion, equals(2.0));
    });

    test('should handle extreme evasion values correctly', () {
      final minEvasionUnit = Unit(
        name: 'Siege Engine',
        faction: 'Test',
        type: 'siege',
        regimentClass: 'heavy',
        characteristics: const UnitCharacteristics(
          march: 2,
          volley: 6,
          clash: 1,
          attacks: 1,
          wounds: 8,
          resolve: 5,
          defense: 5,
          evasion: 1, // Minimum evasion
        ),
        specialRules: const [],
        numericSpecialRules: const {},
        supremacyAbilities: const [],
        drawEvents: const [],
        points: 400,
      );

      final maxEvasionUnit = Unit(
        name: 'Elite Scouts',
        faction: 'Test',
        type: 'infantry',
        regimentClass: 'light',
        characteristics: const UnitCharacteristics(
          march: 8,
          volley: 3,
          clash: 2,
          attacks: 5,
          wounds: 3,
          resolve: 2,
          defense: 1,
          evasion: 4, // Maximum evasion
        ),
        specialRules: const [],
        numericSpecialRules: const {},
        supremacyAbilities: const [],
        drawEvents: const [],
        points: 180,
      );

      final regiments = [
        Regiment(
            unit: minEvasionUnit,
            stands: 1,
            pointsCost: 400), // Evasion 1, 8 wounds
        Regiment(
            unit: maxEvasionUnit,
            stands: 2,
            pointsCost: 300), // Evasion 4, 6 wounds
      ];

      final armyList = ArmyList(
        name: 'Extreme Evasion Army',
        faction: 'Test',
        totalPoints: 700,
        pointsLimit: 2000,
        regiments: regiments,
      );

      final score = scoringEngine.calculateScores(armyList);

      // Min: Evasion 1 × 8 wounds = 8
      // Max: Evasion 4 × 6 wounds = 24
      // Total: (8 + 24) / (8 + 6) = 32 / 14 ≈ 2.29
      expect(score.evasion, closeTo(2.29, 0.01));
    });

    test('should include evasion in shareable text format', () {
      final regiments = [
        Regiment(unit: mediumEvasionUnit, stands: 2, pointsCost: 200),
        Regiment(unit: highEvasionUnit, stands: 1, pointsCost: 150),
      ];

      final armyList = ArmyList(
        name: 'Evasion Test Army',
        faction: 'Test',
        totalPoints: 350,
        pointsLimit: 2000,
        regiments: regiments,
      );

      final score = scoringEngine.calculateScores(armyList);
      final shareableText = score.toShareableText();

      expect(shareableText, contains('Army List Analysis: Evasion Test Army'));
      expect(shareableText, contains('Evasion:'));
      expect(shareableText, contains('Calculated:'));
    });

    test('should handle large armies with consistent performance', () {
      final regiments = <Regiment>[];

      // Create a large army with mixed evasion values
      for (int i = 0; i < 20; i++) {
        regiments
            .add(Regiment(unit: lowEvasionUnit, stands: 1, pointsCost: 200));
      }
      for (int i = 0; i < 15; i++) {
        regiments
            .add(Regiment(unit: mediumEvasionUnit, stands: 1, pointsCost: 160));
      }
      for (int i = 0; i < 10; i++) {
        regiments
            .add(Regiment(unit: highEvasionUnit, stands: 1, pointsCost: 150));
      }

      final armyList = ArmyList(
        name: 'Large Army',
        faction: 'Test',
        totalPoints: 8550,
        pointsLimit: 10000,
        regiments: regiments,
      );

      final score = scoringEngine.calculateScores(armyList);

      // 20 × (Evasion 1 × 6 wounds) = 120
      // 15 × (Evasion 2 × 5 wounds) = 150
      // 10 × (Evasion 3 × 4 wounds) = 120
      // Total: (120 + 150 + 120) / (120 + 75 + 40) = 390 / 235 ≈ 1.66
      expect(score.evasion, closeTo(1.66, 0.01));
      expect(score.evasion, greaterThan(0.0));
    });

    test('should maintain backwards compatibility with existing scoring', () {
      final regiments = [
        Regiment(unit: mediumEvasionUnit, stands: 2, pointsCost: 200),
        Regiment(unit: highEvasionUnit, stands: 1, pointsCost: 150),
      ];

      final armyList = ArmyList(
        name: 'Backwards Compatible Army',
        faction: 'Test',
        totalPoints: 350,
        pointsLimit: 2000,
        regiments: regiments,
      );

      final score = scoringEngine.calculateScores(armyList);

      // Verify all existing scores still work
      expect(score.totalWounds, greaterThan(0));
      expect(score.pointsPerWound, greaterThan(0.0));
      expect(score.expectedHitVolume, greaterThan(0.0));
      expect(score.cleaveRating, greaterThanOrEqualTo(0.0));
      expect(score.rangedExpectedHits, greaterThanOrEqualTo(0.0));
      expect(score.rangedArmorPiercingRating, greaterThanOrEqualTo(0.0));
      expect(score.maxRange, greaterThanOrEqualTo(0));
      expect(score.averageSpeed, greaterThanOrEqualTo(0.0));
      expect(score.toughness, greaterThan(0.0));

      // And new evasion score
      expect(score.evasion, greaterThan(0.0));

      // Verify toString includes evasion
      final stringOutput = score.toString();
      expect(stringOutput, contains('evasion:'));
    });

    test('should handle mixed army with characters and various evasions', () {
      final regiments = [
        Regiment(
            unit: characterUnit,
            stands: 1,
            pointsCost: 150), // Evasion 4, excluded
        Regiment(
            unit: lowEvasionUnit,
            stands: 1,
            pointsCost: 200), // Evasion 1, 6 wounds
        Regiment(
            unit: mediumEvasionUnit,
            stands: 1,
            pointsCost: 160), // Evasion 2, 5 wounds
        Regiment(
            unit: highEvasionUnit,
            stands: 1,
            pointsCost: 150), // Evasion 3, 4 wounds
      ];

      final armyList = ArmyList(
        name: 'Complex Mixed Army',
        faction: 'Test',
        totalPoints: 660,
        pointsLimit: 2000,
        regiments: regiments,
      );

      final score = scoringEngine.calculateScores(armyList);

      // Character excluded
      // Low: Evasion 1 × 6 wounds = 6
      // Medium: Evasion 2 × 5 wounds = 10
      // High: Evasion 3 × 4 wounds = 12
      // Total: (6 + 10 + 12) / (6 + 5 + 4) = 28 / 15 ≈ 1.87
      expect(score.evasion, closeTo(1.87, 0.01));

      // Verify other scores still work correctly
      expect(score.totalWounds, equals(15)); // Characters excluded from wounds
      expect(score.expectedHitVolume,
          greaterThan(0.0)); // Characters included in hit volume
    });

    test('should round to appropriate decimal places correctly', () {
      final regiments = [
        Regiment(
            unit: lowEvasionUnit,
            stands: 1,
            pointsCost: 200), // Evasion 1, 6 wounds
        Regiment(
            unit: mediumEvasionUnit,
            stands: 1,
            pointsCost: 160), // Evasion 2, 5 wounds
        Regiment(
            unit: highEvasionUnit,
            stands: 1,
            pointsCost: 150), // Evasion 3, 4 wounds
      ];

      final armyList = ArmyList(
        name: 'Precision Test Army',
        faction: 'Test',
        totalPoints: 510,
        pointsLimit: 2000,
        regiments: regiments,
      );

      final score = scoringEngine.calculateScores(armyList);

      // Evasion 1 × 6 = 6, Evasion 2 × 5 = 10, Evasion 3 × 4 = 12
      // Total: (6 + 10 + 12) / (6 + 5 + 4) = 28 / 15 ≈ 1.8666...
      expect(score.evasion, closeTo(1.87, 0.01));

      // Verify it displays as one decimal place in shareable text
      final shareableText = score.toShareableText();
      expect(shareableText, contains('Evasion: 1.9'));
    });

    test('should verify evasion calculation is independent of toughness', () {
      final mixedUnit = Unit(
        name: 'Mixed Stats Unit',
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
          defense: 4, // High defense
          evasion: 1, // Low evasion - opposite of defense
        ),
        specialRules: const [],
        numericSpecialRules: const {},
        supremacyAbilities: const [],
        drawEvents: const [],
        points: 180,
      );

      final regiments = [
        Regiment(unit: mixedUnit, stands: 2, pointsCost: 240),
      ];

      final armyList = ArmyList(
        name: 'Mixed Stats Army',
        faction: 'Test',
        totalPoints: 240,
        pointsLimit: 2000,
        regiments: regiments,
      );

      final score = scoringEngine.calculateScores(armyList);

      // Should have high toughness but low evasion
      expect(score.toughness, equals(4.0)); // Defense 4
      expect(score.evasion, equals(1.0)); // Evasion 1
      expect(score.toughness, isNot(equals(score.evasion)));
    });
  });
}
