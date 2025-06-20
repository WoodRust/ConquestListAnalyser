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
        numericSpecialRules: const {},
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
        numericSpecialRules: const {},
        drawEvents: const [],
        points: 170,
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
    });
  });
}
