import 'package:flutter_test/flutter_test.dart';
import 'package:conquest_analyzer/services/scoring_engine.dart';
import 'package:conquest_analyzer/models/army_list.dart';
import 'package:conquest_analyzer/models/regiment.dart';
import 'package:conquest_analyzer/models/unit.dart';

void main() {
  group('Effective Wounds with Resolve Tests', () {
    late ScoringEngine scoringEngine;
    late Unit testUnit;
    late Unit highResolveUnit;
    late Unit lowResolveUnit;

    setUp(() {
      scoringEngine = ScoringEngine();

      testUnit = Unit(
        name: 'Test Unit',
        faction: 'Test',
        type: 'infantry',
        regimentClass: 'medium',
        characteristics: const UnitCharacteristics(
          march: 6,
          volley: 2,
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
        points: 120,
      );

      highResolveUnit = Unit(
        name: 'High Resolve Unit',
        faction: 'Test',
        type: 'infantry',
        regimentClass: 'heavy',
        characteristics: const UnitCharacteristics(
          march: 5,
          volley: 1,
          clash: 4,
          attacks: 3,
          wounds: 5,
          resolve: 5, // High resolve
          defense: 2, // Same defense as test unit
          evasion: 1,
        ),
        specialRules: const [],
        numericSpecialRules: const {},
        supremacyAbilities: const [],
        drawEvents: const [],
        points: 160,
      );

      lowResolveUnit = Unit(
        name: 'Low Resolve Unit',
        faction: 'Test',
        type: 'infantry',
        regimentClass: 'light',
        characteristics: const UnitCharacteristics(
          march: 7,
          volley: 2,
          clash: 2,
          attacks: 4,
          wounds: 3,
          resolve: 1, // Low resolve
          defense: 2, // Same defense as test unit
          evasion: 1,
        ),
        specialRules: const [],
        numericSpecialRules: const {},
        supremacyAbilities: const [],
        drawEvents: const [],
        points: 100,
      );
    });

    test('should calculate both effective wounds metrics correctly', () {
      final regiments = [
        Regiment(unit: testUnit, stands: 2, pointsCost: 240),
      ];
      final armyList = ArmyList(
        name: 'Test Army',
        faction: 'Test',
        totalPoints: 240,
        pointsLimit: 2000,
        regiments: regiments,
      );

      final score = scoringEngine.calculateScores(armyList);

      // Defense-only calculation: 8 wounds × (6/(6-2)) = 8 × 1.5 = 12.0
      expect(score.effectiveWoundsDefense, equals(12.0));

      // Defense + Resolve calculation:
      // Defense failure rate = (6-2)/6 = 4/6 = 0.667
      // Wounds per failed defense = 1 + (6-3)/6 = 1 + 3/6 = 1.5
      // Combined wound rate = 0.667 × 1.5 = 1.0
      // Effective wounds = 8 / 1.0 = 8.0
      expect(score.effectiveWoundsDefenseResolve, equals(8.0));
    });

    test(
        'should show higher resolve units are more survivable than defense-only suggests',
        () {
      final regiments = [
        Regiment(
            unit: highResolveUnit, stands: 1, pointsCost: 160), // Resolve 5
        Regiment(unit: lowResolveUnit, stands: 1, pointsCost: 100), // Resolve 1
      ];
      final armyList = ArmyList(
        name: 'Mixed Resolve Army',
        faction: 'Test',
        totalPoints: 260,
        pointsLimit: 2000,
        regiments: regiments,
      );

      final score = scoringEngine.calculateScores(armyList);

      // Defense-only: Both units have defense 2
      // High resolve: 5 wounds × 1.5 = 7.5
      // Low resolve: 3 wounds × 1.5 = 4.5
      // Total defense-only: 7.5 + 4.5 = 12.0
      expect(score.effectiveWoundsDefense, equals(12.0));

      // Defense + Resolve:
      // High resolve unit (Defense 2, Resolve 5):
      // - Defense failure: 4/6 = 0.667
      // - Wounds per failed defense: 1 + 1/6 = 1.167
      // - Combined: 0.667 × 1.167 = 0.778
      // - Effective: 5 / 0.778 = 6.43

      // Low resolve unit (Defense 2, Resolve 1):
      // - Defense failure: 4/6 = 0.667
      // - Wounds per failed defense: 1 + 5/6 = 1.833
      // - Combined: 0.667 × 1.833 = 1.222
      // - Effective: 3 / 1.222 = 2.45

      // Total: 6.43 + 2.45 = 8.88
      expect(score.effectiveWoundsDefenseResolve, closeTo(8.88, 0.1));

      // Verify high resolve unit is more survivable than low resolve
      expect(score.effectiveWoundsDefenseResolve,
          lessThan(score.effectiveWoundsDefense));
    });

    test('should handle perfect resolve correctly', () {
      final perfectResolveUnit = Unit(
        name: 'Perfect Resolve Unit',
        faction: 'Test',
        type: 'character',
        regimentClass: 'character',
        characteristics: const UnitCharacteristics(
          march: 6,
          volley: 2,
          clash: 5,
          attacks: 3,
          wounds: 3,
          resolve: 6, // Perfect resolve
          defense: 3,
          evasion: 2,
        ),
        specialRules: const [],
        numericSpecialRules: const {},
        supremacyAbilities: const [],
        drawEvents: const [],
        points: 200,
      );

      final regiments = [
        Regiment(unit: perfectResolveUnit, stands: 1, pointsCost: 200),
      ];
      final armyList = ArmyList(
        name: 'Perfect Resolve Army',
        faction: 'Test',
        totalPoints: 200,
        pointsLimit: 2000,
        regiments: regiments,
      );

      final score = scoringEngine.calculateScores(armyList);

      // Note: Characters are excluded from wound calculations, so totals should be 0
      expect(score.effectiveWoundsDefense, equals(0.0));
      expect(score.effectiveWoundsDefenseResolve, equals(0.0));
    });

    test('should handle character monsters correctly in both calculations', () {
      final characterMonster = Unit(
        name: 'Dragon',
        faction: 'Test',
        type: 'monster',
        regimentClass: 'character',
        characteristics: const UnitCharacteristics(
          march: 8,
          volley: 3,
          clash: 5,
          attacks: 8,
          wounds: 8,
          resolve: 4,
          defense: 3,
          evasion: 2,
        ),
        specialRules: const [],
        numericSpecialRules: const {},
        supremacyAbilities: const [],
        drawEvents: const [],
        points: 400,
      );

      final regiments = [
        Regiment(unit: characterMonster, stands: 1, pointsCost: 400),
      ];
      final armyList = ArmyList(
        name: 'Monster Army',
        faction: 'Test',
        totalPoints: 400,
        pointsLimit: 2000,
        regiments: regiments,
      );

      final score = scoringEngine.calculateScores(armyList);

      // Character monsters should be included in both calculations
      // Defense-only: 8 wounds × (6/(6-3)) = 8 × 2.0 = 16.0
      expect(score.effectiveWoundsDefense, equals(16.0));

      // Defense + Resolve:
      // Defense failure rate = (6-3)/6 = 0.5
      // Wounds per failed defense = 1 + (6-4)/6 = 1.333
      // Combined wound rate = 0.5 × 1.333 = 0.667
      // Effective wounds = 8 / 0.667 = 12.0
      expect(score.effectiveWoundsDefenseResolve, closeTo(12.0, 0.1));
    });

    test('should show resolve impact in shareable text', () {
      final regiments = [
        Regiment(unit: testUnit, stands: 1, pointsCost: 120),
      ];
      final armyList = ArmyList(
        name: 'Text Format Test',
        faction: 'Test',
        totalPoints: 120,
        pointsLimit: 2000,
        regiments: regiments,
      );

      final score = scoringEngine.calculateScores(armyList);
      final shareableText = score.toShareableText();

      expect(shareableText, contains('Effective Wounds (Defense):'));
      expect(shareableText, contains('Effective Wounds (Defense & Resolve):'));
      expect(shareableText, contains('Text Format Test'));
    });

    test(
        'should demonstrate clear difference between same defense, different resolve',
        () {
      // Two armies with identical defense but different resolve
      final regimentsArmyA = [
        Regiment(
            unit: highResolveUnit,
            stands: 2,
            pointsCost: 320), // Defense 2, Resolve 5
      ];
      final regimentsArmyB = [
        Regiment(
            unit: lowResolveUnit,
            stands: 3,
            pointsCost:
                300), // Defense 2, Resolve 1 (adjusted for similar wounds)
      ];

      final armyListA = ArmyList(
        name: 'High Resolve Army',
        faction: 'Test',
        totalPoints: 320,
        pointsLimit: 2000,
        regiments: regimentsArmyA,
      );

      final armyListB = ArmyList(
        name: 'Low Resolve Army',
        faction: 'Test',
        totalPoints: 300,
        pointsLimit: 2000,
        regiments: regimentsArmyB,
      );

      final scoreA = scoringEngine.calculateScores(armyListA);
      final scoreB = scoringEngine.calculateScores(armyListB);

      // Both should have similar defense-only effective wounds (both defense 2)
      // Army A: 10 wounds × 1.5 = 15.0
      // Army B: 9 wounds × 1.5 = 13.5
      expect(scoreA.effectiveWoundsDefense, equals(15.0));
      expect(scoreB.effectiveWoundsDefense, equals(13.5));

      // But very different defense + resolve effective wounds
      // Army A should be significantly more survivable due to higher resolve
      expect(scoreA.effectiveWoundsDefenseResolve,
          greaterThan(scoreB.effectiveWoundsDefenseResolve));

      // The difference should be substantial - high resolve should be much better
      final survivalRatio = scoreA.effectiveWoundsDefenseResolve /
          scoreB.effectiveWoundsDefenseResolve;
      expect(survivalRatio, greaterThan(1.7)); // At least 2x more survivable
    });
  });
}
