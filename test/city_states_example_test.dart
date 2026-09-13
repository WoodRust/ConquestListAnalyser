import 'package:flutter_test/flutter_test.dart';
import 'package:conquest_analyzer/services/list_parser.dart';
import 'package:conquest_analyzer/services/scoring_engine.dart';
import 'package:conquest_analyzer/services/unit_database.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('parses City States auxiliaries and grouped War Chariots', () async {
    const input = '''
=== The Last Argument of Kings ===

Mark LGT consider [1995/2000]
The City States

== (Warlord) Polemarch [135]: Aristia, Atalanta's Spear

 * Hoplites (5) [220]: Dorilates, Minotaur Haspist Auxiliary
 * Minotaur Haspists (3) [170]: 
 * Hephaestian (1) [220]: 
 * Hoplites (5) [220]: Dorilates, Minotaur Haspist Auxiliary

== Aristarch [100]: Primodynamic Globe

 * Hoplites (4) [185]: Dorilates, Minotaur Haspist Auxiliary
 * War Chariots (Flogobollon//Skorpios) (2) [270]: Skorpios (2)
 * War Chariots (Flogobollon//Skorpios) (2) [270]: Flogobollon, Skorpios
 * Thorakites (5) [205]: Minotaur Thyrean Auxiliary
''';

    final parser = ListParser(database: UnitDatabase.instance);
    final armyList = await parser.parseList(input);
    final score = ScoringEngine().calculateScores(armyList);

    expect(armyList.characters.map((r) => r.unit.name),
        containsAll(<String>['Polemarch', 'Aristarch']));
    expect(armyList.nonCharacterRegiments.length, equals(10));
    expect(armyList.regiments.length, equals(12));

    final auxiliaryRegiments = armyList.regiments
        .where((regiment) => regiment.auxiliaryStands.isNotEmpty)
        .toList();
    expect(auxiliaryRegiments.length, equals(4));
    expect(
        auxiliaryRegiments
            .where((regiment) => regiment.unit.name == 'Hoplites')
            .length,
        equals(3));
    expect(
        auxiliaryRegiments
            .where((regiment) => regiment.unit.name == 'Thorakites')
            .length,
        equals(1));

    final chariots = armyList.regiments
        .where((regiment) => regiment.unit.type == 'chariot')
        .toList();
    expect(chariots.length, equals(4));
    expect(
        chariots.map((regiment) => regiment.unit.name),
        orderedEquals(
            <String>['Skorpios', 'Skorpios', 'Flogobolon', 'Skorpios']));
    expect(chariots.every((regiment) => regiment.stands == 1), isTrue);
    expect(chariots.map((regiment) => regiment.sourceGroupId).toSet().length,
        equals(2));

    expect(score.totalWounds, equals(178));
    expect(score.scoringStands, equals(29));
  });
}
