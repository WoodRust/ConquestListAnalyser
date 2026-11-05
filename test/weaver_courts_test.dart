import 'package:flutter_test/flutter_test.dart';
import 'package:conquest_analyzer/services/list_parser.dart';
import 'package:conquest_analyzer/services/scoring_engine.dart';
import 'package:conquest_analyzer/services/unit_database.dart';

const _exampleList = '''
=== The Last Argument of Kings ===

Cycle of Seasons [1605/2000]
Weaver Courts

== (Warlord) Mhor Sidhe [100]:

 * Kern Skirmishers (3) [135]: Kiannun Stalker
 * Gemred Knights (3) [220]:
 * Scoth Draic (1) [220]:

== Seanchas Sidhe [100]:
 * Wyrd Cavalry (3) [180]:
 * Gallowglass Wardens (3) [210]:
 * Coill Draic (1) [220]:
''';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Weaver Courts', () {
    late ListParser parser;
    setUp(() => parser = ListParser(database: UnitDatabase.instance));

    test('loads all Weaver Courts units and aliases', () async {
      final database = UnitDatabase.instance;
      await database.loadData();
      final units = database.getUnitsForFaction('WeaverCourts');
      expect(units.length, equals(19));
      expect(database.findUnit('Wyrd Cavalry')!.name, equals('Wyrd Knights'));
      expect(database.findUnit('Skoth Draic')!.name, equals('Scoth Draic'));
    });

    test('parses and scores an example list', () async {
      final armyList = await parser.parseList(_exampleList);
      final score = ScoringEngine().calculateScores(armyList);
      expect(armyList.faction, equals('Weaver Courts'));
      expect(armyList.regiments.length, equals(8));
      expect(armyList.characters.length, equals(2));
      expect(armyList.regiments.first.isWarlord, isTrue);
      expect(armyList.regiments[1].rangedExpectedHits, closeTo(13 * 2 / 6, 0.001));
      expect(score.magicCapability, equals(5));
      expect(score.maxRange, equals(16));
    });
  });
}
