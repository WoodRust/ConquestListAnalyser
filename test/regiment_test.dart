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
    late Unit unitWithArmorPiercing;
    late Unit unitWithBarrageAndArmorPiercing;
    late Unit unitWithAllCapabilities;

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
        supremacyAbilities: const [],
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
        numericSpecialRules: const {}, // No cleave or armor piercing
        supremacyAbilities: const [],
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
        supremacyAbilities: const [],
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
        numericSpecialRules: const {
          'barrage': 2
        }, // Barrage(2), no armor piercing
        supremacyAbilities: const [],
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
        numericSpecialRules: const {
          'barrage': 3
        }, // Barrage(3), no armor piercing
        supremacyAbilities: const [],
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
        }, // Barrage(2) with 24" range, no armor piercing
        supremacyAbilities: const [],
        drawEvents: const [],
        points: 160,
        pointsPerAdditionalStand: 55,
      );

      unitWithArmorPiercing = Unit(
        name: 'Armor Piercing Unit',
        faction: 'Test',
        type: 'infantry',
        regimentClass: 'medium',
        characteristics: const UnitCharacteristics(
          march: 5,
          volley: 4,
          clash: 3,
          attacks: 3,
          wounds: 4,
          resolve: 3,
          defense: 2,
          evasion: 1,
        ),
        specialRules: const [],
        numericSpecialRules: const {
          'barrage': 2,
          'armorPiercingValue': 2
        }, // Barrage(2) with ArmorPiercing(2)
        supremacyAbilities: const [],
        drawEvents: const [],
        points: 170,
        pointsPerAdditionalStand: 55,
      );

      unitWithBarrageAndArmorPiercing = Unit(
        name: 'Heavy Crossbows',
        faction: 'Test',
        type: 'infantry',
        regimentClass: 'heavy',
        characteristics: const UnitCharacteristics(
          march: 4,
          volley: 5,
          clash: 2,
          attacks: 2,
          wounds: 5,
          resolve: 3,
          defense: 3,
          evasion: 1,
        ),
        specialRules: const [],
        numericSpecialRules: const {
          'barrage': 3,
          'armorPiercingValue': 3,
          'barrageRange': 18
        }, // High armor piercing with range
        supremacyAbilities: const [],
        drawEvents: const [],
        points: 200,
        pointsPerAdditionalStand: 65,
      );

      unitWithAllCapabilities = Unit(
        name: 'Elite Hybrid Unit',
        faction: 'Test',
        type: 'infantry',
        regimentClass: 'heavy',
        characteristics: const UnitCharacteristics(
          march: 5,
          volley: 4,
          clash: 3,
          attacks: 4,
          wounds: 5,
          resolve: 4,
          defense: 3,
          evasion: 1,
        ),
        specialRules: const [
          SpecialRule(
            name: 'Leader',
            description: 'This unit has a leader.',
          )
        ],
        numericSpecialRules: const {
          'cleave': 2,
          'barrage': 2,
          'armorPiercingValue': 2,
          'barrageRange': 12
        }, // Has everything
        supremacyAbilities: const [],
        drawEvents: const [],
        points: 250,
        pointsPerAdditionalStand: 80,
      );
    });

    // ===== ARMOR PIERCING TESTS =====
    test(
        'should return correct armor piercing value from numeric special rules',
        () {
      final regimentWithArmorPiercing = Regiment(
        unit: unitWithArmorPiercing,
        stands: 2,
        pointsCost: 280,
      );

      final regimentWithoutArmorPiercing = Regiment(
        unit: unitWithoutCleave,
        stands: 3,
        pointsCost: 200,
      );

      expect(regimentWithArmorPiercing.armorPiercingValue, equals(2));
      expect(regimentWithoutArmorPiercing.armorPiercingValue, equals(0));
    });

    test('should calculate ranged armor piercing rating correctly', () {
      final regiment = Regiment(
        unit: unitWithArmorPiercing,
        stands: 2,
        pointsCost: 280,
      );

      // 2 stands * 2 barrage = 4 total barrage
      // Volley 4 = 4/6 = 0.667 hit chance
      // Ranged expected hits = 4 * 0.667 = 2.67
      // Armor piercing rating = 2.67 * 2 = 5.33
      final armorPiercingRating = regiment.rangedArmorPiercingRating;
      expect(armorPiercingRating, closeTo(5.33, 0.1));
    });

    test(
        'should return zero armor piercing rating for units without armor piercing',
        () {
      final regiment = Regiment(
        unit: unitWithBarrage, // Has barrage but no armor piercing
        stands: 2,
        pointsCost: 230,
      );

      expect(regiment.armorPiercingValue, equals(0));
      expect(regiment.rangedArmorPiercingRating, equals(0.0));
      expect(regiment.calculateRangedExpectedHits(),
          greaterThan(0.0)); // Should still have ranged hits
    });

    test('should return zero armor piercing rating for units without barrage',
        () {
      final unitWithOnlyArmorPiercing = Unit(
        name: 'Melee Armor Piercer',
        faction: 'Test',
        type: 'infantry',
        regimentClass: 'heavy',
        characteristics: const UnitCharacteristics(
          march: 5,
          volley: 2,
          clash: 4,
          attacks: 4,
          wounds: 5,
          resolve: 4,
          defense: 3,
          evasion: 1,
        ),
        specialRules: const [],
        numericSpecialRules: const {
          'cleave': 3,
          'armorPiercingValue': 2
        }, // Has armor piercing but no barrage
        supremacyAbilities: const [],
        drawEvents: const [],
        points: 200,
        pointsPerAdditionalStand: 65,
      );

      final regiment = Regiment(
        unit: unitWithOnlyArmorPiercing,
        stands: 2,
        pointsCost: 330,
      );

      expect(regiment.armorPiercingValue, equals(2));
      expect(regiment.barrageValue, equals(0));
      expect(regiment.rangedArmorPiercingRating,
          equals(0.0)); // No barrage = no ranged armor piercing
      expect(regiment.calculateRangedExpectedHits(),
          equals(0.0)); // No barrage = no ranged hits
    });

    test('should calculate armor piercing rating with leader correctly', () {
      final regiment = Regiment(
        unit: unitWithAllCapabilities,
        stands: 2,
        pointsCost: 410,
      );

      // 2 stands * 2 barrage = 4 base barrage
      // +1 for leader = 5 total barrage
      // Volley 4 = 4/6 = 0.667 hit chance
      // Ranged expected hits = 5 * 0.667 = 3.33
      // Armor piercing rating = 3.33 * 2 = 6.67
      final armorPiercingRating = regiment.calculateRangedArmorPiercingRating();
      expect(armorPiercingRating, closeTo(6.67, 0.1));
    });

    test('should handle high armor piercing values correctly', () {
      final highArmorPiercingUnit = Unit(
        name: 'Artillery Cannon',
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
          defense: 4,
          evasion: 1,
        ),
        specialRules: const [],
        numericSpecialRules: const {
          'barrage': 4,
          'armorPiercingValue': 5,
          'barrageRange': 36
        }, // Very high armor piercing
        supremacyAbilities: const [],
        drawEvents: const [],
        points: 350,
      );

      final regiment = Regiment(
        unit: highArmorPiercingUnit,
        stands: 1,
        pointsCost: 350,
      );

      // 1 stand * 4 barrage = 4 total barrage
      // Volley 5 = 5/6 = 0.833 hit chance
      // Ranged expected hits = 4 * 0.833 = 3.33
      // Armor piercing rating = 3.33 * 5 = 16.67
      final armorPiercingRating = regiment.calculateRangedArmorPiercingRating();
      expect(armorPiercingRating, closeTo(16.67, 0.1));
    });

    test('should include armor piercing in toString', () {
      final regiment = Regiment(
        unit: unitWithArmorPiercing,
        stands: 2,
        pointsCost: 280,
      );

      final stringOutput = regiment.toString();
      expect(stringOutput, contains('armorPiercing: 2'));
      expect(stringOutput, contains('barrage: 2'));
      expect(stringOutput, contains('Armor Piercing Unit'));
    });

    // ===== EXISTING CLEAVE TESTS =====
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

    // ===== EXISTING BARRAGE TESTS =====
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
        supremacyAbilities: const [],
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
        supremacyAbilities: const [],
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
        supremacyAbilities: const [],
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

    // ===== COMBINED CAPABILITY TESTS =====
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
        supremacyAbilities: const [],
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

    test('should handle multiple capabilities correctly', () {
      final regiment = Regiment(
        unit: unitWithAllCapabilities,
        stands: 1,
        pointsCost: 250,
      );

      expect(regiment.cleaveValue, equals(2));
      expect(regiment.barrageValue, equals(2));
      expect(regiment.armorPiercingValue, equals(2));
      expect(regiment.barrageRange, equals(12));

      // Should have non-zero values for all capabilities
      expect(regiment.cleaveRating, greaterThan(0.0));
      expect(regiment.calculateRangedExpectedHits(), greaterThan(0.0));
      expect(regiment.rangedArmorPiercingRating, greaterThan(0.0));
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
        supremacyAbilities: const [],
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

    // ===== EDGE CASE TESTS =====
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
      expect(zeroStandRegiment.armorPiercingValue, equals(0));
      expect(zeroStandRegiment.rangedArmorPiercingRating, equals(0.0));

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
        supremacyAbilities: const [],
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

    test('should handle edge cases for armor piercing', () {
      // Test with 0 stands
      final zeroStandRegiment = Regiment(
        unit: unitWithArmorPiercing,
        stands: 0,
        pointsCost: 0,
      );

      expect(zeroStandRegiment.armorPiercingValue, equals(2));
      expect(zeroStandRegiment.rangedArmorPiercingRating, equals(0.0));
      expect(zeroStandRegiment.calculateRangedExpectedHits(), equals(0.0));

      // Test with very high values
      final highValueUnit = Unit(
        name: 'Extreme Artillery',
        faction: 'Test',
        type: 'siege',
        regimentClass: 'heavy',
        characteristics: const UnitCharacteristics(
          march: 2,
          volley: 6, // Always hits
          clash: 1,
          attacks: 1,
          wounds: 8,
          resolve: 5,
          defense: 5,
          evasion: 1,
        ),
        specialRules: const [],
        numericSpecialRules: const {
          'barrage': 10,
          'armorPiercingValue': 10,
          'barrageRange': 48
        }, // Extreme values
        supremacyAbilities: const [],
        drawEvents: const [],
        points: 500,
      );

      final extremeRegiment = Regiment(
        unit: highValueUnit,
        stands: 1,
        pointsCost: 500,
      );

      // 1 stand * 10 barrage = 10 total barrage
      // Volley 6 = 6/6 = 1.0 hit chance (always hits)
      // Ranged expected hits = 10 * 1.0 = 10.0
      // Armor piercing rating = 10.0 * 10 = 100.0
      expect(extremeRegiment.rangedArmorPiercingRating, equals(100.0));
    });

    // ===== BACKWARDS COMPATIBILITY TESTS =====
    test('should maintain backwards compatibility', () {
      // Ensure existing functionality still works with new armor piercing feature
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
      expect(regiment.armorPiercingValue, equals(0)); // No armor piercing
      expect(
          regiment.rangedArmorPiercingRating, equals(0.0)); // No armor piercing
    });

    test('should calculate complex interactions correctly', () {
      final regiment = Regiment(
        unit: unitWithBarrageAndArmorPiercing,
        stands: 3,
        pointsCost: 470,
      );

      // 3 stands * 3 barrage = 9 total barrage
      // Volley 5 = 5/6 = 0.833 hit chance
      // Ranged expected hits = 9 * 0.833 = 7.5
      // Armor piercing rating = 7.5 * 3 = 22.5

      final rangedHits = regiment.calculateRangedExpectedHits();
      final armorPiercingRating = regiment.calculateRangedArmorPiercingRating();

      expect(rangedHits, closeTo(7.5, 0.1));
      expect(armorPiercingRating, closeTo(22.5, 0.1));
      expect(regiment.barrageRange, equals(18));
    });

    // ===== STRING REPRESENTATION TESTS =====
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

    test('should update toString with all capabilities', () {
      final regiment = Regiment(
        unit: unitWithAllCapabilities,
        stands: 1,
        pointsCost: 250,
      );
      final stringOutput = regiment.toString();
      expect(stringOutput, contains('cleave: 2'));
      expect(stringOutput, contains('barrage: 2'));
      expect(stringOutput, contains('range: 12'));
      expect(stringOutput, contains('armorPiercing: 2'));
      expect(stringOutput, contains('Elite Hybrid Unit'));
    });
  });
}
