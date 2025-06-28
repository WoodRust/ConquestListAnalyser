import '../models/army_list.dart';
import '../models/regiment.dart';
import '../models/list_score.dart';
import '../models/unit.dart';
import 'army_effect_manager.dart';

/// Service for calculating army list scores
class ScoringEngine {
  /// Calculate all scores for an army list
  ListScore calculateScores(ArmyList armyList) {
    // Get active army effects first
    final armyEffects = ArmyEffectManager.getActiveEffects(armyList);

    final totalWounds = _calculateTotalWounds(armyList);
    final pointsPerWound = _calculatePointsPerWound(armyList, totalWounds);
    final expectedHitVolume = _calculateExpectedHitVolume(armyList);
    final cleaveRating = _calculateCleaveRating(armyList);
    final rangedExpectedHits = _calculateRangedExpectedHits(armyList);
    final rangedArmorPiercingRating =
        _calculateRangedArmorPiercingRating(armyList);
    final maxRange = _calculateMaxRange(armyList);
    final averageSpeed = _calculateAverageSpeed(armyList);
    final toughness = _calculateToughness(armyList, armyEffects);
    final evasion = _calculateEvasion(armyList, armyEffects);
    final effectiveWoundsDefense =
        _calculateEffectiveWoundsDefense(armyList, armyEffects);
    final effectiveWoundsDefenseResolve =
        _calculateEffectiveWoundsDefenseResolve(armyList, armyEffects);

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

  /// Calculate points per wound for the entire list
  double _calculatePointsPerWound(ArmyList armyList, int totalWounds) {
    if (totalWounds == 0) return 0.0;
    return armyList.totalPoints / totalWounds;
  }

  /// Calculate expected hit volume for the entire list
  double _calculateExpectedHitVolume(ArmyList armyList) {
    return armyList.regiments.fold(0.0, (total, regiment) {
      // Include ALL regiments (including characters) in hit volume calculation
      return total + _calculateRegimentHitVolume(regiment);
    });
  }

  /// Calculate cleave rating for the entire list
  double _calculateCleaveRating(ArmyList armyList) {
    return armyList.regiments.fold(0.0, (total, regiment) {
      return total + regiment.cleaveRating;
    });
  }

  /// Calculate ranged expected hits for the entire list
  double _calculateRangedExpectedHits(ArmyList armyList) {
    return armyList.regiments.fold(0.0, (total, regiment) {
      return total + regiment.rangedExpectedHits;
    });
  }

  /// Calculate ranged armor piercing rating for the entire list
  double _calculateRangedArmorPiercingRating(ArmyList armyList) {
    return armyList.regiments.fold(0.0, (total, regiment) {
      return total + regiment.rangedArmorPiercingRating;
    });
  }

  /// Calculate maximum range for the entire list
  int _calculateMaxRange(ArmyList armyList) {
    return armyList.regiments.fold(0, (max, regiment) {
      final regimentRange = regiment.barrageRange;
      return regimentRange > max ? regimentRange : max;
    });
  }

  /// Calculate average speed for the entire list
  /// Excludes all characters (including character monsters)
  double _calculateAverageSpeed(ArmyList armyList) {
    final nonCharacterRegiments = armyList.regiments.where((regiment) {
      return regiment.unit.regimentClass != 'character';
    }).toList();

    if (nonCharacterRegiments.isEmpty) return 0.0;

    final totalMarch = nonCharacterRegiments.fold(0.0, (total, regiment) {
      final march = regiment.unit.characteristics.march ?? 0;
      return total + march;
    });

    return totalMarch / nonCharacterRegiments.length;
  }

  /// Calculate toughness (defense-based survivability)
  /// Weighted average defense across all regiments by wound count
  /// Includes: all non-character regiments + character monsters
  double _calculateToughness(
      ArmyList armyList, List<CharacteristicModifier> armyEffects) {
    // Get regiments for toughness calculation: non-characters + character monsters
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

    double totalDefenseWounds = 0.0;
    int totalWounds = 0;

    for (final regiment in regimentsForToughness) {
      final regimentWounds = regiment.totalWounds;
      // Get effective defense considering army effects
      final effectiveDefense = ArmyEffectManager.getEffectiveCharacteristic(
          regiment, 'defense', armyEffects);

      totalDefenseWounds += effectiveDefense * regimentWounds;
      totalWounds += regimentWounds;
    }

    return totalWounds > 0 ? totalDefenseWounds / totalWounds : 0.0;
  }

  /// Calculate evasion (evasion-based survivability)
  /// Weighted average evasion across all regiments by wound count
  /// Includes: all non-character regiments + character monsters
  double _calculateEvasion(
      ArmyList armyList, List<CharacteristicModifier> armyEffects) {
    // Get regiments for evasion calculation: non-characters + character monsters
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

    double totalEvasionWounds = 0.0;
    int totalWounds = 0;

    for (final regiment in regimentsForEvasion) {
      final regimentWounds = regiment.totalWounds;
      // Get effective evasion considering army effects
      final effectiveEvasion = ArmyEffectManager.getEffectiveCharacteristic(
          regiment, 'evasion', armyEffects);

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

      // Calculate wounds per failed defense: 1 + (6 - resolve) / 6
      final woundsPerFailedDefense = 1.0 + (6.0 - cappedResolve) / 6.0;

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

  /// Calculate expected hit volume for a single regiment
  double _calculateRegimentHitVolume(Regiment regiment) {
    // Use the regiment's own expectedHitVolume calculation
    return regiment.expectedHitVolume;
  }
}
