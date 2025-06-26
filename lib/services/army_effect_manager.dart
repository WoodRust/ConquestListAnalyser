import '../models/army_list.dart';
import '../models/regiment.dart';
import '../models/unit.dart';

/// Manages army-wide effects from supremacy abilities and special rules
class ArmyEffectManager {
  /// Get all active characteristic modifiers for the army
  static List<CharacteristicModifier> getActiveEffects(ArmyList armyList) {
    List<CharacteristicModifier> effects = [];

    // Find warlord characters
    final warlords = armyList.regiments
        .where((r) => r.unit.regimentClass == 'character' && r.isWarlord)
        .toList();

    // Apply their supremacy abilities
    for (final warlord in warlords) {
      effects.addAll(_getSupremacyEffects(warlord.unit, armyList));
    }

    return effects;
  }

  /// Get supremacy effects from a warlord character
  static List<CharacteristicModifier> _getSupremacyEffects(
      Unit warlordUnit, ArmyList armyList) {
    List<CharacteristicModifier> effects = [];

    for (final ability in warlordUnit.supremacyAbilities) {
      if (_meetsCondition(ability.condition, warlordUnit, armyList)) {
        effects.add(ability.effect);
      }
    }

    return effects;
  }

  /// Check if a supremacy ability condition is met
  static bool _meetsCondition(String condition, Unit unit, ArmyList armyList) {
    switch (condition) {
      case 'isWarlord':
        // This is already checked when finding warlords
        return true;
      case 'always':
        return true;
      default:
        // For now, unknown conditions default to false
        // This can be extended for more complex conditions
        return false;
    }
  }

  /// Get effective characteristic value considering army effects
  static int getEffectiveCharacteristic(
    Regiment regiment,
    String characteristic,
    List<CharacteristicModifier> armyEffects,
  ) {
    int baseValue;
    // Get base characteristic value
    switch (characteristic) {
      case 'march':
        baseValue = regiment.unit.characteristics.march ?? 0;
        break;
      case 'volley':
        baseValue = regiment.unit.characteristics.volley;
        break;
      case 'clash':
        baseValue = regiment.unit.characteristics.clash;
        break;
      case 'attacks':
        baseValue = regiment.unit.characteristics.attacks;
        break;
      case 'wounds':
        baseValue = regiment.unit.characteristics.wounds;
        break;
      case 'resolve':
        baseValue = regiment.unit.characteristics.resolve;
        break;
      case 'defense':
        baseValue = regiment.unit.characteristics.defense;
        break;
      case 'evasion':
        baseValue = regiment.unit.characteristics.evasion;
        break;
      default:
        return 0;
    }

    // Apply relevant army effects
    for (final effect in armyEffects) {
      if (effect.characteristic == characteristic &&
          effect.appliesTo(regiment)) {
        baseValue = effect.applyToValue(baseValue);
      }
    }

    return baseValue;
  }

  /// Debug method to get a summary of active effects
  static String getEffectsSummary(ArmyList armyList) {
    final effects = getActiveEffects(armyList);
    if (effects.isEmpty) {
      return 'No army-wide effects active';
    }

    final buffer = StringBuffer();
    buffer.writeln('Active Army Effects:');
    for (final effect in effects) {
      buffer.writeln(
          '- ${effect.characteristic} ${effect.operation} ${effect.value}'
          '${effect.maximum != null ? ' (max ${effect.maximum})' : ''}');
    }
    return buffer.toString();
  }
}
