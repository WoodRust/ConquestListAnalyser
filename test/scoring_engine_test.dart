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
        numericSpecialRules: const {}, // No cleave
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
        numericSpecialRules: const {}, // No cleave
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
    });

    test('should handle units without cleave correctly', () {
      final regiments = [
        Regiment(unit: testUnit1, stands: 2, pointsCost: 160),
        Regiment(unit: testUnit2, stands: 1, pointsCost: 170),
      ];

      final armyList = ArmyList(
        name: 'No Cleave Army',
        faction: 'Nords',
        totalPoints: 330,
        pointsLimit: 2000,
        regiments: regiments,
      );

      final score = scoringEngine.calculateScores(armyList);

      // Both units have no cleave, so cleave rating should be 0
      expect(score.cleaveRating, equals(0.0));

      // But should still have expected hit volume
      expect(score.expectedHitVolume, greaterThan(0.0));
    });

    test('should calculate regiment cleave values correctly', () {
      final regimentWithCleave =
          Regiment(unit: testUnitWithCleave, stands: 1, pointsCost: 200);
      final regimentWithoutCleave =
          Regiment(unit: testUnit1, stands: 1, pointsCost: 120);

      expect(regimentWithCleave.cleaveValue, equals(2));
      expect(regimentWithoutCleave.cleaveValue, equals(0));

      expect(regimentWithCleave.cleaveRating, greaterThan(0.0));
      expect(regimentWithoutCleave.cleaveRating, equals(0.0));
    });
  });
}
