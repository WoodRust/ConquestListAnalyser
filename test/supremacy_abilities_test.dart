import 'package:flutter_test/flutter_test.dart';
import 'package:conquest_analyzer/services/list_parser.dart';
import 'package:conquest_analyzer/services/scoring_engine.dart';
import 'package:conquest_analyzer/services/army_effect_manager.dart';
import 'package:conquest_analyzer/services/unit_database_interface.dart';
import 'package:conquest_analyzer/models/unit.dart';

void main() {
  group('Supremacy Abilities Tests', () {
    late ListParser parser;
    late ScoringEngine scoringEngine;
    late MockUnitDatabase mockDatabase;

    setUp(() {
      mockDatabase = MockUnitDatabase();
      parser = ListParser(database: mockDatabase);
      scoringEngine = ScoringEngine();
    });

    test('should apply Divine Protection supremacy ability from Warlord Shaman',
        () async {
      const input = '''
=== The Last Argument of Kings ===
Divine Protection Test [300/2000]
Nords

== (Warlord) Shaman [80]: 
 * Raiders (3) [140]: Captain
 * Raiders (2) [100]: 
''';

      final armyList = await parser.parseList(input);
      final score = scoringEngine.calculateScores(armyList);

      // Verify parsing worked correctly
      expect(armyList.name, equals('Divine Protection Test'));
      expect(armyList.faction, equals('Nords'));
      expect(armyList.regiments.length, equals(3)); // 1 character + 2 regiments

      // Find the warlord
      final warlord = armyList.regiments.firstWhere((r) => r.isWarlord);
      expect(warlord.unit.name, equals('Shaman'));
      expect(warlord.isWarlord, isTrue);

      // Test army effects
      final armyEffects = ArmyEffectManager.getActiveEffects(armyList);
      expect(armyEffects.length, equals(1));

      final divineProtection = armyEffects.first;
      expect(divineProtection.characteristic, equals('evasion'));
      expect(divineProtection.operation, equals('add'));
      expect(divineProtection.value, equals(1));
      expect(divineProtection.maximum, equals(2));

      // Test effective evasion calculation
      final raidersRegiments =
          armyList.regiments.where((r) => r.unit.name == 'Raiders').toList();
      expect(raidersRegiments.length, equals(2));

      for (final raiders in raidersRegiments) {
        // Base evasion is 1, should become 2 with Divine Protection
        final effectiveEvasion = ArmyEffectManager.getEffectiveCharacteristic(
            raiders, 'evasion', armyEffects);
        expect(effectiveEvasion, equals(2));
      }

      // Test overall evasion score includes the effect
      // Base evasion: 1, effective evasion: 2
      // Total wounds: (3 + 2) * 4 = 20 wounds
      // Evasion score: (2 * 20) / 20 = 2.0
      expect(score.evasion, equals(2.0));
    });

    test('should not apply Divine Protection when Shaman is not Warlord',
        () async {
      const input = '''
=== The Last Argument of Kings ===
No Divine Protection Test [300/2000]
Nords

== Shaman [80]: 
 * Raiders (3) [140]: Captain
 * Raiders (2) [100]: 
''';

      final armyList = await parser.parseList(input);
      final score = scoringEngine.calculateScores(armyList);

      // Find the shaman
      final shaman =
          armyList.regiments.firstWhere((r) => r.unit.name == 'Shaman');
      expect(shaman.isWarlord, isFalse);

      // Test army effects - should be empty
      final armyEffects = ArmyEffectManager.getActiveEffects(armyList);
      expect(armyEffects.length, equals(0));

      // Test evasion score remains base value
      // Base evasion: 1
      // Total wounds: (3 + 2) * 4 = 20 wounds
      // Evasion score: (1 * 20) / 20 = 1.0
      expect(score.evasion, equals(1.0));
    });

    test('should apply Divine Protection with maximum constraint', () async {
      const input = '''
=== The Last Argument of Kings ===
Maximum Test [180/2000]
Nords

== (Warlord) Volva [100]: 
 * High Evasion Unit (2) [80]: 
''';

      final armyList = await parser.parseList(input);

      // Test army effects
      final armyEffects = ArmyEffectManager.getActiveEffects(armyList);
      expect(armyEffects.length, equals(1));

      final highEvasionRegiment = armyList.regiments
          .firstWhere((r) => r.unit.name == 'High Evasion Unit');

      // Base evasion is 2, +1 from Divine Protection should be 3, but maximum is 2
      final effectiveEvasion = ArmyEffectManager.getEffectiveCharacteristic(
          highEvasionRegiment, 'evasion', armyEffects);
      expect(effectiveEvasion, equals(2)); // Capped at maximum
    });

    test('should generate correct effects summary', () async {
      const input = '''
=== The Last Argument of Kings ===
Effects Summary Test [180/2000]
Nords

== (Warlord) Shaman [80]: 
 * Raiders (2) [100]: 
''';

      final armyList = await parser.parseList(input);
      final effectsSummary = ArmyEffectManager.getEffectsSummary(armyList);

      expect(effectsSummary, contains('Active Army Effects:'));
      expect(effectsSummary, contains('evasion add 1 (max 2)'));
    });

    test('should handle army with no supremacy abilities', () async {
      const input = '''
=== The Last Argument of Kings ===
No Effects Test [240/2000]
Nords

== (Warlord) Basic Character [80]: 
 * Raiders (2) [160]: 
''';

      final armyList = await parser.parseList(input);

      final armyEffects = ArmyEffectManager.getActiveEffects(armyList);
      expect(armyEffects.length, equals(0));

      final effectsSummary = ArmyEffectManager.getEffectsSummary(armyList);
      expect(effectsSummary, equals('No army-wide effects active'));
    });
  });
}

/// Mock database with Nords units including supremacy abilities
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
    'high evasion unit': Unit(
      name: 'High Evasion Unit',
      faction: 'Nords',
      type: 'infantry',
      regimentClass: 'light',
      characteristics: const UnitCharacteristics(
        march: 7,
        volley: 2,
        clash: 2,
        attacks: 3,
        wounds: 3,
        resolve: 2,
        defense: 1,
        evasion: 2, // Base evasion 2 to test maximum constraint
      ),
      specialRules: const [],
      numericSpecialRules: const {},
      supremacyAbilities: const [],
      drawEvents: const [],
      points: 40,
    ),
    'basic character': Unit(
      name: 'Basic Character',
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
      supremacyAbilities: const [], // No supremacy abilities
      drawEvents: const [],
      points: 80,
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
