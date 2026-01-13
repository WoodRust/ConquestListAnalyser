import 'package:flutter_test/flutter_test.dart';
import 'package:conquest_analyzer/models/army_list.dart';
import 'package:conquest_analyzer/models/regiment.dart';
import 'package:conquest_analyzer/models/unit.dart';
import 'package:conquest_analyzer/models/warband.dart';
import 'package:conquest_analyzer/services/warband_manager.dart';

void main() {
  group('WarbandManager', () {
    group('inferWarbands', () {
      test('should group regiments under regular characters', () {
        // Create a regular character (infantry character)
        final character1 = Regiment(
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

        // Create regular regiments
        final regiment1 = Regiment(
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

        final regiment2 = Regiment(
          unit: Unit(
            name: 'Cavalry',
            faction: 'TestFaction',
            type: 'cavalry',
            regimentClass: 'medium',
            characteristics: UnitCharacteristics(
              march: 8,
              volley: 0,
              clash: 5,
              attacks: 1,
              wounds: 2,
              resolve: 2,
              defense: 2,
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
          totalPoints: 430,
          pointsLimit: 1000,
          regiments: [character1, regiment1, regiment2],
        );

        final warbands = WarbandManager.inferWarbands(armyList);

        expect(warbands.length, 1);
        expect(warbands[0].character, character1);
        expect(warbands[0].regiments.length, 2);
        expect(warbands[0].regiments, containsAll([regiment1, regiment2]));
      });

      test('should create multiple warbands for multiple characters', () {
        final character1 = Regiment(
          unit: Unit(
            name: 'Captain 1',
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

        final regiment1 = Regiment(
          unit: Unit(
            name: 'Infantry 1',
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

        final character2 = Regiment(
          unit: Unit(
            name: 'Captain 2',
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

        final regiment2 = Regiment(
          unit: Unit(
            name: 'Cavalry 1',
            faction: 'TestFaction',
            type: 'cavalry',
            regimentClass: 'medium',
            characteristics: UnitCharacteristics(
              march: 8,
              volley: 0,
              clash: 5,
              attacks: 1,
              wounds: 2,
              resolve: 2,
              defense: 2,
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
          totalPoints: 530,
          pointsLimit: 1000,
          regiments: [character1, regiment1, character2, regiment2],
        );

        final warbands = WarbandManager.inferWarbands(armyList);

        expect(warbands.length, 2);
        expect(warbands[0].character, character1);
        expect(warbands[0].regiments, [regiment1]);
        expect(warbands[1].character, character2);
        expect(warbands[1].regiments, [regiment2]);
      });

      test('should exclude character monsters from warband leadership', () {
        // Character monster (should not lead warband)
        final characterMonster = Regiment(
          unit: Unit(
            name: 'Dragon',
            faction: 'TestFaction',
            type: 'monster',
            regimentClass: 'character',
            actualRegimentClass: 'heavy',
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
          totalPoints: 560,
          pointsLimit: 1000,
          regiments: [characterMonster, character, regiment],
        );

        final warbands = WarbandManager.inferWarbands(armyList);

        // Character monster should not create a warband
        // Only the regular character should lead a warband
        expect(warbands.length, 1);
        expect(warbands[0].character, character);
        // Character monster should be grouped as a regiment under the character
        expect(warbands[0].regiments, containsAll([characterMonster, regiment]));
      });
    });

    group('applyForwardForce', () {
      test('should grant Flank to heaviest eligible regiment', () {
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
          pointsCost: 200, // Higher points
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
          pointsCost: 150, // Lower points but Heavy class
        );

        final warband = Warband(
          character: character,
          regiments: [lightRegiment, heavyRegiment],
        );

        final computedFlank = WarbandManager.applyForwardForce([warband]);

        // Heavy regiment should get Flank despite having lower points
        expect(computedFlank[heavyRegiment], true);
        expect(computedFlank[lightRegiment], isNot(true));
      });

      test('should not grant Flank to regiments that already have it', () {
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

        final mediumWithoutFlank = Regiment(
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
          pointsCost: 150,
        );

        final warband = Warband(
          character: character,
          regiments: [heavyWithFlank, mediumWithoutFlank],
        );

        final computedFlank = WarbandManager.applyForwardForce([warband]);

        // Medium should get Flank since Heavy already has it
        expect(computedFlank[mediumWithoutFlank], true);
        expect(computedFlank.containsKey(heavyWithFlank), false);
      });

      test('should not grant Flank to monsters', () {
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

        final monster = Regiment(
          unit: Unit(
            name: 'Dragon',
            faction: 'TestFaction',
            type: 'monster',
            regimentClass: 'heavy',
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

        final infantry = Regiment(
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
          pointsCost: 150,
        );

        final warband = Warband(
          character: character,
          regiments: [monster, infantry],
        );

        final computedFlank = WarbandManager.applyForwardForce([warband]);

        // Infantry should get Flank, not the monster
        expect(computedFlank[infantry], true);
        expect(computedFlank.containsKey(monster), false);
      });
    });
  });
}
