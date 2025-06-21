import 'package:flutter_test/flutter_test.dart';
import 'package:conquest_analyzer/services/scoring_engine.dart';
import 'package:conquest_analyzer/models/army_list.dart';
import 'package:conquest_analyzer/models/regiment.dart';
import 'package:conquest_analyzer/models/unit.dart';

void main() {
  group('ScoringEngine Tests', () {
    late ScoringEngine scoringEngine;
    late Unit testUnit1;
    late Unit testUnit2;
    late Unit testUnitWithCleave;
    late Unit testUnitWithBarrage;
    late Unit testUnitWithBoth;
    late Unit testUnitWithRange;
    late Unit testUnitWithArmorPiercing;
    late Unit testUnitWithBarrageAndArmorPiercing;
    late Unit testUnitWithAllCapabilities;

    setUp(() {
      scoringEngine = ScoringEngine();

      testUnit1 = Unit(
        name: 'Test Unit 1',
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
        numericSpecialRules: const {}, // No cleave, barrage, or armor piercing
        drawEvents: const [],
        points: 120,
      );

      testUnit2 = Unit(
        name: 'Test Unit 2',
        faction: 'Nords',
        type: 'brute',
        regimentClass: 'medium',
        characteristics: const UnitCharacteristics(
          march: 6,
          volley: 1,
          clash: 3,
          attacks: 6,
          wounds: 5,
          resolve: 3,
          defense: 2,
          evasion: 1,
        ),
        specialRules: const [],
        numericSpecialRules: const {}, // No cleave, barrage, or armor piercing
        drawEvents: const [],
        points: 170,
      );

      testUnitWithCleave = Unit(
        name: 'Cleaving Unit',
        faction: 'Nords',
        type: 'brute',
        regimentClass: 'heavy',
        characteristics: const UnitCharacteristics(
          march: 5,
          volley: 1,
          clash: 3,
          attacks: 5,
          wounds: 6,
          resolve: 4,
          defense: 3,
          evasion: 1,
        ),
        specialRules: const [],
        numericSpecialRules: const {'cleave': 2}, // Has cleave(2)
        drawEvents: const [],
        points: 200,
      );

      testUnitWithBarrage = Unit(
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
        }, // Has barrage(2), no armor piercing
        drawEvents: const [],
        points: 140,
      );

      testUnitWithBoth = Unit(
        name: 'Hybrid Unit',
        faction: 'Test',
        type: 'infantry',
        regimentClass: 'medium',
        characteristics: const UnitCharacteristics(
          march: 5,
          volley: 4,
          clash: 3,
          attacks: 4,
          wounds: 5,
          resolve: 3,
          defense: 2,
          evasion: 1,
        ),
        specialRules: const [],
        numericSpecialRules: const {
          'cleave': 1,
          'barrage': 1
        }, // Has both, no armor piercing
        drawEvents: const [],
        points: 180,
      );

      testUnitWithRange = Unit(
        name: 'Long Range Artillery',
        faction: 'Test',
        type: 'siege',
        regimentClass: 'heavy',
        characteristics: const UnitCharacteristics(
          march: 3,
          volley: 5,
          clash: 1,
          attacks: 2,
          wounds: 6,
          resolve: 4,
          defense: 3,
          evasion: 1,
        ),
        specialRules: const [],
        numericSpecialRules: const {
          'barrage': 3,
          'barrageRange': 36
        }, // Has long range, no armor piercing
        drawEvents: const [],
        points: 280,
      );

      testUnitWithArmorPiercing = Unit(
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
          'armorPiercingValue': 3
        }, // Has barrage and armor piercing
        drawEvents: const [],
        points: 170,
      );

      testUnitWithBarrageAndArmorPiercing = Unit(
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
          'armorPiercingValue': 4,
          'barrageRange': 18
        }, // High armor piercing with range
        drawEvents: const [],
        points: 200,
      );

      testUnitWithAllCapabilities = Unit(
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
        specialRules: const [],
        numericSpecialRules: const {
          'cleave': 2,
          'barrage': 2,
          'armorPiercingValue': 2,
          'barrageRange': 12
        }, // Has everything
        drawEvents: const [],
        points: 250,
      );
    });

    // ===== ARMOR PIERCING TESTS =====
    test('should calculate ranged armor piercing rating correctly', () {
      final regiments = [
        Regiment(
            unit: testUnitWithArmorPiercing,
            stands: 2,
            pointsCost: 340), // Has armor piercing
        Regiment(
            unit: testUnitWithBarrage,
            stands: 1,
            pointsCost: 140), // No armor piercing
      ];

      final armyList = ArmyList(
        name: 'Test Army',
        faction: 'Test',
        totalPoints: 480,
        pointsLimit: 2000,
        regiments: regiments,
      );

      final score = scoringEngine.calculateScores(armyList);

      // Unit with armor piercing: 2 stands * 2 barrage = 4 total barrage
      // Volley 4 = 4/6 = 0.667 hit chance
      // Ranged expected hits = 4 * 0.667 = 2.67
      // Armor piercing rating = 2.67 * 3 = 8.0

      // Unit without armor piercing: 1 stand * 2 barrage = 2 total barrage
      // Volley 3 = 3/6 = 0.5 hit chance
      // Ranged expected hits = 2 * 0.5 = 1.0
      // Armor piercing rating = 1.0 * 0 = 0.0

      // Total armor piercing rating = 8.0 + 0.0 = 8.0
      expect(score.rangedArmorPiercingRating, closeTo(8.0, 0.1));
    });

    test('should handle army with no armor piercing units', () {
      final regiments = [
        Regiment(unit: testUnit1, stands: 2, pointsCost: 160),
        Regiment(
            unit: testUnitWithBarrage,
            stands: 1,
            pointsCost: 140), // Barrage but no armor piercing
      ];

      final armyList = ArmyList(
        name: 'No Armor Piercing Army',
        faction: 'Test',
        totalPoints: 300,
        pointsLimit: 2000,
        regiments: regiments,
      );

      final score = scoringEngine.calculateScores(armyList);

      expect(score.rangedArmorPiercingRating, equals(0.0));
      expect(score.rangedExpectedHits,
          greaterThan(0.0)); // Should still have ranged hits
    });

    test('should handle army with only melee armor piercing units', () {
      final meleeArmorPiercingUnit = Unit(
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
        drawEvents: const [],
        points: 200,
      );

      final regiments = [
        Regiment(unit: meleeArmorPiercingUnit, stands: 2, pointsCost: 400),
        Regiment(unit: testUnit1, stands: 1, pointsCost: 120),
      ];

      final armyList = ArmyList(
        name: 'Melee Armor Piercing Army',
        faction: 'Test',
        totalPoints: 520,
        pointsLimit: 2000,
        regiments: regiments,
      );

      final score = scoringEngine.calculateScores(armyList);

      expect(score.rangedArmorPiercingRating,
          equals(0.0)); // No ranged armor piercing
      expect(score.rangedExpectedHits, equals(0.0)); // No ranged capability
      expect(score.cleaveRating, greaterThan(0.0)); // Should have cleave rating
    });

    test('should calculate high armor piercing values correctly', () {
      final highArmorPiercingUnit = Unit(
        name: 'Super Artillery',
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
          'barrage': 5,
          'armorPiercingValue': 6,
          'barrageRange': 48
        }, // Very high values
        drawEvents: const [],
        points: 400,
      );

      final regiments = [
        Regiment(unit: highArmorPiercingUnit, stands: 1, pointsCost: 400),
      ];

      final armyList = ArmyList(
        name: 'High AP Army',
        faction: 'Test',
        totalPoints: 400,
        pointsLimit: 2000,
        regiments: regiments,
      );

      final score = scoringEngine.calculateScores(armyList);

      // 1 stand * 5 barrage = 5 total barrage
      // Volley 6 = 6/6 = 1.0 hit chance (always hits)
      // Ranged expected hits = 5 * 1.0 = 5.0
      // Armor piercing rating = 5.0 * 6 = 30.0
      expect(score.rangedArmorPiercingRating, equals(30.0));
    });

    test('should handle units with leader bonus and armor piercing', () {
      final leaderUnit = Unit(
        name: 'Armor Piercing Leader',
        faction: 'Test',
        type: 'infantry',
        regimentClass: 'medium',
        characteristics: const UnitCharacteristics(
          march: 5,
          volley: 4,
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
          'barrage': 2,
          'armorPiercingValue': 3
        }, // Has both barrage and armor piercing with leader
        drawEvents: const [],
        points: 180,
      );

      final regiments = [
        Regiment(unit: leaderUnit, stands: 2, pointsCost: 300),
      ];

      final armyList = ArmyList(
        name: 'Leader Armor Piercing Army',
        faction: 'Test',
        totalPoints: 300,
        pointsLimit: 2000,
        regiments: regiments,
      );

      final score = scoringEngine.calculateScores(armyList);

      // 2 stands * 2 barrage = 4 base barrage
      // +1 for leader = 5 total barrage
      // Volley 4 = 4/6 = 0.667 hit chance
      // Ranged expected hits = 5 * 0.667 = 3.33
      // Armor piercing rating = 3.33 * 3 = 10.0

      expect(score.rangedArmorPiercingRating, closeTo(10.0, 0.1));
    });

    test('should handle multiple different armor piercing values', () {
      final lowAPUnit = Unit(
        name: 'Low AP Unit',
        faction: 'Test',
        type: 'infantry',
        regimentClass: 'light',
        characteristics: const UnitCharacteristics(
          march: 6,
          volley: 3,
          clash: 2,
          attacks: 3,
          wounds: 4,
          resolve: 2,
          defense: 1,
          evasion: 1,
        ),
        specialRules: const [],
        numericSpecialRules: const {
          'barrage': 1,
          'armorPiercingValue': 1
        }, // Low armor piercing
        drawEvents: const [],
        points: 120,
      );

      final mediumAPUnit = Unit(
        name: 'Medium AP Unit',
        faction: 'Test',
        type: 'infantry',
        regimentClass: 'medium',
        characteristics: const UnitCharacteristics(
          march: 5,
          volley: 4,
          clash: 3,
          attacks: 3,
          wounds: 5,
          resolve: 3,
          defense: 2,
          evasion: 1,
        ),
        specialRules: const [],
        numericSpecialRules: const {
          'barrage': 2,
          'armorPiercingValue': 2
        }, // Medium armor piercing
        drawEvents: const [],
        points: 160,
      );

      final regiments = [
        Regiment(unit: lowAPUnit, stands: 3, pointsCost: 180), // Low AP
        Regiment(unit: mediumAPUnit, stands: 2, pointsCost: 220), // Medium AP
        Regiment(
            unit: testUnitWithBarrageAndArmorPiercing,
            stands: 1,
            pointsCost: 200), // High AP
      ];

      final armyList = ArmyList(
        name: 'Multi AP Army',
        faction: 'Test',
        totalPoints: 600,
        pointsLimit: 2000,
        regiments: regiments,
      );

      final score = scoringEngine.calculateScores(armyList);

      // All units contribute to total armor piercing rating
      expect(score.rangedArmorPiercingRating, greaterThan(0.0));
      expect(score.rangedExpectedHits, greaterThan(0.0));
    });

    // ===== EXISTING WOUND CALCULATION TESTS =====
    test('should calculate total wounds correctly', () {
      final regiments = [
        Regiment(
            unit: testUnit1, stands: 3, pointsCost: 200), // 4 * 3 = 12 wounds
        Regiment(
            unit: testUnit2, stands: 2, pointsCost: 340), // 5 * 2 = 10 wounds
      ];

      final armyList = ArmyList(
        name: 'Test Army',
        faction: 'Nords',
        totalPoints: 540,
        pointsLimit: 2000,
        regiments: regiments,
      );

      final score = scoringEngine.calculateScores(armyList);
      expect(score.totalWounds, equals(22)); // 12 + 10
    });

    test('should calculate points per wound correctly', () {
      final regiments = [
        Regiment(
            unit: testUnit1, stands: 2, pointsCost: 160), // 4 * 2 = 8 wounds
      ];

      final armyList = ArmyList(
        name: 'Test Army',
        faction: 'Nords',
        totalPoints: 160,
        pointsLimit: 2000,
        regiments: regiments,
      );

      final score = scoringEngine.calculateScores(armyList);
      expect(score.totalWounds, equals(8));
      expect(score.pointsPerWound, equals(20.0)); // 160 / 8
    });

    // ===== EXISTING CLEAVE TESTS =====
    test('should calculate cleave rating correctly', () {
      final regiments = [
        Regiment(
            unit: testUnitWithCleave, stands: 2, pointsCost: 400), // Cleave(2)
        Regiment(unit: testUnit1, stands: 1, pointsCost: 120), // No cleave
      ];

      final armyList = ArmyList(
        name: 'Test Army',
        faction: 'Nords',
        totalPoints: 520,
        pointsLimit: 2000,
        regiments: regiments,
      );

      final score = scoringEngine.calculateScores(armyList);

      // Test unit with cleave should contribute to cleave rating
      // Unit with cleave: 2 stands, 5 attacks per stand = 10 attacks
      // Hit chance with clash 3 = (3+1)/6 = 4/6 = 0.667
      // Expected hits = 10 * 0.667 = 6.67
      // Cleave rating = 6.67 * 2 = 13.33
      // Test unit 1: 1 stand, 4 attacks, clash 2 = (2+1)/6 = 0.5
      // Expected hits = 4 * 0.5 = 2, cleave = 0, so cleave rating = 0
      expect(score.cleaveRating, closeTo(13.33, 0.1));
    });

    // ===== EXISTING RANGED TESTS =====
    test('should calculate ranged expected hits correctly', () {
      final regiments = [
        Regiment(
            unit: testUnitWithBarrage,
            stands: 2,
            pointsCost: 280), // Barrage(2)
        Regiment(unit: testUnit1, stands: 1, pointsCost: 120), // No barrage
      ];

      final armyList = ArmyList(
        name: 'Test Army',
        faction: 'Test',
        totalPoints: 400,
        pointsLimit: 2000,
        regiments: regiments,
      );

      final score = scoringEngine.calculateScores(armyList);

      // Unit with barrage: 2 stands * 2 barrage = 4 total barrage
      // Volley 3 = 3/6 = 0.5 hit chance
      // Expected ranged hits = 4 * 0.5 = 2.0
      // Test unit 1: no barrage, so 0 ranged hits
      expect(score.rangedExpectedHits, closeTo(2.0, 0.1));
    });

    test('should calculate max range correctly', () {
      final regiments = [
        Regiment(
            unit: testUnitWithRange, stands: 1, pointsCost: 280), // Range 36
        Regiment(
            unit: testUnitWithBarrage,
            stands: 2,
            pointsCost: 280), // No range specified (0)
        Regiment(unit: testUnit1, stands: 1, pointsCost: 120), // No barrage (0)
      ];

      final armyList = ArmyList(
        name: 'Test Army',
        faction: 'Test',
        totalPoints: 680,
        pointsLimit: 2000,
        regiments: regiments,
      );

      final score = scoringEngine.calculateScores(armyList);
      expect(score.maxRange, equals(36)); // Highest range in the army
    });

    // ===== COMPREHENSIVE MIXED ARMY TESTS =====
    test(
        'should calculate mixed army with all capabilities including armor piercing',
        () {
      final regiments = [
        Regiment(
            unit: testUnitWithAllCapabilities,
            stands: 2,
            pointsCost: 500), // Has everything
        Regiment(
            unit: testUnitWithCleave,
            stands: 1,
            pointsCost: 200), // Only cleave
        Regiment(
            unit: testUnitWithBarrageAndArmorPiercing,
            stands: 1,
            pointsCost: 200), // Barrage with high armor piercing
        Regiment(unit: testUnit1, stands: 2, pointsCost: 240), // Basic unit
      ];

      final armyList = ArmyList(
        name: 'Mixed Army',
        faction: 'Test',
        totalPoints: 1140,
        pointsLimit: 2000,
        regiments: regiments,
      );

      final score = scoringEngine.calculateScores(armyList);

      // Should have non-zero values for all metrics
      expect(score.totalWounds, greaterThan(0));
      expect(score.pointsPerWound, greaterThan(0.0));
      expect(score.expectedHitVolume, greaterThan(0.0));
      expect(score.cleaveRating, greaterThan(0.0)); // From cleave units
      expect(score.rangedExpectedHits, greaterThan(0.0)); // From barrage units
      expect(score.rangedArmorPiercingRating,
          greaterThan(0.0)); // From armor piercing units
      expect(score.maxRange, greaterThan(0)); // From units with range

      // Verify the score includes armor piercing in the shareable text
      final shareableText = score.toShareableText();
      expect(shareableText, contains('Ranged Armor Piercing:'));
    });

    test(
        'should calculate mixed army with all capabilities including max range',
        () {
      final regiments = [
        Regiment(
            unit: testUnitWithBoth,
            stands: 2,
            pointsCost: 360), // Both cleave and barrage, no range
        Regiment(
            unit: testUnitWithCleave,
            stands: 1,
            pointsCost: 200), // Only cleave
        Regiment(
            unit: testUnitWithRange,
            stands: 1,
            pointsCost: 280), // Barrage with range 36
        Regiment(unit: testUnit1, stands: 2, pointsCost: 160), // Neither
      ];

      final armyList = ArmyList(
        name: 'Mixed Army',
        faction: 'Test',
        totalPoints: 1000,
        pointsLimit: 2000,
        regiments: regiments,
      );

      final score = scoringEngine.calculateScores(armyList);

      // Should have non-zero values for all metrics
      expect(score.totalWounds, greaterThan(0));
      expect(score.pointsPerWound, greaterThan(0.0));
      expect(score.expectedHitVolume, greaterThan(0.0));
      expect(score.cleaveRating, greaterThan(0.0)); // From cleave units
      expect(score.rangedExpectedHits, greaterThan(0.0)); // From barrage units
      expect(score.maxRange, equals(36)); // From artillery unit

      // Verify the score includes max range in the shareable text
      final shareableText = score.toShareableText();
      expect(shareableText, contains('Max Range: 36'));
    });

    // ===== EMPTY AND EDGE CASE TESTS =====
    test('should handle empty army list', () {
      final armyList = ArmyList(
        name: 'Empty Army',
        faction: 'Nords',
        totalPoints: 0,
        pointsLimit: 2000,
        regiments: const [],
      );

      final score = scoringEngine.calculateScores(armyList);

      expect(score.totalWounds, equals(0));
      expect(score.pointsPerWound, equals(0.0));
      expect(score.expectedHitVolume, equals(0.0));
      expect(score.cleaveRating, equals(0.0));
      expect(score.rangedExpectedHits, equals(0.0));
      expect(score.rangedArmorPiercingRating,
          equals(0.0)); // New metric should also be 0
      expect(score.maxRange, equals(0));
    });

    test('should handle units without cleave or barrage correctly', () {
      final regiments = [
        Regiment(unit: testUnit1, stands: 2, pointsCost: 160),
        Regiment(unit: testUnit2, stands: 1, pointsCost: 170),
      ];

      final armyList = ArmyList(
        name: 'No Special Rules Army',
        faction: 'Nords',
        totalPoints: 330,
        pointsLimit: 2000,
        regiments: regiments,
      );

      final score = scoringEngine.calculateScores(armyList);

      // Both units have no cleave, barrage, or armor piercing, so should be 0
      expect(score.cleaveRating, equals(0.0));
      expect(score.rangedExpectedHits, equals(0.0));
      expect(score.rangedArmorPiercingRating, equals(0.0));
      expect(score.maxRange, equals(0)); // No units with range

      // But should still have expected hit volume
      expect(score.expectedHitVolume, greaterThan(0.0));
    });

    // ===== CHARACTER HANDLING TESTS =====
    test(
        'should calculate complex army with characters and armor piercing correctly',
        () {
      // Create a character unit with armor piercing
      final characterUnit = Unit(
        name: 'Armor Piercing Character',
        faction: 'Test',
        type: 'character',
        regimentClass: 'character',
        characteristics: const UnitCharacteristics(
          march: 6,
          volley: 3,
          clash: 4,
          attacks: 6,
          wounds: 3,
          resolve: 4,
          defense: 3,
          evasion: 2,
        ),
        specialRules: const [],
        numericSpecialRules: const {
          'cleave': 3,
          'barrage': 2,
          'armorPiercingValue': 2,
          'barrageRange': 12
        },
        drawEvents: const [],
        points: 150,
      );

      final regiments = [
        Regiment(unit: characterUnit, stands: 1, pointsCost: 150), // Character
        Regiment(
            unit: testUnitWithAllCapabilities,
            stands: 2,
            pointsCost: 500), // Regular unit
      ];

      final armyList = ArmyList(
        name: 'Army with Armor Piercing Character',
        faction: 'Test',
        totalPoints: 650,
        pointsLimit: 2000,
        regiments: regiments,
      );

      final score = scoringEngine.calculateScores(armyList);

      // Wounds should only count non-character regiments
      expect(score.totalWounds,
          equals(10)); // 2 stands * 5 wounds from testUnitWithAllCapabilities

      // But all ratings should include character
      expect(score.expectedHitVolume, greaterThan(0.0));
      expect(score.cleaveRating, greaterThan(0.0)); // Both units have cleave
      expect(score.rangedExpectedHits,
          greaterThan(0.0)); // Both units have barrage
      expect(score.rangedArmorPiercingRating,
          greaterThan(0.0)); // Both units have armor piercing
      expect(score.maxRange, equals(12)); // Character has 12" range
    });

    test('should not give ranged capability to leaders without barrage', () {
      // Create a leader unit with no barrage capability
      final leaderWithoutBarrage = Unit(
        name: 'Melee Leader',
        faction: 'Test',
        type: 'character',
        regimentClass: 'character',
        characteristics: const UnitCharacteristics(
          march: 6,
          volley: 2,
          clash: 4,
          attacks: 6,
          wounds: 3,
          resolve: 4,
          defense: 3,
          evasion: 2,
        ),
        specialRules: const [
          SpecialRule(
            name: 'Leader',
            description: 'This unit has a leader.',
          )
        ],
        numericSpecialRules: const {
          'cleave': 2,
          'armorPiercingValue': 1
        }, // Has cleave and armor piercing but no barrage
        drawEvents: const [],
        points: 120,
      );

      final regiments = [
        Regiment(unit: leaderWithoutBarrage, stands: 1, pointsCost: 120),
        Regiment(
            unit: testUnit1, stands: 2, pointsCost: 160), // Also no barrage
      ];

      final armyList = ArmyList(
        name: 'Melee Army',
        faction: 'Test',
        totalPoints: 280,
        pointsLimit: 2000,
        regiments: regiments,
      );

      final score = scoringEngine.calculateScores(armyList);

      // Should have cleave rating from the leader
      expect(score.cleaveRating, greaterThan(0.0));
      // But no ranged hits because no units have barrage capability
      expect(score.rangedExpectedHits, equals(0.0));
      // And no ranged armor piercing because no units have ranged capability
      expect(score.rangedArmorPiercingRating, equals(0.0));
      // And no max range because no units have ranged capability
      expect(score.maxRange, equals(0));
      // Should still have expected hit volume from melee combat
      expect(score.expectedHitVolume, greaterThan(0.0));
    });

    // ===== SHAREABLE TEXT TESTS =====
    test('should include armor piercing in shareable text format', () {
      final regiments = [
        Regiment(unit: testUnitWithArmorPiercing, stands: 1, pointsCost: 170),
      ];

      final armyList = ArmyList(
        name: 'Armor Piercing Army',
        faction: 'Test',
        totalPoints: 170,
        pointsLimit: 2000,
        regiments: regiments,
      );

      final score = scoringEngine.calculateScores(armyList);
      final shareableText = score.toShareableText();

      expect(
          shareableText, contains('Army List Analysis: Armor Piercing Army'));
      expect(shareableText, contains('Faction: Test'));
      expect(shareableText, contains('Points: 170/2000'));
      expect(shareableText, contains('Total Wounds:'));
      expect(shareableText, contains('Points per Wound:'));
      expect(shareableText, contains('Expected Hit Volume:'));
      expect(shareableText, contains('Cleave Rating:'));
      expect(shareableText, contains('Ranged Expected Hits:'));
      expect(shareableText, contains('Ranged Armor Piercing:'));
      expect(shareableText, contains('Max Range:'));
      expect(shareableText, contains('Calculated:'));
    });

    test('should include max range in shareable text format', () {
      final regiments = [
        Regiment(unit: testUnitWithRange, stands: 1, pointsCost: 280),
      ];

      final armyList = ArmyList(
        name: 'Artillery Army',
        faction: 'Test',
        totalPoints: 280,
        pointsLimit: 2000,
        regiments: regiments,
      );

      final score = scoringEngine.calculateScores(armyList);
      final shareableText = score.toShareableText();

      expect(shareableText, contains('Army List Analysis: Artillery Army'));
      expect(shareableText, contains('Faction: Test'));
      expect(shareableText, contains('Points: 280/2000'));
      expect(shareableText, contains('Total Wounds:'));
      expect(shareableText, contains('Points per Wound:'));
      expect(shareableText, contains('Expected Hit Volume:'));
      expect(shareableText, contains('Cleave Rating:'));
      expect(shareableText, contains('Ranged Expected Hits:'));
      expect(shareableText, contains('Ranged Armor Piercing:'));
      expect(shareableText, contains('Max Range: 36'));
      expect(shareableText, contains('Calculated:'));
    });

    // ===== RANGE SPECIFIC TESTS =====
    test('should handle multiple units with different ranges correctly', () {
      final shortRangeUnit = Unit(
        name: 'Short Range Unit',
        faction: 'Test',
        type: 'infantry',
        regimentClass: 'light',
        characteristics: const UnitCharacteristics(
          march: 6,
          volley: 4,
          clash: 3,
          attacks: 3,
          wounds: 4,
          resolve: 2,
          defense: 1,
          evasion: 1,
        ),
        specialRules: const [],
        numericSpecialRules: const {
          'barrage': 2,
          'barrageRange': 8
        }, // Short range
        drawEvents: const [],
        points: 120,
      );

      final mediumRangeUnit = Unit(
        name: 'Medium Range Unit',
        faction: 'Test',
        type: 'infantry',
        regimentClass: 'medium',
        characteristics: const UnitCharacteristics(
          march: 5,
          volley: 3,
          clash: 2,
          attacks: 3,
          wounds: 5,
          resolve: 3,
          defense: 2,
          evasion: 1,
        ),
        specialRules: const [],
        numericSpecialRules: const {
          'barrage': 2,
          'barrageRange': 18
        }, // Medium range
        drawEvents: const [],
        points: 160,
      );

      final regiments = [
        Regiment(unit: shortRangeUnit, stands: 2, pointsCost: 160), // Range 8
        Regiment(unit: mediumRangeUnit, stands: 1, pointsCost: 160), // Range 18
        Regiment(
            unit: testUnitWithRange, stands: 1, pointsCost: 280), // Range 36
        Regiment(unit: testUnit1, stands: 1, pointsCost: 120), // No range
      ];

      final armyList = ArmyList(
        name: 'Multi-Range Army',
        faction: 'Test',
        totalPoints: 720,
        pointsLimit: 2000,
        regiments: regiments,
      );

      final score = scoringEngine.calculateScores(armyList);

      // Should pick the highest range (36 from artillery)
      expect(score.maxRange, equals(36));
      expect(score.rangedExpectedHits, greaterThan(0.0));
    });

    test('should handle army with only melee units (no ranged)', () {
      final regiments = [
        Regiment(unit: testUnit1, stands: 3, pointsCost: 200),
        Regiment(unit: testUnitWithCleave, stands: 2, pointsCost: 400),
      ];

      final armyList = ArmyList(
        name: 'Melee Only Army',
        faction: 'Test',
        totalPoints: 600,
        pointsLimit: 2000,
        regiments: regiments,
      );

      final score = scoringEngine.calculateScores(armyList);

      expect(score.totalWounds, greaterThan(0));
      expect(score.expectedHitVolume, greaterThan(0.0));
      expect(score.cleaveRating, greaterThan(0.0)); // From cleave unit
      expect(score.rangedExpectedHits, equals(0.0)); // No ranged units
      expect(score.rangedArmorPiercingRating, equals(0.0)); // No ranged units
      expect(score.maxRange, equals(0)); // No ranged units
    });

    test(
        'should correctly calculate max range when some units have barrage but no range',
        () {
      final regiments = [
        Regiment(
            unit: testUnitWithBarrage,
            stands: 2,
            pointsCost: 280), // Has barrage, no range specified (0)
        Regiment(
            unit: testUnitWithRange,
            stands: 1,
            pointsCost: 280), // Has barrage and range 36
      ];

      final armyList = ArmyList(
        name: 'Mixed Range Army',
        faction: 'Test',
        totalPoints: 560,
        pointsLimit: 2000,
        regiments: regiments,
      );

      final score = scoringEngine.calculateScores(armyList);

      // Should return the highest specified range, ignoring units with 0 range
      expect(score.maxRange, equals(36));
      expect(
          score.rangedExpectedHits, greaterThan(0.0)); // Both units can shoot
    });

    test('should handle edge case where all ranged units have 0 range', () {
      final zeroRangeUnit = Unit(
        name: 'Zero Range Unit',
        faction: 'Test',
        type: 'infantry',
        regimentClass: 'light',
        characteristics: const UnitCharacteristics(
          march: 6,
          volley: 3,
          clash: 3,
          attacks: 4,
          wounds: 4,
          resolve: 2,
          defense: 1,
          evasion: 1,
        ),
        specialRules: const [],
        numericSpecialRules: const {
          'barrage': 1,
          'barrageRange': 0
        }, // Explicitly 0 range
        drawEvents: const [],
        points: 100,
      );

      final regiments = [
        Regiment(unit: zeroRangeUnit, stands: 2, pointsCost: 140),
        Regiment(
            unit: testUnitWithBarrage,
            stands: 1,
            pointsCost: 140), // Also 0 range (not specified)
      ];

      final armyList = ArmyList(
        name: 'Zero Range Army',
        faction: 'Test',
        totalPoints: 280,
        pointsLimit: 2000,
        regiments: regiments,
      );

      final score = scoringEngine.calculateScores(armyList);

      expect(score.maxRange, equals(0)); // All units have 0 range
      expect(score.rangedExpectedHits,
          greaterThan(0.0)); // But they can still shoot
    });

    // ===== BACKWARDS COMPATIBILITY TESTS =====
    test('should maintain backwards compatibility with existing tests', () {
      // Ensure existing functionality still works with new armor piercing feature
      final regiments = [
        Regiment(
            unit: testUnit1,
            stands: 3,
            pointsCost: 200), // No special abilities
        Regiment(
            unit: testUnitWithCleave,
            stands: 2,
            pointsCost: 400), // Only cleave
      ];

      final armyList = ArmyList(
        name: 'Backwards Compatible Army',
        faction: 'Test',
        totalPoints: 600,
        pointsLimit: 2000,
        regiments: regiments,
      );

      final score = scoringEngine.calculateScores(armyList);

      expect(score.totalWounds, greaterThan(0));
      expect(score.expectedHitVolume, greaterThan(0.0));
      expect(score.cleaveRating, greaterThan(0.0)); // From cleave unit
      expect(score.rangedExpectedHits, equals(0.0)); // No ranged units
      expect(score.rangedArmorPiercingRating, equals(0.0)); // No armor piercing
      expect(score.maxRange, equals(0)); // No ranged units
    });

    // ===== COMPREHENSIVE VALIDATION TESTS =====
    test('should handle all possible combinations of special rules', () {
      final allCombinationsUnits = [
        testUnit1, // Nothing
        testUnitWithCleave, // Only cleave
        testUnitWithBarrage, // Only barrage
        testUnitWithArmorPiercing, // Barrage + armor piercing
        testUnitWithBoth, // Cleave + barrage
        testUnitWithRange, // Barrage + range
        testUnitWithBarrageAndArmorPiercing, // Barrage + armor piercing + range
        testUnitWithAllCapabilities, // Everything
      ];

      for (int i = 0; i < allCombinationsUnits.length; i++) {
        final regiments = [
          Regiment(unit: allCombinationsUnits[i], stands: 1, pointsCost: 200),
        ];

        final armyList = ArmyList(
          name: 'Test Army $i',
          faction: 'Test',
          totalPoints: 200,
          pointsLimit: 2000,
          regiments: regiments,
        );

        final score = scoringEngine.calculateScores(armyList);

        // All scores should be non-negative
        expect(score.totalWounds, greaterThanOrEqualTo(0));
        expect(score.pointsPerWound, greaterThanOrEqualTo(0.0));
        expect(score.expectedHitVolume, greaterThanOrEqualTo(0.0));
        expect(score.cleaveRating, greaterThanOrEqualTo(0.0));
        expect(score.rangedExpectedHits, greaterThanOrEqualTo(0.0));
        expect(score.rangedArmorPiercingRating, greaterThanOrEqualTo(0.0));
        expect(score.maxRange, greaterThanOrEqualTo(0));

        // Validate logic relationships
        if (allCombinationsUnits[i].numericSpecialRules['barrage'] == null) {
          expect(score.rangedExpectedHits, equals(0.0));
          expect(score.rangedArmorPiercingRating, equals(0.0));
          expect(score.maxRange, equals(0));
        }

        if (allCombinationsUnits[i].numericSpecialRules['cleave'] == null) {
          expect(score.cleaveRating, equals(0.0));
        }

        if (allCombinationsUnits[i].numericSpecialRules['armorPiercingValue'] ==
                null ||
            allCombinationsUnits[i].numericSpecialRules['barrage'] == null) {
          expect(score.rangedArmorPiercingRating, equals(0.0));
        }
      }
    });
  });
}
