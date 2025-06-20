import 'regiment.dart';

/// Represents a complete army list with all regiments and characters
class ArmyList {
  final String name;
  final String faction;
  final int totalPoints;
  final int pointsLimit;
  final List<Regiment> regiments;

  const ArmyList({
    required this.name,
    required this.faction,
    required this.totalPoints,
    required this.pointsLimit,
    required this.regiments,
  });

  /// Calculate total wounds across all regiments
  int get totalWounds =>
      regiments.fold(0, (sum, regiment) => sum + regiment.totalWounds);

  /// Calculate points per wound for the entire list
  double get pointsPerWound => totalPoints / totalWounds;

  /// Get all characters (regimentClass == 'character')
  List<Regiment> get characters =>
      regiments.where((r) => r.unit.regimentClass == 'character').toList();

  /// Get all non-character regiments
  List<Regiment> get nonCharacterRegiments =>
      regiments.where((r) => r.unit.regimentClass != 'character').toList();

  @override
  String toString() =>
      'ArmyList($name, $faction, $totalPoints/$pointsLimit points, ${regiments.length} units)';
}
