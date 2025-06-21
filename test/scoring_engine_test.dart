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
        numericSpecialRules: const {}, // No cleave or barrage
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
        numericSpecialRules: const {}, // No cleave or barrage
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
        numericSpecialRules: const {'barrage': 2}, // Has barrage(2)
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
        numericSpecialRules: const {'cleave': 1, 'barrage': 1}, // Has both
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
        }, // Has long range
        drawEvents: const [],
        points: 280,
      );
    });

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
      expect(score.maxRange, equals(0)); // No units, no range
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

      // Both units have no cleave or barrage, so should be 0
      expect(score.cleaveRating, equals(0.0));
      expect(score.rangedExpectedHits, equals(0.0));
      expect(score.maxRange, equals(0)); // No units with range

      // But should still have expected hit volume
      expect(score.expectedHitVolume, greaterThan(0.0));
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
        numericSpecialRules: const {'cleave': 2}, // Has cleave but no barrage
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
      // And no max range because no units have ranged capability
      expect(score.maxRange, equals(0));
      // Should still have expected hit volume from melee combat
      expect(score.expectedHitVolume, greaterThan(0.0));
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
      expect(shareableText, contains('Max Range: 36'));
      expect(shareableText, contains('Calculated:'));
    });

    test('should calculate complex army with characters correctly', () {
      // Create a character unit (characters are not counted in wounds)
      final characterUnit = Unit(
        name: 'Test Character',
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
        specialRules: const [],
        numericSpecialRules: const {
          'cleave': 3,
          'barrage': 1,
          'barrageRange': 12
        },
        drawEvents: const [],
        points: 150,
      );

      final regiments = [
        Regiment(unit: characterUnit, stands: 1, pointsCost: 150), // Character
        Regiment(
            unit: testUnitWithBoth, stands: 2, pointsCost: 360), // Regular unit
      ];

      final armyList = ArmyList(
        name: 'Army with Character',
        faction: 'Test',
        totalPoints: 510,
        pointsLimit: 2000,
        regiments: regiments,
      );

      final score = scoringEngine.calculateScores(armyList);

      // Wounds should only count non-character regiments
      expect(score.totalWounds,
          equals(10)); // 2 stands * 5 wounds from testUnitWithBoth
      // But hit volumes and ratings should include character
      expect(score.expectedHitVolume, greaterThan(0.0));
      expect(score.cleaveRating, greaterThan(0.0)); // Both units have cleave
      expect(score.rangedExpectedHits,
          greaterThan(0.0)); // Both units have barrage
      expect(score.maxRange, equals(12)); // Character has 12" range
    });

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
  });
}
