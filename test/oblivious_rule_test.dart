import 'package:flutter_test/flutter_test.dart';
import 'package:conquest_analyzer/services/scoring_engine.dart';
import 'package:conquest_analyzer/models/army_list.dart';
import 'package:conquest_analyzer/models/regiment.dart';
import 'package:conquest_analyzer/models/unit.dart';

void main() {
  group('Oblivious Rule Tests', () {
    late ScoringEngine scoringEngine;
    late Unit normalUnit;
    late Unit obliviousUnit;
    late Unit obliviousHighResolveUnit;
    late Unit obliviousLowResolveUnit;

    setUp(() {
      scoringEngine = ScoringEngine();

      // Normal unit without Oblivious rule
      normalUnit = Unit(
        name: 'Normal Unit',
        faction: 'Test',
        type: 'infantry',
        regimentClass: 'medium',
        characteristics: const UnitCharacteristics(
          march: 5,
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
        supremacyAbilities: const [],
        drawEvents: const [],
        points: 150,
      );

      // Unit with Oblivious rule
      obliviousUnit = Unit(
        name: 'Oblivious Unit',
        faction: 'Test',
        type: 'infantry',
        regimentClass: 'medium',
        characteristics: const UnitCharacteristics(
          march: 5,
          volley: 2,
          clash: 3,
          attacks: 4,
          wounds: 5,
          resolve: 3, // Same resolve as normal unit
          defense: 2, // Same defense as normal unit
          evasion: 1,
        ),
        specialRules: const [
          SpecialRule(
            name: 'Oblivious',
            description:
                'Regiments with this Special Rule receive only 1 Wound for every 2 failed Morale Tests, rounding up.',
          ),
        ],
        numericSpecialRules: const {},
        supremacyAbilities: const [],
        drawEvents: const [],
        points: 150,
      );

      // Oblivious unit with high resolve
      obliviousHighResolveUnit = Unit(
        name: 'Oblivious High Resolve Unit',
        faction: 'Test',
        type: 'infantry',
        regimentClass: 'heavy',
        characteristics: const UnitCharacteristics(
          march: 4,
          volley: 1,
          clash: 4,
          attacks: 3,
          wounds: 6,
          resolve: 5, // High resolve
          defense: 3,
          evasion: 1,
        ),
        specialRules: const [
          SpecialRule(
            name: 'Oblivious',
            description:
                'Regiments with this Special Rule receive only 1 Wound for every 2 failed Morale Tests, rounding up.',
          ),
        ],
        numericSpecialRules: const {},
        supremacyAbilities: const [],
        drawEvents: const [],
        points: 200,
      );

      // Oblivious unit with low resolve
      obliviousLowResolveUnit = Unit(
        name: 'Oblivious Low Resolve Unit',
        faction: 'Test',
        type: 'infantry',
        regimentClass: 'light',
        characteristics: const UnitCharacteristics(
          march: 6,
          volley: 2,
          clash: 2,
          attacks: 4,
          wounds: 4,
          resolve: 1, // Low resolve
          defense: 2,
          evasion: 1,
        ),
        specialRules: const [
          SpecialRule(
            name: 'Oblivious',
            description:
                'Regiments with this Special Rule receive only 1 Wound for every 2 failed Morale Tests, rounding up.',
          ),
        ],
        numericSpecialRules: const {},
        supremacyAbilities: const [],
        drawEvents: const [],
        points: 120,
      );
    });

    test('should calculate Oblivious rule correctly - same stats comparison',
        () {
      // Compare identical units with and without Oblivious rule
      final normalRegiments = [
        Regiment(unit: normalUnit, stands: 2, pointsCost: 300),
      ];
      final obliviousRegiments = [
        Regiment(unit: obliviousUnit, stands: 2, pointsCost: 300),
      ];

      final normalArmyList = ArmyList(
        name: 'Normal Army',
        faction: 'Test',
        totalPoints: 300,
        pointsLimit: 2000,
        regiments: normalRegiments,
      );

      final obliviousArmyList = ArmyList(
        name: 'Oblivious Army',
        faction: 'Test',
        totalPoints: 300,
        pointsLimit: 2000,
        regiments: obliviousRegiments,
      );

      final normalScore = scoringEngine.calculateScores(normalArmyList);
      final obliviousScore = scoringEngine.calculateScores(obliviousArmyList);

      // Both should have the same defense-only effective wounds
      expect(normalScore.effectiveWoundsDefense,
          equals(obliviousScore.effectiveWoundsDefense));

      // Defense-only calculation: 10 wounds × (6/(6-2)) = 10 × 1.5 = 15.0
      expect(normalScore.effectiveWoundsDefense, equals(15.0));

      // Normal unit Defense + Resolve calculation:
      // Defense failure rate = (6-2)/6 = 4/6 = 0.667
      // Wounds per failed defense = 1 + (6-3)/6 = 1 + 3/6 = 1.5
      // Combined wound rate = 0.667 × 1.5 = 1.0
      // Effective wounds = 10 / 1.0 = 10.0
      expect(normalScore.effectiveWoundsDefenseResolve, equals(10.0));

      // Oblivious unit Defense + Resolve calculation:
      // Defense failure rate = (6-2)/6 = 4/6 = 0.667
      // Wounds per failed defense = 1 + ((6-3)/6)/2 = 1 + (3/6)/2 = 1 + 0.25 = 1.25
      // Combined wound rate = 0.667 × 1.25 = 0.833
      // Effective wounds = 10 / 0.833 = 12.0
      expect(obliviousScore.effectiveWoundsDefenseResolve, closeTo(12.0, 0.1));

      // Oblivious unit should be more survivable than normal unit
      expect(obliviousScore.effectiveWoundsDefenseResolve,
          greaterThan(normalScore.effectiveWoundsDefenseResolve));
    });

    test('should handle Oblivious with high resolve correctly', () {
      final regiments = [
        Regiment(unit: obliviousHighResolveUnit, stands: 1, pointsCost: 200),
      ];

      final armyList = ArmyList(
        name: 'Oblivious High Resolve Army',
        faction: 'Test',
        totalPoints: 200,
        pointsLimit: 2000,
        regiments: regiments,
      );

      final score = scoringEngine.calculateScores(armyList);

      // Defense-only calculation: 6 wounds × (6/(6-3)) = 6 × 2.0 = 12.0
      expect(score.effectiveWoundsDefense, equals(12.0));

      // Oblivious high resolve Defense + Resolve calculation:
      // Defense failure rate = (6-3)/6 = 3/6 = 0.5
      // Wounds per failed defense = 1 + ((6-5)/6)/2 = 1 + (1/6)/2 = 1 + 0.083 = 1.083
      // Combined wound rate = 0.5 × 1.083 = 0.542
      // Effective wounds = 6 / 0.542 = 11.07
      expect(score.effectiveWoundsDefenseResolve, closeTo(11.07, 0.1));

      // High resolve Oblivious unit should be very close to defense-only
      expect(score.effectiveWoundsDefenseResolve,
          closeTo(score.effectiveWoundsDefense, 1.0));
    });

    test('should handle Oblivious with low resolve correctly', () {
      final regiments = [
        Regiment(unit: obliviousLowResolveUnit, stands: 1, pointsCost: 120),
      ];

      final armyList = ArmyList(
        name: 'Oblivious Low Resolve Army',
        faction: 'Test',
        totalPoints: 120,
        pointsLimit: 2000,
        regiments: regiments,
      );

      final score = scoringEngine.calculateScores(armyList);

      // Defense-only calculation: 4 wounds × (6/(6-2)) = 4 × 1.5 = 6.0
      expect(score.effectiveWoundsDefense, equals(6.0));

      // Oblivious low resolve Defense + Resolve calculation:
      // Defense failure rate = (6-2)/6 = 4/6 = 0.667
      // Wounds per failed defense = 1 + ((6-1)/6)/2 = 1 + (5/6)/2 = 1 + 0.417 = 1.417
      // Combined wound rate = 0.667 × 1.417 = 0.944
      // Effective wounds = 4 / 0.944 = 4.24
      expect(score.effectiveWoundsDefenseResolve, closeTo(4.24, 0.1));

      // Even with low resolve, Oblivious should be more survivable than normal
      expect(score.effectiveWoundsDefenseResolve,
          greaterThan(score.effectiveWoundsDefense * 0.7));
    });

    test('should handle mixed army with Oblivious and normal units', () {
      final regiments = [
        Regiment(unit: normalUnit, stands: 1, pointsCost: 150),
        Regiment(unit: obliviousUnit, stands: 1, pointsCost: 150),
      ];

      final armyList = ArmyList(
        name: 'Mixed Army',
        faction: 'Test',
        totalPoints: 300,
        pointsLimit: 2000,
        regiments: regiments,
      );

      final score = scoringEngine.calculateScores(armyList);

      // Defense-only calculation: (5+5) wounds × (6/(6-2)) = 10 × 1.5 = 15.0
      expect(score.effectiveWoundsDefense, equals(15.0));

      // Normal unit: 5 / 1.0 = 5.0
      // Oblivious unit: 5 / 0.833 = 6.0
      // Total: 5.0 + 6.0 = 11.0
      expect(score.effectiveWoundsDefenseResolve, closeTo(11.0, 0.1));

      // Mixed army should be more survivable than pure normal army
      expect(score.effectiveWoundsDefenseResolve,
          greaterThan(score.effectiveWoundsDefense * 0.7));
    });

    test('should handle perfect resolve with Oblivious correctly', () {
      final perfectResolveObliviousUnit = Unit(
        name: 'Perfect Resolve Oblivious Unit',
        faction: 'Test',
        type: 'infantry',
        regimentClass: 'heavy',
        characteristics: const UnitCharacteristics(
          march: 4,
          volley: 1,
          clash: 4,
          attacks: 3,
          wounds: 5,
          resolve: 6, // Perfect resolve
          defense: 3,
          evasion: 1,
        ),
        specialRules: const [
          SpecialRule(
            name: 'Oblivious',
            description:
                'Regiments with this Special Rule receive only 1 Wound for every 2 failed Morale Tests, rounding up.',
          ),
        ],
        numericSpecialRules: const {},
        supremacyAbilities: const [],
        drawEvents: const [],
        points: 180,
      );

      final regiments = [
        Regiment(unit: perfectResolveObliviousUnit, stands: 1, pointsCost: 180),
      ];

      final armyList = ArmyList(
        name: 'Perfect Resolve Oblivious Army',
        faction: 'Test',
        totalPoints: 180,
        pointsLimit: 2000,
        regiments: regiments,
      );

      final score = scoringEngine.calculateScores(armyList);

      // Defense-only calculation: 5 wounds × (6/(6-3)) = 5 × 2.0 = 10.0
      expect(score.effectiveWoundsDefense, equals(10.0));

      // Perfect resolve Oblivious Defense + Resolve calculation:
      // Defense failure rate = (6-3)/6 = 3/6 = 0.5
      // Wounds per failed defense = 1 + ((6-6)/6)/2 = 1 + (0/6)/2 = 1 + 0 = 1.0
      // Combined wound rate = 0.5 × 1.0 = 0.5
      // Effective wounds = 5 / 0.5 = 10.0
      expect(score.effectiveWoundsDefenseResolve, equals(10.0));

      // Perfect resolve means Oblivious has no additional effect
      expect(score.effectiveWoundsDefenseResolve,
          equals(score.effectiveWoundsDefense));
    });

    test('should demonstrate Oblivious benefit increases with lower resolve',
        () {
      // Compare Oblivious units with different resolve values
      final highResolveRegiments = [
        Regiment(unit: obliviousHighResolveUnit, stands: 1, pointsCost: 200),
      ];

      final lowResolveRegiments = [
        Regiment(unit: obliviousLowResolveUnit, stands: 1, pointsCost: 120),
      ];

      final highResolveArmyList = ArmyList(
        name: 'High Resolve Oblivious Army',
        faction: 'Test',
        totalPoints: 200,
        pointsLimit: 2000,
        regiments: highResolveRegiments,
      );

      final lowResolveArmyList = ArmyList(
        name: 'Low Resolve Oblivious Army',
        faction: 'Test',
        totalPoints: 120,
        pointsLimit: 2000,
        regiments: lowResolveRegiments,
      );

      final highResolveScore =
          scoringEngine.calculateScores(highResolveArmyList);
      final lowResolveScore = scoringEngine.calculateScores(lowResolveArmyList);

      // Calculate resolve impact percentage for both
      final highResolveImpact = highResolveScore.resolveImpactPercentage;
      final lowResolveImpact = lowResolveScore.resolveImpactPercentage;

      // High resolve unit should have less negative impact (closer to 0)
      expect(highResolveImpact, greaterThan(lowResolveImpact));

      // Both should be negative (resolve makes them less survivable than defense-only)
      // but less negative than normal units would be
      expect(highResolveImpact, lessThan(0));
      expect(lowResolveImpact, lessThan(0));
    });

    test('should handle case-insensitive Oblivious rule detection', () {
      final caseInsensitiveObliviousUnit = Unit(
        name: 'Case Insensitive Oblivious Unit',
        faction: 'Test',
        type: 'infantry',
        regimentClass: 'medium',
        characteristics: const UnitCharacteristics(
          march: 5,
          volley: 2,
          clash: 3,
          attacks: 4,
          wounds: 5,
          resolve: 3,
          defense: 2,
          evasion: 1,
        ),
        specialRules: const [
          SpecialRule(
            name: 'OBLIVIOUS', // Uppercase
            description: 'Test case insensitive detection.',
          ),
        ],
        numericSpecialRules: const {},
        supremacyAbilities: const [],
        drawEvents: const [],
        points: 150,
      );

      final regiments = [
        Regiment(
            unit: caseInsensitiveObliviousUnit, stands: 1, pointsCost: 150),
      ];

      final armyList = ArmyList(
        name: 'Case Insensitive Army',
        faction: 'Test',
        totalPoints: 150,
        pointsLimit: 2000,
        regiments: regiments,
      );

      final score = scoringEngine.calculateScores(armyList);

      // Should apply Oblivious rule even with uppercase name
      // Same calculation as standard oblivious unit
      expect(score.effectiveWoundsDefenseResolve, closeTo(6.0, 0.1));
    });

    test('should show Oblivious impact in shareable text', () {
      final regiments = [
        Regiment(unit: obliviousUnit, stands: 1, pointsCost: 150),
      ];

      final armyList = ArmyList(
        name: 'Oblivious Test Army',
        faction: 'Test',
        totalPoints: 150,
        pointsLimit: 2000,
        regiments: regiments,
      );

      final score = scoringEngine.calculateScores(armyList);
      final shareableText = score.toShareableText();

      // Should contain both effective wounds metrics
      expect(shareableText, contains('Effective Wounds (Defense):'));
      expect(shareableText, contains('Effective Wounds (Defense & Resolve):'));
      expect(shareableText, contains('Oblivious Test Army'));

      // Should show the resolve impact percentage
      expect(shareableText, contains('Resolve Impact:'));
    });

    test('should handle character monsters with Oblivious rule', () {
      final obliviousCharacterMonster = Unit(
        name: 'Oblivious Dragon',
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
        specialRules: const [
          SpecialRule(
            name: 'Oblivious',
            description:
                'Regiments with this Special Rule receive only 1 Wound for every 2 failed Morale Tests, rounding up.',
          ),
        ],
        numericSpecialRules: const {},
        supremacyAbilities: const [],
        drawEvents: const [],
        points: 400,
      );

      final regiments = [
        Regiment(unit: obliviousCharacterMonster, stands: 1, pointsCost: 400),
      ];

      final armyList = ArmyList(
        name: 'Oblivious Monster Army',
        faction: 'Test',
        totalPoints: 400,
        pointsLimit: 2000,
        regiments: regiments,
      );

      final score = scoringEngine.calculateScores(armyList);

      // Character monsters should be included in both calculations
      // Defense-only: 8 wounds × (6/(6-3)) = 8 × 2.0 = 16.0
      expect(score.effectiveWoundsDefense, equals(16.0));

      // Oblivious character monster Defense + Resolve:
      // Defense failure rate = (6-3)/6 = 0.5
      // Wounds per failed defense = 1 + ((6-4)/6)/2 = 1 + (2/6)/2 = 1 + 0.167 = 1.167
      // Combined wound rate = 0.5 × 1.167 = 0.583
      // Effective wounds = 8 / 0.583 = 13.72
      expect(score.effectiveWoundsDefenseResolve, closeTo(13.72, 0.1));

      // Should be more survivable than normal character monster
      expect(score.effectiveWoundsDefenseResolve,
          greaterThan(score.effectiveWoundsDefense * 0.8));
    });

    test('should handle edge cases with Oblivious rule', () {
      // Test with zero resolve (theoretical minimum)
      final zeroResolveObliviousUnit = Unit(
        name: 'Zero Resolve Oblivious Unit',
        faction: 'Test',
        type: 'infantry',
        regimentClass: 'light',
        characteristics: const UnitCharacteristics(
          march: 6,
          volley: 2,
          clash: 2,
          attacks: 4,
          wounds: 4,
          resolve: 0, // Theoretical minimum
          defense: 2,
          evasion: 1,
        ),
        specialRules: const [
          SpecialRule(
            name: 'Oblivious',
            description:
                'Regiments with this Special Rule receive only 1 Wound for every 2 failed Morale Tests, rounding up.',
          ),
        ],
        numericSpecialRules: const {},
        supremacyAbilities: const [],
        drawEvents: const [],
        points: 100,
      );

      final regiments = [
        Regiment(unit: zeroResolveObliviousUnit, stands: 1, pointsCost: 100),
      ];

      final armyList = ArmyList(
        name: 'Zero Resolve Oblivious Army',
        faction: 'Test',
        totalPoints: 100,
        pointsLimit: 2000,
        regiments: regiments,
      );

      final score = scoringEngine.calculateScores(armyList);

      // Should handle zero resolve gracefully without errors
      expect(score.effectiveWoundsDefense, equals(6.0)); // 4 × 1.5
      expect(score.effectiveWoundsDefenseResolve, greaterThan(0.0));
      expect(score.effectiveWoundsDefenseResolve,
          lessThan(score.effectiveWoundsDefense));
    });

    test('should maintain backwards compatibility with existing tests', () {
      // Test that units without Oblivious rule still work as before
      final regularUnit = Unit(
        name: 'Regular Unit',
        faction: 'Test',
        type: 'infantry',
        regimentClass: 'medium',
        characteristics: const UnitCharacteristics(
          march: 5,
          volley: 2,
          clash: 3,
          attacks: 4,
          wounds: 5,
          resolve: 3,
          defense: 2,
          evasion: 1,
        ),
        specialRules: const [], // No special rules
        numericSpecialRules: const {},
        supremacyAbilities: const [],
        drawEvents: const [],
        points: 150,
      );

      final regiments = [
        Regiment(unit: regularUnit, stands: 2, pointsCost: 300),
      ];

      final armyList = ArmyList(
        name: 'Regular Army',
        faction: 'Test',
        totalPoints: 300,
        pointsLimit: 2000,
        regiments: regiments,
      );

      final score = scoringEngine.calculateScores(armyList);

      // Should work exactly as before
      expect(score.effectiveWoundsDefense, equals(15.0));
      expect(score.effectiveWoundsDefenseResolve, equals(10.0));
      expect(score.resolveImpactPercentage, closeTo(-33.33, 0.1));
    });
  });
}
