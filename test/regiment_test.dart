import 'package:flutter_test/flutter_test.dart';
import 'package:conquest_analyzer/models/regiment.dart';
import 'package:conquest_analyzer/models/unit.dart';

void main() {
  group('Regiment Model Tests', () {
    late Unit unitWithCleave;
    late Unit unitWithoutCleave;
    late Unit unitWithFlurry;
    late Unit unitWithBarrage;
    late Unit unitWithBarrageAndLeader;
    late Unit unitWithBarrageRange;

    setUp(() {
      unitWithCleave = Unit(
        name: 'Cleaving Warrior',
        faction: 'Nords',
        type: 'infantry',
        regimentClass: 'heavy',
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
        numericSpecialRules: const {'cleave': 3}, // Cleave(3)
        drawEvents: const [],
        points: 180,
        pointsPerAdditionalStand: 60,
      );

      unitWithoutCleave = Unit(
        name: 'Basic Warrior',
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
          evasion: 1,
        ),
        specialRules: const [],
        numericSpecialRules: const {}, // No cleave
        drawEvents: const [],
        points: 120,
        pointsPerAdditionalStand: 40,
      );

      unitWithFlurry = Unit(
        name: 'Flurry Fighter',
        faction: 'Nords',
        type: 'infantry',
        regimentClass: 'medium',
        characteristics: const UnitCharacteristics(
          march: 6,
          volley: 1,
          clash: 2,
          attacks: 5,
          wounds: 4,
          resolve: 3,
          defense: 2,
          evasion: 1,
        ),
        specialRules: const [
          SpecialRule(
            name: 'Flurry',
            description:
                'This Stand may re-roll failed Hit rolls when performing a Clash Action.',
          )
        ],
        numericSpecialRules: const {'cleave': 1}, // Has both flurry and cleave
        drawEvents: const [],
        points: 150,
        pointsPerAdditionalStand: 50,
      );

      unitWithBarrage = Unit(
        name: 'Archer Unit',
        faction: 'Test',
        type: 'infantry',
        regimentClass: 'light',
        characteristics: const UnitCharacteristics(
          march: 6,
          volley: 3, // Good volley for ranged combat
          clash: 2,
          attacks: 3,
          wounds: 4,
          resolve: 2,
          defense: 1,
          evasion: 1,
        ),
        specialRules: const [],
        numericSpecialRules: const {'barrage': 2}, // Barrage(2)
        drawEvents: const [],
        points: 140,
        pointsPerAdditionalStand: 45,
      );

      unitWithBarrageAndLeader = Unit(
        name: 'Elite Archers',
        faction: 'Test',
        type: 'infantry',
        regimentClass: 'medium',
        characteristics: const UnitCharacteristics(
          march: 6,
          volley: 4, // Better volley
          clash: 3,
          attacks: 3,
          wounds: 5,
          resolve: 3,
          defense: 2,
          evasion: 1,
        ),
        specialRules: const [
          SpecialRule(
            name: 'Leader',
            description: 'This unit has a leader.',
          )
        ],
        numericSpecialRules: const {'barrage': 3}, // Barrage(3)
        drawEvents: const [],
        points: 180,
        pointsPerAdditionalStand: 60,
      );

      unitWithBarrageRange = Unit(
        name: 'Long Range Archers',
        faction: 'Test',
        type: 'infantry',
        regimentClass: 'heavy',
        characteristics: const UnitCharacteristics(
          march: 5,
          volley: 4,
          clash: 2,
          attacks: 2,
          wounds: 4,
          resolve: 3,
          defense: 2,
          evasion: 1,
        ),
        specialRules: const [],
        numericSpecialRules: const {
          'barrage': 2,
          'barrageRange': 24
        }, // Barrage(2) with 24" range
        drawEvents: const [],
        points: 160,
        pointsPerAdditionalStand: 55,
      );
    });

    test('should return correct cleave value from numeric special rules', () {
      final regimentWithCleave = Regiment(
        unit: unitWithCleave,
        stands: 2,
        pointsCost: 240,
      );

      final regimentWithoutCleave = Regiment(
        unit: unitWithoutCleave,
        stands: 3,
        pointsCost: 200,
      );

      expect(regimentWithCleave.cleaveValue, equals(3));
      expect(regimentWithoutCleave.cleaveValue, equals(0));
    });

    test('should return correct barrage value from numeric special rules', () {
      final regimentWithBarrage = Regiment(
        unit: unitWithBarrage,
        stands: 2,
        pointsCost: 230,
      );

      final regimentWithoutBarrage = Regiment(
        unit: unitWithoutCleave,
        stands: 3,
        pointsCost: 200,
      );

      expect(regimentWithBarrage.barrageValue, equals(2));
      expect(regimentWithoutBarrage.barrageValue, equals(0));
    });

    test('should return correct barrage range from numeric special rules', () {
      final regimentWithRange = Regiment(
        unit: unitWithBarrageRange,
        stands: 2,
        pointsCost: 270,
      );

      final regimentWithoutRange = Regiment(
        unit: unitWithBarrage,
        stands: 2,
        pointsCost: 230,
      );

      final regimentWithNoRangedCapability = Regiment(
        unit: unitWithoutCleave,
        stands: 3,
        pointsCost: 200,
      );

      expect(regimentWithRange.barrageRange, equals(24));
      expect(regimentWithoutRange.barrageRange,
          equals(0)); // Has barrage but no range specified
      expect(regimentWithNoRangedCapability.barrageRange,
          equals(0)); // No ranged capability
    });

    test('should calculate ranged expected hits correctly', () {
      final regiment = Regiment(
        unit: unitWithBarrage,
        stands: 3,
        pointsCost: 320,
      );

      // 3 stands * 2 barrage = 6 total barrage
      // Volley 3 = 3/6 = 0.5 hit chance
      // Expected ranged hits = 6 * 0.5 = 3.0
      final rangedHits = regiment.calculateRangedExpectedHits();
      expect(rangedHits, closeTo(3.0, 0.1));
    });

    test('should calculate ranged expected hits with leader correctly', () {
      final regiment = Regiment(
        unit: unitWithBarrageAndLeader,
        stands: 2,
        pointsCost: 300,
      );

      // 2 stands * 3 barrage = 6 base barrage
      // +1 for leader = 7 total barrage
      // Volley 4 = 4/6 = 0.667 hit chance
      // Expected ranged hits = 7 * 0.667 = 4.67
      final rangedHits = regiment.calculateRangedExpectedHits();
      expect(rangedHits, closeTo(4.67, 0.1));
    });

    test('should return zero ranged hits for units without barrage', () {
      final regiment = Regiment(
        unit: unitWithoutCleave,
        stands: 3,
        pointsCost: 200,
      );

      expect(regiment.barrageValue, equals(0));
      expect(regiment.calculateRangedExpectedHits(), equals(0.0));
    });

    test('should not add leader bonus to units without barrage capability', () {
      // Create a unit with leader but no barrage
      final unitWithLeaderNoBarrage = Unit(
        name: 'Leader Without Barrage',
        faction: 'Test',
        type: 'infantry',
        regimentClass: 'medium',
        characteristics: const UnitCharacteristics(
          march: 6,
          volley: 3,
          clash: 3,
          attacks: 4,
          wounds: 4,
          resolve: 3,
          defense: 2,
          evasion: 1,
        ),
        specialRules: const [
          SpecialRule(
            name: 'Leader',
            description: 'This unit has a leader.',
          )
        ],
        numericSpecialRules: const {}, // No barrage - cannot shoot
        drawEvents: const [],
        points: 160,
        pointsPerAdditionalStand: 50,
      );

      final regiment = Regiment(
        unit: unitWithLeaderNoBarrage,
        stands: 2,
        pointsCost: 260,
      );

      // Even with leader, should have 0 ranged hits because no barrage capability
      expect(regiment.barrageValue, equals(0));
      expect(regiment.calculateRangedExpectedHits(), equals(0.0));
    });

    test('should calculate cleave rating correctly', () {
      final regiment = Regiment(
        unit: unitWithCleave,
        stands: 2,
        pointsCost: 240,
      );

      // 2 stands * 4 attacks = 8 attacks
      // Clash 3 = (3+1)/6 = 4/6 = 0.667 hit chance
      // Expected hits = 8 * 0.667 = 5.33
      // Cleave rating = 5.33 * 3 = 16.0
      final expectedHitVolume = regiment.expectedHitVolume;
      final cleaveRating = regiment.cleaveRating;

      expect(expectedHitVolume, closeTo(5.33, 0.1));
      expect(cleaveRating, closeTo(16.0, 0.5));
    });

    test('should return zero cleave rating for units without cleave', () {
      final regiment = Regiment(
        unit: unitWithoutCleave,
        stands: 3,
        pointsCost: 200,
      );

      expect(regiment.cleaveValue, equals(0));
      expect(regiment.cleaveRating, equals(0.0));
      expect(regiment.expectedHitVolume,
          greaterThan(0.0)); // Should still have hit volume
    });

    test('should calculate cleave rating with flurry correctly', () {
      final regiment = Regiment(
        unit: unitWithFlurry,
        stands: 2,
        pointsCost: 300,
      );

      // 2 stands * 5 attacks = 10 attacks
      // Clash 2 = (2+1)/6 = 3/6 = 0.5 hit chance
      // Base expected hits = 10 * 0.5 = 5.0
      // With Flurry: missed attacks = 10 - 5 = 5
      // Additional hits from re-rolls = 5 * 0.5 = 2.5
      // Total expected hits = 5.0 + 2.5 = 7.5
      // Cleave rating = 7.5 * 1 = 7.5
      final expectedHitVolume = regiment.expectedHitVolume;
      final cleaveRating = regiment.cleaveRating;

      expect(expectedHitVolume, closeTo(7.5, 0.1));
      expect(cleaveRating, closeTo(7.5, 0.1));
    });

    test('should calculate cleave rating with army context', () {
      final regiment = Regiment(
        unit: unitWithCleave,
        stands: 1,
        pointsCost: 180,
      );

      final mockArmyRegiments = [regiment]; // Simple army context
      final cleaveRating =
          regiment.calculateCleaveRating(armyRegiments: mockArmyRegiments);

      // 1 stand * 4 attacks = 4 attacks
      // Clash 3 = (3+1)/6 = 4/6 = 0.667 hit chance
      // Expected hits = 4 * 0.667 = 2.67
      // Cleave rating = 2.67 * 3 = 8.0
      expect(cleaveRating, closeTo(8.0, 0.5));
    });

    test('should handle units with both barrage and cleave', () {
      final hybridUnit = Unit(
        name: 'Hybrid Unit',
        faction: 'Test',
        type: 'infantry',
        regimentClass: 'medium',
        characteristics: const UnitCharacteristics(
          march: 5,
          volley: 3,
          clash: 3,
          attacks: 4,
          wounds: 5,
          resolve: 3,
          defense: 2,
          evasion: 1,
        ),
        specialRules: const [],
        numericSpecialRules: const {'cleave': 2, 'barrage': 1},
        drawEvents: const [],
        points: 200,
        pointsPerAdditionalStand: 65,
      );

      final regiment = Regiment(
        unit: hybridUnit,
        stands: 2,
        pointsCost: 330,
      );

      expect(regiment.cleaveValue, equals(2));
      expect(regiment.barrageValue, equals(1));
      expect(regiment.cleaveRating, greaterThan(0.0));
      expect(regiment.calculateRangedExpectedHits(),
          closeTo(1.0, 0.1)); // 2 * 1 * (3/6)
    });

    test('should handle units with barrage range correctly', () {
      final regiment = Regiment(
        unit: unitWithBarrageRange,
        stands: 2,
        pointsCost: 270,
      );

      expect(regiment.barrageValue, equals(2));
      expect(regiment.barrageRange, equals(24));
      expect(regiment.calculateRangedExpectedHits(), greaterThan(0.0));
    });

    test('should handle edge cases correctly', () {
      // Test with 0 stands (edge case)
      final zeroStandRegiment = Regiment(
        unit: unitWithCleave,
        stands: 0,
        pointsCost: 0,
      );

      expect(zeroStandRegiment.cleaveValue, equals(3));
      expect(zeroStandRegiment.cleaveRating, equals(0.0));
      expect(zeroStandRegiment.expectedHitVolume, equals(0.0));
      expect(zeroStandRegiment.calculateRangedExpectedHits(), equals(0.0));

      // Test with very high cleave value
      final highCleaveUnit = Unit(
        name: 'Super Cleaver',
        faction: 'Test',
        type: 'monster',
        regimentClass: 'heavy',
        characteristics: const UnitCharacteristics(
          march: 4,
          volley: 1,
          clash: 4,
          attacks: 3,
          wounds: 8,
          resolve: 5,
          defense: 4,
          evasion: 1,
        ),
        specialRules: const [],
        numericSpecialRules: const {'cleave': 10}, // Very high cleave
        drawEvents: const [],
        points: 300,
      );

      final highCleaveRegiment = Regiment(
        unit: highCleaveUnit,
        stands: 1,
        pointsCost: 300,
      );

      expect(highCleaveRegiment.cleaveValue, equals(10));
      expect(highCleaveRegiment.cleaveRating,
          greaterThan(20.0)); // Should be significant
    });

    test('should maintain backwards compatibility', () {
      // Ensure existing functionality still works
      final regiment = Regiment(
        unit: unitWithoutCleave,
        stands: 3,
        pointsCost: 200,
      );

      expect(regiment.totalWounds, equals(12)); // 4 wounds * 3 stands
      expect(regiment.pointsPerWound, closeTo(16.67, 0.1)); // 200 / 12
      expect(regiment.expectedHitVolume, greaterThan(0.0));
      expect(regiment.stands, equals(3));
      expect(regiment.pointsCost, equals(200));
    });

    test('should calculate ranged hits with high volley values correctly', () {
      final highVolleyUnit = Unit(
        name: 'Elite Crossbows',
        faction: 'Test',
        type: 'infantry',
        regimentClass: 'heavy',
        characteristics: const UnitCharacteristics(
          march: 5,
          volley: 6, // Maximum volley (always hits)
          clash: 2,
          attacks: 2,
          wounds: 4,
          resolve: 3,
          defense: 2,
          evasion: 1,
        ),
        specialRules: const [],
        numericSpecialRules: const {'barrage': 3},
        drawEvents: const [],
        points: 220,
        pointsPerAdditionalStand: 70,
      );

      final regiment = Regiment(
        unit: highVolleyUnit,
        stands: 2,
        pointsCost: 360,
      );

      // 2 stands * 3 barrage = 6 total barrage
      // Volley 6 = 6/6 = 1.0 hit chance (always hits)
      // Expected ranged hits = 6 * 1.0 = 6.0
      final rangedHits = regiment.calculateRangedExpectedHits();
      expect(rangedHits, equals(6.0));
    });

    test('should handle volley 1 (minimum) correctly', () {
      final lowVolleyUnit = Unit(
        name: 'Poor Archers',
        faction: 'Test',
        type: 'infantry',
        regimentClass: 'light',
        characteristics: const UnitCharacteristics(
          march: 6,
          volley: 1, // Minimum volley
          clash: 2,
          attacks: 3,
          wounds: 3,
          resolve: 2,
          defense: 1,
          evasion: 1,
        ),
        specialRules: const [],
        numericSpecialRules: const {'barrage': 1},
        drawEvents: const [],
        points: 90,
        pointsPerAdditionalStand: 30,
      );

      final regiment = Regiment(
        unit: lowVolleyUnit,
        stands: 3,
        pointsCost: 150,
      );

      // 3 stands * 1 barrage = 3 total barrage
      // Volley 1 = 1/6 = 0.167 hit chance
      // Expected ranged hits = 3 * 0.167 = 0.5
      final rangedHits = regiment.calculateRangedExpectedHits();
      expect(rangedHits, closeTo(0.5, 0.1));
    });

    test('should handle max range calculations correctly', () {
      final unitWithHighRange = Unit(
        name: 'Artillery Unit',
        faction: 'Test',
        type: 'siege',
        regimentClass: 'heavy',
        characteristics: const UnitCharacteristics(
          march: 3,
          volley: 5,
          clash: 1,
          attacks: 1,
          wounds: 6,
          resolve: 4,
          defense: 3,
          evasion: 1,
        ),
        specialRules: const [],
        numericSpecialRules: const {
          'barrage': 4,
          'barrageRange': 36
        }, // Very long range
        drawEvents: const [],
        points: 300,
        pointsPerAdditionalStand: 100,
      );

      final artilleryRegiment = Regiment(
        unit: unitWithHighRange,
        stands: 1,
        pointsCost: 300,
      );

      expect(artilleryRegiment.barrageRange, equals(36));
      expect(artilleryRegiment.barrageValue, equals(4));
    });

    test('should update toString with range information', () {
      final regiment = Regiment(
        unit: unitWithBarrageRange,
        stands: 2,
        pointsCost: 270,
      );

      final stringOutput = regiment.toString();
      expect(stringOutput, contains('range: 24'));
      expect(stringOutput, contains('barrage: 2'));
      expect(stringOutput, contains('Long Range Archers'));
    });
  });
}
