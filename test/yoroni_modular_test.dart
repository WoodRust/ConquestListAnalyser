import 'package:flutter_test/flutter_test.dart';
import 'package:conquest_analyzer/services/list_parser.dart';
import 'package:conquest_analyzer/services/scoring_engine.dart';
import 'package:conquest_analyzer/services/unit_database.dart';

const _exampleList = '''
=== The Last Argument of Kings ===

Spider Oni combo [1995/2000]
Yoroni


== (Warlord) Daimyo [140]: Fu, Gunbai

 * Modular Regiment (2) [160]: Oni Ayakashi (L), Oni Ayakashi

 * Modular Regiment (4) [315]: Tengu Ayakashi (L), Tengu Ayakashi (2), Kappa Bushi

 * Modular Regiment (2) [160]: Tengu Ayakashi (L), Tengu Ayakashi


== Jorogumo Mahotsu [240]: 

 * Shikigami (3) [120]: 

 * Modular Regiment (2) [160]: Oni Ayakashi (L), Oni Ayakashi

 * Modular Regiment (2) [160]: Oni Ayakashi (L), Oni Ayakashi


== Jorogumo Geisha [260]: 

 * Shikigami (3) [120]: 

 * Modular Regiment (2) [160]: Oni Ayakashi (L), Oni Ayakashi
''';

String _header(String body) => '''
=== The Last Argument of Kings ===

Test [500/2000]
Yoroni

== (Warlord) Daimyo [110]: 
$body
''';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Yoroni Modular Regiments', () {
    late ListParser parser;

    setUp(() => parser = ListParser(database: UnitDatabase.instance));

    test('parses the example list and scores it', () async {
      final armyList = await parser.parseList(_exampleList);
      final score = ScoringEngine().calculateScores(armyList);

      expect(armyList.regiments.length, equals(11));
      final modular = armyList.regiments.where((r) => r.isModular).toList();
      expect(modular.length, equals(6));

      final oni = modular.first;
      expect(oni.unit.name, equals('Oni Ayakashi'));
      expect(oni.stands, equals(2));
      expect(oni.auxiliaryStands, isEmpty);
      expect(oni.totalWounds, equals(14));
      // (5 A + 1 command) x 2 stands + 1 leader, Clash 3 -> 4/6 hit chance
      expect(oni.expectedHitVolume, closeTo(13 * 4 / 6, 0.001));

      final tengu = modular[1];
      expect(tengu.unit.name, equals('Tengu Ayakashi'));
      expect(tengu.stands, equals(3));
      expect(tengu.auxiliaryStands.map((s) => s.name),
          orderedEquals(['Kappa Bushi']));
      expect(tengu.totalWounds, equals(22));
      expect(tengu.displayStands, equals(4));
      // lowest March 6 (Kappa) + 1 Gain Spirit Breeze
      expect(tengu.march, equals(7));
      // (4 x 3 + 1 leader) x Volley 3/6
      expect(tengu.rangedExpectedHits, closeTo(6.5, 0.001));
      expect(tengu.rangedArmorPiercingRating, closeTo(6.5, 0.001));

      for (final regiment in modular) {
        final standPoints = regiment.unit.points * regiment.stands +
            regiment.auxiliaryStands.fold<int>(
                0,
                (sum, stand) =>
                    sum + UnitDatabase.instance.findUnit(stand.name)!.points);
        expect(standPoints, equals(regiment.pointsCost));
      }

      expect(score.totalWounds, equals(148));
      expect(score.scoringStands, equals(23));
    });

    test('Powerful Presence character counts as 3 scoring stands', () async {
      final medium = await parser.parseList(_header(
          ' * Modular Regiment (2) [160]: Oni Ayakashi (L), Oni Ayakashi'));
      expect(ScoringEngine().calculateScores(medium).scoringStands, equals(5));

      final unattached = await parser.parseList(_header(''));
      expect(
          ScoringEngine().calculateScores(unattached).scoringStands, equals(1));
    });

    test('Kami Ayakashi leader adds +1 Evasion to all stands', () async {
      final armyList = await parser.parseList(_header(
          ' * Modular Regiment (3) [230]: Kami Ayakashi (L), Kami Ayakashi, Oni Ayakashi'));
      final regiment = armyList.regiments.singleWhere((r) => r.isModular);
      expect(regiment.unit.characteristics.evasion, equals(2));
      expect(regiment.auxiliaryStands.single.characteristics.evasion,
          equals(2));
      expect(regiment.auxiliaryStands.single.characteristics.attacks,
          equals(5));
    });

    test('skips modular regiments that break the build rules', () async {
      const invalidLines = [
        ' * Modular Regiment (3) [240]: Oni Ayakashi (L), Oni Ayakashi',
        ' * Modular Regiment (1) [80]: Oni Ayakashi (L)',
        ' * Modular Regiment (4) [310]: Oni Ayakashi (L), Oni Ayakashi, Kappa Bushi (2)',
        ' * Modular Regiment (2) [160]: Oni Ayakashi (L), Not A Unit',
        ' * Modular Regiment (2) [240]: Shikigami (L), Shikigami',
        ' * Modular Regiment (2) [155]: Oni Ayakashi (L), Kappa Bushi (L)',
      ];
      for (final line in invalidLines) {
        final armyList = await parser.parseList(_header(line));
        expect(armyList.regiments.where((r) => r.isModular), isEmpty,
            reason: line);
      }
    });

    test('modular composition round-trips through list text', () async {
      final armyList = await parser.parseList(_exampleList);
      for (final regiment in armyList.regiments.where((r) => r.isModular)) {
        final line =
            ' * Modular Regiment (${regiment.displayStands}) [${regiment.pointsCost}]: ${regiment.modularComposition}';
        final reparsed = (await parser.parseList(_header(line)))
            .regiments
            .singleWhere((r) => r.isModular);
        expect(reparsed.unit.name, equals(regiment.unit.name));
        expect(reparsed.stands, equals(regiment.stands));
        expect(reparsed.auxiliaryStands.map((s) => s.name),
            orderedEquals(regiment.auxiliaryStands.map((s) => s.name)));
        expect(reparsed.totalWounds, equals(regiment.totalWounds));
      }
      expect(armyList.regiments.where((r) => r.isModular).elementAt(1)
          .modularComposition,
          equals('Tengu Ayakashi (L), Tengu Ayakashi (2), Kappa Bushi'));
    });
  });
}
