import 'package:conquest_analyzer/models/regiment.dart';

/// Represents the base characteristics and rules for a unit type
class Unit {
  final String name;
  final String faction;
  final String type;
  final String regimentClass;
  final String? actualRegimentClass; // For dual character/regiment units
  final UnitCharacteristics characteristics;
  final List<SpecialRule> specialRules;
  final Map<String, dynamic> numericSpecialRules;
  final List<SupremacyAbility> supremacyAbilities;
  final List<DrawEvent> drawEvents;
  final int points;
  final int? pointsPerAdditionalStand;
  final String? officerUpgrades;

  const Unit({
    required this.name,
    required this.faction,
    required this.type,
    required this.regimentClass,
    this.actualRegimentClass,
    required this.characteristics,
    required this.specialRules,
    required this.numericSpecialRules,
    required this.supremacyAbilities,
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
      actualRegimentClass: json['actualRegimentClass'] as String?,
      characteristics: UnitCharacteristics.fromJson(json['characteristics']),
      specialRules: (json['specialRules'] as List)
          .map((rule) => SpecialRule.fromJson(rule))
          .toList(),
      numericSpecialRules:
          Map<String, dynamic>.from(json['numericSpecialRules']),
      supremacyAbilities: (json['supremacyAbilities'] as List? ?? [])
          .map((ability) => SupremacyAbility.fromJson(ability))
          .toList(),
      drawEvents: (json['drawEvents'] as List)
          .map((event) => DrawEvent.fromJson(event))
          .toList(),
      points: json['points'] as int,
      pointsPerAdditionalStand: json['pointsPerAdditionalStand'] as int?,
      officerUpgrades: json['officerUpgrades'] as String?,
    );
  }

  /// Converts Unit to JSON data
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'faction': faction,
      'type': type,
      'regimentClass': regimentClass,
      'actualRegimentClass': actualRegimentClass,
      'characteristics': characteristics.toJson(),
      'specialRules': specialRules.map((rule) => rule.toJson()).toList(),
      'numericSpecialRules': numericSpecialRules,
      'supremacyAbilities':
          supremacyAbilities.map((ability) => ability.toJson()).toList(),
      'drawEvents': drawEvents.map((event) => event.toJson()).toList(),
      'points': points,
      'pointsPerAdditionalStand': pointsPerAdditionalStand,
      'officerUpgrades': officerUpgrades,
    };
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

  Map<String, dynamic> toJson() {
    return {
      'march': march,
      'volley': volley,
      'clash': clash,
      'attacks': attacks,
      'wounds': wounds,
      'resolve': resolve,
      'defense': defense,
      'evasion': evasion,
    };
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

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
    };
  }
}

/// Supremacy ability definition
class SupremacyAbility {
  final String name;
  final String condition;
  final CharacteristicModifier effect;

  const SupremacyAbility({
    required this.name,
    required this.condition,
    required this.effect,
  });

  factory SupremacyAbility.fromJson(Map<String, dynamic> json) {
    final effectJson = json['effect'] as Map<String, dynamic>;
    return SupremacyAbility(
      name: json['name'] as String,
      condition: json['condition'] as String,
      effect: CharacteristicModifier.fromJson(effectJson),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'condition': condition,
      'effect': effect.toJson(),
    };
  }
}

/// Characteristic modifier for supremacy abilities
class CharacteristicModifier {
  final String type;
  final String target;
  final String characteristic;
  final String operation;
  final int value;
  final int? maximum;

  const CharacteristicModifier({
    required this.type,
    required this.target,
    required this.characteristic,
    required this.operation,
    required this.value,
    this.maximum,
  });

  factory CharacteristicModifier.fromJson(Map<String, dynamic> json) {
    final modifierJson = json['modifier'] as Map<String, dynamic>;
    return CharacteristicModifier(
      type: json['type'] as String,
      target: json['target'] as String,
      characteristic: modifierJson['characteristic'] as String,
      operation: modifierJson['operation'] as String,
      value: modifierJson['value'] as int,
      maximum: modifierJson['maximum'] as int?,
    );
  }

  /// Apply this modifier to a characteristic value
  int applyToValue(int baseValue) {
    int result = baseValue;
    switch (operation) {
      case 'add':
        result = baseValue + value;
        break;
      case 'subtract':
        result = baseValue - value;
        break;
      case 'multiply':
        result = baseValue * value;
        break;
      case 'set':
        result = value;
        break;
    }

    // Apply maximum constraint if specified
    if (maximum != null && result > maximum!) {
      result = maximum!;
    }

    // Ensure minimum of 1 for characteristics
    return result < 1 ? 1 : result;
  }

  /// Check if this modifier applies to a specific regiment
  bool appliesTo(Regiment regiment) {
    // For now, we only support "allFriendlyRegiments"
    // This can be extended for more complex targeting

    // Apply to non-character regiments and character monsters
    if (target == 'allFriendlyRegiments') {
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
    }

    return false;
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'target': target,
      'modifier': {
        'characteristic': characteristic,
        'operation': operation,
        'value': value,
        'maximum': maximum,
      },
    };
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

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
    };
  }
}
