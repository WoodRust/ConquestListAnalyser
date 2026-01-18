import 'army_list.dart';
import 'reinforcement_metrics.dart';

/// Represents the calculated scores for an army list
class ListScore {
  final ArmyList armyList;
  final int totalWounds;
  final double pointsPerWound;
  final double expectedHitVolume;
  final double impactExpectedVolume;
  final double cleaveRating;
  final double rangedExpectedHits;
  final double rangedArmorPiercingRating;
  final int maxRange;
  final double averageSpeed;
  final double toughness;
  final double evasion;
  final double effectiveWoundsDefense; // Renamed from effectiveWounds
  final double effectiveWoundsDefenseResolve; // New field
  final double
      resolveImpactPercentage; // New field - percentage impact of resolve
  final double
      pointsPerEffectiveWoundDefense; // Points per effective wound (defense only)
  final double
      pointsPerEffectiveWoundDefenseResolve; // Points per effective wound (defense & resolve)
  final int scoringStands; // Total scoring stands in army (for objective control)
  final int magicCapability; // Total spell dice from Priest/Wizard units
  final int
      expectedHealingCapability; // Total wounds healable per turn (regeneration + healing spells)
  final ReinforcementMetrics?
      reinforcementMetrics; // Monte Carlo simulation of reinforcement timing
  final DateTime calculatedAt;

  const ListScore({
    required this.armyList,
    required this.totalWounds,
    required this.pointsPerWound,
    required this.expectedHitVolume,
    required this.impactExpectedVolume,
    required this.cleaveRating,
    required this.rangedExpectedHits,
    required this.rangedArmorPiercingRating,
    required this.maxRange,
    required this.averageSpeed,
    required this.toughness,
    required this.evasion,
    required this.effectiveWoundsDefense,
    required this.effectiveWoundsDefenseResolve,
    required this.resolveImpactPercentage,
    required this.pointsPerEffectiveWoundDefense,
    required this.pointsPerEffectiveWoundDefenseResolve,
    required this.scoringStands,
    required this.magicCapability,
    required this.expectedHealingCapability,
    this.reinforcementMetrics,
    required this.calculatedAt,
  });

  /// Create a copy of this ListScore with some fields updated
  ListScore copyWith({
    ArmyList? armyList,
    int? totalWounds,
    double? pointsPerWound,
    double? impactExpectedVolume,
    double? expectedHitVolume,
    double? cleaveRating,
    double? rangedExpectedHits,
    double? rangedArmorPiercingRating,
    int? maxRange,
    double? averageSpeed,
    double? toughness,
    double? evasion,
    double? effectiveWoundsDefense,
    double? effectiveWoundsDefenseResolve,
    double? resolveImpactPercentage,
    double? pointsPerEffectiveWoundDefense,
    double? pointsPerEffectiveWoundDefenseResolve,
    int? scoringStands,
    int? magicCapability,
    int? expectedHealingCapability,
    ReinforcementMetrics? reinforcementMetrics,
    DateTime? calculatedAt,
  }) {
    return ListScore(
      armyList: armyList ?? this.armyList,
      totalWounds: totalWounds ?? this.totalWounds,
      pointsPerWound: pointsPerWound ?? this.pointsPerWound,
      expectedHitVolume: expectedHitVolume ?? this.expectedHitVolume,
      impactExpectedVolume: impactExpectedVolume ?? this.impactExpectedVolume,
      cleaveRating: cleaveRating ?? this.cleaveRating,
      rangedExpectedHits: rangedExpectedHits ?? this.rangedExpectedHits,
      rangedArmorPiercingRating: rangedArmorPiercingRating ?? this.rangedArmorPiercingRating,
      maxRange: maxRange ?? this.maxRange,
      averageSpeed: averageSpeed ?? this.averageSpeed,
      toughness: toughness ?? this.toughness,
      evasion: evasion ?? this.evasion,
      effectiveWoundsDefense: effectiveWoundsDefense ?? this.effectiveWoundsDefense,
      effectiveWoundsDefenseResolve: effectiveWoundsDefenseResolve ?? this.effectiveWoundsDefenseResolve,
      resolveImpactPercentage: resolveImpactPercentage ?? this.resolveImpactPercentage,
      pointsPerEffectiveWoundDefense: pointsPerEffectiveWoundDefense ?? this.pointsPerEffectiveWoundDefense,
      pointsPerEffectiveWoundDefenseResolve: pointsPerEffectiveWoundDefenseResolve ?? this.pointsPerEffectiveWoundDefenseResolve,
      scoringStands: scoringStands ?? this.scoringStands,
      magicCapability: magicCapability ?? this.magicCapability,
      expectedHealingCapability: expectedHealingCapability ?? this.expectedHealingCapability,
      reinforcementMetrics: reinforcementMetrics ?? this.reinforcementMetrics,
      calculatedAt: calculatedAt ?? this.calculatedAt,
    );
  }

  /// Creates a ListScore from JSON data
  factory ListScore.fromJson(Map<String, dynamic> json) {
    return ListScore(
      armyList: ArmyList.fromJson(json['armyList']),
      totalWounds: json['totalWounds'] as int,
      pointsPerWound: (json['pointsPerWound'] as num).toDouble(),
      expectedHitVolume: (json['expectedHitVolume'] as num).toDouble(),
      impactExpectedVolume: (json['impactExpectedVolume'] as num?)?.toDouble() ?? 0.0,
      cleaveRating: (json['cleaveRating'] as num).toDouble(),
      rangedExpectedHits: (json['rangedExpectedHits'] as num).toDouble(),
      rangedArmorPiercingRating:
          (json['rangedArmorPiercingRating'] as num).toDouble(),
      maxRange: json['maxRange'] as int,
      averageSpeed: (json['averageSpeed'] as num).toDouble(),
      toughness: (json['toughness'] as num).toDouble(),
      evasion: (json['evasion'] as num).toDouble(),
      effectiveWoundsDefense:
          (json['effectiveWoundsDefense'] as num).toDouble(),
      effectiveWoundsDefenseResolve:
          (json['effectiveWoundsDefenseResolve'] as num).toDouble(),
      resolveImpactPercentage:
          (json['resolveImpactPercentage'] as num).toDouble(),
      pointsPerEffectiveWoundDefense:
          (json['pointsPerEffectiveWoundDefense'] as num).toDouble(),
      pointsPerEffectiveWoundDefenseResolve:
          (json['pointsPerEffectiveWoundDefenseResolve'] as num).toDouble(),
      scoringStands: json['scoringStands'] as int,
      magicCapability: (json['magicCapability'] as int?) ?? 0,
      expectedHealingCapability:
          (json['expectedHealingCapability'] as int?) ?? 0,
      reinforcementMetrics: json['reinforcementMetrics'] != null
          ? ReinforcementMetrics.fromJson(json['reinforcementMetrics'])
          : null,
      calculatedAt: DateTime.parse(json['calculatedAt'] as String),
    );
  }

  /// Converts ListScore to JSON data
  Map<String, dynamic> toJson() {
    return {
      'armyList': armyList.toJson(),
      'totalWounds': totalWounds,
      'pointsPerWound': pointsPerWound,
      'expectedHitVolume': expectedHitVolume,
      'impactExpectedVolume': impactExpectedVolume,
      'cleaveRating': cleaveRating,
      'rangedExpectedHits': rangedExpectedHits,
      'rangedArmorPiercingRating': rangedArmorPiercingRating,
      'maxRange': maxRange,
      'averageSpeed': averageSpeed,
      'toughness': toughness,
      'evasion': evasion,
      'effectiveWoundsDefense': effectiveWoundsDefense,
      'effectiveWoundsDefenseResolve': effectiveWoundsDefenseResolve,
      'resolveImpactPercentage': resolveImpactPercentage,
      'pointsPerEffectiveWoundDefense': pointsPerEffectiveWoundDefense,
      'pointsPerEffectiveWoundDefenseResolve':
          pointsPerEffectiveWoundDefenseResolve,
      'scoringStands': scoringStands,
      'magicCapability': magicCapability,
      'expectedHealingCapability': expectedHealingCapability,
      'reinforcementMetrics': reinforcementMetrics?.toJson(),
      'calculatedAt': calculatedAt.toIso8601String(),
    };
  }

  /// Creates a formatted summary string for sharing
  String toShareableText() {
    return '''
Army List Analysis: ${armyList.name}
Faction: ${armyList.faction}
Points: ${armyList.totalPoints}/${armyList.pointsLimit}

SCORES:
Total Wounds: $totalWounds
Points per Wound: ${pointsPerWound.toStringAsFixed(2)}
Scoring Stands: $scoringStands
Impact Expected Volume: ${impactExpectedVolume.toStringAsFixed(1)}
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
Resolve Impact: ${resolveImpactPercentage.toStringAsFixed(1)}%
Points per Eff. Wound (Def): ${pointsPerEffectiveWoundDefense.toStringAsFixed(2)}
Points per Eff. Wound (D&R): ${pointsPerEffectiveWoundDefenseResolve.toStringAsFixed(2)}
Magic Capability: $magicCapability spell dice
Expected Healing Capability: $expectedHealingCapability wounds/turn

${reinforcementMetrics != null ? reinforcementMetrics!.toShareableText() : ''}
Calculated: ${calculatedAt.toString().split('.')[0]}
''';
  }

  @override
  String toString() =>
      'ListScore(wounds: $totalWounds, ppw: ${pointsPerWound.toStringAsFixed(2)}, ehv: ${expectedHitVolume.toStringAsFixed(1)}, cleave: ${cleaveRating.toStringAsFixed(1)}, ranged: ${rangedExpectedHits.toStringAsFixed(1)}, armorPiercing: ${rangedArmorPiercingRating.toStringAsFixed(1)}, maxRange: $maxRange, avgSpeed: ${averageSpeed.toStringAsFixed(1)}, toughness: ${toughness.toStringAsFixed(1)}, evasion: ${evasion.toStringAsFixed(1)}, effectiveWoundsDefense: ${effectiveWoundsDefense.toStringAsFixed(1)}, effectiveWoundsDefenseResolve: ${effectiveWoundsDefenseResolve.toStringAsFixed(1)}, resolveImpact: ${resolveImpactPercentage.toStringAsFixed(1)}%, ppEffWoundDef: ${pointsPerEffectiveWoundDefense.toStringAsFixed(2)}, ppEffWoundD&R: ${pointsPerEffectiveWoundDefenseResolve.toStringAsFixed(2)})';
}
