import 'package:flutter_test/flutter_test.dart';
import 'package:conquest_analyzer/services/list_parser.dart';
import 'package:conquest_analyzer/services/unit_database_interface.dart';
import 'package:conquest_analyzer/models/unit.dart';
import 'package:conquest_analyzer/models/army_list.dart';
import 'package:conquest_analyzer/models/regiment.dart';
import 'package:conquest_analyzer/models/list_score.dart';

void main() {
  group('List Reconstruction Tests', () {
    late ListParser parser;
    late MockUnitDatabase mockDatabase;

    setUp(() {
      mockDatabase = MockUnitDatabase();
      parser = ListParser(database: mockDatabase);
    });

    test('reconstructed list text should be parseable by ListParser',
        () async {
      // Create a sample ListScore as would be saved
      final unit1 = Unit(
        name: 'Vargyr Lord',
        faction: 'Nords',
        type: 'infantry',
        regimentClass: 'character',
        characteristics: const UnitCharacteristics(
          march: 6,
          volley: 1,
          clash: 4,
          attacks: 4,
          wounds: 3,
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

      final unit2 = Unit(
        name: 'Raiders',
        faction: 'Nords',
        type: 'infantry',
        regimentClass: 'light',
        characteristics: const UnitCharacteristics(
          march: 6,
          volley: 1,
          clash: 3,
          attacks: 4,
          wounds: 1,
          resolve: 2,
          defense: 2,
          evasion: 1,
        ),
        specialRules: const [],
        numericSpecialRules: const {},
        supremacyAbilities: const [],
        drawEvents: const [],
        points: 120,
        pointsPerAdditionalStand: 40,
      );

      final regiment1 = Regiment(
        unit: unit1,
        stands: 1,
        pointsCost: 160,
        upgrades: const ['Wild Beasts'],
        isWarlord: true,
      );

      final regiment2 = Regiment(
        unit: unit2,
        stands: 3,
        pointsCost: 140,
        upgrades: const ['Captain'],
        isWarlord: false,
      );

      final armyList = ArmyList(
        name: 'Test Army',
        faction: 'Nords',
        totalPoints: 300,
        pointsLimit: 2000,
        regiments: [regiment1, regiment2],
      );

      final score = ListScore(
        armyList: armyList,
        totalWounds: 6,
        pointsPerWound: 50.0,
        expectedHitVolume: 10.0,
        cleaveRating: 0.0,
        rangedExpectedHits: 0.0,
        rangedArmorPiercingRating: 0.0,
        maxRange: 0,
        averageSpeed: 6.0,
        toughness: 2.5,
        evasion: 1.0,
        effectiveWoundsDefense: 8.0,
        effectiveWoundsDefenseResolve: 10.0,
        resolveImpactPercentage: 25.0,
        pointsPerEffectiveWoundDefense: 37.5,
        pointsPerEffectiveWoundDefenseResolve: 30.0,
        magicCapability: 0,
        expectedHealingCapability: 0,
        calculatedAt: DateTime.now(),
      );

      // Reconstruct the list text (simulating what main_screen.dart does)
      final reconstructedText = _reconstructListText(score);

      // The reconstructed text should be parseable by ListParser
      final reparsedList = await parser.parseList(reconstructedText);

      expect(reparsedList.name, equals('Test Army'));
      expect(reparsedList.faction, equals('Nords'));
      expect(reparsedList.totalPoints, equals(300));
      expect(reparsedList.pointsLimit, equals(2000));
      expect(reparsedList.regiments.length, equals(2));
    });

    test('reconstructed text has correct header format', () {
      final unit = Unit(
        name: 'Test Unit',
        faction: 'Nords',
        type: 'infantry',
        regimentClass: 'medium',
        characteristics: const UnitCharacteristics(
          march: 6,
          volley: 1,
          clash: 3,
          attacks: 4,
          wounds: 1,
          resolve: 2,
          defense: 2,
          evasion: 1,
        ),
        specialRules: const [],
        numericSpecialRules: const {},
        supremacyAbilities: const [],
        drawEvents: const [],
        points: 120,
        pointsPerAdditionalStand: 40,
      );

      final regiment = Regiment(
        unit: unit,
        stands: 3,
        pointsCost: 120,
        upgrades: const [],
        isWarlord: false,
      );

      final armyList = ArmyList(
        name: 'Header Test',
        faction: 'Nords',
        totalPoints: 1500,
        pointsLimit: 2000,
        regiments: [regiment],
      );

      final score = ListScore(
        armyList: armyList,
        totalWounds: 3,
        pointsPerWound: 500.0,
        expectedHitVolume: 10.0,
        cleaveRating: 0.0,
        rangedExpectedHits: 0.0,
        rangedArmorPiercingRating: 0.0,
        maxRange: 0,
        averageSpeed: 6.0,
        toughness: 2.0,
        evasion: 1.0,
        effectiveWoundsDefense: 4.0,
        effectiveWoundsDefenseResolve: 5.0,
        resolveImpactPercentage: 25.0,
        pointsPerEffectiveWoundDefense: 375.0,
        pointsPerEffectiveWoundDefenseResolve: 300.0,
        magicCapability: 0,
        expectedHealingCapability: 0,
        calculatedAt: DateTime.now(),
      );

      final reconstructedText = _reconstructListText(score);
      final lines = reconstructedText.split('\n');

      // Check first line has === wrapping
      expect(lines[0], equals('=== The Last Argument of Kings ==='));

      // Check there's a blank line
      expect(lines[1], equals(''));

      // Check points format includes limit with slash separator
      expect(lines[2], equals('Header Test [1500/2000]'));
      expect(lines[2], contains('/'),
          reason: 'Points line should contain / separator');
      expect(lines[2], isNot(contains('pts')),
          reason: 'Points line should not contain "pts" text');

      // Check faction
      expect(lines[3], equals('Nords'));
    });
  });
}

/// Reconstruct list text from a loaded score
/// (Copied from main_screen.dart for testing)
String _reconstructListText(ListScore score) {
  final buffer = StringBuffer();
  buffer.writeln('=== The Last Argument of Kings ===');
  buffer.writeln();
  buffer.writeln(
      '${score.armyList.name} [${score.armyList.totalPoints}/${score.armyList.pointsLimit}]');
  buffer.writeln(score.armyList.faction);
  buffer.writeln();

  for (final regiment in score.armyList.regiments) {
    if (regiment.unit.regimentClass == 'character') {
      buffer.write('== ${regiment.unit.name} [${regiment.pointsCost}]');
    } else {
      buffer.write(
          '* ${regiment.unit.name} (${regiment.stands}) [${regiment.pointsCost}]');
    }

    if (regiment.upgrades.isNotEmpty) {
      buffer.write(': ${regiment.upgrades.join(", ")}');
    }

    if (regiment.isWarlord) {
      buffer.write(' [Warlord]');
    }

    buffer.writeln();
  }

  return buffer.toString();
}

class MockUnitDatabase implements UnitDatabaseInterface {
  @override
  Future<void> loadData() async {
    // No-op for mock
  }

  @override
  Unit? findUnit(String unitName) {
    // Return a mock unit for any request
    return Unit(
      name: unitName,
      faction: 'Nords',
      type: 'infantry',
      regimentClass: 'medium',
      characteristics: const UnitCharacteristics(
        march: 6,
        volley: 1,
        clash: 3,
        attacks: 4,
        wounds: 1,
        resolve: 2,
        defense: 2,
        evasion: 1,
      ),
      specialRules: const [],
      numericSpecialRules: const {},
      supremacyAbilities: const [],
      drawEvents: const [],
      points: 120,
      pointsPerAdditionalStand: 40,
    );
  }

  @override
  List<Unit> getUnitsForFaction(String faction) {
    return [];
  }

  @override
  List<String> get availableFactions => ['Nords'];

  @override
  bool get isLoaded => true;
}
