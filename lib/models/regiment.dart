import 'unit.dart';

/// Represents a specific instance of a unit in an army list
class Regiment {
  final Unit unit;
  final int stands;
  final int pointsCost;
  final List<String> upgrades;
  final bool isWarlord;

  const Regiment({
    required this.unit,
    required this.stands,
    required this.pointsCost,
    this.upgrades = const [],
    this.isWarlord = false,
  });

  /// Total wounds for this regiment (wounds per stand * number of stands)
  int get totalWounds => unit.woundsPerStand * stands;

  /// Points per wound for this regiment
  double get pointsPerWound => pointsCost / totalWounds;

  /// Expected hit volume using army context (for display)
  double get expectedHitVolume => calculateExpectedHitVolume();

  /// Cleave value for this regiment from numeric special rules
  int get cleaveValue => unit.numericSpecialRules['cleave'] as int? ?? 0;

  /// Barrage value for this regiment from numeric special rules
  int get barrageValue => unit.numericSpecialRules['barrage'] as int? ?? 0;

  /// Barrage range value for this regiment from numeric special rules
  int get barrageRange => unit.numericSpecialRules['barrageRange'] as int? ?? 0;

  /// Armor piercing value for this regiment from numeric special rules
  int get armorPiercingValue =>
      unit.numericSpecialRules['armorPiercingValue'] as int? ?? 0;

  /// Calculate cleave rating for this regiment (Expected Hit Volume * Cleave)
  double get cleaveRating => expectedHitVolume * cleaveValue;

  /// Calculate ranged expected hits for this regiment
  double get rangedExpectedHits => calculateRangedExpectedHits();

  /// Calculate ranged armor piercing rating for this regiment (Ranged Expected Hits * Armor Piercing)
  double get rangedArmorPiercingRating =>
      rangedExpectedHits * armorPiercingValue;

  /// Get effective evasion considering army-wide effects
  int getEffectiveEvasion(List<CharacteristicModifier> armyEffects) {
    int effectiveEvasion = unit.characteristics.evasion;

    for (final effect in armyEffects) {
      if (effect.characteristic == 'evasion' && effect.appliesTo(this)) {
        effectiveEvasion = effect.applyToValue(effectiveEvasion);
      }
    }

    return effectiveEvasion;
  }

  /// Get effective defense considering army-wide effects
  int getEffectiveDefense(List<CharacteristicModifier> armyEffects) {
    int effectiveDefense = unit.characteristics.defense;

    for (final effect in armyEffects) {
      if (effect.characteristic == 'defense' && effect.appliesTo(this)) {
        effectiveDefense = effect.applyToValue(effectiveDefense);
      }
    }

    return effectiveDefense;
  }

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

  /// Calculate ranged expected hits for this regiment
  double calculateRangedExpectedHits() {
    // If unit has no barrage capability, it cannot shoot at all
    if (barrageValue == 0) {
      return 0.0;
    }

    // Start with base barrage value from special rules multiplied by stands
    int totalBarrage = barrageValue * stands;

    // Add +1 barrage if regiment has leader (only if unit can already shoot)
    final hasLeader = unit.specialRules
        .any((rule) => rule.name.toLowerCase().contains('leader'));
    if (hasLeader) {
      totalBarrage += 1;
    }

    // Calculate hit chance: volley / 6
    final volleyValue = unit.characteristics.volley;
    final hitChance = volleyValue / 6.0;

    // Calculate expected ranged hits
    return totalBarrage * hitChance;
  }

  /// Calculate cleave rating for this regiment with army context
  double calculateCleaveRating({List<Regiment>? armyRegiments}) {
    final hitVolume = calculateExpectedHitVolume(armyRegiments: armyRegiments);
    return hitVolume * cleaveValue;
  }

  /// Calculate ranged armor piercing rating for this regiment with army context
  double calculateRangedArmorPiercingRating() {
    final rangedHits = calculateRangedExpectedHits();
    return rangedHits * armorPiercingValue;
  }

  @override
  String toString() =>
      'Regiment(${unit.name}, stands: $stands, cost: $pointsCost, wounds: $totalWounds, cleave: $cleaveValue, barrage: $barrageValue, range: $barrageRange, armorPiercing: $armorPiercingValue, warlord: $isWarlord)';
}
