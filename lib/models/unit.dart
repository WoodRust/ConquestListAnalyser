/// Represents the base characteristics and rules for a unit type
class Unit {
  final String name;
  final String faction;
  final String type;
  final String regimentClass;
  final UnitCharacteristics characteristics;
  final List<SpecialRule> specialRules;
  final Map<String, dynamic> numericSpecialRules;
  final List<DrawEvent> drawEvents;
  final int points;
  final int? pointsPerAdditionalStand;
  final String? officerUpgrades;

  const Unit({
    required this.name,
    required this.faction,
    required this.type,
    required this.regimentClass,
    required this.characteristics,
    required this.specialRules,
    required this.numericSpecialRules,
    required this.drawEvents,
    required this.points,
    this.pointsPerAdditionalStand,
    this.officerUpgrades,
  });

  /// Creates a Unit from JSON data
  factory Unit.fromJson(Map<String, dynamic> json) {
    return Unit(
      name: json['name'] as String,
      faction: json['faction'] as String,
      type: json['type'] as String,
      regimentClass: json['regimentClass'] as String,
      characteristics: UnitCharacteristics.fromJson(json['characteristics']),
      specialRules: (json['specialRules'] as List)
          .map((rule) => SpecialRule.fromJson(rule))
          .toList(),
      numericSpecialRules:
          Map<String, dynamic>.from(json['numericSpecialRules']),
      drawEvents: (json['drawEvents'] as List)
          .map((event) => DrawEvent.fromJson(event))
          .toList(),
      points: json['points'] as int,
      pointsPerAdditionalStand: json['pointsPerAdditionalStand'] as int?,
      officerUpgrades: json['officerUpgrades'] as String?,
    );
  }

  /// Calculates total points cost for given number of stands
  int calculatePointsCost(int stands) {
    if (stands <= 1) return points;
    if (pointsPerAdditionalStand == null) return points;
    return points + ((stands - 1) * pointsPerAdditionalStand!);
  }

  /// Gets wounds per stand from characteristics
  int get woundsPerStand => characteristics.wounds;

  @override
  String toString() => 'Unit(name: $name, faction: $faction, points: $points)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Unit && runtimeType == other.runtimeType && name == other.name;

  @override
  int get hashCode => name.hashCode;
}

/// Unit characteristics (stats)
class UnitCharacteristics {
  final int? march;
  final int volley;
  final int clash;
  final int attacks;
  final int wounds;
  final int resolve;
  final int defense;
  final int evasion;

  const UnitCharacteristics({
    this.march,
    required this.volley,
    required this.clash,
    required this.attacks,
    required this.wounds,
    required this.resolve,
    required this.defense,
    required this.evasion,
  });

  factory UnitCharacteristics.fromJson(Map<String, dynamic> json) {
    return UnitCharacteristics(
      march: json['march'] as int?,
      volley: json['volley'] as int,
      clash: json['clash'] as int,
      attacks: json['attacks'] as int,
      wounds: json['wounds'] as int,
      resolve: json['resolve'] as int,
      defense: json['defense'] as int,
      evasion: json['evasion'] as int,
    );
  }
}

/// Special rule definition
class SpecialRule {
  final String name;
  final String description;

  const SpecialRule({
    required this.name,
    required this.description,
  });

  factory SpecialRule.fromJson(Map<String, dynamic> json) {
    return SpecialRule(
      name: json['name'] as String,
      description: json['description'] as String,
    );
  }
}

/// Draw event definition
class DrawEvent {
  final String name;
  final String description;

  const DrawEvent({
    required this.name,
    required this.description,
  });

  factory DrawEvent.fromJson(Map<String, dynamic> json) {
    return DrawEvent(
      name: json['name'] as String,
      description: json['description'] as String,
    );
  }
}
