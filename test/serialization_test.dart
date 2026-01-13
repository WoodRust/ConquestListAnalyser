import 'package:flutter_test/flutter_test.dart';
import 'package:conquest_analyzer/models/army_list.dart';
import 'package:conquest_analyzer/models/regiment.dart';
import 'package:conquest_analyzer/models/unit.dart';
import 'package:conquest_analyzer/models/list_score.dart';
import 'package:conquest_analyzer/models/reinforcement_metrics.dart';

void main() {
  group('JSON Serialization Tests', () {
    test('Unit serialization round-trip', () {
      final unit = Unit(
        name: 'Test Unit',
        faction: 'Test Faction',
        type: 'infantry',
        regimentClass: 'medium',
        characteristics: UnitCharacteristics(
          march: 6,
          volley: 2,
          clash: 3,
          attacks: 5,
          wounds: 4,
          resolve: 3,
          defense: 2,
          evasion: 1,
        ),
        specialRules: [
          const SpecialRule(
            name: 'Flurry',
            description: 'Re-roll failed hits',
          ),
        ],
        numericSpecialRules: {'cleave': 2},
        supremacyAbilities: const [],
        drawEvents: const [],
        points: 150,
        pointsPerAdditionalStand: 50,
      );

      final json = unit.toJson();
      final deserialized = Unit.fromJson(json);

      expect(deserialized.name, unit.name);
      expect(deserialized.faction, unit.faction);
      expect(deserialized.characteristics.march, unit.characteristics.march);
      expect(deserialized.specialRules.length, unit.specialRules.length);
      expect(deserialized.points, unit.points);
    });

    test('Regiment serialization round-trip', () {
      final unit = Unit(
        name: 'Test Unit',
        faction: 'Test Faction',
        type: 'infantry',
        regimentClass: 'medium',
        characteristics: UnitCharacteristics(
          march: 6,
          volley: 2,
          clash: 3,
          attacks: 5,
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
        pointsPerAdditionalStand: 50,
      );

      final regiment = Regiment(
        unit: unit,
        stands: 3,
        pointsCost: 250,
        upgrades: ['Captain', 'Standard'],
        isWarlord: true,
      );

      final json = regiment.toJson();
      final deserialized = Regiment.fromJson(json);

      expect(deserialized.unit.name, regiment.unit.name);
      expect(deserialized.stands, regiment.stands);
      expect(deserialized.pointsCost, regiment.pointsCost);
      expect(deserialized.upgrades.length, regiment.upgrades.length);
      expect(deserialized.isWarlord, regiment.isWarlord);
    });

    test('ArmyList serialization round-trip', () {
      final unit = Unit(
        name: 'Test Unit',
        faction: 'Nords',
        type: 'infantry',
        regimentClass: 'medium',
        characteristics: UnitCharacteristics(
          march: 6,
          volley: 2,
          clash: 3,
          attacks: 5,
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
        pointsPerAdditionalStand: 50,
      );

      final regiment = Regiment(
        unit: unit,
        stands: 3,
        pointsCost: 250,
      );

      final armyList = ArmyList(
        name: 'Test Army',
        faction: 'Nords',
        totalPoints: 1500,
        pointsLimit: 2000,
        regiments: [regiment],
      );

      final json = armyList.toJson();
      final deserialized = ArmyList.fromJson(json);

      expect(deserialized.name, armyList.name);
      expect(deserialized.faction, armyList.faction);
      expect(deserialized.totalPoints, armyList.totalPoints);
      expect(deserialized.pointsLimit, armyList.pointsLimit);
      expect(deserialized.regiments.length, armyList.regiments.length);
    });

    test('ListScore serialization round-trip', () {
      final unit = Unit(
        name: 'Test Unit',
        faction: 'Nords',
        type: 'infantry',
        regimentClass: 'medium',
        characteristics: UnitCharacteristics(
          march: 6,
          volley: 2,
          clash: 3,
          attacks: 5,
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
        pointsPerAdditionalStand: 50,
      );

      final regiment = Regiment(
        unit: unit,
        stands: 3,
        pointsCost: 250,
      );

      final armyList = ArmyList(
        name: 'Test Army',
        faction: 'Nords',
        totalPoints: 1500,
        pointsLimit: 2000,
        regiments: [regiment],
      );

      final now = DateTime.now();
      final score = ListScore(
        armyList: armyList,
        totalWounds: 12,
        pointsPerWound: 125.0,
        expectedHitVolume: 15.5,
        cleaveRating: 31.0,
        rangedExpectedHits: 4.0,
        rangedArmorPiercingRating: 8.0,
        maxRange: 16,
        averageSpeed: 6.0,
        toughness: 2.5,
        evasion: 1.2,
        effectiveWoundsDefense: 16.0,
        effectiveWoundsDefenseResolve: 20.0,
        resolveImpactPercentage: 25.0,
        pointsPerEffectiveWoundDefense: 93.75,
        pointsPerEffectiveWoundDefenseResolve: 75.0,
        magicCapability: 0,
        expectedHealingCapability: 0,
        calculatedAt: now,
      );

      final json = score.toJson();
      final deserialized = ListScore.fromJson(json);

      expect(deserialized.armyList.name, score.armyList.name);
      expect(deserialized.totalWounds, score.totalWounds);
      expect(deserialized.pointsPerWound, score.pointsPerWound);
      expect(deserialized.expectedHitVolume, score.expectedHitVolume);
      expect(deserialized.calculatedAt.millisecondsSinceEpoch,
          score.calculatedAt.millisecondsSinceEpoch);
    });

    test('ArmyList copyWith creates modified copy', () {
      final unit = Unit(
        name: 'Test Unit',
        faction: 'Nords',
        type: 'infantry',
        regimentClass: 'medium',
        characteristics: UnitCharacteristics(
          march: 6,
          volley: 2,
          clash: 3,
          attacks: 5,
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
        pointsPerAdditionalStand: 50,
      );

      final regiment = Regiment(
        unit: unit,
        stands: 3,
        pointsCost: 250,
      );

      final original = ArmyList(
        name: 'Original Name',
        faction: 'Nords',
        totalPoints: 1500,
        pointsLimit: 2000,
        regiments: [regiment],
      );

      final modified = original.copyWith(name: 'Modified Name');

      expect(modified.name, 'Modified Name');
      expect(modified.faction, original.faction);
      expect(modified.totalPoints, original.totalPoints);
      expect(modified.regiments.length, original.regiments.length);
    });

    test('ListScore with reinforcementMetrics serialization round-trip', () {
      final unit = Unit(
        name: 'Test Unit',
        faction: 'Nords',
        type: 'infantry',
        regimentClass: 'medium',
        characteristics: UnitCharacteristics(
          march: 6,
          volley: 2,
          clash: 3,
          attacks: 5,
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
        pointsPerAdditionalStand: 50,
      );

      final regiment = Regiment(
        unit: unit,
        stands: 3,
        pointsCost: 250,
      );

      final armyList = ArmyList(
        name: 'Test Army',
        faction: 'Nords',
        totalPoints: 1500,
        pointsLimit: 2000,
        regiments: [regiment],
      );

      final reinforcementMetrics = ReinforcementMetrics(
        turn1Through5ArrivalPercent: [10.5, 25.3, 50.1, 75.8, 100.0],
        turn1Through5P20: [5.0, 15.0, 35.0, 60.0, 100.0],
        turn1Through5P80: [15.0, 35.0, 65.0, 90.0, 100.0],
      );

      final now = DateTime.now();
      final score = ListScore(
        armyList: armyList,
        totalWounds: 12,
        pointsPerWound: 125.0,
        expectedHitVolume: 15.5,
        cleaveRating: 31.0,
        rangedExpectedHits: 4.0,
        rangedArmorPiercingRating: 8.0,
        maxRange: 16,
        averageSpeed: 6.0,
        toughness: 2.5,
        evasion: 1.2,
        effectiveWoundsDefense: 16.0,
        effectiveWoundsDefenseResolve: 20.0,
        resolveImpactPercentage: 25.0,
        pointsPerEffectiveWoundDefense: 93.75,
        pointsPerEffectiveWoundDefenseResolve: 75.0,
        magicCapability: 0,
        expectedHealingCapability: 0,
        reinforcementMetrics: reinforcementMetrics,
        calculatedAt: now,
      );

      final json = score.toJson();
      final deserialized = ListScore.fromJson(json);

      // Verify basic fields
      expect(deserialized.armyList.name, score.armyList.name);
      expect(deserialized.totalWounds, score.totalWounds);

      // Verify reinforcement metrics were serialized correctly
      expect(deserialized.reinforcementMetrics, isNotNull,
          reason: 'reinforcementMetrics should not be null after deserialization');
      expect(deserialized.reinforcementMetrics!.turn1Through5ArrivalPercent,
          score.reinforcementMetrics!.turn1Through5ArrivalPercent);
      expect(deserialized.reinforcementMetrics!.turn1Through5P20,
          score.reinforcementMetrics!.turn1Through5P20);
      expect(deserialized.reinforcementMetrics!.turn1Through5P80,
          score.reinforcementMetrics!.turn1Through5P80);
    });

    test('ListScore copyWith preserves all fields including reinforcementMetrics', () {
      final unit = Unit(
        name: 'Test Unit',
        faction: 'Nords',
        type: 'infantry',
        regimentClass: 'medium',
        characteristics: UnitCharacteristics(
          march: 6,
          volley: 2,
          clash: 3,
          attacks: 5,
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
        pointsPerAdditionalStand: 50,
      );

      final regiment = Regiment(
        unit: unit,
        stands: 3,
        pointsCost: 250,
      );

      final originalArmyList = ArmyList(
        name: 'Original Name',
        faction: 'Nords',
        totalPoints: 1500,
        pointsLimit: 2000,
        regiments: [regiment],
      );

      final reinforcementMetrics = ReinforcementMetrics(
        turn1Through5ArrivalPercent: [10.5, 25.3, 50.1, 75.8, 100.0],
        turn1Through5P20: [5.0, 15.0, 35.0, 60.0, 100.0],
        turn1Through5P80: [15.0, 35.0, 65.0, 90.0, 100.0],
      );

      final now = DateTime.now();
      final original = ListScore(
        armyList: originalArmyList,
        totalWounds: 12,
        pointsPerWound: 125.0,
        expectedHitVolume: 15.5,
        cleaveRating: 31.0,
        rangedExpectedHits: 4.0,
        rangedArmorPiercingRating: 8.0,
        maxRange: 16,
        averageSpeed: 6.0,
        toughness: 2.5,
        evasion: 1.2,
        effectiveWoundsDefense: 16.0,
        effectiveWoundsDefenseResolve: 20.0,
        resolveImpactPercentage: 25.0,
        pointsPerEffectiveWoundDefense: 93.75,
        pointsPerEffectiveWoundDefenseResolve: 75.0,
        magicCapability: 0,
        expectedHealingCapability: 0,
        reinforcementMetrics: reinforcementMetrics,
        calculatedAt: now,
      );

      final modifiedArmyList = originalArmyList.copyWith(name: 'Modified Name');
      final modified = original.copyWith(armyList: modifiedArmyList);

      // Verify the army list name changed
      expect(modified.armyList.name, 'Modified Name');

      // Verify all other fields including reinforcementMetrics were preserved
      expect(modified.totalWounds, original.totalWounds);
      expect(modified.pointsPerWound, original.pointsPerWound);
      expect(modified.reinforcementMetrics, isNotNull,
          reason: 'reinforcementMetrics should be preserved in copyWith');
      expect(modified.reinforcementMetrics!.turn1Through5ArrivalPercent,
          original.reinforcementMetrics!.turn1Through5ArrivalPercent);
    });
  });
}
