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
    final effectiveWounds = _calculateEffectiveWounds(armyList, armyEffects);

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
      effectiveWounds: effectiveWounds,
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
      // Pass army context for special rule interactions
      return total +
          regiment.calculateExpectedHitVolume(
              armyRegiments: armyList.regiments);
    });
  }

  /// Calculate total cleave rating for the entire list
  double _calculateCleaveRating(ArmyList armyList) {
    return armyList.regiments.fold(0.0, (total, regiment) {
      // Include ALL regiments (including characters) in cleave rating calculation
      // Pass army context for special rule interactions
      return total +
          regiment.calculateCleaveRating(armyRegiments: armyList.regiments);
    });
  }

  /// Calculate total ranged expected hits for the entire list
  double _calculateRangedExpectedHits(ArmyList armyList) {
    return armyList.regiments.fold(0.0, (total, regiment) {
      // Include ALL regiments (including characters) in ranged calculation
      return total + regiment.calculateRangedExpectedHits();
    });
  }

  /// Calculate total ranged armor piercing rating for the entire list
  double _calculateRangedArmorPiercingRating(ArmyList armyList) {
    return armyList.regiments.fold(0.0, (total, regiment) {
      // Include ALL regiments (including characters) in ranged armor piercing calculation
      return total + regiment.calculateRangedArmorPiercingRating();
    });
  }

  /// Calculate maximum barrage range across all regiments
  int _calculateMaxRange(ArmyList armyList) {
    if (armyList.regiments.isEmpty) return 0;
    return armyList.regiments.fold(0, (maxRange, regiment) {
      final regimentRange = regiment.barrageRange;
      return regimentRange > maxRange ? regimentRange : maxRange;
    });
  }

  /// Calculate average speed (march characteristic) across all regiments
  /// Includes: non-character regiments + character monsters
  /// Excludes: regular characters
  double _calculateAverageSpeed(ArmyList armyList) {
    // Get regiments for speed calculation: non-characters + character monsters
    final regimentsForSpeed = armyList.regiments.where((regiment) {
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
    if (regimentsForSpeed.isEmpty) return 0.0;

    // Calculate total march value across all regiments
    final totalMarch = regimentsForSpeed.fold(0, (total, regiment) {
      // Use march characteristic from unit, default to 0 if null
      final marchValue = regiment.unit.characteristics.march ?? 0;
      return total + marchValue;
    });

    // Return average march value
    return totalMarch / regimentsForSpeed.length;
  }

  /// Calculate toughness (wound-weighted average defense) for the entire list
  /// Excludes characters (but includes character monsters)
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

    // Return 0 if no regiments
    if (regimentsForToughness.isEmpty) return 0.0;

    // Calculate total defense weighted by wounds
    double totalDefenseWeighted = 0.0;
    int totalWounds = 0;

    for (final regiment in regimentsForToughness) {
      final regimentWounds = regiment.totalWounds;
      // Get effective defense considering army effects
      final effectiveDefense = ArmyEffectManager.getEffectiveCharacteristic(
          regiment, 'defense', armyEffects);
      totalDefenseWeighted += effectiveDefense * regimentWounds;
      totalWounds += regimentWounds;
    }

    // Return wound-weighted average defense
    if (totalWounds == 0) return 0.0;
    return totalDefenseWeighted / totalWounds;
  }

  /// Calculate evasion (wound-weighted average evasion) for the entire list
  /// Excludes characters (but includes character monsters)
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

    // Return 0 if no regiments
    if (regimentsForEvasion.isEmpty) return 0.0;

    // Calculate total evasion weighted by wounds
    double totalEvasionWeighted = 0.0;
    int totalWounds = 0;

    for (final regiment in regimentsForEvasion) {
      final regimentWounds = regiment.totalWounds;
      // Get effective evasion considering army effects
      final effectiveEvasion = ArmyEffectManager.getEffectiveCharacteristic(
          regiment, 'evasion', armyEffects);
      totalEvasionWeighted += effectiveEvasion * regimentWounds;
      totalWounds += regimentWounds;
    }

    // Return wound-weighted average evasion
    if (totalWounds == 0) return 0.0;
    return totalEvasionWeighted / totalWounds;
  }

  /// Calculate effective wounds using highest of defense or evasion per regiment
  /// Excludes characters (but includes character monsters)
  /// Formula: Sum of (Regiment Wounds × (6 / (6 - Max(Defense, Evasion))))
  double _calculateEffectiveWounds(
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

  /// Calculate expected hit volume for a single regiment
  double _calculateRegimentHitVolume(Regiment regiment) {
    // Use the regiment's own expectedHitVolume calculation
    return regiment.expectedHitVolume;
  }
}
