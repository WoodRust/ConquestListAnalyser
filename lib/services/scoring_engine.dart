import '../models/army_list.dart';
import '../models/regiment.dart';
import '../models/list_score.dart';

/// Service for calculating army list scores
class ScoringEngine {
  /// Calculate all scores for an army list
  ListScore calculateScores(ArmyList armyList) {
    final totalWounds = _calculateTotalWounds(armyList);
    final pointsPerWound = _calculatePointsPerWound(armyList, totalWounds);
    final expectedHitVolume = _calculateExpectedHitVolume(armyList);
    final cleaveRating = _calculateCleaveRating(armyList);

    return ListScore(
      armyList: armyList,
      totalWounds: totalWounds,
      pointsPerWound: pointsPerWound,
      expectedHitVolume: expectedHitVolume,
      cleaveRating: cleaveRating,
      calculatedAt: DateTime.now(),
    );
  }

  /// Calculate total wounds across all regiments
  int _calculateTotalWounds(ArmyList armyList) {
    return armyList.regiments.fold(0, (total, regiment) {
      // Exclude characters from wound calculation
      if (regiment.unit.regimentClass == 'character') {
        return total;
      }
      return total + regiment.totalWounds;
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

  /// Calculate expected hit volume for a single regiment
  double _calculateRegimentHitVolume(Regiment regiment) {
    // Use the regiment's own expectedHitVolume calculation
    return regiment.expectedHitVolume;
  }
}
