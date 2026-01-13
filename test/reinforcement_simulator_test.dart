import 'package:flutter_test/flutter_test.dart';
import 'package:conquest_analyzer/models/army_list.dart';
import 'package:conquest_analyzer/models/regiment.dart';
import 'package:conquest_analyzer/models/unit.dart';
import 'package:conquest_analyzer/services/reinforcement_simulator.dart';

void main() {
  group('ReinforcementSimulator', () {
    test('should produce deterministic results with same seed', () {
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
        totalPoints: 160,
        pointsLimit: 1000,
        regiments: [regiment],
      );

      final simulator1 = ReinforcementSimulator(seed: 42);
      final result1 = simulator1.simulate(armyList, simulations: 1000);

      final simulator2 = ReinforcementSimulator(seed: 42);
      final result2 = simulator2.simulate(armyList, simulations: 1000);

      // Results should be identical with same seed
      expect(result1.turn1Through5ArrivalPercent, result2.turn1Through5ArrivalPercent);
      expect(result1.turn1Through5P20, result2.turn1Through5P20);
      expect(result1.turn1Through5P80, result2.turn1Through5P80);
    });

    test('should have all lights arrive by turn 3', () {
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

      final armyList = ArmyList(
        name: 'Test Army',
        faction: 'TestFaction',
        totalPoints: 260,
        pointsLimit: 1000,
        regiments: [character, lightRegiment],
      );

      final simulator = ReinforcementSimulator(seed: 42);
      final result = simulator.simulate(armyList, simulations: 1000);

      // By turn 3, all lights arrive automatically (100%)
      expect(result.getArrivalPercent(3), 100.0);
      expect(result.getP20(3), 100.0);
      expect(result.getP80(3), 100.0);
    });

    test('should have all heavies arrive by turn 5', () {
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
        pointsCost: 170,
      );

      final armyList = ArmyList(
        name: 'Test Army',
        faction: 'TestFaction',
        totalPoints: 270,
        pointsLimit: 1000,
        regiments: [character, heavyRegiment],
      );

      final simulator = ReinforcementSimulator(seed: 42);
      final result = simulator.simulate(armyList, simulations: 1000);

      // By turn 5, all heavies arrive automatically (100%)
      expect(result.getArrivalPercent(5), 100.0);
      expect(result.getP20(5), 100.0);
      expect(result.getP80(5), 100.0);
    });

    test('should auto-arrive Flank units at earliest eligible turn', () {
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

      final heavyWithFlank = Regiment(
        unit: Unit(
          name: 'Heavy with Flank',
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
          specialRules: [
            SpecialRule(name: 'Flank', description: 'Test'),
          ],
          numericSpecialRules: {},
          supremacyAbilities: [],
          drawEvents: [],
          points: 130,
        ),
        stands: 3,
        pointsCost: 200,
      );

      final armyList = ArmyList(
        name: 'Test Army',
        faction: 'TestFaction',
        totalPoints: 300,
        pointsLimit: 1000,
        regiments: [character, heavyWithFlank],
      );

      final simulator = ReinforcementSimulator(seed: 42);
      final result = simulator.simulate(armyList, simulations: 1000);

      // Heavy with Flank should arrive on Turn 3 (earliest for heavies)
      // Should be 100% by turn 3 with no variance
      expect(result.getArrivalPercent(3), 100.0);
      expect(result.getP20(3), 100.0);
      expect(result.getP80(3), 100.0);
    });

    test('should apply Forward Force to grant Flank', () {
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
        pointsCost: 200,
      );

      final armyList = ArmyList(
        name: 'Test Army',
        faction: 'TestFaction',
        totalPoints: 300,
        pointsLimit: 1000,
        regiments: [character, heavyRegiment],
      );

      final simulator = ReinforcementSimulator(seed: 42);
      final result = simulator.simulate(armyList, simulations: 1000);

      // Heavy should get Flank from Forward Force and arrive Turn 3
      expect(result.getArrivalPercent(3), 100.0);
      expect(result.getP20(3), 100.0);
      expect(result.getP80(3), 100.0);
    });

    test('should handle character monsters using actualRegimentClass', () {
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

      final characterMonster = Regiment(
        unit: Unit(
          name: 'Dragon',
          faction: 'TestFaction',
          type: 'monster',
          regimentClass: 'character',
          actualRegimentClass: 'light', // Light weight class
          characteristics: UnitCharacteristics(
            march: 10,
            volley: 0,
            clash: 6,
            attacks: 1,
            wounds: 8,
            resolve: 2,
            defense: 4,
            evasion: 0,
          ),
          specialRules: [],
          numericSpecialRules: {},
          supremacyAbilities: [],
          drawEvents: [],
          points: 300,
        ),
        stands: 1,
        pointsCost: 300,
      );

      final armyList = ArmyList(
        name: 'Test Army',
        faction: 'TestFaction',
        totalPoints: 400,
        pointsLimit: 1000,
        regiments: [character, characterMonster],
      );

      final simulator = ReinforcementSimulator(seed: 42);
      final result = simulator.simulate(armyList, simulations: 1000);

      // Character monster with light weight should arrive by turn 3 (lights auto)
      expect(result.getArrivalPercent(3), 100.0);
    });

    test('should select highest points unit for player agency', () {
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

      // Create multiple light regiments with different points
      final expensiveLight = Regiment(
        unit: Unit(
          name: 'Expensive Light',
          faction: 'TestFaction',
          type: 'infantry',
          regimentClass: 'light',
          characteristics: UnitCharacteristics(
            march: 6,
            volley: 0,
            clash: 5,
            attacks: 1,
            wounds: 1,
            resolve: 2,
            defense: 3,
            evasion: 0,
          ),
          specialRules: [],
          numericSpecialRules: {},
          supremacyAbilities: [],
          drawEvents: [],
          points: 120,
        ),
        stands: 3,
        pointsCost: 200,
      );

      final cheapLight = Regiment(
        unit: Unit(
          name: 'Cheap Light',
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
        pointsCost: 100,
      );

      final armyList = ArmyList(
        name: 'Test Army',
        faction: 'TestFaction',
        totalPoints: 400,
        pointsLimit: 1000,
        regiments: [character, expensiveLight, cheapLight],
      );

      final simulator = ReinforcementSimulator(seed: 42);
      final result = simulator.simulate(armyList, simulations: 100);

      // Turn 1: Player should select expensive light (200pts) first
      // With Flank auto-arrivals, player selection, and dice rolls,
      // we should see high arrival by turn 1
      final turn1Arrival = result.getArrivalPercent(1);
      expect(turn1Arrival, greaterThan(50.0));
    });

    test('should return empty metrics for army with only characters', () {
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

      final armyList = ArmyList(
        name: 'Test Army',
        faction: 'TestFaction',
        totalPoints: 100,
        pointsLimit: 1000,
        regiments: [character],
      );

      final simulator = ReinforcementSimulator(seed: 42);
      final result = simulator.simulate(armyList, simulations: 100);

      // No regiments to deploy - should return 0s
      for (int turn = 1; turn <= 5; turn++) {
        expect(result.getArrivalPercent(turn), 0.0);
        expect(result.getP20(turn), 0.0);
        expect(result.getP80(turn), 0.0);
      }
    });
  });
}
