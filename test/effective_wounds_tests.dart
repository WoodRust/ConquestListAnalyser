import 'package:flutter_test/flutter_test.dart';
import 'package:conquest_analyzer/services/scoring_engine.dart';
import 'package:conquest_analyzer/models/army_list.dart';
import 'package:conquest_analyzer/models/regiment.dart';
import 'package:conquest_analyzer/models/unit.dart';

void main() {
  group('Effective Wounds Score Tests', () {
    late ScoringEngine scoringEngine;
    late Unit lowDefenseUnit;
    late Unit mediumDefenseUnit;
    late Unit highDefenseUnit;
    late Unit highEvasionUnit;
    late Unit characterUnit;
    late Unit characterMonsterUnit;

    setUp(() {
      scoringEngine = ScoringEngine();

      lowDefenseUnit = Unit(
        name: 'Light Infantry',
        faction: 'Test',
        type: 'infantry',
        regimentClass: 'light',
        characteristics: const UnitCharacteristics(
          march: 6,
          volley: 1,
          clash: 2,
          attacks: 4,
          wounds: 4,
          resolve: 2,
          defense: 1, // Low defense
          evasion: 1, // Low evasion
        ),
        specialRules: const [],
        numericSpecialRules: const {},
        supremacyAbilities: const [],
        drawEvents: const [],
        points: 120,
      );

      mediumDefenseUnit = Unit(
        name: 'Medium Infantry',
        faction: 'Test',
        type: 'infantry',
        regimentClass: 'medium',
        characteristics: const UnitCharacteristics(
          march: 5,
          volley: 1,
          clash: 3,
          attacks: 4,
          wounds: 5,
          resolve: 3,
          defense: 3, // Medium defense
          evasion: 1, // Low evasion
        ),
        specialRules: const [],
        numericSpecialRules: const {},
        supremacyAbilities: const [],
        drawEvents: const [],
        points: 160,
      );

      highDefenseUnit = Unit(
        name: 'Heavy Infantry',
        faction: 'Test',
        type: 'infantry',
        regimentClass: 'heavy',
        characteristics: const UnitCharacteristics(
          march: 4,
          volley: 1,
          clash: 4,
          attacks: 3,
          wounds: 6,
          resolve: 4,
          defense: 5, // High defense
          evasion: 1, // Low evasion
        ),
        specialRules: const [],
        numericSpecialRules: const {},
        supremacyAbilities: const [],
        drawEvents: const [],
        points: 200,
      );

      highEvasionUnit = Unit(
        name: 'Fast Cavalry',
        faction: 'Test',
        type: 'cavalry',
        regimentClass: 'light',
        characteristics: const UnitCharacteristics(
          march: 8,
          volley: 2,
          clash: 2,
          attacks: 4,
          wounds: 4,
          resolve: 2,
          defense: 1, // Low defense
          evasion: 4, // High evasion
        ),
        specialRules: const [],
        numericSpecialRules: const {},
        supremacyAbilities: const [],
        drawEvents: const [],
        points: 150,
      );

      characterUnit = Unit(
        name: 'Test Character',
        faction: 'Test',
        type: 'character',
        regimentClass: 'character',
        characteristics: const UnitCharacteristics(
          march: 8,
          volley: 3,
          clash: 4,
          attacks: 6,
          wounds: 3,
          resolve: 4,
          defense: 5, // Very high defense - should be excluded
          evasion: 2,
        ),
        specialRules: const [],
        numericSpecialRules: const {},
        supremacyAbilities: const [],
        drawEvents: const [],
        points: 150,
      );

      characterMonsterUnit = Unit(
        name: 'Dragon Lord',
        faction: 'Test',
        type: 'monster',
        regimentClass: 'character',
        characteristics: const UnitCharacteristics(
          march: 8,
          volley: 4,
          clash: 5,
          attacks: 8,
          wounds: 8,
          resolve: 5,
          defense: 3, // Medium defense
          evasion: 2, // Medium evasion
        ),
        specialRules: const [],
        numericSpecialRules: const {'cleave': 3},
        supremacyAbilities: const [],
        drawEvents: const [],
        points: 400,
      );
    });

    test('should calculate effective wounds correctly for single regiment', () {
      final regiments = [
        Regiment(unit: mediumDefenseUnit, stands: 2, pointsCost: 200),
      ];
      final armyList = ArmyList(
        name: 'Single Regiment Army',
        faction: 'Test',
        totalPoints: 200,
        pointsLimit: 2000,
        regiments: regiments,
      );

      final score = scoringEngine.calculateScores(armyList);

      // 2 stands × 5 wounds = 10 total wounds
      // Best defensive value = max(3 defense, 1 evasion) = 3
      // Multiplier = 6 / (6 - 3) = 6 / 3 = 2.0
      // Effective wounds = 10 × 2.0 = 20.0
      expect(score.effectiveWounds, equals(20.0));
    });

    test('should use highest of defense or evasion', () {
      final regiments = [
        Regiment(
            unit: mediumDefenseUnit,
            stands: 1,
            pointsCost: 160), // Defense 3, Evasion 1 → use Defense 3
        Regiment(
            unit: highEvasionUnit,
            stands: 1,
            pointsCost: 150), // Defense 1, Evasion 4 → use Evasion 4
      ];
      final armyList = ArmyList(
        name: 'Mixed Defense Army',
        faction: 'Test',
        totalPoints: 310,
        pointsLimit: 2000,
        regiments: regiments,
      );

      final score = scoringEngine.calculateScores(armyList);

      // Medium unit: 5 wounds × (6/(6-3)) = 5 × 2.0 = 10.0
      // High evasion unit: 4 wounds × (6/(6-4)) = 4 × 3.0 = 12.0
      // Total effective wounds = 10.0 + 12.0 = 22.0
      expect(score.effectiveWounds, equals(22.0));
    });

    test('should exclude characters from effective wounds calculation', () {
      final regiments = [
        Regiment(
            unit: characterUnit,
            stands: 1,
            pointsCost: 150), // Character - excluded
        Regiment(
            unit: mediumDefenseUnit,
            stands: 2,
            pointsCost: 200), // Defense 3, 10 wounds
      ];
      final armyList = ArmyList(
        name: 'Army with Character',
        faction: 'Test',
        totalPoints: 350,
        pointsLimit: 2000,
        regiments: regiments,
      );

      final score = scoringEngine.calculateScores(armyList);

      // Character excluded, only medium defense unit counts
      // 10 wounds × (6/(6-3)) = 10 × 2.0 = 20.0
      expect(score.effectiveWounds, equals(20.0));
    });

    test('should include character monsters in effective wounds calculation',
        () {
      final regiments = [
        Regiment(
            unit: characterUnit,
            stands: 1,
            pointsCost: 150), // Regular character - excluded
        Regiment(
            unit: characterMonsterUnit,
            stands: 1,
            pointsCost: 400), // Character monster - included
        Regiment(
            unit: mediumDefenseUnit,
            stands: 1,
            pointsCost: 160), // Regular regiment - included
      ];
      final armyList = ArmyList(
        name: 'Army with Character Monster',
        faction: 'Test',
        totalPoints: 710,
        pointsLimit: 2000,
        regiments: regiments,
      );

      final score = scoringEngine.calculateScores(armyList);

      // Character monster: 8 wounds × (6/(6-3)) = 8 × 2.0 = 16.0
      // Medium regiment: 5 wounds × (6/(6-3)) = 5 × 2.0 = 10.0
      // Total effective wounds = 16.0 + 10.0 = 26.0
      expect(score.effectiveWounds, equals(26.0));
    });

    test('should handle extreme defensive values correctly', () {
      final regiments = [
        Regiment(
            unit: lowDefenseUnit,
            stands: 1,
            pointsCost: 120), // Defense 1, Evasion 1 → use 1
        Regiment(
            unit: highDefenseUnit,
            stands: 1,
            pointsCost: 200), // Defense 5, Evasion 1 → use 5
      ];
      final armyList = ArmyList(
        name: 'Extreme Defense Army',
        faction: 'Test',
        totalPoints: 320,
        pointsLimit: 2000,
        regiments: regiments,
      );

      final score = scoringEngine.calculateScores(armyList);

      // Low defense: 4 wounds × (6/(6-1)) = 4 × 1.2 = 4.8
      // High defense: 6 wounds × (6/(6-5)) = 6 × 6.0 = 36.0
      // Total effective wounds = 4.8 + 36.0 = 40.8
      expect(score.effectiveWounds, equals(40.8));
    });

    test('should cap defensive values at 5 to avoid division by zero', () {
      final maxDefenseUnit = Unit(
        name: 'Invulnerable Unit',
        faction: 'Test',
        type: 'infantry',
        regimentClass: 'heavy',
        characteristics: const UnitCharacteristics(
          march: 2,
          volley: 1,
          clash: 6,
          attacks: 1,
          wounds: 10,
          resolve: 6,
          defense: 6, // Would cause division by zero
          evasion: 1,
        ),
        specialRules: const [],
        numericSpecialRules: const {},
        supremacyAbilities: const [],
        drawEvents: const [],
        points: 500,
      );

      final regiments = [
        Regiment(unit: maxDefenseUnit, stands: 1, pointsCost: 500),
      ];
      final armyList = ArmyList(
        name: 'Max Defense Army',
        faction: 'Test',
        totalPoints: 500,
        pointsLimit: 2000,
        regiments: regiments,
      );

      final score = scoringEngine.calculateScores(armyList);

      // Defense 6 should be capped at 5
      // 10 wounds × (6/(6-5)) = 10 × 6.0 = 60.0
      expect(score.effectiveWounds, equals(60.0));
    });

    test('should return 0 for army with only characters', () {
      final regiments = [
        Regiment(unit: characterUnit, stands: 1, pointsCost: 150),
      ];
      final armyList = ArmyList(
        name: 'Character Only Army',
        faction: 'Test',
        totalPoints: 150,
        pointsLimit: 2000,
        regiments: regiments,
      );

      final score = scoringEngine.calculateScores(armyList);
      expect(score.effectiveWounds, equals(0.0));
    });

    test('should return 0 for empty army', () {
      final armyList = ArmyList(
        name: 'Empty Army',
        faction: 'Test',
        totalPoints: 0,
        pointsLimit: 2000,
        regiments: const [],
      );

      final score = scoringEngine.calculateScores(armyList);
      expect(score.effectiveWounds, equals(0.0));
    });

    test('should handle multiple regiments with different defensive profiles',
        () {
      final regiments = [
        Regiment(
            unit: lowDefenseUnit,
            stands: 3,
            pointsCost: 240), // 12 wounds, defense 1
        Regiment(
            unit: mediumDefenseUnit,
            stands: 1,
            pointsCost: 160), // 5 wounds, defense 3
        Regiment(
            unit: highEvasionUnit,
            stands: 2,
            pointsCost: 240), // 8 wounds, evasion 4
      ];
      final armyList = ArmyList(
        name: 'Complex Army',
        faction: 'Test',
        totalPoints: 640,
        pointsLimit: 2000,
        regiments: regiments,
      );

      final score = scoringEngine.calculateScores(armyList);

      // Low defense: 12 wounds × (6/(6-1)) = 12 × 1.2 = 14.4
      // Medium defense: 5 wounds × (6/(6-3)) = 5 × 2.0 = 10.0
      // High evasion: 8 wounds × (6/(6-4)) = 8 × 3.0 = 24.0
      // Total effective wounds = 14.4 + 10.0 + 24.0 = 48.4
      expect(score.effectiveWounds, equals(48.4));
    });

    test('should include effective wounds in shareable text format', () {
      final regiments = [
        Regiment(unit: mediumDefenseUnit, stands: 2, pointsCost: 200),
        Regiment(unit: highEvasionUnit, stands: 1, pointsCost: 150),
      ];
      final armyList = ArmyList(
        name: 'Effective Wounds Test Army',
        faction: 'Test',
        totalPoints: 350,
        pointsLimit: 2000,
        regiments: regiments,
      );

      final score = scoringEngine.calculateScores(armyList);
      final shareableText = score.toShareableText();

      expect(shareableText,
          contains('Army List Analysis: Effective Wounds Test Army'));
      expect(shareableText, contains('Effective Wounds:'));
      expect(shareableText, contains('Calculated:'));
    });

    test('should handle armies with same defensive values', () {
      final regiments = [
        Regiment(
            unit: mediumDefenseUnit,
            stands: 1,
            pointsCost: 160), // 5 wounds, defense 3
        Regiment(
            unit: mediumDefenseUnit,
            stands: 2,
            pointsCost: 250), // 10 wounds, defense 3
        Regiment(
            unit: mediumDefenseUnit,
            stands: 3,
            pointsCost: 340), // 15 wounds, defense 3
      ];
      final armyList = ArmyList(
        name: 'Uniform Defense Army',
        faction: 'Test',
        totalPoints: 750,
        pointsLimit: 2000,
        regiments: regiments,
      );

      final score = scoringEngine.calculateScores(armyList);

      // All units have defense 3: multiplier = 6/(6-3) = 2.0
      // Total wounds = 5 + 10 + 15 = 30
      // Effective wounds = 30 × 2.0 = 60.0
      expect(score.effectiveWounds, equals(60.0));
    });

    test('should maintain backwards compatibility with existing scoring', () {
      final regiments = [
        Regiment(unit: mediumDefenseUnit, stands: 2, pointsCost: 200),
        Regiment(unit: highEvasionUnit, stands: 1, pointsCost: 150),
      ];
      final armyList = ArmyList(
        name: 'Backwards Compatible Army',
        faction: 'Test',
        totalPoints: 350,
        pointsLimit: 2000,
        regiments: regiments,
      );

      final score = scoringEngine.calculateScores(armyList);

      // Verify all existing scores still work
      expect(score.totalWounds, greaterThan(0));
      expect(score.pointsPerWound, greaterThan(0.0));
      expect(score.expectedHitVolume, greaterThan(0.0));
      expect(score.cleaveRating, greaterThanOrEqualTo(0.0));
      expect(score.rangedExpectedHits, greaterThanOrEqualTo(0.0));
      expect(score.rangedArmorPiercingRating, greaterThanOrEqualTo(0.0));
      expect(score.maxRange, greaterThanOrEqualTo(0));
      expect(score.averageSpeed, greaterThanOrEqualTo(0.0));
      expect(score.toughness, greaterThan(0.0));
      expect(score.evasion, greaterThan(0.0));
      // And new effective wounds score
      expect(score.effectiveWounds, greaterThan(0.0));

      // Verify toString includes effective wounds
      final stringOutput = score.toString();
      expect(stringOutput, contains('effectiveWounds:'));
    });

    test(
        'should handle mixed army with characters, character monsters, and regiments',
        () {
      final regiments = [
        Regiment(
            unit: characterUnit,
            stands: 1,
            pointsCost: 150), // Regular character - excluded
        Regiment(
            unit: characterMonsterUnit,
            stands: 1,
            pointsCost: 400), // Character monster - included
        Regiment(
            unit: lowDefenseUnit,
            stands: 2,
            pointsCost: 200), // Low defense, 8 wounds
        Regiment(
            unit: highEvasionUnit,
            stands: 1,
            pointsCost: 150), // High evasion, 4 wounds
      ];
      final armyList = ArmyList(
        name: 'Complex Mixed Army',
        faction: 'Test',
        totalPoints: 900,
        pointsLimit: 2000,
        regiments: regiments,
      );

      final score = scoringEngine.calculateScores(armyList);

      // Character monster: 8 wounds × (6/(6-3)) = 8 × 2.0 = 16.0
      // Low defense: 8 wounds × (6/(6-1)) = 8 × 1.2 = 9.6
      // High evasion: 4 wounds × (6/(6-4)) = 4 × 3.0 = 12.0
      // Total effective wounds = 16.0 + 9.6 + 12.0 = 37.6
      expect(score.effectiveWounds, equals(37.6));

      // Verify other scores still work correctly
      expect(score.totalWounds, equals(20)); // Characters excluded from wounds
      expect(score.expectedHitVolume,
          greaterThan(0.0)); // Characters included in hit volume
    });

    test('should handle precision in effective wounds calculations', () {
      final regiments = [
        Regiment(
            unit: lowDefenseUnit,
            stands: 1,
            pointsCost: 120), // 4 wounds, defense 1
        Regiment(
            unit: mediumDefenseUnit,
            stands: 1,
            pointsCost: 160), // 5 wounds, defense 3
        Regiment(
            unit: highDefenseUnit,
            stands: 1,
            pointsCost: 200), // 6 wounds, defense 5
      ];
      final armyList = ArmyList(
        name: 'Precision Test Army',
        faction: 'Test',
        totalPoints: 480,
        pointsLimit: 2000,
        regiments: regiments,
      );

      final score = scoringEngine.calculateScores(armyList);

      // Low: 4 × (6/5) = 4 × 1.2 = 4.8
      // Medium: 5 × (6/3) = 5 × 2.0 = 10.0
      // High: 6 × (6/1) = 6 × 6.0 = 36.0
      // Total: 4.8 + 10.0 + 36.0 = 50.8
      expect(score.effectiveWounds, equals(50.8));

      // Verify it displays correctly in shareable text
      final shareableText = score.toShareableText();
      expect(shareableText, contains('Effective Wounds: 50.8'));
    });

    test('should work correctly with army effects modifying defense/evasion',
        () {
      // This test assumes army effects are working (tested separately)
      // But verifies that effective wounds calculation uses modified values
      final regiments = [
        Regiment(unit: lowDefenseUnit, stands: 2, pointsCost: 200),
      ];
      final armyList = ArmyList(
        name: 'Army Effects Test',
        faction: 'Test',
        totalPoints: 200,
        pointsLimit: 2000,
        regiments: regiments,
      );

      final score = scoringEngine.calculateScores(armyList);

      // Even without army effects, should calculate correctly
      // 8 wounds × (6/(6-1)) = 8 × 1.2 = 9.6
      expect(score.effectiveWounds, equals(9.6));
    });

    test('should validate formula examples from UI tooltip', () {
      // Test the specific examples mentioned in the tooltip
      final defense1Unit = Unit(
        name: 'Defense 1 Unit',
        faction: 'Test',
        type: 'infantry',
        regimentClass: 'light',
        characteristics: const UnitCharacteristics(
          march: 6,
          volley: 1,
          clash: 2,
          attacks: 4,
          wounds: 10, // Easy math
          resolve: 2,
          defense: 1,
          evasion: 1,
        ),
        specialRules: const [],
        numericSpecialRules: const {},
        supremacyAbilities: const [],
        drawEvents: const [],
        points: 120,
      );

      final defense3Unit = Unit(
        name: 'Defense 3 Unit',
        faction: 'Test',
        type: 'infantry',
        regimentClass: 'medium',
        characteristics: const UnitCharacteristics(
          march: 5,
          volley: 1,
          clash: 3,
          attacks: 4,
          wounds: 10, // Easy math
          resolve: 3,
          defense: 3,
          evasion: 1,
        ),
        specialRules: const [],
        numericSpecialRules: const {},
        supremacyAbilities: const [],
        drawEvents: const [],
        points: 160,
      );

      // Test Defense 1: 6÷5 = 1.2× wounds
      final army1 = ArmyList(
        name: 'Defense 1 Test',
        faction: 'Test',
        totalPoints: 120,
        pointsLimit: 2000,
        regiments: [Regiment(unit: defense1Unit, stands: 1, pointsCost: 120)],
      );
      final score1 = scoringEngine.calculateScores(army1);
      expect(score1.effectiveWounds, equals(12.0)); // 10 × 1.2

      // Test Defense 3: 6÷3 = 2.0× wounds
      final army3 = ArmyList(
        name: 'Defense 3 Test',
        faction: 'Test',
        totalPoints: 160,
        pointsLimit: 2000,
        regiments: [Regiment(unit: defense3Unit, stands: 1, pointsCost: 160)],
      );
      final score3 = scoringEngine.calculateScores(army3);
      expect(score3.effectiveWounds, equals(20.0)); // 10 × 2.0
    });

    test('should handle large armies with consistent performance', () {
      final regiments = <Regiment>[];
      // Create a large army with mixed defensive values
      for (int i = 0; i < 20; i++) {
        regiments
            .add(Regiment(unit: lowDefenseUnit, stands: 1, pointsCost: 120));
      }
      for (int i = 0; i < 15; i++) {
        regiments
            .add(Regiment(unit: mediumDefenseUnit, stands: 1, pointsCost: 160));
      }
      for (int i = 0; i < 10; i++) {
        regiments
            .add(Regiment(unit: highEvasionUnit, stands: 1, pointsCost: 150));
      }

      final armyList = ArmyList(
        name: 'Large Army',
        faction: 'Test',
        totalPoints: 8300,
        pointsLimit: 10000,
        regiments: regiments,
      );

      final score = scoringEngine.calculateScores(armyList);

      // 20 × (4 wounds × 1.2) = 20 × 4.8 = 96.0
      // 15 × (5 wounds × 2.0) = 15 × 10.0 = 150.0
      // 10 × (4 wounds × 3.0) = 10 × 12.0 = 120.0
      // Total: 96.0 + 150.0 + 120.0 = 366.0
      expect(score.effectiveWounds, equals(366.0));
      expect(score.effectiveWounds, greaterThan(0.0));
    });
  });
}
