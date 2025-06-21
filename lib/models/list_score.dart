import 'army_list.dart';

/// Represents the calculated scores for an army list
class ListScore {
  final ArmyList armyList;
  final int totalWounds;
  final double pointsPerWound;
  final double expectedHitVolume;
  final double cleaveRating;
  final DateTime calculatedAt;

  const ListScore({
    required this.armyList,
    required this.totalWounds,
    required this.pointsPerWound,
    required this.expectedHitVolume,
    required this.cleaveRating,
    required this.calculatedAt,
  });

  /// Creates a formatted summary string for sharing
  String toShareableText() {
    return '''
Army List Analysis: ${armyList.name}
Faction: ${armyList.faction}
Points: ${armyList.totalPoints}/${armyList.pointsLimit}

SCORES:
Total Wounds: $totalWounds
Points per Wound: ${pointsPerWound.toStringAsFixed(2)}
Expected Hit Volume: ${expectedHitVolume.toStringAsFixed(1)}
Cleave Rating: ${cleaveRating.toStringAsFixed(1)}

Calculated: ${calculatedAt.toString().split('.')[0]}
''';
  }

  @override
  String toString() =>
      'ListScore(wounds: $totalWounds, ppw: ${pointsPerWound.toStringAsFixed(2)}, ehv: ${expectedHitVolume.toStringAsFixed(1)}, cleave: ${cleaveRating.toStringAsFixed(1)})';
}
