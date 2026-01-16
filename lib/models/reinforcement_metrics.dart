/// Results from Monte Carlo simulation of reinforcement timing
class ReinforcementMetrics {
  /// Total number of regiments eligible for reinforcement (excludes regular characters)
  final int totalEligibleRegiments;

  /// Percentile arrival percentages for each turn (1-4)
  final List<double> turn1Through4P10;
  final List<double> turn1Through4P20;
  final List<double> turn1Through4P30;
  final List<double> turn1Through4P40;
  final List<double> turn1Through4P50;
  final List<double> turn1Through4P60;
  final List<double> turn1Through4P70;
  final List<double> turn1Through4P80;
  final List<double> turn1Through4P90;

  const ReinforcementMetrics({
    required this.totalEligibleRegiments,
    required this.turn1Through4P10,
    required this.turn1Through4P20,
    required this.turn1Through4P30,
    required this.turn1Through4P40,
    required this.turn1Through4P50,
    required this.turn1Through4P60,
    required this.turn1Through4P70,
    required this.turn1Through4P80,
    required this.turn1Through4P90,
  });

  /// Get percentile for a specific turn (1-4) and percentile level
  double getPercentile(int turn, int percentile) {
    if (turn < 1 || turn > 4) {
      throw ArgumentError('Turn must be between 1 and 4');
    }
    switch (percentile) {
      case 10:
        return turn1Through4P10[turn - 1];
      case 20:
        return turn1Through4P20[turn - 1];
      case 30:
        return turn1Through4P30[turn - 1];
      case 40:
        return turn1Through4P40[turn - 1];
      case 50:
        return turn1Through4P50[turn - 1];
      case 60:
        return turn1Through4P60[turn - 1];
      case 70:
        return turn1Through4P70[turn - 1];
      case 80:
        return turn1Through4P80[turn - 1];
      case 90:
        return turn1Through4P90[turn - 1];
      default:
        throw ArgumentError('Percentile must be 10, 20, 30, 40, 50, 60, 70, 80, or 90');
    }
  }

  /// Get regiment count for a specific turn and percentile
  int getRegimentCount(int turn, int percentile) {
    final percentage = getPercentile(turn, percentile);
    return ((percentage / 100) * totalEligibleRegiments).round();
  }

  /// Get 20th percentile for a specific turn (1-4)
  double getP20(int turn) {
    if (turn < 1 || turn > 4) {
      throw ArgumentError('Turn must be between 1 and 4');
    }
    return turn1Through4P20[turn - 1];
  }

  /// Get 50th percentile (median) for a specific turn (1-4)
  double getP50(int turn) {
    if (turn < 1 || turn > 4) {
      throw ArgumentError('Turn must be between 1 and 4');
    }
    return turn1Through4P50[turn - 1];
  }

  /// Get 80th percentile for a specific turn (1-4)
  double getP80(int turn) {
    if (turn < 1 || turn > 4) {
      throw ArgumentError('Turn must be between 1 and 4');
    }
    return turn1Through4P80[turn - 1];
  }

  /// Convert to JSON for serialization
  Map<String, dynamic> toJson() {
    return {
      'totalEligibleRegiments': totalEligibleRegiments,
      'turn1Through4P10': turn1Through4P10,
      'turn1Through4P20': turn1Through4P20,
      'turn1Through4P30': turn1Through4P30,
      'turn1Through4P40': turn1Through4P40,
      'turn1Through4P50': turn1Through4P50,
      'turn1Through4P60': turn1Through4P60,
      'turn1Through4P70': turn1Through4P70,
      'turn1Through4P80': turn1Through4P80,
      'turn1Through4P90': turn1Through4P90,
    };
  }

  /// Create from JSON
  factory ReinforcementMetrics.fromJson(Map<String, dynamic> json) {
    // Helper function to load percentile data with backward compatibility
    List<double> loadPercentile(String newKey, String oldKey) {
      // Try new format first (4 turns)
      if (json.containsKey(newKey)) {
        return List<double>.from(json[newKey]);
      }
      // Fall back to old format (5 turns) and remove turn 5
      if (json.containsKey(oldKey)) {
        final oldData = List<double>.from(json[oldKey]);
        // Take only first 4 turns, discard turn 5
        return oldData.take(4).toList();
      }
      // If neither exists, return empty list (shouldn't happen)
      return [0, 0, 0, 0];
    }

    return ReinforcementMetrics(
      totalEligibleRegiments: json['totalEligibleRegiments'] as int,
      turn1Through4P10: loadPercentile('turn1Through4P10', 'turn1Through5P10'),
      turn1Through4P20: loadPercentile('turn1Through4P20', 'turn1Through5P20'),
      turn1Through4P30: loadPercentile('turn1Through4P30', 'turn1Through5P30'),
      turn1Through4P40: loadPercentile('turn1Through4P40', 'turn1Through5P40'),
      turn1Through4P50: loadPercentile('turn1Through4P50', 'turn1Through5P50'),
      turn1Through4P60: loadPercentile('turn1Through4P60', 'turn1Through5P60'),
      turn1Through4P70: loadPercentile('turn1Through4P70', 'turn1Through5P70'),
      turn1Through4P80: loadPercentile('turn1Through4P80', 'turn1Through5P80'),
      turn1Through4P90: loadPercentile('turn1Through4P90', 'turn1Through5P90'),
    );
  }

  /// Format for shareable text output
  String toShareableText() {
    final StringBuffer buffer = StringBuffer();
    buffer.writeln('REINFORCEMENT TIMING ($totalEligibleRegiments regiments):');
    
    for (int turn = 1; turn <= 4; turn++) {
      final p20 = getP20(turn).round();
      final p50 = getP50(turn).round();
      final p80 = getP80(turn).round();
      final r20 = getRegimentCount(turn, 20);
      final r50 = getRegimentCount(turn, 50);
      final r80 = getRegimentCount(turn, 80);
      buffer.writeln('Turn $turn: $p20%-$p50%-$p80% ($r20-$r50-$r80 regiments)');
    }
    
    return buffer.toString();
  }

  @override
  String toString() {
    return toShareableText();
  }
}
