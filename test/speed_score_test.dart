import 'package:flutter_test/flutter_test.dart';
import 'package:conquest_analyzer/services/scoring_engine.dart';
import 'package:conquest_analyzer/models/army_list.dart';
import 'package:conquest_analyzer/models/regiment.dart';
import 'package:conquest_analyzer/models/unit.dart';

void main() {
  group('Speed Score Tests', () {
    late ScoringEngine scoringEngine;
    late Unit fastUnit;
    late Unit mediumUnit;
    late Unit slowUnit;
    late Unit characterUnit;
    late Unit unitWithNullMarch;

    setUp(() {
      scoringEngine = ScoringEngine();

      fastUnit = Unit(
        name: 'Fast Cavalry',
        faction: 'Test',
        type: 'cavalry',
        regimentClass: 'light',
        characteristics: const UnitCharacteristics(
          march: 8, // Fast movement
          volley: 1,
          clash: 3,
          attacks: 4,
          wounds: 4,
          resolve: 3,
          defense: 2,
          evasion: 1,
        ),
        specialRules: const [],
        numericSpecialRules: const {},
        supremacyAbilities: const [],
        drawEvents: const [],
        points: 150,
      );

      mediumUnit = Unit(
        name: 'Standard Infantry',
        faction: 'Test',
        type: 'infantry',
        regimentClass: 'medium',
        characteristics: const UnitCharacteristics(
          march: 6, // Medium movement
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
        points: 140,
      );

      slowUnit = Unit(
        name: 'Heavy Infantry',
        faction: 'Test',
        type: 'infantry',
        regimentClass: 'heavy',
        characteristics: const UnitCharacteristics(
          march: 4, // Slow movement
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
        points: 180,
      );

      characterUnit = Unit(
        name: 'Test Character',
        faction: 'Test',
        type: 'character',
        regimentClass: 'character',
        characteristics: const UnitCharacteristics(
          march: 10, // Very fast character - should be excluded
          volley: 1,
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
        points: 120,
      );

      unitWithNullMarch = Unit(
        name: 'Immobile Unit',
        faction: 'Test',
        type: 'siege',
        regimentClass: 'heavy',
        characteristics: const UnitCharacteristics(
          march: null, // No movement
          volley: 5,
          clash: 2,
          attacks: 2,
          wounds: 8,
          resolve: 4,
          defense: 4,
          evasion: 1,
        ),
        specialRules: const [],
        numericSpecialRules: const {},
        supremacyAbilities: const [],
        drawEvents: const [],
        points: 200,
      );
    });

    test('should calculate average speed correctly for single regiment', () {
      final regiments = [
        Regiment(unit: mediumUnit, stands: 2, pointsCost: 200),
      ];

      final armyList = ArmyList(
        name: 'Single Regiment Army',
        faction: 'Test',
        totalPoints: 200,
        pointsLimit: 2000,
        regiments: regiments,
      );

      final score = scoringEngine.calculateScores(armyList);
      expect(score.averageSpeed, equals(6.0)); // Only one regiment with move 6
    });

    test('should calculate average speed correctly for multiple regiments', () {
      final regiments = [
        Regiment(unit: fastUnit, stands: 1, pointsCost: 150), // Move 8
        Regiment(unit: mediumUnit, stands: 2, pointsCost: 200), // Move 6
        Regiment(unit: slowUnit, stands: 1, pointsCost: 180), // Move 4
      ];

      final armyList = ArmyList(
        name: 'Mixed Speed Army',
        faction: 'Test',
        totalPoints: 530,
        pointsLimit: 2000,
        regiments: regiments,
      );

      final score = scoringEngine.calculateScores(armyList);
      // Average of 8, 6, 4 = 18/3 = 6.0
      expect(score.averageSpeed, equals(6.0));
    });

    test('should exclude characters from speed calculation', () {
      final regiments = [
        Regiment(
            unit: characterUnit,
            stands: 1,
            pointsCost: 120), // Move 10 - character (excluded)
        Regiment(unit: mediumUnit, stands: 2, pointsCost: 200), // Move 6
        Regiment(unit: slowUnit, stands: 1, pointsCost: 180), // Move 4
      ];

      final armyList = ArmyList(
        name: 'Army with Character',
        faction: 'Test',
        totalPoints: 500,
        pointsLimit: 2000,
        regiments: regiments,
      );

      final score = scoringEngine.calculateScores(armyList);
      // Average of 6, 4 (character excluded) = 10/2 = 5.0
      expect(score.averageSpeed, equals(5.0));
    });

    test('should handle units with null march values', () {
      final regiments = [
        Regiment(
            unit: unitWithNullMarch,
            stands: 1,
            pointsCost: 200), // Move null (treated as 0)
        Regiment(unit: mediumUnit, stands: 1, pointsCost: 140), // Move 6
      ];

      final armyList = ArmyList(
        name: 'Army with Immobile Unit',
        faction: 'Test',
        totalPoints: 340,
        pointsLimit: 2000,
        regiments: regiments,
      );

      final score = scoringEngine.calculateScores(armyList);
      // Average of 0, 6 = 6/2 = 3.0
      expect(score.averageSpeed, equals(3.0));
    });

    test('should return 0 for army with only characters', () {
      final regiments = [
        Regiment(unit: characterUnit, stands: 1, pointsCost: 120),
      ];

      final armyList = ArmyList(
        name: 'Character Only Army',
        faction: 'Test',
        totalPoints: 120,
        pointsLimit: 2000,
        regiments: regiments,
      );

      final score = scoringEngine.calculateScores(armyList);
      expect(score.averageSpeed, equals(0.0)); // No regiments to calculate
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
      expect(score.averageSpeed, equals(0.0));
    });

    test('should handle all regiments having the same speed', () {
      final regiments = [
        Regiment(unit: mediumUnit, stands: 1, pointsCost: 140), // Move 6
        Regiment(unit: mediumUnit, stands: 2, pointsCost: 200), // Move 6
        Regiment(unit: mediumUnit, stands: 3, pointsCost: 260), // Move 6
      ];

      final armyList = ArmyList(
        name: 'Uniform Speed Army',
        faction: 'Test',
        totalPoints: 600,
        pointsLimit: 2000,
        regiments: regiments,
      );

      final score = scoringEngine.calculateScores(armyList);
      expect(score.averageSpeed, equals(6.0)); // All units have move 6
    });

    test('should calculate speed with high precision values', () {
      final regiment1Unit = Unit(
        name: 'Precise Unit 1',
        faction: 'Test',
        type: 'cavalry',
        regimentClass: 'light',
        characteristics: const UnitCharacteristics(
          march: 7, // Move 7
          volley: 1,
          clash: 3,
          attacks: 4,
          wounds: 4,
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

      final regiment2Unit = Unit(
        name: 'Precise Unit 2',
        faction: 'Test',
        type: 'infantry',
        regimentClass: 'medium',
        characteristics: const UnitCharacteristics(
          march: 5, // Move 5
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
        points: 130,
      );

      final regiments = [
        Regiment(unit: regiment1Unit, stands: 1, pointsCost: 160), // Move 7
        Regiment(unit: regiment2Unit, stands: 1, pointsCost: 130), // Move 5
      ];

      final armyList = ArmyList(
        name: 'Precise Speed Army',
        faction: 'Test',
        totalPoints: 290,
        pointsLimit: 2000,
        regiments: regiments,
      );

      final score = scoringEngine.calculateScores(armyList);
      // Average of 7, 5 = 12/2 = 6.0
      expect(score.averageSpeed, equals(6.0));
    });

    test('should handle fractional averages correctly', () {
      final regiment1Unit = Unit(
        name: 'Unit A',
        faction: 'Test',
        type: 'cavalry',
        regimentClass: 'light',
        characteristics: const UnitCharacteristics(
          march: 8, // Move 8
          volley: 1,
          clash: 3,
          attacks: 4,
          wounds: 4,
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

      final regiment2Unit = Unit(
        name: 'Unit B',
        faction: 'Test',
        type: 'infantry',
        regimentClass: 'medium',
        characteristics: const UnitCharacteristics(
          march: 5, // Move 5
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
        points: 130,
      );

      final regiment3Unit = Unit(
        name: 'Unit C',
        faction: 'Test',
        type: 'infantry',
        regimentClass: 'heavy',
        characteristics: const UnitCharacteristics(
          march: 4, // Move 4
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
        points: 180,
      );

      final regiments = [
        Regiment(unit: regiment1Unit, stands: 1, pointsCost: 160), // Move 8
        Regiment(unit: regiment2Unit, stands: 1, pointsCost: 130), // Move 5
        Regiment(unit: regiment3Unit, stands: 1, pointsCost: 180), // Move 4
      ];

      final armyList = ArmyList(
        name: 'Fractional Average Army',
        faction: 'Test',
        totalPoints: 470,
        pointsLimit: 2000,
        regiments: regiments,
      );

      final score = scoringEngine.calculateScores(armyList);
      // Average of 8, 5, 4 = 17/3 = 5.666...
      expect(score.averageSpeed, closeTo(5.67, 0.01));
    });

    test('should include speed in shareable text format', () {
      final regiments = [
        Regiment(unit: fastUnit, stands: 1, pointsCost: 150), // Move 8
        Regiment(unit: mediumUnit, stands: 1, pointsCost: 140), // Move 6
      ];

      final armyList = ArmyList(
        name: 'Speed Test Army',
        faction: 'Test',
        totalPoints: 290,
        pointsLimit: 2000,
        regiments: regiments,
      );

      final score = scoringEngine.calculateScores(armyList);
      final shareableText = score.toShareableText();

      expect(shareableText, contains('Army List Analysis: Speed Test Army'));
      expect(shareableText, contains('Average Speed: 7.0'));
      expect(shareableText, contains('Calculated:'));
    });

    test('should handle mixed army with characters and regiments for speed',
        () {
      final regiments = [
        Regiment(
            unit: characterUnit,
            stands: 1,
            pointsCost: 120), // Move 10 - character (excluded)
        Regiment(unit: fastUnit, stands: 1, pointsCost: 150), // Move 8
        Regiment(unit: mediumUnit, stands: 2, pointsCost: 200), // Move 6
        Regiment(unit: slowUnit, stands: 1, pointsCost: 180), // Move 4
        Regiment(
            unit: unitWithNullMarch, stands: 1, pointsCost: 200), // Move null/0
      ];

      final armyList = ArmyList(
        name: 'Complex Mixed Army',
        faction: 'Test',
        totalPoints: 850,
        pointsLimit: 2000,
        regiments: regiments,
      );

      final score = scoringEngine.calculateScores(armyList);
      // Average of 8, 6, 4, 0 (character excluded) = 18/4 = 4.5
      expect(score.averageSpeed, equals(4.5));

      // Verify other scores still work correctly
      expect(score.totalWounds, greaterThan(0));
      expect(score.expectedHitVolume, greaterThan(0.0));
      expect(score.averageSpeed, greaterThan(0.0));
    });

    test('should maintain backwards compatibility with existing scoring', () {
      final regiments = [
        Regiment(unit: mediumUnit, stands: 2, pointsCost: 200),
        Regiment(unit: slowUnit, stands: 1, pointsCost: 180),
      ];

      final armyList = ArmyList(
        name: 'Backwards Compatible Army',
        faction: 'Test',
        totalPoints: 380,
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

      // And new speed score
      expect(score.averageSpeed, equals(5.0)); // Average of 6, 4

      // Verify toString includes speed
      final stringOutput = score.toString();
      expect(stringOutput, contains('avgSpeed: 5.0'));
    });

    test('should handle extreme speed values correctly', () {
      final veryFastUnit = Unit(
        name: 'Super Fast Unit',
        faction: 'Test',
        type: 'flying',
        regimentClass: 'light',
        characteristics: const UnitCharacteristics(
          march: 15, // Very fast
          volley: 1,
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
        points: 200,
      );

      final verySlowUnit = Unit(
        name: 'Super Slow Unit',
        faction: 'Test',
        type: 'siege',
        regimentClass: 'heavy',
        characteristics: const UnitCharacteristics(
          march: 1, // Very slow
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
        points: 300,
      );

      final regiments = [
        Regiment(unit: veryFastUnit, stands: 1, pointsCost: 200), // Move 15
        Regiment(unit: verySlowUnit, stands: 1, pointsCost: 300), // Move 1
      ];

      final armyList = ArmyList(
        name: 'Extreme Speed Army',
        faction: 'Test',
        totalPoints: 500,
        pointsLimit: 2000,
        regiments: regiments,
      );

      final score = scoringEngine.calculateScores(armyList);
      // Average of 15, 1 = 16/2 = 8.0
      expect(score.averageSpeed, equals(8.0));
    });
  });
}
