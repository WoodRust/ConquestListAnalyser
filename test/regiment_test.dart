import 'package:flutter_test/flutter_test.dart';
import 'package:conquest_analyzer/models/regiment.dart';
import 'package:conquest_analyzer/models/unit.dart';

void main() {
  group('Regiment Model Tests', () {
    late Unit unitWithCleave;
    late Unit unitWithoutCleave;
    late Unit unitWithFlurry;

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
  });
}
