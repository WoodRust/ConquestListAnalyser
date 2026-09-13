import 'unit.dart';

/// Represents a specific instance of a unit in an army list
class Regiment {
  final Unit unit;
  final int stands;
  final int pointsCost;
  final List<String> upgrades;
  final List<AuxiliaryProfile> auxiliaryStands;
  final bool isWarlord;
  final String? sourceGroupId;
  final String? sourceGroupName;
  final int? sourceGroupPoints;

  const Regiment({
    required this.unit,
    required this.stands,
    required this.pointsCost,
    this.upgrades = const [],
    this.auxiliaryStands = const [],
    this.isWarlord = false,
    this.sourceGroupId,
    this.sourceGroupName,
    this.sourceGroupPoints,
  });

  /// Creates a Regiment from JSON data
  factory Regiment.fromJson(Map<String, dynamic> json) {
    return Regiment(
      unit: Unit.fromJson(json['unit']),
      stands: json['stands'] as int,
      pointsCost: json['pointsCost'] as int,
      upgrades: List<String>.from(json['upgrades'] ?? []),
      auxiliaryStands: (json['auxiliaryStands'] as List? ?? [])
          .map((stand) => AuxiliaryProfile.fromJson(stand))
          .toList(),
      isWarlord: json['isWarlord'] as bool? ?? false,
      sourceGroupId: json['sourceGroupId'] as String?,
      sourceGroupName: json['sourceGroupName'] as String?,
      sourceGroupPoints: json['sourceGroupPoints'] as int?,
    );
  }

  /// Converts Regiment to JSON data
  Map<String, dynamic> toJson() {
    return {
      'unit': unit.toJson(),
      'stands': stands,
      'pointsCost': pointsCost,
      'upgrades': upgrades,
      'auxiliaryStands':
          auxiliaryStands.map((stand) => stand.toJson()).toList(),
      'isWarlord': isWarlord,
      'sourceGroupId': sourceGroupId,
      'sourceGroupName': sourceGroupName,
      'sourceGroupPoints': sourceGroupPoints,
    };
  }

  /// Total wounds for this regiment, including attached auxiliary stands.
  int get totalWounds =>
      unit.woundsPerStand * stands +
      auxiliaryStands.fold(
          0, (total, stand) => total + stand.characteristics.wounds);

  /// Number of stands contributing to objective control.
  int get scoringStandCount => stands + auxiliaryStands.length;

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

  /// Impact value for this regiment from numeric special rules
  int get impactValue => unit.numericSpecialRules['impact'] as int? ?? 0;

  /// Calculate cleave rating using each stand profile's Cleave value.
  double get cleaveRating {
    var rating = _expectedHits(
          unit.characteristics,
          unit.specialRules,
          stands,
          hasLeader: true,
        ) *
        cleaveValue;
    for (final auxiliary in auxiliaryStands) {
      rating += _expectedHits(
            auxiliary.characteristics,
            auxiliary.specialRules,
            1,
          ) *
          (auxiliary.numericSpecialRules['cleave'] as int? ?? 0);
    }
    return rating;
  }

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

  /// Calculate expected hit volume for this regiment, including auxiliaries.
  double calculateExpectedHitVolume({List<Regiment>? armyRegiments}) {
    var expectedHits = _expectedHits(
      unit.characteristics,
      unit.specialRules,
      stands,
      hasLeader: true,
    );

    if (armyRegiments != null &&
        unit.name.toLowerCase() == 'werewargs' &&
        armyRegiments.any(
            (regiment) => regiment.unit.name.toLowerCase() == 'vargyr lord')) {
      expectedHits = _expectedHits(
        unit.characteristics,
        unit.specialRules,
        stands,
        hasLeader: true,
        forceFlurry: true,
      );
    }

    for (final auxiliary in auxiliaryStands) {
      expectedHits += _expectedHits(
        auxiliary.characteristics,
        auxiliary.specialRules,
        1,
      );
    }

    return expectedHits;
  }

  double _expectedHits(
    UnitCharacteristics characteristics,
    List<SpecialRule> rules,
    int standCount, {
    bool hasLeader = false,
    bool forceFlurry = false,
  }) {
    var totalAttacks = characteristics.attacks * standCount;
    if (hasLeader &&
        rules.any((rule) => rule.name.toLowerCase().contains('leader'))) {
      totalAttacks += 1;
    }

    final hitChance = (characteristics.clash + 1) / 6.0;
    var expectedHits = totalAttacks * hitChance;
    final hasFlurry = forceFlurry ||
        rules.any((rule) => rule.name.toLowerCase().contains('flurry'));
    if (hasFlurry) {
      expectedHits += (totalAttacks - expectedHits) * hitChance;
    }
    return expectedHits;
  }

  /// Calculate impact expected volume for this regiment
  /// Formula: Impact × (Clash ÷ 6) × Stands
  /// Note: Uses base clash (no +1 bonus), no Flurry re-rolls, no Leader bonus
  double calculateImpactExpectedVolume() {
    double expectedImpactHits = _impactFor(
      unit.characteristics,
      unit.numericSpecialRules,
      stands,
    );
    for (final auxiliary in auxiliaryStands) {
      expectedImpactHits += _impactFor(
        auxiliary.characteristics,
        auxiliary.numericSpecialRules,
        1,
      );
    }
    return expectedImpactHits;
  }

  double _impactFor(
    UnitCharacteristics characteristics,
    Map<String, dynamic> numericRules,
    int standCount,
  ) {
    final impact = numericRules['impact'] as int? ?? 0;
    return impact * standCount * characteristics.clash / 6.0;
  }

  /// Calculate ranged expected hits for this regiment
  double calculateRangedExpectedHits() {
    var expectedHits = _rangedHitsFor(
      unit.characteristics,
      unit.numericSpecialRules,
      stands,
      hasLeader: true,
      hasLeaderRule: unit.specialRules
          .any((rule) => rule.name.toLowerCase().contains('leader')),
    );
    for (final auxiliary in auxiliaryStands) {
      expectedHits += _rangedHitsFor(
        auxiliary.characteristics,
        auxiliary.numericSpecialRules,
        1,
      );
    }
    return expectedHits;
  }

  double _rangedHitsFor(
    UnitCharacteristics characteristics,
    Map<String, dynamic> numericRules,
    int standCount, {
    bool hasLeader = false,
    bool hasLeaderRule = false,
  }) {
    final barrage = numericRules['barrage'] as int? ?? 0;
    if (barrage == 0) return 0.0;

    var totalBarrage = barrage * standCount;
    if (hasLeader && hasLeaderRule) totalBarrage += 1;
    return totalBarrage * characteristics.volley / 6.0;
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
