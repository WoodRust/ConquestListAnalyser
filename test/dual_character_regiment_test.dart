import 'package:flutter_test/flutter_test.dart';
import 'package:conquest_analyzer/services/list_parser.dart';
import 'package:conquest_analyzer/services/unit_database.dart';
import 'package:conquest_analyzer/services/scoring_engine.dart';
import 'package:conquest_analyzer/models/unit.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  
  group('Dual Character/Regiment Tests', () {
    late UnitDatabase database;
    late ListParser parser;
    late ScoringEngine scoringEngine;

    setUp(() async {
      database = UnitDatabase.instance;
      await database.loadData();
      parser = ListParser(database: database);
      scoringEngine = ScoringEngine();
    });

    test('Jotnar Seidr should count as heavy regiment', () async {
      const input = '''
=== The Last Argument of Kings ===
Jotnar Test [260/2000]
Nords

== Jotnar Seidr [260]:
''';

      final armyList = await parser.parseList(input);
      
      // Verify it's a character monster
      expect(armyList.characterMonsters.length, equals(1));
      expect(armyList.characterMonsters.first.unit.name, equals('Jotnar Seidr'));
      
      // Verify it counts as heavy regiment
      expect(armyList.heavyRegimentCount, equals(1));
      expect(armyList.mediumRegimentCount, equals(0));
      expect(armyList.lightRegimentCount, equals(0));
      
      // Verify it has actualRegimentClass
      expect(armyList.characterMonsters.first.unit.actualRegimentClass, equals('heavy'));
    });

    test('Promethean Oracle should count as heavy regiment', () async {
      const input = '''
=== The Last Argument of Kings ===
Oracle Test [260/2000]
City States

== Promethean Oracle [260]:
''';

      final armyList = await parser.parseList(input);
      
      expect(armyList.characterMonsters.length, equals(1));
      expect(armyList.heavyRegimentCount, equals(1));
      expect(armyList.characterMonsters.first.unit.actualRegimentClass, equals('heavy'));
    });

    test('Fallen Divinity should count as medium regiment', () async {
      const input = '''
=== The Last Argument of Kings ===
Fallen Test [300/2000]
Old Dominion

== Fallen Divinity [300]:
''';

      final armyList = await parser.parseList(input);
      
      expect(armyList.characterMonsters.length, equals(1));
      expect(armyList.mediumRegimentCount, equals(1));
      expect(armyList.heavyRegimentCount, equals(0));
      expect(armyList.characterMonsters.first.unit.actualRegimentClass, equals('medium'));
    });

    test('Winglord Predator should count as heavy regiment', () async {
      const input = '''
=== The Last Argument of Kings ===
Winglord Test [210/2000]
W'adrhun

== Winglord Predator [210]:
''';

      final armyList = await parser.parseList(input);
      
      expect(armyList.characterMonsters.length, equals(1));
      expect(armyList.heavyRegimentCount, equals(1));
      expect(armyList.characterMonsters.first.unit.actualRegimentClass, equals('heavy'));
    });

    test('Jorogumo Mahotsu should count as medium regiment', () async {
      const input = '''
=== The Last Argument of Kings ===
Spider Test [300/2000]
Yoroni

== Jorogumo Mahotsu [300]:
''';

      final armyList = await parser.parseList(input);
      
      expect(armyList.characterMonsters.length, equals(1));
      expect(armyList.mediumRegimentCount, equals(1));
      expect(armyList.characterMonsters.first.unit.actualRegimentClass, equals('medium'));
    });

    test('Jorogumo Geisha should count as medium regiment', () async {
      const input = '''
=== The Last Argument of Kings ===
Geisha Test [280/2000]
Yoroni

== Jorogumo Geisha [280]:
''';

      final armyList = await parser.parseList(input);
      
      expect(armyList.characterMonsters.length, equals(1));
      expect(armyList.mediumRegimentCount, equals(1));
      expect(armyList.characterMonsters.first.unit.actualRegimentClass, equals('medium'));
    });

    test('Army with both regular heavy and dual character heavy', () async {
      const input = '''
=== The Last Argument of Kings ===
Mixed Heavy [520/2000]
Nords

== Jotnar Seidr [260]:
 * Bearsarks (1) [170]:
''';

      final armyList = await parser.parseList(input);
      
      // Should have 1 character monster + 1 regular heavy = 2 heavy total
      expect(armyList.characterMonsters.length, equals(1));
      expect(armyList.nonCharacterRegiments.length, equals(1));
      expect(armyList.heavyRegimentCount, equals(2)); // Both count!
    });

    test('Regular character monster without actualRegimentClass should not count', () async {
      const input = '''
=== The Last Argument of Kings ===
Ice Jotnar Test [250/2000]
Nords

== Ice Jotnar [250]:
''';

      final armyList = await parser.parseList(input);
      
      // Ice Jotnar is a monster with regimentClass='heavy' (not character)
      // It should count as a regular heavy regiment
      expect(armyList.characterMonsters.length, equals(0));
      expect(armyList.heavyRegimentCount, equals(1));
    });
  });
}
