import 'regiment.dart';

/// Represents a warband - a character and the regiments under their command
class Warband {
  /// The character leading this warband (must be a regular character, not a character monster)
  final Regiment character;

  /// The regiments in this warband (excluding the character)
  final List<Regiment> regiments;

  const Warband({
    required this.character,
    required this.regiments,
  });

  /// Check if the character has the Forward Force special rule
  bool get hasForwardForce {
    return character.unit.specialRules
        .any((rule) => rule.name.toLowerCase() == 'forward force');
  }

  /// Get the total points cost of this warband (character + regiments)
  int get totalPoints {
    int total = character.pointsCost;
    for (final regiment in regiments) {
      total += regiment.pointsCost;
    }
    return total;
  }

  @override
  String toString() {
    return 'Warband(character: ${character.unit.name}, regiments: ${regiments.length})';
  }
}
