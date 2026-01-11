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

  /// Creates an ArmyList from JSON data
  factory ArmyList.fromJson(Map<String, dynamic> json) {
    return ArmyList(
      name: json['name'] as String,
      faction: json['faction'] as String,
      totalPoints: json['totalPoints'] as int,
      pointsLimit: json['pointsLimit'] as int,
      regiments: (json['regiments'] as List)
          .map((regiment) => Regiment.fromJson(regiment))
          .toList(),
    );
  }

  /// Converts ArmyList to JSON data
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'faction': faction,
      'totalPoints': totalPoints,
      'pointsLimit': pointsLimit,
      'regiments': regiments.map((regiment) => regiment.toJson()).toList(),
    };
  }

  /// Create a copy with modified fields
  ArmyList copyWith({
    String? name,
    String? faction,
    int? totalPoints,
    int? pointsLimit,
    List<Regiment>? regiments,
  }) {
    return ArmyList(
      name: name ?? this.name,
      faction: faction ?? this.faction,
      totalPoints: totalPoints ?? this.totalPoints,
      pointsLimit: pointsLimit ?? this.pointsLimit,
      regiments: regiments ?? this.regiments,
    );
  }

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

  /// Get all character monsters (regimentClass == 'character' AND type == 'monster')
  List<Regiment> get characterMonsters => regiments
      .where((r) =>
          r.unit.regimentClass == 'character' && r.unit.type == 'monster')
      .toList();

  /// Get count of light regiments (excluding characters, but including dual character/regiments)
  int get lightRegimentCount {
    int count = nonCharacterRegiments
        .where((r) => r.unit.regimentClass.toLowerCase() == 'light')
        .length;
    
    // Add character monsters with actualRegimentClass='light'
    count += characterMonsters
        .where((r) => r.unit.actualRegimentClass?.toLowerCase() == 'light')
        .length;
    
    return count;
  }

  /// Get count of medium regiments (excluding characters, but including dual character/regiments)
  int get mediumRegimentCount {
    int count = nonCharacterRegiments
        .where((r) => r.unit.regimentClass.toLowerCase() == 'medium')
        .length;
    
    // Add character monsters with actualRegimentClass='medium'
    count += characterMonsters
        .where((r) => r.unit.actualRegimentClass?.toLowerCase() == 'medium')
        .length;
    
    return count;
  }

  /// Get count of heavy regiments (excluding characters, but including dual character/regiments)
  int get heavyRegimentCount {
    int count = nonCharacterRegiments
        .where((r) => r.unit.regimentClass.toLowerCase() == 'heavy')
        .length;
    
    // Add character monsters with actualRegimentClass='heavy'
    count += characterMonsters
        .where((r) => r.unit.actualRegimentClass?.toLowerCase() == 'heavy')
        .length;
    
    return count;
  }

  /// Get regiment class breakdown as a map
  Map<String, int> get regimentClassBreakdown => {
        'light': lightRegimentCount,
        'medium': mediumRegimentCount,
        'heavy': heavyRegimentCount,
      };

  @override
  String toString() =>
      'ArmyList($name, $faction, $totalPoints/$pointsLimit points, ${regiments.length} units)';
}
