import 'package:flutter_test/flutter_test.dart';
import 'package:conquest_analyzer/services/list_parser.dart';
import 'package:conquest_analyzer/services/scoring_engine.dart';
import 'package:conquest_analyzer/services/army_effect_manager.dart';
import 'package:conquest_analyzer/services/unit_database_interface.dart';
import 'package:conquest_analyzer/models/unit.dart';
import 'package:conquest_analyzer/models/regiment.dart';
import 'package:conquest_analyzer/models/army_list.dart';

void main() {
  group('Supremacy Abilities Tests with Character Monsters', () {
    late ListParser parser;
    late ScoringEngine scoringEngine;
    late MockUnitDatabase mockDatabase;

    setUp(() {
      mockDatabase = MockUnitDatabase();
      parser = ListParser(database: mockDatabase);
      scoringEngine = ScoringEngine();
    });

    test('should apply Divine Protection to character monsters', () async {
      const input = '''
=== The Last Argument of Kings ===
Character Monster Test [580/2000]
Nords
== (Warlord) Shaman [80]: 
 * Raiders (3) [140]: Captain
 * Dragon Monster (1) [360]: 
''';

      final armyList = await parser.parseList(input);
      final score = scoringEngine.calculateScores(armyList);

      // Verify parsing worked correctly
      expect(armyList.name, equals('Character Monster Test'));
      expect(armyList.faction, equals('Nords'));
      expect(armyList.regiments.length, equals(3)); // 1 character + 2 regiments

      // Find the warlord and character monster
      final warlord = armyList.regiments.firstWhere((r) => r.isWarlord);
      expect(warlord.unit.name, equals('Shaman'));
      expect(warlord.isWarlord, isTrue);

      final characterMonster =
          armyList.regiments.firstWhere((r) => r.unit.name == 'Dragon Monster');
      expect(characterMonster.unit.regimentClass, equals('character'));
      expect(characterMonster.unit.type, equals('monster'));

      // Test army effects
      final armyEffects = ArmyEffectManager.getActiveEffects(armyList);
      expect(armyEffects.length, equals(1));
      final divineProtection = armyEffects.first;
      expect(divineProtection.characteristic, equals('evasion'));
      expect(divineProtection.operation, equals('add'));
      expect(divineProtection.value, equals(1));
      expect(divineProtection.maximum, equals(2));

      // Test that Divine Protection applies to character monster
      final characterMonsterEffectiveEvasion =
          ArmyEffectManager.getEffectiveCharacteristic(
              characterMonster, 'evasion', armyEffects);
      expect(characterMonsterEffectiveEvasion,
          equals(2)); // Base 1 + 1 from Divine Protection

      // Test that Divine Protection applies to regular regiments
      final raidersRegiment =
          armyList.regiments.firstWhere((r) => r.unit.name == 'Raiders');
      final raidersEffectiveEvasion =
          ArmyEffectManager.getEffectiveCharacteristic(
              raidersRegiment, 'evasion', armyEffects);
      expect(raidersEffectiveEvasion,
          equals(2)); // Base 1 + 1 from Divine Protection

      // Test overall evasion score includes both character monster and regiment with effects
      // Raiders: 3 stands * 4 wounds = 12 wounds, effective evasion 2
      // Character monster: 1 stand * 8 wounds = 8 wounds, effective evasion 2
      // Total wounds: 12 + 8 = 20
      // Evasion score: (2 * 12 + 2 * 8) / 20 = 40 / 20 = 2.0
      expect(score.evasion, equals(2.0));
    });

    test('should not apply Divine Protection to regular characters', () async {
      const input = '''
=== The Last Argument of Kings ===
Regular Character Test [340/2000]
Nords
== (Warlord) Shaman [80]: 
 * Raiders (2) [100]: 
== Regular Character [160]: 
''';

      final armyList = await parser.parseList(input);

      // Test army effects
      final armyEffects = ArmyEffectManager.getActiveEffects(armyList);
      expect(armyEffects.length, equals(1));

      // Test that Divine Protection does NOT apply to regular character
      final regularCharacter = armyList.regiments
          .firstWhere((r) => r.unit.name == 'Regular Character');
      final regularCharacterEffectiveEvasion =
          ArmyEffectManager.getEffectiveCharacteristic(
              regularCharacter, 'evasion', armyEffects);
      expect(regularCharacterEffectiveEvasion,
          equals(1)); // Base 1, no effect applied

      // Verify the effect's appliesTo method correctly excludes regular characters
      final effect = armyEffects.first;
      expect(effect.appliesTo(regularCharacter), isFalse);
    });

    test('should handle mixed army with all unit types and supremacy abilities',
        () async {
      const input = '''
=== The Last Argument of Kings ===
Mixed Army Test [1000/2000]
Nords
== (Warlord) Volva [100]: 
 * Raiders (2) [100]: 
 * Dragon Monster (1) [360]: 
== Regular Character [160]: 
 * Heavy Unit (2) [280]: 
''';

      final armyList = await parser.parseList(input);
      final score = scoringEngine.calculateScores(armyList);

      // Test army effects
      final armyEffects = ArmyEffectManager.getActiveEffects(armyList);
      expect(armyEffects.length, equals(1));

      // Verify effects apply correctly to each type
      final raiders =
          armyList.regiments.firstWhere((r) => r.unit.name == 'Raiders');
      final characterMonster =
          armyList.regiments.firstWhere((r) => r.unit.name == 'Dragon Monster');
      final regularCharacter = armyList.regiments
          .firstWhere((r) => r.unit.name == 'Regular Character');
      final heavyUnit =
          armyList.regiments.firstWhere((r) => r.unit.name == 'Heavy Unit');

      final effect = armyEffects.first;

      // Should apply to regular regiments and character monsters
      expect(effect.appliesTo(raiders), isTrue);
      expect(effect.appliesTo(characterMonster), isTrue);
      expect(effect.appliesTo(heavyUnit), isTrue);

      // Should NOT apply to regular characters
      expect(effect.appliesTo(regularCharacter), isFalse);

      // Test effective evasion values
      expect(
          ArmyEffectManager.getEffectiveCharacteristic(
              raiders, 'evasion', armyEffects),
          equals(2)); // 1 + 1
      expect(
          ArmyEffectManager.getEffectiveCharacteristic(
              characterMonster, 'evasion', armyEffects),
          equals(2)); // 1 + 1
      expect(
          ArmyEffectManager.getEffectiveCharacteristic(
              heavyUnit, 'evasion', armyEffects),
          equals(2)); // 1 + 1
      expect(
          ArmyEffectManager.getEffectiveCharacteristic(
              regularCharacter, 'evasion', armyEffects),
          equals(1)); // 1 + 0

      // Test overall score calculations
      // For evasion calculation (includes character monsters, excludes regular characters):
      // Raiders: 2 stands × 4 wounds = 8 wounds, effective evasion 2
      // Character Monster: 1 stand × 8 wounds = 8 wounds, effective evasion 2
      // Heavy Unit: 2 stands × 6 wounds = 12 wounds, effective evasion 2
      // Total: (2×8 + 2×8 + 2×12) / (8 + 8 + 12) = (16 + 16 + 24) / 28 = 56 / 28 = 2.0
      expect(score.evasion, equals(2.0));

      // For toughness calculation (same units):
      // Raiders: defense 1, 8 wounds → 1×8 = 8
      // Character Monster: defense 2, 8 wounds → 2×8 = 16
      // Heavy Unit: defense 2, 12 wounds → 2×12 = 24
      // Total: (8 + 16 + 24) / (8 + 8 + 12) = 48 / 28 ≈ 1.71
      expect(score.toughness, closeTo(1.71, 0.01));
    });

    test('should handle character monster with maximum evasion constraint', () {
      // Create a character monster with high base evasion to test maximum
      final highEvasionCharacterMonster = Unit(
        name: 'High Evasion Dragon',
        faction: 'Nords',
        type: 'monster',
        regimentClass: 'character',
        characteristics: const UnitCharacteristics(
          march: 8,
          volley: 4,
          clash: 5,
          attacks: 8,
          wounds: 8,
          resolve: 5,
          defense: 4,
          evasion: 2, // Base evasion 2, +1 would be 3, but max is 2
        ),
        specialRules: const [],
        numericSpecialRules: const {},
        supremacyAbilities: const [],
        drawEvents: const [],
        points: 400,
      );

      final warlordShaman = Unit(
        name: 'Shaman',
        faction: 'Nords',
        type: 'character',
        regimentClass: 'character',
        characteristics: const UnitCharacteristics(
          march: 6,
          volley: 2,
          clash: 3,
          attacks: 4,
          wounds: 3,
          resolve: 3,
          defense: 1,
          evasion: 1,
        ),
        specialRules: const [],
        numericSpecialRules: const {},
        supremacyAbilities: const [
          SupremacyAbility(
            name: 'Divine Protection',
            condition: 'isWarlord',
            effect: CharacteristicModifier(
              type: 'characteristicModifier',
              target: 'allFriendlyRegiments',
              characteristic: 'evasion',
              operation: 'add',
              value: 1,
              maximum: 2,
            ),
          ),
        ],
        drawEvents: const [],
        points: 80,
      );

      final regiments = [
        Regiment(
            unit: warlordShaman, stands: 1, pointsCost: 80, isWarlord: true),
        Regiment(unit: highEvasionCharacterMonster, stands: 1, pointsCost: 400),
      ];

      final armyList = ArmyList(
        name: 'Maximum Test Army',
        faction: 'Nords',
        totalPoints: 480,
        pointsLimit: 2000,
        regiments: regiments,
      );

      // Test army effects
      final armyEffects = ArmyEffectManager.getActiveEffects(armyList);
      expect(armyEffects.length, equals(1));

      final effect = armyEffects.first;
      expect(effect.maximum, equals(2));

      // Test that character monster evasion is capped at maximum
      final characterMonster = regiments[1];
      final effectiveEvasion = ArmyEffectManager.getEffectiveCharacteristic(
          characterMonster, 'evasion', armyEffects);
      expect(effectiveEvasion, equals(2)); // Capped at maximum, not 3
    });

    test('should generate correct effects summary with character monsters',
        () async {
      const input = '''
=== The Last Argument of Kings ===
Effects Summary Test [440/2000]
Nords
== (Warlord) Shaman [80]: 
 * Raiders (2) [100]: 
 * Dragon Monster (1) [360]: 
''';

      final armyList = await parser.parseList(input);
      final effectsSummary = ArmyEffectManager.getEffectsSummary(armyList);

      expect(effectsSummary, contains('Active Army Effects:'));
      expect(effectsSummary, contains('evasion add 1 (max 2)'));
    });
  });
}

/// Mock database with Nords units including character monsters and supremacy abilities
class MockUnitDatabase implements UnitDatabaseInterface {
  final Map<String, Unit> _units = {
    'shaman': Unit(
      name: 'Shaman',
      faction: 'Nords',
      type: 'character',
      regimentClass: 'character',
      characteristics: const UnitCharacteristics(
        march: 6,
        volley: 2,
        clash: 3,
        attacks: 4,
        wounds: 3,
        resolve: 3,
        defense: 1,
        evasion: 1,
      ),
      specialRules: const [],
      numericSpecialRules: const {},
      supremacyAbilities: const [
        SupremacyAbility(
          name: 'Divine Protection',
          condition: 'isWarlord',
          effect: CharacteristicModifier(
            type: 'characteristicModifier',
            target: 'allFriendlyRegiments',
            characteristic: 'evasion',
            operation: 'add',
            value: 1,
            maximum: 2,
          ),
        ),
      ],
      drawEvents: const [],
      points: 80,
    ),
    'volva': Unit(
      name: 'Volva',
      faction: 'Nords',
      type: 'character',
      regimentClass: 'character',
      characteristics: const UnitCharacteristics(
        march: 6,
        volley: 2,
        clash: 3,
        attacks: 4,
        wounds: 3,
        resolve: 3,
        defense: 1,
        evasion: 1,
      ),
      specialRules: const [],
      numericSpecialRules: const {},
      supremacyAbilities: const [
        SupremacyAbility(
          name: 'Divine Protection',
          condition: 'isWarlord',
          effect: CharacteristicModifier(
            type: 'characteristicModifier',
            target: 'allFriendlyRegiments',
            characteristic: 'evasion',
            operation: 'add',
            value: 1,
            maximum: 2,
          ),
        ),
      ],
      drawEvents: const [],
      points: 100,
    ),
    'raiders': Unit(
      name: 'Raiders',
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
      supremacyAbilities: const [],
      drawEvents: const [],
      points: 120,
      pointsPerAdditionalStand: 40,
    ),
    'dragon monster': Unit(
      name: 'Dragon Monster',
      faction: 'Nords',
      type: 'monster',
      regimentClass: 'character',
      characteristics: const UnitCharacteristics(
        march: 8,
        volley: 4,
        clash: 5,
        attacks: 8,
        wounds: 8,
        resolve: 5,
        defense: 2,
        evasion: 1,
      ),
      specialRules: const [],
      numericSpecialRules: const {'cleave': 3},
      supremacyAbilities: const [],
      drawEvents: const [],
      points: 360,
    ),
    'regular character': Unit(
      name: 'Regular Character',
      faction: 'Nords',
      type: 'character',
      regimentClass: 'character',
      characteristics: const UnitCharacteristics(
        march: 6,
        volley: 2,
        clash: 3,
        attacks: 4,
        wounds: 3,
        resolve: 3,
        defense: 2,
        evasion: 1,
      ),
      specialRules: const [],
      numericSpecialRules: const {},
      supremacyAbilities: const [],
      drawEvents: const [],
      points: 160,
    ),
    'heavy unit': Unit(
      name: 'Heavy Unit',
      faction: 'Nords',
      type: 'infantry',
      regimentClass: 'heavy',
      characteristics: const UnitCharacteristics(
        march: 4,
        volley: 1,
        clash: 4,
        attacks: 3,
        wounds: 6,
        resolve: 4,
        defense: 2,
        evasion: 1,
      ),
      specialRules: const [],
      numericSpecialRules: const {},
      supremacyAbilities: const [],
      drawEvents: const [],
      points: 200,
      pointsPerAdditionalStand: 80,
    ),
  };

  @override
  Future<void> loadData() async {
    // Mock implementation - no async loading needed
  }

  @override
  Unit? findUnit(String unitName) {
    return _units[unitName.toLowerCase()];
  }

  @override
  List<Unit> getUnitsForFaction(String faction) {
    return _units.values.where((unit) => unit.faction == faction).toList();
  }

  @override
  List<String> get availableFactions => ['Nords'];

  @override
  bool get isLoaded => true;
}
