import 'package:flutter_test/flutter_test.dart';
import 'package:conquest_analyzer/services/scoring_engine.dart';
import 'package:conquest_analyzer/models/army_list.dart';
import 'package:conquest_analyzer/models/regiment.dart';
import 'package:conquest_analyzer/models/unit.dart';

void main() {
  group('Toughness Score Tests', () {
    late ScoringEngine scoringEngine;
    late Unit lowDefenseUnit;
    late Unit mediumDefenseUnit;
    late Unit highDefenseUnit;
    late Unit characterUnit;

    setUp(() {
      scoringEngine = ScoringEngine();

      lowDefenseUnit = Unit(
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
          defense: 1, // Low defense
          evasion: 1,
        ),
        specialRules: const [],
        numericSpecialRules: const {},
        drawEvents: const [],
        points: 120,
      );

      mediumDefenseUnit = Unit(
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
          defense: 2, // Medium defense
          evasion: 1,
        ),
        specialRules: const [],
        numericSpecialRules: const {},
        drawEvents: const [],
        points: 160,
      );

      highDefenseUnit = Unit(
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
          defense: 4, // High defense
          evasion: 1,
        ),
        specialRules: const [],
        numericSpecialRules: const {},
        drawEvents: const [],
        points: 200,
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
          defense: 5, // Very high defense - should be excluded
          evasion: 2,
        ),
        specialRules: const [],
        numericSpecialRules: const {},
        drawEvents: const [],
        points: 150,
      );
    });

    test('should calculate toughness correctly for single regiment', () {
      final regiments = [
        Regiment(unit: mediumDefenseUnit, stands: 2, pointsCost: 200),
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
      // Defense 2 × 10 wounds = 20
      // Toughness = 20 / 10 = 2.0
      expect(score.toughness, equals(2.0));
    });

    test('should calculate wound-weighted average toughness correctly', () {
      final regiments = [
        Regiment(
            unit: lowDefenseUnit,
            stands: 1,
            pointsCost: 120), // Defense 1, 4 wounds
        Regiment(
            unit: highDefenseUnit,
            stands: 1,
            pointsCost: 200), // Defense 4, 6 wounds
      ];

      final armyList = ArmyList(
        name: 'Mixed Defense Army',
        faction: 'Test',
        totalPoints: 320,
        pointsLimit: 2000,
        regiments: regiments,
      );

      final score = scoringEngine.calculateScores(armyList);

      // Low defense: Defense 1 × 4 wounds = 4
      // High defense: Defense 4 × 6 wounds = 24
      // Total: (4 + 24) / (4 + 6) = 28 / 10 = 2.8
      expect(score.toughness, equals(2.8));
    });

    test('should exclude characters from toughness calculation', () {
      final regiments = [
        Regiment(
            unit: characterUnit,
            stands: 1,
            pointsCost: 150), // Defense 5, excluded
        Regiment(
            unit: mediumDefenseUnit,
            stands: 2,
            pointsCost: 200), // Defense 2, 10 wounds
      ];

      final armyList = ArmyList(
        name: 'Army with Character',
        faction: 'Test',
        totalPoints: 350,
        pointsLimit: 2000,
        regiments: regiments,
      );

      final score = scoringEngine.calculateScores(armyList);

      // Character excluded, only medium defense unit counts
      // Defense 2 × 10 wounds = 20 / 10 = 2.0
      expect(score.toughness, equals(2.0));
    });

    test('should handle multiple regiments with different wound counts', () {
      final regiments = [
        Regiment(
            unit: lowDefenseUnit,
            stands: 3,
            pointsCost: 240), // Defense 1, 12 wounds
        Regiment(
            unit: mediumDefenseUnit,
            stands: 1,
            pointsCost: 160), // Defense 2, 5 wounds
        Regiment(
            unit: highDefenseUnit,
            stands: 2,
            pointsCost: 320), // Defense 4, 12 wounds
      ];

      final armyList = ArmyList(
        name: 'Complex Army',
        faction: 'Test',
        totalPoints: 720,
        pointsLimit: 2000,
        regiments: regiments,
      );

      final score = scoringEngine.calculateScores(armyList);

      // Low: Defense 1 × 12 wounds = 12
      // Medium: Defense 2 × 5 wounds = 10
      // High: Defense 4 × 12 wounds = 48
      // Total: (12 + 10 + 48) / (12 + 5 + 12) = 70 / 29 ≈ 2.41
      expect(score.toughness, closeTo(2.41, 0.01));
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

      // No non-character regiments = 0 toughness
      expect(score.toughness, equals(0.0));
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

      expect(score.toughness, equals(0.0));
    });

    test('should handle armies with same defense values', () {
      final regiments = [
        Regiment(
            unit: mediumDefenseUnit,
            stands: 1,
            pointsCost: 160), // Defense 2, 5 wounds
        Regiment(
            unit: mediumDefenseUnit,
            stands: 2,
            pointsCost: 250), // Defense 2, 10 wounds
        Regiment(
            unit: mediumDefenseUnit,
            stands: 3,
            pointsCost: 340), // Defense 2, 15 wounds
      ];

      final armyList = ArmyList(
        name: 'Uniform Defense Army',
        faction: 'Test',
        totalPoints: 750,
        pointsLimit: 2000,
        regiments: regiments,
      );

      final score = scoringEngine.calculateScores(armyList);

      // All units have Defense 2, so weighted average should be 2.0
      expect(score.toughness, equals(2.0));
    });

    test('should handle extreme defense values correctly', () {
      final minDefenseUnit = Unit(
        name: 'Glass Cannon',
        faction: 'Test',
        type: 'infantry',
        regimentClass: 'light',
        characteristics: const UnitCharacteristics(
          march: 8,
          volley: 6,
          clash: 1,
          attacks: 8,
          wounds: 2,
          resolve: 1,
          defense: 1, // Minimum defense
          evasion: 3,
        ),
        specialRules: const [],
        numericSpecialRules: const {},
        drawEvents: const [],
        points: 100,
      );

      final maxDefenseUnit = Unit(
        name: 'Fortress',
        faction: 'Test',
        type: 'infantry',
        regimentClass: 'heavy',
        characteristics: const UnitCharacteristics(
          march: 2,
          volley: 1,
          clash: 6,
          attacks: 1,
          wounds: 10,
          resolve: 6,
          defense: 5, // Maximum defense
          evasion: 1,
        ),
        specialRules: const [],
        numericSpecialRules: const {},
        drawEvents: const [],
        points: 400,
      );

      final regiments = [
        Regiment(
            unit: minDefenseUnit,
            stands: 1,
            pointsCost: 100), // Defense 1, 2 wounds
        Regiment(
            unit: maxDefenseUnit,
            stands: 1,
            pointsCost: 400), // Defense 5, 10 wounds
      ];

      final armyList = ArmyList(
        name: 'Extreme Defense Army',
        faction: 'Test',
        totalPoints: 500,
        pointsLimit: 2000,
        regiments: regiments,
      );

      final score = scoringEngine.calculateScores(armyList);

      // Min: Defense 1 × 2 wounds = 2
      // Max: Defense 5 × 10 wounds = 50
      // Total: (2 + 50) / (2 + 10) = 52 / 12 ≈ 4.33
      expect(score.toughness, closeTo(4.33, 0.01));
    });

    test('should include toughness in shareable text format', () {
      final regiments = [
        Regiment(unit: mediumDefenseUnit, stands: 2, pointsCost: 200),
        Regiment(unit: highDefenseUnit, stands: 1, pointsCost: 200),
      ];

      final armyList = ArmyList(
        name: 'Toughness Test Army',
        faction: 'Test',
        totalPoints: 400,
        pointsLimit: 2000,
        regiments: regiments,
      );

      final score = scoringEngine.calculateScores(armyList);
      final shareableText = score.toShareableText();

      expect(
          shareableText, contains('Army List Analysis: Toughness Test Army'));
      expect(shareableText, contains('Toughness:'));
      expect(shareableText, contains('Calculated:'));
    });

    test('should handle large armies with consistent performance', () {
      final regiments = <Regiment>[];

      // Create a large army with mixed defense values
      for (int i = 0; i < 30; i++) {
        regiments
            .add(Regiment(unit: lowDefenseUnit, stands: 1, pointsCost: 120));
      }
      for (int i = 0; i < 20; i++) {
        regiments
            .add(Regiment(unit: mediumDefenseUnit, stands: 1, pointsCost: 160));
      }
      for (int i = 0; i < 10; i++) {
        regiments
            .add(Regiment(unit: highDefenseUnit, stands: 1, pointsCost: 200));
      }

      final armyList = ArmyList(
        name: 'Large Army',
        faction: 'Test',
        totalPoints: 8800,
        pointsLimit: 10000,
        regiments: regiments,
      );

      final score = scoringEngine.calculateScores(armyList);

      // 30 × (Defense 1 × 4 wounds) = 120
      // 20 × (Defense 2 × 5 wounds) = 200
      // 10 × (Defense 4 × 6 wounds) = 240
      // Total: (120 + 200 + 240) / (120 + 100 + 60) = 560 / 280 = 2.0
      expect(score.toughness, equals(2.0));
      expect(score.toughness, greaterThan(0.0));
    });

    test('should maintain backwards compatibility with existing scoring', () {
      final regiments = [
        Regiment(unit: mediumDefenseUnit, stands: 2, pointsCost: 200),
        Regiment(unit: highDefenseUnit, stands: 1, pointsCost: 200),
      ];

      final armyList = ArmyList(
        name: 'Backwards Compatible Army',
        faction: 'Test',
        totalPoints: 400,
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

      // And new toughness score
      expect(score.toughness, greaterThan(0.0));

      // Verify toString includes toughness
      final stringOutput = score.toString();
      expect(stringOutput, contains('toughness:'));
    });

    test('should handle mixed army with characters and various defenses', () {
      final regiments = [
        Regiment(
            unit: characterUnit,
            stands: 1,
            pointsCost: 150), // Defense 5, excluded
        Regiment(
            unit: lowDefenseUnit,
            stands: 2,
            pointsCost: 200), // Defense 1, 8 wounds
        Regiment(
            unit: mediumDefenseUnit,
            stands: 1,
            pointsCost: 160), // Defense 2, 5 wounds
        Regiment(
            unit: highDefenseUnit,
            stands: 1,
            pointsCost: 200), // Defense 4, 6 wounds
      ];

      final armyList = ArmyList(
        name: 'Complex Mixed Army',
        faction: 'Test',
        totalPoints: 710,
        pointsLimit: 2000,
        regiments: regiments,
      );

      final score = scoringEngine.calculateScores(armyList);

      // Character excluded
      // Low: Defense 1 × 8 wounds = 8
      // Medium: Defense 2 × 5 wounds = 10
      // High: Defense 4 × 6 wounds = 24
      // Total: (8 + 10 + 24) / (8 + 5 + 6) = 42 / 19 ≈ 2.21
      expect(score.toughness, closeTo(2.21, 0.01));

      // Verify other scores still work correctly
      expect(score.totalWounds, equals(19)); // Characters excluded from wounds
      expect(score.expectedHitVolume,
          greaterThan(0.0)); // Characters included in hit volume
    });

    test('should round to one decimal place correctly', () {
      final regiments = [
        Regiment(
            unit: lowDefenseUnit,
            stands: 1,
            pointsCost: 120), // Defense 1, 4 wounds
        Regiment(
            unit: mediumDefenseUnit,
            stands: 1,
            pointsCost: 160), // Defense 2, 5 wounds
        Regiment(
            unit: highDefenseUnit,
            stands: 1,
            pointsCost: 200), // Defense 4, 6 wounds
      ];

      final armyList = ArmyList(
        name: 'Precision Test Army',
        faction: 'Test',
        totalPoints: 480,
        pointsLimit: 2000,
        regiments: regiments,
      );

      final score = scoringEngine.calculateScores(armyList);

      // Defense 1 × 4 = 4, Defense 2 × 5 = 10, Defense 4 × 6 = 24
      // Total: (4 + 10 + 24) / (4 + 5 + 6) = 38 / 15 ≈ 2.5333...
      expect(score.toughness, closeTo(2.53, 0.01));

      // Verify it displays as one decimal place
      final shareableText = score.toShareableText();
      expect(shareableText, contains('Toughness: 2.5'));
    });
  });
}
