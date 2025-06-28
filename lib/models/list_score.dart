import 'army_list.dart';

/// Represents the calculated scores for an army list
class ListScore {
  final ArmyList armyList;
  final int totalWounds;
  final double pointsPerWound;
  final double expectedHitVolume;
  final double cleaveRating;
  final double rangedExpectedHits;
  final double rangedArmorPiercingRating;
  final int maxRange;
  final double averageSpeed;
  final double toughness;
  final double evasion;
  final double effectiveWoundsDefense; // Renamed from effectiveWounds
  final double effectiveWoundsDefenseResolve; // New field
  final DateTime calculatedAt;

  const ListScore({
    required this.armyList,
    required this.totalWounds,
    required this.pointsPerWound,
    required this.expectedHitVolume,
    required this.cleaveRating,
    required this.rangedExpectedHits,
    required this.rangedArmorPiercingRating,
    required this.maxRange,
    required this.averageSpeed,
    required this.toughness,
    required this.evasion,
    required this.effectiveWoundsDefense,
    required this.effectiveWoundsDefenseResolve,
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
Ranged Expected Hits: ${rangedExpectedHits.toStringAsFixed(1)}
Ranged Armor Piercing: ${rangedArmorPiercingRating.toStringAsFixed(1)}
Max Range: $maxRange
Average Speed: ${averageSpeed.toStringAsFixed(1)}
Toughness: ${toughness.toStringAsFixed(1)}
Evasion: ${evasion.toStringAsFixed(1)}
Effective Wounds (Defense): ${effectiveWoundsDefense.toStringAsFixed(1)}
Effective Wounds (Defense & Resolve): ${effectiveWoundsDefenseResolve.toStringAsFixed(1)}

Calculated: ${calculatedAt.toString().split('.')[0]}
''';
  }

  @override
  String toString() =>
      'ListScore(wounds: $totalWounds, ppw: ${pointsPerWound.toStringAsFixed(2)}, ehv: ${expectedHitVolume.toStringAsFixed(1)}, cleave: ${cleaveRating.toStringAsFixed(1)}, ranged: ${rangedExpectedHits.toStringAsFixed(1)}, armorPiercing: ${rangedArmorPiercingRating.toStringAsFixed(1)}, maxRange: $maxRange, avgSpeed: ${averageSpeed.toStringAsFixed(1)}, toughness: ${toughness.toStringAsFixed(1)}, evasion: ${evasion.toStringAsFixed(1)}, effectiveWoundsDefense: ${effectiveWoundsDefense.toStringAsFixed(1)}, effectiveWoundsDefenseResolve: ${effectiveWoundsDefenseResolve.toStringAsFixed(1)})';
}
