import 'unit.dart';

/// Represents a specific instance of a unit in an army list
class Regiment {
  final Unit unit;
  final int stands;
  final int pointsCost;
  final List<String> upgrades;

  const Regiment({
    required this.unit,
    required this.stands,
    required this.pointsCost,
    this.upgrades = const [],
  });

  /// Total wounds for this regiment (wounds per stand * number of stands)
  int get totalWounds => unit.woundsPerStand * stands;

  /// Points per wound for this regiment
  double get pointsPerWound => pointsCost / totalWounds;

  /// Expected hit volume using army context (for display)
  double get expectedHitVolume => calculateExpectedHitVolume();

  /// Calculate expected hit volume for this regiment
  double calculateExpectedHitVolume({List<Regiment>? armyRegiments}) {
    // Base attacks = attacks per stand * number of stands
    int totalAttacks = unit.characteristics.attacks * stands;

    // Add +1 if regiment has leader (check for "Leader" special rule)
    final hasLeader = unit.specialRules
        .any((rule) => rule.name.toLowerCase().contains('leader'));
    if (hasLeader) {
      totalAttacks += 1;
    }

    // Calculate hit chance: (clash + 1) / 6
    final clashValue = unit.characteristics.clash;
    final hitChance = (clashValue + 1) / 6.0;

    // Calculate base expected hits
    double expectedHits = totalAttacks * hitChance;

    // Check for Flurry special rule (either direct or granted by army effects)
    bool hasFlurry = unit.specialRules
        .any((rule) => rule.name.toLowerCase().contains('flurry'));

    // Check for Feral Hunters ability from Vargyr Lord
    if (!hasFlurry && armyRegiments != null) {
      final hasVargyrLord = armyRegiments
          .any((regiment) => regiment.unit.name.toLowerCase() == 'vargyr lord');

      if (hasVargyrLord) {
        final benefitsFromFeralHunters = unit.name.toLowerCase() == 'werewargs';

        if (benefitsFromFeralHunters) {
          hasFlurry = true;
        }
      }
    }

    if (hasFlurry) {
      // Calculate missed attacks
      final missedAttacks = totalAttacks - expectedHits;
      // Calculate additional hits from re-rolls
      final additionalHits = missedAttacks * hitChance;
      expectedHits += additionalHits;
    }

    return expectedHits;
  }

  @override
  String toString() =>
      'Regiment(${unit.name}, stands: $stands, cost: $pointsCost, wounds: $totalWounds)';
}
