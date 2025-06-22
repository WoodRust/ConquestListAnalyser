import 'package:flutter_test/flutter_test.dart';
import 'package:conquest_analyzer/services/scoring_engine.dart';
import 'package:conquest_analyzer/models/army_list.dart';
import 'package:conquest_analyzer/models/regiment.dart';
import 'package:conquest_analyzer/models/unit.dart';

void main() {
  group('ScoringEngine Integration Tests with Speed', () {
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
          march: 6, // Standard movement
          volley: 2,
          clash: 3,
          attacks: 4,
          wounds: 5,
          resolve: 3,
          defense: 2,
          evasion: 1,
        ),
        specialRules: const [],
        numericSpecialRules: const {},
        drawEvents: const [],
        points: 140,
      );

      testUnitWithCleave = Unit(
        name: 'Cleaving Unit',
        faction: 'Test',
        type: 'brute',
        regimentClass: 'heavy',
        characteristics: const UnitCharacteristics(
          march: 5, // Slower movement due to heavy armor
          volley: 1,
          clash: 3,
          attacks: 5,
          wounds: 6,
          resolve: 4,
          defense: 3,
          evasion: 1,
        ),
        specialRules: const [],
        numericSpecialRules: const {'cleave': 2},
        drawEvents: const [],
        points: 200,
      );

      testUnitWithBarrage = Unit(
        name: 'Archer Unit',
        faction: 'Test',
        type: 'infantry',
        regimentClass: 'light',
        characteristics: const UnitCharacteristics(
          march: 7, // Fast movement for repositioning
          volley: 4,
          clash: 2,
          attacks: 3,
          wounds: 4,
          resolve: 2,
          defense: 1,
          evasion: 1,
        ),
        specialRules: const [],
        numericSpecialRules: const {
          'barrage': 3,
          'armorPiercingValue': 1,
          'barrageRange': 24
        },
        drawEvents: const [],
        points: 160,
      );

      testCharacterUnit = Unit(
        name: 'Test Character',
        faction: 'Test',
        type: 'character',
        regimentClass: 'character',
        characteristics: const UnitCharacteristics(
          march: 8, // Character movement (excluded from speed calculation)
          volley: 3,
          clash: 4,
          attacks: 6,
          wounds: 3,
          resolve: 4,
          defense: 3,
          evasion: 2,
        ),
        specialRules: const [],
        numericSpecialRules: const {'cleave': 1, 'barrage': 1},
        drawEvents: const [],
        points: 150,
      );
    });

    test('should calculate complete score sheet including speed', () {
      final regiments = [
        Regiment(unit: testUnitBasic, stands: 2, pointsCost: 200), // Move 6
        Regiment(
            unit: testUnitWithCleave, stands: 1, pointsCost: 200), // Move 5
        Regiment(
            unit: testUnitWithBarrage, stands: 1, pointsCost: 160), // Move 7
        Regiment(
            unit: testCharacterUnit,
            stands: 1,
            pointsCost: 150), // Move 8 (excluded)
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
      expect(score.totalWounds, greaterThan(0));
      expect(score.pointsPerWound, greaterThan(0.0));
      expect(score.expectedHitVolume, greaterThan(0.0));
      expect(score.cleaveRating, greaterThan(0.0)); // From cleave units
      expect(score.rangedExpectedHits, greaterThan(0.0)); // From barrage units
      expect(score.rangedArmorPiercingRating,
          greaterThan(0.0)); // From armor piercing
      expect(score.maxRange, equals(24)); // From barrage range

      // Verify speed calculation: average of 6, 5, 7 (character excluded) = 18/3 = 6.0
      expect(score.averageSpeed, equals(6.0));

      // Verify all metrics are included in shareable text
      final shareableText = score.toShareableText();
      expect(shareableText, contains('Total Wounds:'));
      expect(shareableText, contains('Points per Wound:'));
      expect(shareableText, contains('Expected Hit Volume:'));
      expect(shareableText, contains('Cleave Rating:'));
      expect(shareableText, contains('Ranged Expected Hits:'));
      expect(shareableText, contains('Ranged Armor Piercing:'));
      expect(shareableText, contains('Max Range: 24'));
      expect(shareableText, contains('Average Speed: 6.0'));
    });

    test('should handle army with only fast units', () {
      final fastCavalryUnit = Unit(
        name: 'Fast Cavalry',
        faction: 'Test',
        type: 'cavalry',
        regimentClass: 'light',
        characteristics: const UnitCharacteristics(
          march: 9, // Very fast
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
        drawEvents: const [],
        points: 170,
      );

      final regiments = [
        Regiment(unit: fastCavalryUnit, stands: 2, pointsCost: 290),
        Regiment(unit: fastCavalryUnit, stands: 1, pointsCost: 170),
      ];

      final armyList = ArmyList(
        name: 'Fast Army',
        faction: 'Test',
        totalPoints: 460,
        pointsLimit: 2000,
        regiments: regiments,
      );

      final score = scoringEngine.calculateScores(armyList);
      expect(score.averageSpeed, equals(9.0)); // All units have move 9
      expect(score.totalWounds, equals(12)); // 2*4 + 1*4 = 12 wounds
    });

    test('should handle army with only slow units', () {
      final heavyInfantryUnit = Unit(
        name: 'Heavy Infantry',
        faction: 'Test',
        type: 'infantry',
        regimentClass: 'heavy',
        characteristics: const UnitCharacteristics(
          march: 3, // Very slow
          volley: 1,
          clash: 4,
          attacks: 3,
          wounds: 7,
          resolve: 4,
          defense: 4,
          evasion: 1,
        ),
        specialRules: const [],
        numericSpecialRules: const {'cleave': 3},
        drawEvents: const [],
        points: 220,
      );

      final regiments = [
        Regiment(unit: heavyInfantryUnit, stands: 2, pointsCost: 350),
        Regiment(unit: heavyInfantryUnit, stands: 1, pointsCost: 220),
      ];

      final armyList = ArmyList(
        name: 'Slow Army',
        faction: 'Test',
        totalPoints: 570,
        pointsLimit: 2000,
        regiments: regiments,
      );

      final score = scoringEngine.calculateScores(armyList);
      expect(score.averageSpeed, equals(3.0)); // All units have move 3
      expect(score.cleaveRating, greaterThan(0.0)); // Should have high cleave
    });

    test('should handle mixed speed army with various special rules', () {
      final regiments = [
        Regiment(
            unit: testUnitBasic,
            stands: 3,
            pointsCost: 280), // Move 6, no special rules
        Regiment(
            unit: testUnitWithCleave,
            stands: 2,
            pointsCost: 350), // Move 5, cleave
        Regiment(
            unit: testUnitWithBarrage,
            stands: 1,
            pointsCost: 160), // Move 7, barrage + AP
        Regiment(
            unit: testCharacterUnit,
            stands: 1,
            pointsCost: 150), // Move 8, character (excluded from speed)
      ];

      final armyList = ArmyList(
        name: 'Mixed Capabilities Army',
        faction: 'Test',
        totalPoints: 940,
        pointsLimit: 2000,
        regiments: regiments,
      );

      final score = scoringEngine.calculateScores(armyList);

      // Speed: average of 6, 5, 7 (character excluded) = 18/3 = 6.0
      expect(score.averageSpeed, equals(6.0));

      // Verify other capabilities
      expect(
          score.totalWounds,
          equals(
              31)); // 3*5 + 2*6 + 1*4 = 15 + 12 + 4 = 31 (excluding character)
      expect(score.cleaveRating,
          greaterThan(0.0)); // From cleave units + character
      expect(score.rangedExpectedHits,
          greaterThan(0.0)); // From barrage units + character
      expect(score.rangedArmorPiercingRating,
          greaterThan(0.0)); // From armor piercing
      expect(score.maxRange, equals(24)); // From barrage range
    });

    test('should handle edge case with null march values in mixed army', () {
      final immobileUnit = Unit(
        name: 'Artillery Piece',
        faction: 'Test',
        type: 'siege',
        regimentClass: 'heavy',
        characteristics: const UnitCharacteristics(
          march: null, // Cannot move
          volley: 6,
          clash: 1,
          attacks: 1,
          wounds: 8,
          resolve: 5,
          defense: 5,
          evasion: 1,
        ),
        specialRules: const [],
        numericSpecialRules: const {
          'barrage': 5,
          'armorPiercingValue': 4,
          'barrageRange': 36
        },
        drawEvents: const [],
        points: 300,
      );

      final regiments = [
        Regiment(unit: immobileUnit, stands: 1, pointsCost: 300), // Move null/0
        Regiment(unit: testUnitBasic, stands: 2, pointsCost: 200), // Move 6
        Regiment(
            unit: testUnitWithBarrage, stands: 1, pointsCost: 160), // Move 7
      ];

      final armyList = ArmyList(
        name: 'Artillery Army',
        faction: 'Test',
        totalPoints: 660,
        pointsLimit: 2000,
        regiments: regiments,
      );

      final score = scoringEngine.calculateScores(armyList);

      // Speed: average of 0, 6, 7 = 13/3 ≈ 4.33
      expect(score.averageSpeed, closeTo(4.33, 0.01));
      expect(score.maxRange, equals(36)); // From artillery
      expect(score.rangedArmorPiercingRating,
          greaterThan(0.0)); // High AP from artillery
    });

    test('should maintain precision in speed calculations', () {
      final unit1 = Unit(
        name: 'Unit 1',
        faction: 'Test',
        type: 'infantry',
        regimentClass: 'medium',
        characteristics: const UnitCharacteristics(
          march: 7,
          volley: 2,
          clash: 3,
          attacks: 4,
          wounds: 5,
          resolve: 3,
          defense: 2,
          evasion: 1,
        ),
        specialRules: const [],
        numericSpecialRules: const {},
        drawEvents: const [],
        points: 150,
      );

      final unit2 = Unit(
        name: 'Unit 2',
        faction: 'Test',
        type: 'infantry',
        regimentClass: 'medium',
        characteristics: const UnitCharacteristics(
          march: 8,
          volley: 2,
          clash: 3,
          attacks: 4,
          wounds: 5,
          resolve: 3,
          defense: 2,
          evasion: 1,
        ),
        specialRules: const [],
        numericSpecialRules: const {},
        drawEvents: const [],
        points: 160,
      );

      final regiments = [
        Regiment(unit: unit1, stands: 1, pointsCost: 150), // Move 7
        Regiment(unit: unit2, stands: 1, pointsCost: 160), // Move 8
        Regiment(unit: testUnitBasic, stands: 1, pointsCost: 140), // Move 6
      ];

      final armyList = ArmyList(
        name: 'Precision Test Army',
        faction: 'Test',
        totalPoints: 450,
        pointsLimit: 2000,
        regiments: regiments,
      );

      final score = scoringEngine.calculateScores(armyList);

      // Speed: average of 7, 8, 6 = 21/3 = 7.0
      expect(score.averageSpeed, equals(7.0));

      // Verify string representation includes speed
      final stringOutput = score.toString();
      expect(stringOutput, contains('avgSpeed: 7.0'));
    });

    test('should work correctly with existing scoring metrics', () {
      // This test ensures the speed feature doesn't break any existing functionality
      final regiments = [
        Regiment(unit: testUnitWithCleave, stands: 2, pointsCost: 350),
        Regiment(unit: testUnitWithBarrage, stands: 1, pointsCost: 160),
      ];

      final armyList = ArmyList(
        name: 'Backwards Compatibility Test',
        faction: 'Test',
        totalPoints: 510,
        pointsLimit: 2000,
        regiments: regiments,
      );

      final score = scoringEngine.calculateScores(armyList);

      // Verify all existing metrics still work
      expect(score.armyList, equals(armyList));
      expect(score.totalWounds, equals(16)); // 2*6 + 1*4 = 16
      expect(score.pointsPerWound, equals(31.875)); // 510/16
      expect(score.expectedHitVolume, greaterThan(0.0));
      expect(score.cleaveRating, greaterThan(0.0));
      expect(score.rangedExpectedHits, greaterThan(0.0));
      expect(score.rangedArmorPiercingRating, greaterThan(0.0));
      expect(score.maxRange, equals(24));
      expect(score.calculatedAt, isA<DateTime>());

      // And new speed metric
      expect(score.averageSpeed, equals(6.0)); // Average of 5, 7 = 6.0

      // Verify shareable text includes all metrics
      final shareableText = score.toShareableText();
      expect(shareableText,
          contains('Army List Analysis: Backwards Compatibility Test'));
      expect(shareableText, contains('Faction: Test'));
      expect(shareableText, contains('Points: 510/2000'));
      expect(shareableText, contains('Total Wounds: 16'));
      expect(shareableText, contains('Points per Wound: 31.88'));
      expect(shareableText, contains('Average Speed: 6.0'));
    });
  });
}
