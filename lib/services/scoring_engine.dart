import '../models/army_list.dart';
import '../models/list_score.dart';
import '../models/regiment.dart';
import '../models/unit.dart';
import 'army_effect_manager.dart';

/// Service for calculating army list scores and statistics
class ScoringEngine {
  /// Calculate comprehensive scores for an army list
  ListScore calculateScores(ArmyList armyList) {
    // Get army-wide effects (supremacy abilities, etc.)
    final armyEffects = ArmyEffectManager.getActiveEffects(armyList);

    // Calculate basic metrics
    final totalWounds = _calculateTotalWounds(armyList);
    final pointsPerWound =
        totalWounds > 0 ? armyList.totalPoints / totalWounds : 0.0;

    // Calculate combat metrics
    final expectedHitVolume = _calculateTotalExpectedHitVolume(armyList);
    final cleaveRating = _calculateTotalCleaveRating(armyList);
    final rangedExpectedHits = _calculateTotalRangedExpectedHits(armyList);
    final rangedArmorPiercingRating =
        _calculateTotalRangedArmorPiercingRating(armyList);
    final maxRange = _calculateMaxRange(armyList);

    // Calculate survivability metrics
    final averageSpeed = _calculateAverageSpeed(armyList);
    final toughness = _calculateToughness(armyList, armyEffects);
    final evasion = _calculateEvasion(armyList, armyEffects);

    // Calculate effective wounds metrics
    final effectiveWoundsDefense =
        _calculateEffectiveWoundsDefense(armyList, armyEffects);
    final effectiveWoundsDefenseResolve =
        _calculateEffectiveWoundsDefenseResolve(armyList, armyEffects);
    final resolveImpactPercentage = _calculateResolveImpactPercentage(
        effectiveWoundsDefense, effectiveWoundsDefenseResolve);

    return ListScore(
      armyList: armyList,
      totalWounds: totalWounds,
      pointsPerWound: pointsPerWound,
      expectedHitVolume: expectedHitVolume,
      cleaveRating: cleaveRating,
      rangedExpectedHits: rangedExpectedHits,
      rangedArmorPiercingRating: rangedArmorPiercingRating,
      maxRange: maxRange,
      averageSpeed: averageSpeed,
      toughness: toughness,
      evasion: evasion,
      effectiveWoundsDefense: effectiveWoundsDefense,
      effectiveWoundsDefenseResolve: effectiveWoundsDefenseResolve,
      resolveImpactPercentage: resolveImpactPercentage,
      calculatedAt: DateTime.now(),
    );
  }

  /// Calculate total wounds across all regiments
  /// Includes: all non-character regiments + character monsters
  int _calculateTotalWounds(ArmyList armyList) {
    return armyList.regiments.fold(0, (total, regiment) {
      // Include non-character regiments
      if (regiment.unit.regimentClass != 'character') {
        return total + regiment.totalWounds;
      }
      // Include character monsters
      if (regiment.unit.regimentClass == 'character' &&
          regiment.unit.type == 'monster') {
        return total + regiment.totalWounds;
      }
      // Exclude regular characters
      return total;
    });
  }

  /// Calculate total expected hit volume across all regiments
  double _calculateTotalExpectedHitVolume(ArmyList armyList) {
    return armyList.regiments.fold(0.0, (total, regiment) {
      return total + _calculateRegimentHitVolume(regiment);
    });
  }

  /// Calculate total cleave rating across all regiments
  double _calculateTotalCleaveRating(ArmyList armyList) {
    return armyList.regiments.fold(0.0, (total, regiment) {
      return total + regiment.cleaveRating;
    });
  }

  /// Calculate total ranged expected hits across all regiments
  double _calculateTotalRangedExpectedHits(ArmyList armyList) {
    return armyList.regiments.fold(0.0, (total, regiment) {
      return total + regiment.rangedExpectedHits;
    });
  }

  /// Calculate total ranged armor piercing rating across all regiments
  double _calculateTotalRangedArmorPiercingRating(ArmyList armyList) {
    return armyList.regiments.fold(0.0, (total, regiment) {
      return total + regiment.rangedArmorPiercingRating;
    });
  }

  /// Calculate maximum range across all regiments
  int _calculateMaxRange(ArmyList armyList) {
    return armyList.regiments.fold(0, (max, regiment) {
      final regimentMaxRange = regiment.barrageRange;
      return regimentMaxRange > max ? regimentMaxRange : max;
    });
  }

  /// Calculate average speed across all regiments
  /// Excludes characters but includes character monsters
  double _calculateAverageSpeed(ArmyList armyList) {
    final regimentsWithSpeed = armyList.regiments.where((regiment) {
      // Include non-character regiments
      if (regiment.unit.regimentClass != 'character') {
        return true;
      }
      // Include character monsters
      if (regiment.unit.regimentClass == 'character' &&
          regiment.unit.type == 'monster') {
        return true;
      }
      // Exclude regular characters
      return false;
    }).toList();

    if (regimentsWithSpeed.isEmpty) return 0.0;

    final totalSpeed = regimentsWithSpeed.fold(0, (total, regiment) {
      return total + (regiment.unit.characteristics.march ?? 0);
    });

    return totalSpeed / regimentsWithSpeed.length;
  }

  /// Calculate toughness score (weighted average defense)
  /// Excludes characters but includes character monsters
  double _calculateToughness(
      ArmyList armyList, List<CharacteristicModifier> armyEffects) {
    final regimentsForToughness = armyList.regiments.where((regiment) {
      // Include non-character regiments
      if (regiment.unit.regimentClass != 'character') {
        return true;
      }
      // Include character monsters
      if (regiment.unit.regimentClass == 'character' &&
          regiment.unit.type == 'monster') {
        return true;
      }
      // Exclude regular characters
      return false;
    }).toList();

    if (regimentsForToughness.isEmpty) return 0.0;

    int totalDefenseWounds = 0;
    int totalWounds = 0;

    for (final regiment in regimentsForToughness) {
      // Get effective defense considering army effects
      final effectiveDefense = ArmyEffectManager.getEffectiveCharacteristic(
          regiment, 'defense', armyEffects);

      final regimentWounds = regiment.totalWounds;
      totalDefenseWounds += effectiveDefense * regimentWounds;
      totalWounds += regimentWounds;
    }

    return totalWounds > 0 ? totalDefenseWounds / totalWounds : 0.0;
  }

  /// Calculate evasion score (weighted average evasion)
  /// Excludes characters but includes character monsters
  double _calculateEvasion(
      ArmyList armyList, List<CharacteristicModifier> armyEffects) {
    final regimentsForEvasion = armyList.regiments.where((regiment) {
      // Include non-character regiments
      if (regiment.unit.regimentClass != 'character') {
        return true;
      }
      // Include character monsters
      if (regiment.unit.regimentClass == 'character' &&
          regiment.unit.type == 'monster') {
        return true;
      }
      // Exclude regular characters
      return false;
    }).toList();

    if (regimentsForEvasion.isEmpty) return 0.0;

    int totalEvasionWounds = 0;
    int totalWounds = 0;

    for (final regiment in regimentsForEvasion) {
      // Get effective evasion considering army effects
      final effectiveEvasion = ArmyEffectManager.getEffectiveCharacteristic(
          regiment, 'evasion', armyEffects);

      final regimentWounds = regiment.totalWounds;
      totalEvasionWounds += effectiveEvasion * regimentWounds;
      totalWounds += regimentWounds;
    }

    return totalWounds > 0 ? totalEvasionWounds / totalWounds : 0.0;
  }

  /// Calculate effective wounds using highest of defense or evasion per regiment
  /// Excludes characters (but includes character monsters)
  /// Formula: Sum of (Regiment Wounds × (6 / (6 - Max(Defense, Evasion))))
  double _calculateEffectiveWoundsDefense(
      ArmyList armyList, List<CharacteristicModifier> armyEffects) {
    // Get regiments for effective wounds calculation: non-characters + character monsters
    final regimentsForEffectiveWounds = armyList.regiments.where((regiment) {
      // Include non-character regiments
      if (regiment.unit.regimentClass != 'character') {
        return true;
      }
      // Include character monsters
      if (regiment.unit.regimentClass == 'character' &&
          regiment.unit.type == 'monster') {
        return true;
      }
      // Exclude regular characters
      return false;
    }).toList();

    // Return 0 if no regiments
    if (regimentsForEffectiveWounds.isEmpty) return 0.0;

    double totalEffectiveWounds = 0.0;
    for (final regiment in regimentsForEffectiveWounds) {
      final regimentWounds = regiment.totalWounds;

      // Get effective defense and evasion considering army effects
      final effectiveDefense = ArmyEffectManager.getEffectiveCharacteristic(
          regiment, 'defense', armyEffects);
      final effectiveEvasion = ArmyEffectManager.getEffectiveCharacteristic(
          regiment, 'evasion', armyEffects);

      // Use the highest of defense or evasion
      final bestDefensiveValue = effectiveDefense > effectiveEvasion
          ? effectiveDefense
          : effectiveEvasion;

      // Calculate multiplier: 6 / (6 - bestDefensiveValue)
      // Cap defensive value at 5 to avoid division by zero
      final cappedDefensiveValue =
          bestDefensiveValue > 5 ? 5 : bestDefensiveValue;
      final multiplier = 6.0 / (6.0 - cappedDefensiveValue);

      // Add this regiment's effective wounds to the total
      totalEffectiveWounds += regimentWounds * multiplier;
    }

    return totalEffectiveWounds;
  }

  /// Calculate effective wounds considering both defense and resolve
  /// Formula: Sum of (Regiment Wounds ÷ (Defense Failure Rate × Wounds per Failed Defense))
  /// Where:
  /// - Defense Failure Rate = (6 - Best Defense) / 6
  /// - Wounds per Failed Defense = 1 + (6 - Resolve) / 6
  /// - For Oblivious units: Wounds per Failed Defense = 1 + ((6 - Resolve) / 6) / 2
  double _calculateEffectiveWoundsDefenseResolve(
      ArmyList armyList, List<CharacteristicModifier> armyEffects) {
    // Get regiments for effective wounds calculation: non-characters + character monsters
    final regimentsForEffectiveWounds = armyList.regiments.where((regiment) {
      // Include non-character regiments
      if (regiment.unit.regimentClass != 'character') {
        return true;
      }
      // Include character monsters
      if (regiment.unit.regimentClass == 'character' &&
          regiment.unit.type == 'monster') {
        return true;
      }
      // Exclude regular characters
      return false;
    }).toList();

    // Return 0 if no regiments
    if (regimentsForEffectiveWounds.isEmpty) return 0.0;

    double totalEffectiveWounds = 0.0;
    for (final regiment in regimentsForEffectiveWounds) {
      final regimentWounds = regiment.totalWounds;

      // Get effective characteristics considering army effects
      final effectiveDefense = ArmyEffectManager.getEffectiveCharacteristic(
          regiment, 'defense', armyEffects);
      final effectiveEvasion = ArmyEffectManager.getEffectiveCharacteristic(
          regiment, 'evasion', armyEffects);
      final effectiveResolve = ArmyEffectManager.getEffectiveCharacteristic(
          regiment, 'resolve', armyEffects);

      // Use the highest of defense or evasion
      final bestDefensiveValue = effectiveDefense > effectiveEvasion
          ? effectiveDefense
          : effectiveEvasion;

      // Cap values to prevent division by zero and impossible probabilities
      final cappedDefensiveValue =
          bestDefensiveValue > 5 ? 5 : bestDefensiveValue;
      final cappedResolve = effectiveResolve > 6 ? 6 : effectiveResolve;

      // Calculate defense failure rate: (6 - defense) / 6
      final defenseFailureRate = (6.0 - cappedDefensiveValue) / 6.0;

      // Check if the unit has the Oblivious special rule
      final hasOblivious = regiment.unit.specialRules
          .any((rule) => rule.name.toLowerCase() == 'oblivious');

      // Calculate wounds per failed defense
      double woundsPerFailedDefense;
      if (hasOblivious) {
        // For Oblivious units: they take only 1 wound for every 2 failed morale tests
        // This means the effective wound rate from failed resolve is halved
        // Formula: 1 + ((6 - resolve) / 6) / 2
        final baseFailedResolveRate = (6.0 - cappedResolve) / 6.0;
        final obliviousModifiedRate = baseFailedResolveRate / 2.0;
        woundsPerFailedDefense = 1.0 + obliviousModifiedRate;
      } else {
        // Standard formula: 1 + (6 - resolve) / 6
        woundsPerFailedDefense = 1.0 + (6.0 - cappedResolve) / 6.0;
      }

      // Calculate combined wound rate
      final combinedWoundRate = defenseFailureRate * woundsPerFailedDefense;

      // Calculate effective wounds: raw wounds ÷ combined wound rate
      // If combined wound rate is 0 (perfect defense), treat as infinite effective wounds
      // but cap at a reasonable maximum (1000x base wounds)
      final effectiveWounds = combinedWoundRate > 0.0
          ? regimentWounds / combinedWoundRate
          : regimentWounds * 1000.0;

      totalEffectiveWounds += effectiveWounds;
    }

    return totalEffectiveWounds;
  }

  /// Calculate the percentage impact of resolve on effective wounds
  /// Formula: ((Defense&Resolve - Defense) / Defense) × 100
  /// Negative values indicate resolve makes the army less survivable
  double _calculateResolveImpactPercentage(
      double effectiveWoundsDefense, double effectiveWoundsDefenseResolve) {
    // Handle edge case where defense-only effective wounds is 0
    if (effectiveWoundsDefense == 0.0) return 0.0;

    // Calculate percentage difference
    return ((effectiveWoundsDefenseResolve - effectiveWoundsDefense) /
            effectiveWoundsDefense) *
        100.0;
  }

  /// Calculate expected hit volume for a single regiment
  double _calculateRegimentHitVolume(Regiment regiment) {
    // Use the regiment's own expectedHitVolume calculation
    return regiment.expectedHitVolume;
  }
}
