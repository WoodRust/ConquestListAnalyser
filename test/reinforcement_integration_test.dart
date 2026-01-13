import 'package:flutter_test/flutter_test.dart';
import 'package:conquest_analyzer/models/army_list.dart';
import 'package:conquest_analyzer/models/list_score.dart';
import 'package:conquest_analyzer/models/regiment.dart';
import 'package:conquest_analyzer/models/unit.dart';
import 'package:conquest_analyzer/services/scoring_engine.dart';

void main() {
  group('Reinforcement Metrics Integration', () {
    late ScoringEngine scoringEngine;

    setUp(() {
      scoringEngine = ScoringEngine();
    });

    test('should include reinforcement metrics in ListScore', () {
      final character = Regiment(
        unit: Unit(
          name: 'Captain',
          faction: 'TestFaction',
          type: 'infantry',
          regimentClass: 'character',
          characteristics: UnitCharacteristics(
            march: 6,
            volley: 0,
            clash: 5,
            attacks: 1,
            wounds: 3,
            resolve: 2,
            defense: 3,
            evasion: 0,
          ),
          specialRules: [],
          numericSpecialRules: {},
          supremacyAbilities: [],
          drawEvents: [],
          points: 100,
        ),
        stands: 1,
        pointsCost: 100,
      );

      final lightRegiment = Regiment(
        unit: Unit(
          name: 'Light Infantry',
          faction: 'TestFaction',
          type: 'infantry',
          regimentClass: 'light',
          characteristics: UnitCharacteristics(
            march: 6,
            volley: 0,
            clash: 4,
            attacks: 1,
            wounds: 1,
            resolve: 2,
            defense: 2,
            evasion: 0,
          ),
          specialRules: [],
          numericSpecialRules: {},
          supremacyAbilities: [],
          drawEvents: [],
          points: 100,
        ),
        stands: 3,
        pointsCost: 160,
      );

      final mediumRegiment = Regiment(
        unit: Unit(
          name: 'Medium Infantry',
          faction: 'TestFaction',
          type: 'infantry',
          regimentClass: 'medium',
          characteristics: UnitCharacteristics(
            march: 6,
            volley: 0,
            clash: 5,
            attacks: 1,
            wounds: 1,
            resolve: 2,
            defense: 2,
            evasion: 0,
          ),
          specialRules: [],
          numericSpecialRules: {},
          supremacyAbilities: [],
          drawEvents: [],
          points: 110,
        ),
        stands: 3,
        pointsCost: 170,
      );

      final heavyRegiment = Regiment(
        unit: Unit(
          name: 'Heavy Infantry',
          faction: 'TestFaction',
          type: 'infantry',
          regimentClass: 'heavy',
          characteristics: UnitCharacteristics(
            march: 5,
            volley: 0,
            clash: 5,
            attacks: 1,
            wounds: 2,
            resolve: 2,
            defense: 3,
            evasion: 0,
          ),
          specialRules: [],
          numericSpecialRules: {},
          supremacyAbilities: [],
          drawEvents: [],
          points: 130,
        ),
        stands: 3,
        pointsCost: 180,
      );

      final armyList = ArmyList(
        name: 'Mixed Army',
        faction: 'TestFaction',
        totalPoints: 610,
        pointsLimit: 1000,
        regiments: [character, lightRegiment, mediumRegiment, heavyRegiment],
      );

      final listScore = scoringEngine.calculateScores(armyList);

      // Verify reinforcement metrics are present
      expect(listScore.reinforcementMetrics, isNotNull);

      // Verify structure
      final metrics = listScore.reinforcementMetrics!;
      expect(metrics.turn1Through5ArrivalPercent.length, 5);
      expect(metrics.turn1Through5P20.length, 5);
      expect(metrics.turn1Through5P80.length, 5);

      // Verify arrival percentages increase over time
      for (int turn = 1; turn < 5; turn++) {
        expect(
          metrics.getArrivalPercent(turn + 1),
          greaterThanOrEqualTo(metrics.getArrivalPercent(turn)),
          reason: 'Turn ${turn + 1} should have >= arrival than turn $turn',
        );
      }

      // Verify turn 5 has 100% arrival
      expect(metrics.getArrivalPercent(5), 100.0);
      expect(metrics.getP20(5), 100.0);
      expect(metrics.getP80(5), 100.0);

      // Verify percentile relationships (with small tolerance for floating point)
      for (int turn = 1; turn <= 5; turn++) {
        final p20 = metrics.getP20(turn);
        final avg = metrics.getArrivalPercent(turn);
        final p80 = metrics.getP80(turn);
        
        // P20 should be <= average (with tiny tolerance for FP errors)
        expect(
          p20,
          lessThanOrEqualTo(avg + 0.01),
          reason: 'P20 ($p20) should be <= average ($avg) for turn $turn',
        );
        
        // P80 should be >= average (with tiny tolerance for FP errors)
        expect(
          p80,
          greaterThanOrEqualTo(avg - 0.01),
          reason: 'P80 ($p80) should be >= average ($avg) for turn $turn',
        );
      }
    });

    test('should serialize and deserialize reinforcement metrics', () {
      final character = Regiment(
        unit: Unit(
          name: 'Captain',
          faction: 'TestFaction',
          type: 'infantry',
          regimentClass: 'character',
          characteristics: UnitCharacteristics(
            march: 6,
            volley: 0,
            clash: 5,
            attacks: 1,
            wounds: 3,
            resolve: 2,
            defense: 3,
            evasion: 0,
          ),
          specialRules: [],
          numericSpecialRules: {},
          supremacyAbilities: [],
          drawEvents: [],
          points: 100,
        ),
        stands: 1,
        pointsCost: 100,
      );

      final regiment = Regiment(
        unit: Unit(
          name: 'Infantry',
          faction: 'TestFaction',
          type: 'infantry',
          regimentClass: 'light',
          characteristics: UnitCharacteristics(
            march: 6,
            volley: 0,
            clash: 4,
            attacks: 1,
            wounds: 1,
            resolve: 2,
            defense: 2,
            evasion: 0,
          ),
          specialRules: [],
          numericSpecialRules: {},
          supremacyAbilities: [],
          drawEvents: [],
          points: 100,
        ),
        stands: 3,
        pointsCost: 160,
      );

      final armyList = ArmyList(
        name: 'Test Army',
        faction: 'TestFaction',
        totalPoints: 260,
        pointsLimit: 1000,
        regiments: [character, regiment],
      );

      final originalScore = scoringEngine.calculateScores(armyList);

      // Serialize to JSON
      final json = originalScore.toJson();

      // Deserialize from JSON
      final deserializedScore = ListScore.fromJson(json);

      // Verify reinforcement metrics survived serialization
      expect(deserializedScore.reinforcementMetrics, isNotNull);
      expect(
        deserializedScore.reinforcementMetrics!.turn1Through5ArrivalPercent,
        originalScore.reinforcementMetrics!.turn1Through5ArrivalPercent,
      );
      expect(
        deserializedScore.reinforcementMetrics!.turn1Through5P20,
        originalScore.reinforcementMetrics!.turn1Through5P20,
      );
      expect(
        deserializedScore.reinforcementMetrics!.turn1Through5P80,
        originalScore.reinforcementMetrics!.turn1Through5P80,
      );
    });

    test('should include reinforcement metrics in shareable text', () {
      final character = Regiment(
        unit: Unit(
          name: 'Captain',
          faction: 'TestFaction',
          type: 'infantry',
          regimentClass: 'character',
          characteristics: UnitCharacteristics(
            march: 6,
            volley: 0,
            clash: 5,
            attacks: 1,
            wounds: 3,
            resolve: 2,
            defense: 3,
            evasion: 0,
          ),
          specialRules: [],
          numericSpecialRules: {},
          supremacyAbilities: [],
          drawEvents: [],
          points: 100,
        ),
        stands: 1,
        pointsCost: 100,
      );

      final regiment = Regiment(
        unit: Unit(
          name: 'Infantry',
          faction: 'TestFaction',
          type: 'infantry',
          regimentClass: 'light',
          characteristics: UnitCharacteristics(
            march: 6,
            volley: 0,
            clash: 4,
            attacks: 1,
            wounds: 1,
            resolve: 2,
            defense: 2,
            evasion: 0,
          ),
          specialRules: [],
          numericSpecialRules: {},
          supremacyAbilities: [],
          drawEvents: [],
          points: 100,
        ),
        stands: 3,
        pointsCost: 160,
      );

      final armyList = ArmyList(
        name: 'Test Army',
        faction: 'TestFaction',
        totalPoints: 260,
        pointsLimit: 1000,
        regiments: [character, regiment],
      );

      final listScore = scoringEngine.calculateScores(armyList);
      final shareableText = listScore.toShareableText();

      // Verify reinforcement section is included
      expect(shareableText, contains('REINFORCEMENT TIMING:'));
      expect(shareableText, contains('Turn 1:'));
      expect(shareableText, contains('Turn 2:'));
      expect(shareableText, contains('Turn 3:'));
      expect(shareableText, contains('Turn 4:'));
      expect(shareableText, contains('Turn 5:'));
      
      // Verify format includes percentages and ranges
      expect(shareableText, contains('%'));
      expect(shareableText, contains('('));
      expect(shareableText, contains('%)'));
    });

    test('should handle Forward Force in full integration', () {
      final character = Regiment(
        unit: Unit(
          name: 'Captain',
          faction: 'TestFaction',
          type: 'infantry',
          regimentClass: 'character',
          characteristics: UnitCharacteristics(
            march: 6,
            volley: 0,
            clash: 5,
            attacks: 1,
            wounds: 3,
            resolve: 2,
            defense: 3,
            evasion: 0,
          ),
          specialRules: [
            SpecialRule(name: 'Forward Force', description: 'Test'),
          ],
          numericSpecialRules: {},
          supremacyAbilities: [],
          drawEvents: [],
          points: 100,
        ),
        stands: 1,
        pointsCost: 100,
      );

      final heavyRegiment = Regiment(
        unit: Unit(
          name: 'Heavy Infantry',
          faction: 'TestFaction',
          type: 'infantry',
          regimentClass: 'heavy',
          characteristics: UnitCharacteristics(
            march: 5,
            volley: 0,
            clash: 5,
            attacks: 1,
            wounds: 2,
            resolve: 2,
            defense: 3,
            evasion: 0,
          ),
          specialRules: [],
          numericSpecialRules: {},
          supremacyAbilities: [],
          drawEvents: [],
          points: 130,
        ),
        stands: 3,
        pointsCost: 180,
      );

      final armyList = ArmyList(
        name: 'Forward Force Army',
        faction: 'TestFaction',
        totalPoints: 280,
        pointsLimit: 1000,
        regiments: [character, heavyRegiment],
      );

      final listScore = scoringEngine.calculateScores(armyList);

      // Heavy with Forward Force should arrive turn 3 (earliest for heavies with Flank)
      expect(listScore.reinforcementMetrics, isNotNull);
      final metrics = listScore.reinforcementMetrics!;
      
      // Should be 100% by turn 3 (auto-arrival with Flank)
      expect(metrics.getArrivalPercent(3), 100.0);
    });
  });
}
